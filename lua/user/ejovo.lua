---@module ejovo
---@author
---@license
--
-- Random utilities for working with nvim

local ejovo = {}
--- Submodule for working with files
ejovo.file = {}
--- Submodule for working with buffers
ejovo.buffer = {}
--- Submodule for random helper functions
ejovo.utils = {}
--- Submodule for random directory things
ejovo.dir = {}
--- Some random Vision stuff
ejovo.vision = {}
ejovo.fs = {}

--- Create a new tab that can be deleted with q
---@param tab_name string The name of your new tab; defaults to 'New Tab'
---@return buffer The newly created buffer
ejovo.buffer.new_tab = function(tab_name)
  tab_name = tab_name or ''
  vim.cmd('tabnew ' .. tab_name)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true, desc = 'Quit' })
  return bufnr
end

ejovo.buffer.read_only_fake = function(tab_name)
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

--- Retrieve the file _name_ of the current buffer
---@param bufnr integer
---@return string
ejovo.file.name = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(bufnr)
end

--- Retrieve the file _type_ the current buffer. Ex: 'python', 'lua'
---@param bufnr integer
---@return string
ejovo.file.type = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_option(bufnr, 'filetype')
end

--- Retrieve the comment string of a given buffer
---@param bufnr integer
---@return string
ejovo.file.comment_string = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_option(bufnr, 'commentstring')
end

ejovo.file.basename = function()
  return vim.fn.expand("%:t")
end

ejovo.file.info = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return {
    name = ejovo.file.name(bufnr),
    type = ejovo.file.type(bufnr),
    comment_string = ejovo.file.comment_string(bufnr),
  }
end

-- ~ Buffers ~
--
--

--- Create a new, vertical read only buffer
---@param vertical boolean
---@return buffer
ejovo.buffer.read_only = function(vertical)
  vertical = vertical or true
  if vertical then
    vim.api.nvim_command 'vnew'
  else
    vim.api.nvim_command 'new'
  end
  local bufnr = vim.api.nvim_create_buf(true, true)
  vim.bo[bufnr].readonly = true
  return bufnr
end

--- Retrieve a list of all buffers, loaded or unloaded. See vim.api.nvim_list_bufs for more.
---@return List[integer]
ejovo.buffer.list = function()
  return vim.api.nvim_list_bufs()
end

--- Retrieve a list of buffers that are currently loaded
---@return List
ejovo.buffer.loaded = function()
  local buf_list = ejovo.buffer.list()
  return ejovo.utils.filter_values(buf_list, vim.api.nvim_buf_is_loaded)
end

--- Drop the first n elements of an arrya
---@param t Array
---@param n integer The number of elements to drop
ejovo.utils.drop = function(t, n)
  local out = {}
  for index, value in ipairs(t) do
    if index > n then
      table.insert(out, index - n, value)
    end
  end
  return out
end

-- ejovo.utils.map_keys = function(t, fn)
--   local out = {}
--
--   if ejovo.utils.is_array(t) then
--     for index, _ in ipairs(t) do
--       table.insert(out, index, fn(index))
--     end
--   else
--     for key, _ in pairs(t) do
--       out[key] = fn(key)
--     end
--   end
--
--   return out
-- end

--- Apply a function for all values in a tables key, value pairs
---@param t
---@param fn
ejovo.utils.map_values = function(t, fn)
  local out = {}

  if ejovo.utils.is_array(t) then
    for index, value in ipairs(t) do
      table.insert(out, index, fn(value))
    end
  else
    for key, value in pairs(t) do
      out[key] = fn(value)
    end
  end

  return out
end

--- Apply a predicate filter on a table's keys
---@param list any[]
---@param predicate function
ejovo.utils.filter_keys = function(list, predicate)
  local result = {}
  for key, value in pairs(list) do
    if predicate(key) then
      table.insert(list, -1, value)
    end
  end
  return result
end

--- Apply a predicate filter on a table's values
---@param list any[]
---@param predicate function
ejovo.utils.filter_values = function(list, predicate)
  local result = {}

  local n_true = 0

  if ejovo.utils.is_array(list) then
    for _, value in ipairs(list) do
      if predicate(value) then
        n_true = n_true + 1
        table.insert(result, n_true, value)
      end
    end
  else
    for key, value in pairs(list) do
      if predicate(value) then
        result[key] = value
      end
    end
  end
  return result
end

--- Apply a predicate filter on a table's key and values
---@param list any[]
---@param predicate function
ejovo.utils.filter = function(list, predicate)
  local result = {}
  for key, value in pairs(list) do
    if predicate(key, value) then
      result[key] = value
    end
  end
  return result
end

ejovo.utils.curl = function(host, port, endpoint)
  host = host or 'localhost'
  port = port or 8881
  endpoint = endpoint or '/'
  return vim.fn.system('curl -s ' .. host .. ':' .. port .. endpoint)
end

