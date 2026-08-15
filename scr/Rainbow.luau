--[[

@Rainbow.luau
@author: TaskKill.

---// a simple rainbow mod provinding configurations and cleaning functions to free some memory.

]]

local myriadAPI = _myriadApi or loadstring(game:HttpGet("https://github.com/Standard-2/Myriad/releases/latest/download/api.luau"))()
if not _myriadApi then
    pcall(function()
        getgenv()._myriadApi = myriadAPI
    end)
end

local ClonerefCheckResult = myriadAPI.Standards.Checks.Instances.cloneref()
if ClonerefCheckResult ~= 200 then
    ClonerefCheckResult = false
end

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/Data-Oriented-House/LemonSignal/refs/heads/main/src/LemonSignal.lua"))()
local HttpService: HttpService = ClonerefCheckResult and cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")
local RunService: RunService = ClonerefCheckResult and cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local CurrentSignals = {}

local module = {}

--// this doens't return a signal but is just for typescript recognize
function module.Init(Saturation: number?, Brightness: number?, RainbowIncrementer: number?): (RBXScriptSignal, string)
    Saturation = Saturation or 1
    Brightness = Brightness or 1
    RainbowIncrementer = RainbowIncrementer or 0.06

    local randomindex = HttpService:GenerateGUID(false)
    local signal: RBXScriptSignal = Signal.new()
    local conn = nil
    local hue = 0

    conn = RunService.RenderStepped:Connect(function(dt)
        hue = (hue + RainbowIncrementer * dt) % 1
        
        if signal then
            signal:Fire(Color3.fromHSV(hue, Saturation, Brightness))
        end
    end)

    CurrentSignals[randomindex] = {
        RainbowSignal = signal,
        SteppedConnection = conn
    }

    return signal, randomindex
end

function module.GetAvaibleSignal(): RBXScriptSignal?
	local count = 0
	for _ in pairs(CurrentSignals) do 
        count += 1 
    end

	if count == 0 then 
        return nil
    end

	local choice = math.random(1, count)
	local index = 0

	for _, v in pairs(CurrentSignals) do
		index += 1

		if index == choice then
			return v.signal
		end
	end

	return nil
end

function module.Destroy(Index: string?)
    if type(Index) ~= "string" then
        return
    end

    local Data = CurrentSignals[Index]
    if Data then
        if Data.SteppedConnection and Data.SteppedConnection.Connected ~= false then
            Data.SteppedConnection:Disconnect()
        end

        if Data.RainbowSignal then
            Data.RainbowSignal:Destroy()
        end

        CurrentSignals[Index] = nil
    end
end

return module