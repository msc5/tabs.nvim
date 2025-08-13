-- Basic configuration example for tabs.nvim
-- Place this in your Neovim config (e.g., ~/.config/nvim/lua/plugins/tabs.lua)

return {
    'your-username/tabs.nvim',
    event = 'VimEnter',
    config = function()
        require('tabs').setup()
    end,
} 