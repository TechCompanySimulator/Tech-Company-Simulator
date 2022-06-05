local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local ConsoleKeybinds = loadModule("ConsoleKeybinds")
local Maid = loadModule("Maid")

local ProximityPrompt = {}
ProximityPrompt.__index = ProximityPrompt

function ProximityPrompt.new(contents, debounceTime)
	assert(typeof(contents) == "table" or (typeof(contents) == "Instance" and contents:IsA("ProximityPrompt")), "Contents must be either a table or a proximity prompt.")

	local self = setmetatable({}, ProximityPrompt)

	if typeof(contents) == "table" then
		self.prompt = Instance.new("ProximityPrompt")
		self.prompt.ObjectText = contents.objectText or contents.parent.Name
		self.prompt.ActionText = contents.actionText or "Activate"

		self.prompt.MaxActivationDistance = contents.maxActivationDistance or 10
		self.prompt.RequiresLineOfSight = contents.requiresLineOfSight or false
		self.prompt.HoldDuration = contents.holdDuration or 0
		self.prompt.Enabled = contents.enabled or true

		self.prompt.KeyboardKeyCode = contents.keyboardKeyCode or Enum.KeyCode.E
		self.prompt.GamepadKeyCode = ConsoleKeybinds[self.prompt.KeyboardKeyCode]

		self.prompt.Parent = contents.parent
	else
		self.prompt = contents
	end

	self.debounce = debounceTime
	self.maid = Maid.new()

	return self
end

function ProximityPrompt:connect(_callback)
	local callback
	if self.debounce then
		callback = function()
			self.prompt.Enabled = false

			_callback()

			task.delay(self.debounce, function()
				self.prompt.Enabled = true
			end)
		end
	else
		callback = _callback
	end

	self.maid:GiveTask(self.prompt.Triggered:Connect(callback))
end

function ProximityPrompt:doCleaning()
	self.maid:DoCleaning()
end

function ProximityPrompt:toggleEnabled(isEnabled)
	self.proxPrompt.Enabled = isEnabled
end

return ProximityPrompt