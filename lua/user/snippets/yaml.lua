-- Snippets for yaml files
--
-- In particular, define snippets for getting started with quarto documents
--
--

local ls = require 'luasnip'
local ft = require 'Comment.ft'
local s = ls.s
local fmt = require('luasnip.extras.fmt').fmt
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local rep = require('luasnip.extras').rep

local book_template = [[
project:
  type: book

book:
  title: "{title}"
  author: "Evan Voyles"
  chapters:
    - index.qmd
    # - part: part_1/index.qmd
    #  chapters:
    #    - part_1/chapter_1.qmd
    #    - part_1/chapter_1.qmd

format:
  html:
    theme: cyborg
]]

ls.add_snippets('yaml', {
  s(
    'quarto-book',
    fmt(book_template, {
      title = i(1, 'Title'),
    })
  ),
})
