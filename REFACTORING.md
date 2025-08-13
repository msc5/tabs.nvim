# Refactoring Analysis for tabs.nvim

This document identifies areas of the codebase that could benefit from refactoring and improvement.

## Code Quality Issues

### 1. **Tabline Module (`lua/tabs/tabline.lua`)**

#### Issues:
- **Complex string manipulation**: The `replace` and `insert` methods use complex UTF-8 offset calculations that could be simplified
- **Repeated sorting**: The `highlight` method sorts the highlights array multiple times
- **Magic numbers**: Hard-coded positions (3, 20, 40) in the setup function
- **Mixed responsibilities**: The module handles both rendering and user commands

#### Suggested Improvements:
```lua
-- Extract string manipulation to a separate utility
local function insert_text_at_position(text, insert_text, position)
    local sub_stop = utf8.offset(text, position - 1)
    local sub_start = utf8.offset(text, position)
    return text:sub(0, sub_stop) .. insert_text .. text:sub(sub_start)
end

-- Optimize highlight processing
function Tabline:highlight()
    local highlights = {}
    
    -- Process all highlights in one pass
    for _, highlight in pairs(self.highlights) do
        table.insert(highlights, { pos = highlight.start, text = '%#' .. highlight.group .. '#' })
        table.insert(highlights, { pos = highlight.stop, text = '%#TablineDefault#' })
    end
    
    -- Single sort operation
    table.sort(highlights, function(a, b) return a.pos > b.pos end)
    
    for _, highlight in pairs(highlights) do
        self:insert(highlight.text, highlight.pos)
    end
    
    self.text = '%#TablineDefault#' .. self.text
end
```

### 2. **Manager Module (`lua/tabs/manager.lua`)**

#### Issues:
- **Complex tab processing**: The `tabs()` function has nested loops and complex logic
- **Hard-coded file type filtering**: The `skip_filetypes` table is hard-coded
- **Mixed concerns**: Combines tab management with keymap setup

#### Suggested Improvements:
```lua
-- Extract file type filtering to configuration
local config = {
    skip_filetypes = {
        ['NvimTree'] = true,
        ['neo-tree'] = true,
        ['aerial'] = true,
        ['help'] = true,
        ['qf'] = true,
    }
}

-- Separate tab processing logic
local function process_tab_windows(wins)
    local wins_real = {}
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if should_include_buffer(buf) then
            table.insert(wins_real, win)
        end
    end
    return wins_real
end

local function should_include_buffer(buf)
    local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
    local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
    return bt == '' and not config.skip_filetypes[ft]
end
```

### 3. **Section Module (`lua/tabs/section.lua`)**

#### Issues:
- **Error handling**: Uses `pcall` for every text/section access, which could be optimized
- **Repeated pattern**: Similar logic for `get_text` and `get_sections`
- **Hard-coded positions**: Session section has hard-coded position values

#### Suggested Improvements:
```lua
-- Extract common function calling pattern
local function safe_call(func_or_value)
    if type(func_or_value) == 'function' then
        local success, result = pcall(func_or_value)
        return success and result or nil
    end
    return func_or_value
end

function Section:get_text()
    return safe_call(self.text)
end

function Section:get_sections()
    return safe_call(self.sections)
end

-- Make positions configurable
local function create_session_section(config)
    return Section:new {
        sections = {
            Section:new {
                text = config.session_icon or '󰮄 ',
                highlight = 'TablineSessionIcon',
                position = config.icon_position or 0,
            },
            Section:new {
                text = function()
                    return vim.v.this_session ~= '' and vim.fs.basename(vim.v.this_session) or ''
                end,
                highlight = 'TablineSession',
                position = config.text_position or 3,
            },
        },
    }
end
```

### 4. **Colors Module (`lua/tabs/colors.lua`)**

#### Issues:
- **Hard-coded color mappings**: Color mappings are hard-coded
- **No fallback handling**: No handling for missing highlight groups
- **Mixed color gathering and setting**: Combines color extraction with highlight setting

#### Suggested Improvements:
```lua
-- Extract color gathering to separate function
local function gather_colors()
    local colors = { fg = {}, bg = {} }
    
    local fg_highlights = {
        grey = 'NonText',
        red = 'Error',
        purple = 'Statement',
        orange = 'Constant',
        blue = 'Function',
        cyan = 'Character',
        light_blue = 'Label',
        pink = 'Macro',
    }
    
    for color, highlight in pairs(fg_highlights) do
        local hl = vim.api.nvim_get_hl(0, { name = highlight })
        colors.fg[color] = hl.fg or '#808080' -- fallback color
    end
    
    return colors
end

-- Separate highlight setting
local function setup_highlights(colors)
    local hl = function(name, opts) 
        vim.api.nvim_set_hl(0, name, opts) 
    end
    
    hl('TablineDefault', { fg = colors.fg.grey, bg = 'none' })
    hl('TablineVersion', { fg = colors.fg.grey, bg = 'none' })
    -- ... other highlights
end
```

