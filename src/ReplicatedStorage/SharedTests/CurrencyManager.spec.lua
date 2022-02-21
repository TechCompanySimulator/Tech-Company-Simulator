local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local CurrencyManager = loadModule("CurrencyManager")
	local RoduxStore = loadModule("RoduxStore")

	local player = if RunService:IsClient() then Players.LocalPlayer else Players:GetPlayers()[1]
	if not player then
		while not Players:GetPlayers()[1] do
			task.wait()
		end
		player = Players:GetPlayers()[1]
	end

    describe("CurrencyManager", function()
		it("should transact an amount of currency for the player", function()
			if RunService:IsClient() then
				local test1 = CurrencyManager:transact(player, "Coins", 100)
				expect(test1).never.to.be.ok()
			else
				local test1 = CurrencyManager:transact(player, "Coins", -100)
				expect(test1).never.to.be.ok()

				local test2 = CurrencyManager:transact(player, "Coins", 100)
				expect(test2).to.equal(true)

				local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
				expect(playerData.Coins).to.equal(100)

				local test3 = CurrencyManager:transact(player, "Coins", -10)

				expect(test3).to.equal(true)
				playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
				expect(playerData.Coins).to.equal(90)

				local test4 = CurrencyManager:transact(player, "Fail", -10)
				expect(test4).never.to.be.ok()
			end
		end)

		it("should return the amount of given currency the player has in their data", function()
			local test1 = CurrencyManager.getCurrencyAmount(player, "Coins")
			expect(test1).to.equal(90)
			local test2 = CurrencyManager.getCurrencyAmount(player, "Fail")
			expect(test2).to.equal(nil)
		end)

		it("should return whether the player has enough of the given currency or not", function()
			local test1 = CurrencyManager.hasEnoughCurrency(player, "Coins", -100)
			expect(test1).to.equal(false)
			local test2 = CurrencyManager.hasEnoughCurrency(player, "Coins", 100)
			expect(test2).to.equal(false)

			local test3 = CurrencyManager.hasEnoughCurrency(player, "Coins", -90)
			expect(test3).to.equal(true)
			local test4 = CurrencyManager.hasEnoughCurrency(player, "Coins", 90)
			expect(test4).to.equal(true)

			expect(function()
				CurrencyManager.hasEnoughCurrency(player, "Coins", "Fail")
			end).to.throw()
		end)
	end)
end