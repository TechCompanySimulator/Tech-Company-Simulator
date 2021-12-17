-- Creates a grid object with useful methods
-- Author: TheM0rt0nator

local Grid = {}
Grid.__index = Grid

-- Creates a new grid object
function Grid.new(w, h, cellRefType, valType)
	assert(typeof(w) == "number" and typeof(h) == "number", "Width and height need to be of type: number")

	local self = setmetatable({}, Grid)

	self.w = w
	self.h = h

	if cellRefType and cellRefType == "LetterNum" then
		self:CreateLetterNumCells(valType)
	else
		self:CreateNumberedCells(valType)
	end

	return self
end

-- Creates a table containing the numbered grid reference of each cell (e.g. 1:1, 1:2, 2:1, etc)
function Grid:CreateNumberedCells(valType)
	self.numberedCells = {}
	local initialVal = (valType == "table" and {}) or (valType == "string" and "") or {}

	for w = 1, self.w do
		for h = 1, self.h do
			self.numberedCells[w .. ":" .. h] = initialVal
		end
	end
end

-- Creates a table containing the letter num grid reference of each cell (e.g. a:1, a:2, b:1, etc)
function Grid:CreateLetterNumCells(valType)
	self.letterNumCells = {}
	local initialVal = (valType == "table" and {}) or (valType == "string" and "") or {}

	for w = 1, self.w do
		local letter = string.char(w + 96)
		for h = 1, self.h do
			self.numberedCells[letter .. ":" .. h] = initialVal
		end
	end
end

-- Returns a tables of the cells surrounding the piece
function Grid:GetSurroundingCells(cell)
	local surroundingCells = {}

	-- Vectors to check surrounding cells of a cell
	local Vectors = {
		Vector2.new(-1, 1); Vector2.new(0, 1); Vector2.new(1, 1);
		Vector2.new(-1, 0);                    Vector2.new(1, 0);
		Vector2.new(-1, -1); Vector2.new(0, -1); Vector2.new(1, -1);
	}

	for _, vector in pairs(Vectors) do
		local surroundingCell = cell + vector
		if surroundingCell.X >= 1
			and surroundingCell.X <= self.w
			and surroundingCell.Y >= 1
			and surroundingCell.Y <= self.h
		then
			table.insert(surroundingCells, surroundingCell)
		end
	end

	return surroundingCells
end

return Grid