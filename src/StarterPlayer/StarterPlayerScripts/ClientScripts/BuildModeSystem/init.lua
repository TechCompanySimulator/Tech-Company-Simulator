local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local setInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local BuildModeSystem = {}

function BuildModeSystem.enter()
	setInterfaceState:Fire("buildMode")
end

function BuildModeSystem.exit()
	setInterfaceState:Fire("gameplay")
end

return BuildModeSystem