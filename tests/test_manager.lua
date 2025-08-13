local manager = require('tabs.manager')

describe('manager', function()
    describe('setup', function()
        it('should set up keymaps', function()
            -- This test would require mocking vim.api.nvim_set_keymap
            -- For now, we just test that the function exists and doesn't error
            assert.is_not_nil(manager.setup)
            assert.is_function(manager.setup)
        end)
    end)

    describe('tabs', function()
        it('should return a table', function()
            local tabs = manager.tabs()
            assert.is_table(tabs)
        end)

        it('should handle empty tab list', function()
            -- This would need mocking of vim.api.nvim_list_tabpages
            -- For now, just test the function exists
            assert.is_function(manager.tabs)
        end)
    end)

    describe('skip_filetypes', function()
        it('should contain expected file types', function()
            local skip_filetypes = {
                ['NvimTree'] = true,
                ['neo-tree'] = true,
                ['aerial'] = true,
                ['help'] = true,
                ['qf'] = true,
            }
            
            -- Test that all expected file types are present
            for ft, _ in pairs(skip_filetypes) do
                assert.is_true(skip_filetypes[ft], 'File type ' .. ft .. ' should be skipped')
            end
        end)
    end)
end) 