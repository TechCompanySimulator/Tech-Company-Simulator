local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local Maths = loadModule("Maths")

	describe("Maths", function()
		it("should interpolate a number linearly by the given alpha amount", function()
			local result1
			expect(function()
				result1 = Maths.lerp(1, 2, 0.5)
			end).never.to.throw()
			expect(result1).to.equal(1.5)
			local result2 = Maths.lerp(0, 100, 0.75)
			expect(result2).to.equal(75)
		end)
	end)
end