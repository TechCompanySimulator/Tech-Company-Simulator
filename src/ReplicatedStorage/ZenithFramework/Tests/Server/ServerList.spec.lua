local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local ServerList = loadModule("ServerList")
	local SortedMaps = loadModule("SortedMaps")
	local TestMap = SortedMaps.getSortedMap("ServerListTestMap")

	SortedMaps.flush(TestMap)

    describe("ServerList", function()
		it("should create a unique server list key by inputting a number and outputting a string with the correct amount of significant figures", function()
			local stringKey
			expect(function()
				stringKey = ServerList.createServerKeyString(1)
			end).never.to.throw()
			expect(stringKey).to.equal("000001")
			expect(function()
				ServerList.createServerKeyString("Fail")
			end).to.throw()
		end)

		-- Commented this out because it takes a while to append 500 servers
		--[[it("should append a server to the server list correctly with a correct unique key", function()
			expect(function()
				ServerList:appendServer(TestMap)
			end).never.to.throw()
			expect(TestMap:GetAsync("000001")).to.be.ok()
			for _ = 1, 499 do
				ServerList:appendServer(TestMap)
			end
			expect(TestMap:GetAsync("000500")).to.be.ok()
		end)]]

		it("should remove a server from the server list correctly", function()
			ServerList:appendServer(TestMap)
			expect(function()
				ServerList:removeServer(TestMap)
			end).never.to.throw()
			expect(TestMap:GetAsync(ServerList.serverKey)).never.to.be.ok()
		end)
	end)
end