## Architectural Improvements

### 1. **Configuration System**

Create a centralized configuration system:

```lua
-- lua/tabs/config.lua
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
    keymaps = {
        next = 'L',
        prev = 'H',
        new = 'Tn',
        close = 'Tc',
    }
}

function M.setup(opts)
    opts = opts or {}
    for key, value in pairs(opts) do
        if M[key] then
            if type(value) == 'table' then
                M[key] = vim.tbl_deep_extend('force', M[key], value)
            else
                M[key] = value
            end
        end
    end
    return M
end

return M
```

### 2. **Error Handling**

Add proper error handling throughout the codebase:

```lua
-- lua/tabs/utils.lua
local M = {}

function M.safe_require(module)
    local success, result = pcall(require, module)
    if not success then
        vim.notify('tabs.nvim: Failed to load ' .. module, vim.log.levels.ERROR)
        return nil
    end
    return result
end

function M.validate_config(config)
    local errors = {}
    
    if not config.sections then
        table.insert(errors, 'sections configuration is required')
    end
    
    if #errors > 0 then
        vim.notify('tabs.nvim configuration errors: ' .. table.concat(errors, ', '), vim.log.levels.ERROR)
        return false
    end
    
    return true
end

return M
```

### 3. **Performance Optimizations**

- **Caching**: Cache expensive operations like highlight group lookups
- **Lazy loading**: Only load sections when needed
- **Reduced API calls**: Batch Neovim API calls where possible

```lua
-- Cache highlight groups
local highlight_cache = {}

local function get_highlight(name)
    if not highlight_cache[name] then
        highlight_cache[name] = vim.api.nvim_get_hl(0, { name = name })
    end
    return highlight_cache[name]
end

-- Clear cache on colorscheme change
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        highlight_cache = {}
    end
})
```

## Testing Improvements

### 1. **Mock System**

Create a proper mocking system for Neovim API calls:

```lua
-- tests/mocks.lua
local M = {}

function M.mock_vim_api()
    local mock_api = {
        nvim_list_tabpages = function() return { 1, 2, 3 } end,
        nvim_get_current_tabpage = function() return 1 end,
        nvim_tabpage_list_wins = function() return { 1, 2 } end,
        -- ... other API functions
    }
    
    -- Replace vim.api with mock
    local original_api = vim.api
    vim.api = mock_api
    
    return function()
        vim.api = original_api
    end
end

return M
```

### 2. **Integration Tests**

Add integration tests that test the full plugin functionality:

```lua
-- tests/integration.lua
describe('Integration Tests', function()
    it('should render tabline correctly', function()
        local tabs = require('tabs')
        tabs.setup()
        
        local result = tabs.render()
        assert.is_not_nil(result)
        assert.is_string(result)
        assert.is_true(#result > 0)
    end)
end)
```

## Documentation Improvements

### 1. **API Documentation**

Add comprehensive API documentation using LuaDoc:

```lua
---@class TabsConfig
---@field sections? table Configuration for tabline sections
---@field skip_filetypes? table File types to skip in tab display
---@field keymaps? table Custom keymap configuration

---Setup the tabs.nvim plugin
---@param opts? TabsConfig Configuration options
function M.setup(opts)
    -- implementation
end
```

### 2. **Examples**

Add more examples in the README for common use cases:

```lua
-- Custom section configuration
require('tabs').setup({
    sections = {
        version = { position = 5 },
        session = { position = 25 },
        tabs = { position = 50, justify = 'center' },
    }
})
```

## Priority Recommendations

1. **High Priority**:
   - Extract configuration system
   - Improve error handling
   - Optimize highlight processing

2. **Medium Priority**:
   - Refactor string manipulation utilities
   - Add proper mocking for tests
   - Improve documentation

3. **Low Priority**:
   - Performance optimizations
   - Additional customization options
   - Extended test coverage

## Conclusion

The codebase is well-structured but would benefit from:
- Better separation of concerns
- Centralized configuration
- Improved error handling
- More comprehensive testing
- Performance optimizations

These improvements would make the plugin more maintainable, testable, and user-friendly. 