local Section = require('tabs.section')

describe('Section', function()
    describe('new', function()
        it('should create a new section with default values', function()
            local section = Section:new()
            assert.is_not_nil(section)
            assert.equals('', section.text)
            assert.equals('', section.highlight)
            assert.equals(0, section.position)
            assert.equals('left', section.justify)
            assert.is_not_nil(section.sections)
        end)

        it('should create a new section with custom values', function()
            local section = Section:new({
                text = 'test',
                highlight = 'TestHighlight',
                position = 10,
                justify = 'right'
            })
            assert.equals('test', section.text)
            assert.equals('TestHighlight', section.highlight)
            assert.equals(10, section.position)
            assert.equals('right', section.justify)
        end)
    end)

    describe('get_text', function()
        it('should return string text directly', function()
            local section = Section:new({ text = 'hello world' })
            assert.equals('hello world', section:get_text())
        end)

        it('should call function text and return result', function()
            local section = Section:new({ 
                text = function() return 'function result' end 
            })
            assert.equals('function result', section:get_text())
        end)

        it('should return nil for empty string', function()
            local section = Section:new({ text = '' })
            assert.is_nil(section:get_text())
        end)

        it('should handle function errors gracefully', function()
            local section = Section:new({ 
                text = function() error('test error') end 
            })
            assert.is_nil(section:get_text())
        end)
    end)

    describe('get_sections', function()
        it('should return sections table directly', function()
            local subsections = { Section:new({ text = 'sub1' }) }
            local section = Section:new({ sections = subsections })
            local result = section:get_sections()
            assert.equals(subsections, result)
        end)

        it('should call function sections and return result', function()
            local section = Section:new({ 
                sections = function() 
                    return { Section:new({ text = 'dynamic' }) }
                end 
            })
            local result = section:get_sections()
            assert.is_not_nil(result)
            assert.equals('dynamic', result[1]:get_text())
        end)

        it('should return nil for empty sections', function()
            local section = Section:new({ sections = {} })
            assert.is_nil(section:get_sections())
        end)

        it('should handle function errors gracefully', function()
            local section = Section:new({ 
                sections = function() error('test error') end 
            })
            assert.is_nil(section:get_sections())
        end)
    end)

    describe('builtin sections', function()
        it('should create version section', function()
            local version = Section:version()
            assert.is_not_nil(version)
            assert.equals('TablineVersion', version.highlight)
            local text = version:get_text()
            assert.is_not_nil(text)
            assert.is_true(string.match(text, 'Neovim v%d+%.%d+%.%d+'))
        end)

        it('should create session section', function()
            local session = Section:session()
            assert.is_not_nil(session)
            local subsections = session:get_sections()
            assert.is_not_nil(subsections)
            assert.equals(2, #subsections)
            assert.equals('󰮄 ', subsections[1]:get_text())
            assert.equals('TablineSessionIcon', subsections[1].highlight)
        end)

        it('should create tabs section', function()
            local tabs = Section:tabs()
            assert.is_not_nil(tabs)
            local subsections = tabs:get_sections()
            assert.is_not_nil(subsections)
        end)
    end)
end) 