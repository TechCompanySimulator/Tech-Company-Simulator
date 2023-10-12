local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local RoduxStore = loadModule("RoduxStore")

local pickupBoxEvent = getDataStream("pickupBoxEvent", "RemoteEvent")

local BOX_TAG = "MachineBox"

local boxAssets --= ReplicatedStorage.Assets.Boxes

local Box = {}
Box.__index = Box

if RunService:IsServer() then
	function Box.new(player : Player) : table
		local playerBoxLevel = RoduxStore:waitForValue("playerData", tostring(player.UserId), "BoxLevel")

		local self = setmetatable({
			player = player;
			model = boxAssets["Box" .. playerBoxLevel]:Clone();
			level = playerBoxLevel;
		}, Box)

		self.model:GiveAttribute("PlayerId", tostring(player.UserId))

		self.model.AncestoryChanged:Connect(function()
			if not self.model.Parent then
				self:placeOnSpawn()
			end
		end)
	end

	function Box:getSpawnPosition() : Vector3
		-- TODO:

		return Vector3.new(0, 0, 0)
	end

	function Box:placeOnSpawn() : nil
		local spawnPos = self:getSpawnPosition()

		self.model:SetPrimaryPartCFrame(CFrame.new(spawnPos))
		self.model.Parent = workspace
	end

	function Box:pickup()
		-- TODO: Weld to player
	end

	function Box:drop()
		pickupBoxEvent:FireClient(self.player)
	end
else
	function Box.isPlayersBox(boxModel : Model) : boolean
		local ownerId = boxModel:GetAttribute("PlayerId")

		return tostring(Players.LocalPlayer.UserId) == ownerId
	end

	function Box.setupBox(boxModel : Model)
		--[[
		local proxPrompt = ProximityPrompt.new({
			parent = boxModel.PrimaryPart;
		})

		Box.playerBox = boxModel
		Box.proxPrompt = proxPrompt

		proxPrompt:connect(Box.pickupBox)
		]]
	end

	function Box.pickupBox()
		pickupBoxEvent:FireServer()
		Box.proxPrompt:toggleEnabled(false)
	end

	function Box.start() : nil
		local boxes = CollectionService:GetTagged(BOX_TAG)

		for _, boxModel in boxes do
			if Box.isPlayersBox(boxModel) then
				Box.setupBox(boxModel)
				break
			end
		end

		CollectionService:GetInstanceAddedSignal(BOX_TAG):Connect(function(boxModel)
			if Box.isPlayersBox(boxModel) then
				Box.setupBox(boxModel)
			end
		end)

		pickupBoxEvent.OnClientEvent:Connect(function()
			if Box.proxPrompt then
				Box.proxPrompt:toggleEnabled(true)
			end
		end)
	end
end

return Box