--!optimize 2

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
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
			warn(`[Notify Library]: Invalid RBX Service: {tostring(name)}`)
		end
	end,
	__metatable = "meow!"
})

local CoreGui = Services.CoreGui
local BasePlayerGui = Services.StarterGui

local function SendMessageFromCore(args)
	local Success, Result = pcall(function()
		BasePlayerGui:SetCore("SendNotification", {
			Title = args["Title"] or "",
			Text = args["Subtitle"] or "",
			Icon = args["Icon"] or "",
			Duration = args["Duration"] or 5
		})
	end)

	if not Success then
		warn(`[Notify Library]: Error on Sending Core Messages: {tostring(Result)}`)
	end
end

local function StartupSound(Id)
	local Ended
	local Sound = Instance.new("Sound")
	Sound.Name = "Notify Library - Sound"
	Sound.SoundId = `rbxassetid://{Id}`
	Sound.Volume = 1
	Sound.Parent = CoreGui

	Ended = Sound.Ended:Connect(function()
		pcall(game.Destroy, Sound)
		if Ended then
			Ended:Disconnect()
		end
	end)

	Sound:Play()
end

local Notify = {}

function Notify.new(title, subtitle, icon, duration, soundId)
	SendMessageFromCore({
		Title = title,
		Subtitle = subtitle,
		Icon = icon,
		Duration = duration
	})

	if soundId then
		StartupSound(soundId)
	end
end

return Notify