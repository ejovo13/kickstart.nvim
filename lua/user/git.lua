-- Helpful functions that can be used to interact with git
--
--
--

vim.print 'Hello'

-- Add the current file to git's staging area.
local function stage_current_file()
  local current_file_name = vim.fn.expand '%'

  print("Adding '" .. current_file_name .. "' to the staging area")
end

stage_current_file()
