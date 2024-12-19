-- Functions that use the nui component library
--
--

local ui = {}

local Popup = require('nui.popup')


-- Create and mount a popup, then set it's lines as @lines
ui.feed_popup = function(lines)
    local bufnr = vim.api.nvim_create_buf(true, true)
    local popup = Popup({position = "50%", size = { width = 80, height = 40}, enter = true, border = 'double', bufnr = bufnr})
    popup:mount()
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, vim.fn.split(lines, '\n'))
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true, desc = 'Quit' })
end


-- Feed a popup from the outputs of a command result.
--   Pass in the command as a _function_ to call
ui.feed_popup_cmd = function(cmd_fn)
    local bufnr = vim.api.nvim_create_buf(true, true)
    local popup = Popup({position = "50%", size = { width = 80, height = 40}, enter = true, border = 'double', bufnr = bufnr})
    popup:mount()
    local out = cmd_fn()
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, vim.fn.split(out, '\n'))
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true, desc = 'Quit' })
end

return ui
