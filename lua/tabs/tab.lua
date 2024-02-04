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
    local handle = vim.api.nvim_get_current_tabpage()
    local number = vim.api.nvim_tabpage_get_number(handle)
    return self.number == number
end

---@return string
function Tab:str()
    if self:is_current() then
        return string.format('%s( %s %d )', '%#TablineCurrentTab#', self.name, self.number)
    else
        return string.format('%s  %s %d  ', '%#TablineTab#', self.name, self.number)
    end
end

return Tab
