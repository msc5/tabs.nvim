local M = {}

function M.tabs()
    local tabs = {}

    -- Get Diffview tabs
    local diffview_tabs = {}
    pcall(function()
        for _, view in pairs(require('diffview.lib').views) do
            diffview_tabs[view.tabpage] = true
        end
    end)

    for number, handle in pairs(vim.api.nvim_list_tabpages()) do
        --
        local name

        if diffview_tabs[handle] then
            name = 'Diffview'
        else
            name = 'Tab'
        end

        --
        local windows = vim.api.nvim_tabpage_list_wins(handle)
        local heading = '( ' .. name .. ' ' .. number .. ' )'

        table.insert(tabs, {
            name = name,
            heading = heading,
            number = number,
            handle = handle,
            windows = windows,
            is_current = handle == vim.api.nvim_get_current_tabpage(),
        })
    end
    return tabs
end

function M.setup()
    local opts = { silent = true, noremap = true }
    vim.api.nvim_set_keymap('n', 'L', '<cmd>tabnext<cr>', opts)
    vim.api.nvim_set_keymap('n', 'H', '<cmd>tabprevious<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tn', '<cmd>tabnew<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tc', '<cmd>tabclose<cr>', opts)
end

return M
