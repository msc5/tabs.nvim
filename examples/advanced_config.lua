-- Advanced configuration example for tabs.nvim
-- This shows how to customize the plugin with the new configuration system

return {
    'your-username/tabs.nvim',
    event = 'VimEnter',
    config = function()
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
            
            -- Custom color mappings
            colors = {
                fg_highlights = {
                    grey = 'Comment',      -- Use Comment instead of NonText
                    red = 'ErrorMsg',      -- Use ErrorMsg instead of Error
                    orange = 'WarningMsg', -- Use WarningMsg instead of Constant
                    blue = 'Function',     -- Keep Function
                },
                bg_highlights = {
                    dark = 'Pmenu',        -- Use Pmenu instead of NormalFloat
                }
            }
        })
    end,
} 