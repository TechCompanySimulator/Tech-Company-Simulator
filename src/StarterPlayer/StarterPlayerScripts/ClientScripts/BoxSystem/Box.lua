local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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

	self.maid:giveTask(self.model:GetAttributeChangedSignal("Sold"):Connect(function()
		if not self.model:GetAttribute("Sold") then return end

		self.pickupPrompt.prompt.Enabled = false
	end))

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
		holdDuration = 0.5;
		keyboardKeyCode = Enum.KeyCode.E;
		custom = true;
	})

	self.pickupPrompt:Connect(function()
		self.PickupDebounce = true
		self:Pickup()
	end)
end

function Box:Pickup()
	if self.pickedUp or player.UserId ~= self.model:GetAttribute("OwnerId") then return end

	self.pickedUp = true
	self.pickupPrompt.prompt.Enabled = false
	local success = pickupBoxFunc:InvokeServer(true, self.model)
	if not success then
		self.pickedUp = false
		self.pickupPrompt.prompt.Enabled = true
	else
		ProximityPromptService.Enabled = false
		self.maid:giveTask(UserInputService.InputEnded:Connect(function(input, processed)
			if processed or input.KeyCode ~= Enum.KeyCode.E then return end
			
			if self.PickupDebounce then
				self.PickupDebounce = false
				return
			end

			self:Drop()
		end), 'PickupBox')
	end
end

function Box:Drop()
	local success = pickupBoxFunc:InvokeServer(false, self.model)
	if not success then return end


	self.maid:remove('PickupBox')

	ProximityPromptService.Enabled = true
	self.pickedUp = false
	self.pickupPrompt.prompt.Enabled = true
end

function Box:Destroy()
	self.maid:doCleaning()
end

return Box