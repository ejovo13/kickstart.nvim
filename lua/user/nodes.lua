-- Playing around with nodes!
--
--
--
nodes = {}
local utils = require 'user.utils'
local ts_utils = require 'nvim-treesitter.ts_utils'

-- Check if a key exists in a given table or metatable
function utils.contains(table, key)
  return table[key] ~= nil
end

-- Check if a given function exists for the given object.
function nodes.check_function(ob, fn_name)
  local metadata = getmetatable(ob)
  return utils.contains(metadata, fn_name)
end

-- Compute the height of a tree (or note?)
function nodes.height_node(node)
  if node:child_count() == 0 then
    return 1
  end

  local heights = {}
  for c in node:iter_children() do
    table.insert(heights, nodes.height_node(c))
  end

  return math.max(unpack(heights)) + 1
end

-- Compile a query and execute it against a tree
--
-- Returns
-- -------
-- A list of nodes that were captured.
local function run_query() end

function nodes._retrieve_lineage(node, lineage)
  if node:parent() ~= nil then
    table.insert(lineage, node:parent())
    return nodes._retrieve_lineage(node:parent(), lineage)
  else
    return lineage
  end
end

function nodes.retrieve_lineage(node)
  local ancestors = nodes._retrieve_lineage(node, {})
  -- table.insert(ancestors, 0, node)
  return table.rev(ancestors)
end

function table.len(tbl)
  local count = 0
  for _, _ in ipairs(tbl) do
    count = count + 1
  end
  return count
end

function table.rev(tbl)
  local rev = {}
  local len = table.len(tbl)
  for i = len, 1, -1 do
    table.insert(rev, tbl[i])
  end
  return rev
end

-- Print the ancestry of a given node
function nodes.print_ancestry(node)
  -- Iterate through parents
  local lineage = nodes.retrieve_lineage(node)
  vim.print(lineage)

  print '=========='
  for i, node in ipairs(lineage) do
    print(string.rep('  ', i - 1) .. node:type())
  end
  print(string.rep('  ', table.len(lineage)) .. node:type())
end

-- Return the number of parents that this node has.
function nodes.n_parents(node)
  if node:parent() == nil then
    return 0
  else
    return 1 + nodes.n_parents(node:parent())
  end
end

-- Print the types of children of this node
function nodes.children_types(node)
  for c in node:iter_children() do
    print(c:type())
  end
end

-- Get the root nood of the treesitter tree for a given window
function nodes.get_treesitter_root(winnr)
  local current_node = ts_utils.get_node_at_cursor(winnr)
  local tree = current_node:tree()
  return tree:root()
end

-- Fit a string to a certain length.
function nodes.summarize_string(str, line_len)
  local len_str = string.len(str)
  if len_str > line_len then
    -- Grab the first part
    return string.sub(str, 1, line_len - 3) .. '...'
  else
    return str
  end
end

-- Pretty print a treesitter node.
function nodes.pretty_node(node)
  node = node or error('Node is nil', -1)
  local n_par = nodes.n_parents(node)
  local height = nodes.height_node(node)
  local start_row, _ = node:start()
  local end_row, _ = node:end_()
  return '[TSNode] '
    .. '{ \n  .type = '
    .. node:type()
    .. '\n  .depth = '
    .. n_par
    .. '\n  .height = '
    .. height
    .. '\n  .start_row = '
    .. start_row
    .. '\n  .end_row = '
    .. end_row
    .. '\n}   '
  -- .. summarize_string(utils.get_string_from_node(node, bufnr))
end

function nodes.print_depth(node, depth)
  depth = depth or nodes.n_parents(node)
  print(string.rep('--', depth) .. node:type())
end

function nodes._dfs_depth(node, fn, depth)
  depth = depth or 0
  fn(node, depth) -- second argument totally optational
  for c in node:iter_children() do
    nodes._dfs_depth(c, fn, depth + 1)
  end
end

-- Apply a function
--
--     fn: Node -> Any
--
-- to every node in dfs order.
function nodes.dfs(node, fn)
  fn = fn or function() end -- noop
  nodes._dfs_depth(node, fn)
end

-- Find the first node that matches a given predicate, via dfs
function nodes.dfs_search(node, predicate)
  if predicate(node) then
    return node
  else
    for c in node:iter_children() do
      return nodes.dfs_search(c, predicate)
    end
  end
end

-- Dfs but only call `fn` on nodes satisfying a predicate
function nodes.dfs_filter_apply(node, fn, predicate)
  local wrapper = function(node, depth)
    if predicate(node) then
      fn(node, depth)
    end
  end
  nodes.dfs(node, wrapper)
end

-- Return all nodes that match a given predicate, via dfs.
--
-- Returns
-- -------
-- A table mapping [depth] => {node, node2, ... }
function nodes.dfs_filter_by_depth(node, predicate)
  local ns = {}
  -- fn that will be run when predicate evaluates to true
  local fn = function(n, depth)
    if ns[depth] == nil then
      ns[depth] = {}
      table.insert(ns[depth], n)
    else
      table.insert(ns[depth], n)
    end
  end

  ns.dfs_filter_apply(node, fn, predicate)
  return ns
end

function nodes.dfs_filter(node, predicate)
  local ns = {}
  -- fn that will be run when predicate evaluates to true
  local fn = function(n)
    table.insert(ns, n)
  end

  nodes.dfs_filter_apply(node, fn, predicate)
  return ns
