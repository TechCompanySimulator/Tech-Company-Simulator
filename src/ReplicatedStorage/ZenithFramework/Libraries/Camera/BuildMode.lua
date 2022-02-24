local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local UserInput = loadModule("UserInput")
local Maid = loadModule("Maid")

local buildModeCam = {
	moveVector = Vector2.new(0, 0);
	rotationVector = 0;
	moving = false;
	rotating = false;
	moveSpeed = 0.5;
	rotateSpeed = 0.8;
	currentOffset = Vector2.new(0, 0);
}

local inputs = {
	movement = {
		[Enum.KeyCode.W] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "Forward";
			vector = Vector2.new(0, 1);
		};
		[Enum.KeyCode.A] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "Left";
			vector = Vector2.new(-1, 0);
		};
		[Enum.KeyCode.S] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "Back";
			vector = Vector2.new(0, -1);
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
			vector = 1;
		};
		[Enum.KeyCode.E] = {
			inputType = Enum.UserInputType.Keyboard;
			direction = "RotateLeft";
			vector = -1;
		};
	};
}

local function moveCam(self)
	if self.currentType ~= "BuildMode" then
		RunService:UnbindFromRenderStep("BuildModeCamMove")
	end

	local rightVector = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z) * buildModeCam.moveVector.X
	local forwardVector = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z) * buildModeCam.moveVector.Y
	local totalVector = rightVector + forwardVector
	Camera.CFrame += (totalVector.Unit * buildModeCam.moveSpeed)
end

local function rotateCam(self)
	if self.currentType ~= "BuildMode" then
		RunService:UnbindFromRenderStep("BuildModeCamRotate")
	end

	local angle = CFrame.Angles(0, math.rad(buildModeCam.rotationVector * buildModeCam.rotateSpeed), 0)
	local rotCF = angle:ToObjectSpace(Camera.CFrame)
	Camera.CFrame = CFrame.fromMatrix(Camera.CFrame.Position, rotCF.XVector, rotCF.YVector, rotCF.ZVector)
end


local function bindCamMovement(self)
	RunService:BindToRenderStep("BuildModeCamMove", 200, function()
		moveCam(self)
	end)
end

local function bindCamRotation(self)
	RunService:BindToRenderStep("BuildModeCamRotate", 200, function()
		rotateCam(self)
	end)
end


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
	elseif buildModeCam.moveVector == 0 and buildModeCam.rotating then
		buildModeCam.rotating = false
		RunService:UnbindFromRenderStep("BuildModeCamRotate")
	end
end


local function connectInputs(self)
	-- Connect movement inputs
	for keycode, info in pairs(inputs.movement) do
		UserInput.connectInput(info.inputType, keycode, "MoveCam" .. info.direction, function()
			buildModeCam.moveVector += info.vector
			checkMovementVector(self)
		end, function()
			buildModeCam.moveVector -= info.vector
			checkMovementVector(self)
		end)
	end

	-- Connect rotation inputs
	for keycode, info in pairs(inputs.rotation) do
		UserInput.connectInput(info.inputType, keycode, "Cam" .. info.direction, function()
			buildModeCam.rotationVector += info.vector
			checkRotationVector(self)
		end, function()
			buildModeCam.rotationVector -= info.vector
			checkRotationVector(self)
		end)
	end
end

return function(self, startCFrame)
	Camera.CameraType = Enum.CameraType.Scriptable
	if startCFrame then
		Camera.CFrame = startCFrame
	end
	connectInputs(self)
end