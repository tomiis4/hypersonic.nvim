local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

---@param char string
---@return string
local explain_char = function(char)
    if U.is_escape_char(char) then
        local single_char = string.sub(char, 2, 2)
        local meta_explain = T.meta_table[single_char] or ('Match escaped ' .. char)

        return meta_explain
    else
        local tables_explain = T.special_table[char] or T.char_table[char] or ('Match ' .. char)

        return tables_explain
    end
end


---@param tbl table
---@return table
local explain_class = function(tbl)
    local class = { { 'class #CLASS', tbl[1] } }

    for idx, v in pairs(tbl) do
        if v ~= '#CLASS' then
            local explained = explain_char(v)

            -- class does not have "or" as "|"
            if explained == T.special_table['|'] then
                explained = 'Match |'
            end

            -- class does not have "^" as "Start of string"
            if explained == T.char_table['^'] then
                local expl = idx == 1 and 'Match except' or 'Match ^'
                explained = expl
            end

            table.insert(class, { v, explained })

            -- add "or"
            local not_range = tbl[idx + 1] ~= '-' and tbl[idx] ~= '-'
            if idx ~= #tbl and not_range then
                table.insert(class, { '', 'or' })
            end
        end
    end

    return class
end

---@param tbl table
---@param result_tbl table
---@return table
M.explain = function(tbl, result_tbl)
    for _, v in pairs(tbl) do
        if type(v) == 'table' then
            -- if is table, check if is it class -> explain class, group -> explain normal
            if v[1] == '#CLASS' then
                table.insert(result_tbl, explain_class(v))
            else
                table.insert(result_tbl, M.explain(v, {}))
            end
        elseif v ~= '#CLASS' and v ~= '#GROUP' then
            table.insert(result_tbl, { v, explain_char(v) })
        end
    end

    return result_tbl
end

-- TESTING
-- for _, v in pairs(T.test_inputs) do
--     local test_tbl = S.split(v)
--     local result = M.explain(test_tbl, { { 'Regex', v } })
--     U.print_table(result, 0)
-- end


return M
