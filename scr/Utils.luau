local hCloneref = cloneref or clonereference or clone_reference or function(ref)
	if not getreg then return ref end

	local InstanceList

	local a = Instance.new("Part")
	for _, c in pairs(getreg()) do
		if type(c) == "table" and #c then
			if rawget(c, "__mode") == "kvs" then
				for d, e in pairs(c) do
					if e == a then
						InstanceList = c
						break
					end
				end
			end
		end
	end
	local f = {}
	function f.invalidate(g)
		if not InstanceList then
			return
		end
		for b, c in pairs(InstanceList) do
			if c == g then
				InstanceList[b] = nil
				return g
			end
		end
	end
	return f.invalidate
end

local SimpleCache = {
	Randomizer = Random.new(),
	ProtectedUI = nil
}

local ugc = hCloneref(game)

local CoreGui = hCloneref(ugc:GetService("CoreGui"))
local BasePlayerGui = hCloneref(ugc:GetService("StarterGui"))

local function Create(Class, Properties)
	if type(Class) ~= "string" then
		return nil
	end
	
	local ok, CreatedClass = pcall(function()
		return Instance.new(Class)
	end)
	
	if not ok then
		return nil
	end
	
	if type(Properties) == "table" then
		for k, v in pairs(Properties) do
			pcall(function()
				CreatedClass[k] = v
			end)
		end
	end
	
	return CreatedClass
end

local function randomString()
	local length = SimpleCache.Randomizer:NextInteger(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(SimpleCache.Randomizer:NextInteger(32, 126))
	end
	return table.concat(array)
end

local function toTable(Value)
	if type(Value) == "table" then
		return Value
	else
		return {Value}
	end
end

local function getCurrentPlaceData()
	return ugc.PlaceId, ugc.PlaceVersion
end

if gethui or get_hidden_ui or get_hidden_gui then
	local HiddenUI = gethui or get_hidden_ui or get_hidden_gui
	SimpleCache.ProtectedUI = HiddenUI()
elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
	local HiddenUI = Create("ScreenGui", {
		Name = "Notification",
		ResetOnSpawn = false,
		Parent = CoreGui
	})
	syn.protect_gui(HiddenUI)
	SimpleCache.ProtectedUI = HiddenUI
elseif CoreGui:FindFirstChild("RobloxGui") then
	SimpleCache.ProtectedUI = CoreGui.RobloxGui
else
	local HiddenUI = Create("ScreenGui", {
		Name = "Notification",
		ResetOnSpawn = false,
		Parent = CoreGui
	})
	SimpleCache.ProtectedUI = HiddenUI
end

local function SendNotification(Array)
	Array.Title = Array.Title or ""
	Array.Text = Array.Text or ""
	Array.Icon = Array.Icon or ""
	Array.Duration = Array.Duration or 6.5

	local success = pcall(function()
		BasePlayerGui:SetCore("SendNotification", {
			Title = Array.Title,
			Text = Array.Text,
			Icon = Array.Icon,
			Duration = Array.Duration
		})
	end)

	if not success then
		return
	end

	if Array.Sound then
		local isString = type(Array.Sound) == "string" or false
		local isNumber = type(Array.Sound) == "number" or false
		local Id
		if isString then
			if Array.Sound:match("^rbxasset://") or Array.Sound:match("^rbxassetid://") then
				Id = Array.Sound
			else
				Id = string.format("rbxassetid://%s", tostring(Array.Sound))
			end
		elseif isNumber then
			Id = string.format("rbxassetid://%s", tostring(Array.Sound))
		else
			return
		end

		local Sound = Create("Sound", {
			Name = randomString(),
			SoundId = Id,
			Volume = 1,
			Parent = SimpleCache.ProtectedUI
		})

		Sound.Ended:Once(function()
			Sound:Destroy()
		end)

		Sound:Play()
	end
end

pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/secretisadev/Babyhamsta_Backup/refs/heads/main/Universal/Bypasses.lua", true))()
end)

local Utils = {}

local PlaceSignature = {}
local Notification = {}
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
	local self = setmetatable({}, Janitor)
	self.Items = {}

	return self
end

function Janitor:Add(key, obj)
	self.Items[key] = obj
end

function Janitor:SyncConnection(Signal, func)
	local Connection
	local key = randomString()

	Connection = Signal:Connect(function(...)
		func(Connection, key, ...)
	end)

	self:Add(key, Connection)
	return Connection, key
end

function Janitor:Remove(key)
	local obj = self.Items[key]

	if not obj then
		return
	end

	if type(obj) == "thread" then
		task.cancel(obj)
	elseif typeof(obj) == "RBXScriptConnection" then
		obj:Disconnect()
	elseif typeof(obj) == "Instance" then
		pcall(ugc.Destroy, obj)
	end

	self.Items[key] = nil
end

function Janitor:Cleanup()
	for key, _ in pairs(self.Items) do
		self:Remove(key)
	end
end

function PlaceSignature:Matches(Profile)
	if not Profile or type(Profile) ~= "table" then
		return false, {
			StatusMessage = "no_profile_provided"
		}
	end

	local PlaceId, PlaceVersion = getCurrentPlaceData()
	local ResolvedId, SupportedVersion = nil, nil

	local ProvidedPlaces = toTable(Profile.ExpectedPlace)
	local ProvidedVersions = toTable(Profile.ExpectedVersion)

	for _, v in pairs(ProvidedPlaces) do
		if v == PlaceId then
			ResolvedId = v
			break
		end
	end

	if not ResolvedId then
		return false, {
			StatusMessage = "unsupported_location"
		}
	end

	for k, v in pairs(ProvidedVersions) do
		if k == ResolvedId and v == PlaceVersion then
			SupportedVersion = v
			break
		end
	end

	if not SupportedVersion then
		if Profile.AllowOutdatedVersions then
			return true, {
				ResolvedId = ResolvedId,
				IsOutdated = true,
				StatusMessage = "outdated_but_allowed"
			}
		end

		return false, {
			StatusMessage = "outdated_version"
		}
	end

	return true, {
		ResolvedId = ResolvedId,
		SupportedVersion = SupportedVersion,
		IsOutdated = false,
		StatusMessage = "success"
	}
end

function Notification:Send(Array)
	SendNotification(Array)
end

function Utils:Inject()
	local Modules = {
		["simpleJanitor"] = Janitor,
		["PlaceSignature"] = PlaceSignature,
		["Notification"] = Notification
	}
	
	for key, value in Modules do
		getfenv()[key] = value
	end
end

return Utils