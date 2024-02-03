---@class Tab
local Tab = {
    name = 'tab',
}

---@param o Tab | nil
---@return Tab
function Tab:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

return Tab
