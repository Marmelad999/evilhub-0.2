--// EvilHub 0.23

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "EvilHub 0.23",
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

local Characters = Workspace:WaitForChild("Characters")
local Tower = Workspace:WaitForChild("Tower")

--// Player
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

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

local MobESPObjects = {}
local MiscESPObjects = {}

-------------------------------------------------
-- CHEST RARITY DATA
-------------------------------------------------

local chestRarity = {

	["Dark stone grey"] = {name = "COMMON", color = Color3.fromRGB(90,90,90)},
	["Earth green"] = {name = "UNCOMMON", color = Color3.fromRGB(60,170,90)},
	["Dark Royal blue"] = {name = "RARE", color = Color3.fromRGB(65,105,225)},
	["Mulberry"] = {name = "EPIC", color = Color3.fromRGB(197,75,140)},
	["CGA brown"] = {name = "LEGENDARY", color = Color3.fromRGB(205,127,50)},
	["Maroon"] = {name = "MYTHIC", color = Color3.fromRGB(128,0,0)},
	["Really black"] = {name = "CURSED", color = Color3.fromRGB(15,15,15)}

}

-------------------------------------------------
-- RESPAWN
-------------------------------------------------

player.CharacterAdded:Connect(function(char)

	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
	humanoid = char:WaitForChild("Humanoid")

end)

-------------------------------------------------
-- WALKSPEED FIX
-------------------------------------------------

task.spawn(function()

	while true do

		if humanoid then
			humanoid.WalkSpeed = WalkSpeed
		end

		task.wait(0.05)

	end

end)

-------------------------------------------------
-- AUTO ATTACK
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

local function getMobs()

	local mobs = {}

	for _,mob in ipairs(Characters:GetChildren()) do

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
-- ESP CREATION (HP VERSION)
-------------------------------------------------

