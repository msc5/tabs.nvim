local M = {
    session = {},
}

local config = require 'tabs.config'

function M.render() return M.tabline:render() end

---Setup the tabs.nvim plugin
---@param opts? table Configuration options
function M.setup(opts)
    -- Setup configuration first (with fallback to defaults)
    if opts then config.setup(opts) end

    -- Setup modules
    M.manager = require('tabs.manager').setup()
    M.colors = require('tabs.colors').setup()
    M.tabline = require('tabs.tabline').setup()

    -- Configure Neovim options
    vim.api.nvim_set_option_value('showtabline', 1, {})
    vim.api.nvim_set_option_value('tabline', "%!v:lua.require('tabs').render()", {})

    -- Add user command for debugging
    vim.api.nvim_create_user_command('TabsInspect', function()
        local tabline = require('tabs').tabline
        if not tabline then
            print '❌ Tabline not initialized. Run :TabsSetup first.'
            return
        end

        tabline:render()
        print '📊 tabs.nvim debug information:'
        print('Columns: ' .. vim.o.columns)
        print('Text length: ' .. vim.fn.strdisplaywidth(tabline.text))
        print('Raw text: |' .. tabline.text .. '|')
        print('Sections count: ' .. #tabline.sections)
        print('Highlights count: ' .. #tabline.highlights)
    end, {})
end

return M
