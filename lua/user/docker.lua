-- Utilities for working with docker and docker compose
--

local tmux = require 'user.tmux'
local ejovo = require 'user.ejovo'

-- Drop the first n_elements from a table
local function drop(t, n_elements)
  local out = {}
  for index, value in ipairs(t) do
    if index > n_elements then
      table.insert(out, index - n_elements, value)
    end
  end
  return out
end

--- List all files in the current working directory
local function list_files()
  local output = vim.fn.system { 'ls', '-1a' }
  local lines = vim.fn.split(output, '\n')
  return drop(lines, 2)
end

--- Extend table t with the elements of an iterator
---@param t Array The array of values to extend
---@param iterator Array iterator of elements to add to t
---@return Array
local function extend(t, iterator)
  local n_el = table.len(t)
  for i, value in ipairs(iterator) do
    table.insert(t, i + n_el, value)
  end
  return t
end

-- List any files in the current directory that have 'docker-compose' in it
local function list_docker_compose_files()
  local files = list_files()
  local p = 'docker-compose[%w%.]*%.ya?ml'
  local docker_files = ejovo.utils.filter_values(files, function(f)
    return string.match(f, p) ~= nil
  end)
  return docker_files
end

--- Execute 'docker command' plus options
---@param cmds List
local function docker_compose(options)
  local dc_command = extend({ 'docker', 'compose' }, options)
  return vim.fn.system(dc_command)
end

local function list_docker_compose_services()
  return docker_compose { 'config', '--services' }
end

local files = list_files()
vim.print(files)
vim.print(list_docker_compose_files())
vim.print(list_docker_compose_services())

-- Check if the current opened directory has a docker compose file in it.
local function has_docker_compose() end

-- First thing to do is list the services that we have
--
local function list_services() end
