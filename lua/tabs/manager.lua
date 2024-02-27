local M = {}

function M.tabs()
    -- Lists all tabs
    local tabs = {}
    for number, handle in pairs(vim.api.nvim_list_tabpages()) do
        table.insert(tabs, {
            name = 'Tab',
            number = number,
            handle = handle,
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
