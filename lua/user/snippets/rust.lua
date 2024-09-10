-- Rust snippets

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
local comment_width = 80
local ai = require 'luasnip.nodes.absolute_indexer'

ls.add_snippets('rust', {
  s('HelloSnip', fmt('fn {{}}(Test):\n', {})),
  s('pcfn', { t 'pub(crate) fn ', i(1), t '(', i(2), t ')' }),
  s('fn', fmt('fn {}() {{\n\t{}\n}}', { i(1), i(2) })),
  s('pfn', { t 'fn ', i(1), t '(', i(2), t ')' }),

  s(
    'trig',
    fmt('{}\n{}\n{}', {
      i(1, 'text_of_first'),
      i(2, { 'first_line_of_second', 'second_line_of_second' }),
      f(function(args, snip)
        --here
        -- order is 2,1, not 1,2!!
        return '[ ' .. args[1][1] .. ' ]'
      end, { 2, 1 }),
    })
  ),

  s(
    '// line',
    fmt('// {prefix} {} {suffix}\n{}', {
      i(1),
      prefix = f(function(args, snip)
        --here
        -- order is 2,1, not 1,2!!
        return string.rep('=', (comment_width / 2) - (string.len(args[1][1]) / 2) - 2)
      end, { 1 }),
      suffix = f(function(args, snip)
        --here
        -- order is 2,1, not 1,2!!
        return string.rep('=', (comment_width / 2) - (string.len(args[1][1]) / 2) - 2)
      end, { 1 }),
      i(2),
    })
  ),
  s(
    '// block',
    fmt('// {line}\n// {prefix} {}\n// {line}\n{}', {
      i(1),
      prefix = f(function(args, snip)
        return '=' .. string.rep(' ', (comment_width / 2) - (string.len(args[1][1]) / 2) - 3)
      end, { 1 }),
      i(2),
      line = f(function(args, snip)
        return string.rep('=', comment_width - 3)
      end, {}),
    })
  ),
})
