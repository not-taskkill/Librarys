local WorkspaceDescendants = workspace:GetDescendants()

local function descendantAdded(instance: Instance)
	table.insert(WorkspaceDescendants, instance)
end

local Array = {}

function Array.remove(array, value)
	local index = table.find(array, value)
	if index then
		return table.remove(array, index)
	end
end

local function descendantRemoving(instance: Instance)
	Array.remove(WorkspaceDescendants, instance)
end

workspace.DescendantAdded:Connect(descendantAdded)
workspace.DescendantRemoving:Connect(descendantRemoving)

return WorkspaceDescendants