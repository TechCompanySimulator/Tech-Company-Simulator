-- Useful functions to do with time
-- Author: TheM0rt0nator

local Time = {}

-- Returns the Unix Timestamp in seconds
function Time:GetCurrentUnixTime()
	local now = DateTime.now()

	return now.UnixTimestamp
end

-- Returns the Unix Timestamp in milliseconds
function Time:GetCurrentUnixTimeMillis()
	local now = DateTime.now()

	return now.UnixTimestampMillis
end

return Time