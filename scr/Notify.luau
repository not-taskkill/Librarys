repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

gservice = game.GetService
gdestroy = game.Destroy
tonum = tonumber
tostr = tostring
parent = nil
inew = function(InstanceIdentity, Propertys)
	local InstanceCreatedSuccess, InstanceCreated = pcall(function()
		return Instance.new(InstanceIdentity)
	end)
	
	if not InstanceCreatedSuccess then
		return
	end
	
	for PropertyIdentity, PropertyValue in pairs(Propertys) do
		InstanceCreated[PropertyIdentity] = PropertyValue
	end
	
	return InstanceCreated
end

local BasePlayerGui = gservice(game, "StarterGui")
local CoreGui = gservice(game, "CoreGui")

local function HookMusic(Id)
	local IsNumber = tonum(Id)
	local realSound = nil
	
	if IsNumber then
		realSound = `rbxassetid://{tostr(Id)}`
	else
		realSound = Id
	end
	
	local Sound = inew("Sound", {
		Volume = 1,
		SoundId = realSound
	})
	
	if parent then
		Sound.Parent = parent
	else
		if get_hidden_gui or gethui then
			local hiddenUI = get_hidden_gui or gethui
			Sound.Parent = hiddenUI()
			parent = hiddenUI()
		elseif CoreGui:FindFirstChild("RobloxGui") then
			parent = CoreGui.RobloxGui
		else
			Sound.Parent = CoreGui
			parent = CoreGui
		end
	end
	
	if not Sound.Loaded then
		Sound.Loaded:Wait()
	end
	
	Sound:Play()
	
	Sound.Ended:Once(function()
		pcall(gdestroy, Sound)
	end)
end

local Notify = function(NotificationArguments)
	BasePlayerGui:SetCore("SendNotification", {
		Title = NotificationArguments["Title"] or "",
		Text = NotificationArguments["Subtitle"] or "",
		Icon = NotificationArguments["Icon"] or "",
		Duration = NotificationArguments["Duration"] or 5
	})
	
	if NotificationArguments["SoundId"] then
		HookMusic(NotificationArguments["SoundId"])
	end
end

return Notify