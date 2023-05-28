--[[

FIXME
    -> insert_exlp, if it ends with or still insert, everytime

SOLUTION
    - loop trough `input` without `idx=1` (title) and add it to `merged`
    - each input is `v`, (1 = key, 2 = explanation)
    - make `temp` table, (1 = key, 2 = value, 3 = second data)

    - if `temp2` is normal (starts with `Match` and ends with `"`) and `temp3` is nil
        - if `v2` is escaped (starts with `Match escaped`)
            - from `temp2` remove from end of the match to end, e.g. `Match "x"` -> `"x"`
                - put it to `temp3`, and push to `temp3` `v2`
        - if `v2` is normal (starts with `Match "`)
            - add `v1` to idx1, from `temp2` remove last (") and add `v1 + "`
        - if `v2` is `or`
            - from `temp2` replace `Match` with `Match either`,
            - from `temp2` remove from end of the match to end, e.g. `Match "x"` -> `"x"`
                - put it to `temp3`, and push to `temp3` `v2`

    -> ab|x
        => ab|x Match either
            => 1) "ab"
            => 2) "x"

        {
            "ab|x"
            "Match either",
            {
                "ab",
                "x"
            }
        }

        +--------------------------+
        | "ab|x"                   |
        |    Match either          |
        |       1) "ab"            |
        |       2) "x"             |
        +--------------------------+

-- ]]

local E = require('explain')
local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

---@param temp2 string
---@param v1 string
---@return string
local function insert_exlp(temp2, v1)
    if temp2 == '' then
        return 'Match "' .. v1 .. '"'
    else
        -- if is last element "
        if U.ends_with(temp2, '"') then
            return string.sub(temp2, 1, #temp2 - 1) .. v1 .. '"'
        else
            return ''
        end
    end
end

---@param merged table
---@param temp table
---@return table
local function clear(merged, temp)
    if temp[1] ~= '' then
        table.insert(merged, temp)
    end

    return merged
end

---@param merged table
---@param temp table
---@param v table
---@return table
---@return table
local function merge_special(merged, temp, v)
    if v[2] == T.special_table['|'] then
        temp[1] = temp[1] .. '|'
        temp[2] = 'Match either' .. string.sub(temp[2], #'Match ', #temp[2]) .. ' or '
    end

    return merged, temp
end

---@param tbl table
---@param merged table
---@param depth integer
--- -@return table
M.merge = function(tbl, merged, depth)
    local temp = { '', '' }

    -- add title
    merged = { tbl[1] }

    for idx = 2, #tbl do
        local v = tbl[idx]


        if v[1][2] == "#CLASS" then
            -- classes
            print('Class')
            merged = clear(merged, temp)
            temp = { '', '' }
        elseif v[1][2] ~= nil then
            -- groups
            print('Group')
            merged = clear(merged, temp)
            temp = { '', '' }
        elseif U.starts_with(v[2], 'Match') then
            temp[1] = temp[1] .. v[1]
            temp[2] = insert_exlp(temp[2], v[1])
        elseif T.special_table[v[1]] ~= nil then -- maybe add `or v[1] == ''`
            -- special characters, ?+*|
            merged, temp = merge_special(merged, temp, v)
        else
            -- characters like Escaped chars., sol/eol
            print('Others')
            merged = clear(merged, temp)
            temp = { '', '' }

            table.insert(merged, v)
        end
    end

    merged = clear(merged, temp)
    temp = { '', '' }

    U.print_table(merged, 0)
end

local idx = 8
local split_tbl = S.split(T.test_inputs[idx])
local expl_tbl = E.explain(split_tbl, {})

M.merge(expl_tbl, {}, 0)
-- U.print_table(M.merge(expl_tbl, {}, 0), 0)


return M