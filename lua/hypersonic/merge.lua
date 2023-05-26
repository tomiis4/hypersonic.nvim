local E = require('explain')
local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

---@param str string
---@param expr string
---@return string
local function insert_exlp(str, expr)
    if str == '' then
        return 'Match "' .. expr .. '"'
    else
        -- if is last element match
        if string.sub(str, #str, #str) == '"' then
            return string.sub(str, 1, #str - 1) .. expr .. '"'
        else
            return ''
        end
    end
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
            -- TODO
            if temp[1] ~= '' then
                table.insert(merged, temp)
                temp = { '', '' }
            end
        elseif v[1][2] ~= nil then
            -- TODO
            if temp[1] ~= '' then
                table.insert(merged, temp)
                temp = { '', '' }
            end
        elseif U.starts_with(v[2], 'Match') then
            temp[1] = temp[1] .. v[1]
            temp[2] = insert_exlp(temp[2], v[1])
        elseif T.special_table[v[1]] ~= nil then
            -- TODO
            print('Special')
        else
            if temp[1] ~= '' then
                table.insert(merged, temp)
                temp = { '', '' }
            end

            table.insert(merged, v)
        end
    end

    if temp[1] ~= '' then
        table.insert(merged, temp)
        temp = { '', '' }
    end

    U.print_table(merged, 0)
end

local idx = 8
local split_tbl = S.split(T.test_inputs[idx])
local expl_tbl = E.explain(split_tbl, {})

M.merge(expl_tbl, {}, 0)
-- U.print_table(M.merge(expl_tbl, {}, 0), 0)


return M
