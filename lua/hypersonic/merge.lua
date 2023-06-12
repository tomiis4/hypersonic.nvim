local explain = require('explain').explain
local U = require('utils')
local split_regex = require('split').split_regex
local T = require('tables')
local M = {}

-- TODO: class, groups, clear temp

---@param temp table
---@param type 'Match'|'Match either'|''
---@return table
local function concat_temp(temp, type)
    local res = {}
    local n_loop = type == 'Match' and 1 or #temp

    for i = 1, n_loop do
        -- FIXME
        -- if is type Match, do only temp. Otherwise use splited s
        local keywords = type == 'Match' and temp or U.split(temp[i], '<br>')

        local temp_res = ''
        local temp_kw = ''
        local is_normal = false
        local is_escaped = false

        for _, v in pairs(keywords) do
            if #v == 1 then
                if is_escaped then
                    temp_res = temp_res .. '<br>escaped ' .. temp_kw
                    temp_kw = ''
                end

                is_normal = true
                is_escaped = false
                temp_kw = temp_kw .. v
            elseif U.starts_with(v, 'escaped') then
                if is_normal then
                    print(temp_kw)
                    temp_res = temp_res .. '<br>' .. temp_kw
                    temp_kw = ''
                end

                is_normal = false
                is_escaped = true

                local replaced = v:gsub('escaped ', '')
                temp_kw = temp_kw .. replaced
            else
                if is_escaped then
                    temp_kw = 'escaped ' .. temp_kw
                end

                is_normal = false
                is_escaped = false

                temp_res = temp_res .. '<br>' .. temp_kw .. v
                temp_kw = ''
            end
        end

        if temp_kw ~= '' then
            if is_escaped then
                temp_kw = 'escaped ' .. temp_kw
            end

            temp_res = temp_res .. '<br>' .. temp_kw
        end

        table.insert(res, temp_res:sub(5))
    end

    return res
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
        local is_temp_normal = type(v[1]) ~= 'table'

        if is_temp_normal then
            local is_char_escaped = U.starts_with(v[1], '\\')
            local is_char_normal = U.starts_with(v[2], 'Match ' .. v[1])
            local is_char_quantifier = U.has_value(T.quantifiers, v[1])
            local is_char_chartbl = T.char_table[v[1]] ~= nil

            if temp[3][1] == nil then
                if is_char_escaped then
                    local removed_temp = temp[2]:gsub('Match ', '')

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
                    local removed_temp = temp[2]:gsub('Match ', '')

                    table.insert(temp[3], removed_temp)
                    table.insert(temp[3], '')

                    temp[2] = 'Match either'
                end

                if is_char_quantifier then
                    local removed_t = T.special_table[v[1]]:gsub('Match', 'and')
                    temp[2] = temp[2] .. ' ' .. removed_t
                end

                if is_char_chartbl then
                    local removed_temp = temp[2]:gsub('Match ', '')

                    if removed_temp ~= '' then
                        table.insert(temp[3], removed_temp)
                    end

                    temp[2] = 'Match'
                end
            end

            if temp[3][1] ~= nil or temp[2] == 'Match' then
                local last_elem = temp[3][#temp[3]]

                if temp[2] == 'Match either' then
                    local removed_v = v[2] == 'or' and '' or v[2]:gsub('Match ', '')

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
                    local removed_v = v[2]:gsub('Match ', '')

                    table.insert(temp[3], removed_v)
                end
            end
        end
        temp[1] = temp[1] .. v[1]
    end

    U.print_table(temp[3])
    temp[3] = concat_temp(temp[3], temp[2])

    table.insert(merged, temp)

    U.print_table(merged, 0)
    return merged
end

--[[ local idx = 3 ]]
--[[ local idx = 6 ]]
local idx = 6
local inp = T.test_inputs[idx]
local split_tbl = split_regex(inp)
local expl_tbl = explain(split_tbl, {})

M.merge(expl_tbl, {})
return M
