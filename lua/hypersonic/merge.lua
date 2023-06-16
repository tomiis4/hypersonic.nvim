local explain = require('explain').explain
local U = require('utils')
local split_regex = require('split').split_regex
local T = require('tables')
local M = {}

-- TODO: class, groups, clear temp

---@alias regex_type 'Match'|'Match either'|''

---@class temp
---@field[1] string regex name
---@field[2] regex_type regex explanation
---@field[3] table further regex explanation


---@param temp table
---@param type regex_type
---@return table
local function concat_temp(temp, type)
    local res = {}
    local n_loop = type == 'Match' and 1 or #temp

    for i = 1, n_loop do
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

--- FIXME: in explain, class does not have any quantifiers
--- FIXME, just run the code, you will see
---@param tbl table
---@return table
local function merge_class(tbl)
    ---@class temp
    local temp = { '', '', {} }

    local res = {}

    for idx = 2, #tbl do
        local v = tbl[idx]

        local is_char_escaped = U.starts_with(v[1], '\\')
        local is_char_normal = U.starts_with(v[2], 'Match ' .. v[1])

        if #temp[3] == 0 then
            if is_char_escaped then
                local removed_temp = temp[2]:gsub('Match ', '')

                if removed_temp ~= '' then
                    table.insert(temp[3], removed_temp)
                end

                temp[2] = 'Match'
            end

            if is_char_normal then
                temp[2] = temp[2] .. (temp[2] == '' and v[2] or v[1])
            end

            if v[2] == 'to' then
                temp[2] = temp[2] .. ' to '
            end

            if v[2] == 'or' then
                local removed_temp = temp[2]:gsub('Match ', '')

                table.insert(temp[3], removed_temp)
                table.insert(temp[3], '')

                temp[2] = 'Match either'
                U.print_table(temp[3])
            end
        end

        if #temp[3] > 0 or temp[2] == 'Match' then
            local last_elem = temp[3][#temp[3]]

            if temp[2] == 'Match either' then
                local removed_v = v[2] == 'or' and '' or v[2]:gsub('Match ', '')
                local add_br = U.ends_with(last_elem, ' to ') and '' or '<br>'

                temp[3][#temp[3]] = last_elem == '' and removed_v or last_elem .. add_br .. removed_v
            end

            if v[2] == 'to' then
                temp[3][#temp[3]] = last_elem .. ' to '
            end

            if v[2] == 'or' then
                temp[2] = 'Match either'
                temp[3] = { table.concat(temp[3], '') }
                table.insert(temp[3], '')
            end

            if temp[2] == 'Match' then
                local removed_v = v[2]:gsub('Match ', '')

                table.insert(temp[3], removed_v)
            end
        end

        temp[1] = temp[1] .. (type(v[1]) == 'table' and '' or v[1])
    end

    U.print_table(temp)

    return res
end

---@param tbl table
---@param merged table
---@return table
M.merge = function(tbl, merged)
    ---@class temp
    local temp = { '', '', {} }

    -- add title
    merged = { tbl[1] }

    for idx = 2, #tbl do
        local v = tbl[idx]
        local is_v_normal = type(v[2]) ~= 'table'

        if is_v_normal then
            local is_char_escaped = U.starts_with(v[1], '\\')
            local is_char_normal = U.starts_with(v[2], 'Match ' .. v[1])
            local is_char_quantifier = U.has_value(T.quantifiers, v[1])
            local is_char_chartbl = T.char_table[v[1]] ~= nil

            if #temp[3] == 0 then
                if is_char_escaped then
                    local removed_temp = temp[2]:gsub('Match ', '')

                    if removed_temp ~= '' then
                        table.insert(temp[3], removed_temp)
                    end

                    temp[2] = 'Match'
                end

                if is_char_normal then
                    temp[2] = temp[2] .. (temp[2] == '' and v[2] or v[1])
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

            if #temp[3] > 0 or temp[2] == 'Match' then
                local last_elem = temp[3][#temp[3]]

                if temp[2] == 'Match either' then
                    local removed_v = v[2] == 'or' and '' or v[2]:gsub('Match ', '')

                    temp[3][#temp[3]] = last_elem == '' and removed_v or last_elem .. '<br>' .. removed_v
                end

                if v[2] == 'or' then
                    temp[2] = 'Match either'
                    temp[3] = { table.concat(temp[3], '<br>') }
                    table.insert(temp[3], '')
                end

                if temp[2] == 'Match' then
                    local removed_v = v[2]:gsub('Match ', '')

                    table.insert(temp[3], removed_v)
                end
            end
        else
            -- v is not normal (it's either group or class)
            if v[1][2] == '#CLASS' then
                merge_class(v)
            end
        end
        temp[1] = temp[1] .. (type(v[1]) == 'table' and '' or v[1])
    end

    temp[3] = concat_temp(temp[3], temp[2])

    table.insert(merged, temp)

    -- U.print_table(merged, 0)
    return merged
end

local idx = 4
local inp = '[a+-zfuck]' or T.test_inputs[idx]
local split_tbl = split_regex(inp)
local expl_tbl = explain(split_tbl, {})

M.merge(expl_tbl, {})
return M
