local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Box = loadModule("Box")

local BoxSystem = {}
BoxSystem.boxes = {}

function BoxSystem.initiate()
	for _, box in CollectionService:GetTagged("Box") do
		task.spawn(BoxSystem.spawnBox, box)
	end

	CollectionService:GetInstanceAddedSignal("Box"):Connect(BoxSystem.spawnBox)
	CollectionService:GetInstanceRemovedSignal("Box"):Connect(BoxSystem.despawnBox)
end

function BoxSystem.spawnBox(box)
	if not box:IsDescendantOf(workspace) then return end

	local newBox = Box.new(box)
	BoxSystem.boxes[box] = newBox
end

function BoxSystem.despawnBox(box)
	if not BoxSystem.boxes[box] then return end

	BoxSystem.boxes[box]:Destroy()
	BoxSystem.boxes[box] = nil
end

return BoxSystem