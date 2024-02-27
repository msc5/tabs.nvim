local M = {
    session = {},
}

function M.render() return M.tabline:render() end

function M.setup()
    M.manager = require('tabs.manager').setup()
    M.colors = require('tabs.colors').setup()
    M.tabline = require('tabs.tabline').setup()

    vim.api.nvim_set_option('showtabline', 2)
    vim.api.nvim_set_option('tabline', "%!v:lua.require('tabs').render()")
end

return M
