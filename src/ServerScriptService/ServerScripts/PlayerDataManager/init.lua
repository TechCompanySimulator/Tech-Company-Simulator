local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local DataStore = require("DataStore")
local DefaultData = require("DefaultData")
local Table = require("Table")
local RoduxStore = require("RoduxStore")

local addPlayerSession = require("addPlayerSession")
local removePlayerSession = require("removePlayerSession")
local setPlayerLevel = require("setPlayerLevel")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

local PlayerDataManager = {}

function PlayerDataManager.PlayerAdded(player)
	local userId = player.UserId
	local playerDataIndex = "User_" .. userId
	local playersData = DataStore.getData(PlayerDataStore, playerDataIndex, Table.clone(DefaultData))

	if playersData then
		RoduxStore:dispatch(addPlayerSession(userId, playersData))
	end
end

function PlayerDataManager.PlayerRemoving(player)
	local userId = player.UserId
	DataStore.removeSessionData(PlayerDataStore, "User_" .. userId, true)
	RoduxStore:dispatch(removePlayerSession(userId))
end

task.spawn(function()
	for _, player in pairs(Players:GetPlayers()) do
		PlayerDataManager.PlayerAdded(player)
	end
end)

Players.PlayerAdded:Connect(PlayerDataManager.PlayerAdded)
Players.PlayerRemoving:Connect(PlayerDataManager.PlayerRemoving)

RoduxStore.changed:connect(function(newState, oldState) 
	if not Table.deepCheckEquality(newState, oldState) then
		print("New state: " , newState)
		for userId, data in pairs(newState.playerData) do
			if not oldState.playerData[userId] or not Table.deepCheckEquality(oldState.playerData[userId], data) then
				DataStore.setSessionData(PlayerDataStore, "User_" .. userId, data)
			end
		end
	end
end)

return PlayerDataManager