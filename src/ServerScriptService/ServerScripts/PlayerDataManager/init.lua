local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local DataStore = loadModule("DataStore")
local DefaultData = loadModule("DefaultData")
local Llama = loadModule("Llama")
local RoduxStore = loadModule("RoduxStore")
local CONFIG = loadModule("CONFIG")

local setPlayerSession = loadModule("setPlayerSession")

local playerLeftEvent = getDataStream("PlayerLeft", "BindableEvent")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

local PlayerDataManager = {
	loadedData = {};
	leftBools = {};
}

-- Sets up the check for when the rodux store changes to update the players data, and sets up the playerAdded/playerRemoving functions
function PlayerDataManager:initiate()
	task.spawn(function()
		for _, player in pairs(Players:GetPlayers()) do
			PlayerDataManager.playerAdded(player)
		end
	end)

	Players.PlayerAdded:Connect(PlayerDataManager.playerAdded)
	Players.PlayerRemoving:Connect(PlayerDataManager.playerRemoving)

	RoduxStore.changed:connect(function(newState, oldState)
		if not Llama.deepCheckEquality(newState, oldState) then
			for userId, data in pairs(newState.playerData) do
				if not oldState.playerData[userId] or not Llama.deepCheckEquality(oldState.playerData[userId], data) then
					DataStore.setSessionData(PlayerDataStore, "User_" .. userId, data)
				end
			end
		end
	end)
end

function PlayerDataManager:resetData(userId)
	RoduxStore:dispatch(setPlayerSession(userId, DefaultData))
end

-- Yields until the players data has been sorted
function PlayerDataManager:waitForLoadedData(player)
	while not PlayerDataManager.loadedData[tostring(player.UserId)] do
		task.wait()
	end
end

function PlayerDataManager.playerAdded(player)
	local userId = player.UserId
	local playerDataIndex = "User_" .. userId
	local playersData = DataStore.getData(PlayerDataStore, playerDataIndex, Llama.Dictionary.copyDeep(DefaultData))

	if (not CONFIG.RESET_PLAYER_DATA or not RunService:IsStudio()) and playersData then
		RoduxStore:dispatch(setPlayerSession(userId, playersData))
	elseif CONFIG.RESET_PLAYER_DATA and RunService:IsStudio() then
		PlayerDataManager:resetData(userId)
	end
	RoduxStore:waitForValue("playerData", tostring(player.UserId))
	PlayerDataManager.loadedData[tostring(player.UserId)] = true
end

function PlayerDataManager.playerRemoving(player)
	if not PlayerDataManager.leftBools[tostring(player.UserId)] then
		playerLeftEvent.Event:Wait()
	end
	local userId = player.UserId

	DataStore.removeSessionData(PlayerDataStore, "User_" .. userId, true)
	RoduxStore:dispatch(setPlayerSession(userId, Llama.None))
	PlayerDataManager.loadedData[tostring(player.UserId)] = nil
	PlayerDataManager.leftBools[tostring(player.UserId)] = nil
end

return PlayerDataManager