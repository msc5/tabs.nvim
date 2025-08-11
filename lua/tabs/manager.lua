local M = {}

local skip_filetypes = {
    ['NvimTree'] = true,
    ['neo-tree'] = true,
    ['aerial'] = true,
    ['help'] = true,
    ['qf'] = true,
}

function M.tabs()
    local tabs = {}

    for number, handle in pairs(vim.api.nvim_list_tabpages()) do
        local name

        local wins = vim.api.nvim_tabpage_list_wins(handle)
        local wins_real = {}

        for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
            local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })

            if bt == '' and not skip_filetypes[ft] then
                local fullpath = vim.api.nvim_buf_get_name(buf)
                local relpath = vim.fn.fnamemodify(fullpath, ':.')

                if name ~= '' then name = relpath end
                table.insert(wins_real, win)
            end
        end

        local windows = vim.api.nvim_tabpage_list_wins(handle)
        local heading = ('  %s (%s)  '):format(name, #wins_real)

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
