-- Helpful utilities when writing python code
--
--


local shell = require('user.shell')

local python = {}


---Check if the current directory contains a 'pyproject.toml' file
---@return boolean
python.is_python_project = function()
    return shell.fileExists('pyproject.toml')
end

return python
