# tabs.nvim

A beautiful and informative tabline plugin for Neovim that renders tabs in a visually interesting way and provides useful information to users.

## Features

- **Custom Tabline Rendering**: Replaces Neovim's default tabline with a custom, visually appealing design
- **Session Information**: Displays current session name with an icon
- **Version Display**: Shows Neovim version information
- **Smart Tab Management**: Intelligently displays tab information with proper highlighting
- **Customizable Sections**: Modular section-based architecture for easy customization
- **Automatic Color Adaptation**: Adapts to your color scheme automatically
- **Built-in Keymaps**: Convenient keymaps for tab navigation

## Installation

### Using Lazy.nvim (Recommended)

Add this to your `init.lua` or plugin configuration:

```lua
{
    'your-username/tabs.nvim',
    event = 'VimEnter',
    config = function()
        require('tabs').setup()
    end,
}
```

### Using Packer

```lua
use {
    'your-username/tabs.nvim',
    config = function()
        require('tabs').setup()
    end,
}
```

### Using vim-plug

```vim
Plug 'your-username/tabs.nvim'
```

Then in your `init.lua`:
```lua
require('tabs').setup()
```

## Usage

Once installed and configured, the plugin will automatically:

1. Replace the default tabline with a custom one
2. Display session information, Neovim version, and tabs
3. Set up convenient keymaps for tab navigation

### Default Keymaps

The plugin provides these keymaps for easy tab navigation:

- `L` - Go to next tab
- `H` - Go to previous tab  
- `Tn` - Create new tab
- `Tc` - Close current tab

### Built-in Sections

The tabline includes three main sections:

1. **Version Section** (position 3): Shows Neovim version
2. **Session Section** (position 20): Shows current session name with icon
3. **Tabs Section** (position 40): Shows all tabs with current tab highlighted

## Configuration

### Basic Setup

```lua
require('tabs').setup()
```

### Custom Configuration

This plugin supports the following configuration options:

```lua
require('tabs').setup({
    -- Custom section positions
    sections = {
        version = { position = 5 },
        session = { position = 25 },
        tabs = { position = 50, justify = 'center' },
    },
    
    -- Custom file types to skip
    skip_filetypes = {
        ['NvimTree'] = true,
        ['neo-tree'] = true,
        ['aerial'] = true,
        ['help'] = true,
        ['qf'] = true,
        ['toggleterm'] = true, -- Additional file type
    },
    
    -- Custom color mappings
    colors = {
        fg_highlights = {
            grey = 'Comment',      -- Use Comment instead of NonText
            red = 'ErrorMsg',      -- Use ErrorMsg instead of Error
            orange = 'WarningMsg', -- Use WarningMsg instead of Constant
            blue = 'Function',     -- Keep Function
        },
        bg_highlights = {
            dark = 'Pmenu',        -- Use Pmenu instead of NormalFloat
        }
    }
})
```

### Highlight Groups

The plugin uses these highlight groups that you can customize:

- `TablineDefault` - Default tabline text
- `TablineVersion` - Version section text
- `TablineSessionIcon` - Session icon color
- `TablineSession` - Session name text
- `TablineTab` - Regular tab text
- `TablineCurrentTab` - Current tab text

Example customization:

```lua
-- In your colorscheme or init.lua
vim.api.nvim_set_hl(0, 'TablineCurrentTab', { fg = '#ff6b6b', bg = '#2d3748', bold = true })
vim.api.nvim_set_hl(0, 'TablineSession', { fg = '#fbbf24', bg = 'none', bold = true })
```

## File Type Filtering

The plugin automatically filters out certain file types from tab display:

- `NvimTree`
- `neo-tree`
- `aerial`
- `help`
- `qf`

You can modify this list in `lua/tabs/manager.lua` in the `skip_filetypes` table.

## Development

### Debugging

Use these commands to debug the tabline:

```vim
:TabsInspect  " Show debug information about the tabline
```

### Testing

The plugin includes a comprehensive test suite. To run tests locally:

```bash
# Run basic tests (no external dependencies)
make test

# Check Lua syntax
make lint

# Install development dependencies and run full test suite
make install
make test-full
```

For more information about testing, see the `tests/` directory and `Makefile`.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
