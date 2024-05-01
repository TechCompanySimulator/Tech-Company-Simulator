local Orb = {}
Orb.__index = Orb

function Orb.new()
	local self = setmetatable({}, Orb)
	
	return self
end

function Orb:destroy()
	
end

return Orb