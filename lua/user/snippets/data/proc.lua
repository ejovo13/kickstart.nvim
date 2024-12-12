

---@module proc
---
--- Processing functions for data
---@author 
---@license 

local proc = {}

proc.lines = function(str)
  local result = {}
  for line in str:gmatch '[^\n]+' do
    table.insert(result, line)
  end
  return result
end

-- EJOVO IMPORTS
-- snipppets
local flakes = require('user.snippets.data.flake')
local flake = flakes.basic
local derivations = require('user.snippets.data.derivation')

proc.flake_lines = function()
  return proc.lines(flake)
end

proc.flake_str = function()
  return flake
end

require('notify').notify('Hello!')


vim.print(proc.flake_lines())

-- Now let's map this to nodes
--
--
--
local ejovo = require('user.ejovo')
local ls = require('luasnip')
local t = ls.text_node
local s = ls.s
local i = ls.i
local fmt = require('luasnip.extras.fmt').fmt

local lines = proc.flake_lines()
vim.print("Are lines an array?: " .. tostring(ejovo.utils.is_array(lines)))

local text_nodes = ejovo.utils.map_values(proc.flake_lines(), function(line) return t(line) end)

-- Convert a table into a format string 
--
-- toFormat { x, y, z } => "{}\n{}\n{}"
local toFormat = function(tbl)
  local str = ''
  for _, _ in ipairs(tbl) do
    str = str .. "{}\n"
  end
  return str
end

-- proc.from_template = function(template_str)
--
--

vim.print(toFormat(text_nodes))
vim.print(proc.flake_lines())
vim.print(type(text_nodes))


-- double up squigly brackets. 
-- 
-- doubleBrackets('hi{}') => 'hi{{}}'
local doubleBrackets = function(str) 
  return str:gsub("{", "{{"):gsub("}", "}}")
end

local debracket = function(str)
  return string.gsub(str, "{{}}", "{}")
end

-- local TEMPLATE_MARK = '<<SNIPPET_NODE>>'
local TEMPLATE_MARK = '<<<<SNIPPET_EJOVO_NODE>>>>'
local replaceTemplateMark = function(str)
  return string.gsub(str, TEMPLATE_MARK, '{}')
end


-- Convert a regular str to a luasnip format
--


local template = {}
template.toformatstring = function(str)
  return replaceTemplateMark(doubleBrackets(str))
end

template.toformat = function(str, nodes)
  local fmt_string = template.toformatstring(str)
  return fmt(fmt_string, nodes)
end


template.tonode = function( trigger, str, nodes)
  str = str or 'Default snippet'
  nodes = nodes or {}
  return s(trigger, template.toformat(str, nodes))
end

-- vim.print(template.toformatstring(flake))


ls.add_snippets('nix', {
  -- s('flake', text_nodes)
})

vim.print(template.toformatstring(flakes.package))

local ejovo = require('user.ejovo')

-- Template block/snippet that grabs the name of the current file
local header_template = function()
  return vim.fn.printf(vim.bo.commentstring, ejovo.file.name())
end

local comment = function(str)
  return vim.fn.printf(vim.bo.commentstring, str)
end

local linecomment = function(str)
  return vim.fn.printf("%s\n", comment(str))
end

local current_time = function ()
  return os.date("%Y-%m-%d")
end

local header_block = function()
  return linecomment(ejovo.file.basename()) .. linecomment(current_time()) .. linecomment("")
end


local join = function(delim, lst)
  out = ''
  for i, value in ipairs(lst) do
    out = out .. delim .. tostring(value)
  end
  return out
end

local header_template = function(description, usage, author)
  description = description or 'Some file'
  usage = usage or 'usage..'
  author = author or 'JeancoisFrancois'

  lines = {
    comment('Filename:       ' .. ejovo.file.basename()),
    comment('Author:         ' .. author),
    comment('Date:           ' .. current_time()),
    comment('Description:    ' .. description),
    comment('Usage:          ' .. usage),
  }

  local final = join('\n', lines)
  return final
end


local condensed_header = function()
  return vim.fn.printf("[%s] %s", current_time(), ejovo.file.basename())
end

local clean_header = function() 
  local lines = {
    condensed_header(),
    ' ',
    ' ',
    ' ',
  }

  local comments = ejovo.utils.map_values(lines, function(x) return comment(x) end)
  return join('\n', comments)
end

local clean_header_fmt = function()
  local lines = {
    condensed_header(),
    ' ',
    ' ' .. '{}',
    ' ',
  }

  local comments = ejovo.utils.map_values(lines, function(x) return comment(x) end)
  return join('\n', comments)
end

local clean_header_snippet = function()
  return fmt(clean_header_fmt(), i(1, 'Description'))
end



vim.print(condensed_header())
vim.print(clean_header())

local header_snippet = function()

  lines = {
    comment('Filename:       ' .. ejovo.file.basename()),
    comment('Author:         ' .. '{}'),
    comment('Date:           ' .. current_time()),
    comment('Description:    ' .. '{}'),
    comment('Usage:          ' .. '{}'),
  }
  local final_fmt = join('\n', lines)

  local header_nodes = {
    i(1, 'Some file'),
    i(2, 'JeancoisFrancois'),
    i(3, 'Usage'),
  }

  return fmt(final_fmt, header_nodes)  
end




vim.print(header_block())
vim.print(header_template('desc', 'usage'))

local new_nodes = {
  template.tonode('flake-basic', flake, {i(1)}),
  template.tonode('flake-outputs-documented', flakes.documented, {}),
  template.tonode('flake-package', flakes.package, {i(1), i(2, "derivation")}),
  template.tonode('derivation-basic', derivations.basic, {i(1)}),
  s('header', header_snippet()),
  s('header-clean', clean_header_snippet()),
}


-- Filename:       proc.lua
-- Description:    Something important
-- Author:         Evan Voyles
-- Date:           2024-12-09
-- Usage:          usage..





-- Templates that i want
-- [x] package
-- [ ] wrapper
-- [ ] c project
-- [ ] cmake project



-- [2024-12-09] proc.lua
-- 
--  Something that I want
-- 



ls.add_snippets('nix', new_nodes)
ls.add_snippets('lua', new_nodes)

-- [2024-12-09] proc.lua
--  
--  Description
--  

return proc
