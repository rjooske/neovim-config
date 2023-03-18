local sut = require("indent").exported_for_testing

describe("detect tab:", function()
  it("not indented with tabs", function()
    local tests = { "", "\t", "hi", "  foo", "  \tbar", "123\t", "タ\tブ" }
    for _, test in ipairs(tests) do
      assert.equals(sut.detect_tab(test), false)
    end
  end)

  it("indented with tabs", function()
    local tests = { "\tabc", "\t\tTEST", "\t  987", "\tあいうえお" }
    for _, test in ipairs(tests) do
      assert.equals(sut.detect_tab(test), true)
    end
  end)
end)

describe("detect spaces:", function()
  it("not indented with 2 or 4 spaces", function()
    local tests = { "", "  ", "    ", "fn", "\t  asdf", " 空白", "   three" }
    for _, test in ipairs(tests) do
      assert.equals(sut.detect_spaces(test, { 4, 2 }), nil)
    end
  end)

  it("indented with 2 or 4 spaces", function()
    local tests = {
      { line = "  func", want = 2 },
      { line = "    WHERE", want = 4 },
      { line = "  \t", want = 2 },
      { line = "    🤔", want = 4 },
    }
    for _, test in ipairs(tests) do
      assert.equals(sut.detect_spaces(test.line, { 4, 2 }), test.want)
    end
  end)
end)

describe("detect indents:", function()
  it("no indents; no vim options", function()
    local tests = {
      {
        line = "",
        config = { tab_width = 4, space_widths = { 4, 2 } },
      },
      {
        line = " not looking for a single space",
        config = { tab_width = 4, space_widths = { 4, 2 } },
      },
    }
    for _, test in ipairs(tests) do
      assert.equals(sut.detect_tab_or_spaces(test.line, test.config), nil)
    end
  end)

  it("tab-indented; vim options for using tabs", function()
    local tests = {
      {
        input = {
          line = "\tprint('hello world')",
          config = { tab_width = 4, space_widths = { 4, 2 } },
        },
        want = { expandtab = false, shiftwidth = 4, tabstop = 4 },
      },
      {
        input = {
          line = "\t\tint a = 65;",
          config = { tab_width = 8, space_widths = { 4, 2 } },
        },
        want = { expandtab = false, shiftwidth = 8, tabstop = 8 },
      },
    }
    for _, test in ipairs(tests) do
      assert.same(
        sut.detect_tab_or_spaces(test.input.line, test.input.config),
        test.want
      )
    end
  end)

  it("space-indented; vim options for using spaces", function()
    local tests = {
      {
        input = {
          line = "  for (int i = 0; i < 10; i++)",
          config = { tab_width = 4, space_widths = { 4, 2 } },
        },
        want = { expandtab = true, shiftwidth = 2, tabstop = 2 },
      },
      {
        input = {
          line = "        <- 8 spaces",
          config = { tab_width = 4, space_widths = { 8, 4, 2 } },
        },
        want = { expandtab = true, shiftwidth = 8, tabstop = 8 },
      },
      {
        input = {
          line = "   who uses 3 spaces?",
          config = { tab_width = 3, space_widths = { 4, 3, 2 } },
        },
        want = { expandtab = true, shiftwidth = 3, tabstop = 3 },
      },
    }
    for _, test in ipairs(tests) do
      assert.same(
        sut.detect_tab_or_spaces(test.input.line, test.input.config),
        test.want
      )
    end
  end)
end)
