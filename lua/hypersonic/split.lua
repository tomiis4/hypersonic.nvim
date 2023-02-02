-- Structure, each {} is group ()
-- { \n, \n, da, { x,y \b, { \b } }, { \nd } }
local REGEX_TABLE = {}

-- UILT

-- print table
local function print_table(tbl)
	for _, elem in ipairs(tbl) do
		if type(elem) == "table" then
			print_table(elem)
		else
			print(elem)
		end
	end
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


-- FUCK THIS SCHEME AND THIS FUNCTION
-- New scheme for append function
-- 	take TABLE, GROUP, VALUE as argument
-- 	loop trough TABLE and each time you find new type=table
-- 		add 1 to some index, if index == GROUP then 



--	UPDATE, FUCK THIS SHIT TOO
-- FIXME If i make 2 tables, one for chars and second for groups
-- FIXME in chars i will save like { x,y,c, #groupX", {} }


-- Append item to REGEX_TABLE
-- append( []any, int, any(string))
-- FIXME appending to another group
-- FIXME OPTIONS:
--		- group does not exists
--		- it's saved in copy of variable
local function append(tbl, group, value)
	-- if is inserting to main arr
	if group == 1 then
		table.insert(REGEX_TABLE, value)
		return
	end

	-- loop trough main arr
	for _, val in ipairs(tbl) do
		-- if main have table
		if type(val) == "table" then
			group = group - 1

			if group == 1 then
				table.insert(val, value)
				return
			end
			append(val, group-1, value)
		end
	end
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
		-- if is_group('start', letter) then
		-- 	regex_group = regex_group + 1
		-- elseif is_group('end', letter) then
		-- 	regex_group = regex_group - 1
		-- end

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

	-- just for removing warnings
	-- print(split_regex())
	-- print(is_group())
	-- print(is_class())
	-- print(is_literal_character())
	-- print(is_character())
	print_table(REGEX_TABLE)
end


split('^([a-zA-Z])(*$)ahoj')
