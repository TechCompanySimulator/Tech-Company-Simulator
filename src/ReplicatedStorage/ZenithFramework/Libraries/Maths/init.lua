local Maths = {}

-- Linear interpolation
function Maths.lerp(start, goal, alpha)
	return start + (goal - start) * alpha
end

return Maths