local M = {}
local config = require('tabs.config')
local utils = require('tabs.utils')

---Check if buffer should be included in tab display
---@param buf integer Buffer handle
---@return boolean
local function should_include_buffer(buf)
    local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
    local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
    local skip_filetypes = config.get('skip_filetypes', {
        ['NvimTree'] = true,
        ['neo-tree'] = true,
        ['aerial'] = true,
        ['help'] = true,
        ['qf'] = true,
    })
    return bt == '' and not skip_filetypes[ft]
end

---Process tab windows to get real windows
---@param wins table Window handles
---@return table real_windows
---@return string? tab_name
local function process_tab_windows(wins)
    local wins_real = {}
    local name = nil
    
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if should_include_buffer(buf) then
            local fullpath = vim.api.nvim_buf_get_name(buf)
            local relpath = vim.fn.fnamemodify(fullpath, ':.')
            
            if not name and relpath ~= '' then 
                name = relpath 
            end
            table.insert(wins_real, win)
        end
    end
    
    return wins_real, name
end

function M.tabs()
    local tabs = {}

    for number, handle in pairs(vim.api.nvim_list_tabpages()) do
        local wins = vim.api.nvim_tabpage_list_wins(handle)
        local wins_real, name = process_tab_windows(wins)
        
        local heading = ('  %s (%s)  '):format(name or 'Tab', #wins_real)

        table.insert(tabs, {
            name = name,
            heading = heading,
            number = number,
            handle = handle,
            windows = wins_real,
            is_current = handle == vim.api.nvim_get_current_tabpage(),
        })
    end
    return tabs
end

function M.setup()
    local opts = { silent = true, noremap = true }
    local keymaps = config.get('keymaps', {
        next = 'L',
        prev = 'H',
        new = 'Tn',
        close = 'Tc',
    })
    
    vim.api.nvim_set_keymap('n', keymaps.next, '<cmd>tabnext<cr>', opts)
    vim.api.nvim_set_keymap('n', keymaps.prev, '<cmd>tabprevious<cr>', opts)
    vim.api.nvim_set_keymap('n', keymaps.new, '<cmd>tabnew<cr>', opts)
    vim.api.nvim_set_keymap('n', keymaps.close, '<cmd>tabclose<cr>', opts)
end

return M
