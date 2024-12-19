-- Snippets for cmake
--
--

-- Snippets for nix packages
local ls = require 'luasnip'
-- local ft = require 'Comment.ft'
local fmt = require('luasnip.extras.fmt').fmt

-- Lua snippet
local s = ls.s

-- It takes a position (like $1) and optionally some default text
-- i(<position>, [default_text])
local i = ls.insert_node

-- Text node
local t = ls.text_node

-- Function node
local f = ls.function_node

-- Repeats a node
-- rep(<position>)
local rep = require('luasnip.extras').rep


ls.add_snippets('cmake', {
  s('new-project', fmt("cmake_minimum_{}{}", { i(1, 'default'), rep(1) })),
  s('new-cpp', fmt([[
      cmake_minimum_required(VERSION {version})

      project({project_name})
      enable_language(CXX)

      set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

      add_executable({target_name} {target_name_rep}.{file_format})

      install(TARGETS {target_name_rep} DESTINATION bin)
    ]], {
      version = i(1, '3.11'),
      project_name = i(2, 'NewProject'),
      target_name = i(3, 'main'),
      target_name_rep = rep(3),
      file_format = i(4, 'cpp'),
    })),


  s('msg-status', fmt('message(STATUS "{msg}")', { msg = i(1, 'STATUS_MSG') })),

  -- s('flake', fmt("{}", { t(test_flake) })),
  -- s('fromFile', ),
})

ls.add_snippets('cpp', {
  s('main', fmt("int main() {{\n\t{}\n}}\n", { i(1, 'std::cout << "Hello, World!" << std::endl;') })),
  s('tmpl', fmt("template<typename {}> {}", { i(1, 'T'), i(2) })),
  s('tmpl-struct', fmt("template<typename {type}> struct {struct_name} {{\n\t{type} {var};\n}};", {
    type = i(1, 'T'), 
    struct_name = i(1, 'StructName'),
    var = i(3, 'var') 
  })),
  s('tmpl-class', fmt("template<typename {}> {}", { i(1, 'T'), i(2) })),
  s('tmpl-fn', fmt("template<typename {}> {}", { i(1, 'T'), i(2) })),
  s('inc', fmt("#include <{module}>\n{}", { module = i(1, 'iostream'), i(2) })),
})

vim.print("Added some snippets!")
