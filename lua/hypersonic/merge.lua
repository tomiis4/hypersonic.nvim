--[[

For future developers:

I'm very sorry.
Good luck.
    - tomiis

]]
local T = require('hypersonic.tables')
local U = require('hypersonic.utils')
local M = {}

---@alias regex_type 'Match'|'Match either'|'Match neither'|''

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
                    temp_res = temp_res .. '<br>escaped ' .. temp_kw:sub(1)
                    temp_kw = ''
                end

                is_normal = true
                is_escaped = false
                temp_kw = temp_kw .. v
            elseif U.starts_with(v, 'escaped') then
                if is_normal then
                    temp_res = temp_res .. '<br>' .. temp_kw:sub(1)
                    temp_kw = ''
                end

                is_normal = false
                is_escaped = true

                local replaced = v:sub(#('escaped ' .. U.escaped_char))
                temp_kw = temp_kw .. replaced
            else
                if is_escaped then
                    temp_kw = 'escaped ' .. temp_kw:sub(1)
                end

                is_normal = false
                is_escaped = false

                temp_res = temp_res .. '<br>' .. temp_kw .. v
                temp_kw = ''
            end
        end

        if temp_kw ~= '' then
            if is_escaped then
                temp_kw = 'escaped ' .. temp_kw:sub(1)
            end

            temp_res = temp_res .. '<br>' .. temp_kw
        end

        table.insert(res, temp_res:sub(5))
    end

    return res
end

---@param tbl table
---@return table
local function concat_temp_class(tbl)
    local res = {}
    local temp = ''

    for _, v1 in pairs(tbl) do
        local v = U.ends_with(v1, '<br>') and v1:sub(0, -5) or v1

        if #v == 1 and v:match('[a-zA-Z0-9]') then
            temp = temp .. (temp:find(v) and '' or v)
        else
            if temp ~= '' then
                table.insert(res, 'one character from ' .. temp)
                temp = ''
            end
            table.insert(res, v)
        end
    end

    if temp ~= '' then
        table.insert(res, 'one character from ' .. temp)
    end

    for idx, v in pairs(res) do
        if v == 'to' and U.ends_with(res[idx - 1], ' to ') then
            res[idx - 1] = res[idx - 1]:gsub('to', '')
        end
    end

    return res
end

---@param tbl table
---@return table
local function merge_class(tbl)
    ---@class temp
    local temp = { '', '', {} }

    for idx = 2, #tbl do
        local v = tbl[idx]

        local is_char_escaped = U.is_escape_char(v[1])
        local is_char_normal = U.starts_with(v[2], 'Match ' .. v[1]) and v[1] ~= '^'

        if #temp[3] == 0 then
            if is_char_escaped then
                local removed_temp = temp[2]:gsub('Match ', '')

                if removed_temp ~= '' then
                    table.insert(temp[3], removed_temp:gsub(U.escaped_char, '', 1)[1])
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

                if temp[2] ~= 'Match neither' and idx ~= 2 then
                    table.insert(temp[3], removed_temp)
                    table.insert(temp[3], '')
                else
                    table.insert(temp[3], '')
                end

                temp[2] = temp[2] == 'Match neither' and temp[2] or 'Match either'
            end

            if v[1] == '^' and idx == 2 then
                temp[2] = 'Match neither'
            end
        end

        if #temp[3] > 0 or temp[2] == 'Match' then
            local last_elem = temp[3][#temp[3]]

            if temp[2] == 'Match either' or temp[2] == 'Match neither' then
                local removed_v = v[2] == 'or' and '' or v[2]:gsub('Match ', '')
                local add_br = U.ends_with(last_elem, ' to ') and '' or '<br>'

                temp[3][#temp[3]] = last_elem == '' and removed_v or (last_elem .. add_br .. removed_v)
            end

            if v[2] == 'to' then
                temp[3][#temp[3]] = last_elem:gsub('to', '')
                temp[3][#temp[3]] = last_elem .. ' to '
            end

            if v[2] == 'or' then
                temp[3] = temp[2] == 'Match' and { table.concat(temp[3], '<br>') } or temp[3]
                temp[2] = temp[2] == 'Match neither' and temp[2] or 'Match either'

                if last_elem ~= '' then
                    table.insert(temp[3], '')
                end
            end

            if temp[2] == 'Match' then
                local removed_v = v[2]:gsub('Match ', '')

                table.insert(temp[3], removed_v)
            end
        end

        temp[1] = temp[1] .. (type(v[1]) == 'table' and '' or v[1])
    end

    temp[1] = '[' .. temp[1] .. ']'
    temp[3] = concat_temp_class(temp[3])

    return temp
end

---@param tbl table
---@param is_capturing boolean
---@return table
local function check_capture(tbl, is_capturing)
    if not is_capturing then
        return tbl
    end

    tbl[2] = tbl[2]:gsub('Match', 'Capture')

    return tbl
end

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

---@param tbl table
---@param merged table
---@param is_capturing boolean
---@param is_group boolean
---@return table, string?
function M.merge(tbl, merged, is_capturing, is_group)
    fix_language()

    ---@class temp
    local temp = { '', '', {} }
    local err = nil

    for idx = 2, #tbl do
        local v = tbl[idx]
        local is_v_normal = type(v[2]) ~= 'table'
        local is_added = false

        if is_v_normal then
            local is_char_escaped = U.is_escape_char(v[1])
            local is_char_normal = U.starts_with(v[2], 'Match ' .. v[1])
            local is_char_quantifier = U.has_value(T.quantifiers, v[1])
            local is_char_chartbl = T.char_table[v[1]] ~= nil

            if #temp[3] == 0 then
                if is_char_escaped then
                    local removed_temp = temp[2]:gsub('Match ', '')

                    if removed_temp ~= '' then
                        table.insert(temp[3], removed_temp:sub(#U.escaped_char))
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
                    local removed_t = T.special_table[v[1]]:gsub('Match', ' and')

                    local last_merged = merged[#merged] or {}
                    local is_last_group = U.starts_with(last_merged[2] or '', 'Capture')
                    local is_last_class = (last_merged[1] or ''):sub(1, 1) == '['

                    if v[1] == '.' and temp[2] == '' then
                        -- concat just to fix warning about type (:
                        temp[2] = temp[2] .. T.special_table['.']

                        -- quantifier is related to group/class
                    elseif (is_last_group or is_last_class) and not is_group then
                        merged[#merged][1] = last_merged[1] .. v[1]
                        table.insert(merged[#merged][3], removed_t)
                        is_added = true

                        -- other quantifiers
                    else
                        table.insert(temp[3], v[2])
                    end
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

                    temp[3][#temp[3]] = last_elem == '' and removed_v or (last_elem .. '<br>' .. removed_v)
                end

                if v[2] == 'or' then
                    temp[3] = temp[2] == 'Match' and { table.concat(temp[3], '<br>') } or temp[3]
                    temp[2] = 'Match either'

                    if last_elem ~= '' then
                        table.insert(temp[3], '')
                    end
                end

                if is_char_quantifier and last_elem ~= v[2] then
                    table.insert(temp[3], v[2])
                end

                if temp[2] == 'Match' and not is_char_quantifier then
                    local removed_v = v[2]:gsub('Match ', '')

                    table.insert(temp[3], removed_v)
                end
            end
        else
            -- v is not normal (it's either group or class)
            if #temp[1] > 0 then
                temp = check_capture(temp, is_capturing)
                table.insert(merged, temp)

                temp = { '', '', {} }
            end

            if v[1][2] == '#CLASS' then
                table.insert(merged, merge_class(v))
            end

            if v[1][2] == '#QUANTIFIER' then
                table.insert(merged, {v[2][1], v[2][2], {}})
            end

            if v[1] == '#GROUP' then
                merged = M.merge(v, merged, true, true)
            end
        end

        local title = (type(v[1]) == 'table' or v[1] == '#GROUP') and '' or v[1]
        temp[1] = temp[1] .. (is_added and '' or title)
    end


    if #temp[1] > 0 then
        temp = check_capture(temp, is_capturing)
        temp[3] = concat_temp(temp[3], temp[2])
        table.insert(merged, temp)
    end

    return merged, err
end

return M
