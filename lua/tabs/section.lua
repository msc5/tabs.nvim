---@class Section
local Section = {
    text = '',
    highlight = '',
}

---@param o Section | nil
---@return Section
function Section:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---@return Section
function Section:version()
    local v = vim.version()
    return Section:new {
        text = string.format('Neovim v%d.%d.%d', v.major, v.minor, v.patch),
    }
end

---@return string
function Section:render()
    local text = string.format('%%#%s#%s', self.highlight, self.text)
    return text
end

return Section
