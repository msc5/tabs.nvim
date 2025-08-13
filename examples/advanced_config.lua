-- Advanced configuration example for tabs.nvim
-- This shows how you could customize the plugin (when configuration options are added)

return {
    'your-username/tabs.nvim',
    event = 'VimEnter',
    config = function()
        -- Example of future configuration options
        require('tabs').setup({
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
            
            -- Custom keymaps
            keymaps = {
                next = 'L',
                prev = 'H',
                new = 'Tn',
                close = 'Tc',
            },
            
            -- Custom colors
            colors = {
                current_tab = { fg = '#ff6b6b', bg = '#2d3748', bold = true },
                session = { fg = '#fbbf24', bg = 'none', bold = true },
            }
        })
    end,
} 