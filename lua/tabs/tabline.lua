local Section = require 'tabs.section'
local str = require 'tabs.str'
local utf8 = require 'utf8'

---@class Tabline
---@field text? string
---@field sections? table
---@field highlights? table
local Tabline = {
    text = '',
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

---@param text string
---@param position integer
function Tabline:replace(text, position)
    --
    -- Example:
    -- text = 'example'
    -- replace('|', 3)
    -- text = 'ex|mple'
    --
    local sub_stop = utf8.offset(self.text, position - 1)
    local sub_start = utf8.offset(self.text, position + text:len())
    self.text = self.text:sub(0, sub_stop) .. text .. self.text:sub(sub_start)
end

---@param text string
---@param position integer
function Tabline:insert(text, position)
    --
    -- Example:
    -- text = 'example'
    -- insert('|', 3)
    -- text = 'ex|ample'
    --
    local sub_stop = utf8.offset(self.text, position - 1)
    local sub_start = utf8.offset(self.text, position)
    self.text = self.text:sub(0, sub_stop) .. text .. self.text:sub(sub_start)
end

---@param position? integer
---@param verbose? boolean
---@param sections? table
function Tabline:generate(position, verbose, sections)
    --
    position = position or 0
    verbose = verbose or false
    sections = sections or self.sections or {}

    --
    for _, section in pairs(sections) do
        local text = section:get_text()
        local subsections = section:get_sections()

        -- Compute render start position
        local start = position + section.position

        -- Render directly
        if text then
            table.insert(self.highlights, {
                group = section.highlight,
                start = start,
                stop = start + vim.fn.strdisplaywidth(text),
            })
            self:replace(text, start)

        -- Render recursively
        elseif subsections then
            self:generate(start, verbose, subsections)
        end
    end
end

function Tabline:highlight()
    --
    local highlights = {}

    --
    table.sort(self.highlights, function(a, b) return a.start > b.start end)
    for _, highlight in pairs(self.highlights) do
        table.insert(highlights, {
            pos = highlight.start,
            text = '%#' .. highlight.group .. '#',
        })
    end
    table.sort(self.highlights, function(a, b) return a.stop > b.stop end)
    for _, highlight in pairs(self.highlights) do
        table.insert(highlights, {
            pos = highlight.stop,
            text = '%#TablineDefault#',
        })
    end

    --
    table.sort(highlights, function(a, b) return a.pos > b.pos end)
    for _, highlight in pairs(highlights) do
        self:insert(highlight.text, highlight.pos)
    end

    --
    self.text = '%#TablineDefault#' .. self.text
end

function Tabline:render()
    self.text = string.rep(' ', vim.o.columns)
    self.highlights = {}
    self:generate()
    self:highlight()
    return self.text
end

vim.api.nvim_create_user_command('TabsInspect', function()
    local tabline = require('tabs').tabline
    tabline:render()
    print(vim.o.columns)
    print(vim.fn.strdisplaywidth(tabline.text))
    print('|' .. tabline.text .. '|')
    print(vim.inspect(tabline))
end, {})

return {
    setup = function()
        return Tabline:new {
            sections = {
                Section:version { position = 3 },
                Section:session { position = 20 },
                Section:tabs { position = 40, justify = 'right' },
            },
        }
    end,
}
