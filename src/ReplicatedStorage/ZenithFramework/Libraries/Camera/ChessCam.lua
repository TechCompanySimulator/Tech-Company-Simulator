local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local chessCamTypeChange = getDataStream("ChessCamTypeChange", "BindableEvent")
local camTypeChanged = getDataStream("CamTypeChanged", "BindableEvent")

local Maid = loadModule("Maid")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local currentType = "attach"

local ChessCam = {
	_maid = Maid.new()
}

-- Cam attaches to the board and can rotate the camera around it using mouse / swiping
function ChessCam.attachCam(self, board, seat)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CameraSubject = board.PrimaryPart
	local originalDist = 5
	local vectorDiff = (seat.Position - board.PrimaryPart.Position).Unit
	local diff = vectorDiff:Dot(board.PrimaryPart.Position)
	local side = diff < 0 and 1 or -1
	camera.CFrame = CFrame.new((board.PrimaryPart.CFrame * CFrame.new(0, originalDist, side * originalDist)).Position, board.PrimaryPart.Position)
	camera.CameraType = Enum.CameraType.Custom
end

-- Sets the camera to the current type
local function setCam(...)
	if typeof(ChessCam[currentType .. "Cam"]) == "function" then
		ChessCam[currentType .. "Cam"](...)
	end
end

return function(self, board, seat)
	setCam(self, board, seat)
	ChessCam._maid:GiveTask(chessCamTypeChange.Event:Connect(function(newType)
		if typeof(ChessCam[currentType .. "Cam"]) == "function" and self.currentType == "ChessCam" then
			currentType = newType
			setCam(self, board, seat)
		end
	end))
	ChessCam._maid:GiveTask(camTypeChanged.Event:Connect(function(newType)
		if newType ~= "ChessCam" then
			ChessCam._maid:DoCleaning()
		end
	end))
end