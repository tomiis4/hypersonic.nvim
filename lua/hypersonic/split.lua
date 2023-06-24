local S = {}
local U = require('hypersonic.utils')

local function fix_language(s)
    local lang = vim.bo.filetype

    if lang == 'python' then
        if U.starts_with(s, 'r"') or U.starts_with(s, 'r\'') then
            s = s:sub(2)
        end
    end

    return s
end

---@param str string
---@return table<boolean, string?>
local function is_error(str)
    -- replace all escaped () or []
    for _, v in pairs({ '%[', '%]', '%(', '%)' }) do
        str = str:gsub(U.escaped_char .. v, '')
    end

    -- if ther isn't any content inside [], ()
    if U.find(str, '%[%]') >= 1 or U.find(str, '%(%)') >= 1 then
        return { true, 'Error: Empty Parentheses/Brackets' }
    end

    -- delete all characters except (,),[,]
    str = str:gsub('[^%(%)%[%]]', '')

    if U.find(str, '%(') ~= U.find(str, '%)') then
        return { true, 'Missing closing or opening square bracket' }
    end

    if U.find(str, '%[') ~= U.find(str, '%]') then
        return { true, 'Missing closing or opening parenthesis' }
    end

    return { false }
end

---split regex to specific table
---@param str string
---@return table, string
function S.split_regex(str)
    str = fix_language(str)
    local error = is_error(str)
    if error[1] then
        str = ''
    end

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
            if char == ']' then
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

    return main, error[2]
end

return S
