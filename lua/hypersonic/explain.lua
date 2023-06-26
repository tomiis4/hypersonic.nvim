local U = require('hypersonic.utils')
local T = require('hypersonic.tables')
local M = {}

local function fix_language()
    -- if you are in cmdline don't cound filetype
    local lang = vim.fn.getcmdpos() ~= 0 and '' or vim.bo.filetype

    if lang == 'lua' then
        U.escaped_char = '%'
        U.meta_table = T.lua_meta_table
    else
        U.escaped_char = '\\'
        U.meta_table = T.php_meta_table
    end
end

---@param char string
---@return string
local function explain_char(char)
    if U.is_escape_char(char) then
        local single_char = char:sub(2, 2)
        local meta_explain = T.meta_table[single_char] or ('Match escaped ' .. char)

        return meta_explain
    else
        local tables_explain = T.special_table[char] or T.char_table[char] or ('Match ' .. char)

        return tables_explain
    end
end

--- class have only normal/escaped characters, ranges, except
---@param tbl table
---@return table
local function explain_class(tbl)
    local class = { { 'class #CLASS', tbl[1] } }

    for idx, v in pairs(tbl) do
        if v ~= '#CLASS' then
            local explained_char = explain_char(v)

            -- class does not have "or" as "|"
            if explained_char == T.special_table['|'] then
                explained_char = 'Match |'
            end

            -- class does not have "^" as "Start of string"
            if explained_char == T.char_table['^'] then
                explained_char = 'Match ^'
            end

            -- class does not have quantifiers
            if U.has_value(T.quantifiers, v) then
                explained_char = 'Match ' .. v
            end

            -- if is "-" last element, it does not mean range
            if idx == #tbl and explained_char == T.special_table['-'] then
                explained_char = 'Match -'
            end

            table.insert(class, { v, explained_char })

            -- add "or"
            local is_not_range = class[#class][2] ~= 'to'
            local is_future_range = tbl[idx + 1] == '-'

            if idx ~= #tbl and is_not_range and not is_future_range then
                table.insert(class, { '', 'or' })
            end
        end
    end

    return class
end

---@param tbl table
---@return table
local function explain_quantifier(tbl)
    local res = { { tbl[1], tbl[1] } }
    local num = ''

    for i = 2, #tbl do
        local v = tbl[i]

        if v == ',' then
            table.insert(res, { '{' .. num, 'Match ' .. num })
            num = ''
        elseif v:match('[0-9]') then
            num = num .. v
        end
    end

    res[#res][2] = res[#res][2] .. ' to ' .. num

    res[#res][1] = res[#res][1] .. ',' .. num .. '}'
    res[#res][2] = res[#res][2] .. (num == '' and 'inf' or '') .. ' times'

    return res
end

---@param tbl table
---@param result_tbl table
---@param is_group boolean
---@return table
function M.explain(tbl, result_tbl, is_group)
    -- add title
    if result_tbl[1] == nil then
        fix_language()
        result_tbl = { tbl[1] }
    end

    -- loop over table without title
    for idx = 2, #tbl do
        local v = tbl[idx]

        -- explain class/group
        if type(v) == 'table' then
            if v[1] == '#CLASS' then
                table.insert(result_tbl, explain_class(v))
            elseif v[1] == '#QUANTIFIER' then
                table.insert(result_tbl, explain_quantifier(v))
            else
                table.insert(result_tbl, M.explain(v, {}, true))
            end
        elseif v ~= '#GROUP' then
            local explained_char = explain_char(v)

            -- only class have "-" as range
            if explained_char == T.special_table['-'] then
                explained_char = 'Match -'
            end

            -- TODO
            -- look-arounds in groups
            -- if (idx == 3 or idx == 4) and is_group then
            --     local prev = tbl[2] .. tbl[3]
            --     local explained_la = T.lookahead[prev] or T.lookahead[prev .. v]
            --
            --     if explained_la then
            --
            --         v = prev
            --         explained_char = explained_la
            --     end
            -- end

            table.insert(result_tbl, { v, explained_char })
        end
    end

    return result_tbl
end

return M
