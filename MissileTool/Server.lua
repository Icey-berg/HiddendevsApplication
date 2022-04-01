local tool = script.Parent
local event = tool.FireMissiles

local min = tool.RadiusInner.Value
local max = tool.RadiusOuter.Value

local chaosFactor = 100 --// Determines how NOT smooth the bezier curves will be
local studsPerPathNode = 4 --// studsPerPathNode is used instead of a set amount of path nodes to eliminate uneven distribution, thus allowing linear missile speeds. Prevents: https://developer.roblox.com/assets/bltcdd5fd2ce9185675/Bezier8.gif Causes: https://developer.roblox.com/assets/blt2ee53c6a18bb5ec1/Bezier9.gif
local frameNodes = 5
local missiles = 15

local NodeTemplate = game.ReplicatedStorage.NodeTemplate

local TweenService = game:GetService("TweenService")
local tweenTimeMin = 10
local tweenTimeMax = 30

local explodeSound = game.SoundService.SmallExplosion
local missileModel = game.ReplicatedStorage.Missile

function multilerp(t, ...) --// Repeatively lerps through supplied points (arg 2) with the alpha declared in variable t (arg 1)
	local Points = {...}


	while #Points > 2 do --// Repeatively lerp until only 2 positions remain
		for i, v in pairs(Points) do
			local NextPoint = Points[i + 1]
			if NextPoint == nil then --// When the for loop reaches the last position/index, remove itself because it was already lerped in the previous iteration
				table.remove(Points, i)
			else
				Points[i] = v:Lerp(NextPoint, t)
			end
		end
	end

	return Points[1]:Lerp(Points[2], t) --// Lerp the final positions
end

event.OnServerEvent:Connect(function(player, hit)
	
	local character = player.Character
	if character.Humanoid.Health <= 0 then 
		return 
	end
	local root = character.HumanoidRootPart
	
	local targetPosition = hit.Position
	local distance = math.floor((targetPosition - root.Position).Magnitude)
	
	
	if distance <= max and distance >= min then
		
		local endNode = NodeTemplate:Clone()
		endNode.Position = targetPosition
		endNode.Transparency = 1
		endNode.Parent = workspace
				
		for i = 1, missiles do
			local framePositions = {}	
			
			local missileTweenTime = math.random(tweenTimeMin, tweenTimeMax) / (distance * 5)

			local missileTweenInfo = TweenInfo.new(missileTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			
			for i = 0, 1, 1/frameNodes do	
				
				local position = root.Position:Lerp(targetPosition, i)
				if i ~= 0 and i ~= 1 then --// Doing this will make sure that the missile isn't offset when it comes out of the player root (0) and also when it's arriving at the targetPosition (1) 
					position += Vector3.new(math.random(-chaosFactor, chaosFactor),math.random(0, chaosFactor*1.5),math.random(-chaosFactor, chaosFactor))
				end

				table.insert(framePositions, position)		
			end

			local pathPositions = {}
			
			--// Apply studsPerPathNode
			local goal = distance/studsPerPathNode 
			local increment = goal/distance 
			

			for i = 0, goal, increment do
				local position = multilerp(i/goal, table.unpack(framePositions))
				table.insert(pathPositions, position)
				--[[
				How does this work?
				Some values may not fully add up to one. For example: 0.3. The method used here fixes it by creating a number (goal) which the increment variable can 
				evenly divide into. Then we do i/goal to get a decimal percentage value which is used as t (lerp alpha)				
				]]
			end
			
			local missileNode = missileModel:Clone()
			missileNode.Position = root.Position
			missileNode.Parent = workspace
			missileNode.LaunchSound:Play()
			missileNode.FlyingSound:Play()
			
			task.spawn(function() --// Move the missile along the path. Use task.spawn() so that it doesnt yield the creation of all the other missiles.
				for i = 1, #pathPositions do
					local pathPos = pathPositions[i]
					
					local tweenGoal
					
					if i == #pathPositions then
						tweenGoal = { Position = pathPos }
					else
						tweenGoal = { CFrame = CFrame.new(pathPos, pathPositions[i + 1]) }
					end
					
					local tween = TweenService:Create(missileNode, missileTweenInfo, tweenGoal)
					tween:Play()
					task.wait(missileTweenTime - missileTweenTime/2) --// Avoid choppiness by cutting tweens slightly short
				end
				
				local explosion = Instance.new("Explosion") --// Create Explosion effect
				explosion.Position = missileNode.Position
				explosion.Parent = workspace
						
				--// Dont destroy the missile right away as the trail is still stretched. Destroying the missile with no delay will cause the trail to seamingling disappear and it would not look as aesthetic
				missileNode.Transparency = 1
				game.Debris:AddItem(missileNode, 0.6)
				
				local explosionSoundClone = explodeSound:Clone()
				explosionSoundClone.Parent = endNode
				explosionSoundClone:Play()
				
				explosionSoundClone.Ended:Wait()
				if i == #pathPositions then --// Destroy the endNode if currently on last missile
					endNode:Destroy()
				end
				
			end)			

		end
		
	end
end)
