-- Utilities for working with cmake
--
local cmake = {}
local shell = require('user.shell')

-- Check if the current diretory has a CMakeCache.txt file
cmake.isBuildDir = function(dir)
    dir = dir or './'
    return shell.file_exists(dir .. 'CMakeCache.txt')
end

-- Check if the current directory has a CMakeLists.txt file
cmake.isCMakeDir = function(dir)
    dir = dir or './'
    return shell.file_exists(dir .. 'CMakeLists.txt')
end

-- Check if this file contains the cmake 'project()' keyword
cmake.isProject = function(dir)
    dir = dir or './'
    local filename = dir .. 'CMakeLists.txt'
    shell.grepMatch(filename, '^project(*)')
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
            return 'not_found'
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


-- Call the cmake shell commands to build cmake 
cmake.build = function()
end







return cmake
