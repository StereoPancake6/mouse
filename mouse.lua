

        if Settings.Prediction == true then
            local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            local split = string.split(pingvalue,'(')
            local ping = tonumber(split[1])
            if ping < 200 then
                 Settings.Prediction = 0.1865
            elseif ping < 190 then 
                 Settings.Prediction = 0.1848
            elseif ping < 180 then
                 Settings.Prediction = 0.1672
            elseif ping < 170 then
                 Settings.Prediction = 0.1663
            elseif ping < 160 then
                 Settings.Prediction = 0.1574
            elseif ping < 150 then
                 Settings.Prediction = 0.1555
            elseif ping < 140 then
                 Settings.Prediction = 0.1500
            elseif ping < 130 then
                Settings.Prediction = 0.1411
            elseif ping < 120 then
                 Settings.Prediction = 0.1344
            elseif ping < 110 then
                 Settings.Prediction = 0.1315
            elseif ping < 100 then
                 Settings.Prediction = 0.1300
            elseif ping < 90 then
                 Settings.Prediction = 0.1295
            elseif ping < 80 then
                 Settings.Prediction = 0.1290
            elseif ping < 70 then
                 Settings.Prediction = 0.1250
            elseif ping < 60 then
                 Settings.Prediction = 0.1230
            elseif ping < 50 then
                 Settings.Prediction = 0.1190
            elseif ping < 40 then
                 Settings.Prediction = 0.1100
            elseif ping < 30 then
                 Settings.Prediction = 0.1000
            elseif ping < 20 then
                 Settings.Prediction = 0.0920
end
end



task.spawn(function()

    while task.wait() do

        if Settings.Resolver and Settings.Aimpart ~= nil and (Settings.Humanoid)  then

            local oldVel = game.Players[Settings.Aimpart].Character.HumanoidRootPart.Velocity

            game.Players[Settings.Aimpart].Character.HumanoidRootPart.Velocity = Vector3.new(oldVel.X, -0, oldVel.Z)

        end 

    end

end)





Drawing = Drawing
mousemoverel = mousemoverel

local Locking = false
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()


local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera


local FOV_CIRCLE = Drawing.new("Circle")
FOV_CIRCLE.Filled = false
FOV_CIRCLE.Color = Color3.fromRGB(170, 255, 255)
FOV_CIRCLE.Radius = Settings.FOV_Radius
FOV_CIRCLE.Thickness = 1
FOV_CIRCLE.Visible = Settings.FOV_Visible
FOV_CIRCLE.Transparency = .35
FOV_CIRCLE.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)


local Move_Circle = nil
Move_Circle = RunService.RenderStepped:Connect(function()
	FOV_CIRCLE.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
end)


function InRadius()
	local Target = nil
	local Distance = 9e9
	local Camera = game:GetService("Workspace").CurrentCamera
	for _, v in pairs(Players:GetPlayers()) do 
		if v ~= LocalPlayer and v.Character and v.Character[Settings.Aimpart] and v.Character[Settings.Humanoid] and v.Character[Settings.Humanoid].Health > 0 then
			local Enemy = v.Character	
			local CastingFrom = CFrame.new(Camera.CFrame.Position, Enemy[Settings.Aimpart].CFrame.Position) * CFrame.new(0, 0, -4)
			local RayCast = Ray.new(CastingFrom.Position, CastingFrom.LookVector * 9000)
			local World, ToSpace = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(RayCast, {LocalPlayer.Character[Settings.Aimpart]});
			local RootWorld = (Enemy[Settings.Aimpart].CFrame.Position - ToSpace).magnitude
			if RootWorld < 4 then		
				local RootPartPosition, Visible = Camera:WorldToViewportPoint(Enemy[Settings.Aimpart].Position)
				if Visible then
					local Real_Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(RootPartPosition.X, RootPartPosition.Y)).Magnitude
					if Real_Magnitude < Distance and Real_Magnitude < FOV_CIRCLE.Radius then
						Distance = Real_Magnitude
						Target = Enemy
					end
				end
			end
		end
	end
	return Target
end


local Render_Lock = nil
function Aimbot()
	pcall(function()
		if Locking then
			local Enemy = InRadius()
			local Camera = game:GetService("Workspace").CurrentCamera
			local Predicted_Position = nil
			local GetPositionsFromVector3 = nil
			if Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health > 0 then		
				Render_Lock = RunService.Stepped:Connect(function()
					pcall(function()	
						if Locking and Enemy ~= nil and Enemy[Settings.Humanoid] and Enemy[Settings.Humanoid].Health > 0 then

							Predicted_Position = Enemy[Settings.Aimpart].Position + (Enemy[Settings.Aimpart].AssemblyLinearVelocity * Settings.Prediction + Settings.NeckOffSet)
							GetPositionsFromVector3 = Camera:WorldToScreenPoint(Predicted_Position)
							mousemoverel((GetPositionsFromVector3.X - Mouse.X) / Settings.Smoothness, (GetPositionsFromVector3.Y - Mouse.Y) / Settings.Smoothness)

						elseif Locking == false then
							Enemy = nil
						elseif Enemy == nil then
							Locking = false
						end
					end)
				end)
			end	
		end
	end)
end


Mouse.KeyDown:Connect(function(KeyPressed)
	if KeyPressed == string.lower(Settings.Toggle_Key) then
		pcall(function()
			if Locking == false then
				Locking = true
				Aimbot()
			elseif Locking == true then
				Locking = false
				Render_Lock:Disconnect()
			end
		end)
	end
end)


Mouse.KeyDown:Connect(function(Rejoin)
	if Rejoin == string.lower(Settings.Rejoin_Key) then
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) task.wait()
	end
end);


--Method used, MouseMoveRel. ( unpatchable and undetectable have fun patching this one my guy xddd )
