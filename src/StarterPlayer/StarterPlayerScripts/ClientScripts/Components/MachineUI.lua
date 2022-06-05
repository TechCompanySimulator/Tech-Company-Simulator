local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local ProximityManager = loadModule("ProximityManager")
local Roact = loadModule("Roact")
local RoduxStore = loadModule("RoduxStore")

local Button = loadModule("Button")
local MachineSystem = loadModule("MachineSystem")

local MachineUI = Roact.Component:extend("MachineUI")

function MachineUI:init()
	self:setState({enabled = false})
	MachineSystem._signal:connect(function(machine)
		self.machine = machine
		self:setState({enabled = true})
	end)
end

function MachineUI:getOptions()
	if not self.machine then return end

	local researchLevel = RoduxStore:waitForValue("playerData", tostring(self.machine.userId), "ResearchLevels", self.machine.machineType)
	local options = {}

	-- TODO: Convert to iterate through RoduxStore
	for ind, option in pairs(self.machine.machineValues.buildOptions) do
		local button = Roact.createElement(Button, {
			buttonProps = {
				LayoutOrder = ind;
				Size = UDim2.new(0.12, 0, 0.07, 0);
			};
			text = option.displayName;
			buttonStyle = (researchLevel >= ind and "Standard") or "Disabled";
			onClick = function()
				self.machine:setBuildOption(ind)
				self:setState({enabled = false})
				self.machine = nil
				ProximityManager:enable("MachineUI")
			end;
		})

		table.insert(options, button)
	end

	local upgrades = {
		speed = self.machine.machineValues.speedUpgrades[self.machine.speedLevel];
		quality = self.machine.machineValues.qualityUpgrades[self.machine.qualityLevel]
	}

	for upgradeType, values in pairs(upgrades) do
		table.insert(options,
			Roact.createElement(Button, {
				buttonProps = {
					LayoutOrder = 10 * string.len(upgradeType);
					Size = UDim2.new(0.12, 0, 0.07, 0);
				};
				text = "Speed Upgrade " .. self.machine[upgradeType .. "Level"] .. " : " .. values.amount .. " " .. values.currency;
				buttonStyle = "Upgrade";
				onClick = function()
					if self.machine:upgrade(upgradeType) then
						self:setState({})
					else
						-- TODO: Notify Currency purchase
					end
				end;
			})
		)
	end

	return Roact.createFragment(options)
end

function MachineUI:render()
	return Roact.createElement("Frame", {
		Visible = self.state.enabled;
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 1, 0);
		BackgroundColor3 = Color3.new(1, 1, 1);
	}, {
		Title = Roact.createElement("TextLabel", {
			FontSize = Enum.FontSize.Size14;
			TextColor3 = Color3.new(1, 1, 1);
			TextStrokeColor3 = Color3.new(0.086, 0.694, 1);
			Text = "Select a Build Option:";
			TextStrokeTransparency = 0;
			Font = Enum.Font.Roboto;
			BackgroundTransparency = 1;
			Name = "Title";
			Size = UDim2.new(0.3, 0, 0.1, 0);
			TextScaled = true;
			BackgroundColor3 = Color3.new(1, 1, 1);
			LayoutOrder = -1;
		});
		ExitButton = Roact.createElement(Button, {
			buttonProps = {
				LayoutOrder = 10000;
				Size = UDim2.new(0.12, 0, 0.07, 0);
			};
			text = "Exit";
			buttonStyle = "Cancel";
			onClick = function()
				self:setState({enabled = false})
				self.machine = nil
				ProximityManager:enable("MachineUI")
			end;
		});
		OptionButtons = self:getOptions();
		UIListLayout = Roact.createElement("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center;
			SortOrder = Enum.SortOrder.LayoutOrder;
			HorizontalAlignment = Enum.HorizontalAlignment.Center;
			Padding = UDim.new(0.005, 0);
		});
	})
end

return MachineUI