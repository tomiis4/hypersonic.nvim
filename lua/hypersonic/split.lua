local S = {}
local U = require('utils')

---split regex to specific table
---@param str string
---@return table
function S.split_regex(str)
    local main = {{'Regex', str}}
    local depth = 0
    local escape_char = false

    local str_len = #str

    for i = 1, str_len do
        local char = str:sub(i, i)

        -- get groups
        if (char == '[' or char == '(') and not escape_char then
            local label = char == '[' and '#CLASS' or '#GROUP'

            U.insert(main, depth, { label })
            depth = depth + 1

        -- end groups
        elseif (char == ']' or char == ')') and not escape_char then
            depth = depth - 1

        -- get escape
        elseif char == '\\' then
            escape_char = true

        -- add escape
        elseif escape_char then
            escape_char = false
            U.insert(main, depth, '\\' .. char)

        -- get normal chars
        else
            escape_char = false
            U.insert(main, depth, char)
        end
    end

    return main
end

return S
