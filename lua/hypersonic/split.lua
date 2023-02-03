-- Structure, each {} is group ()
-- { \n, \n, da, { x,y \b, { \b } }, { \nd } }
local REGEX_TABLE = {}

-- UILT


-- print table function
local function print_table(tbl, indent)
  indent = indent or 0
  print(string.rep("  ", indent) .. "{")
  for _, v in pairs(tbl) do
    if type(v) == "table" then
      print_table(v, indent + 1)
    else
      print(string.rep("  ", indent + 1) .. string.format("%q,", v))
    end
  end
  print(string.rep("  ", indent) .. "},")
end

-- split string letter by letter
local function split_by_letter(str)
	local letters = {}

	if #str == 1 then
		return str
	end

	for i = 1, #str do
		local letter = string.sub(str, i, i)
	   table.insert(letters, letter)
	end

	return letters
end

-- Get length of array/table
-- len( []any ) => int
local function len(arr)
	local i=0

	for _ in pairs(arr) do
		i = i + 1
	end

	return i
end


-- function for append()
local function find_group(tbl, group, value)
	local temp_group = tbl
	local last_elem = temp_group[len(temp_group)]

	-- loop for groups and add new table GROUP times
	for i=2, group do
		if type(last_elem) ~= "table" then
			table.insert(temp_group, {})
		end

		-- asign temp_group to new group
		-- and update last element
		temp_group = temp_group[len(temp_group)]
		last_elem = temp_group[len(temp_group)]
	end

	-- insert element
	-- if type(last_elem) == "table" then
		-- table.insert(temp_group, "group: "..group.." "..value)
		table.insert(temp_group, value)
	-- else
	-- 	local temp_elem = {"group: "..group.." "..value}
		-- local temp_elem = {"TempValue: "..value}
		-- table.insert(temp_group, temp_elem)
	-- end
end

-- Append item to REGEX_TABLE
-- append( []any, int, any(string))
local function append(tbl, group, value)
	if group == 1 then
 		-- table.insert(REGEX_TABLE, "group: "..group.." "..value)
		table.insert(REGEX_TABLE, value)
 		return
	end

	find_group(tbl, group, value)
end


-- CHECK


-- check if is literal character
local function is_literal_character(previous_letter)
	if previous_letter == '\\' then
		return true
	else
		return false
	end
end

-- check if is character
local function is_character(previous_letter, letter)
	local is_char = string.match(letter, '[a-zA-Z]')

	if is_literal_character(previous_letter) == false and is_char then
		return true
	else
		return false
	end
end

-- if is end or start of group
-- is_group('start' || 'end', string) => boolean
local function is_group(type, letter)
	if type == 'start' and letter == '(' then
		return true
	elseif type == 'end' and letter == ')' then
		return true
	else
		return false
	end
end

-- if is end or start of class
-- is_class('start' || 'end', string) => boolean
local function is_class(type, letter)
	if type == 'start' and letter == '[' then
		return true
	elseif type == 'end' and letter == ']' then
		return true
	else
		return false
	end
end

-- TODO add other characters ($, ^, ...)

-- CAPTURING

local function capture_class(group, letter)
	append(REGEX_TABLE, group, letter)
end


-- final function for spliting regex to groups
local function split(regex)
	local split_regex = split_by_letter(regex)
	local regex_group = 1

	-- false = can capture class, true = can capture everything
	local can_capture = true

	for i=1, len(split_regex) do
		local letter = split_regex[i]
		local prev_letter = split_regex[i-1]

		-- group check
		-- FIXME
		if is_group('start', letter) then
			regex_group = regex_group + 1
		elseif is_group('end', letter) then
			regex_group = regex_group - 1
		end

		-- check for classes
		if is_class('start', letter) then
			can_capture = false
		elseif is_class('end', letter) then
			can_capture = true
		end

		-- CAPTURE
		-- caprure in class
		if can_capture == false then
			capture_class(regex_group, letter)
		end

		-- capture literal characters
		if is_literal_character(prev_letter) and can_capture then
			local char = prev_letter..letter

			append(REGEX_TABLE, regex_group, char)
			i = i+1
		end

		-- capture character
		if is_character(prev_letter, letter) and can_capture then
			append(REGEX_TABLE, regex_group, letter)
		end
	end


	print_table(REGEX_TABLE)
end


-- Need fix groups between, it put 2() inside same object
-- split('xyz(xy)(uy)')


-- TESTING
-- split('hi(match(sh(ws))(x))(sa)')
-- split('y^([a-zA-Z](x))(*$)ahoj')
-- split('xyz(pl(sa))')
