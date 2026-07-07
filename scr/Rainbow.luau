local SignalPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexanderLindholt/SignalPlus/refs/heads/main/source/init.luau"))()

local Rainbow = {}
local Signals = {}

local function randomString()
	local length = math.random(10, 20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

function Rainbow:CreateSignal(Saturation: number?, Brightness: number?, Speed: number?)
	Saturation = Saturation or 1
	Brightness = Brightness or 1
	Speed = Speed or 0.06
	
	local hue = 0
	local loopThread = nil
	local key = randomString()
	local RainbowSignal = SignalPlus()
	
	loopThread = task.spawn(function()
		while task.wait(Speed) do
			hue = (hue + 0.01) % 1
			
			if RainbowSignal then
				RainbowSignal:Fire(Color3.fromHSV(hue, Saturation, Brightness))
			end
		end
	end)
	
	Signals[key] = {
		Signal = RainbowSignal,
		Loop = loopThread
	}
	
	return RainbowSignal, key
end

function Rainbow:DestroySignal(Key: string)
	if not Key then return end
	
	local Data = Signals[Key]
	if Data then
		task.cancel(Data.Loop)
		if Data.Signal then
			Data.Signal:Destroy()
		end
		
		Signals[Key] = nil
	end
end

return Rainbow