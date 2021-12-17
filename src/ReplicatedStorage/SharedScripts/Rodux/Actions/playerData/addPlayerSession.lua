local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = table.unpack(require(ReplicatedStorage.ZenithFramework))

local makeActionCreator = require("makeActionCreator")

return makeActionCreator("addPlayerSession", function(userId, data)
    return {
        userId = userId,
        data = data,
    }
end)