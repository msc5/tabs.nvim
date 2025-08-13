---@class TabsConfig
---@field sections? table Configuration for tabline sections
---@field skip_filetypes? table File types to skip in tab display
---@field keymaps? table Custom keymap configuration
---@field colors? table Custom color configuration

local M = {
    sections = {
        version = { position = 3 },
        session = { position = 20 },
        tabs = { position = 40, justify = 'right' },
    },
    skip_filetypes = {
        ['NvimTree'] = true,
        ['neo-tree'] = true,
        ['aerial'] = true,
        ['help'] = true,
        ['qf'] = true,
    },
    colors = {
        -- Default color mappings - can be overridden
        fg_highlights = {
            grey = 'NonText',
            red = 'Error',
            purple = 'Statement',
            orange = 'Constant',
            blue = 'Function',
            cyan = 'Character',
            light_blue = 'Label',
            pink = 'Macro',
        },
        bg_highlights = {
            dark = 'NormalFloat',
        }
    }
}

---Setup configuration with user options
---@param opts? TabsConfig Configuration options
---@return table
function M.setup(opts)
    opts = opts or {}
    
    -- Deep merge configuration
    for key, value in pairs(opts) do
        if M[key] then
            if type(value) == 'table' and type(M[key]) == 'table' then
                M[key] = vim.tbl_deep_extend('force', M[key], value)
            else
                M[key] = value
            end
        end
    end
    
    return M
end

---Get a configuration value with fallback
---@param key string Configuration key
---@param default any Default value if key doesn't exist
---@return any
function M.get(key, default)
    local keys = vim.split(key, '.', { plain = true })
    local value = M
    
    for _, k in ipairs(keys) do
        if value and type(value) == 'table' then
            value = value[k]
        else
            return default
        end
    end
    
    return value ~= nil and value or default
end

---Validate configuration
---@return boolean success
---@return string? error_message
function M.validate()
    local errors = {}
    
    -- Validate sections
    if not M.sections then
        table.insert(errors, 'sections configuration is required')
    end
    
    -- Validate keymaps
    if not M.keymaps then
        table.insert(errors, 'keymaps configuration is required')
    end
    
    -- Validate skip_filetypes
    if not M.skip_filetypes then
        table.insert(errors, 'skip_filetypes configuration is required')
    end
    
    if #errors > 0 then
        return false, 'Configuration errors: ' .. table.concat(errors, ', ')
    end
    
    return true
end

return M 