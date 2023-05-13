local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local InventoryManager = loadModule("InventoryManager")
	local RoduxStore = loadModule("RoduxStore")

	local isServer = RunService:IsServer()

	-- Wait for a player to join and set up players inventory data
	local player = RunService:IsClient() and Players.LocalPlayer
	if not player then
		while not Players:GetPlayers()[1] do
			task.wait(0.1)
		end
		player = Players:GetPlayers()[1]
	end

	local userId = player.UserId
	local invName = "Inventory"

	RoduxStore:waitForValue("playerData", tostring(userId), invName)

	local playerData = RoduxStore:waitForValue("playerData", tostring(userId))
	local playersInventory

	describe("InventoryManager", function()
		it("should return the players inventory data", function()
			expect(function()
				playersInventory = InventoryManager.getInventory(userId, invName)
			end).never.to.throw()
			expect(playersInventory).to.be.ok()
			if RunService:IsClient() then
				while not InventoryManager.hasItem(userId, invName, "Tools", {
					name = "Hammer";
					level = 1;
				}) do
					print("Waiting")
					task.wait(0.1)
				end
			end
		end)

		if isServer then
			it("should add items to the players inventory", function()
				expect(function()
					InventoryManager.addItem(userId, invName, "Tools", {
						name = "Hammer";
						level = 1;
					})
				end).never.to.throw()
			end)
		end

		it("should get the content size of the inventory", function()
			local contentSize
			expect(function()
				contentSize = InventoryManager.getContentSize(userId, invName)
			end).never.to.throw()
			expect(contentSize).to.equal(1)
		end)

		it("should get the capacity of the players inventory", function()
			local capacity
			expect(function()
				capacity = InventoryManager.getCapacity(userId, invName)
			end).never.to.throw()
			expect(capacity).to.equal(playerData.InventoryCapacity or 5)
		end)

		it("should return whether the players inventory is full or not", function()
			local isFull
			expect(function()
				isFull = InventoryManager.isInventoryFull(userId, invName)
			end).never.to.throw()
			expect(isFull).to.equal(false)
		end)

		it("should return whether the player has the given item in their inventory or not", function()
			local hasItem
			expect(function()
				hasItem = InventoryManager.hasItem(userId, invName, "Tools", {
					name = "Hammer";
					level = 1;
				})
			end).never.to.throw()

			expect(hasItem).to.equal(true)

			expect(InventoryManager.hasItem(userId, invName, "Tools", {
				name = "Hammer";
				level = 2;
			})).to.equal(false)

			expect(function()
				InventoryManager.hasItem(userId, invName, {}, {})
			end).to.throw()

			expect(function()
				InventoryManager.hasItem(userId, invName, "Tools", "Fail")
			end).to.throw()
		end)

		it("should return the number of the given item the player has in their inventory", function()
			local numItems
			expect(function()
				numItems = InventoryManager.getItemCount(userId, invName, "Tools", {
					name = "Hammer";
					level = 1;
				})
			end).never.to.throw()
			expect(numItems).to.equal(1)
			expect(InventoryManager.getItemCount(userId, invName, "Tools", {
				name = "Hammer";
				level = 2;
			})).to.equal(0)
			expect(function()
				InventoryManager.getItemCount(userId, invName, {}, {})
			end).to.throw()
			expect(function()
				InventoryManager.getItemCount(userId, invName, "Tools", "Fail")
			end).to.throw()
		end)

		if isServer then
			it("should change an items data in the players inventory", function()
				expect(function()
					InventoryManager.replaceItem(userId, invName, "Tools", {
						name = "Hammer";
						level = 1;
					}, {
						name = "Hammer";
						level = 2;
					})
				end).never.to.throw()
				expect(InventoryManager.hasItem(userId, invName, "Tools", {
					name = "Hammer";
					level = 1;
				})).to.equal(false)
				expect(InventoryManager.hasItem(userId, invName, "Tools", {
					name = "Hammer";
					level = 2;
				})).to.equal(true)
			end)

			it("should remove an item from the players inventory", function()
				expect(function()
					InventoryManager.removeItem(userId, invName, "Tools", {
						name = "Hammer";
						level = 2;
					})
				end).never.to.throw()
				expect(InventoryManager.hasItem(userId, invName, "Tools", {
					name = "Hammer";
					level = 2;
				})).to.equal(false)
				if not InventoryManager.hasItem(userId, invName, "Tools", {
					name = "Hammer";
					level = 1;
				}) then
					InventoryManager.addItem(userId, invName, "Tools", {
						name = "Hammer";
						level = 1;
					})
				end
			end)
		end
	end)
end