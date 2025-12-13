local Section = require 'tabs.section'
local config = require 'tabs.config'
local str = require 'tabs.str'
local utf8 = require 'utf8'
local utils = require 'tabs.utils'

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
    -- Validate position is within bounds
    local text_len = utf8.len(self.text)
    if position < 1 or position > text_len then return end

    -- Ensure we don't exceed available space
    local max_len = vim.o.columns
    if position + text:len() > max_len then
        -- Truncate text to fit
        local available = max_len - position
        if available <= 0 then return end
        text = text:sub(1, available)
    end

    self.text = utils.replace_text_at_position(self.text, text, position, text:len())
end

---@param text string
---@param position integer
function Tabline:insert(text, position)
    -- Validate position is within bounds
    local text_len = utf8.len(self.text)
    if position < 1 or position > text_len + 1 then return end

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

    -- Get available width
    local max_width = vim.o.columns

    --
    for _, section in pairs(sections) do
        local text = section:get_text()
        local subsections = section:get_sections()

        -- Compute render start position
        local start = position + section.position

        -- Skip if section would start beyond available width
        if start >= max_width then goto continue end

        -- Render directly
        if text then
            local text_width = vim.fn.strdisplaywidth(text)
            local end_pos = start + text_width

            -- Truncate text if it would exceed bounds
            if end_pos > max_width then
                local available = max_width - start
                if available > 0 then
                    -- Truncate text to fit
                    text = vim.fn.strcharpart(text, 0, available - 3) .. '...'
                    text_width = vim.fn.strdisplaywidth(text)
                    end_pos = start + text_width
                else
                    goto continue
                end
            end

            table.insert(self.highlights, {
                group = section.highlight,
                start = start,
                stop = end_pos,
            })
            self:replace(text, start)

        -- Render recursively
        elseif subsections then
            self:generate(start, verbose, subsections)
        end

        ::continue::
    end
end

function Tabline:highlight()
    local highlights = {}

    -- Process all highlights in one pass
    for _, highlight in pairs(self.highlights) do
        -- Ensure positions are within bounds
        if highlight.start >= 1 and highlight.start <= vim.o.columns then
            table.insert(highlights, { pos = highlight.start, text = '%#' .. highlight.group .. '#' })
        end
        if highlight.stop >= 1 and highlight.stop <= vim.o.columns then
            table.insert(highlights, { pos = highlight.stop, text = '%#TablineDefault#' })
        end
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
