---@module tmux some tmux commands
---@author ejovo13
--
--
--
--
--

local tmux = {}

-- Function to jump to a file or a folder
--
--
--
-- tmux.cmd = function(cmd, options)
--   return vim.fn.system { 'tmux', cmd, options }
-- end

tmux.pane_command = function(target_window, target_pane)
  local target = target_window .. '.' .. target_pane
  return vim.fn.system { 'tmux', 'display-message', '-p', '-t', target, '#{pane_current_command}' }
end

--- Retrieve the name of the current session
tmux.current_session = function()
  return vim.fn.system { 'tmux', 'display-message', '-p', '#S' }
end

-- Get the command for every single window

tmux.list_panes = function()
  return vim.fn.system { 'tmux', 'list-panes', '-as' }
end

--- Run a command in tmux
---@param cmd string A tmux command to run (like new-server)
---
--- Examples:
---   run.tmux('new-server') -- Creates a new tmux server
tmux.cmd = function(cmd, background)
  if background then
    return vim.fn.system { 'tmux', cmd, '-d' }
  else
    return vim.fn.system { 'tmux', cmd }
  end
end

local function isnil(value)
  return value == nil
end

-- Some patterns for matching
--
-- Matches:  server_name:<WIN_ID>.<PANE_ID>: [850x899]
local window_pane_pattern = '([%w-_]+):(%d+)%.(%d+):+%s+%[(%d+)x(%d+)%]%s%[[%w%s,/]+%]%s%%%d+'
local is_active_pattern = '%(active%)$'
local function extract_server_window_pane(line)
  local _, _, session, window, pane, width, height = string.find(line, window_pane_pattern)
  local s_idx, _ = string.find(line, is_active_pattern)
  local active = nil
  if isnil(s_idx) then
    active = true
  else
    active = false
  end
  return session, window, pane, width, height, active
end

local test = 'vision_test:1.0: [190x46] [history 0/1000000, 211232 bytes] %11 (active)'
local test = 'vision_test:1.0: [190x46] [history 0/1000000, 211232 bytes] %11'
-- vim.print(string.find(test, window_pane_pattern))
-- vim.print(string.find(test, is_active_pattern))
--
--
-- tmux.kill_window = function()
--   local output = vim.fn.system { 'tmux', 'kill_window' }
-- end

tmux.get_sessions_tree = function()
  local output = vim.fn.system { 'tmux', 'list-panes', '-as' }
  local lines = vim.fn.split(output, '\n')
  vim.print(lines)

  local sessions = {}

  for _, line in ipairs(lines) do
    local s, _, _, _, _, _ = extract_server_window_pane(line)
    if s then
      sessions[s] = {}
    end
  end

  for _, line in ipairs(lines) do
    local s, w, _, _, _, _ = extract_server_window_pane(line)
    if s and w then
      sessions[s][w] = {}
    end
  end

  local str = ''
  for _, line in ipairs(lines) do
    local s, w, p, pw, ph, active = extract_server_window_pane(line)
    active = active or false
    if s and w and p then
      local obj = {
        tonumber(pw),
        tonumber(ph),
        active,
      }

      str = str .. '\n' .. vim.inspect(obj)
      sessions[s][w][p] = obj
    end
  end

  return sessions
end

-- tmux.print_sessions

tmux.delete_last_window = function()
  return vim.fn.system { 'tmux', 'kill-window', '-t', ':$' }
end

tmux.focus_last_window = function()
  tmux.cmd 'last-window'
end

vim.keymap.set('n', ';tw', function()
  tmux.cmd('new-window', true)
end, { desc = '[t]mux [w]indow' })

local function keys(dict)
  local out = {}
  local i = 1
  for key, _ in pairs(dict) do
    table.insert(out, i, key)
    i = i + 1
  end
  return out
end

local e = require 'user.ejovo'

