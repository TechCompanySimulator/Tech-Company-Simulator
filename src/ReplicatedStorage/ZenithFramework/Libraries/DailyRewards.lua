local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return {} end

local require, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = require("RoduxStore")
local PlayerDataManager = require("PlayerDataManager")
local Table = require("Table")

local setPlayerData = require("setPlayerData")

local playerLeftEvent = getDataStream("PlayerLeft", "BindableEvent")

local DailyRewards = {
	timer = 86400;
	leftBools = {};
}

--[[
	POTENTIAL CHANGES:
	- Make it so that it finds the number of boundaries it has passed from a certain unix timestamp (use DateTime to make this exact so I can choose the time it resets daily)
	- Use this number of boundaries to find where the previous boundary is
	- Can then use this found boundary to work out if we are in the next boundary or not
	- Makes it easier to change it from a day to smaller or larger times
]]

-- Create a new streak for the player, saving the previous time interval unix timestamp and the login time
function DailyRewards.newStreak(player, loginTime, timeBoundary)
	local saveTable = {
		timeBoundary = timeBoundary;
		loginTime = loginTime;
		streak = 1;
	}
	RoduxStore:dispatch(setPlayerData(player.UserId, "DailyRewards", saveTable))
end

-- Checks if we can continue the streak or reset the streak back to 1
function DailyRewards.addStreak(player, playerData, loginTime, timeBoundary, numStreaks)
	local currentTable = playerData.DailyRewards
	local saveTable = Table.merge(currentTable, {
		timeBoundary = timeBoundary;
		loginTime = loginTime;
		streak = currentTable.streak + numStreaks;
	})
	RoduxStore:dispatch(setPlayerData(player.UserId, "DailyRewards", saveTable))
end

-- When player joins, need to check the time and see if they are eligible for a reward
function DailyRewards.playerAdded(player)
	local loginTime = DateTime.now()
	local universalTime = loginTime:ToUniversalTime()
	PlayerDataManager:waitForLoadedData(player)
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	local timeBoundary = DateTime.fromUniversalTime( 
		universalTime.Year, 
		universalTime.Month, 
		universalTime.Day
	).UnixTimestamp

	local loginUnix = loginTime.UnixTimestamp
	if playerData.DailyRewards and playerData.DailyRewards.streak > 0 and timeBoundary == (playerData.DailyRewards.timeBoundary + DailyRewards.timer) then
		DailyRewards.addStreak(player, playerData, loginUnix, timeBoundary, 1)
	elseif not playerData.DailyRewards 
		or not playerData.DailyRewards.streak 
		or playerData.DailyRewards.streak == 0 
		or (loginUnix > (playerData.DailyRewards.timeBoundary + DailyRewards.timer) 
			and timeBoundary ~= (playerData.DailyRewards.timeBoundary + DailyRewards.timer) 
		) 
	then
		DailyRewards.newStreak(player, loginUnix, timeBoundary)
	end
end

-- When a player leaves, need to check to see if they stayed long enough to receive more login streaks
function DailyRewards.playerRemoving(player)
	local leaveTime = DateTime.now()
	local universalTime = leaveTime:ToUniversalTime()
	local timeBoundary = DateTime.fromUniversalTime( 
		universalTime.Year, 
		universalTime.Month, 
		universalTime.Day
	).UnixTimestamp
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	if playerData.DailyRewards and playerData.DailyRewards.timeBoundary ~= timeBoundary then
		local numBoundariesPassed = 0
		while timeBoundary ~= playerData.DailyRewards.timeBoundary do
			timeBoundary += DailyRewards.timer
			numBoundariesPassed += 1
		end
		DailyRewards.addStreak(player, playerData, leaveTime.UnixTimestamp, timeBoundary, numBoundariesPassed)
	end
	PlayerDataManager.leftBools[tostring(player.UserId)] = true
	playerLeftEvent:Fire()
end

-- Run the function for any players who already loaded in before this module loaded
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(function()
		DailyRewards.playerAdded(player)
	end)
end

Players.PlayerAdded:Connect(DailyRewards.playerAdded)
Players.PlayerRemoving:Connect(DailyRewards.playerRemoving)

return DailyRewards