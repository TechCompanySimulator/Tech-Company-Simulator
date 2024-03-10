local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CurrencyManager = loadModule("CurrencyManager")
local MachineUtility = loadModule("MachineUtility")
local RoduxStore = loadModule("RoduxStore")
local Signal = loadModule("Signal")

local player = Players.LocalPlayer

local Machine = {
	openMachinePrompt = Signal.new();
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
	local self = setmetatable(machineData, Machine)

	return self
end

function Machine:createPrompts()

end

function Machine:openBuildUI()

end

function Machine:destroy()

end

return Machine