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
-- ↑ function from DexRefined

local function Create(Class, Properties)
	if not Class then return end
	
	Properties = Properties or {}
	
	local success, CreatedClass = pcall(function()
		return Instance.new(Class)
	end)
	
	if not success then
		--// error(`cannot create this Instance -> {tostring(Class)}`)
	end
	
	for Entry, Value in pairs(Properties) do
		CreatedClass[Entry] = Value
	end
	
	return CreatedClass
end

local ugc = hCloneref(game)
local rng = Random.new(os.clock())

repeat task.wait() until ugc:IsLoaded()

local CoreGui = hCloneref(ugc:GetService("CoreGui"))
local BasePlayerGui = hCloneref(ugc:GetService("StarterGui")) -- hmm
local Contentr = hCloneref(ugc:GetService("ContentProvider"))
local Players = hCloneref(ugc:GetService("Players"))
-- ↑ i will make a better way to get services later

local LocalUser = hCloneref(Players.LocalPlayer)

local HiddenSource = nil
if gethui or get_hidden_gui or get_hidden_ui then
	local hiddenUI = gethui or get_hidden_gui or get_hidden_u
	HiddenSource = hiddenUI()
elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
	local hiddenUI = Create("ScreenGui", {
		Name = "Notification",
		ResetOnSpawn = false,
		Parent = CoreGui
	})
	syn.protect_gui(hiddenUI)
	HiddenSource = hiddenUI
elseif CoreGui:FindFirstChild("RobloxGui") then
	HiddenSource = CoreGui.RobloxGui
else
	local hiddenUI = Create("ScreenGui", {
		Name = "Notification",
		ResetOnSpawn = false,
		Parent = CoreGui
	})
	HiddenSource = hiddenUI
end

local function randomString()
	local length = rng:NextInteger(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(rng:NextInteger(32, 126))
	end
	return table.concat(array)
end

local function SendNotification(Array)
	Array.Title = Array.Title or ""
	Array.Text = Array.Text or ""
	Array.Icon = Array.Icon or ""
	Array.Duration = Array.Duration or 6.5
	
	local success, err = pcall(function()
		BasePlayerGui:SetCore("SendNotification", {
			Title = Array.Title,
			Text = Array.Text,
			Icon = Array.Icon,
			Duration = Array.Duration
		})
	end)
	
	if not success then
		--// error(`cannot display notifications through starter gui -> {tostring(err)}`)
	end
	
	if Array.Sound then
		local isString = type(Array.Sound) == "string" or false
		local isNumber = type(Array.Sound) == "number" or false
		local Id
		if isString then
			if Array.Sound:match("^rbxasset://") or Array.Sound:match("^rbxassetid://") then
				Id = Array.Sound
			else
				Id = `rbxassetid://{Array.Sound}`
			end
		elseif isNumber then
			Id = `rbxassetid://{tostring(Array.Sound)}`
		else
			return
		end
		
		local Sound = Create("Sound", {
			Name = randomString(),
			SoundId = Id,
			Volume = 1,
			Parent = HiddenSource
		})

		Sound.Ended:Once(function()
			Sound:Destroy()
		end)

		Sound:Play()
	end
end

local success, result = pcall(function()
	if getgenv()[`{LocalUser.UserId or LocalUser.Name}_cBypassAlreadyDone`] then
		return "bypass has been already done"
	end
	
	-- ContentProvider Bypasses
	local randomizedCoreGuiTable;
	local randomizedGameTable;

	local coreguiTable = {}

	game:GetService("ContentProvider"):PreloadAsync({CoreGui}, function(assetId) --use preloadasync to patch preloadasync :troll:
		if not assetId:find("rbxassetid://") then
			table.insert(coreguiTable, assetId);
		end
	end)
	local gameTable = {}

	for i, v in pairs(game:GetDescendants()) do
		if v:IsA("ImageLabel") then
			if v.Image:find('rbxassetid://') and v:IsDescendantOf(CoreGui) then else
				table.insert(gameTable, v.Image)
			end
		end
	end

	function randomizeTable(t)
		local n = #t
		while n > 0 do
			local k = math.random(n)
			t[n], t[k] = t[k], t[n]
			n = n - 1
		end
		return t
	end

	local ContentProviderBypass
	ContentProviderBypass = hookmetamethod(game, "__namecall", function(self, Instances, ...)
		local method = getnamecallmethod();
		local args = ...;

		if not checkcaller() and (method == "preloadAsync" or method == "PreloadAsync") then
			if Instances and Instances[1] and self.ClassName == "ContentProvider" then
				if Instances ~= nil then
					if typeof(Instances[1]) == "Instance" and (table.find(Instances, CoreGui) or table.find(Instances, game)) then
						if Instances[1] == CoreGui then
							randomizedCoreGuiTable = randomizeTable(coreguiTable)
							return ContentProviderBypass(self, randomizedCoreGuiTable, ...)
						end

						if Instances[1] == game then
							randomizedGameTable = randomizeTable(gameTable)
							return ContentProviderBypass(self, randomizedGameTable, ...)
						end
					end
				end
			end
		end

		return ContentProviderBypass(self, Instances, ...)
	end)

	local preloadBypass; preloadBypass = hookfunction(Content.PreloadAsync, function(a, b, c)
		if not checkcaller() then
			if typeof(a) == "Instance" and tostring(a) == "ContentProvider" and typeof(b) == "table" then
				if (table.find(b, CoreGui) or table.find(b, game)) and not (table.find(b, true) or table.find(b, false)) then
					if b[1] == CoreGui then -- Double Check
						randomizedCoreGuiTable = randomizeTable(coreguiTable)
						return preloadBypass(a, randomizedCoreGuiTable, c)
					end
					if b[1] == game then -- Triple Check
						randomizedGameTable = randomizeTable(gameTable)
						return preloadBypass(a, randomizedGameTable, c)
					end
				end
			end
		end

		return preloadBypass(a, b, c)
	end)
	
	getgenv()[`{LocalUser.UserId or LocalUser.Name}_cBypassAlreadyDone`] = true
end)

if not success then
	--// warn("your executor doesn't support the bypass script you can be detected to game anti-cheat any time.")
end

local Notification = {}

function Notification:Send(Array)
	--[[ print("Notification Send Request.")
	print("Attempting to get the arguments..")
	for Key, Value in pairs(Array) do
		print(`Key -> {Key} | Value -> {Value}`)
	end
	print("Done with arguments starting function..") ]]
	task.spawn(SendNotification, Array)
end

return Notification