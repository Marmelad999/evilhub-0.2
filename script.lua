-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
 Name = "Evilhub 0.2",
 LoadingTitle = "Initializing...",
 LoadingSubtitle = "Rayfield UI",
 ConfigurationSaving = {
  Enabled = true,
  FolderName = "LevelBound",
  FileName = "Config"
 }
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local AttackRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AttackV2")

-- настройки киллауры
local Aura = {
 Enabled = false,
 Range = 300,
 Delay = 0.2,
 Combo = 1
}

-- обновление персонажа
player.CharacterAdded:Connect(function(char)
 character = char
 hrp = char:WaitForChild("HumanoidRootPart")
 Aura.Combo = 1
end)

-- комбо система
local function nextCombo()

 Aura.Combo += 1

 if Aura.Combo > 3 then
  Aura.Combo = 1
 end

 return Aura.Combo

end

-- поиск ближайшей цели
local function getClosestTarget()

 local closest
 local dist = Aura.Range

 for _,model in ipairs(Workspace.Characters:GetChildren()) do

  if model ~= character then

   local hum = model:FindFirstChildOfClass("Humanoid")
   local thrp = model:FindFirstChild("HumanoidRootPart")
   local id = model:GetAttribute("ID")

   if hum and hum.Health > 0 and thrp and id then

    local d = (thrp.Position - hrp.Position).Magnitude

    if d <= dist then
     dist = d
     closest = model
    end

   end
  end
 end

 return closest

end

-- направление удара (ИСПРАВЛЕНО)
local function getDirection(targetHRP)

 local cam = Workspace.CurrentCamera
 local origin = cam.CFrame.Position

 -- немного выше центра модели
 local targetPos = targetHRP.Position + Vector3.new(0,1.5,0)

 local dir = (targetPos - origin).Unit

 return string.format("%.2f:%.2f:%.2f", dir.X, dir.Y, dir.Z)

end

-- цикл киллауры
task.spawn(function()

 while true do

  if Aura.Enabled and hrp then

   local target = getClosestTarget()

   if target then

    local id = target:GetAttribute("ID")
    local thrp = target:FindFirstChild("HumanoidRootPart")

    if id and thrp then

     local combo = nextCombo()

     -- start attack
     AttackRemote:FireServer(3, combo)

     -- direction
     AttackRemote:FireServer(4, combo, getDirection(thrp))

     -- hit confirm
     AttackRemote:FireServer(5, combo, {id})

     -- finish attack
     AttackRemote:FireServer(1, combo)

    end
   end
  end

  task.wait(Aura.Delay)

 end

end)

-- UI
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
 Name = "KillAura",
 CurrentValue = false,
 Flag = "KillAuraToggle",
 Callback = function(v)
  Aura.Enabled = v
 end
})

CombatTab:CreateSlider({
 Name = "Aura Range",
 Range = {10,500},
 Increment = 5,
 Suffix = " studs",
 CurrentValue = 300,
 Flag = "AuraRange",
 Callback = function(v)
  Aura.Range = v
 end
})

CombatTab:CreateSlider({
 Name = "Aura Delay",
 Range = {1,20},
 Increment = 1,
 Suffix = " ticks",
 CurrentValue = 4,
 Flag = "AuraDelay",
 Callback = function(v)

  Aura.Delay = v * 0.05

 end
})
