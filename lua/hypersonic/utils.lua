local U = {}

---@param tbl table
---@param n number
---@return nil
U.print_table = function(tbl, n)
    n = n or 0

    print(string.rep('|   ', n) .. '{')

    for _, v in pairs(tbl) do
        if type(v) == 'table' then
            U.print_table(v, n + 1)
        else
            print(string.rep('|   ', n + 1) .. v .. ',')
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
    return string.sub(char, 1, 1) == '\\'
end

---@param depth integer
---@return string
U.get_depth = function(depth)
    return string.rep('<space>', depth)
end

---@param s string
---@param start string
---@return boolean
U.starts_with = function(s, start)
    return string.sub(s, 1, #start) == start
end

---@param s string
---@param ends string
---@return boolean
U.ends_with = function(s, ends)
    return ends == "" or string.sub(s, -#ends) == ends
end

---@param tbl table
---@param v any
---@return boolean
U.has_value = function(tbl, v)
    for _, v1 in ipairs(tbl) do
        if v1 == v then
            return true
        end
    end

    return false
end


return U
