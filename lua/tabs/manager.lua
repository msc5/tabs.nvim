local Tab = require 'tabs.tab'

local M = {
    tabs = {
        Tab:new(),
    },
    current = {},
}

function M.on_tabnew()
    local tabnr = vim.api.nvim_get_current_tabpage()
    M.tabs[tabnr] = Tab:new()
    M.tab_info()
end

function M.on_tabclosed()
    local tabnr = vim.fn.expand '<afile>'
    M.tabs[tonumber(tabnr)] = nil
    M.tab_info()
end

function M.tab_rename()
    local tabnr = vim.api.nvim_get_current_tabpage()

    local Input = require 'nui.input'
    local input = Input({
        relative = 'editor',
        position = { row = 2, col = 27 },
        size = 20,
        border = { style = 'rounded', text = { top = 'Rename Tab', top_align = 'left' } },
        win_options = { winhighlight = 'Normal:NormalFloat' },
    }, {
        on_submit = function(value)
            M.tabs[tabnr].name = value
            vim.cmd [[ redrawtabline ]]
        end,
    })

    input:map('n', '<esc>', function() input:unmount() end, { noremap = true })
    input:map('n', 'q', function() input:unmount() end, { noremap = true })

    input:show()
end

function M.tab_info()
    --
    print(vim.inspect(M))
end

function M.setup()
    vim.api.nvim_create_autocmd({ 'TabNewEntered' }, { callback = M.on_tabnew })
    vim.api.nvim_create_autocmd({ 'TabClosed' }, { callback = M.on_tabclosed })

    vim.api.nvim_create_user_command('TabInfo', M.tab_info, {})
    vim.api.nvim_create_user_command('TabRename', M.tab_rename, {})
end

return M
