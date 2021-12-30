local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local SortedMaps = loadModule("SortedMaps")

	local TestMap

    describe("SortedMaps", function()
		it("should get a sorted map of a given name and save it in the sorted maps table", function()
			expect(function()
				TestMap = SortedMaps.getSortedMap("TestMap")
			end).never.to.throw()
			expect(SortedMaps["TestMap"]).to.be.ok()
		end)

		it("should get the first unique key in the sorted map, and return it, along with if it is the first key or not", function()
			local foundKey
			expect(function()
				foundKey = SortedMaps.getUniqueKey(TestMap)
			end).never.to.throw()
			expect(foundKey).to.equal(1)
		end)

		it("should create a new key in a sorted map, cancelling the update if the key already exists", function()
			local success
			expect(function()
				success = SortedMaps.createNewKey(TestMap, "TestKey", "TestValue", 100000)
			end).never.to.throw()
			expect(success).to.equal(true)
			success = SortedMaps.createNewKey(TestMap, "TestKey", "TestValue", 100000)
			expect(success).to.equal(false)
		end)

		it("should print all the keys in a given sorted map", function()
			expect(function()
				SortedMaps.printAllKeys(TestMap)
			end).never.to.throw()
		end)

		it("should flush all of the memory out of a memory store sorted map", function()
			expect(function()
				SortedMaps.flush(TestMap)
			end).never.to.throw()
			local success, items = pcall(function()
				return SortedMaps.getSortedMap("TestMap"):GetRangeAsync(Enum.SortDirection.Ascending, 100)
			end)
			if success then
				expect(#items).to.equal(0)
			end
		end)
	end)
end