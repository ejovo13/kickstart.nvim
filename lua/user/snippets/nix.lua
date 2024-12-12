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



proc = require('user.snippets.data.proc')
local test_flake = require('user.snippets.data.flake')

-- local notify = require('notify')
-- notify.notify('Trying to read the following file:', '')
-- local output = 'hehe'

-- local output = readLines("testRead.txt")


-- Let's add some snippets for functions in c++
ls.add_snippets('cpp', {
  s('snp-function', fmt("auto {name} = [](\n\t{type} {arg} = {default})\n-> {output} {{\n\t{body}\n}};",
    {
      name = i(1, 'function_name'),
      type = i(2, 'int'),
      arg = i(3, 'arg'),
      default = i(4, '10'),
      output = i(5, 'void'),
      body = i(6),
    })
  )})





ls.add_snippets('nix', {
  s('defaultPackage', fmt("local{} = require('{}')", { i(1, 'default'), rep(1) })),
  -- s('flake', fmt("{}", { t(test_flake) })),
  -- s('fromFile', ),
})

