local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local InventoryManager = loadModule("InventoryManager")
	local RoduxStore = loadModule("RoduxStore")

	local testStream = getDataStream("TestStream", "RemoteEvent")

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

	local playerData = RoduxStore:waitForValue("playerData", tostring(userId))
	local playersInventory

	local currentTest = 0
	if RunService:IsServer() then
		testStream.OnServerEvent:Connect(function()
			currentTest += 1
		end)
	else
		testStream.OnClientEvent:Connect(function()
			currentTest += 1
		end)
	end

	describe("InventoryManager", function()
		it("should return the players inventory data", function()
			expect(function()
				playersInventory = InventoryManager.getInventory(userId, invName)
			end).never.to.throw()
			expect(playersInventory).to.be.ok()
			if RunService:IsClient() then
				while currentTest == 0 do
					task.wait()
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

				testStream:FireClient(player)

				while currentTest == 0 do
					task.wait()
				end
			end)
		end

		it("should get the content size of the inventory", function()
			local contentSize
			expect(function()
				contentSize = InventoryManager.getContentSize(userId, invName, "Tools")
			end).never.to.throw()
			expect(contentSize).to.equal(1)
		end)

		it("should get the capacity of the players inventory", function()
			local capacity
			expect(function()
				capacity = InventoryManager.getCapacity(userId, invName, "Tools")
			end).never.to.throw()
			expect(capacity).to.equal(playerData.Inventory.Capacities.Tools)
		end)

		it("should return whether the players inventory is full or not", function()
			local isFull
			expect(function()
				isFull = InventoryManager.isInventoryFull(userId, invName, "Tools")
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

			if RunService:IsClient() then
				testStream:FireServer()
			end
		end)

		if isServer then
			it("should change an items data in the players inventory", function()
				expect(function()
					InventoryManager.updateItem(userId, invName, "Tools", "key_1", {
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
					InventoryManager.removeItem(userId, invName, "Tools", "key_1")
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