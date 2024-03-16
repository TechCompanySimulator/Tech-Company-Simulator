local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

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
local joinBindings = React.joinBindings
local camera = workspace.CurrentCamera

local buttonTemplate = RoactTemplate.fromInstance(React, ReplicatedStorage.Assets.ReactTemplates.Elements.Button)

return function(props: table): table
	local isHovered, setHovered = useBinding(false)
	local debounce = useRef(false)

	local buttonTypeBinding = if typeof(props.buttonType) ~= "string" then props.buttonType else nil

	local function isDisabled(): boolean
		local buttonType = if buttonTypeBinding then buttonTypeBinding:getValue() else props.buttonType

		return buttonType == "Disabled"
	end

	return e(buttonTemplate, {
		[RoactTemplate.Root] = props.buttonProps or {};

		Click = {
			BackgroundColor3 = joinBindings({
				buttonType = buttonTypeBinding;
				isHovered = isHovered;
			}):map(function(values: table): Color3
				local buttonType = if values.buttonType then values.buttonType else props.buttonType

				local buttonColours = BUTTON_STYLES[buttonType]

				if not buttonColours then
					warn("Invalid button type: " .. tostring(buttonType))
					buttonColours = BUTTON_STYLES.Standard
				end

				local index = if values.isHovered then "hover" else "default"

				return buttonColours[index]
			end);
			[React.Event.MouseButton1Click] = function(): nil
				if isDisabled() or debounce.current or typeof(props.onClick) ~= "function" then return end

				debounce.current = true

				-- TODO: Click Sound
				props.onClick()

				if props.debounce then
					task.wait(props.debounce)
				end

				debounce.current = false
			end;

			[React.Event.MouseEnter] = function(...): nil
				if isDisabled() then return end

				setHovered(true)
				-- TODO: Hover Sound

				if typeof(props.onMouseEnter) == "function" then
					props.onMouseEnter(...)
				end
			end;

			[React.Event.MouseLeave] = function(...): nil
				if isDisabled() then return end

				setHovered(false)

				if typeof(props.onMouseLeave) == "function" then
					props.onMouseLeave(...)
				end
			end;
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