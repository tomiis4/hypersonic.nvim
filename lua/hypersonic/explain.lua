-- uilt

local function len(arr)
	local i=0

	for _ in pairs(arr) do
		i = i + 1
	end

	return i
end

-- print table
local function tprint(tbl, indent)
	indent = indent or 0
	print(string.rep("  ", indent) .. "{")
	for _, v in pairs(tbl) do
		if type(v) == "table" then
			tprint(v, indent + 1)
		else
			print(string.rep("  ", indent + 1) .. string.format("%q,", v))
		end
	end
	print(string.rep("  ", indent) .. "},")
end


local function connect_table(tbl)
	local str = ''

	for _, elem in pairs(tbl) do
		-- to make sure its correct
		if type(elem) == 'string' then
			local last_letter = str:sub(#str, #str)
			local first_letter = elem:sub(1, 1)

			-- if 2 letters are same
			if first_letter == last_letter then
				-- remove last letter from main string and add to it element
				str = str:sub(1, #str - 1)..elem
			else
				str = str..elem
			end
		end
	end

	-- if is last ',' remove it
	if str:sub(#str,#str) == ',' then
		str = str:sub(1, #str-1)
	end

	return str
end


-- if is end or start of class
-- is_class('start' || 'end', string) => boolean
local function is_class(type, letter)
	if type == 'start' and letter == '#class' then
		return true
	elseif type == 'end' and letter == '#end-class' then
		return true
	end

	return false
end

local function is_character(letter)
	local is_char = string.match(letter, '[a-zA-Z]')

	if is_char and #letter == 1 then
		return true
	end

	return false
end

local function is_symbol(letter)
	local is_symbol_v = string.match(letter, '%W')
	local letter_str = tostring(letter)

	if is_symbol_v and #letter_str == 1 then
		return true
	end

	return false
end


-- explain class
--		Check if class does contain not (^)
--			if it does contain
--			check is range (a-z)
--				if future == - then insert letter (from)
--				if letter == - then insert future (to)
--
--			check is or
--			a) next each other (ab) is same as a||b
--				if letters are length 1
--				and are not symbols (only numbers, a-z)
--				insert letter and future
--			b)	if it's separated using | (a|b)
--				if future == |
--					(just for better reading)
--					if table is have only (NOT string)
--						insert letter
--					else
--						insert characters letter
--				if letter == |
--					insert future_letter
--		class does not contain not
--			is empty
--				range
--					future == - insert letter
--				or next each other
--					if letters are length 1
--					and are not symbols (only numbers, a-z)
--					insert letter, future
--				or with |
--					future == |
--						insert letter
--					letter == |
--						insert future
--
--
-- FIXME while connecting string, make sure ther are not 2x same chars at 'end'

local temp_class = {}
local check_class = {
	not_index = nil
}
local function explain_class(letter, future_letter)
	-- if regex contains NOT (^), add it to check
	if letter == '^' then
		check_class['not_index'] = 1
		table.insert(temp_class, 'Class #NUMBER matches characters that are NOT included in')
	end

	-- if it's not
	if check_class['not_index'] ~= nil then
		-- check for range
		if future_letter == '-' then
			table.insert(temp_class, " range from "..letter)
		elseif letter == '-' then
			table.insert(temp_class, " to "..future_letter..",")
		end

		-- or
		-- next eachother
		if not is_symbol(letter) and not is_symbol(future_letter) and is_len_one then
			table.insert(temp_class, " characters"..letter.." or "..future_letter..",")
		end

		-- or
		-- | symbol
		if future_letter == '|' then
			table.insert(temp_class, " or characters "..letter)
		elseif letter == '|' then
			table.insert(temp_class, " or "..future_letter..",")
		end
	end


	-- explain class without NOT character
	if check_class['not_index'] == nil then
		-- TEMP_CLASS is empty
		if len(temp_class) == 0 then
			local is_len_one = #letter == 1 and #future_letter == 1

			-- range
			if future_letter == '-' then
				temp_class[len(temp_class)+1] = 'Class #NUMBER matches characters in range from '..letter
			end

			-- or
			-- next eachother
			if not is_symbol(letter) and not is_symbol(future_letter) and is_len_one then
				table.insert(temp_class, "Class #NUMBER matches characters "..letter.." or "..future_letter..",")
			end

			-- separated using | symbool
			if future_letter == '|' then
				table.insert(temp_class, "Class #NUMBER matches characters "..letter.." ")
			elseif letter == '|' then
				table.insert(temp_class, "or "..future_letter..",")
			end
		else
			-- TEMP_CLASS is not empty
			-- range
			if letter == '-' then
				table.insert(temp_class, ' to '..future_letter..",")
			end

			-- or
			-- next eachother
			local is_len_one = #letter == 1 and #future_letter == 1
			if not is_symbol(letter) and not is_symbol(future_letter) and is_len_one then
				table.insert(temp_class, ""..letter.." or "..future_letter..",")
			end

			-- separated using | symbool
			if letter == '|' then
				table.insert(temp_class, " or "..future_letter..",")
			end
		end
	end


	return temp_class
end

-- main

local function explain(regex)
	local response = {}
	local isClass = false

	-- loop trough full regex
	for i, elem in pairs(regex) do
		-- if its group, explain that group
		if type(elem) == 'table' then
			explain(elem)
		else
			-- MAIN EXPLAINING CODE

			--  CLASS  --
			-- check if is start of class and clear temp_class
			if is_class('start', elem) then
				isClass = true
				temp_class = {}
			end

			-- explain class
			-- is_class variable check if is not empty table | regexI+1 = next letter
			local is_start_end = is_class('start', elem) == false and is_class('end', elem) == false
			if isClass == true and is_start_end then
				local class_table = explain_class(elem, regex[i+1])
				local str_table = connect_table(class_table)

				table.insert(response, str_table)
			end

			-- check if is end of class and clear temp_class
			if is_class('end', elem) then
				isClass = false
				temp_class = {}
			end
		end
	end

	tprint(response)
end


local regex = {
	'g',
	'r',
	'#class',
		'^',
		'a',
		'-',
		'y',
		'p',
		'-',
		'x',
	'#end-class',
	'y'
}

-- local regex = {
-- 	'g',
-- 	'r',
-- 	'#class',
-- 		'^',
-- 		'a',
-- 		'-',
-- 		'b',
-- 		'c',
-- 		'|',
-- 		'p',
-- 	'#end-class',
-- 	'y'
-- }

explain(regex)
