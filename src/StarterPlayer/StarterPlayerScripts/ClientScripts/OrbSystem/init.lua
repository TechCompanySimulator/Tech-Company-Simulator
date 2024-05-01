local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local OrbSystem = {}

function OrbSystem:initiate()
	for _, orb in RoduxStore:getState().orbs do
		OrbSystem.spawnOrb(orb)
	end

	
end

function OrbSystem.spawnOrb()

end

return OrbSystem