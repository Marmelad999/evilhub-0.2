--// UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "LevelBound Helper",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "AutoAttack + ESP",
	ConfigurationSaving = {
		Enabled = false
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

player.CharacterAdded:Connect(function(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
end)

--// Remote
local AttackRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AttackV2")

-------------------------------------------------
-- SETTINGS
-------------------------------------------------

local AutoAttackEnabled = false
local AttackRange = 20
local AttackCooldown = 0.15

local ESPStates = {
	Mobs = false,
	Ruby = false,
	GoldBag = false,
	Chest = false,
	SecretChest = false,
	ChallengeRug = false
}

local ESPColors = {
	Mobs = Color3.fromRGB(255,255,255),
	Ruby = Color3.fromRGB(220,20,60),
	GoldBag = Color3.fromRGB(255,0,255),
	Chest = Color3.fromRGB(255,215,0),
	SecretChest = Color3.fromRGB(170,0,255),
	ChallengeRug = Color3.fromRGB(0,200,255)
}

local ActiveBillboards = {}

-------------------------------------------------
-- Direction
-------------------------------------------------

local function getDirectionString(targetHRP)

	local vec = targetHRP.Position - hrp.Position
	local mag = vec.Magnitude

	if mag == 0 then
		return "0, 0, 1"
	end

	local dir = vec / mag

	return string.format("%f, %f, %f", dir.X, dir.Y, dir.Z)

end

-------------------------------------------------
-- MOBS IN RANGE
-------------------------------------------------

local function getMobsInRange()

	local mobs = {}

	for _, mob in ipairs(Workspace.Characters:GetChildren()) do

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

-------------------------------------------------
-- AUTO ATTACK
-------------------------------------------------

task.spawn(function()

	while true do

		if AutoAttackEnabled and hrp then

			for _,mob in ipairs(getMobsInRange()) do

				local mobHRP = mob:FindFirstChild("HumanoidRootPart")

				if mobHRP then

					local direction = getDirectionString(mobHRP)

					AttackRemote:FireServer(5,1,mob)
					AttackRemote:FireServer(4,1,direction)

				end

			end

		end

		task.wait(AttackCooldown)

	end

end)

-------------------------------------------------
-- BILLBOARD CREATION
-------------------------------------------------

local function createBillboard(obj,text,color)

	if ActiveBillboards[obj] then return end

	local part

	if obj:IsA("Model") then
		part = obj:FindFirstChild("HumanoidRootPart")
	else
		part = obj
	end

	if not part then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP"
	billboard.Adornee = part
	billboard.Size = UDim2.new(0,140,0,40)
	billboard.StudsOffset = Vector3.new(0,3,0)
	billboard.AlwaysOnTop = true

	local label = Instance.new("TextLabel")
	label.Parent = billboard
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0,0,0)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold

	billboard.Parent = part

	ActiveBillboards[obj] = billboard

end

local function removeBillboard(obj)

	local gui = ActiveBillboards[obj]

	if gui then
		gui:Destroy()
		ActiveBillboards[obj] = nil
	end

end

-------------------------------------------------
-- ESP APPLY
-------------------------------------------------

local function applyESP(obj)

	if obj:IsA("Model") and ESPStates.Mobs then
		if obj ~= character and not Players:GetPlayerFromCharacter(obj) then
			createBillboard(obj,obj.Name,ESPColors.Mobs)
		end
	end

	if obj.Name == "Ruby" and ESPStates.Ruby then
		createBillboard(obj,"Ruby",ESPColors.Ruby)
	end

	if obj.Name == "GoldBag" and ESPStates.GoldBag then
		createBillboard(obj,"GoldBag",ESPColors.GoldBag)
	end

	if obj.Name == "Chest" and ESPStates.Chest then
		createBillboard(obj,"Chest",ESPColors.Chest)
	end

	if obj.Name == "SecretChest" and ESPStates.SecretChest then
		createBillboard(obj,"SecretChest",ESPColors.SecretChest)
	end

	if obj.Name == "ChallengeRug" and ESPStates.ChallengeRug then
		createBillboard(obj,"Challenge",ESPColors.ChallengeRug)
	end

end

-------------------------------------------------
-- WORLD SCAN
-------------------------------------------------

local function scanWorld()

	for _,obj in ipairs(Workspace:GetDescendants()) do
		applyESP(obj)
	end

end

-------------------------------------------------
-- TRACK NEW OBJECTS
-------------------------------------------------

Workspace.DescendantAdded:Connect(function(obj)
	task.defer(function()
		applyESP(obj)
	end)
end)

-------------------------------------------------
-- UI
-------------------------------------------------

local CombatTab = Window:CreateTab("Combat",4483362458)

CombatTab:CreateToggle({
	Name = "Auto Attack",
	CurrentValue = false,
	Callback = function(v)
		AutoAttackEnabled = v
	end
})

CombatTab:CreateSlider({
	Name = "Attack Range",
	Range = {5,100},
	Increment = 1,
	CurrentValue = 20,
	Callback = function(v)
		AttackRange = v
	end
})

CombatTab:CreateSlider({
	Name = "Attack Cooldown",
	Range = {0.05,1},
	Increment = 0.01,
	CurrentValue = 0.15,
	Callback = function(v)
		AttackCooldown = v
	end
})

-------------------------------------------------

local VisualTab = Window:CreateTab("Visuals",4483362458)

local function createESPToggle(name,key)

	VisualTab:CreateToggle({
		Name = name,
		CurrentValue = false,
		Callback = function(v)

			ESPStates[key] = v

			if v then
				scanWorld()
			else
				for obj,gui in pairs(ActiveBillboards) do
					if gui then
						gui:Destroy()
					end
				end
				ActiveBillboards = {}
			end

		end
	})

end

createESPToggle("Mob ESP","Mobs")
createESPToggle("Ruby ESP","Ruby")
createESPToggle("GoldBag ESP","GoldBag")
createESPToggle("Chest ESP","Chest")
createESPToggle("Secret Chest ESP","SecretChest")
createESPToggle("Challenge ESP","ChallengeRug")

-------------------------------------------------

Rayfield:Notify({
	Title = "Loaded",
	Content = "AutoAttack + Full ESP Ready",
	Duration = 5
})
