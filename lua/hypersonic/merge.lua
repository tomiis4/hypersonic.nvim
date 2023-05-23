local E = require('explain')
local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

---@param tbl table
---@param merged table
---@return table
M.merge = function(tbl, merged)
end

local idx = 5
local split_tbl = S.split(T.test_inputs[idx])
local expl_tbl = E.explain(split_tbl, {})

U.print_table(M.merge(expl_tbl, {}), 0)


return M
