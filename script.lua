--// AutoAttack Script (Multi Target)

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "AutoAttack",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "Rayfield UI",
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

--// Direction function (NaN protection)
local function getDirectionString(targetHRP)

	local vec = targetHRP.Position - hrp.Position
	local mag = vec.Magnitude

	if mag == 0 then
		return "0, 0, 1"
	end

	local dir = vec / mag

	return string.format("%f, %f, %f", dir.X, dir.Y, dir.Z)

end

--// Get all mobs in range
local function getMobsInRange()

	local mobs = {}

	for _, mob in ipairs(Workspace.Characters:GetChildren()) do

		if mob == character then
			continue
		end

		-- ignore players
		if Players:GetPlayerFromCharacter(mob) then
			continue
		end

		local mobHRP = mob:FindFirstChild("HumanoidRootPart")
		local hum = mob:FindFirstChildOfClass("Humanoid")

		if not mobHRP or not hum then
			continue
		end

		if hum.Health <= 0 then
			continue
		end

		local distance = (mobHRP.Position - hrp.Position).Magnitude

		if distance <= AttackRange then
			table.insert(mobs, mob)
		end

	end

	return mobs

end

--// AutoAttack loop
task.spawn(function()

	while true do

		if AutoAttackEnabled and hrp then

			local mobs = getMobsInRange()

			for _, mob in ipairs(mobs) do

				local mobHRP = mob:FindFirstChild("HumanoidRootPart")

				if mobHRP then

					local direction = getDirectionString(mobHRP)

					-- Target
					AttackRemote:FireServer(5,1,mob)

					-- Direction
					AttackRemote:FireServer(4,1,direction)

				end

			end

		end

		task.wait(AttackCooldown)

	end

end)

--// UI
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
	Suffix = "Range",
	CurrentValue = 20,
	Callback = function(v)
		AttackRange = v
	end
})

CombatTab:CreateSlider({
	Name = "Attack Cooldown",
	Range = {0.05,1},
	Increment = 0.01,
	Suffix = "s",
	CurrentValue = 0.15,
	Callback = function(v)
		AttackCooldown = v
	end
})

Rayfield:Notify({
	Title = "Loaded",
	Content = "Multi Target AutoAttack Ready",
	Duration = 5
})
