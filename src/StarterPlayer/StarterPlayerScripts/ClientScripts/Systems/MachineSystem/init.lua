local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local MachineUtility = loadModule("MachineUtility")
local Signal = loadModule("Signal")

local upgradeMachineLevel = getDataStream("UpgradeMachineLevel", "RemoteFunction")
local setBuildOption = getDataStream("SetBuildOption", "RemoteFunction")

local Machine = {
	openMachinePrompt = Signal.new();
}
Machine.__index = Machine

function Machine.new()

end

function Machine:upgradeLevel()
	
end

-- TODO: Fire the Research UI if this is attempted and the level isn't sufficient
function Machine:setBuildOption()

end

function Machine:toggleAutomation()

end

function Machine:openBuildUI()

end

function Machine:startBuild()

end

function Machine:reset()

end

function Machine:destroy()

end

task.spawn(function()
	-- Allows for inheritance
	for _, module in script:GetChildren() do
		setmetatable(require(module), Machine)
	end
end)

return Machine