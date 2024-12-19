-- Utilities for calling shell or command-line utilities
--
--
local shell = {}
local ejovo = require('user.ejovo')

shell.dirExists = function(filename)
    local cmds = { "bash", "./dirExists.sh", filename }
    local out = vim.fn.system(cmds)
    return out == 'true'
end

shell.fileExists = function(filename)
    local cmds = { "bash", "./fileExists.sh", filename }
    local out = vim.fn.system(cmds)
    return out == 'true'
end

-- Test if a file exists
-- vim.print(shell.fileExists('CMakeLists.txt'))
-- vim.print(shell.fileExists('./flake.nix'))
-- vim.print(shell.fileExists('./false.nix'))
-- vim.print(shell.dirExists('./src'))
-- vim.print(shell.dirExists('./build'))
-- vim.print(shell.dirExists('./false'))

shell.fileExistsScript = function(filename)
return {
    vim.fn.printf('test -f ' .. '%s && echo -n "true" || echo -n "false"', filename)
}
end

shell.dirExistsScript = function(dirname)
return {
    vim.fn.printf('test -f ' .. '%s && echo -n "true" || echo -n "false"', dirname)
}
end

shell.grepMatchScript = function(filename, pattern)
return {
    vim.fn.printf('cat %s | grep -P "%s" -q && echo -n "true" || echo -n "false"', filename, pattern)
}
end

shell.grepScript = function(filename, pattern)
return {
    vim.fn.printf('cat %s | grep -P "%s"', filename, pattern)
}
end

-- Execute a bash script using an input array of lines
shell.execute_bash = function(lines)
    local command = ejovo.join('; ', lines)
    local file = io.popen(command)
    local result = file:read("*all")
    file:close()
    return result
end

shell.execute_bash_from = function(lines, dir)
    dir = dir or './'
    table.insert(lines, 1, 'cd ' .. dir)
    return shell.execute_bash(lines)
end

shell.grep = function(filename, pattern)
    return shell.execute_bash(shell.grepScript(filename, pattern))
end

-- Test if a file has any lines containing @pattern
shell.grepMatch = function(filename, pattern)
    local out = shell.execute_bash(shell.grepMatchScript(filename, pattern))
    return out == 'true'
end

shell.file_exists = function(filename)
    local out = shell.execute_bash(shell.fileExistsScript(filename))
    return out == 'true'
end


shell.dir_exists = function(filename)
    local out = shell.execute_bash(shell.dirExistsScript(filename))
    return out == 'true'
end


-- Get the name of the parent directory
shell.getParentDirScript = function(child)
    return {
        vim.fn.printf("cd %s && cd ../ && echo -n $PWD", child)
    }
end


shell.parent_dir = function(child)
    if child then
        return shell.execute_bash(shell.getParentDirScript(child))
    else
        return shell.execute_bash(shell.parentDirScript)
    end
end

shell.current_dir = function()
    return shell.execute_bash({"echo -n $PWD"})
end


-- "Test" suite
-- local out = shell.execute_bash_from({'pwd'}, '/home/ejovo/nixos-config/')
-- vim.print("Out dir: " .. out)

return shell
