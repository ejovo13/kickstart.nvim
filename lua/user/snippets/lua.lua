local ls = require 'luasnip'
local ft = require 'Comment.ft'

-- This is a snippet creator
-- c(<trigger>, <nodes>)
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

ls.add_snippets('lua', {
  -- Lua specific snippets go here.
  s('req', fmt("local{} = require('{}')", { i(1, 'default'), rep(1) })),
})