end

-- Function factory for predicate functions that will be used in filters.
--
-- Examples
-- --------
-- > dfs_filter(get_treesitter_root(), print_depth, type_equals('string'))
function nodes.type_equals(type_str)
  return function(node)
    return node:type() == type_str
  end
end

function nodes.type_equals_any(type_list)
  return function(node)
    for _, type in ipairs(type_list) do
      if node:type() == type then
        return true
      end
    end
    return false
  end
end

-- Get a set of types under this node
function nodes.type_names(node)
  local types = {}

  local fn = function(n)
    types[n:type()] = true
  end
  nodes.dfs(node, fn)
  return types
end

-- =================================================
-- =           Function for computing distances
-- =================================================
-- Given a list of nodes, compute the start distance and end distance from a specified line.
function nodes.get_distances(node_list, row_num)
  local out_dist = {}
  for _, node in ipairs(node_list) do
    -- Compute the start distance
    local distances = {}
    local start_row, _ = node:start()
    local end_row, _ = node:end_()
    local start_dist = math.abs(row_num - start_row)
    local end_dist = math.abs(row_num - end_row)
    table.insert(out_dist, math.min(start_dist, end_dist))
  end
  return out_dist
end

function nodes.sort_by_distances(node_list, row_num, desc)
  desc = desc or false

  local distances = nodes.get_distances(node_list, row_num)
  -- We want to sort by distance
  table.sort(distances)
  return distances
end

-- =================================================
-- =            Specific utilities for filtering
-- =================================================
function nodes.get_string_nodes(node)
  local pred = nodes.type_equals 'string'
  local ns = nodes.dfs_filter(node, pred)
  return ns
end

function nodes.get_function_nodes(node)
  local pred = nodes.type_equals_any { 'function_declaration', 'function_definition' }
  local ns = nodes.dfs_filter(node, pred)
  return ns
end

-- Return the next node after the cursor line
function nodes.node_after_cursor(list_node)
  local cursor_line = vim.fn.line '.'

  -- Find the node whose starting distance is the lowest positive number
  for _, node in ipairs(list_node) do
    local start_row, _ = node:start()
    local dist = start_row - cursor_line
    if dist >= 0 then
      return node
    end
  end
  return nil
end

-- Return the node closes to the cursor, ignoring all nodes that come after the cursor.
function nodes.node_before_cursor(list_node)
  local cursor_line = vim.fn.line '.'
  local prev_node = nil

  for _, node in ipairs(list_node) do
    local start_row, _ = node:start()
    local dist = (start_row + 1) - cursor_line
    if dist >= 0 then
      return prev_node
    end
    prev_node = node
  end
  return prev_node
end

-- =================================================
-- =           Functions for jumping
-- =================================================
-- Jump the cursor to a given line using 'G' + line number
function nodes.jump_start_line(rownr)
  vim.cmd('norm! ' .. rownr .. 'G')
  vim.cmd 'norm! 0'
end

function nodes.jump_node(node)
  if node == nil then
    return
  end
  local start_row, start_col = node:start()
  nodes.jump_start_line(start_row + 1)
  vim.fn.cursor(start_row + 1, start_col + 1)
end

-- Examples
-- --------
-- jump_next_class = mk_jump_prev { 'class' }
function nodes.mk_jump_prev(type_list)
  return function()
    local root = nodes.get_treesitter_root()
    local pred = nodes.type_equals_any(type_list)
    local ns = nodes.dfs_filter(root, pred)
    local prev_class_node = nodes.node_before_cursor(ns)
    nodes.jump_node(prev_class_node)
  end
end

function nodes.mk_jump_next(type_list)
  return function()
    local root = nodes.get_treesitter_root()
    local pred = nodes.type_equals_any(type_list)
    local ns = nodes.dfs_filter(root, pred)
    local next_node = nodes.node_after_cursor(ns)
    nodes.jump_node(next_node)
  end
end

-- Get the name of the current file
function utils.current_file()
  return string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), '')
end

-- Wrapper around vim.bo.filetype to get the current file type
function utils.current_file_type()
  return vim.bo.filetype
end

-- ===================================================
-- =                 Public API
-- ===================================================
function nodes.alert_current_node(winnr)
  -- Get the root of the current buffer
  local current_node = ts_utils.get_node_at_cursor(winnr)
  utils.alert(nodes.pretty_node(current_node))
end

-- ===================================================
-- =                Polished keybinds
-- ===================================================
local function jump_map(key, type_list, desc)
  local jump_prev_fn = nodes.mk_jump_prev(type_list)
  local jump_next_fn = nodes.mk_jump_next(type_list)

  vim.keymap.set('n', '[' .. key, jump_prev_fn, { desc = 'Get prev ' .. desc })
  vim.keymap.set('n', ']' .. key, jump_next_fn, { desc = 'Get prev ' .. desc })
end

jump_map('f', { 'function_definition', 'function_declaration' }, '[F]unction')
jump_map('c', { 'class_definition' }, '[C]lass')
jump_map('i', { 'identifier' }, '[I]identifier')
jump_map('t', { 'type' }, '[T]ype')
jump_map('b', { 'block' }, '[B]lock')

utils.alert(utils.current_file_type(), 'Loaded!')

return nodes
