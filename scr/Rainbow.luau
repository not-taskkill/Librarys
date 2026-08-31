--[[
	@Rainbow - v3
	@author: . . .
	
	sorry this is vibecoded because, i was bored and tired. I will change later
	A lightweight HSV color cycler for Roblox.

	Features:
		- Single RenderStepped connection per Rainbow instance
		- Multiple listeners/signals supported
		- Automatic cleanup
		- Delta-time based hue progression
		- Immutable options
]]

export type RainbowOptions = {
	Incrementer: number?,
	Saturation: number?,
	Brightness: number?
}

export type Rainbow = {
	new: (Options: RainbowOptions?) -> Rainbow,

	CreateSignal: (self: Rainbow) -> RBXScriptSignal,
	Destroy: (self: Rainbow) -> (),

	SetIncrementer: (self: Rainbow, Value: number) -> (),
	SetSaturation: (self: Rainbow, Value: number) -> (),
	SetBrightness: (self: Rainbow, Value: number) -> (),

	GetColor: (self: Rainbow) -> Color3
}

local RunService = game:GetService("RunService")

local LemonSignal = require(script.LemonSignal)

local Rainbow = {}
Rainbow.__index = Rainbow

local DEFAULT_INCREMENTER = 0.06
local DEFAULT_SATURATION = 1
local DEFAULT_BRIGHTNESS = 1

local function clamp01(Value: number): number
	return math.clamp(Value, 0, 1)
end

local function validateNumber(Value: any, Default: number): number
	if type(Value) ~= "number" or Value ~= Value then
		return Default
	end

	return Value
end

function Rainbow.new(Options: RainbowOptions?): Rainbow
	Options = Options or {}

	local self = setmetatable({
		_signal = LemonSignal.new(),
		_connection = nil,

		_hue = 0,
		_incrementer = validateNumber(
			Options.Incrementer,
			DEFAULT_INCREMENTER
		),

		_saturation = clamp01(validateNumber(
			Options.Saturation,
			DEFAULT_SATURATION
			)),

		_brightness = clamp01(validateNumber(
			Options.Brightness,
			DEFAULT_BRIGHTNESS
			)),

		_destroyed = false,
	}, Rainbow)

	self._connection = RunService.RenderStepped:Connect(function(dt)
		if self._destroyed then
			return
		end

		self._hue = (self._hue + self._incrementer * dt) % 1

		self._signal:Fire(
			Color3.fromHSV(
				self._hue,
				self._saturation,
				self._brightness
			)
		)
	end)

	return self
end

function Rainbow:CreateSignal(): RBXScriptSignal
	assert(not self._destroyed, "Rainbow has been destroyed")

	return self._signal
end

function Rainbow:SetIncrementer(Value: number)
	assert(not self._destroyed, "Rainbow has been destroyed")
	assert(type(Value) == "number", "Incrementer must be a number")

	self._incrementer = Value
end

function Rainbow:SetSaturation(Value: number)
	assert(not self._destroyed, "Rainbow has been destroyed")
	assert(type(Value) == "number", "Saturation must be a number")

	self._saturation = clamp01(Value)
end

function Rainbow:SetBrightness(Value: number)
	assert(not self._destroyed, "Rainbow has been destroyed")
	assert(type(Value) == "number", "Brightness must be a number")

	self._brightness = clamp01(Value)
end

function Rainbow:GetColor(): Color3
	assert(not self._destroyed, "Rainbow has been destroyed")

	return Color3.fromHSV(
		self._hue,
		self._saturation,
		self._brightness
	)
end

function Rainbow:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end

	if self._signal then
		self._signal:Destroy()
		self._signal = nil
	end
end

return Rainbow