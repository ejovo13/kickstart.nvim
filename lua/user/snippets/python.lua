-- Python snippets.
--
local ls = require 'luasnip'
local ft = require 'Comment.ft'

local s = ls.s

-- This is a format node.
-- It takes a format string and a list of nodes
-- fmt(<fmt_string>, {...nodes})
local fmt = require('luasnip.extras.fmt').fmt

-- This is an insert node
-- It takes a position (like $1) and optionally some default text
-- i(<position>, [default_text])
local i = ls.insert_node

-- Text node
local t = ls.text_node

-- Function node
local f = ls.function_node

-- Repeats a node
-- rep(<position>)
local rep = require('luasnip.extras').rep

ls.add_snippets('python', {
  s('Settings', fmt('class {}(BaseSettings):\n    """Pydantic Settings {}."""\n    {}', { i(1), i(2), i(3) })),
  s('def', fmt('def {}({}){}: \n\t{}\n', { i(1), i(2), i(3), i(4) })),
  s('Examples', fmt('    Examples\n    --------\n    ```\n    >>> {}\n    ```', { i(1) })),
  s('main', fmt('if __name__ == "__main__":\n    {}', i(1))),
  s('idc', t 'from dataclasses import dataclass'),
  s('dc', fmt('@dataclass\nclass {}:\n    {}', { i(1, 'Data'), i(2, 'pass') })),
})
