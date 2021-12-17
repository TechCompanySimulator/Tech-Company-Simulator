-- Useful string manipulation functions
-- Author: TheM0rt0nator

local String = {}

-- Removes all white space in a string
function String.removeSpaces(str)
	assert(typeof(str) == "string", "Argument needs to be a string")

	local newString, numSpaces = string.gsub(str, "(%s)%s*", "")

	return newString
end

-- Removes all punctation in a string, uncluding special characters like @
function String.removePunc(str)
	assert(typeof(str) == "string", "Argument needs to be a string")

	local newString, numRemovals = string.gsub(str, "%p", "")

	return newString
end

-- Returns a table of start and end indexes of a pattern within a string
function String.getStringMatches(str, pattern)
	assert(typeof(str) == "string" and typeof(pattern) == "string", "Arguments need to be a strings")

	local found = 0
	local positions = {}
	while(found)do
		found += 1
		found = str:find(pattern, found)
		table.insert(positions, found)
	end

	return positions
end

-- Makes the first letter of a string lowercase
function String.lowerFirstLetter(str)
	assert(typeof(str) == "string", "Argument needs to be a string")

	return string.lower(str:sub(1, 1)) .. str:sub(2)
end

-- Makes the first letter of a string uppercase
function String.upperFirstLetter(str)
	assert(typeof(str) == "string", "Argument needs to be a string")

	return string.upper(str:sub(1, 1)) .. str:sub(2)
end

return String