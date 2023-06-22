local S = {}
local U = require('hypersonic.utils')

---split regex to specific table
---@param str string
---@return table
function S.split_regex(str)
    local main = { { '', str } }
    local depth = 0
    local escape_char = false
    local is_class = false

    local str_len = #str

    for i = 1, str_len do
        local char = str:sub(i, i)

        -- get groups
        if (char == '[' or char == '(') and not escape_char then
            local label = char == '[' and '#CLASS' or '#GROUP'

            if char == '[' then
                is_class = true
            end

            if char == '(' and is_class then
                U.insert(main, depth, char)
            else
                U.insert(main, depth, { label })
                depth = depth + 1
            end


            -- end groups
        elseif (char == ']' or char == ')') and not escape_char then
            if char == '[' then
                is_class = false
            end

            if is_class and char == ')' then
                U.insert(main, depth, char)
                depth = depth + 1
            end

            depth = depth - 1

            -- get escape
        elseif char == U.escaped_char then
            escape_char = true

            -- add escape
        elseif escape_char then
            escape_char = false
            U.insert(main, depth, U.escaped_char .. char)

            -- get normal chars
        else
            escape_char = false
            U.insert(main, depth, char)
        end
    end

    return main
end

return S
