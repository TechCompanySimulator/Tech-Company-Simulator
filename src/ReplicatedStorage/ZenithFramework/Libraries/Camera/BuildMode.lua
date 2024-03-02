-- Build mode camera where you can move around with WASD and the camera is angled down by 45 degrees. Can also rotate the camera with the keys E and Q and zoom in / out

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if RunService:IsServer() then return {} end

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local UserInput = loadModule("UserInput")
local Controls = require(Player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local camTypeChanged = getDataStream("CamTypeChanged", "BindableEvent")

local buildModeCam = {}

local inputs = {
	movement = {
		[Enum.KeyCode.W] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "Forward";
			vector = Vector2.new(0, -1);
		};
		[Enum.KeyCode.A] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "Left";
			vector = Vector2.new(-1, 0);
		};
		[Enum.KeyCode.S] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "Back";
			vector = Vector2.new(0, 1);
		};
		[Enum.KeyCode.D] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "Right";
			vector = Vector2.new(1, 0);
		};

		[Enum.KeyCode.DPadUp] = {
			inputType = Enum.UserInputType.Gamepad1;
			direction = "Forward";
			vector = Vector2.new(0, 1);
		};
		[Enum.KeyCode.DPadLeft] = {
			inputType = Enum.UserInputType.Gamepad1;
			direction = "Left";
			vector = Vector2.new(-1, 0);
		};
		[Enum.KeyCode.DPadDown] = {
			inputType = Enum.UserInputType.Gamepad1;
			direction = "Back";
			vector = Vector2.new(0, -1);
		};
		[Enum.KeyCode.DPadRight] = {
			inputType = Enum.UserInputType.Gamepad1;
			direction = "Right";
			vector = Vector2.new(1, 0);
		};
	};

	rotation = {
		[Enum.KeyCode.Q] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "RotateRight";
			vector = -1;
		};
		[Enum.KeyCode.E] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "RotateLeft";
			vector = 1;
		};
	};
}

-- Reset the values back to default and account for any keys which area already pressed
local function resetValues()
	local forwardVector = UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0
	local leftVector = UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
	local backwardVector = UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
	local rightVector = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0

	local rotateRight = UserInputService:IsKeyDown(Enum.KeyCode.Q) and -1 or 0
	local rotateLeft = UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0

	buildModeCam = {
		moveVector = Vector2.new(leftVector + rightVector, forwardVector + backwardVector);
		rotationVector = rotateRight + rotateLeft;
		moving = false;
		rotating = false;
		moveSpeed = 0.5;
		rotateSpeed = 0.8;
		zoomSpeed = 2;
		maxZoom = 50;
		currentOffset = Vector2.new(20, 20);
		prevOrigin = nil;
	}
end

