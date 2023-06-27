local S = {}
local U = require('hypersonic.utils')
local T = require('hypersonic.tables')

local function fix_language(s)
    local lang = vim.bo.filetype

    if lang == 'lua' then
        U.escaped_char = '%'
    else
        U.escaped_char = '\\'
    end

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
        -- lua can't have 2 escaped char. next to each other
        local escaped_char = U.escaped_char == '%' and '' or U.escaped_char

        str = str:gsub(escaped_char .. v, '')
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

---@param type string
---@param value string|table
---@param children table?
---@return table
local function get_node(type, value, children)
    return {
        type = type,
        value = value,
        children = children or {}
    }
end

---@param s string
---@param type '('|'{'|'['
---@param idx number
---@return number
local function get_closing(s, type, idx)
    local n = 0
    local is_escaped = false
    local opposite = {
        ['('] = ')',
        ['['] = ']',
        ['{'] = '}',
    }

    for i = idx, #s do
        local char = s:sub(i, i)

        if char == type and not is_escaped then
            n = n + 1
        elseif char == opposite[type] and not is_escaped then
            n = n - 1

            if n == 0 then
                return i
            end
        elseif char == U.escaped_char then
            is_escaped = true
        else
            is_escaped = false
        end
    end

    return -1
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

    local main = {}
    local esc = U.escaped_char .. U.escaped_char

    local i = 1
    while i <= #str do
        local char = str:sub(i, i)

        if char == U.escaped_char then
            local esc_char = str:sub(i + 1, i + 1)
            local node = get_node('escaped', esc_char)

            i = i + 1
            table.insert(main, node)
        elseif char == '[' then
            local close_idx = str:find('[^' .. esc .. ']%]', i) + 1
            local class_value = str:sub(i, close_idx)
            local node = get_node('group', class_value)

            i = close_idx
            table.insert(main, node)
        elseif char == '(' then
            local close_idx = get_closing(str, '(', i)
            local group_value = str:sub(i + 1, close_idx - 1)
            local node = get_node('group', '', S.split_regex(group_value))

            i = close_idx
            table.insert(main, node)
        elseif char == '{' and str:find('%d+,%d*}',i) then
            local close_idx = get_closing(str, '{', i)
            local quantifier_value = str:sub(i + 1, close_idx - 1)
            local min, max = quantifier_value:match("(%d+),(%d*)")
            local node = get_node('quantifier', {
                    min = min,
                    max = max == '' and 'inf' or max
                })

            i = close_idx
            table.insert(main, node)
        elseif U.has_value(T.quantifiers, char) then
            local prev_node = main[#main]
            prev_node.value = prev_node.value .. char
        else
            local node = get_node('character', char)
            table.insert(main, node)
        end

        i = i + 1
    end

    return main, error[2]
end

return S
