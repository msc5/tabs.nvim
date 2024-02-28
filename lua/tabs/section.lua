---@class Section
---@field text? string | function
---@field sections? table | function
---@field position? integer
---@field justify? "right" | "left"
local Section = {
    text = '',
    highlight = '',
    position = 0,
    justify = 'left',
    sections = {},
}

---@param o Section | nil
---@return Section
function Section:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Section:get_text()
    local success, result = pcall(function() return self.text() end)
    if success then
        return result
    elseif self.text:len() > 0 then
        return self.text
    else
        return nil
    end
end

function Section:get_sections()
    local success, result = pcall(function() return self.sections() end)
    if success then
        return result
    elseif next(self.sections) ~= nil then
        return self.sections
    else
        return nil
    end
end

-- ------------------------- Builtin Section Types -------------------------- --

---@param o Section | nil
---@return Section
function Section:version(o)
    local version = Section:new {
        text = function()
            local v = vim.version()
            return string.format('Neovim v%d.%d.%d', v.major, v.minor, v.patch)
        end,
        highlight = 'TablineVersion',
    }
    return version:new(o)
end

---@param o Section | nil
---@return Section
function Section:session(o)
    local session = Section:new {
        sections = {
            Section:new {
                text = '󰮄 ',
                highlight = 'TablineSessionIcon',
                position = 0,
            },
            Section:new {
                text = function()
                    return vim.v.this_session ~= '' and vim.fs.basename(vim.v.this_session) or ''
                end,
                highlight = 'TablineSession',
                position = 3,
            },
        },
    }
    return session:new(o)
end

---@param o Section | nil
---@return Section
function Section:tabs(o)
    local tabs = Section:new {
        sections = function()
            local manager = require 'tabs.manager'
            local sections, position = {}, 0
            for _, tab in pairs(manager.tabs()) do
                local highlight = tab.is_current and 'TablineCurrentTab' or 'TablineTab'
                table.insert(
                    sections,
                    Section:new {
                        text = tab.heading,
                        highlight = highlight,
                        position = position,
                    }
                )
                position = position + tab.heading:len() + 1
            end
            return sections
        end,
    }
    return tabs:new(o)
end

return Section