-- Move camera, taking into account the current offset and always look at the origin
local function moveCam(self)
	if self.currentType ~= "BuildMode" then
		RunService:UnbindFromRenderStep("BuildModeCamMove")
	end

	local unitVector = Vector3.new(buildModeCam.moveVector.X, 0, buildModeCam.moveVector.Y)
	local potentialNext = buildModeCam.origin * CFrame.new(unitVector * buildModeCam.moveSpeed)
	local moveVector = potentialNext.Position - buildModeCam.origin.Position
	if buildModeCam.plotSize and moveVector.Magnitude > 0 then
		local additionalVectorX, additionalVectorZ = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
		local objSpace = buildModeCam.startCF:ToObjectSpace(potentialNext)
		-- Get the vector in object space in the X and Z directions (relative to orientation of startCF)
		local xVec = ((buildModeCam.startCF * CFrame.new(1, 0, 0)).Position - buildModeCam.startCF.Position).Unit
		local zVec = ((buildModeCam.startCF * CFrame.new(0, 0, 1)).Position - buildModeCam.startCF.Position).Unit

		-- Get the component of our movement vectors in the direction of the axial vectors above
		local xComp, zComp = moveVector.Unit:Dot(xVec) / xVec.Magnitude, moveVector.Unit:Dot(zVec) / zVec.Magnitude

		-- If our next position is going to be past the bounds, add a vector to cancel out the vector in that axis
		if objSpace.X < buildModeCam.xLowerBound or objSpace.X > buildModeCam.xUpperBound then
			additionalVectorX = -xComp * xVec
		end

		if objSpace.Z < buildModeCam.zLowerBound or objSpace.Z > buildModeCam.zUpperBound then
			additionalVectorZ = -zComp * zVec
		end

		local finalVector = (moveVector.Unit + additionalVectorX + additionalVectorZ) * buildModeCam.moveSpeed
		-- Make sure the new point doesn't exceed the square bound
		local newOrigin = buildModeCam.origin + finalVector
		if (newOrigin.Position - buildModeCam.startCF.Position).Magnitude < ((buildModeCam.plotSize * math.sqrt(2)) / 2) then
			-- Add all the vectors together
			buildModeCam.origin = newOrigin
		end

		-- Add something here to try and stop the jittering in the corners / edges when at an angle
	end
	local offsetCF = buildModeCam.origin * CFrame.new(0, buildModeCam.currentOffset.Y, buildModeCam.currentOffset.X) * CFrame.new(0, -1, 6)
	Camera.CFrame = CFrame.new(offsetCF.Position, buildModeCam.origin.Position)
	buildModeCam.prevOrigin = buildModeCam.origin
end

-- Rotate cameras origin
local function rotateCam(self)
	if self.currentType ~= "BuildMode" then
		RunService:UnbindFromRenderStep("BuildModeCamRotate")
	end

	buildModeCam.origin *= CFrame.Angles(0, math.rad(buildModeCam.rotationVector * buildModeCam.rotateSpeed), 0)
	if not buildModeCam.moving then
		moveCam(self)
	end
end

-- Set cameras offset and move the camera if not already moving
local function zoomCam(self, input)
	local direction = input.Position.Z > 0 and -1 or 1
	local currentOffset = buildModeCam.currentOffset
	local newX = currentOffset.X + direction * buildModeCam.zoomSpeed
	local newY = currentOffset.Y + direction * buildModeCam.zoomSpeed
	buildModeCam.currentOffset = Vector2.new(math.clamp(newX, 1, buildModeCam.maxZoom), math.clamp(newY, 1, buildModeCam.maxZoom))
	if not buildModeCam.moving then
		moveCam(self)
	end
	if not buildModeCam.rotating then
		rotateCam(self)
	end
end

-- Bind camera movement to render stepped
local function bindCamMovement(self)
	RunService:BindToRenderStep("BuildModeCamMove", 0, function()
		moveCam(self)
	end)
end

local function bindCamRotation(self)
	RunService:BindToRenderStep("BuildModeCamRotate", 0, function()
		rotateCam(self)
	end)
end

-- If the camera is moving, bind the input, if not then unbind it
local function checkMovementVector(self)
	if buildModeCam.moveVector ~= Vector2.new(0, 0) and not buildModeCam.moving then
		buildModeCam.moving = true
		bindCamMovement(self)
	elseif buildModeCam.moveVector == Vector2.new(0, 0) and buildModeCam.moving then
		buildModeCam.moving = false
		RunService:UnbindFromRenderStep("BuildModeCamMove")
	end
end

local function checkRotationVector(self)
	if buildModeCam.rotationVector ~= 0 and not buildModeCam.rotating then
		buildModeCam.rotating = true
		bindCamRotation(self)
	elseif buildModeCam.rotationVector == 0 and buildModeCam.rotating then
		buildModeCam.rotating = false
		RunService:UnbindFromRenderStep("BuildModeCamRotate")
	end
end

