local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Camera = loadModule("Camera")

local setInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local BuildModeSystem = {}

function BuildModeSystem.enter()
	--Camera:setCameraType("BuildMode", workspace.Plots.Plot1.CFrame + Vector3.new(0, 2, 0), workspace.Plots.Plot1.Size.X)
	setInterfaceState:Fire("buildMode")
end

function BuildModeSystem.exit()
	--Camera:setCameraType("Default")
	setInterfaceState:Fire("gameplay")
end

return BuildModeSystem