-- Snippets for bats testing
--
local ls = require 'luasnip'
local ft = require 'Comment.ft'
local s = ls.s
local fmt = require('luasnip.extras.fmt').fmt
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local rep = require('luasnip.extras').rep

local test_jq_fmt = [[
    @test "{name}" {{
        run jq -n -c '
            include "{module}";
            {filter}
        '
        assert_success
        assert_output '{output}'
    }}
]]

ls.add_snippets('bash', {
  s(
    'test-jq',
    fmt(test_jq_fmt, {
      name = i(1, 'Test Name'),
      module = i(2, 'Module'),
      filter = i(3, 'filter'),
      output = i(4, 'output'),
    })
  ),
})
