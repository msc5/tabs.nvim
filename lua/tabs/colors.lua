local M = {
    fg = {},
    bg = {},
    highlights = {},
}

function M.merge(a, b)
    for k, v in pairs(a) do
        b[k] = v
    end
end

function M.setup()
    -- Create highlight groups when `ColorScheme` event fires
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        callback = function()
            -- Gather colors based on common configuration
            local fg_highlights = {
                grey = 'NonText',
                red = 'Error',
                purple = 'Statement',
                orange = 'Constant',
                blue = 'Function',
                cyan = 'Character',
                pink = 'Macro',
            }
            for color, highlight in pairs(fg_highlights) do
                M.fg[color] = vim.api.nvim_get_hl(0, { name = highlight }).fg
            end

            local bg_highlights = {
                dark = 'NormalFloat',
            }
            for color, highlight in pairs(bg_highlights) do
                M.bg[color] = vim.api.nvim_get_hl(0, { name = highlight }).bg
            end
            local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end
            hl('TablineVersion', { fg = M.fg.grey, bg = M.bg.dark })
            hl('TablineSessionIcon', { fg = M.fg.red, bg = M.bg.dark })
            hl('TablineSession', { fg = M.fg.orange, bg = M.bg.dark, bold = true })
            hl('TablineTab', { fg = M.fg.grey, bg = M.bg.dark })
            hl('TablineCurrentTab', { fg = M.fg.pink, bg = M.bg.dark, bold = true })
        end,
    })
end

return M
