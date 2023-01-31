local REGEX_TABLE = {}


-- CHECK

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

-- check if is literal characters
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


-- CAPTURING



-- final function for spliting regex to groups
local function split(regex)
	local split_regex = split_by_letter(regex)

	-- just for removing warnings
	print(split_regex())
	print(is_literal_character())
	print(is_character())
	print(is_group())
	print(is_class())
end


split('^([a-zA-Z])(*$)')
