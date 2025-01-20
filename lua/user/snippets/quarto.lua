-- Quarto snippets
--
--
--

-- Snippets for nix packages
local ls = require 'luasnip'
-- local ft = require 'Comment.ft'
local fmt = require('luasnip.extras.fmt').fmt

-- Lua snippet
local s = ls.s

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

-- Actual snippets
--

ls.add_snippets('quarto', {
  s('env', fmt('{{{{< env {} >}}}}', { i(1, 'PATH') })),
  -- s('flake', fmt("{}", { t(test_flake) })),
  -- s('fromFile', ),
})
