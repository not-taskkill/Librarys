--//====================================================\\--
--||                     Variables                      ||--
--\\====================================================//--

local CurrentPlaceId = game.PlaceId
local CurrentPlaceVersion = game.PlaceVersion

local RNG

--//====================================================\\--
--||                     Functions                      ||--
--\\====================================================//--

-- idk what i am doing
local function getRNG()
	if not RNG then
		RNG = Random.new()
	end
	
	return RNG
end

local function getCurrentPlaceInfo()
	return game.PlaceId, game.PlaceVersion
end

local function toTable(Value)
	if Value then
		if typeof(Value) == "table" then
			return Value
		else
			return {Value}
		end
	end
end

local function randomBytes(len)
	return ("."):rep(len or getRNG():NextInteger(75, 100)):gsub(".", function()
		local b = buffer.create(1)
		buffer.writei8(b, 0, math.random(-128, 127))
		return buffer.tostring(b)
	end)
end

--//====================================================\\--
--||                   Module Config                    ||--
--\\====================================================//--

--// PlaceSignature is an improved replacement for the legacy PlaceCheck.luau
--// The legacy module is still supported but new scripts should use PlaceSignature

local PlaceSignature = {}

-- Checks whether the provided profile matches the current place signature
function PlaceSignature:Matches(Profile)
	if not Profile then
		warn(`{randomBytes()} [PlaceSignature]: no Profile.`)
		return
	end

	local Places = toTable(Profile.ExpectedPlace)
	local Versions = toTable(Profile.ExpectedVersion)

	local PlaceId, PlaceVersion = getCurrentPlaceInfo()

	local PlaceIdMatched
	local PlaceVersionMatched

	for idx, Place in pairs(Places) do
		if Place == PlaceId then
			PlaceIdMatched = idx
			break
		end
	end

	if not PlaceIdMatched then
		return false, "WrongPlace"
	end

	for idx, Version in pairs(Versions) do
		if idx == PlaceIdMatched and Version == PlaceVersion then
			PlaceVersionMatched = true
			break
		end
	end

	if not PlaceVersionMatched then
		if Profile.AllowOutdatedVersions then
			return {
				Result = true,
				MatchedPlace = PlaceIdMatched,
				IsOutdated = true
			}
		end

		return false, "WrongVersion"
	end

	return {
		Result = true,
		MatchedPlace = PlaceIdMatched,
		IsOutdated = false
	}
end

return PlaceSignature