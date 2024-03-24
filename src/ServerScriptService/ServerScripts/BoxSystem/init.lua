local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Box = loadModule("Box")
local CollisionGroups = loadModule("CollisionGroups")
local CurrencyManager = loadModule("CurrencyManager")

local pickupBoxFunc = getDataStream("PickupBox", "RemoteFunction")

local BoxSystem = {}
BoxSystem.boxes = {}
BoxSystem.soldBoxes = {}

function BoxSystem:initiate()
	for _, sellPart in CollectionService:GetTagged("SellPart") do
		self:setupSellPart(sellPart)
	end

	pickupBoxFunc.OnServerInvoke = function(player, pickUp, box)
		return self:pickBoxUp(player, pickUp, box)
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

	CollisionGroups.assignGroup(box.model, "Sold_Box")
end

function BoxSystem:pickBoxUp(player, pickUp, box)
	if not (typeof(box) == "Instance") then return false end

	local boxId = box:GetAttribute("Id")
	if not boxId or not self.boxes[player] or not self.boxes[player][boxId] then warn("Box object not found") return false end
	
	if pickUp then
		return self.boxes[player][boxId]:Pickup(player)
	else
		return self.boxes[player][boxId]:Drop(player)
	end
end

function BoxSystem:getBoxObjectFromModel(box)
	for owner, objects in self.boxes do
		for _id, object in objects do
			if object.model ~= box then continue end

			return object, owner
		end
	end
end

function BoxSystem:setupSellPart(part)
	part.Touched:Connect(function(hit)
		local box = hit.Parent
		if not CollectionService:HasTag(box, "Box") or self.soldBoxes[box] then return end

		self.soldBoxes[box] = true
		local boxObject, owner = self:getBoxObjectFromModel(box)
		local boxValues = self:calculateBoxValue(boxObject)
		for currency, value in boxValues do
			CurrencyManager:transact(owner, currency, value)
		end

		CollisionGroups.assignGroup(box, "Sold_Box")

		box:SetAttribute("Sold", true)

		task.delay(2, function()
			self.soldBoxes[box] = nil
			box:Destroy()
		end)
	end)
end

function BoxSystem:calculateBoxValue(boxObject)
	if not boxObject then warn("Could not find box object") return end

	return {
		Coins = 500;
	}
end

return BoxSystem