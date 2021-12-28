local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local Vectors = loadModule("Vectors")

	describe("Vectors", function()
		it("should convert a vector to a string in the format x:y or x:y:z", function()
			local convertedVector
			expect(function()
				convertedVector = Vectors.vectorToString(Vector2.new(5, 4))
			end).never.to.throw()
			expect(convertedVector).to.equal("5:4")
			expect(Vectors.vectorToString(Vector3.new(5, 4, 6))).to.equal("5:4:6")
			expect(function()
				convertedVector = Vectors.vectorToString("Hello")
			end).to.throw()
		end)

		it("should convert a string to a vector from the format x:y or x:y:z", function()
			local convertedString
			expect(function()
				convertedString = Vectors.stringToVector("5:4")
			end).never.to.throw()
			expect(convertedString).to.equal(Vector2.new(5, 4))
			expect(Vectors.stringToVector("5:4:6")).to.equal(Vector3.new(5, 4, 6))
			expect(function()
				convertedString = Vectors.stringToVector(Vector2.new(1, 2))
			end).to.throw()
		end)

		it("should check whether the given vector is within the given bounds", function()
			local isWithin
			expect(function()
				isWithin = Vectors.checkWithinBounds(Vector2.new(5, 4), 4, 6, 3, 5)
			end).never.to.throw()
			expect(isWithin).to.equal(true)
			expect(Vectors.checkWithinBounds(Vector2.new(5, 4), 6, 7, 3, 5)).to.equal(false)
		end)
	end)
end