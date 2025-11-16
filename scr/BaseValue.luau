--!optimize 2
--!nocheck
--!native

-- Deprecated but works.

local LemonSignal = loadstring(game:HttpGet("https://gitlab.com/not-taskkill/roblox/-/raw/main/librays/LemonSignal.lua?ref_type=heads"))()

local BaseValue = {}
BaseValue.__index = BaseValue

local ValueObject = {}
ValueObject.__index = ValueObject

function ValueObject.new(key: string, defaultValue: any, typeCheck: string?)
	local self = setmetatable({}, ValueObject)
	self._key = key
	self._value = defaultValue
	self._typeCheck = typeCheck
	self.OnChanged = LemonSignal.new()
	return self
end

function ValueObject:Get()
	return self._value
end

function ValueObject:Set(newValue)
	if self._typeCheck and typeof(newValue) ~= self._typeCheck then
		pcall(error, string.format("Type mismatch in BaseValue '%s': expected %s got %s", self._key, self._typeCheck, typeof(newValue)))
	end

	if self._value ~= newValue then
		local oldValue = self._value
		self._value = newValue
		self.OnChanged:Fire(newValue, oldValue)
	end
end

function ValueObject:Destroy()
	self.OnChanged:DisconnectAll()
	self.OnChanged:Destroy()
	self._value = nil
	self._key = nil
	self._typeCheck = nil
end

function BaseValue.new()
	local self = setmetatable({}, BaseValue)
	self._values = {}
	return self
end

function BaseValue:CreateValue(key: string, defaultValue: any, typeCheck: string?)
	if self._values[key] then
		return self._values[key]
	end

	local val = ValueObject.new(key, defaultValue, typeCheck)
	self._values[key] = val

	local proxy = {
		OnChanged = val.OnChanged,
		Get = function()
			return val:Get()
		end,
		Set = function(_, newValue)
			val:Set(newValue)
		end,
		Current = function()
			return val:Get()
		end,
	}

	local mt = {
		__index = proxy,
		__metatable = "meow!"
	}

	return setmetatable(proxy, mt)
end

function BaseValue:GetValue(key: string)
	local val = self._values[key]
	if val then
		return val:Get()
	else
		return nil
	end
end

function BaseValue:SetValue(key: string, value: any)
	local val = self._values[key]
	if val then
		val:Set(value)
	end
end

function BaseValue:DestroyValue(key: string)
	local val = self._values[key]
	if val then
		val:Destroy()
		self._values[key] = nil
	end
end

return BaseValue