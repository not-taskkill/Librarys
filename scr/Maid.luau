local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid:GiveTask(Key, Task)
	if Task == nil then
		Task = Key
		Key = #self._tasks + 1
	end

	self:RemoveTask(Key)

	self._tasks[Key] = Task

	return Task
end

function Maid:IsTaskActive(Key)
	return self._tasks[Key] ~= nil
end

function Maid:GetTask(Key)
	return self._tasks[Key]
end

function Maid:RemoveTask(Key)
	local Task = self._tasks[Key]

	if not Task then
		return
	end
	
	self._tasks[Key] = nil
	
	if typeof(Task) == "RBXScriptConnection" then
		Task:Disconnect()
	elseif typeof(Task) == "function" then
		Task()
	elseif typeof(Task) == "Instance" then
		Task:Destroy()
	elseif typeof(Task) == "thread" then
		task.cancel(Task)
	elseif type(Task) == "table" and (Task.Cleanup or getmetatable(Task) == Maid) then
		Task:Cleanup()
	end
end

function Maid:Cleanup()
	for Key in self._tasks do
		self:RemoveTask(Key)
	end
end

return Maid