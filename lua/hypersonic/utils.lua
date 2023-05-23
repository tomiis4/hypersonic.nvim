local U = {}

---@param tbl table
---@param n number
---@return nil
U.print_table = function(tbl, n)
    n = n or 0

    print(string.rep('|   ', n) .. '{')

    for i, v in pairs(tbl) do
        if type(v) == 'table' then
            U.print_table(v, n + 1)
        else
            print(string.rep('|   ', n + 1) .. string.format('[%q]: %q,', i, v))
        end
    end
    print(string.rep('|   ', n) .. '},')
end

---@param tbl table
---@param ctx table|string
---@param depth number
---@return table
U.insert = function(tbl, depth, ctx)
    local last_item = tbl

    -- if is last item of LAST_ITEM table, set it as last item, else make new table with idx+
    for _ = 1, depth do
        if type(last_item[#last_item]) == 'table' then
            last_item = last_item[#last_item]
        else
            last_item[#last_item + 1] = {}
            last_item = last_item[#last_item]
        end
    end

    table.insert(last_item, ctx)
    return tbl
end

---@param char string
---@return boolean
U.is_escape_char = function(char)
    return string.sub(char, 1,1) == '\\'
end

return U
