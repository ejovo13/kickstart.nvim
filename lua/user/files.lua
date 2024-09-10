-- Helpful file manipulations
--
--
local files = {}

-- CONSTANTS
GITLAB_CI_FILENAME = '.gitlab-ci.yml'

local function _filename(bufnr)
  bufnr = bufnr or 0
  return vim.api.nvim_buf_get_name(bufnr)
end

-- Gitlab CI
function files.is_gitlab_ci(bufnr)
  return _filename(bufnr) == GITLAB_CI_FILENAME
end

-- Docker compose
function files.is_docker_compose(bufnr)
  local i, _ = string.find(_filename(bufnr), 'docker-compose')
  local cond = (i ~= nil) and (vim.bo.filetype == 'yaml')
  return cond
end

local current_file = vim.api.nvim_buf_get_name(0)

print 'is gitlab CI?'
if files.is_gitlab_ci() then
  print 'Yes!'
else
  print 'Nope.'
end

print 'is docker compose?'
if files.is_docker_compose() then
  print 'Yes!'
else
  print 'Nope.'
end

-- We effectively want a namespace of file commands that quickly let's me determine the file type.

return files
