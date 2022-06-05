local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

--local SetInterfaceRemote = getDataStream("SetInterfaceState", "RemoteEvent")
local SetInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local Roact = loadModule("Roact")
local Maid = loadModule("Maid")

local MainInterface = Roact.Component:extend("MainInterface")

local Components = {
	Inventory = loadModule("Inventory");
	LoadingScreen = loadModule("LoadingScreen");
	MachineUI = loadModule("MachineUI");
	MainMenu = loadModule("MainMenu");
}

local InterfaceStates = {
	mainMenu = {
		"MainMenu";
	};
	loadingScreen = {
		"LoadingScreen";
	};
	gameplay = {
		"Inventory";
		"MachineUI";
	};
}

function MainInterface:init()
	self.maid = Maid.new()
	self.currentState = nil
	self.visibilityBindings = {}
	self.setVisibleBindings = {}
	for componentName, _ in pairs(Components) do
		self.visibilityBindings[componentName], self.setVisibleBindings[componentName] = Roact.createBinding(false)
	end

	--[[self.maid:GiveTask(SetInterfaceRemote.OnClientEvent:Connect(function(state)
		if state and InterfaceStates[state] and self.currentState ~= state then
			self:setState(state)
		end
	end))]]

	self.maid:GiveTask(SetInterfaceState.Event:Connect(function(state)
		if state and InterfaceStates[state] and self.currentState ~= state then
			self:setState(state)
		end
	end))

	self:setState("loadingScreen")
end

function MainInterface:setState(state)
	self.currentState = state
	local stateComponents = InterfaceStates[state]
	for componentName, _ in pairs(Components) do
		if not table.find(stateComponents, componentName) and self.visibilityBindings[componentName] and self.setVisibleBindings[componentName] then
			self.setVisibleBindings[componentName](false)
		else
			self.setVisibleBindings[componentName](true)
		end
	end
end

function MainInterface:render()
	local children = {}

	for componentName, component in pairs(Components) do
		children[componentName] = Roact.createElement(component, {
			visible = self.visibilityBindings[componentName]
		})
	end

	return Roact.createElement("ScreenGui", {
		Name = "MainInterface";
	}, children)
end

return MainInterface