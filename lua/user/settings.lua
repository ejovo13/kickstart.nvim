local function alert(body)
  require 'notify'(body, 'info', { title = 'Hello world!' })
end

alert 'Loaded settings!'

-- Now let's add some vim keymaps!
--
--
local function hello_world()
  alert 'Hello'
end

vim.keymap.set('n', '<leader>aa', hello_world, { desc = 'Say hi!' })
