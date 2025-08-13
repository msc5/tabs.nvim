-- Test runner for tabs.nvim
-- Run with: nvim --headless -c "lua dofile('tests/run_tests.lua')"

local busted = require('busted')
local handler = require('busted.outputHandlers.base')

-- Add the lua directory to package.path for require statements
package.path = package.path .. ';lua/?.lua;lua/?/init.lua'

-- Configure busted
busted.setup({
    output = 'utfTerminal',
    verbose = true,
    suppressPending = false,
    suppressSkipped = false,
    shuffle = false,
    seed = os.time(),
    maxParallel = 1,
})

-- Run all test files
local test_files = {
    'tests/test_section.lua',
    'tests/test_str.lua',
    'tests/test_manager.lua',
}

local success = true
for _, test_file in ipairs(test_files) do
    print('Running tests in: ' .. test_file)
    local ok, err = pcall(function()
        busted.run(test_file)
    end)
    if not ok then
        print('Error running tests in ' .. test_file .. ': ' .. tostring(err))
        success = false
    end
end

if success then
    print('All tests completed successfully!')
    os.exit(0)
else
    print('Some tests failed!')
    os.exit(1)
end 