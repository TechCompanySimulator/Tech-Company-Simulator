local HttpService = game:GetService("HttpService")
-- Handles the storing and cleaning up of connections

local Maid = {}
Maid.__index = Maid

-- Creates a new maid object
function Maid.new()
	local self = setmetatable({}, Maid)

	self.connections = {}

	return self
end

-- Stores a task in the maid
function Maid:GiveTask(task, index)
	index = index or HttpService:GenerateGUID(false)
	self.connections[index] = task
end

-- Clears all tasks stored in the maid
function Maid:DoCleaning()
	for _, task in pairs(self.connections) do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		end
	end

	self.connections = {}
end

function Maid:Remove(index)
	if not self.connections[index] then warn("No task with index ", index, " found in maid") return end

	self.connections[index]:Disconnect()
	self.connections[index] = nil
end

Maid.giveTask = Maid.GiveTask
Maid.doCleaning = Maid.DoCleaning
Maid.remove = Maid.Remove

return Maid