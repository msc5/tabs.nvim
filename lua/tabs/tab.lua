---@class Tab
local Tab = {
    name = 'tab',
    number = nil,
}

---@param o Tab | nil
---@return Tab
function Tab:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---@return boolean
function Tab:is_current()
    -- TODO: Migrate this out of Tab class and remove `number` variable from Tab
    local handle = vim.api.nvim_get_current_tabpage()
    local number = vim.api.nvim_tabpage_get_number(handle)
    return self.number == number
end

function Tab:serialize()
    return {
        name = self.name,
        number = self.number,
    }
end

return Tab
