local NPC = {}
NPC.__index = NPC

function NPC.new()
	local self = setmetatable({}, NPC)

	return self
end

function NPC:loadAnimations()

end

function NPC:destroy()

end

return NPC