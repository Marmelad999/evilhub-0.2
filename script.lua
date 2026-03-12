-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Combat Dev Tool",
    LoadingTitle = "Loading",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CombatDev",
        FileName = "Settings"
    }
})

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- Remote
local AttackRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AttackV2")

-- Settings
local Settings = {
    Enabled = false,
    KillAura = false,
    SmartTarget = false,
    Debug = false,

    Range = 25,
    HitsPerTarget = 5,
    AttackDelay = 0.1
}

-- Debug printer
local function debugPrint(...)
    if Settings.Debug then
        print("[AutoAttack]", ...)
    end
end

-- Get targets
local function getTargets()

    local targets = {}

    for _, model in ipairs(Workspace.Characters:GetChildren()) do

        if model:IsA("Model") and model ~= character then

            local mobHRP = model:FindFirstChild("HumanoidRootPart")
            local mobId = model:GetAttribute("ID")

            if mobHRP and mobId then

                local distance = (mobHRP.Position - hrp.Position).Magnitude

                if distance <= Settings.Range then
                    table.insert(targets, {
                        id = mobId,
                        distance = distance
                    })
                end

            end

        end

    end

    return targets

end

-- Get closest target
local function getClosestTarget(targets)

    local closest = nil
    local minDist = math.huge

    for _, target in ipairs(targets) do

        if target.distance < minDist then
            minDist = target.distance
            closest = target
        end

    end

    return closest

end

-- Attack function
local function attackTarget(id)

    for i = 1, Settings.HitsPerTarget do
        AttackRemote:FireServer(1,1,{id})
    end

end

-- Main loop
task.spawn(function()

    while true do

        if Settings.Enabled and hrp then

            local targets = getTargets()

            debugPrint("Targets found:", #targets)

            if #targets > 0 then

                -- Kill Aura (attack all)
                if Settings.KillAura then

                    for _, target in ipairs(targets) do
                        attackTarget(target.id)
                        debugPrint("KillAura attacking:", target.id)
                    end

                -- Smart target (closest only)
                elseif Settings.SmartTarget then

                    local closest = getClosestTarget(targets)

                    if closest then
                        attackTarget(closest.id)
                        debugPrint("SmartTarget attacking:", closest.id)
                    end

                -- Normal mode
                else

                    attackTarget(targets[1].id)
                    debugPrint("Attacking:", targets[1].id)

                end

            end

        end

        task.wait(Settings.AttackDelay)

    end

end)

-- UI
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = false,
    Callback = function(state)
        Settings.Enabled = state
    end
})

CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(state)
        Settings.KillAura = state
    end
})

CombatTab:CreateToggle({
    Name = "Smart Target (Closest)",
    CurrentValue = false,
    Callback = function(state)
        Settings.SmartTarget = state
    end
})

CombatTab:CreateToggle({
    Name = "Debug Mode",
    CurrentValue = false,
    Callback = function(state)
        Settings.Debug = state
    end
})

CombatTab:CreateSlider({
    Name = "Attack Range",
    Range = {5, 150},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(value)
        Settings.Range = value
    end
})

CombatTab:CreateSlider({
    Name = "Hits Per Target",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        Settings.HitsPerTarget = value
    end
})

CombatTab:CreateSlider({
    Name = "Attack Delay",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = 0.1,
    Callback = function(value)
        Settings.AttackDelay = value
    end
})

Rayfield:Notify({
    Title = "Loaded",
    Content = "Combat system ready",
    Duration = 5
})