--- Create a new tmux window in the current session that opens up a fish shell then executes a command
---@param shell_cmd string A fish/bash command to execute
---@param background boolean
---@return string
tmux.window_with_command = function(shell_cmd, background, name)
  name = name or 'new-window'
  if shell_cmd == '' then
    shell_cmd = 'clear'
  end
  local cmd
  if background then
    cmd = { 'tmux', 'new-window', '-n', name, '-d', 'fish' }
  else
    cmd = { 'tmux', 'new-window', '-n', name, 'fish' }
  end
  local send_keys = { 'tmux', 'send-keys', '-t', ':$', shell_cmd, 'Enter' }
  vim.print(cmd)
  local _ = vim.fn.system(cmd)
  return vim.fn.system(send_keys)
end

--- Run neovim in a new window opened in the directory specified.
---@param dir string The directory we want to open nvim in.
tmux.nvim = function(dir)
  tmux.window_with_command('cd ' .. dir .. ' && nvim ./')
end

tmux.jump_to_last_window = function()
  local cmd = { 'tmux', 'select-window', '-t', ':$' }
  return vim.fn.system(cmd)
end

---
---@param background boolean Whether or not to open the window in the background
---@return string
tmux.jump_to_directory = function(background)
  local directory = vim.fn.input 'Zoxide jump: '
  local output = vim.fn.system { 'zoxide', 'query', directory }
  vim.print(output)
  return tmux.window_with_command('cd ' .. output .. 'nvim ./', background, directory)
end

tmux.jump_to_command = function(background)
  background = background or false
  local cmd = vim.fn.input 'Execute: '
  local output = tmux.window_with_command(cmd, background)
  return output
end

vim.keymap.set('n', ';tc', function()
  tmux.jump_to_command(true)
end, { desc = 'Start a new [t]mux window with a [c]ommand' })
vim.keymap.set('n', ';tC', tmux.jump_to_command, { desc = 'Start a new [t]mux window with a [c]ommand' })
vim.keymap.set('n', ';tW', tmux.jump_to_last_window, { desc = '[t]mux focus [L]ast window' })
vim.keymap.set('n', ';td', tmux.jump_to_directory, { desc = '[t]mux jump to [d]irectory' })

local function values(dict)
  local out = {}
  local i = 1
  for _, value in pairs(dict) do
    table.insert(out, i, value)
    i = i + 1
  end
  return out
end

e.bash = {}

--- Append contents to a file using bash
---@param content string The content to append
---@param file? string path to a file
e.bash.write = function(content, file)
  file = file or 'out.json'
  content = string.gsub(content, '"', '\\"')
  local cmd = 'sh -c "echo \'' .. content .. '\'" > ' .. file
  vim.print(cmd)
  vim.fn.system(cmd)
end

local print_panes = function()
  local sessions = tmux.get_sessions_tree()
  -- local json = e.utils.json(sessions)
  local json = vim.json.encode(sessions)
  -- Now write this to a file
  e.bash.write(json)
end

local print_fn = function(fn)
  local inner_fn = function()
    vim.print(fn())
  end
  return inner_fn
end

tmux.list_sessions = function()
  local sessions = tmux.get_sessions_tree()
  return keys(sessions)
end

tmux.list_windows = function()
  local sessions = tmux.get_sessions_tree()
  for index, value in ipairs(sessions) do
    vim.print()
  end
end

vim.keymap.set('n', ';tl', tmux.focus_last_window, { desc = '[t]mux [l]ast window' })
vim.keymap.set('n', ';tL', tmux.delete_last_window, { desc = '[t]mux delete [L]ast window' })
-- vim.keymap.set('n', ';tp', tmux.get_sessions_tree, { desc = '[t]mux delete [p]rint [p]anes' })
vim.keymap.set('n', ';tp', print_panes, { desc = '[t]mux [p]rint [p]anes' })
vim.keymap.set('n', ';ts', print_fn(tmux.current_session), { desc = '[t]mux print [s]essions' })
-- vim.keymap.set('n', ';tc', print_fn(tmux.pane_command), { desc = '[t]mux window with [c]ommand' })
-- vim.keymap.set('n', ';tc', print_fn(tmux.pane_command), { desc = '[t]mux window with [c]ommand' })
vim.keymap.set('n', ';tS', print_fn(tmux.list_sessions), { desc = '[t]mux list [S]essions' })

-- Delete the _final_ window in this session

return tmux
