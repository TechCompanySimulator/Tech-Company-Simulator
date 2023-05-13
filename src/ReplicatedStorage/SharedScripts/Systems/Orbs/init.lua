local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local InventoryManager = loadModule("InventoryManager")

local Orbs = {}

-- Gives the player an orb with the given name, level and XP
function Orbs:giveOrb(player, orbId, orbLevel, orbXP)
	if RunService:IsClient() then return end
	local gameValues = RoduxStore:waitForValue("gameValues")
	local orbValues = gameValues.orbs
	if not orbValues[orbId] then
		warn("Invalid orb ID")
		return false
	end
	InventoryManager.addItem(player.UserId, "Inventory", "Orbs", {
		id = orbId;
		level = orbLevel or 1;
		xp = orbXP or 0;
	})
end

-- Returns a table containing the boosts the given orb has
function Orbs.getOrbBoosts(orbId)
	local gameValues = RoduxStore:waitForValue("gameValues")
	local orbValues = gameValues.orbs
	if orbValues and orbValues[orbId] then
		return orbValues[orbId].boosts
	end
end

return Orbs

