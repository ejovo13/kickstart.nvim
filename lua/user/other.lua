---@module other
---@author Evan Voyles
---@license
--
--

-- Get functions that process directories.
--

local nodes = require 'user.nodes'
local ejovo = require 'user.ejovo'

-- local pattern = '(%a+%.py):(%d+)'
local pattern = '([%a_/%.%d]+):(%d+)'
local test = 'nvim_mgr/__init__.py:18 in public class `AppState`:'

--- Extract the full path of a file (as reported by pre-commit) and the line where the error was called
---@param line
local function extract_path_and_pos(line)
  local s_idx, e_idx, path, pos = string.find(line, pattern)
  return path, pos
end

local real_ex = 'File "/home/ejovo/Fentech/Vision/viewcreator/viewcreator/kafka_utils.py", line 12'

local python_err_pattern = 'File "([%p%a%d]+)", line (%d+)'

local function extract_path_and_pos_python_error(line)
  local s_idx, e_idx, path, line_n = string.find(line, python_err_pattern)
  return path, line_n
end

assert(extract_path_and_pos_python_error(real_ex), 'Something is wrong with the python error pattern!')

--- Insert a list of lines to the front of a buffer
---@param bufnr buffer
---@param lines List[string]
local insert_buffer = function(bufnr, lines)
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
end

--- Append a list of lines to the end of a buffer
---@param bufnr buffer
---@param lines List[string]
local append_buffer = function(bufnr, lines)
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
end

--- Feed the stdout of a given list of args into the end of a buffer
---@param bufnr buffer
---@param args List[string]
local feed_buffer = function(bufnr, args)
  vim.fn.jobstart(args, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      if data then
        append_buffer(bufnr, data)
      end
    end,
  })
end

-- local wait_duration_s =
-- local wait_cmd = string.format('sleep %dm', wait_duration_s * 1000)
--
--
-- append_buffer(split_buffer, { 'This', 'is', 'Dope', '' })
-- feed_buffer(split_buffer, { 'ls', '-1' })
-- feed_buffer(split_buffer, { 'sleep', '4' })
-- feed_buffer(split_buffer, { 'which', 'ls' })
-- -- feed_buffer(split_buffer, { 'pre-commit', 'run', '--files', start_file_name })
-- feed_buffer(split_buffer, { 'tokei', start_file_name })
-- feed_buffer(split_buffer, { 'which', 'tokei' })
-- feed_buffer(split_buffer, { 'git', 'status' })
--
-- append_buffer(split_buffer, { 'This', 'is', 'Coolio', '' })
-- feed_buffer(split_buffer, { 'bash', '/home/ejovo/Programming/Bash/new.sh' })
--
-- feed_buffer(split_buffer, { '/home/ejovo/Programming/Bash/list_dir.sh' })
--
--

-- list_directories =
--
--
--
-- local ls_file_pattern =
--
--
--
--
--

---
--
local function read_only_tab_fake(tab_name)
  tab_name = tab_name or 'Test'
  vim.cmd('tabnew ' .. tab_name)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true, desc = 'Quit' })

  local mappings = {
    i = '<nop>',
    I = '<nop>',
    a = '<nop>',
    A = '<nop>',
    o = '<nop>',
    O = '<nop>',
    d = '<nop>',
    D = '<nop>',
    x = '<nop>',
    J = '<nop>',
    c = '<nop>',
    C = '<nop>',
    p = '<nop>',
    P = '<nop>',
    r = '<nop>',
    s = '<nop>',
    S = '<nop>',
    ['~'] = '<nop>',
    ['g~'] = '<nop>',
    gv = '<nop>',
    -- Add more insert mode commands if needed
  }

  local mappings_v = {
    d = '<nop>',
    D = '<nop>',
    x = '<nop>',
    c = '<nop>',
    C = '<nop>',
    I = '<nop>',
    p = '<nop>',
    P = '<nop>',
    r = '<nop>',
    u = '<nop>',
    U = '<nop>',
    s = '<nop>',
    S = '<nop>',
    ['~'] = '<nop>',
    ['g~'] = '<nop>',
    gv = '<nop>',
  }

  -- Apply the mappings to the specified buffer
  for lhs, rhs in pairs(mappings) do
    vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, { noremap = true, silent = true })
  end

  -- Visual mode
  for lhs, rhs in pairs(mappings_v) do
    vim.api.nvim_buf_set_keymap(bufnr, 'v', lhs, rhs, { noremap = true, silent = true })
  end

  return bufnr
end

local function do_something_teehee()
  local start_file_bufnr = vim.api.nvim_get_current_buf()
  local start_file_name = ejovo.file.name(start_file_bufnr)
  local split_buffer = read_only_tab_fake()

  insert_buffer(split_buffer, { 'Home Navigation' })
  feed_buffer(split_buffer, { 'tokei', start_file_name })
  feed_buffer(split_buffer, { '/home/ejovo/Programming/Bash/test.sh', '/home/ejovo' })
  feed_buffer(split_buffer, { '/home/ejovo/Programming/Bash/tmux_sessions.sh', '/home/ejovo' })
  feed_buffer(split_buffer, { 'zoxide', 'query', '-sl' })
end

-- Do something when we send a certain key
local function f()
  local current_line = vim.api.nvim_get_current_line()
  local path, pos = extract_path_and_pos(current_line)
  if path == nil then
    path, pos = extract_path_and_pos_python_error(current_line)
  end

  if path then
    vim.print(path .. ':' .. pos)
    vim.cmd('vnew ' .. path)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true, desc = 'Quit' })
    nodes.jump_start_line(pos)
  else
    vim.print 'Nill!'
  end
end

vim.keymap.set('n', '<C-k>', do_something_teehee)
vim.keymap.set('v', '<C-k>', do_something_teehee)
vim.keymap.set('n', '<C-j>', f)
vim.keymap.set('v', '<C-j>', f)

-- vim.bo[split_buffer].readonly = true
