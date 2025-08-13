local M = {}

---Safe require function with error handling
---@param module string Module name to require
---@return any? module_or_nil
function M.safe_require(module)
    local success, result = pcall(require, module)
    if not success then
        vim.notify('tabs.nvim: Failed to load ' .. module .. ': ' .. tostring(result), vim.log.levels.ERROR)
        return nil
    end
    return result
end

---Safe function call with error handling
---@param func function|any Function to call or value to return
---@return any? result_or_nil
function M.safe_call(func)
    if type(func) == 'function' then
        local success, result = pcall(func)
        if not success then
            vim.notify('tabs.nvim: Function call failed: ' .. tostring(result), vim.log.levels.WARN)
            return nil
        end
        return result
    end
    return func
end

---Insert text at position with UTF-8 awareness
---@param text string Original text
---@param insert_text string Text to insert
---@param position integer Position to insert at (1-indexed)
---@return string
function M.insert_text_at_position(text, insert_text, position)
    local utf8 = require('utf8')
    local sub_stop = utf8.offset(text, position - 1)
    local sub_start = utf8.offset(text, position)
    return text:sub(0, sub_stop) .. insert_text .. text:sub(sub_start)
end

---Replace text at position with UTF-8 awareness
---@param text string Original text
---@param replace_text string Text to replace with
---@param position integer Position to replace at (1-indexed)
---@param length integer Length of text to replace
---@return string
function M.replace_text_at_position(text, replace_text, position, length)
    local utf8 = require('utf8')
    local sub_stop = utf8.offset(text, position - 1)
    local sub_start = utf8.offset(text, position + length)
    return text:sub(0, sub_stop) .. replace_text .. text:sub(sub_start)
end

---Cache for expensive operations
local cache = {}

---Get cached value or compute and cache
---@param key string Cache key
---@param compute_func function Function to compute value if not cached
---@return any
function M.cached(key, compute_func)
    if cache[key] == nil then
        cache[key] = compute_func()
    end
    return cache[key]
end

---Clear cache
---@param key? string Specific key to clear, or all if nil
function M.clear_cache(key)
    if key then
        cache[key] = nil
    else
        cache = {}
    end
end

---Validate configuration
---@param config table Configuration to validate
---@return boolean success
---@return string? error_message
function M.validate_config(config)
    local errors = {}
    
    if not config then
        return false, 'Configuration is required'
    end
    
    if not config.sections then
        table.insert(errors, 'sections configuration is required')
    end
    
    if not config.skip_filetypes then
        table.insert(errors, 'skip_filetypes configuration is required')
    end
    
    if not config.keymaps then
        table.insert(errors, 'keymaps configuration is required')
    end
    
    if #errors > 0 then
        return false, 'Configuration errors: ' .. table.concat(errors, ', ')
    end
    
    return true
end

---Log message with plugin prefix
---@param level integer Log level
---@param message string Message to log
function M.log(level, message)
    vim.notify('tabs.nvim: ' .. message, level)
end

---Log error message
---@param message string Error message
function M.log_error(message)
    M.log(vim.log.levels.ERROR, message)
end

---Log warning message
---@param message string Warning message
function M.log_warn(message)
    M.log(vim.log.levels.WARN, message)
end

---Log info message
---@param message string Info message
function M.log_info(message)
    M.log(vim.log.levels.INFO, message)
end

return M 