local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")
local React = loadModule("React")
local RoactRodux = loadModule("RoactRodux")
local RoactTemplate = loadModule("RoactTemplate")
local ResearchSystem = loadModule("ResearchSystem")

local Button = loadComponent("Button")
local CloseButton = loadComponent("CloseButton")
local ResearchOptions = loadComponent("ResearchOptions")

local openResearchUI = getDataStream("OpenResearchUI", "BindableEvent")

local uiTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.ResearchUI.ResearchPrompt)

local e = React.createElement
local useBinding = React.useBinding
local useEffect = React.useEffect

local player = Players.LocalPlayer

local function getTechnologyButtons(props : table, setSelectedMachine) : table?
	if not props.machines then return end

	local buttons = {}

	for machineType, machineData in props.machines do
		table.insert(buttons, e(Button, {
			buttonProps = {
				Size = UDim2.new(0.8, 0, 0.14, 0);
				LayoutOrder = machineData.displayOrder;
				Name = machineType;
			};
			buttonType = "Standard";
			text = machineData.displayName;
			onClick = function()
				setSelectedMachine(machineType)
			end;
		}))
	end

	return buttons
end

local function getResearchButtons(props : table, selectedMachine) : table
	local researchFrames = {}

	for category, upgradeCosts in props.researchCosts do
		local machineData = props.machines[category]
		local displayName = machineData.displayName

		table.insert(researchFrames, e(ResearchOptions, {
			machineType =  category;
			machineDisplayName = displayName; 
			buildItems = machineData.buildItems;
			upgradeCosts = upgradeCosts;
			selectedMachine = selectedMachine;
		}))
	end

	return researchFrames
end

local function researchPrompt(props: table)
	-- TODO: Set Initial State as Basic Machine Type
	local selectedMachine, setSelectedMachine = useBinding("")
	local toggleBinds = props.toggleBinds.ResearchPrompt

	useEffect(function()
		local maid = Maid.new()

		maid:giveTask(openResearchUI.Event:Connect(function(machineType : string?): nil
			toggleBinds.setBind(true)

			-- If this has been toggled by a specific machine then set the state to that type
			if machineType then
				setSelectedMachine(machineType)
			else
				local selectedMachineType = ResearchSystem.getFirstUIDisplayType(player)

				setSelectedMachine(selectedMachineType)
			end
		end))

		return function()
			maid:doCleaning()
		end
	end)

	return e(uiTemplate, {
		[RoactTemplate.Root] = 	{
			Visible = toggleBinds.bind:map(function(bool)
				return bool and props.visible
			end);

			[React.Children] = {
				CloseButton = e(CloseButton, {
					onClick = function()
						toggleBinds.setBind(false)
					end;
				});
			};
		};

		ButtonFrame = {
			[React.Children] = getTechnologyButtons(props, setSelectedMachine);
		};

		ResearchFrame = {
			[React.Children] = getResearchButtons(props, selectedMachine);
			Size = UDim2.new(0.7, 0, 0.7, 0);
			Position = UDim2.new(0.25, 0, 0.2, 0);
		}
	})
end

researchPrompt = RoactRodux.connect(function(state)
	local gameValues = state.gameValues or {}
	local machines = gameValues.machines or {}
	local researchCosts = gameValues.researchCosts or {}

	return {
		machines = machines;
		researchCosts = researchCosts;
	}
end)(researchPrompt)

return researchPrompt