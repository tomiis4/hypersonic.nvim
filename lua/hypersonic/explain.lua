local U = require('hypersonic.utils')
local S = require('hypersonic.split')
local M = {}

---@param tbl table
---@param result_tbl table
---@return table
M.split = function(tbl, result_tbl)
    for _, v in pairs(tbl) do
        if type(v) == 'table' then
            M.split(v, result_tbl)
        elseif U.is_escape_char(v) then
            local c = string.sub(v, 2,2)
            local e = U.meta_table[c]

            table.insert(result_tbl, {v, e})
        end

    end

    return result_tbl
end

local test_idx = 3
local test_tbl = S.split(U.input_test[test_idx])
local result = M.split(test_tbl, {{'Regex', U.input_test[test_idx]}})
U.print_table(result, 0)
