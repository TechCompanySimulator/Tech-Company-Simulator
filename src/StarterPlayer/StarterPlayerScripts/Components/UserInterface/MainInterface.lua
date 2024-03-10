local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local setInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local React = loadModule("React")
local RoduxStore = loadModule("RoduxStore")

local ThemeContext = loadComponent("ThemeContext")

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect
local createBinding = React.createBinding

local player = Players.LocalPlayer

local interfaceStates = {
	gameplay = {
		HUD = {};
		ResearchPrompt = {
			hasToggle = true;
		};
		CompanyNameUI = {
			hasToggle = true;
		};
	};
	buildMode = {
		BuildModeUI = {
			hasToggle = true;
		};
		HUD = {};
	};
	plotSelection = {
		PlotSelectionUI = {};
	};
}

local toggleBinds = require(script.ToggleBinds)

for _, components in interfaceStates do
	for componentName, info in pairs(components) do
		if not info.hasToggle then continue end

		local bind, setBind = createBinding(if info.enabled ~= nil then info.enabled else false)

		toggleBinds[componentName] = {
			bind = bind;
			setBind = setBind;
		}
	end
end

local function mainInterface()
	local state, setState = useState("plotSelection")

	local playerData = RoduxStore:waitForValue("playerData", tostring(player.UserId))
	local settingsData = playerData.Settings or {}
	local isDarkMode = settingsData.DarkMode
	local theme, setTheme = useState(isDarkMode and "dark" or "light")

	useEffect(function()
		local connection = setInterfaceState.Event:Connect(function(newState)
			if newState and interfaceStates[newState] then
				setState(newState)
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {state})

	local children = {}

	for _, components in interfaceStates do
		for componentName, _ in pairs(components) do
			children[componentName] = e(loadComponent(componentName), {
				visible = interfaceStates[state][componentName] ~= nil;
				toggleBinds = toggleBinds;
				setTheme = componentName == "SettingsUI" and setTheme;
			})
		end
	end

	return e("ScreenGui", {
		Name = "MainInterface";
	}, {
		Provider = e(ThemeContext.Provider, {
			value = theme;
		}, children)
	})
end

return mainInterface