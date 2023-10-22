local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local DefaultData = loadModule("DefaultData")
local Llama = loadModule("Llama")
local RoduxStore = loadModule("RoduxStore")
-- local PlayerOrderedDataManager = loadModule("PlayerOrderedDataManager")
local ProfileService = loadModule("ProfileService")
local CONFIG = loadModule("CONFIG")
local setPlayerSession = loadModule("setPlayerSession")

local playerDataLoaded = getDataStream("playerDataLoaded", "BindableEvent")

local profiles = {}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData",
	DefaultData
)

local PlayerDataManager = {
	leavingCallbacks = {};
}

-- Sets up the playerAdded function for all players already in the game and for new players
function PlayerDataManager:start() : nil
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerDataManager.playerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerDataManager.playerAdded)
	Players.PlayerRemoving:Connect(PlayerDataManager.playerRemoving)

	--PlayerOrderedDataManager:init(PlayerDataManager.TOTAL_LEAVING_FUNCS)
end

-- Dispatches the new data to rodux for UI changes and then updates the data store directly
function PlayerDataManager:updatePlayerData(userId : number, action, ...) : boolean
	RoduxStore:dispatch(action(userId, ...))

	local newData = RoduxStore:waitForValue("playerData")[tostring(userId)]
	local player = Players:GetPlayerByUserId(userId)

	if not newData or not player or not profiles[player] then return false end

	profiles[player].Data = newData

	return true
end

function PlayerDataManager:resetData(userId : number) : nil
	PlayerDataManager:updatePlayerData(userId, setPlayerSession, DefaultData)
end

function PlayerDataManager:addLeavingCallback(callback : (Player) -> nil) : string
	local guid = HttpService:GenerateGUID(false)
	PlayerDataManager.leavingCallbacks[guid] = callback

	return guid
end

function PlayerDataManager:removeLeavingCallback(guid : string) : nil
	PlayerDataManager.leavingCallbacks[guid] = nil
end

function PlayerDataManager.playerAdded(player : Player) : nil
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile then
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

		if player:IsDescendantOf(Players) then
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

function PlayerDataManager.playerRemoving(player : Player) : nil
	local callbacksCompleted = Llama.Dictionary.map(PlayerDataManager.leavingCallbacks, function()
		return false
	end)

	-- Run all callbacks that have been connected to the player leaving event
	for guid, callback in PlayerDataManager.leavingCallbacks do
		task.spawn(function() : nil
			local success, err = pcall(callback, player)

			if not success then
				warn(err)
			end

			callbacksCompleted[guid] = nil
		end)
	end

	-- Wait for all callbacks to be completed
	while next(callbacksCompleted) ~= nil do
		task.wait(0.1)
	end

	local profile = profiles[player]

	if profile then
		profile:Release()
	end

	-- Remove data from Rodux store
	RoduxStore:dispatch(setPlayerSession(player.UserId, Llama.None))
end

return PlayerDataManager