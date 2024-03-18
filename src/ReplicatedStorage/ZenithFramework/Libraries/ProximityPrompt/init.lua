local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local ConsoleKeybinds = loadModule("ConsoleKeybinds")
local Maid = loadModule("Maid")
local ProximityManager = loadModule("ProximityManager")

local ProximityPrompt = {}
ProximityPrompt.__index = ProximityPrompt

function ProximityPrompt.new(contents)
	assert(typeof(contents) == "table" or (typeof(contents) == "Instance" and contents:IsA("ProximityPrompt")), "Contents must be either a table or a proximity prompt.")

	local self = setmetatable({}, ProximityPrompt)

	if typeof(contents) == "table" then
		self:_CreatePrompt(contents)

		self.onStarted = contents.onStarted
		self.onStopped = contents.onStopped
	else
		self.prompt = contents
	end

	self.maid = Maid.new()
	ProximityManager.prompts[self.prompt] = self

	return self
end

function ProximityPrompt:_CreatePrompt(contents)
	self.prompt = Instance.new("ProximityPrompt")
	self.custom = contents.custom
	self.saveProgress = contents.saveProgress

	self.prompt.ObjectText = contents.objectText or contents.parent.Name
	self.prompt.ActionText = contents.actionText or "Activate"

	self.prompt.MaxActivationDistance = contents.maxActivationDistance or 10
	self.prompt.HoldDuration = contents.holdDuration or 0
	self.prompt.Enabled = contents.enabled or true

	self.prompt.KeyboardKeyCode = contents.keyboardKeyCode or Enum.KeyCode.E
	self.prompt.GamepadKeyCode = ConsoleKeybinds[self.prompt.KeyboardKeyCode]

	if contents.custom then
		self.prompt:SetAttribute("SaveProgress", self.saveProgress)
		self.prompt.Style = Enum.ProximityPromptStyle.Custom
	end

	if self.onStarted then
		self.maid:giveTask(self.prompt.PromptButtonHoldBegan:Connect(self.onStarted))
	end

	if self.onStopped then
		self.maid:giveTask(self.prompt.PromptButtonHoldEnded:Connect(self.onStopped))
	end

	self.prompt.Parent = contents.parent
end

function ProximityPrompt:Connect(connectedFunction)
	if not self.custom then
		self.maid:giveTask(self.prompt.Triggered:Connect(connectedFunction))
	else
		if not self.connectedFunctions then
			self.connectedFunctions = {}
		end

		table.insert(self.connectedFunctions, connectedFunction)
	end
end

function ProximityPrompt:DoCleaning()
	self.maid:doCleaning()
end

function ProximityPrompt:ToggleEnabled(isEnabled)
	self.proxPrompt.Enabled = isEnabled
end

function ProximityPrompt:Destroy()
	self.maid:doCleaning()
	self.prompt:Destroy()
	ProximityManager.prompts[self.prompt] = nil
end

return ProximityPrompt