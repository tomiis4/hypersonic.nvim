local U = {}

---@param tbl table
---@param n number? number of indents (default 0)
---@return nil
function U.print_table(tbl, n)
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

---insert element to specific depth
---@param tbl table
---@param ctx table|string
---@param depth number
---@return table
function U.insert(tbl, depth, ctx)
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
function U.is_escape_char(char)
    return string.sub(char, 1, 1) == '\\'
end

---@param depth integer
---@return string
function U.get_depth(depth)
    return string.rep('<space>', depth)
end

---@param s string
---@param start string
---@return boolean
function U.starts_with(s, start)
    return string.sub(s, 1, #start) == start
end

---@param s string
---@param ending string
---@return boolean
function U.ends_with(s, ending)
    return ending == "" or s:sub(-#ending) == ending
end

---@param tbl table
---@param v any
---@return boolean
function U.has_value(tbl, v)
    for _, v1 in ipairs(tbl) do
        if v1 == v then
            return true
        end
    end

    return false
end

---@param s string
---@param sep string
---@return table, integer
function U.split(s, sep)
    local t = {}
    local n = 0

    if s == nil then
        return {}, 0
    end

    for v in string.gmatch(s .. sep, '(.-)' .. sep) do
        table.insert(t, v)
        n = n + 1
    end

    return t, n
end

return U
