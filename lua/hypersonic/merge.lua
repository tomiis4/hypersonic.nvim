local E = require('explain')
local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

---@param tbl table
---@param merged table
---@param depth integer
---@return table
local function merge_str(class, merged, depth)
    local temp_str = ""

    for char, v in pairs(class) do
        local depth_str = U.get_depth(depth)

    end

    return merged
end

---@param tbl table
---@param merged table
---@param depth integer
---@return table
M.merge = function(tbl, merged, depth)
    for _, v in pairs(tbl) do
        print(v)
        U.print_table(v,0)
    end

    return merged
end

local idx = 4
local split_tbl = S.split(T.test_inputs[idx])
local expl_tbl = E.explain(split_tbl, {})

M.merge(expl_tbl, {}, 0)
-- U.print_table(M.merge(expl_tbl, {}, 0), 0)


return M
