local Section = require 'tabs.section'
local str = require 'tabs.str'
local utf8 = require 'utf8'

---@class Tabline
---@field text? string
---@field sections? table
---@field highlights? table
local Tabline = {
    text = '',
    highlighted = '',
    sections = {},
    highlights = {},
}

---@param o Tabline | nil
---@return Tabline
function Tabline:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Tabline:replace(text, position)
    local sub_stop = utf8.offset(self.text, position - 1)
    local sub_start = utf8.offset(self.text, position + text:len())
    self.text = self.text:sub(0, sub_stop) .. text .. self.text:sub(sub_start)
end

function Tabline:insert(text, position)
    local sub_stop = utf8.offset(self.text, position - 1)
    local sub_start = utf8.offset(self.text, position)
    self.text = self.text:sub(0, sub_stop) .. text .. self.text:sub(sub_start)
end

function Tabline:generate(position, verbose, sections)
    --
    position = position or 0
    verbose = verbose or false
    sections = sections or self.sections

    --
    for _, section in pairs(sections) do
        local text = section:get_text()
        local subsections = section:get_sections()

        -- Render directly
        if text then
            table.insert(self.highlights, {
                group = section.highlight,
                start = position + section.position,
                stop = position + section.position + text:len(),
            })
            self:replace(text, position + section.position)

        -- Render recursively
        elseif subsections then
            self:generate(section.position, verbose, subsections)
        end
    end

    table.sort(self.highlights, function(a, b) return a.start > b.start end)
end

function Tabline:highlight()
    --
    for _, highlight in pairs(self.highlights) do
        local highlight_str = '%#' .. highlight.group .. '#'
        self:insert('%#NormalFloat#', highlight.stop)
        self:insert(highlight_str, highlight.start)
    end
end

function Tabline:render()
    self.text = string.rep(' ', vim.o.columns)
    self:generate()
    self:highlight()
    return self.text
end

vim.api.nvim_create_user_command('TabsInspect', function()
    local tabline = require('tabs').tabline
    print(vim.inspect(tabline))
    tabline:render(0, true)
    print('|' .. tabline.text .. '|')
    print('|' .. tabline.highlighted .. '|')
end, {})

return {
    setup = function()
        return Tabline:new {
            sections = {
                Section:version { position = 3 },
                Section:session { position = 20 },
                Section:tabs { position = 80 },
            },
        }
    end,
}
