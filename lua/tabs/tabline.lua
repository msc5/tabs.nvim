local Section = require 'tabs.section'

local M = {
    sections = {
        Section:version(),
        Section:session(),
        Section:tabs(),
    },
}

function M:render()
    local sections = {}
    for _, section in pairs(M.sections) do
        local str = section:render()
        if str ~= '' then table.insert(sections, str) end
    end
    return table.concat(sections, ' ')
end

-- Create global alias
TabsRender = function() return M:render() end

function M:setup()
    vim.api.nvim_set_option('showtabline', 2)
    vim.api.nvim_set_option('tabline', '%!v:lua.TabsRender()')
end

return M
