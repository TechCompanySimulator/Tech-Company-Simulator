local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Llama = loadModule("Llama")
local React = loadModule("React")
local RoactTemplate = loadModule("RoactTemplate")

local BUTTON_STYLES = {
	Standard = {
		default = Color3.fromRGB(255, 255, 255);
		hover = Color3.fromRGB(220, 220, 220);
	};
	Confirm = {
		default = Color3.fromRGB(70, 255, 70);
		hover = Color3.fromRGB(100, 255, 100);
	};
	Cancel = {
		default = Color3.fromRGB(255, 70, 70);
		hover = Color3.fromRGB(255, 100, 100);
	};
	Special = {
		default = Color3.fromRGB(237, 184, 56);
		hover = Color3.fromRGB(250, 197, 74);
	};
	Disabled = {
		default = Color3.fromRGB(177, 177, 177);
		hover = Color3.fromRGB(200, 200, 200);
	}
}

local e = React.createElement
local useRef = React.useRef
local useBinding = React.useBinding
local camera = workspace.CurrentCamera

local buttonTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.Elements.Button)

return function(props)
	local isHovered, setHovered = useBinding(false)
	local debounce = useRef(false)

	local buttonColours = BUTTON_STYLES[props.buttonType or "Standard"]
	local debounceTime = props.debounce or 0.2
	local isActive = props.buttonType ~= "Disabled"

	return e(buttonTemplate, {
		[RoactTemplate.Root] = props.buttonProps or {};

		Click = {
			Active = isActive;
			BackgroundColor3 = isHovered:map(function(bool)
				local index = bool and "hover" or "default"
				return buttonColours[index]
			end);
			[React.Event.MouseButton1Click] = function()
				if debounce.current or typeof(props.onClick) ~= "function" then return end

				debounce.current = true

				-- TODO: Click Sound
				props.onClick()

				task.wait(debounceTime)
				debounce.current = false
			end;

			[React.Event.MouseEnter] = if isActive then function(...)
				setHovered(true)
				-- TODO: Hover Sound

				if typeof(props.onMouseEnter) == "function" then
					props.onMouseEnter(...)
				end
			end else nil;

			[React.Event.MouseLeave] = if isActive then function(...)
				setHovered(false)

				if typeof(props.onMouseLeave) == "function" then
					props.onMouseLeave(...)
				end
			end else nil;
		};

		Text = {
			Text = props.text or "";
		};

		UIStroke = {
			Thickness = camera.ViewportSize.Y * 0.002;
		};

		TextUIStroke = {
			Thickness = camera.ViewportSize.Y * 0.002;
		}
	})
end