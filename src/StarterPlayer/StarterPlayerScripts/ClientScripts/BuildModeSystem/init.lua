local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local setInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local BuildModeSystem = {}
BuildModeSystem.isActive = false

function BuildModeSystem.enter()
	if BuildModeSystem.isActive then return end

	BuildModeSystem.isActive = true
	--Camera:setCameraType("BuildMode", workspace.Plots.Plot1.CFrame + Vector3.new(0, 2, 0), workspace.Plots.Plot1.Size.X)
	setInterfaceState:Fire("buildMode")
end

function BuildModeSystem.exit()
	if not BuildModeSystem.isActive then return end
	
	BuildModeSystem.isActive = false
	--Camera:setCameraType("Default")
	setInterfaceState:Fire("gameplay")
end

return BuildModeSystem