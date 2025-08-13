local M = {
    fg = {},
    bg = {},
    highlights = {},
}

local config = require 'tabs.config'

---Get highlight color with fallback
---@param highlight_name string Highlight group name
---@param fallback_color string Fallback color if highlight not found
---@return string
local function get_highlight_color(highlight_name, fallback_color, use_bg)
    local success, hl = pcall(vim.api.nvim_get_hl, 0, { name = highlight_name })
    if success and hl then return string.format('#%06x', use_bg and hl.bg or hl.fg) end
    return fallback_color
end

---Gather colors from highlight groups
---@return table colors
local function gather_colors()
    local colors = { fg = {}, bg = {} }

    -- Get color configuration with fallbacks
    local colors_config = config.get('colors', {
        fg_highlights = {
            grey = 'NonText',
            red = 'Error',
            purple = 'Statement',
            orange = 'Constant',
            blue = 'Function',
            cyan = 'Character',
            light_blue = 'Label',
            pink = 'Macro',
        },
        bg_highlights = {
            dark = 'NormalFloat',
        },
    })

    -- Gather foreground colors
    for color, highlight in pairs(colors_config.fg_highlights) do
        colors.fg[color] = get_highlight_color(highlight, '#808080', false)
    end

    -- Gather background colors
    for color, highlight in pairs(colors_config.bg_highlights) do
        colors.bg[color] = get_highlight_color(highlight, '#000000', true)
    end

    return colors
end

---Setup highlight groups
---@param colors table Color values
local function setup_highlights(colors)
    local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

    -- Basic tabline highlights
    hl('TabLine', { fg = colors.fg.grey, bg = 'none' })
    hl('TabLineFill', { fg = colors.fg.grey, bg = 'none' })
    hl('TabLineSel', { fg = colors.fg.grey, bg = 'none' })

    -- Custom tabline highlights
    hl('TablineDefault', { fg = colors.fg.grey, bg = 'none' })
    hl('TablineVersion', { fg = colors.fg.grey, bg = 'none' })
    hl('TablineSessionIcon', { fg = colors.fg.red, bg = 'none' })
    hl('TablineSession', { fg = colors.fg.orange, bg = 'none', bold = true })
    hl('TablineTab', { fg = colors.fg.grey, bg = 'none' })
    hl('TablineCurrentTab', { fg = colors.fg.blue, bg = colors.bg.dark, bold = true })
end

local function setup_colors()
    local colors = gather_colors()
    M.fg = colors.fg
    M.bg = colors.bg
    setup_highlights(colors)
end

function M.setup()
    setup_colors()

    -- Create highlight groups when `ColorScheme` event fires
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, { callback = setup_colors })
end

return M
