-- Advanced configuration example for tabs.nvim
-- This shows how to customize the plugin with the new configuration system

return {
    'your-username/tabs.nvim',
    event = 'VimEnter',
    config = function()
        require('tabs').setup {
            -- Custom section positions
            sections = {
                version = { position = 5 },
                session = { position = 25 },
                tabs = { position = 50, justify = 'center' },
            },

            -- Custom file types to skip
            skip_filetypes = {
                ['NvimTree'] = true,
                ['neo-tree'] = true,
                ['aerial'] = true,
                ['help'] = true,
                ['qf'] = true,
                ['toggleterm'] = true, -- Additional file type
            },
        }
    end,
}