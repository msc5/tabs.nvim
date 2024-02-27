local M = {}

--- Return default value for arguments provided in function.
---@param value any
---@param default any
function M.default(value, default)
    if value == nil then
        return default
    else
        return value
    end
end

--- Justify `text` with provided options
---@param text string
---@param opts table | nil
---@return string
function M.justify(text, opts)
    opts = M.default(opts, {})
    local width = M.default(opts.width, 80)
    local align = M.default(opts.align, 'center')

    local fill_size = width - #text
    local fill_half = math.floor(fill_size / 2)
    local fill_extra = fill_size % 2

    if fill_size < 0 then error 'Provided text is wider than `width` option!' end

    local fill_left = string.rep(' ', fill_half)
    local fill_right = string.rep(' ', fill_half + fill_extra)

    -- Construct the justified string
    if align == 'center' then
        return string.format('%s%s%s', fill_left, text, fill_right)
    elseif align == 'left' then
        return string.format('%s%s%s', text, fill_left, fill_right)
    elseif align == 'right' then
        return string.format('%s%s%s', fill_left, fill_right, text)
    else
        error '`align` option must be one of `center`, `left`, or `right`.'
    end
end

return M
