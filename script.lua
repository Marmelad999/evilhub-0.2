```lua
--// Load UI
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

--// Settings
local AutoAttackEnabled = false
local AttackRange = 20
local AttackCooldown = 0.15

--// ESP Settings
local MobESPEnabled = false
local RubyESPEnabled = false

local ActiveBillboards = {}

-------------------------------------------------
-- Direction (NaN protection)
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
-- Get mobs in range
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
			table.insert(mobs, mob)
		end

	end

	return mobs

end

-------------------------------------------------
-- AutoAttack Loop
-------------------------------------------------

task.spawn(function()

	while true do

		if AutoAttackEnabled and hrp then

			local mobs = getMobsInRange()

			for _, mob in ipairs(mobs) do

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
-- Billboard ESP creation
-------------------------------------------------

local function createBillboard(obj, text, color)

	if ActiveBillboards[obj] then return end

	local part = obj:IsA("Model") and obj:FindFirstChild("Human
```
