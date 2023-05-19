local U = {}

U.input_test = {
    '^hello',
    '(\\/)(.*)(\\/)',
    '\\d*',
    'gr[ae]y',
    '^[a-zA-Z|]+$',
    '^\\S+$'
}

U.char_table = {
    ['^'] = 'Start of strig',
    ['$'] = 'End of strig',
    ['.'] = 'Every single character',
}

U.special_table = {
    ['|'] = 'or',
    ['-'] = 'to',
    ['?'] = 'Matches 0 or 1 times',
    ['*'] = 'Matches 0 or more times',
    ['+'] = 'Matches 1 or more'
}

U.meta_table = {
    ['n'] = 'Newline',
    ['r'] = 'Carriage return',
    ['t'] = 'Tab',
    ['s'] = 'Any whitespace character',
    ['S'] = 'Any non-whitespace character',
    ['d'] = 'Any digit',
    ['D'] = 'Any non-digit',
    ['w'] = 'Any word character',
    ['W'] = 'Any non-word character',
    ['b'] = 'A word boundary',
    ['B'] = 'Non-word boundary',
    ['0'] = 'Null character',
    ['X'] = 'Any Unicode sequences, linebreaks included',
    ['C'] = 'Match one data unit',
    ['R'] = 'Unicode newlines',
    ['N'] = 'Match anything but a newline',
    ['v'] = 'Vertical whitespace character',
    ['h'] = 'Horizontal whitespace character',
    ['G'] = 'Start of match',
    ['A'] = 'Start of string',
    ['Z'] = 'End of string',
    ['z'] = 'Absolute end of string'
}

---@param tbl table
---@param n number
---@return nil
U.print_table = function(tbl, n)
    n = n or 0

    print(string.rep('   ', n) .. '{')

    for i, v in pairs(tbl) do
        if type(v) == 'table' then
            U.print_table(v, n + 1)
        else
            print(string.rep('  ', n + 1) .. string.format('[%q]: %q,', i, v))
        end
    end
    print(string.rep('   ', n) .. '},')
end

---@param tbl table
---@param ctx table|string
---@param depth number
---@return table
U.insert = function(tbl, depth, ctx)
    local last_item = tbl

    for _ = 1, depth do
        if type(last_item[#last_item]) == 'table' then
            last_item = last_item[#last_item]
        else
            last_item[#last_item + 1] = {}
            last_item = last_item[#last_item]
        end
    end

    table.insert(last_item, ctx)
    return tbl
end

---@param char string
---@return boolean
U.is_meta_char = function(char)
    if U.meta_table[char] ~= nil then
        return true
    end

    return false
end

---@param char string
---@return boolean
U.is_escape_char = function(char)
    return string.sub(char, 1,1) == '\\'
end

return U
