local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local DataStore = loadModule("DataStore")
local DefaultData = loadModule("DefaultData")
local Table = loadModule("Table")
local RoduxStore = loadModule("RoduxStore")
local CONFIG = loadModule("CONFIG")

local addPlayerSession = loadModule("addPlayerSession")
local removePlayerSession = loadModule("removePlayerSession")
local setPlayerLevel = loadModule("setPlayerLevel")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

local PlayerDataManager = {}

-- Sets up the check for when the rodux store changes to update the players data, and sets up the playerAdded/playerRemoving functions
function PlayerDataManager:initiate()
	task.spawn(function()
		for _, player in pairs(Players:GetPlayers()) do
			PlayerDataManager.PlayerAdded(player)
		end
	end)

	Players.PlayerAdded:Connect(PlayerDataManager.PlayerAdded)
	Players.PlayerRemoving:Connect(PlayerDataManager.PlayerRemoving)

	RoduxStore.changed:connect(function(newState, oldState)
		if not Table.deepCheckEquality(newState, oldState) then
			for userId, data in pairs(newState.playerData) do
				if not oldState.playerData[userId] or not Table.deepCheckEquality(oldState.playerData[userId], data) then
					DataStore.setSessionData(PlayerDataStore, "User_" .. userId, data)
				end
			end
		end
	end)
end

function PlayerDataManager:ResetData(userId)
	RoduxStore:dispatch(addPlayerSession(userId, DefaultData))
end

function PlayerDataManager.PlayerAdded(player)
	local userId = player.UserId
	local playerDataIndex = "User_" .. userId
	local playersData = DataStore.getData(PlayerDataStore, playerDataIndex, Table.clone(DefaultData))

	if (not CONFIG.RESET_PLAYER_DATA or not RunService:IsStudio()) and playersData then
		RoduxStore:dispatch(addPlayerSession(userId, playersData))
	elseif CONFIG.RESET_PLAYER_DATA and RunService:IsStudio() then
		PlayerDataManager:ResetData(userId)
	end
end

function PlayerDataManager.PlayerRemoving(player)
	local userId = player.UserId
	DataStore.removeSessionData(PlayerDataStore, "User_" .. userId, true)
	RoduxStore:dispatch(removePlayerSession(userId))
end

return PlayerDataManager