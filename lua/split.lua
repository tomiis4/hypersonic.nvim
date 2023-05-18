local M = {}
local U = require('hypersonic.utils')

-- testing
local input = 'gr[ae]y'
local input_test = {
    '^hello',
    '(\\/)(.*?)(\\/)',
    '\\d*',
    'gr[ae]y',
    '^[a-zA-Z]+$',
    '^\\S+$'
}

-- @param str string
-- @return table
local split = function(str)
    local main = {}
    local depth = 0
    local escape_char = false

    for i = 1, #str do
        local char = string.sub(str, i, i)

        if (char == '[' or char == '(') and not escape_char then
            local label = char == '[' and '#CLASS' or '#GROUP'

            U.insert(main, depth, {label})
            depth = depth + 1

        elseif (char == ']' or char == ')') and not escape_char then
            depth = depth - 1

        elseif char == '\\' then
            escape_char = true

        elseif escape_char and U.is_meta_char(char) then
            escape_char = false
            U.insert(main, depth, '\\' .. char)

        else
            escape_char = false
            U.insert(main, depth, char)
        end
    end

    return main
end

M.test_split = function()
    for _, v in pairs(input_test) do
        U.print_table(split(v), 0)
    end
end


M.test_split()
U.print_table(split(input), 0)
