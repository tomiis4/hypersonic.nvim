local E = require('explain')
local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

-- TODO: class, groups, clear temp
-- TODO: optimize fix_temp and do it same for escaped

---@param temp table
---@return table
local function fix_temp(temp)
    local t = {}

    for idx, v in pairs(temp) do
        local s = U.split(v, '<br>')


        for _, v1 in pairs(s) do
            local split_t, t_n = U.split(t[idx], '<br>')

            local _, n_t = string.gsub(split_t[t_n] or '', ' ', ' ')
            local _, n_v = string.gsub(v1 or '', ' ', ' ')


            if n_t < 2 and n_v < 2 then
                t[idx] = (t[idx] or '') .. v1
            else
                t[idx] = (t[idx] or '') .. '<br>' .. v1
            end
        end

        -- fix <br> at start
        if U.starts_with(t[idx], '<br>') then
            t[idx] = string.sub(t[idx], 5)
        end
    end

    return t
end

---@param tbl table
---@param merged table
---@return table
M.merge = function(tbl, merged)
    local temp = { '', '', {} }

    -- add title
    merged = { tbl[1] }

    for idx = 2, #tbl do
        local v = tbl[idx]
        local is_temp_normal = type(v[1]) ~= "table"

        if is_temp_normal then
            local is_char_escaped = U.starts_with(v[1], '\\')
            local is_char_normal = U.starts_with(v[2], 'Match ' .. v[1])
            local is_char_quantifier = U.has_value(T.quantifiers, v[1])
            local is_char_chartbl = T.char_table[v[1]] ~= nil

            if temp[3][1] == nil then
                if is_char_escaped then
                    local removed_temp = string.gsub(temp[2], 'Match ', '')

                    if removed_temp ~= '' then
                        table.insert(temp[3], removed_temp)
                    end

                    temp[2] = 'Match'
                end

                if is_char_normal then
                    if temp[2] == '' then
                        temp[2] = temp[2] .. v[2]
                    else
                        temp[2] = temp[2] .. v[1]
                    end
                end

                if v[2] == 'or' then
                    local removed_temp = string.gsub(temp[2], 'Match ', '')

                    table.insert(temp[3], removed_temp)
                    table.insert(temp[3], '')

                    temp[2] = 'Match either'
                end

                if is_char_quantifier then
                    local removed_t = string.gsub(T.special_table[v[1]], 'Match', 'and')
                    temp[2] = temp[2] .. ' ' .. removed_t
                end

                if is_char_chartbl then
                    local removed_temp = string.gsub(temp[2], 'Match ', '')

                    if removed_temp ~= '' then
                        table.insert(temp[3], removed_temp)
                    end

                    temp[2] = 'Match'
                end
            end

            if temp[3][1] ~= nil or temp[2] == 'Match' then
                local last_elem = temp[3][#temp[3]]

                if temp[2] == 'Match either' then
                    local removed_v = v[2] == 'or' and '' or string.gsub(v[2], 'Match ', '')

                    if last_elem == '' then
                        temp[3][#temp[3]] = removed_v
                    else
                        temp[3][#temp[3]] = last_elem .. '<br>' .. removed_v
                    end
                elseif v[2] == 'or' then
                    temp[2] = 'Match either'
                    temp[3] = { table.concat(temp[3], '<br>') }
                    table.insert(temp[3], '')
                elseif temp[2] == 'Match' then
                    local removed_v = string.gsub(v[2], 'Match ', '')

                    table.insert(temp[3], removed_v)
                end
            end
        end
        temp[1] = temp[1] .. v[1]
    end

    temp[3] = fix_temp(temp[3])

    table.insert(merged, temp)

    U.print_table(merged, 0)
    return merged
end

--[[ local idx = 3 ]]
--[[ local idx = 6 ]]
local idx = 1
local inp = '^xy|f\\Sckyou' or T.test_inputs[idx]
local split_tbl = S.split(inp)
local expl_tbl = E.explain(split_tbl, {})

M.merge(expl_tbl, {})
return M
