local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local SetInterfaceState = getDataStream("SetInterfaceState", "BindableEvent")

local Roact = loadModule("Roact")
local Flipper = loadModule("Flipper")

local LoadingScreen = Roact.Component:extend("LoadingScreen")

function LoadingScreen:init()
	self.loadProgress, self.setLoadingProgress = Roact.createBinding(UDim2.new(0, 0, 1, 0))
	self.progressMotor = Flipper.SingleMotor.new(0)
	self.progressMotor:onStep(function(newVal)
		self.setLoadingProgress(UDim2.new(newVal, 0, 1, 0))
	end)
end

function LoadingScreen:render()
	local loadingScreen
	if not self.isLoaded or self.state.render then
		loadingScreen = Roact.createElement("ScreenGui", {
			Enabled = self.props.visible:map(function(value)
				if value and not self.isLoading then
					self.isLoading = true
					self:load()
				elseif not value and self.isLoaded then
					self:setState({
						render = false;
					})
				end
				return value
			end);
		}, {
			Background = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.new(0.5, 0, 0.5, 0);
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundColor3 = Color3.new(1, 1, 1);
				BorderSizePixel = 0
			}, {
				LoadingBar = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0);
					Name = "LoadingBar";
					Position = UDim2.new(0.5, 0, 0.776, 0);
					ZIndex = 2;
					Size = UDim2.new(0, 786, 0, 97);
					BackgroundColor3 = Color3.new(1, 1, 1);
					BorderSizePixel = 0
				}, {
					Fill = Roact.createElement("Frame", {
						Name = "Fill";
						ZIndex = 2;
						Size = self.loadProgress;
						BackgroundColor3 = Color3.new(0.047, 1, 0);
						BorderSizePixel = 0
					});
				});
			})
		})
	end
	return loadingScreen
end

function LoadingScreen:load()
	task.spawn(function()
		while self.loadProgress:getValue().X.Scale < 1 do
			self.progressMotor:setGoal(Flipper.Spring.new(self.loadProgress:getValue().X.Scale + 0.01, {frequency = 10}))
			task.wait()
		end
		self.isLoaded = true
		SetInterfaceState:Fire("mainMenu")
	end)
end

return LoadingScreen