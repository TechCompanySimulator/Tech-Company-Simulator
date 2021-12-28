local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local Grid = loadModule("Grid")

	local newGrid
	local gridWidth = 8
	local gridHeight = 8

	describe("Grid", function()
		it("should create a new grid object correctly", function()
			expect(function()
				newGrid = Grid.new(gridWidth, gridHeight)
			end).never.to.throw()
		end)

		it("should store the cell references for the grid as numbers in the form 1:1 etc", function()
			expect(function()
				newGrid:CreateNumberedCells()
			end).never.to.throw()
			for w = 1, gridWidth do
				for h = 1, gridHeight do
					expect(newGrid.numberedCells[w .. ":" .. h]).to.be.ok()
				end
			end
		end)

		it("should store the cell references for the grid as letters and numbers in the form a:1 etc", function()
			expect(function()
				newGrid:CreateLetterNumCells()
			end).never.to.throw()
			for w = 1, gridWidth do
				local letter = string.char(w + 96)
				for h = 1, gridHeight do
					expect(newGrid.numberedCells[letter .. ":" .. h]).to.be.ok()
				end
			end
		end)

		it("should return the surrounding cells of the given cell reference", function()
			local surroundingCells 
			expect(function()
				surroundingCells = newGrid:GetSurroundingCells(Vector2.new(5, 4))
			end).never.to.throw()
			expect(#surroundingCells).to.equal(8)
		end)
	end)
end