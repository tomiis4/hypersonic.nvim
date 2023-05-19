-- FIXME: make some format, that will know if is it inside group/class

local U = require('hypersonic.utils')
local S = require('hypersonic.split')
local M = {}

---@param char string
---@return string
M.explain_char = function(char)
    -- TODO: make it more readable
    if U.is_escape_char(char) then
        local single_char = string.sub(char, 2, 2)
        local meta_explain =
            U.meta_table[single_char] == nil
            and 'Match escaped ' .. char
            or U.meta_table[single_char]
        return meta_explain

    elseif U.char_table[char] ~= nil then
        return U.char_table[char]
    elseif U.special_table[char] ~= nil then
        return U.special_table[char]
    else
        return "Match "..char
    end
end


---@param tbl table
---@param result_tbl table
---@return table
M.explain_class = function(tbl, result_tbl)
    for idx, v in pairs(tbl) do
        if v ~= '#CLASS' then
            local explained = M.explain_char(v)

            -- class does not have "or" as "|"
            if explained == U.special_table['|'] then
                explained = 'Match |'
            end

            table.insert(result_tbl, { v, explained })

            -- add "or"
            -- FIXME: fix when there is 'to'
            if idx ~= #tbl then
                table.insert(result_tbl, { 'OR' })
            end
        end
    end

    return result_tbl
end

---@param tbl table
---@param result_tbl table
---@return table
M.explain = function(tbl, result_tbl)
    for _, v in pairs(tbl) do
        if type(v) == 'table' then
            if v[1] == '#CLASS' then
                table.insert(result_tbl, { 'Expain class ' .. v[1], v[1] })
                result_tbl = M.explain_class(v, result_tbl)
            else
                M.explain(v, result_tbl)
            end
        elseif v ~= '#CLASS' and v ~= '#GROUP' then
            table.insert(result_tbl, { v, M.explain_char(v) })
        end
    end

    return result_tbl
end

local test_idx = 3
local test_tbl = S.split(U.input_test[test_idx])
local result = M.explain(test_tbl, { { 'Regex', U.input_test[test_idx] } })
U.print_table(result, 0)
