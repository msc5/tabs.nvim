# GitHub Actions Workflows

This directory contains GitHub Actions workflows for continuous integration.

## Available Workflows

### `test.yml` - Full Test Suite
- Runs the complete test suite using Neovim
- Includes syntax checking
- Provides debug information
- **Use this for comprehensive testing**

### `test-alt.yml` - Alternative Test Suite
- Uses the official Neovim setup action
- More reliable but may be slower
- **Use this if the main workflow fails**

### `syntax-check.yml` - Syntax Check Only
- Minimal workflow that only checks Lua syntax
- Fastest and most reliable
- **Use this for quick validation**

## Troubleshooting

### Common Issues

1. **Lua installation fails**
   - The workflows use `lua5.1` from Ubuntu repositories
   - If this fails, try the alternative workflow

2. **Neovim not found**
   - The main workflow installs Neovim via `apt-get`
   - The alternative workflow uses the official Neovim action

3. **Test failures**
   - Check the debug output in the workflow logs
   - Ensure all Lua files have valid syntax
   - Verify the test files are properly formatted

### Local Testing

Before pushing, test locally:

```bash
# Basic syntax check
make lint

# Run tests
make test

# Full test suite (requires busted)
make install
make test-full
```

## Workflow Selection

- **Default**: Use `test.yml` for comprehensive testing
- **Fallback**: Use `test-alt.yml` if the default fails
- **Quick**: Use `syntax-check.yml` for syntax validation only 