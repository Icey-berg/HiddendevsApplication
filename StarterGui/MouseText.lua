local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()
local Container = script.Parent:WaitForChild("Container")
local HumanoidText = Container:WaitForChild("HumanoidText")
local PositionText = Container:WaitForChild("PositionText")

function floorVector3(v3)
	local f = math.floor
	return Vector3.new(f(v3.X), f(v3.Y), f(v3.Z))
end

game:GetService("RunService").Heartbeat:Connect(function()
	if not character:FindFirstChild("Missile Rain") then
		Container.Visible = false
		return
	else
		Container.Visible = true
	end
	
	Container.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y + 15)
	
	local position = floorVector3(mouse.Hit.Position) --// mouse.Hit.Position returns a number which contains a lot of unnecessary decimal points
	if position then
		PositionText.Text = "X: ".. tostring(position.X) .. " Y: ".. tostring(position.Y) .. " Z: ".. tostring(position.Z)
	end
	
	local humanoidsInRange = (function()
		local h = 0
		for i, v in pairs(workspace.Living:GetChildren()) do
			if v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - position).Magnitude <= 4 then
				h +=1
			end
		end
		return tostring(h)
	end)()
	
	HumanoidText.Text = "Lifeforms: ".. humanoidsInRange
end)
