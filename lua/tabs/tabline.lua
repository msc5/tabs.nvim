local Section = require 'tabs.section'
local str = require 'tabs.str'
local utils = require 'tabs.utils'
local config = require 'tabs.config'
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
    self.text = utils.replace_text_at_position(self.text, text, position, text:len())
end

---@param text string
---@param position integer
function Tabline:insert(text, position)
    self.text = utils.insert_text_at_position(self.text, text, position)
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
    local highlights = {}
    
    -- Process all highlights in one pass
    for _, highlight in pairs(self.highlights) do
        table.insert(highlights, { pos = highlight.start, text = '%#' .. highlight.group .. '#' })
        table.insert(highlights, { pos = highlight.stop, text = '%#TablineDefault#' })
    end
    
    -- Single sort operation
    table.sort(highlights, function(a, b) return a.pos > b.pos end)
    
    for _, highlight in pairs(highlights) do
        self:insert(highlight.text, highlight.pos)
    end
    
    self.text = '%#TablineDefault#' .. self.text
end

function Tabline:render()
    self.text = string.rep(' ', vim.o.columns)
    self.highlights = {}
    self:generate()
    self:highlight()
    return self.text
end

return {
    setup = function()
        -- Get configuration with fallback to defaults
        local sections_config = config.get('sections', {
            version = { position = 3 },
            session = { position = 20 },
            tabs = { position = 40, justify = 'right' },
        })
        
        return Tabline:new {
            sections = {
                Section:version { position = sections_config.version.position },
                Section:session { position = sections_config.session.position },
                Section:tabs { position = sections_config.tabs.position, justify = sections_config.tabs.justify },
            },
        }
    end,
}
