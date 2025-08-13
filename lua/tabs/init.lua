local M = {
    session = {},
}

local config = require 'tabs.config'

function M.render() return M.tabline:render() end

function M.breakout()
    local current_tabpage = vim.api.nvim_get_current_tabpage()
    local wins = vim.api.nvim_tabpage_list_wins(current_tabpage)

    -- Filter out sidebars like NvimTree, Trouble, etc.
    local real_wins = vim.tbl_filter(function(win)
        local win_config = vim.api.nvim_win_get_config(win)
        if win_config.relative ~= '' then return false end -- floating window
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        return not vim.tbl_contains({
            'NvimTree',
            'aerial',
            'trouble',
        }, ft)
    end, wins)

    -- Only continue if there's more than one real window
    if #real_wins <= 1 then return end

    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()

    -- Open a new tab
    vim.cmd 'tabnew'

    -- Set the buffer to the one from the previous window
    vim.api.nvim_win_set_buf(0, buf)

    -- Close the original window
    vim.api.nvim_win_close(win, true)
end

---Setup the tabs.nvim plugin
---@param opts? table Configuration options
function M.setup(opts)
    -- Setup configuration first (with fallback to defaults)
    if opts then config.setup(opts) end

    -- Setup modules
    M.colors = require('tabs.colors').setup()
    M.tabline = require('tabs.tabline').setup()

    -- Configure Neovim options
    vim.api.nvim_set_option_value('showtabline', 1, {})
    vim.api.nvim_set_option_value('tabline', "%!v:lua.require('tabs').render()", {})

    -- Add user command for debugging
    vim.api.nvim_create_user_command('TabsInspect', function()
        local tabline = require('tabs').tabline

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
