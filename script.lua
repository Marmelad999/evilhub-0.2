-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Combat Dev Tool",
    LoadingTitle = "Loading",
    LoadingSubtitle = "Rayfield",
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
    HitsPerTarget = 3,
    AttackDelay = 0.15
}

local combo = 1

-- Debug
local function debugPrint(...)
    if Settings.Debug then
        print("[AutoAttack]", ...)
    end
end

-- Direction calculator
local function getDirection(targetHRP)

    local dir = (targetHRP.Position - hrp.Position).Unit

    return string.format(
        "%.2f:%.2f:%.2f",
        dir.X,
        dir.Y,
        dir.Z
    )

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
                    table.insert(targets, model)
                end

            end

        end

    end

    return targets

end

-- Closest target
local function getClosest(targets)

    local closest
    local dist = math.huge

    for _, target in ipairs(targets) do

        local thrp = target:FindFirstChild("HumanoidRootPart")

        if thrp then
            local d = (thrp.Position - hrp.Position).Magnitude

            if d < dist then
                dist = d
                closest = target
            end
        end

    end

    return closest

end

-- Attack sequence
local function attackTarget(target)

    local mobId = target:GetAttribute("ID")
    local thrp = target:FindFirstChild("HumanoidRootPart")

    if not mobId or not thrp then return end

    local direction = getDirection(thrp)

    debugPrint("Attacking ID:", mobId)

    AttackRemote:FireServer(5, combo, {mobId})
    task.wait()

    AttackRemote:FireServer(3, combo)
    task.wait()

    AttackRemote:FireServer(4, combo, direction)
    task.wait()

    AttackRemote:FireServer(1, combo)

    combo += 1
    if combo > 2 then
        combo = 1
    end

end

-- Main loop
task.spawn(function()

    while true do

        if Settings.Enabled and hrp then

            local targets = getTargets()

            debugPrint("Targets:", #targets)

            if #targets > 0 then

                if Settings.KillAura then

                    for _, target in ipairs(targets) do
                        for i = 1, Settings.HitsPerTarget do
                            attackTarget(target)
                        end
                    end

                elseif Settings.SmartTarget then

                    local closest = getClosest(targets)

                    if closest then
                        for i = 1, Settings.HitsPerTarget do
                            attackTarget(closest)
                        end
                    end

                else

                    local target = targets[1]

                    for i = 1, Settings.HitsPerTarget do
                        attackTarget(target)
                    end

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
    Name = "Smart Target",
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
    Range = {5,150},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(v)
        Settings.Range = v
    end
})

CombatTab:CreateSlider({
    Name = "Hits Per Target",
    Range = {1,20},
    Increment = 1,
    CurrentValue = 3,
    Callback = function(v)
        Settings.HitsPerTarget = v
    end
})

CombatTab:CreateSlider({
    Name = "Attack Delay",
    Range = {0.05,1},
    Increment = 0.05,
    CurrentValue = 0.15,
    Callback = function(v)
        Settings.AttackDelay = v
    end
})

Rayfield:Notify({
    Title = "Loaded",
    Content = "Auto Attack ready",
    Duration = 5
})
