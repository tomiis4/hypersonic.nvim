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

    local single_char = {}

    for idx = 1, #tbl do
        ---@type Merged
        local v = tbl[idx]
        local value, children, explanation = v.value, v.children, v.explanation

        local is_group = explanation:find('Capture') ~= nil
        local is_class = explanation:find('either') ~= nil

        if is_class then
            table.insert(main, {
                value = value,
                children = merge_class(children),
                explanation = explanation
            })
        end

        if is_group then
            if #single_char > 0 then
                local concat = table.concat(single_char)
                table.insert(main, {
                    value = concat,
                    children = {},
                    explanation = 'Capture ' .. concat,
                    -- FIXME ^, fix captur/match
                })
                single_char = {}
            end
        end

        if not is_class then
            local char = explanation:gsub('Match ', '')
            char = char:gsub('Capture ', '')

            if #children >= 1 or #char > 1 then
                if #single_char > 0 then
                    local concat = table.concat(single_char)
                    table.insert(main, {
                        value = concat,
                        children = {},
                        explanation = 'Match ' .. concat,
                        -- FIXME ^
                    })
                    single_char = {}
                end

                table.insert(main, {
                    value = value,
                    children = children,
                    explanation = explanation
                })
            end

            -- vim.print('child', children, 'char ' .. #char)
            if #children == 0 and #char == 1 then
                -- vim.print(single_char)
                table.insert(single_char, char)
            end
        end
    end
    if #single_char > 0 then
        local concat = table.concat(single_char)
        table.insert(main, {
            value = concat,
            children = {},
            explanation = 'Match ' .. concat,
        })
    end

    return #main == 0 and tbl or main
end

-- ---@param tbl Explained[]
-- ---@param main Merged[]?
-- ---@return table
-- function M.merge(tbl, main)
--     fix_language()
--     main = main or {}
--
--     local single = {}
--
--     for idx = 1, #tbl do
--         ---@type Merged
--         local v = tbl[idx]
--         local value, children, explanation = v.value, v.children, v.explanation
--
--         local is_group = explanation:find('Capture') ~= nil
--         local is_class = explanation:find('either') ~= nil
--
--         if is_class then
--             if #single > 0 then
--                 local concat = table.concat(single)
--                 table.insert(main, {
--                     value = concat,
--                     children = {},
--                     explanation = 'Match ' .. concat,
--                 })
--             end
--             single = {}
--
--             children = merge_class(children)
--         end
--
--         if is_group then
--             if #single > 0 then
--                 local concat = table.concat(single)
--                 table.insert(main, {
--                     value = concat,
--                     children = {},
--                     explanation = 'Capture ' .. concat,
--                 })
--             end
--             single = {}
--         end
--
--         if not is_class then
--             local char = explanation:gsub('Match |Capture ', '')
--
--             if #children >= 1 or #char > 1 then
--                 if #single > 0 then
--                     local concat = table.concat(single)
--                     table.insert(main, {
--                         value = concat,
--                         children = {},
--                         explanation = 'Match ' .. concat,
--                         -- FIXME ^
--                     })
--                     single = {}
--                 end
--
--                 table.insert(main, {
--                     value = value,
--                     children = children,
--                     explanation = explanation
--                 })
--             end
--
--             if #children == 0 and #char == 1 then
--                 table.insert(single, char)
--             end
--
--         end
--     end
--
--     if #single > 0 then
--         local concat = table.concat(single)
--         table.insert(main, {
--             value = concat,
--             children = {},
--             explanation = 'Match ' .. concat,
--         })
--         single = {}
--     end
--
--     return main
-- end

return M
