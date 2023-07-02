--[[

For future developers:

I'm very sorry.
Good luck.
    - tomiis

]]

local T = require('hypersonic.tables')
local U = require('hypersonic.utils')
local M = {}

---@alias Merged Explained

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

---@param class table
---@return table
local function merge_class(class)
    local main = {}
    local single = {}

    for i = 1, #class do
        local char = class[i]

        if #char == 1 then
            table.insert(single, char)
        else
            if #single > 0 then
                table.insert(main, U.concat_or(single))
                single = {}
            end

            table.insert(main, char)
        end

        i = i + 1
    end

    if #single > 0 then
        table.insert(main, U.concat_or(single))
        single = {}
    end

    return main
end

---@param tbl Explained[]
---@param main Merged[]?
---@return table
function M.merge(tbl, main)
    fix_language()
    main = main or {}

    local temp = {
        char = {},
        children = {},
        type = '',
    }

    local function clear_single()
        if #temp.char > 0 then
            local concat = table.concat(temp.char)
            table.insert(main, {
                value = concat,
                children = temp.children,
                explanation = temp.type .. ' ' .. concat,
            })
        end

        temp = {
            char = {},
            children = {},
            type = '',
        }
    end

    for idx = 1, #tbl do
        ---@type Merged
        local v = tbl[idx]
        local value, children, explanation = v.value, v.children, v.explanation
        local char = explanation:gsub('Match ', ''):gsub('Capture ', '')

        local is_group = explanation:find('Capture') ~= nil
        local is_class = explanation:find('either') ~= nil

        if is_class then
            clear_single()
            table.insert(main, {
                value = value,
                children = merge_class(children),
                explanation = explanation
            })
        end

        if is_group then
            if temp.type == 'Match' then
                clear_single()
            end

            if #char == 1 and #children == 0 then
                table.insert(temp.char, char)
            else
                if #char == 1 then
                    table.insert(temp.char, char)
                else
                    table.insert(temp.children, char)
                end

                -- quantifiers
                for _, child in ipairs(children) do
                    table.insert(temp.children, child)
                end
            end
        end

        if not is_group and not is_class then
            if temp.type == 'Capture' then
                clear_single()
            end

            if #char == 1 and #children == 0 then
                table.insert(temp.char, char)
            else
                clear_single()

                table.insert(main, {
                    value = value,
                    children = children,
                    explanation = explanation
                })
            end
        end

        if is_group then
            temp.type = 'Capture'
        elseif not is_class then
            temp.type = 'Match'
        end
    end

    clear_single()
    return main
end

return M
