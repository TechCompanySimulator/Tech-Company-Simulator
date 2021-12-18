local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Roact = loadModule("Roact")
local UICorner = loadModule("UICorner")

local SetInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local MainMenu = Roact.Component:extend("MainMenu")

function MainMenu:render()
	local mainMenu
	if not self.initiated or self.state.render then
		mainMenu = Roact.createElement("ScreenGui", {
			Enabled = self.props.visible:map(function(value)
				if value and not self.initiated then
					self.initiated = true
					Lighting:WaitForChild("Blur").Size = 20
				elseif not value and self.initiated then
					self:setState({
						render = false
					})
				end
				return value
			end)
		}, {
			Holder = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5);
				BackgroundTransparency = 1;
				Position = UDim2.new(0.5, 0, 0.5, 0);
				Name = "Holder";
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundColor3 = Color3.new(1, 1, 1);
			}, {
				Title = Roact.createElement("TextLabel", {
					FontSize = Enum.FontSize.Size14;
					TextColor3 = Color3.new(0.184, 0.471, 1);
					Text = "TECH COMPANY SIMULATOR";
					Name = "Title";
					Font = Enum.Font.TitilliumWeb;
					BackgroundTransparency = 1;
					Position = UDim2.new(0.277, 0, 0.174, 0);
					Size = UDim2.new(0.446, 0, 0.097, 0);
					RichText = true;
					TextScaled = true;
					BackgroundColor3 = Color3.new(1, 1, 1);
				});
			
				PlayButton = Roact.createElement("ImageButton", {
					Name = "PlayButton";
					Position = UDim2.new(0.407, 0, 0.564, 0);
					Size = UDim2.new(0.185, 0, 0.1, 0);
					BackgroundColor3 = Color3.new(1, 1, 1);
					[Roact.Event.MouseButton1Click] = function()
						SetInterfaceState:Fire("gameplay")
						Lighting:WaitForChild("Blur").Size = 0
					end
				}, {
					UICorner = UICorner(0.2, 0);
			
					TextLabel = Roact.createElement("TextLabel", {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0, 0, 0);
						Text = "PLAY";
						AnchorPoint = Vector2.new(0.5, 0.5);
						Font = Enum.Font.SourceSansBold;
						BackgroundTransparency = 1;
						Position = UDim2.new(0.5, 0, 0.5, 0);
						Size = UDim2.new(0.9, 0, 0.9, 0);
						TextScaled = true;
						BackgroundColor3 = Color3.new(1, 1, 1);
					});
				});
			})
		})
	end
	return mainMenu
end

return MainMenu