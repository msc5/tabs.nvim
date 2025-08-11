local M = {
    fg = {},
    bg = {},
    highlights = {},
}

local function setup_colors()
    -- Gather colors based on common configuration
    local fg_highlights = {
        grey = 'NonText',
        red = 'Error',
        purple = 'Statement',
        orange = 'Constant',
        blue = 'Function',
        cyan = 'Character',
        light_blue = 'Label',
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
    hl('TabLine', { fg = M.fg.grey, bg = 'none' })
    hl('TabLineFill', { fg = M.fg.grey, bg = 'none' })
    hl('TabLineSel', { fg = M.fg.grey, bg = 'none' })

    hl('TablineDefault', { fg = M.fg.grey, bg = 'none' })
    hl('TablineVersion', { fg = M.fg.grey, bg = 'none' })
    hl('TablineSessionIcon', { fg = M.fg.red, bg = 'none' })
    hl('TablineSession', { fg = M.fg.orange, bg = 'none', bold = true })
    hl('TablineTab', { fg = M.fg.grey, bg = 'none' })
    hl('TablineCurrentTab', { fg = M.fg.blue, bg = M.bg.dark, bold = true })
end

function M.setup()
    setup_colors()

    -- Create highlight groups when `ColorScheme` event fires
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, { callback = setup_colors })
end

return M
