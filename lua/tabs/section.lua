---@class Section
---@field text? string | function
---@field sections? table | function
---@field position? integer | "right" | "left"
local Section = {
    text = '',
    highlight = '',
    position = 0,
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
    return success and result or self.text
end

function Section:get_sections()
    local success, result = pcall(function() return self.sections() end)
    return success and result or nil
end

-- ------------------------- Builtin Section Types -------------------------- --

---@param o Section | nil
---@return Section
function Section:version(o)
    local opts = vim.tbl_deep_extend('force', o, {
        text = function()
            local v = vim.version()
            return string.format('Neovim v%d.%d.%d', v.major, v.minor, v.patch)
        end,
        highlight = 'TablineVersion',
    })
    return Section:new(opts)
end

---@param o Section | nil
---@return Section
function Section:session(o)
    local opts = vim.tbl_deep_extend('force', o, {
        sections = {
            Section:new {
                text = '󰮄 ',
                highlight = 'Constant',
                position = 0,
            },
            Section:new {
                text = function()
                    return vim.v.this_session ~= '' and vim.fs.basename(vim.v.this_session) or ''
                end,
                highlight = 'Character',
                position = 3,
            },
        },
        highlight = 'TablineSession',
    })
    return Section:new(opts)
end

---@param o Section | nil
---@return Section
function Section:tabs(o)
    local opts = vim.tbl_deep_extend('force', o, {
        sections = function()
            local manager = require 'tabs.manager'
            local sections, position = {}, 0
            for _, tab in pairs(manager.tabs()) do
                local text = '( ' .. tab.name .. ' ' .. tab.number .. ' )'
                local highlight = tab.is_current and 'TablineCurrentTab' or 'TablineTab'
                table.insert(
                    sections,
                    Section:new {
                        text = text,
                        highlight = highlight,
                        position = position,
                    }
                )
                position = position + text:len() + 1
            end
            return sections
        end,
        highlight = 'TablineTab',
    })
    return Section:new(opts)
end

return Section
