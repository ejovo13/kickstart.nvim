-- Utilities for working with cmake
--
local cmake = {}
local shell = require('user.shell')
local ejovo = require('user.ejovo')

-- Check if the current diretory has a CMakeCache.txt file
cmake.isBuildDir = function(dir)
    dir = dir or './'
    return shell.file_exists(dir .. '/CMakeCache.txt')
end

-- Check if the current directory has a CMakeLists.txt file
cmake.isCMakeDir = function(dir)
    dir = dir or './'
    return shell.file_exists(dir .. '/CMakeLists.txt')
end

-- Check if this file contains the cmake 'project()' keyword
cmake.isProject = function(dir)
    dir = dir or './'
    local filename = dir .. '/CMakeLists.txt'
    vim.print(vim.fn.printf("Looking for file: %s", filename))
    local regex = '^project\\(*'
    vim.print("Regex: " .. regex)
    return shell.grepMatch(filename, regex)
end


-- Figure out where the CMake project directory is
cmake.findProjectDir = function(working_dir)
    working_dir = working_dir or shell.current_dir()
    if cmake.isBuildDir(working_dir) then
        return shell.grep(working_dir .. '/CMakeCache.txt', 'CMAKE_HOME_DIR')
    else
        if cmake.isProject(working_dir) then
            return working_dir
        else
            ejovo.error(
                "NotACmakeProject",
                {
                    'No CMakeLists.txt found',
                    vim.fn.printf('Current dir: (%s)', shell.current_dir())
                }
            )
        end
    end
end

cmake.buildPath = function(working_dir)
    local dir = working_dir or cmake.findProjectDir()
    return dir .. '/build'
end

-- Return the full path to the compile_commands.json files
cmake.compileCommandsPath = function(dir)
    dir = dir or cmake.findProjectDir()
    return dir .. '/build/compile_commands.json'
end


local Popup = require('nui.popup')


-- Create and mount a popup, then set it's lines as @lines
local feed_popup = function(lines)
    local bufnr = vim.api.nvim_create_buf(true, true)
    local popup = Popup({position = "50%", size = { width = 80, height = 40}, enter = true, border = 'double', bufnr = bufnr})
    popup:mount()
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, vim.fn.split(lines, '\n'))
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true, desc = 'Quit' })
end


-- Feed a popup from the outputs of a command result.
--   Pass in the command as a _function_ to call
local feed_popup_cmd = function(cmd_fn)
    local bufnr = vim.api.nvim_create_buf(true, true)
    local popup = Popup({position = "50%", size = { width = 80, height = 40}, enter = true, border = 'double', bufnr = bufnr})
    popup:mount()
    local out = cmd_fn()
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, vim.fn.split(out, '\n'))
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true, desc = 'Quit' })
end


cmake.runCommand = function(cmd, build_dir)

    if not cmake.isCMakeDir() then
        ejovo.error(
            "NotACmakeProject",
            {
                'No CMakeLists.txt found',
                vim.fn.printf('Current dir: (%s)', shell.current_dir())
            }
        )
    end

    build_dir = build_dir or './build'
    local project_dir = cmake.findProjectDir()
    vim.print("Executing cmake command: '".. cmd.. "'")

    feed_popup_cmd(function()
        return shell.execute_bash_from({cmd}, project_dir)
    end)

end

cmake.configure = function(build_dir)
    build_dir = build_dir or './build'
    local command = 'cmake -B ' .. build_dir .. ' -S ./'
    cmake.runCommand(command, build_dir)
end

-- Call the cmake shell commands to build cmake 
cmake.build = function(build_dir)
    build_dir = build_dir or './build'
    local command = 'cmake --build ' .. build_dir
    cmake.runCommand(command, build_dir)
end

-- Try and read the build directory's cache
cmake.getVariable = function(var_name)
    local build_path = cmake.buildPath()
    local shell_cmd = vim.fn.printf([[cat %s/CMakeCache.txt | rg -m 1 -or '$1' "^%s:?\w*=(.*)"]], build_path, var_name)
    vim.print("Shell cmd: " .. shell_cmd)
    return shell.execute_bash( { shell_cmd } )
end


cmake.openProjectFile = function()
    local dir = cmake.findProjectDir()
    vim.cmd(":e " .. dir .. "/CMakeLists.txt")
end



-- Functions that take in popup









return cmake
