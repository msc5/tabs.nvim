local Section = require 'tabs.section'

local M = {
    sections = {
        Section:version(),
        Section:new { text = 'Tabs', highlight = 'Character' },
    },
}

function M:render()
    --
    local sections = {}
    for _, section in pairs(M.sections) do
        table.insert(sections, section:render())
    end
    return table.concat(sections, '|')
end

-- Create global alias
TabsRender = M.render

function M:setup()
    vim.api.nvim_set_option('showtabline', 2)
    vim.api.nvim_set_option('tabline', '%!v:lua.TabsRender()')
end

return M
