local Section = require 'tabs.section'
local str = require 'tabs.str'

local utf8 = require 'utf8'

local M = {
    sections = {
        Section:version { position = 3 },
        Section:session { position = 20 },
        Section:tabs { position = 80 },
    },
}

function M.replace(original, text, position)
    --
    -- sub() is [start, stop] i.e., inclusive both sides
    --
    local sub_stop = utf8.offset(original, position - 1)
    local sub_start = utf8.offset(original, position + text:len())
    return original:sub(0, sub_stop) .. text .. original:sub(sub_start)
end

function M.insert(original, text, position)
    local sub_stop = utf8.offset(original, position - 1)
    local sub_start = utf8.offset(original, position)
    return original:sub(0, sub_stop) .. text .. original:sub(sub_start)
end

function M.render(sections, tabline, highlights, position)
    --
    tabline = tabline or string.rep(' ', vim.o.columns)
    highlights = highlights or {}
    position = position or 0

    --
    for _, section in pairs(sections) do
        local subsections = section:get_sections()
        if subsections then
            tabline, highlights = M.render(subsections, tabline, highlights, section.position)
        elseif next(section.sections) ~= nil then
            tabline, highlights = M.render(section.sections, tabline, highlights, section.position)
        else
            local text = section:get_text()
            table.insert(highlights, {
                group = section.highlight,
                start = position + section.position,
                stop = position + section.position + text:len(),
            })
            tabline = M.replace(tabline, text, position + section.position)
        end
    end

    table.sort(highlights, function(a, b) return a.start > b.start end)

    --
    return tabline, highlights
end

function M.highlight(tabline, highlights)
    --
    for _, highlight in pairs(highlights) do
        local highlight_str = '%#' .. highlight.group .. '#'
        -- local reset_str = '%#NormalFloat#'
        -- tabline = M.insert(tabline, reset_str, highlight.stop)
        tabline = M.insert(tabline, highlight_str, highlight.start)
    end

    --
    return tabline
end

-- Create global alias
TabsRender = function()
    local tabline, highlights = M.render(M.sections)
    return M.highlight(tabline, highlights)
end

vim.api.nvim_create_user_command('TabsInspect', function()
    local tabline, highlights = M.render(M.sections)
    local highlighted = M.highlight(tabline, highlights)
    print('|' .. tabline .. '|')
    print('|' .. highlighted .. '|')
    print(vim.inspect(highlights))
end, {})

function M:setup()
    vim.api.nvim_set_option('showtabline', 2)
    vim.api.nvim_set_option('tabline', '%!v:lua.TabsRender()')
end

return M
