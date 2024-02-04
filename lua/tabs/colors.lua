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
    -- Gather colors based on common configuration
    local fg_highlights = {
        grey = 'Comment',
        red = 'Error',
        purple = 'Statement',
        orange = 'Constant',
        blue = 'Function',
        cyan = 'Character',
        pink = 'Define',
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

    -- Create highlight groups when `ColorScheme` event fires
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        callback = function()
            local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end
            hl('TablineVersion', { link = 'NonText' })
            hl('TablineSessionIcon', { link = 'Error' })
            hl('TablineSession', { link = 'Constant', bold = true })
            hl('TablineTab', { link = 'NonText' })
            hl('TablineCurrentTab', { link = 'Function', bold = true })
        end,
    })
end

return M
