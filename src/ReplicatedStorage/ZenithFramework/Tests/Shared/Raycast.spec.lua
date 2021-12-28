local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local Raycast = loadModule("Raycast")

	describe("Raycast", function()
		it("should raycast and detect a part correctly", function()
			local testPart = Instance.new("Part", workspace)
			testPart.Anchored = true
			testPart.Position = Vector3.new(0, 20, 0)
			testPart.Size = Vector3.new(10, 10, 1)
			local filterInstances = {testPart}

			local raycastResult
			expect(function()
				raycastResult = Raycast.new(filterInstances, "Whitelist", Vector3.new(0, 20, 5), Vector3.new(0, 0, -1), 5)
			end).never.to.throw()
			expect(raycastResult).to.be.ok()
			expect(raycastResult.Instance).to.equal(testPart)
			raycastResult = Raycast.new(filterInstances, "Whitelist", Vector3.new(0, 20, 6), Vector3.new(0, 0, -1), 5)
			expect(raycastResult).never.to.be.ok()
			raycastResult = Raycast.new(filterInstances, "Whitelist", Vector3.new(0, 20, 5), Vector3.new(0, 0, -1), 4)
			expect(raycastResult).never.to.be.ok()
			raycastResult = Raycast.new(filterInstances, "Whitelist", Vector3.new(0, 20, 0), Vector3.new(0, 0, -1), 4)
			expect(raycastResult).never.to.be.ok()
			expect(function()
				Raycast.new(5, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.new(filterInstances, 5, Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.new(filterInstances, "Whitelist", "Fail", Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.new(filterInstances, "Whitelist", Vector3.new(0, 0, 5), "Fail", 5)
			end).to.throw()
			expect(function()
				Raycast.new(filterInstances, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), "Fail")
			end).to.throw()

			testPart:Destroy()
		end)

		it("should return a table of all the hit parts from a raycast", function()
			local filterInstances = {}
			local parts = {}
			for i = 1, 5 do
				local testPart = Instance.new("Part", workspace)
				testPart.Anchored = true
				testPart.Position = Vector3.new(0, 20, (i - 1) * 3)
				testPart.Size = Vector3.new(10, 10, 1)
				table.insert(filterInstances, testPart)
				table.insert(parts, testPart)
			end

			local raycastResults
			expect(function()
				raycastResults = Raycast.getAllHitParts(filterInstances, "Whitelist", Vector3.new(0, 20, -2), Vector3.new(0, 0, 1), 20)
			end).never.to.throw()
			expect(#raycastResults).to.equal(5)
			for _, part in pairs(parts) do
				expect(table.find(raycastResults, part)).to.be.ok()
			end
			raycastResults = Raycast.getAllHitParts(filterInstances, "Whitelist", Vector3.new(0, 20, -2), Vector3.new(0, 0, 1), 12)
			expect(#raycastResults).to.equal(4)
			expect(function()
				Raycast.getAllHitParts(5, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitParts(filterInstances, 5, Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitParts(filterInstances, "Whitelist", "Fail", Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitParts(filterInstances, "Whitelist", Vector3.new(0, 0, 5), "Fail", 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitParts(filterInstances, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), "Fail")
			end).to.throw()

			for _, part in pairs(parts) do
				part:Destroy()
			end
		end)

		it("should return the first model hit by the raycast", function()
			local filterInstances = {}
			local newModel = Instance.new("Model", workspace)
			for i = 1, 5 do
				local testPart = Instance.new("Part", newModel)
				testPart.Anchored = true
				testPart.Position = Vector3.new(0, 20, (i - 1) * 3)
				testPart.Size = Vector3.new(10, 10, 1)
				table.insert(filterInstances, testPart)
			end

			local hitModel
			expect(function()
				hitModel = Raycast.getFirstHitModel(filterInstances, "Whitelist", Vector3.new(0, 20, -2), Vector3.new(0, 0, 1), 20)
			end).never.to.throw()
			expect(hitModel).to.equal(newModel)
			expect(function()
				Raycast.getFirstHitModel(5, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getFirstHitModel(filterInstances, 5, Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getFirstHitModel(filterInstances, "Whitelist", "Fail", Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getFirstHitModel(filterInstances, "Whitelist", Vector3.new(0, 0, 5), "Fail", 5)
			end).to.throw()
			expect(function()
				Raycast.getFirstHitModel(filterInstances, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), "Fail")
			end).to.throw()

			newModel:Destroy()
		end)

		it("should return a table of all of the models hit by the raycast", function()
			local filterInstances = {}
			local models = {}
			for i = 1, 5 do
				local newModel = Instance.new("Model", workspace)
				local testPart = Instance.new("Part", newModel)
				testPart.Anchored = true
				testPart.Position = Vector3.new(0, 20, (i - 1) * 3)
				testPart.Size = Vector3.new(10, 10, 1)
				table.insert(filterInstances, testPart)
				table.insert(models, newModel)
			end

			local hitModels
			expect(function()
				hitModels = Raycast.getAllHitModels(filterInstances, "Whitelist", Vector3.new(0, 20, -2), Vector3.new(0, 0, 1), 20)
			end).never.to.throw()
			for _, model in pairs(hitModels) do
				expect(table.find(models, model)).to.be.ok()
			end
			expect(function()
				Raycast.getAllHitModels(5, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitModels(filterInstances, 5, Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitModels(filterInstances, "Whitelist", "Fail", Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitModels(filterInstances, "Whitelist", Vector3.new(0, 0, 5), "Fail", 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitModels(filterInstances, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), "Fail")
			end).to.throw()

			for _, model in pairs(models) do
				model:Destroy()
			end
		end)

		it("should return a table of all of the players hit by a raycast", function()
			local filterInstances = {}
			expect(function()
				Raycast.getAllHitPlayers(filterInstances, "Whitelist", Vector3.new(0, 20, -2), Vector3.new(0, 0, 1), 20)
			end).never.to.throw()
			expect(function()
				Raycast.getAllHitPlayers(5, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitPlayers(filterInstances, 5, Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitPlayers(filterInstances, "Whitelist", "Fail", Vector3.new(0, 0, -1), 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitPlayers(filterInstances, "Whitelist", Vector3.new(0, 0, 5), "Fail", 5)
			end).to.throw()
			expect(function()
				Raycast.getAllHitPlayers(filterInstances, "Whitelist", Vector3.new(0, 0, 5), Vector3.new(0, 0, -1), "Fail")
			end).to.throw()
		end)

		it("should show a raycast as a part and return this part", function()
			local rayPart
			expect(function()
				rayPart = Raycast.showRayAsPart(Vector3.new(0, 20, 5), Vector3.new(0, 0, -1), 20, workspace)
			end).never.to.throw()
			expect(rayPart).to.be.ok()

			rayPart:Destroy()
		end)
	end)
end