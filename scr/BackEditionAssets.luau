-- Don't use that module.
-- This module needs a rework

local BackiEditionAssets = {}

local function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
base64dec = missing("function", base64decode or base64_decode or crypt and crypt.base64decode or Base64Decode or Base64_Decode)
waxwritefile, waxreadfile = writefile, readfile
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
waxgetcustomasset = missing("function", getcustomasset or getsynasset)

local BackiEditionImages = {}
local BackiEditionSounds = {}

local UserInputService = game:GetService("UserInputService")

local IsOnMobile = nil
xpcall(function()
	IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())
end, function()
	IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end)

local function CreateFileOrFolder(path, content, folder)
	if isfile(path) or isfolder(path) then
		return
	end

	if folder then
		makefolder(path)
	else
		writefile(path, content)
	end
end

local function SendToArray(t, k, v)
	t[k] = v
end

for _, folder in {"TaskHub", "TaskHub/Forsaken", "TaskHub/Forsaken/BackiEdition", "TaskHub/Forsaken/BackiEdition/assets"} do
	CreateFileOrFolder(folder, nil, true)
end

function BackiEditionAssets:GetAssets(TaskHubScriptIdentity, ShouldPrintAssetLoading)
	local soundBasePath = "TaskHub/Forsaken/BackiEdition/sounds/"

	local soundData = {
		{ "BackiSound1.mp3",  "rbxassetid://70542612197339" },
		{ "BackiSound2.mp3",  "rbxassetid://2796806401" },
		{ "BackiSound3.mp3",  "rbxassetid://129247666293361" },
		{ "BackiSound4.mp3",  "rbxassetid://70904367354423" },
		{ "BackiSound5.mp3",  "rbxassetid://92665389750132" },
		{ "BackiSound6.mp3",  "rbxassetid://72209573879445" },
		{ "BackiSound7.mp3",  "rbxassetid://81079187158300" },
		{ "BackiSound8.mp3",  "rbxassetid://139366645110326" },
		{ "BackiSound9.mp3",  "rbxassetid://96913434421788" },
		{ "BackiSound10.mp3", "rbxassetid://131803555321436" },
		{ "BackiSound11.mp3", "https://raw.githubusercontent.com/not-taskkill/op-rep/refs/heads/main/Musics/You%20Flirping%20Twitt.txt" }
	}

	for _, data in ipairs(soundData) do
		SendToArray(
			BackiEditionSounds,
			soundBasePath .. data[1],
			data[2]
		)
	end


	local basePath = "TaskHub/Forsaken/BackiEdition/assets/"
	local baseUrl = "https://raw.githubusercontent.com/not-taskkill/op-rep/refs/heads/main/Images/TaskHub-BackHubi/"

	local totalImages = 31

	for i = 1, totalImages do
		local imageName = "BackiImage" .. i
		local imagePath = basePath .. imageName .. ".png"
		local imageUrl = baseUrl .. imageName .. ".txt"

		local bytecode = base64dec(game:HttpGetAsync(imageUrl))
		CreateFileOrFolder(imagePath, bytecode, false)

		if IsOnMobile then
			CreateFileOrFolder(string.format("%s/.nomedia", basePath), "", false)
		end

		local asset = waxgetcustomasset(imagePath)
		BackiEditionImages[imagePath] = asset

		if ShouldPrintAssetLoading then
			print(string.format("[%s]: loading image -> %s", TaskHubScriptIdentity, imageName))
		end
	end

	for path, source in pairs(BackiEditionSounds) do
		if source:match("^https://") then
			local bytecode = base64dec(game:HttpGetAsync(source))
			CreateFileOrFolder(path, bytecode, false)

			local asset = waxgetcustomasset(path)
			BackiEditionSounds[path] = asset
		end

		if IsOnMobile then
			CreateFileOrFolder(string.format("%s/.nomedia", soundBasePath), "", false)
		end

		if ShouldPrintAssetLoading then
			print(string.format("[%s]: loading sound -> %s", TaskHubScriptIdentity, source))
		end
	end

	return BackiEditionSounds, BackiEditionImages
end

return BackiEditionAssets