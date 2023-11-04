local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = loadModule("makeActionCreator")

return makeActionCreator("updateDailyRewards", function(userId : number, timeBoundary : number, loginTime : number, streak : number) : table
	return {
		userId = userId;
		timeBoundary = timeBoundary;
		loginTime = loginTime;
		streak = streak;
	}
end)