.PHONY: test lint clean help

# Default target
help:
	@echo "Available targets:"
	@echo "  test    - Run all tests"
	@echo "  lint    - Check Lua syntax"
	@echo "  clean   - Remove temporary files"
	@echo "  install - Install plugin dependencies"

# Run tests
test:
	@echo "Running tests..."
	@nvim --headless -c "lua dofile('tests/simple_test.lua')"

# Check Lua syntax
lint:
	@echo "Checking Lua syntax..."
	@find lua -name "*.lua" -exec luac -p {} \;
	@find tests -name "*.lua" -exec luac -p {} \;
	@echo "✓ All Lua files have valid syntax"

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.swp" -delete
	@find . -name "*.swo" -delete
	@find . -name "*~" -delete
	@echo "✓ Cleaned"

# Install dependencies (for development)
install:
	@echo "Installing development dependencies..."
	@luarocks install busted
	@luarocks install luassert
	@echo "✓ Dependencies installed"

# Run full test suite (requires busted)
test-full:
	@echo "Running full test suite with busted..."
	@nvim --headless -c "lua dofile('tests/run_tests.lua')" 