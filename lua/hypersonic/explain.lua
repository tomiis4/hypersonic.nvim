local U = require('utils')
local T = require('tables')
local M = {}

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
                local expl = idx == 1 and 'Match except' or 'Match ^'
                explained_char = expl
            end

            -- if is "-" last element, it does not mean range
            if idx == #tbl and explained_char == T.special_table['-'] then
                explained_char = 'Match -'
            end

            table.insert(class, { v, explained_char })

            -- add "or"
            local is_not_range = class[#class][2] ~= 'to'
            local is_future_range = tbl[idx+1] == '-'

            if idx ~= #tbl and is_not_range and not is_future_range then
                table.insert(class, { '', 'or' })
            end
        end
    end

    return class
end

---@param tbl table
---@param result_tbl table
---@return table
function M.explain(tbl, result_tbl)
    -- add title
    if result_tbl[1] == nil then
        result_tbl = { tbl[1] }
    end

    -- loop over table without title
    for idx = 2, #tbl do
        local v = tbl[idx]

        if type(v) == 'table' then
            -- check if is it class -> explain class, group -> explain normal
            if v[1] == '#CLASS' then
                table.insert(result_tbl, explain_class(v))
            else
                table.insert(result_tbl, M.explain(v, {}))
            end
        elseif v ~= '#CLASS' and v ~= '#GROUP' then
            local explained_char = explain_char(v)

            -- only class have "-" as range
            if explained_char == T.special_table['-'] then
                explained_char = "Match -"
            end
            table.insert(result_tbl, { v, explained_char })
        end
    end

    return result_tbl
end

return M
