local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local ConsoleKeybinds = loadModule("ConsoleKeybinds")
local Maid = loadModule("Maid")

local ProximityPrompt = {}
ProximityPrompt.__index = ProximityPrompt

function ProximityPrompt.new(contents)
	assert(typeof(contents) == "table" or (typeof(contents) == "Instance" and contents:IsA("ProximityPrompt")), "Contents must be either a table or a proximity prompt.")

	local self = setmetatable({}, ProximityPrompt)

	if typeof(contents) == "table" then
		self.prompt = Instance.new("ProximityPrompt")
		self.prompt.ObjectText = contents.objectText or contents.parent.Name
		self.prompt.ActionText = contents.actionText or "Activate"

		self.prompt.MaxActivationDistance = contents.maxActivationDistance or 10
		self.prompt.HoldDuration = contents.holdDuration or 0
		self.prompt.Enabled = contents.enabled or true

		self.prompt.KeyboardKeyCode = contents.keyboardKeyCode or Enum.KeyCode.E
		self.prompt.GamepadKeyCode = ConsoleKeybinds[self.prompt.KeyboardKeyCode]

		self.prompt.Parent = contents.parent
	else
		self.prompt = contents
	end

	self.maid = Maid.new()

	return self
end

function ProximityPrompt:Connect(connectedFunction)
	self.maid:GiveTask(self.prompt.Triggered:Connect(connectedFunction))
end

function ProximityPrompt:DoCleaning()
	self.maid:DoCleaning()
end

function ProximityPrompt:ToggleEnabled(isEnabled)
	self.proxPrompt.Enabled = isEnabled
end

return ProximityPrompt