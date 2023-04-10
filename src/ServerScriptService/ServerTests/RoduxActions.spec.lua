local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local Llama = loadModule("Llama")
	local RoduxStore = loadModule("RoduxStore")

	local playerId = 1

	describe("RoduxActions", function()
		it("should set a player session in the playerData table in Rodux", function()
			local setPlayerSession = loadModule("setPlayerSession")
			local data = {}

			expect(function()
				RoduxStore:dispatch(setPlayerSession(playerId, data))
			end).never.to.throw()
			expect(RoduxStore:getState().playerData[tostring(playerId)]).to.equal(data)
		end)

		it("should add an inventory item to an inventory table in the players data", function()
			local addInventoryItem = loadModule("addInventoryItem")

			local newItem = {
				name = "Hammer";
				Level = 1;
			}

			expect(function()
				RoduxStore:dispatch(addInventoryItem(playerId, "TestInventory", "Tools", newItem))
			end).never.to.throw()
			expect(RoduxStore:getState().playerData[tostring(playerId)].TestInventory.Tools).to.be.ok()
			expect(Llama.Dictionary.includes(RoduxStore:getState().playerData[tostring(playerId)].TestInventory.Tools, newItem)).to.equal(true)
		end)

		it("should change an inventory item in an inventory table in the players data", function()
			local changeInventoryItem = loadModule("changeInventoryItem")

			local itemToChange = {
				name = "Hammer";
				Level = 1;
			}
			local newItem = {
				name = "Hammer";
				Level = 2;
			}

			expect(function()
				RoduxStore:dispatch(changeInventoryItem(playerId, "TestInventory", "Tools", itemToChange, newItem))
			end).never.to.throw()
			expect(Llama.Dictionary.includes(RoduxStore:getState().playerData[tostring(playerId)].TestInventory.Tools, newItem)).to.equal(true)
		end)
	end)
end