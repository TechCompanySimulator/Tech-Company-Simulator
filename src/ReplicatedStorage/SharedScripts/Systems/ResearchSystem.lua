local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local PlayerDataManager = loadModule("PlayerDataManager")
local RoduxStore = loadModule("RoduxStore")

local ResearchSystem = {}

function ResearchSystem.getPlayerLevel(player : Player, machineType : string) : (number, table)
	local playerData = RoduxStore:waitForValue("playerData")[tostring(player.UserId)]
	if not playerData then return end

	local researchLevels = Llama.Dictionary.map(playerData.ResearchLevels, function(researchData, index)
		return researchData, string.lower(index)
	end)

	local playerLevel = researchLevels[string.lower(machineType)]

	return playerLevel.Level, playerLevel.Progress
end


-- TODO: Set Player Level


return ResearchSystem