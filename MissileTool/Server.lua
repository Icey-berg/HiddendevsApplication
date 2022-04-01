local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()

local TweenService = game:GetService("TweenService")
local TI = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local tool = script.Parent
local RadiusOuter = game.ReplicatedStorage:WaitForChild("RadiusOuter")
local RadiusInner = game.ReplicatedStorage:WaitForChild("RadiusInner")

local RadiusInnerValue = tool:WaitForChild("RadiusInner").Value * 2
local RadiusOuterValue = tool:WaitForChild("RadiusOuter").Value * 2

tool.Activated:Connect(function()
	if mouse.hit then
		script.Parent.FireMissiles:FireServer(mouse.Hit)
	end
end)

tool.Equipped:Connect(function() --// Create the ffects
	
	tool.EquipSound:Play()
	character.HumanoidRootPart.Anchored = true
	local r1 = RadiusInner:Clone()
	r1.Parent = workspace
	r1.Position = character.HumanoidRootPart.Position
	
	local w1 = Instance.new("WeldConstraint")
	w1.Part0 = r1
	w1.Part1 = character.HumanoidRootPart
	w1.Parent = r1
		
	TweenService:Create(r1, TI, { Size = Vector3.new(RadiusInnerValue,RadiusInnerValue,RadiusInnerValue) }):Play()
	
	local r2 = RadiusOuter:Clone()
	r2.Parent = workspace
	r2.Position = character.HumanoidRootPart.Position

	local w2 = Instance.new("WeldConstraint")
	w2.Part0 = r2
	w2.Part1 = character.HumanoidRootPart
	w2.Parent = r2


	TweenService:Create(r2, TI, { Size = Vector3.new(RadiusOuterValue,RadiusOuterValue,RadiusOuterValue) }):Play()
	

end)

tool.Unequipped:Connect(function()
	character.HumanoidRootPart.Anchored = false
	TweenService:Create(workspace.RadiusInner, TI, { Size = Vector3.new(0,0,0) }):Play()
	TweenService:Create(workspace.RadiusOuter, TI, { Size = Vector3.new(0,0,0) }):Play()
	task.wait(0.5)
	workspace.RadiusInner:Destroy()
	workspace.RadiusOuter:Destroy()
end)
