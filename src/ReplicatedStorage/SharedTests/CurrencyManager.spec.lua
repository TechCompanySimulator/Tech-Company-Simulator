local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local CurrencyManager = loadModule("CurrencyManager")

	local player = if RunService:IsClient() then Players.LocalPlayer else Players:GetPlayers()[1]
	if not player then
		while not Players:GetPlayers()[1] do
			task.wait()
		end
		player = Players:GetPlayers()[1]
	end

    describe("CurrencyManager", function()
		it("should transact an amount of currency for the player", function()
			
		end)
	end)
end