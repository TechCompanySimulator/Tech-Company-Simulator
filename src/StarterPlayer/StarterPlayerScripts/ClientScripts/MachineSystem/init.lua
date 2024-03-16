local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CurrencyManager = loadModule("CurrencyManager")
local MachineUtility = loadModule("MachineUtility")
local ResearchSystem = loadModule("ResearchSystem")
local RoduxStore = loadModule("RoduxStore")
local Signal = loadModule("Signal")

local upgradeMachine = getDataStream("UpgradeMachine", "RemoteFunction")
local setBuildOption = getDataStream("SetMachineBuildOption", "RemoteFunction")
local openResearchUI = getDataStream("OpenResearchUI", "BindableEvent")

local player = Players.LocalPlayer

local Machine = {
	machinePromptSignal = Signal.new();
	activeMachines = {};
}
Machine.__index = Machine

function Machine.initiate(): nil
	-- Allows for inheritance
	for _, module in script:GetChildren() do
		setmetatable(require(module), Machine)
	end
end

function Machine.start(): nil
	local roduxMachines = RoduxStore:waitForValue("machines", tostring(player.UserId))

	Machine.syncRoduxTable(roduxMachines)

	RoduxStore:bindToValueChanged(Machine.syncRoduxTable, "machines", tostring(player.UserId))
end

function Machine.syncRoduxTable(roduxMachines: table): nil
	-- Loop through the Rodux Machines and create any that don't exist
	for guid, machineData in roduxMachines do
		local machine = Machine.activeMachines[guid]

		if not machine then
			Machine.activeMachines[guid] = Machine.new(machineData)
		end
	end

	-- Loop through the active machines and destroy any that don't exist in the Rodux store
	for guid, machine in Machine.activeMachines do
		if not roduxMachines[guid] then
			machine:destroy()

			Machine.activeMachines[guid] = nil
		end
	end
end

function Machine.new(machineData: table): table
	local self = setmetatable(table.clone(machineData), Machine)

	self:createPrompts()

	return self
end

function Machine:createPrompts()
	local machineUIPart = self.machine.ControlPanel.AssembleButton
	local buildPart = self.machine.ProxPromptPart

	self.selectorPrompt = Instance.new("ProximityPrompt")
	self.selectorPrompt.ActionText = "Open Build Menu"
	self.selectorPrompt.ObjectText = self.machineType .. " Machine"
	self.selectorPrompt.MaxActivationDistance = 25
	self.selectorPrompt.RequiresLineOfSight = false

	self.selectorPrompt.Triggered:Connect(function()
		self:openMachinePrompt()
	end)
	self.selectorPrompt.Parent = machineUIPart

	self.buildPrompt = Instance.new("ProximityPrompt")
	self.buildPrompt.MaxActivationDistance = 25
	self.buildPrompt.RequiresLineOfSight = false
	self.buildPrompt.Enabled = false
	self.buildPrompt.Parent = buildPart

	self.buildPrompt.Triggered:Connect(function()
		--
	end)

	self:updateBuildPrompt()
end

function Machine:toggleAutomation()

end

function Machine:openMachinePrompt()
	Machine.machinePromptSignal:fire(self)
end

function Machine:setBuildOption(option: number): boolean
	if self.buildOption == option then return true end

	if ResearchSystem.hasPlayerResearched(player, self.machineType:lower(), option) then
		local success = setBuildOption:InvokeServer(self.guid, option)

		if success then
			self.buildOption = option
			self:updateBuildPrompt()

			return true
		end
	end

	openResearchUI:Fire(self.machineType:lower())

	return false
end

function Machine:updateBuildPrompt()
	self.buildPrompt.ActionText = if self.automated then "Start Production" else "Build Item"

	if self.buildOption then
		self.buildPrompt.ObjectText = MachineUtility.getBuildItems(self.machineType)[self.buildOption]
		self.buildPrompt.Enabled = true
	else
		self.buildPrompt.Enabled = false
	end
end

-- TODO: Ensure sufficient debounce on UI Button
-- Game values is indexed from 1 onwards, with 1 representing costs for level 2
function Machine:upgradeLevel(levelType: string): boolean
	if not MachineUtility.isValidLevelType(levelType) then return false end

	local upgradeValues = RoduxStore:waitForValue("gameValues", "machines", self.machineType:lower(), levelType .. "Upgrades")

	-- Upgrade costs are indexed from 1 onwards, with 1 representing costs for level 2 etc
	local currentLevel = self[levelType .. "Level"]
	local upgradeDetails = upgradeValues[currentLevel]

	if not upgradeDetails then
		warn(levelType .. " is already at max level for machine of type " .. self.machineType)
		return false
	end

	if CurrencyManager:hasAmount(player, upgradeDetails.currency, upgradeDetails.cost) then
		local success = upgradeMachine:InvokeServer(self.guid, levelType)

		if success then
			self[levelType .. "Level"] = currentLevel + 1

			return true
		end
	else
		-- TODO: Open Currency UI
		return false
	end
end

function Machine:destroy()

end

return Machine