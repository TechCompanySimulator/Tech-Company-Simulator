local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")
local ProximityPrompt = loadModule("ProximityPrompt")

local pickupBoxFunc = getDataStream("PickupBox", "RemoteFunction")

local player = Players.LocalPlayer

local Box = {}
Box.__index = Box

function Box.new(box)
	local self = setmetatable({}, Box)

	self.maid = Maid.new()
	self.model = box
	self.pickedUp = false

	self:SetupPrompt()

	return self
end

function Box:SetupPrompt()
	if player.UserId ~= self.model:GetAttribute("OwnerId") then return end

	local main = self.model:WaitForChild("Main", 3)
	if not main then warn("Main part not found for box") return end

	self.pickupPrompt = ProximityPrompt.new({
		parent = main;
		objectText = "Wooden Box";
		actionText = "Pick Up";
		maxActivationDistance = 10;
		holdDuration = 1;
		keyboardKeyCode = Enum.KeyCode.E;
		custom = true;
	})

	self.pickupPrompt:Connect(function()
		self:Pickup()
	end)
end

function Box:Pickup()
	if self.pickedUp or player.UserId ~= self.model:GetAttribute("OwnerId") then return end

	self.pickedUp = true
	self.pickupPrompt.prompt.Enabled = false
	local success = pickupBoxFunc:InvokeServer(self.model)
	if not success then
		self.pickedUp = false
		self.pickupPrompt.prompt.Enabled = true
	end
end

function Box:Destroy()
	self.maid:doCleaning()
end

return Box