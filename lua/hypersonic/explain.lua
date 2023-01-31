local function explanLiteral(char)
	if char == '\\n' then
		return char.." = New line"
	elseif char == '\\r' then
		return char.." = Carriage return"
	elseif char == '\\t' then
		return char.." = Tab"
	elseif char == '\\0' then
		return char.." = Null character"
	elseif char == '\\s' then
		return char.." = Any whitespace charackter"
	elseif char == '\\S' then
		return char.." = Any non-whitespace charackter"
	elseif char == '\\d' then
		return char.." = Any digit"
	elseif char == '\\D' then
		return char.." = Any non-digit"
	elseif char == '\\w' then
		return char.." = Any word character"
	elseif char == '\\W' then
		return char.." = Any non-word character"
	end
end

return explanLiteral
