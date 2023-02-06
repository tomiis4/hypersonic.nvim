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
-- How does it work?
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
--
--		( i think this is more simple than with ^)
--		TODO remake first explain with ^
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
	not_index = nil,
	range_index = nil
}
local function explain_class(letter, future_letter)
	-- if contain NOT insert explaination in temp
	if letter == '^' then
		check_class['not_index'] = len(temp_class)+1
		temp_class[len(temp_class)+1] = { 'Class #NUMBER matches characters that are NOT included in' }
	end


	-- add range elements to NOT
	if check_class['not_index'] ~= nil then
		local notTable = temp_class[check_class['not_index']]

		-- range elements
		if future_letter == '-' then
			table.insert(notTable, "range from "..letter)
		elseif letter == '-' then
			table.insert(notTable, "to"..future_letter)
		end

		-- next eachother
		local is_len_one = #letter == 1 and #future_letter == 1
		if not is_symbol(letter) and not is_symbol(future_letter) and is_len_one then
			-- if it have other elements
			if len(notTable) > 1 then
				local result = ""..letter.." or "..future_letter
				table.insert(notTable, result)
			else
				-- there is only NOT character
				local result = "characters "..letter.." or "..future_letter
				table.insert(notTable, result)
			end
		end

		-- or operator (|)
		if future_letter == '|' then
			-- if there is multiple checks
			if len(notTable) > 1 then
				table.insert(notTable, ""..letter)
			else
				-- there is only NOT
				table.insert(notTable, "characters "..letter)
			end
		elseif letter == '|' then
			table.insert(notTable, "or "..future_letter)
		end
	end


	-- explain class without NOT character

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
			table.insert(temp_class, "Class #NUMBER matches characters "..letter.." or "..future_letter)
		end

		-- separated using | symbool
		if future_letter == '|' then
			table.insert(temp_class, "Class #NUMBER matches characters "..letter.." ")
		elseif letter == '|' then
			table.insert(temp_class, "or "..future_letter)
		end
	else
		-- TEMP_CLASS is not empty
		-- range
		if letter == '-' then
			table.insert(temp_class, ' to '..future_letter)
		end

		-- or
		-- next eachother
		local is_len_one = #letter == 1 and #future_letter == 1
		if not is_symbol(letter) and not is_symbol(future_letter) and is_len_one then
			table.insert(temp_class, ""..letter.." or "..future_letter)
		end

		-- separated using | symbool
		if letter == '|' then
			table.insert(temp_class, "or "..future_letter)
		end
	end


	tprint(temp_class)
end

-- main

local function explain(regex)
	-- local formated_response = {}
	-- local response = {}
	local isClass = false

	-- loop trough full regex
	for i, elem in pairs(regex) do
		-- if its group, explain that group
		if type(elem) == 'table' then
			explain(elem)
		else
			-- MAIN EXPLAINING CODE

			-- CLASS
			-- check if is start of class and clear temp_class
			if is_class('start', elem) then
				isClass = true
				temp_class = {}
			end

			-- explain class
			-- is_class variable check if is not empty table | regexI+1 = next letter
			local is_start_end = is_class('start', elem) == false and is_class('end', elem) == false
			if isClass == true and is_start_end then
				explain_class(elem, regex[i+1])
			end

			-- check if is end of class and clear temp_class
			if is_class('end', elem) then
				isClass = false
				temp_class = {}
			end
		end
	end
end


local regex = {
	'g',
	'r',
	'#class',
		'a',
		'-',
		'y',
		'p',
		'|',
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