ejovo.utils.url = function(protocol, host, port, endpoint)
  protocol = protocol or 'http'
  host = host or 'localhost'
  port = port or 8881
  endpoint = endpoint or '/'
  return protocol .. '://' .. host .. ':' .. port .. endpoint
end

--- Post json data to an application using curl
---@param host string
---@param port integer
---@param endpoint string
---@param data table
ejovo.utils.post = function(host, port, endpoint, data)
  local url = ejovo.utils.url(nil, host, port, endpoint)
  local cmd = 'curl -s -X POST ' .. url .. ' -H "Content-Type: application/json" -d ' .. ejovo.utils.wrap(ejovo.utils.json(data), "'")
  return vim.fn.system(cmd)
end

ejovo.utils.is_mgr_running = function()
  local output = ejovo.utils.curl()
  if string.find(output, 'Alive') then
    return true
  else
    return false
  end
end

--- Wrap a string with quotation marks
---@param s string
ejovo.utils.wrap = function(s, mark)
  mark = mark or '"'
  return (mark .. s .. mark)
end

--- Count the number of non key value pairs
ejovo.utils.array_len = function(table)
  local count = 0
  for _, _ in ipairs(table) do
    count = count + 1
  end
  return count
end

--- Iterate over all elemenents but the last
ejovo.utils.all_but_one = function(table, fn, is_array)
  is_array = is_array or false
  local count = 0
  local i = 1
  if is_array then
    count = ejovo.utils.element_count(table)
    for _, value in ipairs(table) do
      if i == count then
        return value
      else
        fn(value)
      end
      i = i + 1
    end
  else
    count = ejovo.utils.key_count(table)
    for key, value in pairs(table) do
      if i == count then
        return key, value
      else
        fn(key, value)
      end
      i = i + 1
    end
  end
end

--- Count the number of key, value pairs present in a table
ejovo.utils.element_count = function(table)
  local count = 0
  for _, _ in pairs(table) do
    count = count + 1
  end
  return count
end

---
---@param t table
ejovo.utils.key_count = function(t)
  return ejovo.utils.element_count(t) - ejovo.utils.array_len(t)
end

--- Retrieve the rhs string for a value in a json object.
---@param value
ejovo.utils.json_value = function(value)
  local t = type(value)
  if t == 'string' then
    return ejovo.utils.wrap(value)
  elseif t == 'number' then
    return tostring(value)
  elseif t == 'table' then
    if ejovo.utils.is_array(value) then
      local prefix = '['
      local suffix = ']'
      local s = prefix

      local lambda = function(val)
        return s .. ejovo.utils.json_value(val)
      end

      local lambda_comma = function(val)
        s = lambda(val) .. ', '
      end

      local lvalue = ejovo.utils.all_but_one(value, lambda_comma, true)
      s = lambda(lvalue)
      return s .. suffix
    else
      local prefix = '{'
      local suffix = '}'
      local s = prefix

      local lambda = function(key, val)
        return s .. ejovo.utils.wrap(key) .. ': ' .. ejovo.utils.json_value(val)
      end

      local lambda_comma = function(key, val)
        s = lambda(key, val) .. ', '
      end

      local lkey, lvalue = ejovo.utils.all_but_one(value, lambda_comma)
      s = lambda(lkey, lvalue) .. suffix
      return s
    end
  else
    return 'ERROR'
  end
end

--- Represent this object as json
---@param v any
ejovo.utils.json = function(v)
  return ejovo.utils.json_value(v)
end

--- Return true if the table has only key-value pairs
---@param value any
ejovo.utils.is_object = function(value)
  if type(value) ~= 'table' then
    return false
  else
    return ejovo.utils.key_count(value) == ejovo.utils.element_count(value)
  end
end

--- Return true if the table has no key value pairs
---@param value any
ejovo.utils.is_array = function(value)
  if type(value) ~= 'table' then
    return false
  else
    return ejovo.utils.key_count(value) == 0
  end
end

-- Retrieve the names of all the buffers that we currently have opened
ejovo.file.loaded = function()
  local buf_list = ejovo.buffer.loaded()
  -- Including empty files!
  local all_files = ejovo.utils.map_values(buf_list, ejovo.file.name)
  return ejovo.utils.filter_values(all_files, function(n)
    return n ~= ''
  end)
end

-- Shorthand for posting to this application
local function post(data, endpoint)
  return ejovo.utils.post(nil, nil, endpoint, data)
end

ejovo.utils.server_name = function()
  local output = vim.fn.execute 'echo v:servername'
  return string.gsub(output, '\n', '')
end

--- Create the payload that reporst the files that this instance is currently editing
local function file_payload(msg)
  msg = msg or 'Hello World'
  local server = ejovo.utils.server_name()
  return { loaded_files = ejovo.file.loaded(), message = msg, server = server }
end

local function report_files()
  local payload = file_payload 'Some files :)'
  post(payload, '/files')
end

local function identity()
  return { server = ejovo.utils.server_name() }
end

local function register()
  return post(identity(), '/register')
end

