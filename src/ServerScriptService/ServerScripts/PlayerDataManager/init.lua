local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local DefaultData = loadModule("DefaultData")
local Table = loadModule("Table")
local RoduxStore = loadModule("RoduxStore")
local CONFIG = loadModule("CONFIG")
-- local PlayerOrderedDataManager = loadModule("PlayerOrderedDataManager")
local ProfileService = loadModule("ProfileService")

local setPlayerSession = loadModule("setPlayerSession")

local playerDataLoaded = getDataStream("playerDataLoaded", "BindableEvent")

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData",
	DefaultData
)

local PlayerDataManager = {
	leftBools = {};
}

PlayerDataManager.TOTAL_LEAVING_FUNCS = 2

local profiles = {}

-- Sets up the playerAdded function for all players already in the game and for new players
function PlayerDataManager:start()
	for _, player in pairs(Players:GetPlayers()) do
		task.spawn(PlayerDataManager.playerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerDataManager.playerAdded)
	Players.PlayerRemoving:Connect(PlayerDataManager.playerRemoving)

	--PlayerOrderedDataManager:init(PlayerDataManager.TOTAL_LEAVING_FUNCS)
end

-- Dispatches the new data to rodux for UI changes and then updates the data store directly
function PlayerDataManager:updatePlayerData(userId, action, ...)
	RoduxStore:dispatch(action(userId, ...))
	local newData = RoduxStore:getState().playerData[tostring(userId)]
	local player = Players:GetPlayerByUserId(userId)
	if not newData or not player or not profiles[player] then return end

	profiles[player].Data = newData
end

function PlayerDataManager:resetData(userId)
	PlayerDataManager:updatePlayerData(userId, setPlayerSession, DefaultData)
end

function PlayerDataManager.playerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		-- Reset data for testing if enabled
		if CONFIG.RESET_PLAYER_DATA and RunService:IsStudio() then 
			profile.Data = DefaultData
		end

		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			profiles[player] = profile
			-- A profile has been successfully loaded
			RoduxStore:dispatch(setPlayerSession(player.UserId, profile.Data))

			-- Fire a bindable event to let the server know that the player has loaded successfully and we can run any data-dependant functions
			playerDataLoaded:Fire(player)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		-- Roblox servers trying to load this profile at the same time:
		player:Kick() 
	end
end

function PlayerDataManager.playerRemoving(player)
	-- Here we wait for all the other leaving functions which effect data to be completed before removing the players data from rodux and saving it
	if not PlayerDataManager.leftBools[tostring(player.UserId)] or PlayerDataManager.leftBools[tostring(player.UserId)] < PlayerDataManager.TOTAL_LEAVING_FUNCS then
		while not PlayerDataManager.leftBools[tostring(player.UserId)] or PlayerDataManager.leftBools[tostring(player.UserId)] < PlayerDataManager.TOTAL_LEAVING_FUNCS do
			task.wait(0.1)
		end
	end

	local profile = profiles[player]
	if profile ~= nil then
		profile:Release()
	end

	-- Remove data from Rodux store
	RoduxStore:dispatch(setPlayerSession(player.UserId, Table.None))

	PlayerDataManager.leftBools[tostring(player.UserId)] = nil
end

return PlayerDataManager