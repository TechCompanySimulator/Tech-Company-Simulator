local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("updateDailyRewards", function(userId, timeBoundary, loginTime, streak)
	return {
		userId = userId;
		timeBoundary = timeBoundary;
		loginTime = loginTime;
		streak = streak;
	}
end)