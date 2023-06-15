local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local HostServer = loadModule("HostServer")
	local SortedMaps = loadModule("SortedMaps")
	local TestMap = SortedMaps.getSortedMap("HostServer")

	SortedMaps.flush(TestMap)

	SKIP()

    describe("HostServer", function()
		it("should bind a host function to the server to be run if / when this server becomes the host", function()
			local test = false
			expect(function()
				HostServer:bindHostFunction(function()
					test = true
				end)
			end).never.to.throw()
			task.wait(1)
			expect(test).to.equal(true)
		end)
	end)
end