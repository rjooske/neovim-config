# Terminal mouse forwarding in Neovim

When a TUI program runs inside a Neovim `:terminal` and the mouse wheel is used
while the pointer hovers that terminal's window but **keyboard focus is in
another window**, Neovim scrolls the terminal buffer's scrollback instead of
forwarding the wheel event to the program. For a program that paints its own
scrollable viewport, this reveals stale output above the current screen rather
than scrolling the program.

Neovim already knows whether the program wants mouse events. That knowledge is
private to one C file and is only consulted on one code path — the one that
doesn't apply here.

Findings are against `neovim/neovim` at
`bcf116cc2f2f59e6c0f5ce5a644f832476f77384` (2026-08-20), behavior observed on
0.12.4.

## Reproduce

1. `:vsplit | terminal` and run any program that enables mouse tracking and
   handles wheel events itself (a pager, an editor, a TUI app).
2. Move keyboard focus to the other window, in Normal mode.
3. Hover the pointer over the terminal window and scroll.

Expected: the program scrolls. Actual: Neovim scrolls its own view of the
terminal buffer, exposing scrollback above the program's screen.

## Where the state lives

libvterm reports mouse-tracking changes as the `VTERM_PROP_MOUSE` property.
Neovim stores it in a single struct field:

```c
// src/nvim/terminal.c:184
bool forward_mouse;
```

It is assigned in exactly one place:

```c
// src/nvim/terminal.c:1644
case VTERM_PROP_MOUSE:
  term->forward_mouse = (bool)val->number;
  break;
```

`struct terminal` is defined in `terminal.c` itself — `terminal.h` carries only
the opaque typedef. The field is therefore invisible to every other translation
unit, and there is no API, option, or variable that surfaces it.

## Which code paths consult it

The only reader is `send_mouse_event()` (`src/nvim/terminal.c:2203`), and it has
exactly one caller: the key dispatch inside `terminal_execute()`
(`src/nvim/terminal.c:1133`). That runs only while Terminal mode owns input.

Every other wheel path finds the window under the pointer and scrolls its view,
with no awareness that a terminal is there:

| Mode | Entry point | Behavior |
| --- | --- | --- |
| Normal | `nv_mousescroll` — `src/nvim/mouse.c:1636` | `mouse_find_win_inner()` → `do_mousescroll()` |
| Insert | `ins_mousescroll` — `src/nvim/mouse.c:1081` | same shape |
| Command-line | `cmdline_mousescroll` — `src/nvim/mouse.c:1150` | same shape |
| Terminal | `send_mouse_event` — `src/nvim/terminal.c:2203` | checks `forward_mouse`, forwards to the program |

`do_mousescroll()` (`src/nvim/mouse.c:1049`) is the shared implementation all
four ultimately reach; it is buffer-agnostic by design.

### A second gap on the same field

Even the Terminal-mode path forwards only to the terminal that currently owns
input:

```c
// src/nvim/terminal.c:2215
&& term->forward_mouse && mouse_win->w_buffer->terminal == term && row >= 0
```

With terminal A focused and the pointer over terminal B, the condition fails and
control falls to the scroll branch at `src/nvim/terminal.c:2270`, which calls
`do_mousescroll()` on B — the same stale-scrollback result.

## The stored value is narrower than what libvterm knows

libvterm distinguishes four tracking states, one per DECSET mode:

```c
// src/nvim/vterm/state.c:796
case 1000:
case 1002:
case 1003:
  settermprop_int(state, VTERM_PROP_MOUSE,
                  !val ? VTERM_PROP_MOUSE_NONE
                       : (num == 1000) ? VTERM_PROP_MOUSE_CLICK
                                       : (num == 1002) ? VTERM_PROP_MOUSE_DRAG
                                                       : VTERM_PROP_MOUSE_MOVE);
```

(`VTERM_PROP_MOUSE_NONE` and friends are defined at
`src/nvim/vterm/vterm_defs.h:210`.)

The cast at `terminal.c:1644` flattens all three enabled states to `true`. A
bool is sufficient to gate a wheel event, but the enum is already computed and
carries strictly more information — notably whether the program asked for motion
reporting.

## Not observable from Lua today

`TermRequest` is the natural place to look for a userspace hook, but it fires
only from the OSC, DCS, and APC handlers (`src/nvim/terminal.c:350`, `:387`,
`:410`). Mouse tracking is enabled with the CSI sequence `ESC [ ? 1000 h` (or
1002 / 1003), which is consumed inside `vterm/state.c` and never reaches an
autocommand.

There is consequently no way for a plugin to learn that the program in a
terminal wants mouse events. Any userspace workaround must guess — typically
from the buffer name or the job's argv.

## What a fix could look like

### Option A — expose the flag

Both halves already have precedent in the tree.

An accessor beside the existing ones (`terminal_buf` at
`src/nvim/terminal.c:1513`, `terminal_running` at `:1519`, `terminal_suspended`
at `:1525`):

```c
bool terminal_forward_mouse(const Terminal *term)
  FUNC_ATTR_NONNULL_ALL
{
  return term->forward_mouse;
}
```

And a surface, either:

- a buffer variable such as `b:term_mouse`, following `buf_set_term_title()`
  (`src/nvim/terminal.c:1581`), which sets `b:term_title` the same way; or
- a field on `nvim_get_chan_info()`, which already ships terminal data through
  `terminal_buf()` at `src/nvim/channel.c:1054`.

