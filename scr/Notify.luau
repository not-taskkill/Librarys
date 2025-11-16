--!optimize 2

-- Deprecated but works.

local Notify = {}
Notify.__index = Notify

-- ↓ stealed from inf yield
local function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

local function inew(name, properties)
	local ok, realInstance = pcall(function()
		return Instance.new(name)
	end)
	if not ok then
		return nil
	end

	for propertyName, propertyValue in pairs(properties) do
		realInstance[propertyName] = propertyValue
	end
	return realInstance
end

cloneref = missing("function", cloneref, function(...) return ... end)

Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			warn(`Invalid Roblox Service -> {tostring(name)}`)
		end
	end,
	__metatable = "meow!"
})

local BasePlayerGui = Services.StarterGui
local CoreGui = Services.CoreGui
local ContentProvider = Services.ContentProvider

local function RunSound()
	local EndedConnection
	local Sound = inew("Sound", {
		Volume = 1.5,
		SoundId = "rbxassetid://12221944",
		Parent = CoreGui
	})
	ContentProvider:PreloadAsync({Sound})
	EndedConnection = Sound.Ended:Connect(function()
		pcall(game.Destroy, Sound)
		if EndedConnection then
			EndedConnection:Disconnect()
			EndedConnection = nil
		end
		return
	end)
	
	Sound:Play()
end

function Notify.new(title, text, icon, duration, SoundEnabled)
	BasePlayerGui:SetCore("SendNotification", {
		Title = title or "",
		Text = text or "",
		Icon = icon or "",
		Duration = duration or 5
	})
	
	if SoundEnabled then
		RunSound()
	end
end

return Notify