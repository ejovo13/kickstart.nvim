if utils then
  return
end
utils = {}

function utils.get_string_from_range(start_row, start_col, end_row, end_col, bufnr)
  local lines = {}
  local buf = bufnr or vim.api.nvim_get_current_buf()

  -- print("Using range: [" .. start_row .. ":" .. start_col .. ", " .. end_row .. ":" .. end_col .. "]")

  if start_row == end_row then
    local line_text = vim.api.nvim_buf_get_lines(buf, start_row - 1, start_row, false)[1]
    return line_text:sub(start_col + 1, end_col)
  end

  for row = start_row, end_row do
    local line_text = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]

    if row == start_row then
      line_text = line_text:sub(start_col)
    end

    if row == end_row then
      line_text = line_text:sub(1, end_col)
    end

    table.insert(lines, line_text)
  end

  return table.concat(lines, '\n')
end

-- Wrapper around nvim_get_current_buf
function utils.current_buf()
  return vim.api.nvim_get_current_buf()
end

-- Get the number of lines in a given buffer
function utils.n_lines()
  return vim.fn.line '$'
end

-- Retrieve a string given a node from the treesitter parsed tree
function utils.get_string_from_node(tree_node, buf)
  local sr, sc, er, ec = tree_node:range()
  local str = utils.get_string_from_range(sr + 1, sc, er + 1, ec, buf)
  return str
end

--
-- Create a tree from a given buffer.
--
function utils.get_tree(bufnr)
  local parser = vim.treesitter.get_parser(bufnr)
  local tree = parser:parse { 0, -1 }
  return tree[1]
end

-- Get function declarations in a given tree
--
function utils.get_function_declarations(tree)
  return utils.get_nodes(tree, 'function_declaration', 'function')
end

-- Retrieve a dictionary of a function name and the node that encapsulates a functions parameters
function utils.get_function_parameters(tree)
  local func_nodes = utils.get_function_declarations(tree)
  -- Array of function names
  local func_names = {}
  local func_parameters = {}

  for _, node in pairs(func_nodes) do
    -- Now try and get the function name
    local fn_name = ''
    for c in node:iter_children() do
      if c:type() == 'identifier' then
        fn_name = utils.get_string_from_node(c)
        table.insert(func_names, fn_name)
      end

      if c:type() == 'parameters' then
        func_parameters[fn_name] = c
      end
    end
  end

  return func_parameters
end

-- Extract the names of functions declared in a given tree
function utils.extract_function_names(tree)
  local func_nodes = utils.get_function_declarations(tree)
  local func_names = {}

  for _, node in pairs(func_nodes) do
    -- Now try and get the function name
    for c in node:iter_children() do
      -- Extract the names of the functions
      if c:type() == 'identifier' then
        local fn_name = utils.get_string_from_node(c)
        table.insert(func_names, fn_name)
      end
    end
  end

  return func_names
end

-- Extract function names as well as argument names.
function utils.extract_function_and_argument_names(tree)
  -- Table maping fn_name => (parameters) ts node
  local func_parameters = utils.get_function_parameters(tree)
  local func_arguments = {}

  for fn_name, params in pairs(func_parameters) do
    local param_names = {}
    for p in params:iter_children() do
      if p:type() == 'identifier' then
        local p_name = utils.get_string_from_node(p)
        table.insert(param_names, p_name)
      end
    end
    func_arguments[fn_name] = param_names
  end

  return func_arguments
end

-- Retrieve a list of argument names when given a function
function utils.extract_argument_names(tree, fn_name)
  local func_arguments = utils.extract_function_and_argument_names(tree)
  return func_arguments[fn_name]
end

-- Retrieve the function declaration node that was declared on line `row_num`
function utils.function_declaration_on_line(tree, row_num)
  local func_decs = utils.get_function_declarations(tree)
  for _, node in ipairs(func_decs) do
    local start_row, _ = node:start()
    if start_row == row_num then
      return node
    end
  end
end

-- Retrieve the first identifier (as a string) for a given node.
function utils.get_node_identifier(tree_node, bufnr)
  local buf = bufnr or vim.api.nvim_get_current_buf()

  for c in tree_node:iter_children() do
    if c:type() == 'identifier' then
      return utils.get_string_from_node(c, buf)
    end
  end
  error('No identifier found for tree_node: ' .. tree_node, 10)
end

-- Compute the distance between all functions and a given line
--
-- Returns
-- -------
-- A mapping between `fn_name` => start_distance
function utils.function_declaration_distances(tree, row_num, bufnr)
  local fn_decs_distances = {}
  local fn_decs = utils.get_function_declarations(tree)
  for _, node in ipairs(fn_decs) do
    local fn_name = utils.get_node_identifier(node, bufnr)
    local start_row, _ = node:start()
    local end_row, _ = node:end_()

    local start_dist = math.abs(row_num - start_row)
    local end_dist = math.abs(row_num - end_row)
    local min_dist = math.min(start_dist, end_dist)

    fn_decs_distances[fn_name] = min_dist
  end

  return fn_decs_distances
end

-- Get the name of the nearest function
function utils.nearest_function(tree, row_num, bufnr)
  local min_dist = nil
  local min_fname = nil
  local distances = utils.function_declaration_distances(tree, row_num, bufnr)
  for fn_name, distance in pairs(distances) do
    print(fn_name, distance)
  end
  -- Extract the smallest distance
  for fn_name, distance in pairs(distances) do
    min_dist = min_dist or distance
    min_fname = min_fname or fn_name

    if distance < min_dist then
      min_dist = distance
      min_fname = fn_name
    end
  end

  return min_fname
end

-- Retrieve the function closest to the cursor
function utils.get_nearest_function_to_cursor(tree, bufnr)
  local current_line = vim.fn.line '.'
  local nearest_fn_name = utils.nearest_function(tree, current_line, bufnr)
  return nearest_fn_name
end

-- Retrieve a node with any type and thing after
function utils.get_nodes(tree, lhs, tag)
  local query = '(' .. lhs .. ') @' .. tag
  vim.print(query)
  local n_lines = vim.fn.line '$'
  local bufnr = vim.api.nvim_get_current_buf()
  local root = tree:root()

  local nodes = {}
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local q = vim.treesitter.query.parse(filetype, query)

  for _, match, _ in q:iter_matches(root, bufnr, 0, n_lines, { all = true }) do
    for _, node in pairs(match) do
      table.insert(nodes, node)
    end
  end

  return nodes
end

-- Retrieve nodes matching a given query.
function utils.get_nodes_query(tree, query)
  local n_lines = vim.fn.line '$'
  local bufnr = vim.api.nvim_get_current_buf()
  local root = tree:root()

  local nodes = {}
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local q = vim.treesitter.query.parse(filetype, query)

  for _, match, _ in q:iter_matches(root, bufnr, 0, n_lines, { all = true }) do
    for _, node in pairs(match) do
      table.insert(nodes, node)
    end
  end

  return nodes
end

function utils.test()
  local current_buf = utils.current_buf()
  vim.print('Current buf: ' .. current_buf)
end

-- Retrieve the first identifier (as a string) for a given node.
function utils.alert(title, body)
  require 'notify'(body, 'info', { title = title })
end

return utils
