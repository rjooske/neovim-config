local sut = require("indent")

---@param s string
---@return string
local function prettify_test_input(s)
  s = string.gsub(s, " ", "␣")
  s = string.gsub(s, "\t", "⇥")
  s = '"' .. s .. '"'
  return s
end

describe("tab:", function()
  describe("not indented with tabs:", function()
    local tests = { "", "\t", "hi", "  foo", "  \tbar", "123\t", "タ\tブ" }
    for _, test in ipairs(tests) do
      it(prettify_test_input(test), function()
        assert.equals(sut.detect_tab(test), false)
      end)
    end
  end)

  describe("indented with tabs:", function()
    local tests = { "\tabc", "\t\tTEST", "\t  987", "\tあいうえお" }
    for _, test in ipairs(tests) do
      it(prettify_test_input(test), function()
        assert.equals(sut.detect_tab(test), true)
      end)
    end
  end)
end)

describe("spaces:", function()
  describe("not indented with 2 or 4 spaces:", function()
    local tests = { "", "  ", "    ", "fn", "\t  asdf", " 空白", "   three" }
    for _, test in ipairs(tests) do
      it(prettify_test_input(test), function()
        assert.equals(sut.detect_spaces(test, { 4, 2 }), nil)
      end)
    end
  end)

  describe("indented with 2 or 4 spaces:", function()
    local tests = {
      { line = "  func", want = 2 },
      { line = "    WHERE", want = 4 },
      { line = "  \t", want = 2 },
      { line = "    🤔", want = 4 },
    }
    for _, test in ipairs(tests) do
      it(prettify_test_input(test.line), function()
        assert.equals(sut.detect_spaces(test.line, { 4, 2 }), test.want)
      end)
    end
  end)
end)
