local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local NPC = require(script.Parent.Parent)

local PostOfficeNPC = {}
PostOfficeNPC.__index = PostOfficeNPC
setmetatable(PostOfficeNPC, NPC)

function PostOfficeNPC.new()
	local newNPC = NPC.new()
	local self = setmetatable(newNPC, PostOfficeNPC)

	return self
end

return PostOfficeNPC