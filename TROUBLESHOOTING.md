# Troubleshooting Guide

## Common Issues

### 1. **Tabs Not Visible**

**Symptoms**: No tabline appears at the top of the window

**Solutions**:
1. **Check if the plugin is loaded**:
   ```vim
   :lua print(require('tabs') ~= nil)
   ```

2. **Manually setup the plugin**:
   ```vim
   :TabsSetup
   ```

3. **Check Neovim options**:
   ```vim
   :set showtabline?    " Should be 1
   :set tabline?        " Should show the tabline function
   ```

4. **Debug the tabline**:
   ```vim
   :TabsInspect
   ```

5. **Check if sections are rendering**:
   ```vim
   :lua local tabs = require('tabs'); tabs.setup(); print(tabs.render())
   ```

### 2. **Configuration Errors**

**Symptoms**: Error messages about configuration

**Solutions**:
1. **Use default configuration**:
   ```lua
   require('tabs').setup()  -- No arguments
   ```

2. **Check your configuration syntax**:
   ```lua
   require('tabs').setup({
       sections = {
           version = { position = 3 },
           session = { position = 20 },
           tabs = { position = 40, justify = 'right' },
       }
   })
   ```

### 3. **Color Issues**

**Symptoms**: Tabs appear but with wrong colors

**Solutions**:
1. **Check if your colorscheme is loaded**:
   ```vim
   :colorscheme
   ```

2. **Customize colors**:
   ```lua
   require('tabs').setup({
       colors = {
           fg_highlights = {
               grey = 'Comment',      -- Use different highlight groups
               red = 'ErrorMsg',
           }
       }
   })
   ```

### 4. **Keymaps Not Working**

**Symptoms**: Tab navigation keymaps don't work

**Solutions**:
1. **Check if keymaps are set**:
   ```vim
   :map L
   :map H
   ```

2. **Customize keymaps**:
   ```lua
   require('tabs').setup({
       keymaps = {
           next = 'L',
           prev = 'H',
           new = 'Tn',
           close = 'Tc',
       }
   })
   ```

### 5. **Performance Issues**

**Symptoms**: Slow tabline rendering

**Solutions**:
1. **Reduce file type filtering**:
   ```lua
   require('tabs').setup({
       skip_filetypes = {
           ['help'] = true,
           ['qf'] = true,
           -- Remove unnecessary file types
       }
   })
   ```

2. **Simplify sections**:
   ```lua
   require('tabs').setup({
       sections = {
           tabs = { position = 0, justify = 'left' },  -- Only show tabs
       }
   })
   ```

## Debug Commands

### `:TabsSetup`
Manually initialize the plugin. Use this if the plugin doesn't load automatically.

### `:TabsInspect`
Show detailed information about the current tabline state, including:
- Number of columns
- Text length
- Raw tabline text
- Number of sections
- Number of highlights

## Getting Help

If you're still having issues:

1. **Check the logs**: Look for error messages in `:messages`
2. **Run tests locally**: `make test`
3. **Check syntax**: `make lint`
4. **Create a minimal config**: Test with just `require('tabs').setup()`

## Common Configuration Examples

### Minimal Setup
```lua
require('tabs').setup()
```

### Custom Positions
```lua
require('tabs').setup({
    sections = {
        version = { position = 5 },
        session = { position = 25 },
        tabs = { position = 50, justify = 'center' },
    }
})
```

### Custom Colors
```lua
require('tabs').setup({
    colors = {
        fg_highlights = {
            grey = 'Comment',
            red = 'ErrorMsg',
            orange = 'WarningMsg',
            blue = 'Function',
        }
    }
})
```

### Custom Keymaps
```lua
require('tabs').setup({
    keymaps = {
        next = '<C-l>',
        prev = '<C-h>',
        new = '<C-t>',
        close = '<C-w>',
    }
})
``` 