-- remove later
print("init.lua has loaded")

local function splitLetter(str)
	local letters = {}

	for i = 1, #str do
		local letter = string.sub(str, i, i)
	   table.insert(letters, letter)
	end

	return letters
end

local function split(str)
	local groups = {}
	local charClass = {}
	local charLiteral = {}
	local char= {}

	-- groups
	-- regex = get content from ()
	for group in string.gmatch(str, '%(([^%(%)]+)%)') do
		table.insert(groups, group)
	end

	-- char class
	-- regex = get content from []
	for class in string.gmatch(str, '%[([^%[%]]+)%]') do
		table.insert(groups, class)
	end

	-- char literal
	for i = 1, #splitLetter(str) do
		local letter = splitLetter(str)[i]

		if letter == "\\" then
			local newLetter = "\\"..splitLetter(str)[i+1]
			i = i+1
			table.insert(charLiteral, newLetter)
		elseif letter ~= '\\' and i > 1 and splitLetter(str)[i-1] ~= '\\' then
			table.insert(charLiteral, letter)
		end
	end

	-- char
	for i = 1, #splitLetter(str) do
		local prevLetter = splitLetter(str)[i-1]
		local letter = splitLetter(str)[i]

		local isChar = string.match(letter, '[a-zA-Z]')
		local isNotLiteral = letter ~= '\\' and i > 1 and prevLetter ~= '\\'
		local function prevNotSpecial() if prevLetter ~= '^' and prevLetter ~= '$' and prevLetter then return true else return false end end

		if isNotLiteral and prevNotSpecial() and isChar then
			table.insert(char, letter)
		end
	end


	return {
		groups, char, charClass, charLiteral
	}
end

local function content()
	local currentLine = vim.fn.getline('.')

	-- match every characters between /
	local regexPatern = '/(.*)/'
	local strStartI, strEndI = string.find(currentLine, regexPatern)

	if strStartI and strEndI then
		local selectedRegex = string.sub(currentLine, strStartI+1, strEndI-1)

		print(selectedRegex)
		return selectedRegex
	else
		-- remove later
		print("You are not matching any regex")
		return ''
	end
end

local function explain()
	local regex = content()
	local groups = split(regex)

	-- explain char literal
	for _, value in pairs(groups[2]) do
		print(value)
	end
end

return {
	explain = explain,
	content = content
}
