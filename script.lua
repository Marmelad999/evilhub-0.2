--// EvilHub 0.2

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "EvilHub 0.2",
	LoadingTitle = "EvilHub",
	LoadingSubtitle = "Loading...",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "EvilHub",
		FileName = "Settings"
	}
})

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
	humanoid = char:WaitForChild("Humanoid")
end)

--// Remote
local AttackRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AttackV2")

-------------------------------------------------
-- SETTINGS
-------------------------------------------------

local AutoAttack = false
local AttackRange = 20
local AttackCooldown = 0.15

local WalkSpeed = 16

local MobESP = false
local MiscESP = false

local ActiveESP = {}

-------------------------------------------------
-- Direction
-------------------------------------------------

local function getDirectionString(targetHRP)

	local vec = targetHRP.Position - hrp.Position
	local mag = vec.Magnitude

	if mag == 0 then
		return "0,0,1"
	end

	local dir = vec / mag

	return string.format("%f,%f,%f",dir.X,dir.Y,dir.Z)

end

-------------------------------------------------
-- AutoAttack
-------------------------------------------------

local function getMobs()

	local mobs = {}

	for _,mob in ipairs(Workspace.Characters:GetChildren()) do

		if mob == character then continue end
		if Players:GetPlayerFromCharacter(mob) then continue end

		local hum = mob:FindFirstChildOfClass("Humanoid")
		local mobHRP = mob:FindFirstChild("HumanoidRootPart")

		if not hum or not mobHRP then continue end
		if hum.Health <= 0 then continue end

		local dist = (mobHRP.Position - hrp.Position).Magnitude

		if dist <= AttackRange then
			table.insert(mobs,mob)
		end

	end

	return mobs

end

task.spawn(function()

	while true do

		if AutoAttack then

			for _,mob in ipairs(getMobs()) do

				local mobHRP = mob:FindFirstChild("HumanoidRootPart")

				if mobHRP then

					local dir = getDirectionString(mobHRP)

					AttackRemote:FireServer(5,1,mob)
					AttackRemote:FireServer(4,1,dir)

				end

			end

		end

		task.wait(AttackCooldown)

	end

end)

-------------------------------------------------
-- WalkSpeed Loop
-------------------------------------------------

task.spawn(function()

	while true do

		if humanoid then
			humanoid.WalkSpeed = WalkSpeed
		end

		task.wait(0.2)

	end

end)

-------------------------------------------------
-- ESP UI
-------------------------------------------------

local function createESP(obj,text,color)

	if ActiveESP[obj] then return end

	local part = obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") or obj
	if not part then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "ESP"
	gui.Adornee = part
	gui.Size = UDim2.new(0,110,0,26)
	gui.StudsOffset = Vector3.new(0,3,0)
	gui.AlwaysOnTop = true

	local frame = Instance.new("Frame")
	frame.Parent = gui
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
	frame.BackgroundTransparency = 0.35

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Parent = frame
	stroke.Color = color
	stroke.Thickness = 1

	local label = Instance.new("TextLabel")
	label.Parent = frame
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11

	gui.Parent = part

	ActiveESP[obj] = gui

end

local function removeESP(obj)

	if ActiveESP[obj] then
		ActiveESP[obj]:Destroy()
		ActiveESP[obj] = nil
	end

end

-------------------------------------------------
-- ESP Scanner
-------------------------------------------------

local function scanESP()

	for _,obj in ipairs(Workspace:GetDescendants()) do

		-- mobs
		if MobESP and obj:IsA("Model") then

			if obj ~= character and not Players:GetPlayerFromCharacter(obj) then
				createESP(obj,obj.Name,Color3.fromRGB(255,255,255))
			end

		end

		-- misc
		if MiscESP then

			if obj.Name == "Ruby" then
				createESP(obj,"Ruby",Color3.fromRGB(220,20,60))
			end

			if obj.Name == "GoldBag" then
				createESP(obj,"GoldBag",Color3.fromRGB(255,0,255))
			end

			if obj.Name == "Chest" then
				createESP(obj,"Chest",Color3.fromRGB(255,215,0))
			end

			if obj.Name == "SecretChest" then
				createESP(obj,"SecretChest",Color3.fromRGB(170,0,255))
			end

			if obj.Name == "ChallengeRug" then
				createESP(obj,"Challenge",Color3.fromRGB(0,200,255))
			end

		end

	end

end

task.spawn(function()

	while true do
		scanESP()
		task.wait(2)
	end

end)

-------------------------------------------------
-- UI
-------------------------------------------------

local CombatTab = Window:CreateTab("Combat",4483362458)

CombatTab:CreateToggle({
	Name = "Auto Attack",
	CurrentValue = false,
	Flag = "AutoAttack",
	Callback = function(v)
		AutoAttack = v
	end
})

CombatTab:CreateSlider({
	Name = "Attack Range",
	Range = {5,100},
	Increment = 1,
	CurrentValue = 20,
	Flag = "Range",
	Callback = function(v)
		AttackRange = v
	end
})

CombatTab:CreateSlider({
	Name = "Attack Cooldown",
	Range = {0.05,1},
	Increment = 0.01,
	CurrentValue = 0.15,
	Flag = "Cooldown",
	Callback = function(v)
		AttackCooldown = v
	end
})

CombatTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16,100},
	Increment = 1,
	CurrentValue = 16,
	Flag = "WalkSpeed",
	Callback = function(v)
		WalkSpeed = v
	end
})

-------------------------------------------------

local VisualTab = Window:CreateTab("Visuals",4483362458)

VisualTab:CreateToggle({
	Name = "Mob ESP",
	CurrentValue = false,
	Flag = "MobESP",
	Callback = function(v)
		MobESP = v
	end
})

VisualTab:CreateToggle({
	Name = "Misc ESP",
	CurrentValue = false,
	Flag = "MiscESP",
	Callback = function(v)
		MiscESP = v
	end
})

-------------------------------------------------

Rayfield:Notify({
	Title = "EvilHub 0.2",
	Content = "Loaded Successfully",
	Duration = 5
})
