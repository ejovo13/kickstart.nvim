local M = {}

local e = require 'user.ejovo'

M.precommit_all = function()
  vim.api.nvim_command 'write'

  -- Startring file
  local starting_bufnr = vim.api.nvim_get_current_buf()
  local starting_name = e.file.name(starting_bufnr)
  local bufnr = e.buffer.new_tab()

  vim.fn.jobstart({ 'pre-commit', 'run', '--all-files' }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
      end
    end,
  })
end

M.precommit = function()
  vim.api.nvim_command 'write'

  -- Startring file
  local starting_bufnr = vim.api.nvim_get_current_buf()
  local starting_name = e.file.name(starting_bufnr)
  local bufnr = e.buffer.new_tab()

  vim.fn.jobstart({ 'pre-commit', 'run' }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
      end
    end,
  })
end

M.run_mypy = function()
  vim.api.nvim_command 'write'

  -- Startring file
  local starting_bufnr = vim.api.nvim_get_current_buf()
  local starting_name = e.file.name(starting_bufnr)
  local bufnr = e.buffer.new_tab()

  vim.fn.jobstart({ 'pre-commit', 'run', 'mypy', '--all-files' }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
      end
    end,
  })
end

vim.keymap.set('n', '<leader>xp', M.precommit, { desc = 'E[x]ecute [p]re-commit' })
vim.keymap.set('n', '<leader>xP', M.precommit_all, { desc = 'E[x]ecute [P]re-commit for all files' })
vim.keymap.set('n', '<leader>xm', M.run_mypy, { desc = 'E[x]ecute [m]ypy pre-commit' })

return M
