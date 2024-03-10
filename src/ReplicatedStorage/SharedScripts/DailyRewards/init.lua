local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")
local CurrencyManager = loadModule("CurrencyManager")
local PlayerDataManager = RunService:IsServer() and loadModule("PlayerDataManager")

local updateDailyRewards = loadModule("updateDailyRewards")

local dailyRewardsEvent = getDataStream("DailyRewardsEvent", "RemoteEvent")

local DailyRewards = {}

-- Calculate the reward based on the current login streak you're on
function DailyRewards.calculateReward(streak)
	local dailyRewardsConfig = RoduxStore:waitForValue("gameValues", "dailyRewardsConfig")
	local streakLength = #dailyRewardsConfig.rewards
	local streakNum = streak % streakLength
	local numCycles = math.floor(streak / streakLength)

	if streakNum == 0 then 
		numCycles = math.floor((streak - 1) / streakLength)
		streakNum = streakLength
	end
	local multiplier = dailyRewardsConfig.multiplier ^ numCycles
	local reward = dailyRewardsConfig.rewards[streakNum]
	return reward.currency, math.floor(reward.amount * multiplier)
end

if RunService:IsClient() then return DailyRewards end

-- Connect this event before the start functions are ran
function DailyRewards:initiate()
	PlayerDataManager:playerAdded(DailyRewards.playerAdded)
	PlayerDataManager:addLeavingCallback(DailyRewards.playerRemoving)
end

-- Awards the reward to the player
function DailyRewards.awardReward(player, streak)
	local currency, amount = DailyRewards.calculateReward(streak)

	CurrencyManager:transact(player, currency, amount)
end

-- Create a new streak for the player, saving the previous time interval unix timestamp and the login time
function DailyRewards.newStreak(player, loginTime, timeBoundary)
	PlayerDataManager:updatePlayerData(player, updateDailyRewards, timeBoundary, loginTime, 1)
	DailyRewards.awardReward(player, 1)
end

-- Checks if we can continue the streak or reset the streak back to 1
function DailyRewards.addStreak(player, playerData, loginTime, timeBoundary, numStreaks)
	local currentTable = playerData.DailyRewards
	local newStreak = currentTable.streak + numStreaks
	
	PlayerDataManager:updatePlayerData(player, updateDailyRewards, timeBoundary, loginTime, newStreak)
	DailyRewards.awardReward(player, newStreak)
end

-- Gets the previous time boundary for the given time
function DailyRewards.getTimeBoundary(time)
	local dailyRewardsConfig = RoduxStore:waitForValue("gameValues", "dailyRewardsConfig")
	local timeDiff = time - dailyRewardsConfig.baseTime.UnixTimestamp
	local timer = dailyRewardsConfig.timer
	local numBoundaries = timeDiff / timer
	local remainder = numBoundaries - math.floor(numBoundaries)

	return time - remainder * timer
end

-- When timer is over on client, server is fired to add the streak
function DailyRewards.serverEvent(player)
	local timeNow = DateTime.now().UnixTimestamp
	local playerData = RoduxStore:waitForValue("playerData")[tostring(player.UserId)]
	if not playerData then return end

	local dailyRewardsConfig = RoduxStore:waitForValue("gameValues", "dailyRewardsConfig")
	local timeBoundary = DailyRewards.getTimeBoundary(timeNow)
	if playerData.DailyRewards and playerData.DailyRewards.streak > 0 and timeBoundary == (playerData.DailyRewards.timeBoundary + dailyRewardsConfig.timer) then
		DailyRewards.addStreak(player, playerData, timeNow, timeBoundary, 1)
	else
		-- Add this just incase the client fires the server slightly too early
		task.wait(3)
		timeBoundary = DailyRewards.getTimeBoundary(DateTime.now().UnixTimestamp)
		if playerData.DailyRewards and playerData.DailyRewards.streak > 0 and timeBoundary == (playerData.DailyRewards.timeBoundary + dailyRewardsConfig.timer) then
			DailyRewards.addStreak(player, playerData, timeNow, timeBoundary, 1)
		end
	end
end

-- When player joins, need to check the time and see if they are eligible for a reward
function DailyRewards.playerAdded(player, playerData)
	if not player:IsDescendantOf(Players) then return end

	local loginTime = DateTime.now().UnixTimestamp
	local dailyRewardsConfig = RoduxStore:waitForValue("gameValues", "dailyRewardsConfig")
	local timeBoundary = DailyRewards.getTimeBoundary(loginTime)
	local timer = dailyRewardsConfig.timer
	
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
	local playerData = RoduxStore:waitForValue("playerData")[tostring(player.UserId)]

	if playerData and playerData.DailyRewards and playerData.DailyRewards.timeBoundary ~= timeBoundary then
		local dailyRewardsConfig = RoduxStore:waitForValue("gameValues", "dailyRewardsConfig")
		local numBoundariesPassed = 0
		local prevTimeBoundary = playerData.DailyRewards.timeBoundary
		local timeDiff = timeBoundary - prevTimeBoundary
		numBoundariesPassed += math.floor(timeDiff / dailyRewardsConfig.timer)
		DailyRewards.addStreak(player, playerData, leaveTime, timeBoundary, numBoundariesPassed)
	end
end

dailyRewardsEvent.OnServerEvent:Connect(DailyRewards.serverEvent)

return DailyRewards