-- Connect / disconnect camera movement inputs
local function connectInputs(self)
	-- Connect movement inputs
	for keycode, info in pairs(inputs.movement) do
		UserInput.connectInput(info.inputType, keycode, "MoveCam" .. info.direction, {
			beganFunc = function()
				buildModeCam.moveVector += info.vector
				checkMovementVector(self)
			end;

			endedFunc = function()
				buildModeCam.moveVector -= info.vector
				checkMovementVector(self)
			end;
		})
	end

	-- Connect rotation inputs
	for keycode, info in pairs(inputs.rotation) do
		UserInput.connectInput(info.inputType, keycode, "Cam" .. info.direction,  {
			beganFunc = function()
				buildModeCam.rotationVector += info.vector
				checkRotationVector(self)
			end;

			endedFunc = function()
				buildModeCam.rotationVector -= info.vector
				checkRotationVector(self)
			end;
		})
	end

	-- Connect scroll wheel inputs
	UserInput.connectInput(Enum.UserInputType.MouseWheel, nil, "Zoom", {
		changedFunc = function(input)
			zoomCam(self, input)
		end;
	})

	-- Connect right mouse button rotation
	UserInput.connectInput(Enum.UserInputType.MouseButton2, nil, "RightMouseButton", {
		beganFunc = function(originalInput)
			local prevPos = originalInput.Position
			UserInput.connectInput(Enum.UserInputType.MouseMovement, nil, "MouseMovement", {
				changedFunc = function(input)
					local mousePos = input.Position
					buildModeCam.origin *= CFrame.Angles(0, math.rad(prevPos.X - mousePos.X) * 0.1, 0)
					if not buildModeCam.moving then
						moveCam(self)
					end

					prevPos = mousePos
				end
			})
		end;
		endedFunc = function()
			UserInput.disconnectInput(Enum.UserInputType.MouseMovement, "MouseMovement")
		end;
	})
end

local function disconnectInputs()
	-- Disconnect movement inputs
	for _, info in pairs(inputs.movement) do
		UserInput.disconnectInput(info.inputType, "MoveCam" .. info.direction)
	end

	-- Disconnect rotation inputs
	for _, info in pairs(inputs.rotation) do
		UserInput.disconnectInput(info.inputType, "Cam" .. info.direction)
	end

	-- Disconnect scroll wheel inputs
	UserInput.disconnectInput(Enum.UserInputType.MouseWheel, "Zoom")

	RunService:UnbindFromRenderStep("BuildModeCamMove")
	RunService:UnbindFromRenderStep("BuildModeCamRotate")
end

return function(self, startCFrame, plotLength)
	Controls:Disable()
	resetValues()
	Camera.CameraType = Enum.CameraType.Scriptable
	if startCFrame then
		buildModeCam.startCF = startCFrame
		buildModeCam.origin = startCFrame
		buildModeCam.plotSize = plotLength
	end

	if plotLength then
		buildModeCam.xLowerPos = buildModeCam.startCF * CFrame.new(-buildModeCam.plotSize / 2, 0, 0)
		buildModeCam.xUpperPos = buildModeCam.startCF * CFrame.new(buildModeCam.plotSize / 2, 0, 0)
		buildModeCam.zLowerPos = buildModeCam.startCF * CFrame.new(0, 0, -buildModeCam.plotSize / 2)
		buildModeCam.zUpperPos = buildModeCam.startCF * CFrame.new(0, 0, buildModeCam.plotSize / 2)

		buildModeCam.xLowerBound = buildModeCam.startCF:ToObjectSpace(buildModeCam.xLowerPos).X
		buildModeCam.xUpperBound = buildModeCam.startCF:ToObjectSpace(buildModeCam.xUpperPos).X
		buildModeCam.zLowerBound = buildModeCam.startCF:ToObjectSpace(buildModeCam.zLowerPos).Z
		buildModeCam.zUpperBound = buildModeCam.startCF:ToObjectSpace(buildModeCam.zUpperPos).Z
	end

	moveCam(self)
	rotateCam(self)
	connectInputs(self)

	local camTypeChangedConnection
	camTypeChangedConnection = camTypeChanged.Event:Connect(function(newType)
		if newType ~= "BuildMode" then
			camTypeChangedConnection:Disconnect()
			camTypeChangedConnection = nil
			disconnectInputs()
			Controls:Enable()
		end
	end)
end