local function createESP(part,text,color)

	local gui = Instance.new("BillboardGui")
	gui.Name = "EvilESP"
	gui.Size = UDim2.new(0,130,0,30)
	gui.StudsOffset = Vector3.new(0,3,0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 999999
	gui.Adornee = part

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
	frame.BackgroundTransparency = 0.25
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 1.5
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.6
	label.Text = text
	label.Parent = frame

	gui.Parent = part

	-- HP updater
	task.spawn(function()

		local model = part.Parent
		local hum = model and model:FindFirstChildOfClass("Humanoid")

		while gui.Parent and part.Parent do

			if hum then

				local hpPercent = math.floor((hum.Health / hum.MaxHealth) * 100)

				label.Text = text.." ["..hpPercent.."%]"

			end

			task.wait(0.25)

		end

	end)

	return gui

end

-------------------------------------------------
-- MOB ESP
-------------------------------------------------

local function addMobESP(mob)

	if not MobESP then return end
	if mob == character then return end
	if Players:GetPlayerFromCharacter(mob) then return end

	local hrp2 = mob:FindFirstChild("HumanoidRootPart")
	local hum = mob:FindFirstChildOfClass("Humanoid")

	if not hrp2 or not hum then return end
	if hum.Health <= 0 then return end

	if not MobESPObjects[hrp2] then

		MobESPObjects[hrp2] =
			createESP(hrp2,mob.Name,Color3.fromRGB(255,255,255))

	end

end

local function enableMobESP()

	for _,mob in ipairs(Characters:GetChildren()) do
		addMobESP(mob)
	end

end

local function disableMobESP()

	for _,esp in pairs(MobESPObjects) do
		esp:Destroy()
	end

	table.clear(MobESPObjects)

end

-- новые мобы
Characters.ChildAdded:Connect(function(mob)

	task.wait(0.2)

	addMobESP(mob)

end)

-- удаление мобов
Characters.ChildRemoved:Connect(function(mob)

	local hrp2 = mob:FindFirstChild("HumanoidRootPart")

	if hrp2 and MobESPObjects[hrp2] then

		MobESPObjects[hrp2]:Destroy()
		MobESPObjects[hrp2] = nil

	end

end)
-------------------------------------------------
-- MISC ESP + CHEST RARITY
-------------------------------------------------

local miscColors = {
	Ruby = Color3.fromRGB(220,20,60),
	GoldBag = Color3.fromRGB(255,0,255),
	ChallengeRug = Color3.fromRGB(0,200,255),
	EXPBook = Color3.fromRGB(0,255,120)
}

-------------------------------------------------
-- CHEST BILLBOARD
-------------------------------------------------

local function createChestBillboard(part, rarityName, color)

	local gui = Instance.new("BillboardGui")
	gui.Name = "ChestRarityESP"
	gui.Size = UDim2.new(0,140,0,30)
	gui.StudsOffset = Vector3.new(0,4,0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 999999
	gui.Adornee = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 14
	label.Text = rarityName
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.3
	label.Parent = gui

	gui.Parent = part

	return gui

end

-------------------------------------------------
-- CHEST DETECTION
-------------------------------------------------

local function detectChest(model)

	if MiscESPObjects[model] then return end

	local down = model:FindFirstChild("Down")
	local up = model:FindFirstChild("Up")

	local part = down or up
	if not part then return end

	local rarity = chestRarity[part.BrickColor.Name]
	if not rarity then return end

	-- Billboard
	local billboard = createChestBillboard(part, rarity.name, rarity.color)

	-- Highlight
	local highlight = Instance.new("Highlight")
	highlight.Name = "ChestESP"
	highlight.FillColor = rarity.color
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = rarity.color
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = model
	highlight.Parent = model

	MiscESPObjects[model] = {
		billboard = billboard,
		highlight = highlight
	}

end

-------------------------------------------------
-- MISC OBJECT ESP
-------------------------------------------------

local function addMiscESP(obj)

	if not MiscESP then return end

	-- CHEST ESP
	if obj.Name == "Chest" or obj.Name == "SecretChest" then
		detectChest(obj)
		return
	end

	local color = miscColors[obj.Name]
	if not color then return end

	if MiscESPObjects[obj] then return end

	if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "MiscESP"
	highlight.FillColor = color
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.new(1,1,1)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = obj
	highlight.Parent = obj

	MiscESPObjects[obj] = highlight

end

-------------------------------------------------
-- ENABLE / DISABLE
-------------------------------------------------

local function enableMiscESP()

	for _,obj in ipairs(Tower:GetDescendants()) do
		addMiscESP(obj)
	end

end

local function disableMiscESP()

	for obj,data in pairs(MiscESPObjects) do

		if typeof(data) == "table" then

			if data.billboard then
				data.billboard:Destroy()
			end

			if data.highlight then
				data.highlight:Destroy()
			end

		else

			data:Destroy()

		end

	end

	table.clear(MiscESPObjects)

end

-------------------------------------------------
-- OBJECT SPAWN
-------------------------------------------------

Tower.DescendantAdded:Connect(function(obj)
	addMiscESP(obj)
end)

Tower.DescendantRemoving:Connect(function(obj)

	local data = MiscESPObjects[obj]

	if data then

		if typeof(data) == "table" then

			if data.billboard then
				data.billboard:Destroy()
			end

			if data.highlight then
				data.highlight:Destroy()
			end

		else

			data:Destroy()

		end

		MiscESPObjects[obj] = nil

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
	Range = {0.01,1},
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

		if v then
			enableMobESP()
		else
			disableMobESP()
		end

	end
})

VisualTab:CreateToggle({
	Name = "Misc ESP",
	CurrentValue = false,
	Flag = "MiscESP",
	Callback = function(v)

		MiscESP = v

		if v then
			enableMiscESP()
		else
			disableMiscESP()
		end

	end
})

-------------------------------------------------

Rayfield:Notify({
	Title = "EvilHub 0.2",
	Content = "Loaded Successfully",
	Duration = 5
})




