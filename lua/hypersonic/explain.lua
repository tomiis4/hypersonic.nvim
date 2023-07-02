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

---@param char string
---@param type 'character'|'escaped'|'group'|'class'|'quantifier'
---@param quantifiers string
---@param is_class boolean?
---@param is_group boolean?
---@return table
local function explain_char(char, type, quantifiers, is_class, is_group)
    is_class = is_class == true and true or false
    quantifiers = is_class and '' or quantifiers
    local expl = {
        explanation = nil,
        children = {}
    }

    -- explain characer
    if type == 'escaped' then
        local split_i = is_class and 2 or 1
        local meta_expl = U.meta_table[char:sub(split_i, split_i)]

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

    local match_type = is_group and 'Capture' or 'Match'
    expl.explanation = expl.explanation:gsub('Match', match_type)

    return expl
end

---@param class_str string
---@param quantifiers string
---@return table<string>
local function explain_class(class_str, quantifiers)
    local main = {}

    class_str = class_str:gsub('^%^', '')
    local class_tbl = {}

    -- split class
    for c in string.gmatch(class_str, U.escaped_char .. '?.') do
        table.insert(class_tbl, c)
    end

    -- explain class
    local idx = 1
    while idx <= #class_tbl do
        local v = class_tbl[idx]
        local type = U.is_escape_char(v) and 'escaped' or 'character'
        local expl = explain_char(v, type, '', true).explanation:gsub('Match ', '')

        -- class use - as range
        if expl == '-' and idx ~= #class_tbl then
            local last_elem = main[#main]

            -- get future chacater
            v = class_tbl[idx + 1]
            type = U.is_escape_char(v) and 'escaped' or 'character'
            expl = explain_char(v, type, '', true).explanation:gsub('Match ', '')

            expl = 'range from ' .. last_elem .. ' to ' .. expl


            idx = idx + 1
            table.remove(main, #main)
        end

        idx = idx + 1
        table.insert(main, expl)
    end

    -- explain quantifier
    local quant_len = quantifiers and #quantifiers or 0
    for i = 1, quant_len do
        local q = quantifiers:sub(i, i)

        table.insert(main, T.special_table[q])
    end

    return main
end

---@param tbl Node[]
---@param main Explained[]?
---@param is_group boolean?
---@return table
function M.explain(tbl, main, is_group)
    fix_language()
    main = main or {}

    for idx = 1, #tbl do
        ---@type Node
        local v = tbl[idx]
        local type, value, children, quantifiers = v.type, v.value, v.children, v.quantifiers

        if type == 'escaped' or type == 'character' then
            local expl = explain_char(value, type, quantifiers, false, is_group)
            local node = {
                value = value .. quantifiers,
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
                value = '[' .. value .. ']' .. quantifiers,
                explanation = 'Match ' .. class_start,
                children = explain_class(value, quantifiers)
            }
            table.insert(main, node)
        end

        if type == 'group' then
            children[#children].quantifiers = quantifiers
            main = M.explain(children, main, true)
        end
    end

    return main
end

return M