local function disconnect()
  return post(identity(), '/disconnect')
end

local file_with_spaces_pattern = "'(.+)'$"
local file_end_pattern = '([%w%p]+)$'

--- List directories in a given directory
---@param dir
ejovo.dir.list = function(dir)
  dir = dir or '.'
  local cmds = {
    'ls',
    '-l',
    dir,
    -- '|',
    -- 'grep',
    -- '^d',
    -- '|',
    -- 'awk',
    -- '{print $NF}',
  }
  local out = vim.fn.system(cmds)
  local lines = vim.fn.split(out, '\n')
  local files = ejovo.utils.drop(lines, 1)

  -- Only save items that start with d
  local dir_entries = ejovo.utils.filter_values(files, function(v)
    local m, _ = string.match(v, '^d.*')
    return m
  end)

  local extract_file_name = function(ls_entry)
    local file_with_spaces = string.match(ls_entry, file_with_spaces_pattern)
    local file = file_with_spaces or string.match(ls_entry, file_end_pattern)
    return file
  end

  return ejovo.utils.map_values(dir_entries, extract_file_name)
end

ejovo.utils.tail = function(t, tail_length)
  local n = table.len(t)
  local stop_idx = n - tail_length
  local out = {}
  for index, value in ipairs(t) do
    if index > stop_idx then
      table.insert(out, value)
    end
  end
  return out
end

--- Retrieve the first n elements of an array.
---@param t List
---@param n integer
---@return List
ejovo.utils.head = function(t, n)
  local out = {}
  for index, value in ipairs(t) do
    if index <= n then
      table.insert(out, value)
    end
  end
  return out
end

ejovo.utils.drop_last = function(t)
  return ejovo.utils.head(t, table.len(t) - 1)
end

ejovo.utils.drop_first = function(t)
  return ejovo.utils.tail(t, table.len(t) - 1)
end

--- Split off the last element and return a tupl (drop_last, tail)
---@param t
ejovo.utils.chip_off = function(t)
  return ejovo.utils.drop_last(t), t[table.len(t)]
end

ejovo.utils.decapitate = function(t)
  return t[1], ejovo.utils.drop_first(t)
end

-- vim.print(ejovo.utils.tail({ 'hi', 'mmom' }, 1))
-- vim.print(ejovo.utils.head({ 'hi', 'mmom' }, 1))
-- vim.print(ejovo.utils.head({ 'hi', 'mmom' }, 2))
-- vim.print(ejovo.utils.decapitate { 'hi', 'mmom', 'booty' })
-- vim.print(ejovo.utils.chip_off { 'hi', 'mmom' })

--- Get the parent directory of a file
---@param file_name string Full path to a file
---@param delimiter string
---@return
ejovo.fs.parent_directory = function(file_name, delimiter)
  -- Assuming a file is in the format /some/path/to/thing.ext
  --
  delimiter = delimiter or '/'
  local components = vim.fn.split(file_name, delimiter)
  vim.print(head_n)
  local head_n = ejovo.utils.head(components, table.len(components) - 1)
  -- vim.print('Head: [' .. head .. ']')
  -- return vim.fn.join(head, delimiter)
end

-- vim.print(ejovo.fs.parent_directory '/sup/poop/')

local function value_in(v, t)
  for _, value in ipairs(t) do
    if value == v then
      return true
    end
  end
  return false
end

--- Remove elements from a list.
---@param t Array
---@param to_drop Array | string
ejovo.utils.remove = function(t, to_drop)
  if type(to_drop) == 'string' then
    to_drop = { to_drop }
  end
  return ejovo.utils.filter_values(t, function(v)
    return not value_in(v, to_drop)
  end)
end

--- Retrieve the last element of t
---@param t List
ejovo.utils.last = function(t)
  local n = table.len(t)
  if n == 0 then
    return {}
  end
  for index, value in ipairs(t) do
    if index == n then
      return value
    end
  end
end


ejovo.join = function(delim, lst)
  local out = ''
  for i, value in ipairs(lst) do
    if i > 1 then
    out = out .. delim .. tostring(value)
        else
    out = value
        end
  end
  return out
end

-- Custom error message
ejovo.error = function(error_name, lines)
  error_name = error_name or 'GenericError'
  local hdr0 = "=========================="
  local hdr = vim.fn.printf("<Error.%s>", error_name)
  -- Insert header "after" error header
  table.insert(lines, 1, hdr0)
  table.insert(lines, 1, hdr)
  table.insert(lines, 1, hdr0)
  local lines_prefixed = ejovo.utils.map_values(lines, function(l) return "    " .. l end)
  table.insert(lines_prefixed, 1, '')
  local message = ejovo.join('\n', lines_prefixed)
  return error(message)
end

-- to execute the function

ejovo.server = {}
ejovo.server.identity = identity
ejovo.server.register = register
ejovo.server.disconnect = disconnect
ejovo.server.is_running = ejovo.utils.is_mgr_running
ejovo.server.report_files = report_files

return ejovo
