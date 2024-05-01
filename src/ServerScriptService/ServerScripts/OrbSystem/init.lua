local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local addOrb = loadModule("addOrb")
local removeOrb = loadModule("removeOrb")
local updateOrb = loadModule("updateOrb")
local removePlayerOrbs = loadModule("removePlayerOrbs")

local OrbSystem = {}

function OrbSystem.initiate()
	Players.PlayerRemoving:Connect(OrbSystem.playerRemoving)
end

function OrbSystem.spawnOrb(player)
	RoduxStore:dispatch(addOrb(player.UserId))
end

function OrbSystem.despawnOrb(player, orbId)
	RoduxStore:dispatch(removeOrb(player.UserId, orbId))
end

function OrbSystem.playerRemoving(player)
	RoduxStore:dispatch(removePlayerOrbs(player.UserId))
end

return OrbSystem