local M = {
    session = {},
}

local config = require('tabs.config')
local utils = require('tabs.utils')

function M.render() 
    return M.tabline:render() 
end

---Setup the tabs.nvim plugin
---@param opts? table Configuration options
function M.setup(opts)
    -- Setup configuration first (with fallback to defaults)
    if opts then
        config.setup(opts)
    end
    
    -- Setup modules
    M.manager = require('tabs.manager').setup()
    M.colors = require('tabs.colors').setup()
    M.tabline = require('tabs.tabline').setup()

    -- Configure Neovim options
    vim.api.nvim_set_option_value('showtabline', 1, {})
    vim.api.nvim_set_option_value('tabline', "%!v:lua.require('tabs').render()", {})
    
    if opts then
        utils.log_info('tabs.nvim setup complete with custom configuration')
    else
        utils.log_info('tabs.nvim setup complete with default configuration')
    end
end

return M
