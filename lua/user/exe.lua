-- Add a command to 'execute' files.
--
--
local exe = {}

LIST_NAME = 'things'

exe[LIST_NAME] = {}

-- Return a list of things that i've been storing
function exe.list_things()
  return exe[LIST_NAME]
end

function exe.add_things(el)
  table.insert(exe[LIST_NAME], el)
end
-- Use m for the current test keybinds
local function map(keys, cmd, desc)
  vim.keymap.set('n', keys, cmd, { desc = desc })
end

map(';aml', function()
  vim.print(vim.inspect(exe.list_things()))
end, 'My description')

map(';ama', function()
  local new_el = 'ELement ' .. #exe.list_things()
  exe.add_things(new_el)
  vim.print 'Added more elements!'
end, 'Add a new element')
return exe
