local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CurrencyManager = loadModule("CurrencyManager")
local MachineUtility = loadModule("MachineUtility")
local RoduxStore = loadModule("RoduxStore")
local Signal = loadModule("Signal")

local upgradeMachineLevel = getDataStream("UpgradeMachineLevel", "RemoteEvent")
local setBuildOption = getDataStream("SetBuildOption", "RemoteEvent")
local openResearchUI = getDataStream("OpenResearchUI", "BindableEvent")

local player = Players.LocalPlayer

local Machine = {
	openMachinePrompt = Signal.new();
	activeMachines = {};
}
Machine.__index = Machine

function Machine.new(machineData : table) : table
	warn("CREATE CLIENT MACHINE")

	local self = setmetatable(machineData, Machine)

	Machine.activeMachines[self.guid] = self

	self.selectorPrompt = Instance.new("ProximityPrompt")
	self.selectorPrompt.ActionText = "Open Build Menu"
	self.selectorPrompt.ObjectText = self.machineType .. " Machine"
	self.selectorPrompt.MaxActivationDistance = 25
	self.selectorPrompt.RequiresLineOfSight = false

	self.selectorPrompt.Triggered:Connect(function()
		self:openBuildUI()
	end)
	self.selectorPrompt.Parent = self.machine.PrimaryPart

	warn(self)

	return self
end

function Machine:updateValues(roduxData : table) : nil
	for key, value in roduxData do
		self[key] = value
	end
end

function Machine:upgradeLevel(levelType : string) : boolean
	local currentLevel = self[levelType .. "Level"]

	local upgradeDetails = MachineUtility.getUpgradeCost(self.machineType, levelType, currentLevel + 1)

	-- If there are no further upgrades of this type then return
	if not upgradeDetails then return false end

	-- TODO: Also Check Currency
	if CurrencyManager:hasAmount(player, upgradeDetails.currency, upgradeDetails.cost) then
		upgradeMachineLevel:FireServer(self.guid, levelType)

		return true
	else
		-- TODO: Fire Currency Shop with the currency type
		return false
	end
end

function Machine:setBuildOption(itemIndex : number) : boolean
	if MachineUtility.isItemResearched(itemIndex) then
		setBuildOption:FireServer(self.guid, itemIndex)

		return true
	else
		openResearchUI:Fire(self.machineType)

		return false
	end
end

function Machine:toggleAutomation()

end

function Machine:openBuildUI()
	Machine.openMachinePrompt:fire(self)
end

function Machine:startBuild()

end

function Machine:reset()

end

function Machine:destroy()

end

-- TODO: Determine if the update method is necessary
function Machine.updateFromRodux(roduxMachines : table)
	for guid, machineData in roduxMachines do
		local machineObj = Machine.activeMachines[guid]

		if not machineObj then
			-- Create the machine object if it doesn't already exist
			Machine.new(machineData)
		else
			-- Else update the machine object to match the data stored on the server
			machineObj:updateValues(machineData)
		end
	end

	-- Destroy the machine object if it doesn't exist on the server
	for guid, machineObj in Machine.activeMachines do
		if not roduxMachines[guid] then
			Machine.activeMachines[guid] = nil
			machineObj:destroy()
		end
	end
end

function Machine.init()
	-- Allows for inheritance
	for _, module in script:GetChildren() do
		setmetatable(require(module), Machine)
	end
end

function Machine.start()
	local machines = RoduxStore:waitForValue("machines")
	local playerMachines = machines[tostring(player.UserId)] or {}

	task.spawn(Machine.updateFromRodux, playerMachines)

	RoduxStore:bindToValueChanged(function(_playerMachines : table)
		Machine.updateFromRodux(_playerMachines)
	end, "machines", tostring(player.UserId))
end

return Machine