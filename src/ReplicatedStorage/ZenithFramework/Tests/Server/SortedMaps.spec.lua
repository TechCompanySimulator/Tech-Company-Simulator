local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local SortedMaps = loadModule("SortedMaps")

    describe("SortedMaps", function()
		it("should get a sorted map of a given name and save it in the sorted maps table", function()
			expect(function()
				SortedMaps.getSortedMap("TestMap")
			end).never.to.throw()
			expect(SortedMaps["TestMap"]).to.be.ok()
		end)

		it("should get the first unique key in the sorted map, and return it, along with if it is the first key or not", function()
			local foundKey, isFirstKey
			expect(function()
				foundKey, isFirstKey = SortedMaps.getUniqueKey(SortedMaps.getSortedMap("TestMap"))
			end).never.to.throw()
			expect(foundKey).to.equal(1)
			expect(isFirstKey).to.equal(true)
		end)

		it("should flush all of the memory out of a memory store sorted map", function()
			expect(function()
				SortedMaps.flush(SortedMaps.getSortedMap("TestMap"))
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