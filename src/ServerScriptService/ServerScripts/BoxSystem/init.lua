local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Box = loadModule("Box")

local pickupBoxFunc = getDataStream("PickupBox", "RemoteFunction")

local BoxSystem = {}
BoxSystem.boxes = {}

function BoxSystem:initiate()
	pickupBoxFunc.OnServerInvoke = function(player, box)
		return self:pickBoxUp(player, box)
	end
end

function BoxSystem:spawnBox(owner, boxType, cf)
	if not self.boxes[owner] then
		self.boxes[owner] = {}
	end

	local boxId = 1
	for i = 1, #self.boxes[owner] do
		if self.boxes[owner][tostring(i)] then boxId += 1 continue end
	end

	local box = Box.new(owner, boxType, cf, boxId)
	self.boxes[owner][tostring(boxId)] = box
end

function BoxSystem:pickBoxUp(player, box)
	if not (typeof(box) == "Instance") then return false end

	local boxId = box:GetAttribute("Id")
	if not boxId or not self.boxes[player] or not self.boxes[player][boxId] then warn("Box object not found") return false end
	
	return self.boxes[player][boxId]:Pickup(player)
end

return BoxSystem