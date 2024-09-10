local ls = require 'luasnip'

ls.config.set_config {

  history = true,
  updateevents = 'TextChanged,TextChangedI',

  enable_autosnippets = true,
}

vim.keymap.set({ 'i', 's' }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<c-j>', function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

require 'user.snippets.python'
require 'user.snippets.rust'
require 'user.snippets.lua'
