-- Simple test runner for tabs.nvim
-- Run with: nvim --headless -c "lua dofile('tests/simple_test.lua')"

-- Add the lua directory to package.path for require statements
package.path = package.path .. ';lua/?.lua;lua/?/init.lua'

local function run_tests()
    local tests = {}
    local passed = 0
    local failed = 0
    
    -- Simple assertion function
    local function assert(condition, message)
        if not condition then
            error(message or "Assertion failed")
        end
    end
    
    local function assert_equals(expected, actual, message)
        if expected ~= actual then
            error(string.format("%s: expected %s, got %s", 
                message or "Assertion failed", 
                tostring(expected), 
                tostring(actual)))
        end
    end
    
    local function assert_not_nil(value, message)
        if value == nil then
            error(message or "Expected non-nil value")
        end
    end
    
    local function assert_is_function(value, message)
        if type(value) ~= 'function' then
            error(message or "Expected function")
        end
    end
    
    local function assert_is_table(value, message)
        if type(value) ~= 'table' then
            error(message or "Expected table")
        end
    end
    
    -- Test str module
    print("Testing str module...")
    local str = require('tabs.str')
    
    -- Test default function
    assert_equals('default', str.default(nil, 'default'), "str.default should return default for nil")
    assert_equals('custom', str.default('custom', 'default'), "str.default should return value when not nil")
    
    -- Test justify function
    assert_equals('  hello   ', str.justify('hello', { width = 10 }), "str.justify should center by default")
    assert_equals('hello     ', str.justify('hello', { width = 10, align = 'left' }), "str.justify should left align")
    assert_equals('     hello', str.justify('hello', { width = 10, align = 'right' }), "str.justify should right align")
    
    print("✓ str module tests passed")
    passed = passed + 1
    
    -- Test Section module
    print("Testing Section module...")
    local Section = require('tabs.section')
    
    -- Test new section creation
    local section = Section:new()
    assert_not_nil(section, "Section:new() should return a section")
    assert_equals('', section.text, "Default text should be empty string")
    assert_equals(0, section.position, "Default position should be 0")
    
    -- Test custom section creation
    local custom_section = Section:new({ text = 'test', position = 10 })
    assert_equals('test', custom_section.text, "Custom text should be set")
    assert_equals(10, custom_section.position, "Custom position should be set")
    
    -- Test get_text with string
    assert_equals('hello', Section:new({ text = 'hello' }):get_text(), "get_text should return string text")
    
    -- Test get_text with function
    local func_section = Section:new({ text = function() return 'function result' end })
    assert_equals('function result', func_section:get_text(), "get_text should call function and return result")
    
    -- Test builtin sections
    local version = Section:version()
    assert_not_nil(version, "Section:version() should return a section")
    assert_equals('TablineVersion', version.highlight, "Version section should have correct highlight")
    
    local session = Section:session()
    assert_not_nil(session, "Section:session() should return a section")
    
    local tabs = Section:tabs()
    assert_not_nil(tabs, "Section:tabs() should return a section")
    
    print("✓ Section module tests passed")
    passed = passed + 1
    
    -- Test manager module
    print("Testing manager module...")
    local manager = require('tabs.manager')
    
    assert_is_function(manager.setup, "manager.setup should be a function")
    assert_is_function(manager.tabs, "manager.tabs should be a function")
    
    local tabs_list = manager.tabs()
    assert_is_table(tabs_list, "manager.tabs() should return a table")
    
    print("✓ manager module tests passed")
    passed = passed + 1
    
    -- Test colors module
    print("Testing colors module...")
    local colors = require('tabs.colors')
    
    assert_is_function(colors.setup, "colors.setup should be a function")
    assert_is_table(colors.fg, "colors.fg should be a table")
    assert_is_table(colors.bg, "colors.bg should be a table")
    
    print("✓ colors module tests passed")
    passed = passed + 1
    
    -- Test main module
    print("Testing main module...")
    local tabs_main = require('tabs')
    
    assert_is_function(tabs_main.setup, "tabs.setup should be a function")
    assert_is_function(tabs_main.render, "tabs.render should be a function")
    
    print("✓ main module tests passed")
    passed = passed + 1
    
    print(string.format("\n🎉 All tests passed! (%d/%d)", passed, passed))
    return true
end

-- Run tests
local success, err = pcall(run_tests)
if not success then
    print("❌ Test failed: " .. tostring(err))
    os.exit(1)
end

os.exit(0) 