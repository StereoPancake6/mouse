local Settings = {
	Aimpart = "HumanoidRootPart", "Head", "UpperTorso",
	Humanoid = "Humanoid",
	NeckOffSet = Vector3.new(0,tonumber(1),0);
	Resolver = true,
	FOV_Visible = true,
	FOV_Radius = 250 ,
	Smoothness = 4,
	Prediction = true,
	Rejoin_Key = "=",
	Toggle_Key = "E",
};

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




local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/StereoPancake6/ddd/main/depo.lua"))()

Aiming.TeamCheck(false)



local Workspace = game:GetService("Workspace")

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")



local LocalPlayer = Players.LocalPlayer

local Mouse = LocalPlayer:GetMouse()

local CurrentCamera = Workspace.CurrentCamera


---------------------------------------------------------------
local SilentSettings = {
    
    SilentAim = true,

    AimLock = true,

    Prediction = true,

    AimLockKeybind = Enum.KeyCode.E,

    Resolver = true,
    
}
--------------------------------------------------
getgenv().SilentSettings = SilentSettings        
getgenv().Aiming.ShowFOV = true
getgenv().Aiming.FOV = 5
getgenv().Aiming.FOVSides = 15
--------------------------------------------------- -fov 5.5-6.6 is legit

        if SilentSettings.Prediction == true then
            local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            local split = string.split(pingvalue,'(')
            local ping = tonumber(split[1])
            if ping < 200 then
                 SilentSettings.Prediction = 0.1865
            elseif ping < 190 then 
                 SilentSettings.Prediction = 0.1848
            elseif ping < 180 then
                 SilentSettings.Prediction = 0.1672
            elseif ping < 170 then
                 SilentSettings.Prediction = 0.1663
            elseif ping < 160 then
                 SilentSettings.Prediction = 0.1574
            elseif ping < 150 then
                 SilentSettings.Prediction = 0.1555
            elseif ping < 140 then
                 SilentSettings.Prediction = 0.1500
            elseif ping < 130 then
                SilentSettings.Prediction = 0.1411
            elseif ping < 120 then
                 SilentSettings.Prediction = 0.1344
            elseif ping < 110 then
                 SilentSettings.Prediction = 0.1315
            elseif ping < 100 then
                 SilentSettings.Prediction = 0.1300
            elseif ping < 90 then
                 SilentSettings.Prediction = 0.1295
            elseif ping < 80 then
                 SilentSettings.Prediction = 0.1290
            elseif ping < 70 then
                 SilentSettings.Prediction = 0.1250
            elseif ping < 60 then
                 SilentSettings.Prediction = 0.1230
            elseif ping < 50 then
                 SilentSettings.Prediction = 0.1190
            elseif ping < 40 then
                 SilentSettings.Prediction = 0.1100
            elseif ping < 30 then
                 SilentSettings.Prediction = 0.1000
            elseif ping < 20 then
                 SilentSettings.Prediction = 0.0920
end
end

function Aiming.Check()

    if not (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then

        return false

    end

    local Character = Aiming.Character(Aiming.Selected)

    local KOd = Character:WaitForChild("BodyEffects")["K.O"].Value

    local Grabbed = Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

    if (KOd or Grabbed) then

        return false

    end

    return true

end



task.spawn(function()

    while task.wait() do

        if SilentSettings.Resolver and Aiming.Selected ~= nil and (Aiming.Selected.Character)  then

            local oldVel = game.Players[Aiming.Selected.Name].Character.HumanoidRootPart.Velocity

            game.Players[Aiming.Selected.Name].Character.HumanoidRootPart.Velocity = Vector3.new(oldVel.X, -0, oldVel.Z)

        end 

    end

end)



local Script = {Functions = {}}



Script.Functions.getToolName = function(name)

    local split = string.split(string.split(name, "[")[2], "]")[1]

    return split

end



Script.Functions.getEquippedWeaponName = function(player)

   if (player.Character) and player.Character:FindFirstChildWhichIsA("Tool") then

      local Tool =  player.Character:FindFirstChildWhichIsA("Tool")

      if string.find(Tool.Name, "%[") and string.find(Tool.Name, "%]") and not string.find(Tool.Name, "Wallet") and not string.find(Tool.Name, "Phone") then 

         return Script.Functions.getToolName(Tool.Name)

      end

   end

   return nil

end



game:GetService("RunService").RenderStepped:Connect(function()

    if Script.Functions.getEquippedWeaponName(game.Players.LocalPlayer) ~= nil then

        local WeaponSettings = GunSettings[Script.Functions.getEquippedWeaponName(game.Players.LocalPlayer)]

        if WeaponSettings ~= nil then

            Aiming.FOV = WeaponSettings.FOV

        else

            Aiming.FOV = 5

        end

    end    

end)

local __index

__index = hookmetamethod(game, "__index", function(t, k)

    if (t:IsA("Mouse") and (k == "Hit" or k == "Target") and Aiming.Check()) then

        local SelectedPart = Aiming.SelectedPart

        if (SilentSettings.SilentAim and (k == "Hit" or k == "Target")) then

            local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * SilentSettings.Prediction)

            return (k == "Hit" and Hit or SelectedPart)

        end

    end



    return __index(t, k)

end)



RunService:BindToRenderStep("AimLock", 0, function()

    if (SilentSettings.AimLock and Aiming.Check() and UserInputService:IsKeyDown(SilentSettings.AimLockKeybind)) then

        local SelectedPart = Aiming.SelectedPart

        local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * SilentSettings.Prediction)

        CurrentCamera.CFrame = CFrame.lookAt(CurrentCamera.CFrame.Position, Hit.Position)

    end
end)
