local Tab = require 'tabs.tab'

local M = {
    tabs = {
        Tab:new { number = 1 },
    },
}

function M.get_current()
    local handle = vim.api.nvim_get_current_tabpage()
    local number = vim.api.nvim_tabpage_get_number(handle)
    return handle, number
end

function M.on_tabnew()
    local _, number = M.get_current()
    M.tabs[number] = Tab:new { number = number }
end

function M.on_tabclosed()
    local number = vim.fn.expand '<afile>'
    M.tabs[tonumber(number)] = nil
end

function M.tab_rename()
    local _, number = M.get_current()

    local Input = require 'nui.input'
    local input = Input({
        relative = 'editor',
        position = { row = 2, col = 27 },
        size = 20,
        border = { style = 'rounded', text = { top = 'Rename Tab', top_align = 'left' } },
        win_options = { winhighlight = 'Normal:NormalFloat' },
    }, {
        on_submit = function(value)
            M.tabs[number].name = value
            vim.cmd [[ redrawtabline ]]
        end,
    })

    input:map('n', '<esc>', function() input:unmount() end, { noremap = true })
    input:map('n', 'q', function() input:unmount() end, { noremap = true })

    input:show()
end

function M.tab_info()
    --
    local tabline = require 'tabs.tabline'
    print(vim.inspect(M))
    print(vim.inspect(tabline.sections))
    print(tabline:render())
end

function M.setup()
    vim.api.nvim_create_autocmd({ 'TabNewEntered' }, { callback = M.on_tabnew })
    vim.api.nvim_create_autocmd({ 'TabClosed' }, { callback = M.on_tabclosed })

    vim.api.nvim_create_user_command('TabInfo', M.tab_info, {})
    vim.api.nvim_create_user_command('TabRename', M.tab_rename, {})
end

return M
