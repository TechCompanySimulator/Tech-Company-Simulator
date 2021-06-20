-- Useful functions for Raycasting
-- Author: TheM0rt0nator

local Raycast = {}

-- Retuns a raycast result with the given arguments
function Raycast.new(filterInstances, filterType, origin, direction, length)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = filterInstances
    raycastParams.FilterType = Enum.RaycastFilterType[filterType]

    return workspace:Raycast(origin, direction * length, raycastParams)
end

return Raycast