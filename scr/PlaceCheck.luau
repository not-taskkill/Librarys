local module = {}

local function ToTable(value)
	if typeof(value) ~= "table" then
		return { value }
	else
		return value
	end
end

function module(Config)
	if typeof(Config) ~= "table" or Config.PlaceToCheck == nil then
		return false, "INVALID_CONFIG"
	end

	local placeId = game.PlaceId
	local placeVersion = game.PlaceVersion
	local places = ToTable(Config.PlaceToCheck)

	local matched = false

	for key, value in pairs(places) do
		local checkId =
			typeof(key) == "number" and key
			or typeof(value) == "number" and value
			or nil

		if checkId == placeId then
			matched = true
			break
		end
	end

	if not matched then
		return false, "WRONG_PLACE"
	end

	if Config.ExpectedPlaceVersion and placeVersion ~= Config.ExpectedPlaceVersion then
		if Config.AllowOutdated then
			return true, "OUTDATED"
		end
		return false, "OUTDATED"
	end

	return true, "OK"
end

return module