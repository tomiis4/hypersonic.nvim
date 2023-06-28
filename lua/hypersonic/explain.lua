local U = require('hypersonic.utils')
local T = require('hypersonic.tables')
local M = {}

---@class Explained
---@field value string
---@field explanation string
---@field children table<string>|{}

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

-- ---@param char string
-- ---@return string
-- local function explain_char(char)
--     if U.is_escape_char(char) then
--         local single_char = char:sub(2, 2)
--         local meta_explain = T.meta_table[single_char] or ('Match escaped ' .. char)
--
--         return meta_explain
--     else
--         local tables_explain = T.special_table[char] or T.char_table[char] or ('Match ' .. char)
--
--         return tables_explain
--     end
-- end
--
-- --- class have only normal/escaped characters, ranges, except
-- ---@param tbl table
-- ---@return table
-- local function explain_class(tbl)
--     local class = { { 'class #CLASS', tbl[1] } }
--
--     for idx, v in pairs(tbl) do
--         if v ~= '#CLASS' then
--             local explained_char = explain_char(v)
--
--             -- class does not have "or" as "|"
--             if explained_char == T.special_table['|'] then
--                 explained_char = 'Match |'
--             end
--
--             -- class does not have "^" as "Start of string"
--             if explained_char == T.char_table['^'] then
--                 explained_char = 'Match ^'
--             end
--
--             -- class does not have quantifiers
--             if U.has_value(T.quantifiers, v) then
--                 explained_char = 'Match ' .. v
--             end
--
--             -- if is "-" last element, it does not mean range
--             if idx == #tbl and explained_char == T.special_table['-'] then
--                 explained_char = 'Match -'
--             end
--
--             table.insert(class, { v, explained_char })
--
--             -- add "or"
--             local is_not_range = class[#class][2] ~= 'to'
--             local is_future_range = tbl[idx + 1] == '-'
--
--             if idx ~= #tbl and is_not_range and not is_future_range then
--                 table.insert(class, { '', 'or' })
--             end
--         end
--     end
--
--     return class
-- end
--
-- ---@param tbl table
-- ---@return table
-- local function explain_quantifier(tbl)
--     local res = { { tbl[1], tbl[1] } }
--     local num = ''
--
--     for i = 2, #tbl do
--         local v = tbl[i]
--
--         if v == ',' then
--             table.insert(res, { '{' .. num, 'Match ' .. num })
--             num = ''
--         elseif v:match('[0-9]') then
--             num = num .. v
--         end
--     end
--
--     res[#res][2] = res[#res][2] .. ' to ' .. num
--
--     res[#res][1] = res[#res][1] .. ',' .. num .. '}'
--     res[#res][2] = res[#res][2] .. (num == '' and 'inf' or '') .. ' times'
--
--     return res
-- end

---@param char string
---@param type 'character'|'escaped'|'group'|'class'|'quantifier'
---@param is_class boolean?
---@return table
local function explain_char(char, type, is_class)
    is_class = is_class == true and true or false
    local quantifiers = is_class and '' or char:match('[?+*]+')
    local expl = {
        explanation = nil,
        children = {}
    }

    -- explain characer
    if type == 'escaped' then
        local meta_expl = U.meta_table[char:sub(1, 1)]
        if meta_expl then
            expl.explanation = meta_expl
        else
            expl.explanation = 'Match escaped ' .. char:sub(1, 1)
        end
    else
        local single_char = char:sub(1, 1)
        local e = T.char_table[single_char]
            or T.special_table[single_char]
            or 'Match ' .. single_char

        expl.explanation = is_class and single_char or e
    end

    -- explain quantifier
    local quant_len = quantifiers and #quantifiers or 0
    for i = 1, quant_len do
        local q = quantifiers:sub(i, i)

        table.insert(expl.children, T.special_table[q])
    end

    return expl
end

--- TODO: add range
--- FIXME: fix +?* after class
---@param class_str string
---@return table<string>
local function explain_class(class_str)
    local main = {}

    class_str = class_str:gsub('^%^', '')
    local class_tbl = {}

    for c in string.gmatch(class_str, U.escaped_char .. '?.') do
        table.insert(class_tbl, c)
    end

    for _, v in ipairs(class_tbl) do
        local type = U.is_escape_char(v) and 'escaped' or 'character'
        local expl = explain_char(v, type, true).explanation:gsub('Match ', '')
        table.insert(main, expl)
    end

    return main
end

---@param tbl Node[]
---@param main Explained[]?
---@return table
function M.explain(tbl, main)
    fix_language()
    main = main or {}
    vim.print('---------------------')
    vim.print(tbl)
    vim.print('---------------------')

    for idx = 1, #tbl do
        ---@type Node
        local v = tbl[idx]
        local type, value, children = v.type, v.value, v.children

        if type == 'escaped' or type == 'character' then
            print(value)
            local expl = explain_char(value, type)
            local node = {
                value = value,
                explanation = expl.explanation,
                children = expl.children
            }
            table.insert(main, node)
        end

        if type == 'quantifier' and #main >= 1 then
            local q_value = '{' .. value.min .. ',' .. value.max .. '}'
            local q_explanation = (value.min .. ' to ' .. value.max .. ' times')

            -- add quantifier to previous value child
            main[#main].value = main[#main].value .. q_value
            table.insert(main[#main].children, q_explanation)
        end

        if type == 'class' then
            local class_start = value:sub(1, 1) == '^' and 'neither' or 'either'

            local node = {
                value = '[' .. value .. ']',
                explanation = 'Match ' .. class_start,
                children = explain_class(value)
            }
            table.insert(main, node)
        end

        if type == 'group' then
            main = M.explain(children, main)
        end
    end

    return main
end

return M
