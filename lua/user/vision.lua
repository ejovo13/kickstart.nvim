-- Launching vision services with tmux.
--
--
local ejovo = require 'user.ejovo'
local tmux = require 'user.tmux'

local VISION_DIRECTORY = '/home/ejovo/Fentech/Vision'
local VISION_FILTER_LIST = {
  'all',
  'brave-chat-server',
}

ejovo.vision.list_directories = function()
  local all_dir = ejovo.dir.list(VISION_DIRECTORY)
  return ejovo.utils.remove(all_dir, VISION_FILTER_LIST)
end

--
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values

local vision_picker = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Vision',
      finder = finders.new_table {
        results = ejovo.vision.list_directories(),
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.print(selection[1])
        end)
        return true
      end,
    })
    :find()
end

FENTECH_FD_COMMANDS = {
  'fd',
  '--glob',
  '.git',
  '/home/ejovo/Fentech/',
  '-H',
  '-I',
}

local fen_picker = function()
  return vim.fn.split(vim.fn.system(FENTECH_FD_COMMANDS), '\n')
end

local fentech_picker = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Fentech Repositories',
      finder = finders.new_table {
        results = fen_picker(),
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          tmux.nvim(selection[1])
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set('n', ';sv', vision_picker, { desc = '[S]earch [V]ision' })
vim.keymap.set('n', ';sF', fentech_picker, { desc = '[S]earch [F]entech' })