Exposing the libvterm enum rather than the bool costs nothing extra and avoids a
second round trip if motion reporting ever matters.

This makes correct userspace gating possible, but leaves the default behavior
wrong.

### Option B — fix the hovered-window paths

Teach `nv_mousescroll` / `ins_mousescroll` / `cmdline_mousescroll` that the
window under the pointer may hold a terminal whose program wants the event, and
forward it there instead of calling `do_mousescroll()` — reusing the translation
that `send_mouse_event()` already performs. The same change closes the
focused-A-hovering-B gap.

This fixes every user with no configuration and makes Option A unnecessary for
this purpose. The tradeoff worth discussing upstream is that it silently changes
what the wheel does over an unfocused terminal, so it may warrant an opt-in flag
rather than being unconditional. `term->in_altscreen` (same struct, also
private) is a useful corroborating signal: a full-screen program's Neovim-side
scrollback is meaningless by construction.

## Workaround available today

Intercept the wheel in Lua, and when the pointer is over a chosen terminal
window, write the SGR mouse sequence to the job yourself. `getmousepos()` gives
the window under the pointer regardless of focus or mode, so this works from any
mode and without stealing focus.

```lua
--- Return the bufnr of the terminal to forward to, or nil.
--- There is no way to ask whether the program enabled mouse tracking, so the
--- terminal has to be identified some other way — here, by buffer name.
local function target_terminal_buf()
  local bufnr = vim.fn.bufnr("^my-terminal$")
  if bufnr == -1 or vim.bo[bufnr].buftype ~= "terminal" then
    return nil
  end
  return bufnr
end

-- SGR mouse encoding of wheel buttons 4-7.
local wheel_button = { up = 64, down = 65, left = 66, right = 67 }

--- @param direction "up" | "down" | "left" | "right"
--- @param key string Returned when the pointer is elsewhere, so the default
---   scroll still happens.
local function forward_wheel(direction, key)
  return function()
    local bufnr = target_terminal_buf()
    local pos = vim.fn.getmousepos()
    if
      bufnr == nil
      or pos.winid == 0
      or vim.api.nvim_win_get_buf(pos.winid) ~= bufnr
    then
      return key
    end

    local chan = vim.bo[bufnr].channel
    if chan == 0 then
      return ""
    end

    vim.fn.chansend(
      chan,
      string.format(
        "\27[<%d;%d;%dM",
        wheel_button[direction],
        pos.wincol,
        pos.winrow
      )
    )
    return ""
  end
end

for _, spec in ipairs({
  { lhs = "<ScrollWheelUp>", direction = "up" },
  { lhs = "<ScrollWheelDown>", direction = "down" },
  { lhs = "<ScrollWheelLeft>", direction = "left" },
  { lhs = "<ScrollWheelRight>", direction = "right" },
}) do
  vim.keymap.set(
    { "n", "i", "x", "t" },
    spec.lhs,
    forward_wheel(spec.direction, spec.lhs),
    { expr = true, silent = true }
  )
end
```

Notes on the workaround:

- **Keep the gate narrow.** A program that never enabled mouse tracking receives
  the escape sequence as literal input, so forwarding for every terminal buffer
  is worse than the bug. This is the direct consequence of the missing
  exposure — the correct predicate is not available.
- **One event per wheel tick** matches `mousescroll=ver:1,hor:1`. Repeat the
  sequence to send more per tick.
- **Horizontal wheel support varies by program.** Buttons 66/67 are the xterm
  extension for wheel left/right; programs that don't recognize them typically
  ignore the event, but check the one you target.
- **`expr` mappings are fine here.** `chansend()` inside an expr mapping is not
  blocked by textlock (verified). `vim.keymap.set` also defaults
  `replace_keycodes` to `true` when `expr` is set, so returning the literal
  `"<ScrollWheelUp>"` string as the fallback works.
- **Verify the fallback preserves hover-scrolling.** `:help scroll-mouse-wheel`
  warns that remapping the scroll keys makes the *active* window scroll
  regardless of pointer position, and Vim has a report of exactly that
  ([vim/vim#6898](https://github.com/vim/vim/issues/6898)). Returning the same
  mouse key should keep the position — the hovered-window lookup reads the
  `mouse_row` / `mouse_col` globals, which survive the mapping round trip — but
  it is worth one tick over an unfocused normal window to confirm.

## Verification notes

Source claims above were read directly from the tree at the pinned commit. The
runtime behavior was reported from normal use; it could not be re-tested
programmatically here, because mouse input requires an attached UI and headless
Neovim silently discards `nvim_input_mouse()` — a wheel event sent over a plain
window did not move its topline. Driving an embedded instance as a UI client
from another Neovim also failed (the child exits once the parent, which is not a
real UI client, receives `redraw` notifications). Testing this properly needs a
real UI or the upstream test harness.

## References

- `:help terminal-mouse` — documents that events are forwarded "if the program
  has enabled mouse events", and that a wheel over another window scrolls the
  hovered window.
- `:help scroll-mouse-wheel` — hovered-window scrolling, and the caveat about
  remapped scroll keys.
- `:help 'mouse'` — mode flags `n`, `v`, `i`, `c`, `h`, `a`, `r`; default
  `"nvi"`. There is no `t` flag: Terminal-mode mouse handling is not selected
  through this option.
