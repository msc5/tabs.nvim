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
    local number = tonumber(vim.fn.expand '<afile>')
    if number ~= nil then
        local tabs = {}
        for i = 1, #M.tabs do
            if i < number then
                tabs[i] = M.tabs[i]
            elseif i < #M.tabs then
                tabs[i] = M.tabs[i + 1]
                tabs[i].number = i
            end
        end
        M.tabs = tabs
    end
end

function M.save_path()
    local session = vim.fs.basename(vim.v.this_session)
    local path = table.concat({ vim.fn.stdpath 'cache', 'tabs', session }, '/')
    return vim.fs.normalize(path)
end

function M.save()
    pcall(function()
        if vim.v.this_session ~= nil then
            local serialized = {}
            for _, tab in pairs(M.tabs) do
                table.insert(serialized, tab:serialize())
            end
            local json = vim.fn.json_encode(serialized)
            vim.fn.writefile({ json }, M.save_path())
        end
    end)
end

function M.load()
    pcall(function()
        if vim.v.this_session ~= nil then
            local success, data = pcall(function() return vim.fn.readfile(M.save_path()) end)
            if success then
                M.tabs = {}
                local tabs = vim.fn.json_decode(data)
                if tabs then
                    for _, tab in pairs(tabs) do
                        table.insert(M.tabs, Tab:new(tab))
                    end
                end
            end
        end
    end)
end

function M.tab_rename()
    local Input = require 'nui.input'
    local input = Input({
        relative = 'editor',
        position = { row = 2, col = 27 },
        size = 20,
        border = { style = 'rounded', text = { top = 'Rename Tab', top_align = 'left' } },
        win_options = { winhighlight = 'Normal:NormalFloat' },
    }, {
        on_submit = function(value)
            local _, number = M.get_current()
            M.tabs[number].name = value
            M.save()
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
    vim.api.nvim_create_autocmd({ 'SessionLoadPost' }, { callback = M.load })

    vim.api.nvim_create_user_command('TabInfo', M.tab_info, {})
    vim.api.nvim_create_user_command('TabRename', M.tab_rename, {})
    vim.api.nvim_create_user_command('TabSave', M.save, {})
    vim.api.nvim_create_user_command('TabLoad', M.load, {})

    local opts = { silent = true, noremap = true }
    vim.api.nvim_set_keymap('n', 'L', '<cmd>tabnext<cr>', opts)
    vim.api.nvim_set_keymap('n', 'H', '<cmd>tabprevious<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tr', '<cmd>TabRename<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Ti', '<cmd>TabInfo<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tn', '<cmd>tabnew<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tc', '<cmd>tabclose<cr>', opts)
end

return M
