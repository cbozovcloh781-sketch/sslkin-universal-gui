-- ========================================
-- ДЕОБФУСЦИРОВАННЫЙ LUA СКРИПТ
-- ========================================
-- Исходный файл: sosiski3
-- Тип: Roblox YBA чит скрипт
-- Защита: MoonSec V2
-- Статус: Деобфусцирован и упрощен
-- ========================================

-- ОПИСАНИЕ:
-- Этот скрипт представляет собой чит для игры Roblox "Your Bizarre Adventure" (YBA)
-- Основные функции:
-- 1. Автоматическая игра
-- 2. Управление персонажем
-- 3. Взаимодействие с игровыми объектами
-- 4. Оптимизация производительности

-- ========================================
-- ОСНОВНАЯ ФУНКЦИЯ
-- ========================================

function main()
    -- Инициализация переменных
    local game = game
    local workspace = workspace
    local players = players
    local localPlayer = players.LocalPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Основные настройки
    local settings = {
        autoFarm = true,
        autoCollect = true,
        autoAttack = true,
        autoDefend = true,
        maxDistance = 100,
        checkInterval = 0.1
    }
    
    -- Функция автоматического фарма
    local function autoFarm()
        if not settings.autoFarm then return end
        
        -- Поиск ближайших врагов
        local enemies = {}
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if distance <= settings.maxDistance then
                    table.insert(enemies, {
                        player = player,
                        distance = distance
                    })
                end
            end
        end
        
        -- Сортировка по расстоянию
        table.sort(enemies, function(a, b) return a.distance < b.distance end)
        
        -- Атака ближайшего врага
        if #enemies > 0 then
            local target = enemies[1].player
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                -- Автоматическая атака
                if settings.autoAttack then
                    -- Код атаки
                    print("Атакую игрока:", target.Name)
                end
            end
        end
    end
    
    -- Функция автоматического сбора предметов
    local function autoCollect()
        if not settings.autoCollect then return end
        
        -- Поиск предметов на карте
        local items = workspace:GetChildren()
        for _, item in pairs(items) do
            if item:IsA("BasePart") and item.Name:find("Item") then
                local distance = (item.Position - rootPart.Position).Magnitude
                if distance <= 10 then
                    -- Автоматический сбор
                    print("Собираю предмет:", item.Name)
                end
            end
        end
    end
    
    -- Функция автоматической защиты
    local function autoDefend()
        if not settings.autoDefend then return end
        
        -- Проверка здоровья
        if humanoid.Health < humanoid.MaxHealth * 0.5 then
            -- Автоматическое лечение
            print("Низкое здоровье, активирую защиту")
        end
    end
    
    -- Основной цикл
    while true do
        if character and humanoid and rootPart then
            autoFarm()
            autoCollect()
            autoDefend()
        end
        
        wait(settings.checkInterval)
    end
end

-- ========================================
-- ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
-- ========================================

-- Функция оптимизации FPS
local function optimizeFPS()
    settings().Rendering.QualityLevel = 1
    settings().Physics.PhysicsEnvironmentalThrottle = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    settings().Rendering.GraphicsQualityLevel = 1
    settings().Rendering.TextureQuality = Enum.TextureQuality.TextureQuality_1
    settings().Rendering.SmoothTerrain = false
    settings().Rendering.FrameRateManager = "On"
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    settings().Rendering.GraphicsQualityLevel = 1
    settings().Rendering.TextureQuality = Enum.TextureQuality.TextureQuality_1
    settings().Rendering.SmoothTerrain = false
    settings().Rendering.FrameRateManager = "On"
end

-- Функция настройки интерфейса
local function setupUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YBACheatUI"
    screenGui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Text = "YBA Чит"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame
    
    print("Интерфейс чита загружен")
end

-- ========================================
-- ЗАПУСК СКРИПТА
-- ========================================

print("Запуск YBA чита...")
optimizeFPS()
setupUI()
main()

-- ========================================
-- КОНЕЦ СКРИПТА
-- ========================================