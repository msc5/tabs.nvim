local fs = require 'util.fs'

local Input = require 'nui.input'

local o = {
    current = {},
    tabs = {},
}

function o.get_tab_str(handle)
    local tab = o.getTab(handle)
    if tab ~= nil then
        if tab.handle == o.current.handle then
            return string.format('%s( %s %d )', '%#TablineCurrentTab#', tab.name, tab.number)
        else
            return string.format('%s  %s %d  ', '%#TablineTab#', tab.name, tab.number)
        end
    end
end

function o.getTab(handle) return o.tabs[tostring(handle)] end

function o.setTab(handle, value) o.tabs[tostring(handle)] = value end

function o.get_tabs()
    --

    -- Update current tab info
    o.current.handle = vim.api.nvim_get_current_tabpage()
    o.current.number = vim.api.nvim_tabpage_get_number(o.current.handle)

    -- Update all tabs info
    local modified, tabs_open = false, {}
    for _, handle in pairs(vim.api.nvim_list_tabpages()) do
        tabs_open[handle] = true

        -- Track new tab
        local tab = o.getTab(handle)
        if tab == nil then
            tab = { name = 'tab', handle = handle }
            o.setTab(handle, tab)
            modified = true
        end

        -- Update tab info
        local number = vim.api.nvim_tabpage_get_number(handle)
        if tab.number ~= number then
            tab.number = number
            modified = true
        end
    end

    -- Remove closed tabs
    for _, tab in pairs(o.tabs) do
        if not tabs_open[tab.handle] then o.setTab(tab.handle, nil) end
    end

    -- Sort tabs by `tabnr`
    table.sort(o.tabs, function(a, b) return a.number < b.number end)

    -- Save tabs
    if modified then o.saveTabs() end
end

function o.saveTabs()
    local success, result = pcall(function()
        if vim.v.this_session ~= nil then
            local path = fs.join(vim.fn.stdpath 'cache', 'tabs', fs.basename(vim.v.this_session))
            local json = vim.fn.json_encode(o.tabs)
            vim.fn.writefile({ json }, path)
        end
    end)
    if not success then
        local msg = 'Failed to save tab info\nError:\n' .. result
        vim.notify(msg, vim.log.levels.ERROR, { title = 'Tabs' })
    end
end

function o.loadTabs()
    local success, result = pcall(function()
        if vim.v.this_session ~= nil then
            local path = fs.join(vim.fn.stdpath 'cache', 'tabs', fs.basename(vim.v.this_session))
            local success, data = pcall(function() return vim.fn.readfile(path) end)
            if success then
                local tabs = vim.fn.json_decode(data)
                o.tabs = tabs
            end
        end
    end)
    if not success then
        local msg = 'Failed to load tab info\nError:\n' .. result
        vim.notify(msg, vim.log.levels.ERROR, { title = 'Tabs' })
    end
end

function o.tabinfo()
    --
    print(vim.inspect(o))
end

function o.tabstr()
    --
    local tabs = {}
    for _, tab in pairs(o.tabs) do
        table.insert(tabs, o.get_tab_str(tab.handle))
    end
    return table.concat(tabs, ' ')
end

function o.tabrename()
    local handle = vim.api.nvim_get_current_tabpage()

    local popup_options = {
        relative = 'editor',
        position = { row = 2, col = 27 },
        size = 20,
        border = {
            style = 'rounded',
            text = { top = 'Name Tab', top_align = 'left' },
        },
        win_options = {
            winhighlight = 'Normal:Normal',
        },
    }

    local input = Input(popup_options, {
        on_submit = function(value)
            --
            local tab = o.getTab(handle)
            tab.name = value
            vim.cmd [[ redrawtabline ]]
            o.saveTabs()
        end,
    })

    input:map('n', '<esc>', function() input:unmount() end, { noremap = true })
    input:map('n', 'q', function() input:unmount() end, { noremap = true })

    input:show()
end

function o.session()
    local sess
    if vim.v.this_session ~= '' then
        sess = ' 󰮄  ' .. fs.basename(vim.v.this_session)
    else
        sess = ''
    end
    return sess
end

function o.version()
    local v = vim.version()
    return string.format('Neovim v%d.%d.%d', v.major, v.minor, v.patch)
end

function o.tabline()
    --
    pcall(o.get_tabs)

    local rainbow = require('util.colors').rainbow()
    local background = vim.api.nvim_get_hl(0, { name = 'NormalFloat' })
    local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end
    local theme = {
        hl('TablineVersion', { fg = rainbow.grey, bg = background.bg }),
        hl('TablineSession', { fg = rainbow.orange, bg = background.bg, bold = true }),
        hl('TablineTab', { fg = rainbow.grey, bg = background.bg }),
        hl('TablineCurrentTab', { fg = rainbow.blue, bg = background.bg }),
    }
    return (
        '%#TablineVersion#'
        .. ' '
        .. o.version()
        .. '  '
        .. '%#TablineSession#'
        .. o.session()
        .. '  '
        .. o.tabstr()
    )
end

function o.setup()
    CustomTabline = o.tabline
    vim.api.nvim_set_option('showtabline', 2)
    vim.api.nvim_set_option('tabline', '%!v:lua.CustomTabline()')

    vim.api.nvim_create_user_command('TabRename', o.tabrename, {})
    vim.api.nvim_create_user_command('TabInfo', o.tabinfo, {})

    local opts = { silent = true, noremap = true }
    vim.api.nvim_set_keymap('n', 'L', '<cmd>tabnext<cr>', opts)
    vim.api.nvim_set_keymap('n', 'H', '<cmd>tabprevious<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tr', '<cmd>TabRename<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Ti', '<cmd>TabInfo<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tn', '<cmd>tabnew<cr>', opts)
    vim.api.nvim_set_keymap('n', 'Tc', '<cmd>tabclose<cr>', opts)
end

return o
