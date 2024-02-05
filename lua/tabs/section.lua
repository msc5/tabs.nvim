---@class Section
local Section = {
    text = '',
    highlight = '',
}

function Section.hl(text, highlight) return string.format('%%#%s#%s', highlight, text) end

---@param o Section | nil
---@return Section
function Section:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---@return string
function Section:render()
    local success, result = pcall(function() return self.text() end)
    if success then
        return Section.hl(result, self.highlight)
    else
        return Section.hl(self.text, self.highlight)
    end
end

function Section:width()
    local success, result = pcall(function() return self.text() end)
    if success then
        return string.len(result)
    else
        return string.len(self.text)
    end
end

-- ------------------------- Builtin Section Types -------------------------- --

---@return Section
function Section:version()
    return Section:new {
        text = function()
            local v = vim.version()
            return string.format('Neovim v%d.%d.%d', v.major, v.minor, v.patch)
        end,
        highlight = 'TablineVersion',
    }
end

---@return Section
function Section:tabs()
    return Section:new {
        text = function()
            local manager = require 'tabs.manager'
            local str = {}
            for _, tab in pairs(manager.tabs) do
                local section = Section.render {
                    text = '( ' .. tab.name .. ' ' .. tab.number .. ' )',
                    highlight = tab:is_current() and 'TablineCurrentTab' or 'TablineTab',
                }
                table.insert(str, section)
            end
            return table.concat(str, ' ')
        end,
        highlight = 'TablineTab',
    }
end

function Section:session()
    return Section:new {
        text = function()
            local icon = Section.render { text = '󰮄 ', highlight = 'TablineSessionIcon' }
            if vim.v.this_session ~= '' then
                local session = Section.render {
                    text = vim.fs.basename(vim.v.this_session),
                    highlight = 'TablineSession',
                }
                return icon .. ' ' .. session
            else
                return icon
            end
        end,
        highlight = 'TablineSession',
    }
end

return Section
