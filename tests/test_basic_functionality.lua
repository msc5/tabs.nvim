-- Basic functionality test for tabs.nvim
-- This test verifies that the plugin can be set up and render a tabline

package.path = package.path .. ';lua/?.lua;lua/?/init.lua'

local function test_basic_functionality()
    print("Testing basic functionality...")
    
    -- Test that the plugin can be required
    local tabs = require('tabs')
    assert(tabs, "tabs module should be loadable")
    assert(type(tabs.setup) == 'function', "tabs.setup should be a function")
    assert(type(tabs.render) == 'function', "tabs.render should be a function")
    
    -- Test that setup works without configuration
    local success, err = pcall(function()
        tabs.setup()
    end)
    assert(success, "tabs.setup() should work without configuration: " .. tostring(err))
    
    -- Test that tabline is created
    assert(tabs.tabline, "tabline should be created after setup")
    assert(type(tabs.tabline.render) == 'function', "tabline.render should be a function")
    
    -- Test that render returns a string
    local result = tabs.render()
    assert(type(result) == 'string', "render() should return a string")
    assert(#result > 0, "render() should return non-empty string")
    
    print("✓ Basic functionality test passed")
    return true
end

-- Run the test
local success, err = pcall(test_basic_functionality)
if not success then
    print("❌ Basic functionality test failed: " .. tostring(err))
    os.exit(1)
end

print("🎉 All basic functionality tests passed!")
os.exit(0) 