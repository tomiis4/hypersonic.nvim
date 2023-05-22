local E = require('explain')
local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

---@param tbl table
M.merge = function(tbl)

end

local test_idx = 7
local test_tbl = S.split(T.test_inputs[test_idx])
local explained_tbl = E.explain(test_tbl, { { 'Regex', T.test_inputs[test_idx] } })
U.print_table(M.merge(explained_tb.print_table(M.merge(explained_tbl))))

return M
