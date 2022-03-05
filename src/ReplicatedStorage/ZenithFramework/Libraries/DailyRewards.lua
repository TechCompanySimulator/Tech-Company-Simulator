local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local require, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = require("RoduxStore")
local PlayerDataManager = require("PlayerDataManager")
local Table = require("Table")

local setPlayerData = require("setPlayerData")

local dailyRewardsEvent = getDataStream("DailyRewardsEvent", "RemoteEvent")

local playerLeftEvent 
if RunService:IsServer() then
	playerLeftEvent = getDataStream("PlayerLeft", "BindableEvent")
end

local DailyRewards = {
	baseTime = DateTime.fromUniversalTime(
		2022, 
		3, 
		1
	);
	timer = 20;
}

if RunService:IsClient() then return DailyRewards end

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

-- Gets the previous time boundary for the given time
function DailyRewards.getTimeBoundary(time)
	local timeDiff = time - DailyRewards.baseTime.UnixTimestamp
	local timer = DailyRewards.timer
	local numBoundaries = timeDiff / timer
	local remainder = numBoundaries - math.floor(numBoundaries)
	return time - remainder * timer
end

-- When timer is over on client, server is fired to add the streak
function DailyRewards.serverEvent(player)
	local timeNow = DateTime.now().UnixTimestamp
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	local timeBoundary = DailyRewards.getTimeBoundary(timeNow)
	if playerData.DailyRewards and playerData.DailyRewards.streak > 0 and timeBoundary == (playerData.DailyRewards.timeBoundary + DailyRewards.timer) then
		DailyRewards.addStreak(player, playerData, timeNow, timeBoundary, 1)
	else
		-- Add this just incase the client fires the server slightly too early
		task.wait(3)
		timeBoundary = DailyRewards.getTimeBoundary(DateTime.now().UnixTimestamp)
		if playerData.DailyRewards and playerData.DailyRewards.streak > 0 and timeBoundary == (playerData.DailyRewards.timeBoundary + DailyRewards.timer) then
			DailyRewards.addStreak(player, playerData, timeNow, timeBoundary, 1)
		end
	end
end

-- When player joins, need to check the time and see if they are eligible for a reward
function DailyRewards.playerAdded(player)
	local loginTime = DateTime.now().UnixTimestamp
	PlayerDataManager:waitForLoadedData(player)
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	local timeBoundary = DailyRewards.getTimeBoundary(loginTime)
	local timer = DailyRewards.timer
	
	if playerData.DailyRewards and playerData.DailyRewards.streak > 0 and timeBoundary == (playerData.DailyRewards.timeBoundary + timer) then
		DailyRewards.addStreak(player, playerData, loginTime, timeBoundary, 1)
	elseif not playerData.DailyRewards 
		or not playerData.DailyRewards.streak 
		or playerData.DailyRewards.streak == 0 
		or (loginTime > (playerData.DailyRewards.timeBoundary + timer) 
			and timeBoundary ~= (playerData.DailyRewards.timeBoundary + timer) 
		) 
	then
		DailyRewards.newStreak(player, loginTime, timeBoundary)
	end
end

-- When a player leaves, need to check to see if they stayed long enough to receive more login streaks
function DailyRewards.playerRemoving(player)
	local leaveTime = DateTime.now().UnixTimestamp
	local timeBoundary = DailyRewards.getTimeBoundary(leaveTime)
	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	if playerData.DailyRewards and playerData.DailyRewards.timeBoundary ~= timeBoundary then
		local numBoundariesPassed = 0
		local prevTimeBoundary = playerData.DailyRewards.timeBoundary
		local timeDiff = timeBoundary - prevTimeBoundary
		numBoundariesPassed += math.floor(timeDiff / DailyRewards.timer)
		DailyRewards.addStreak(player, playerData, leaveTime, timeBoundary, numBoundariesPassed)
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

dailyRewardsEvent.OnServerEvent:Connect(DailyRewards.serverEvent)
Players.PlayerAdded:Connect(DailyRewards.playerAdded)
Players.PlayerRemoving:Connect(DailyRewards.playerRemoving)

return DailyRewards