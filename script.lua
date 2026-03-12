-- Инициализация Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "LevelBound Helper",
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
local humanoid = character:WaitForChild("Humanoid")

local AttackRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AttackV2")

-- Настройки киллауры
local KillAuraSettings = {
    ENABLED = false,
    RANGE = 20,
    DELAY = 0.25,
    COMBO = 1
}

-- Обновляем персонажа при респауне
local function onCharacterAdded(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    KillAuraSettings.COMBO = 1
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Функция для перехода к следующей стадии комбо
local function nextCombo()
    KillAuraSettings.COMBO += 1
    if KillAuraSettings.COMBO > 3 then
        KillAuraSettings.COMBO = 1
    end
    return KillAuraSettings.COMBO
end

-- Поиск ближайшей цели
local function getClosestTarget()
    local closest
    local dist = KillAuraSettings.RANGE

    for _, model in ipairs(Workspace.Characters:GetChildren()) do
        if model ~= character then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local targetHRP = model:FindFirstChild("HumanoidRootPart")
            local id = model:GetAttribute("ID")

            if hum and hum.Health > 0 and targetHRP and id then
                local d = (targetHRP.Position - hrp.Position).Magnitude
                if d <= dist then
                    dist = d
                    closest = model
                end
            end
        end
    end

    return closest
end

-- Получаем направление удара
local function getDirection(targetHRP)
    local dir = (targetHRP.Position - hrp.Position).Unit
    return string.format("%.2f:%.2f:%.2f", dir.X, dir.Y, dir.Z)
end

-- Цикл киллауры
task.spawn(function()
    while true do
        if KillAuraSettings.ENABLED and hrp then
            local target = getClosestTarget()
            if target then
                local id = target:GetAttribute("ID")
                local targetHRP = target:FindFirstChild("HumanoidRootPart")
                if id and targetHRP then
                    local c = nextCombo()

                    -- Старт атаки
                    AttackRemote:FireServer(3, c)
                    -- Направление удара
                    AttackRemote:FireServer(4, c, getDirection(targetHRP))
                    -- Подтверждение попадания
                    AttackRemote:FireServer(5, c, {id})
                    -- Завершение атаки
                    AttackRemote:FireServer(1, c)
                end
            end
        end
        task.wait(KillAuraSettings.DELAY)
    end
end)

-- Создаем вкладку и элементы управления Rayfield
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "KillAura",
    CurrentValue = false,
    Flag = "KillAuraToggle",
    Callback = function(state)
        KillAuraSettings.ENABLED = state
    end
})

CombatTab:CreateSlider({
    Name = "Range",
    Min = 5,
    Max = 100,
    Increment = 1,
    Suffix = " studs",
    CurrentValue = KillAuraSettings.RANGE,
    Flag = "KillAuraRange",
    Callback = function(value)
        KillAuraSettings.RANGE = value
    end
})

CombatTab:CreateSlider({
    Name = "Delay",
    Min = 0.05,
    Max = 1,
    Increment = 0.05,
    Suffix = " sec",
    CurrentValue = KillAuraSettings.DELAY,
    Flag = "KillAuraDelay",
    Callback = function(value)
        KillAuraSettings.DELAY = value
    end
})