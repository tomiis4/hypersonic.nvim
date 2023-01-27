print("init.lua has loaded")


local function help()
	print("help func")
end

local function content()
	local currentLine = vim.fn.getline('.')

	-- match every characters between ",',(, [, {
	local regexPatern = "[\"\'%[%]](.-)[\"\'%[%]]"

	local strStartI, strEndI = string.find(currentLine, regexPatern)

	if strStartI and strEndI then
		-- +- 1 to remove ",(...
		local selected_text = string.sub(currentLine, strStartI+1, strEndI-1)

		print(selected_text)
	else 
		print("You are not matching any regex")
	end
end

return {
	-- help = help
	content = content 
}
