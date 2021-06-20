local Vectors = {}

-- Converts a Vector to a string in the format 'x:y' or 'x:y:Z'
function Vectors.vectorToString(vector)
    local endPart = ""
    if typeof(vector) == "Vector3" then
        endPart = ":" .. vector.z
    end

    return vector.x .. ":" .. vector.y .. endPart
end

-- Converts a string in the format 'x:y' or 'x:y:z' to a Vector
function Vectors.stringToVector(str)
    local vals = str:split(":")
    if #vals == 2 then
        return Vector2.new(tonumber(vals[1]), tonumber(vals[2]))
    elseif #vals == 3 then
        return Vector3.new(tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3]))
    end
end

-- Checks whether the given vector lies within the given bounds
function Vectors.checkWithinBounds(vector, lowerXBound, upperXBound, lowerYBound, upperYBound)
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