local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, _, loadComponent = table.unpack(require(ReplicatedStorage.ZenithFramework))

local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")

local Button = loadComponent("Button")

local companyNameUITemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.CompanyNameUI)
local exitButton = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.BuildMode.ExitButton)

local e = React.createElement
local useState = React.useState

local function companyNameUI(props)
	if not props.visible then return end

	return e(companyNameUITemplate, {
			[RoactTemplate.Root] = {
				Visible = props.toggleBinds.CompanyNameUI.bind;

				[React.Children] = {
					EnterButton = e(Button, {
						buttonProps = {
							Size = UDim2.new(0.4, 0, 0.14, 0);
							Position = UDim2.new(0.5, 0, 0.8, 0);
							AnchorPoint = Vector2.new(0.5, 0.5);
						};
						buttonType = "Standard";
						text = "CONFIRM";
						onClick = function()
							print("Setting name")
						end;
					});

					--[[ExitButton = e(exitButton, {
						[RoactTemplate.Root] = {
							[React.Event.MouseButton1Click] = function()

							end;
						};
					});]]
				}
			};
		}
	)
end

return companyNameUI