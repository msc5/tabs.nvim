local Section = require 'tabs.section'
local config = require 'tabs.config'
local str = require 'tabs.str'
local utf8 = require 'utf8'
local utils = require 'tabs.utils'

---@class Tabline
---@field text? string
---@field sections? table
---@field highlights? table
---@field is_collapsed? boolean
local Tabline = {
    text = '',
    sections = {},
    highlights = {},
    is_collapsed = false,
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

---Calculate scrolled tab sections with counter
---@param tabs_section table The tabs section
---@param max_width integer Maximum available width
---@return table sections Modified sections with counter
local function calculate_scrolled_tabs(tabs_section, max_width)
    local manager = require 'tabs.manager'
    local all_tabs = manager.tabs()

    if #all_tabs == 0 then return {} end

    -- Find current tab index
    local current_idx = 1
    for i, tab in ipairs(all_tabs) do
        if tab.is_current then
            current_idx = i
            break
        end
    end

    -- Calculate total width needed for all tabs
    local total_width = 0
    for _, tab in ipairs(all_tabs) do
        total_width = total_width + vim.fn.strdisplaywidth(tab.heading) + 1
    end

    -- Create counter section (e.g., "← 5/12 →")
    local counter_text = string.format(' ← %d/%d → ', current_idx, #all_tabs)
    local counter_width = vim.fn.strdisplaywidth(counter_text)

    -- Available width for tabs after counter
    local tabs_available = max_width - counter_width - 5 -- 5 for padding

    local sections = {}
    local position = 0

    -- Add counter section
    table.insert(
        sections,
        Section:new {
            text = counter_text,
            highlight = 'TablineTabCounter',
            position = 0,
        }
    )

    position = counter_width

    -- If all tabs fit, show them all
    if total_width <= tabs_available then
        for _, tab in ipairs(all_tabs) do
            local highlight = tab.is_current and 'TablineCurrentTab' or 'TablineTab'
            table.insert(
                sections,
                Section:new {
                    text = tab.heading,
                    highlight = highlight,
                    position = position,
                }
            )
            position = position + vim.fn.strdisplaywidth(tab.heading) + 1
        end
        return sections
    end

    -- Calculate which tabs to show (centered around current tab)
    local visible_tabs = {}
    local visible_width = 0

    -- Start with current tab (preserve the original tab object with is_current)
    local current_tab = all_tabs[current_idx]
    table.insert(visible_tabs, current_tab)
    visible_width = vim.fn.strdisplaywidth(current_tab.heading)

    -- Add tabs before and after current tab
    local before_idx = current_idx - 1
    local after_idx = current_idx + 1

    while (before_idx >= 1 or after_idx <= #all_tabs) and visible_width < tabs_available do
        -- Try to add a tab after
        if after_idx <= #all_tabs then
            local tab = all_tabs[after_idx]
            local tab_width = vim.fn.strdisplaywidth(tab.heading) + 1
            if visible_width + tab_width <= tabs_available then
                table.insert(visible_tabs, tab)
                visible_width = visible_width + tab_width
                after_idx = after_idx + 1
            else
                break
            end
        end

        -- Try to add a tab before
        if before_idx >= 1 then
            local tab = all_tabs[before_idx]
            local tab_width = vim.fn.strdisplaywidth(tab.heading) + 1
            if visible_width + tab_width <= tabs_available then
                table.insert(visible_tabs, 1, tab)
                visible_width = visible_width + tab_width
                before_idx = before_idx - 1
            else
                break
            end
        end
    end

    -- Add visible tabs to sections, preserving is_current status
    for _, tab in ipairs(visible_tabs) do
        local highlight = tab.is_current and 'TablineCurrentTab' or 'TablineTab'
        table.insert(
            sections,
            Section:new {
                text = tab.heading,
                highlight = highlight,
                position = position,
            }
        )
        position = position + vim.fn.strdisplaywidth(tab.heading) + 1
    end

    return sections
end

---@param position? integer
---@param verbose? boolean
---@param sections? table
function Tabline:generate(position, verbose, sections)
    position = position or 0
    verbose = verbose or false
    sections = sections or self.sections or {}

    -- Get available width
    local max_width = vim.o.columns

    for _, section in pairs(sections) do
        local text = section:get_text()
        local subsections = section:get_sections()

        -- Compute render start position
        local start = position + section.position

        -- Skip if section would start beyond available width
        if start >= max_width then goto continue end

        -- Special handling for tabs section - check if scrolling is needed
        if section.sections and type(section.sections) == 'function' then
            -- Check if this is the tabs section by trying to get subsections
            local temp_subsections = section:get_sections()
            if temp_subsections and #temp_subsections > 0 then
                -- Calculate total width needed
                local total_width = 0
                for _, subsection in ipairs(temp_subsections) do
                    local subtext = subsection:get_text()
                    if subtext then total_width = total_width + vim.fn.strdisplaywidth(subtext) + 1 end
                end

                local available = max_width - start

                -- If tabs don't fit, use scrolled view
                if total_width > available then
                    self.is_collapsed = true
                    subsections = calculate_scrolled_tabs(section, available)
                else
                    self.is_collapsed = false
                    subsections = temp_subsections
                end

                if subsections then self:generate(start, verbose, subsections) end
                goto continue
            end
        end

        -- Render directly
        if text then
            local text_width = vim.fn.strdisplaywidth(text)
            local end_pos = start + text_width

            -- Truncate text if it would exceed bounds
            if end_pos > max_width then
                local available = max_width - start
                if available > 0 then
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
    self.is_collapsed = false
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
