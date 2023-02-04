-- uilt

local function len(arr)
	local i=0

	for _ in pairs(arr) do
		i = i + 1
	end

	return i
end


local function tprint(tbl)
	for _, value in pairs(tbl) do
		print(value)
	end
end

-- check
-- local function is_letter(letter)
-- 	local is_char = string.match(letter, '[a-zA-Z]')

-- 	if #letter == 1 and is_char then
-- 		return true
-- 	end

-- 	return false
-- end

-- if is end or start of class
-- is_class('start' || 'end', string) => boolean
local function is_class(type, letter)
	if type == 'start' and letter == '#class' then
		return true
	elseif type == 'end' and letter == '#end-class' then
		return true
	else
		return false
	end
end

-- explain

-- check if it contain NOT
--		:-> put in temp_class i=0
--			^ match character that is NOT included in
--			IF future_letter is - then insert to 0
--				range from LETTER to
--			IF letter is - then insert to 0
--				FUTURE LETTER

--	check if it not contain NOT
--		IF future_letter is - then insert to next index
--			match characters from LETTER
--		IF letter is - then insert to next index
--			FUTURE LETTER

-- check if x1 == character and x2 == character, same as |
--		add OR to things

local temp_class = {}
local check_class = {
	not_index = nil,
	range_index = nil
}
local function explain_class(letter, future_letter)
	-- if contain NOT insert explaination in temp
	if letter == '^' then
		check_class["not_index"] = len(temp_class)
		temp_class[len(temp_class)] = { '^ match character that is NOT included in' }
	end

	-- add any character if element NOT exist
	if check_class["not_index"] ~= nil then
		local notTable = temp_class[check_class["not_index"]]
		table.insert(notTable, letter)
	end

	-- check if it contain range
	if future_letter == "-" then
		temp_class[len(temp_class)] = { 'range ' }
	end
end

-- response
-- local function resp_letter(letter)
-- 	return 'Match character with letter '..letter
-- end

-- main

local function explain(regex)
	local formated_response = {}
	local response = {}

	-- loop trough full regex
	for i, elem in pairs(regex) do
		-- if is group, explain that group
		if type(elem) == 'table' then
			explain(elem)
		else
			local isClass = false

			-- check if is end/start of class and clear temp_class
			if is_class('start', elem) then
				isClass = true
				temp_class = {}
			elseif is_class('end', elem) then
				isClass = false
				temp_class = {}
			end



			-- explain class
			-- is_class function check if is not [] but only content
			-- regex[i+1] = future_letter
			local is_start_end = is_class('start', elem) and is_class('end', elem)
			if isClass == true and not is_start_end then
				explain_class(elem, regex[i+1])
			end

			-- explain current letter
			-- if is_letter(elem) then
			-- 	table.insert(response, resp_letter(elem))
			-- end
		end
	end


	tprint(response)
end


local regex = {
	'g',
	'r',
	'#class',
		'a',
		'e',
	'#end-class',
	'y'
}

explain(regex)
