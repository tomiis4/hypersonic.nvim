local U = {}

---@param char string
---@return boolean
function U.is_escape_char(char)
    return string.sub(char, 1, 1) == U.escaped_char
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
    return ending == "" or s:sub( -#ending) == ending
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

---@param tbl table
---@return integer
function U.get_longest(tbl)
    table.sort(tbl, function(a, b) return #b < #a end)
    return #tbl[1]
end

---@param tbl table
---@return integer
function U.get_longest_key(tbl)
    local n = 0

    for _, v in pairs(tbl) do
        if #v.value > n then
            n = #v.value
        end
    end

    return n
end

---@param s string
---@param wrap string
---@return string
function U.wrap(s, wrap)
    return wrap .. s .. wrap
end

---@param s string
---@return string
function U.trim(s)
    local t, _ = s:gsub("^%s*(.-)%s*$", "%1")
    return t
end

---@param s string
---@param value string
---@return number
function U.find(s, value)
    local n = 0
    for _ in string.gmatch(s, value) do
        n = n + 1
    end

    return n
end

---@param tbl table
---@return string
function U.concat_or(tbl)
    if #tbl == 1 then
        return tbl[1]
    else
        local prev_value = table.remove(tbl)
        local joined = table.concat(tbl, ", ")

        return joined .. " or " .. prev_value
    end
end

U.escaped_char = '\\'

return U
