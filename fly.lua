-- PC FLY + GUI
-- Для своей игры Roblox Studio

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character
local humanoid
local rootPart

local flying = false
local speed = 60

local bodyVelocity
local bodyGyro
local flyConnection

-- =========================================
-- CHARACTER
-- =========================================

local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
	setupCharacter(char)

	if flying then
		flying = false
	end
end)

-- =========================================
-- GUI
-- =========================================

local gui = Instance.new("ScreenGui")
gui.Name = "PCFlyGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 270, 0, 150)
main.Position = UDim2.new(0.5, -135, 0, 40)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 90, 120)
stroke.Thickness = 1.5
stroke.Parent = main

-- Title

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "✈  PC FLY"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- Status

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 28)
status.Position = UDim2.new(0, 10, 0, 48)
status.BackgroundTransparency = 1
status.Text = "FLY: OFF"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.TextSize = 17
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

-- Speed

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, -10, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 85)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 60"
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
speedLabel.TextSize = 15
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = main

-- Button

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 100, 0, 35)
flyButton.Position = UDim2.new(1, -110, 0, 82)
flyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
flyButton.Text = "FLY [F]"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextSize = 14
flyButton.Font = Enum.Font.GothamBold
flyButton.Parent = main

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 9)
buttonCorner.Parent = flyButton

-- =========================================
-- FLY
-- =========================================

local function stopFly()
	flying = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
	end

	status.Text = "FLY: OFF"
	status.TextColor3 = Color3.fromRGB(255, 80, 80)
	flyButton.Text = "FLY [F]"
end

local function startFly()
	if not character or not humanoid or not rootPart then
		return
	end

	flying = true

	humanoid.PlatformStand = true
	humanoid.AutoRotate = false

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = rootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 10000
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart

	status.Text = "FLY: ON"
	status.TextColor3 = Color3.fromRGB(80, 255, 120)
	flyButton.Text = "STOP [F]"

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flying or not character or not rootPart then
			return
		end

		local camera = workspace.CurrentCamera

		local moveDirection = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection += camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection -= camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection -= camera.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection += camera.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection += Vector3.new(0, 1, 0)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDirection -= Vector3.new(0, 1, 0)
		end

		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit * speed
		end

		bodyVelocity.Velocity = moveDirection

		local look = camera.CFrame.LookVector

		bodyGyro.CFrame = CFrame.lookAt(
			rootPart.Position,
			rootPart.Position + look
		)
	end)
end

local function toggleFly()
	if flying then
		stopFly()
	else
		startFly()
	end
end

-- =========================================
-- INPUT
-- =========================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		toggleFly()
	end
end)

flyButton.MouseButton1Click:Connect(function()
	toggleFly()
end)

-- =========================================
-- SPEED CONTROL
-- =========================================

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0, 100, 0, 30)
speedButton.Position = UDim2.new(0, 10, 0, 115)
speedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
speedButton.Text = "Speed +10"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextSize = 13
speedButton.Font = Enum.Font.Gotham
speedButton.Parent = main

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedButton

speedButton.MouseButton1Click:Connect(function()
	speed += 10

	if speed > 200 then
		speed = 20
	end

	speedLabel.Text = "Speed: " .. speed
end)

-- =========================================
-- RESPAWN SAFETY
-- =========================================

player.CharacterAdded:Connect(function()
	stopFly()
end)
