local Vectors = {}

-- Converts a Vector to a string in the format 'x:y' or 'x:y:Z'
function Vectors.vectorToString(vector)
	assert(typeof(vector) == "Vector2" or typeof(vector) == "Vector3", "Vector arguments need to be a Vector2 or a Vector3")

	local endPart = ""
	if typeof(vector) == "Vector3" then
		endPart = ":" .. vector.z
	end

	return vector.x .. ":" .. vector.y .. endPart
end

-- Converts a string in the format 'x:y' or 'x:y:z' to a Vector
function Vectors.stringToVector(str)
	assert(typeof(str) == "string", "String arguments needs to be a string")

	local vals = str:split(":")
	if #vals == 2 then
		return Vector2.new(tonumber(vals[1]), tonumber(vals[2]))
	elseif #vals == 3 then
		return Vector3.new(tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3]))
	end
end

-- Checks whether the given vector lies within the given bounds (only works for Vector2 for now)
function Vectors.checkWithinBounds(vector, lowerXBound, upperXBound, lowerYBound, upperYBound)
	assert(typeof(vector) == "Vector2", "Vector argument needs to be a Vector2")
	assert(typeof(lowerXBound) == "number" 
		and typeof(upperXBound) == "number" 
		and typeof(lowerYBound) == "number" 
		and typeof(upperYBound) == "number", 
		"All bound arguments need to be numbers"
	)

	if vector.X >= lowerXBound
		and vector.X <= upperXBound
		and vector.Y >= lowerYBound
		and vector.Y <= upperYBound
	then
		return true
	end

	return false
end

return Vectors