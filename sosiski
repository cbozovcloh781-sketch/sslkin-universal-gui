if not game:IsLoaded() then game.Loaded:Wait() end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local Config = {
    ESP = {
        Enabled     = true,
        TeamCheck   = false,
        ShowOutline = true,
        ShowLines   = false,
        Rainbow     = false,
        FillColor   = Color3.fromRGB(255,255,255),
        OutlineColor= Color3.fromRGB(255,255,255),
        TextColor   = Color3.fromRGB(255,255,255),
        LineColor   = Color3.fromRGB(255,255,255),
        FillTransparency    = 0.5,
        OutlineTransparency = 0,
        Font        = Enum.Font.SciFi,
        TeamColor   = Color3.fromRGB(0,255,0),
        EnemyColor  = Color3.fromRGB(255,0,0),
        ToggleKey   = nil,
    },
    Aimbot = {
        Enabled         = false,
        TeamCheck       = false,
        VisibilityCheck = true,
        FOV             = 150,
        ToggleKey       = nil,
        FOVColor        = Color3.fromRGB(255,128,128),
        FOVRainbow      = false,
    },
    MenuCollapsed = false,
}

-- Полностью переписанная система полета для YBA
local FlyConfig = {
    Enabled = false,
    Speed = 1,
    ToggleKey = nil,
}

-- Система NoClip
local NoClipConfig = {
    Enabled = false,
    ToggleKey = nil,
}

-- Система SpeedHack
local SpeedHackConfig = {
    Enabled = false,
    Speed = 1,
    ToggleKey = nil,
    UseJumpPower = false, -- Альтернативный метод через JumpPower
}

-- Система телепортации к игрокам
local TeleportConfig = {
    Enabled = false,
    TargetPlayer = nil,
    OriginalPosition = nil,
    ToggleKey = nil,
    SelectedPlayerName = nil, -- Сохраняем ник выбранного игрока
    UseStealthMode = true, -- Использовать скрытый режим телепортации
}

-- Переменные для полета
local isFlying = false
local flyConnections = {}
local originalGravity = workspace.Gravity

-- Переменные для NoClip
local isNoClipping = false
local noClipConnections = {}

-- Переменные для SpeedHack
local isSpeedHacking = false
local speedHackConnections = {}
local originalWalkSpeed = 16
local originalJumpPower = 50

-- Переменные для телепортации
local isTeleporting = false
local teleportConnections = {}
local playerSelectionWindow = nil -- Окно выбора игрока

local function startFly()
    local plr = Players.LocalPlayer
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end
    
    isFlying = true
    
    -- Сохраняем оригинальные настройки
    local originalJumpPower = hum.JumpPower
    local originalJumpHeight = hum.JumpHeight
    local originalGravity = workspace.Gravity
    local originalHipHeight = hum.HipHeight
    
    -- Настройки для полета в YBA
    hum.JumpPower = 0
    hum.JumpHeight = 0
    workspace.Gravity = 0
    hum.HipHeight = 0 -- Важно для YBA
    
    local ctrl = {f = 0, b = 0, l = 0, r = 0, u = 0, d = 0}
    
    local inputDown = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
        elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
        elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
        elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1
        elseif input.KeyCode == Enum.KeyCode.Space then ctrl.u = 1
        elseif input.KeyCode == Enum.KeyCode.LeftControl then ctrl.d = -1 end
    end)
    
    local inputUp = UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
        elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
        elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
        elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0
        elseif input.KeyCode == Enum.KeyCode.Space then ctrl.u = 0
        elseif input.KeyCode == Enum.KeyCode.LeftControl then ctrl.d = 0 end
    end)
    
    local renderConnection = RunService.RenderStepped:Connect(function()
        if not isFlying or not char or not char:FindFirstChild("Humanoid") or not root then
            -- Восстанавливаем оригинальные настройки
            if hum then
                hum.JumpPower = originalJumpPower
                hum.JumpHeight = originalJumpHeight
                hum.HipHeight = originalHipHeight
            end
            -- Восстанавливаем гравитацию только если NoClip не включен
            if not isNoClipping then
                workspace.Gravity = originalGravity
            end
            
            inputDown:Disconnect()
            inputUp:Disconnect()
            renderConnection:Disconnect()
            return
        end
        
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        -- Вычисляем направление движения
        local forward = cam.CFrame.lookVector
        local right = cam.CFrame.rightVector
        local up = Vector3.new(0, 1, 0)
        
        local moveVector = Vector3.new(0, 0, 0)
        moveVector = moveVector + (forward * (ctrl.f + ctrl.b))
        moveVector = moveVector + (right * (ctrl.r + ctrl.l))
        moveVector = moveVector + (up * (ctrl.u + ctrl.d))
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * (FlyConfig.Speed * 10)
            -- Используем BodyVelocity для YBA
            local bv = root:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            bv.Velocity = moveVector
        else
            -- Останавливаем движение
            local bv = root:FindFirstChild("BodyVelocity")
            if bv then
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
    
    -- Сохраняем соединения
    table.insert(flyConnections, inputDown)
    table.insert(flyConnections, inputUp)
    table.insert(flyConnections, renderConnection)
end

local function stopFly()
    isFlying = false
    
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        -- Восстанавливаем оригинальные настройки
        hum.JumpPower = 50
        hum.JumpHeight = 7.2
        hum.HipHeight = 2
    end
    
    workspace.Gravity = 196.2
    
    -- Удаляем BodyVelocity
    if root then
        local bv = root:FindFirstChild("BodyVelocity")
        if bv then
            bv:Destroy()
        end
    end
    
    -- Отключаем все соединения
    for _, connection in ipairs(flyConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    flyConnections = {}
end

-- NoClip из Infinite Yield
local function startNoClip()
    local char = Players.LocalPlayer.Character
    if not char then return end
    
    isNoClipping = true
    
    -- Infinite Yield NoClip метод
    local function noclip()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    -- Создаем соединение для постоянного обновления NoClip
    local noClipLoop = RunService.Heartbeat:Connect(function()
        if not isNoClipping or not char or not char.Parent then
            return
        end
        noclip()
    end)
    
    table.insert(noClipConnections, noClipLoop)
    
    -- Создаем соединение для новых частей персонажа
    local function setupNoClipForPart(part)
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
    
    local descendantAdded = char.DescendantAdded:Connect(setupNoClipForPart)
    table.insert(noClipConnections, descendantAdded)
end

local function stopNoClip()
    isNoClipping = false
    
    local char = Players.LocalPlayer.Character
    if not char then return end
    
    -- Восстанавливаем коллизии (Infinite Yield метод)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    
    -- Отключаем все соединения
    for _, connection in ipairs(noClipConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            elseif typeof(connection) == "Instance" then
                pcall(function() connection:Destroy() end)
            end
        end
    end
    noClipConnections = {}
end

-- Функции SpeedHack - Безопасная система без BodyVelocity
local function startSpeedHack()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    isSpeedHacking = true
    originalWalkSpeed = hum.WalkSpeed
    originalJumpPower = hum.JumpPower
    
    -- Устанавливаем скорость через Humanoid (безопасный метод)
    hum.WalkSpeed = SpeedHackConfig.Speed * 16
    
    -- Альтернативный метод через JumpPower для большей скорости
    if SpeedHackConfig.UseJumpPower then
        hum.JumpPower = SpeedHackConfig.Speed * 50
    end
    
    -- Создаем соединение для обновления скорости при респавне
    local function onCharacterAdded(newChar)
        local newHum = newChar:WaitForChild("Humanoid")
        if isSpeedHacking then
            newHum.WalkSpeed = SpeedHackConfig.Speed * 16
            if SpeedHackConfig.UseJumpPower then
                newHum.JumpPower = SpeedHackConfig.Speed * 50
            end
        end
    end
    
    local characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(speedHackConnections, characterAddedConnection)
    
    -- Создаем соединение для постоянного обновления скорости
    local speedLoop = RunService.Heartbeat:Connect(function()
        if not isSpeedHacking then return end
        
        local currentChar = Players.LocalPlayer.Character
        local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        
        if currentHum then
            -- Обновляем WalkSpeed только если она отличается
            if currentHum.WalkSpeed ~= SpeedHackConfig.Speed * 16 then
                currentHum.WalkSpeed = SpeedHackConfig.Speed * 16
            end
            
            -- Обновляем JumpPower если используется альтернативный метод
            if SpeedHackConfig.UseJumpPower and currentHum.JumpPower ~= SpeedHackConfig.Speed * 50 then
                currentHum.JumpPower = SpeedHackConfig.Speed * 50
            end
        end
    end)
    
    table.insert(speedHackConnections, speedLoop)
end

local function stopSpeedHack()
    isSpeedHacking = false
    
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = originalWalkSpeed
        hum.JumpPower = originalJumpPower
    end
    
    -- Отключаем все соединения
    for _, connection in ipairs(speedHackConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            elseif typeof(connection) == "Instance" then
                pcall(function() connection:Destroy() end)
            end
        end
    end
    speedHackConnections = {}
end

-- Новая система телепортации к игрокам
local function createStealthTeleport()
    if not TeleportConfig.TargetPlayer then 
        print("Не выбран игрок для телепортации")
        return 
    end
    
    local char = Players.LocalPlayer.Character
    local targetChar = TeleportConfig.TargetPlayer.Character
    if not char or not targetChar then 
        print("Персонаж не найден")
        return 
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then 
        print("HumanoidRootPart не найден")
        return 
    end
    
    isTeleporting = true
    print("Скрытая телепортация к " .. TeleportConfig.TargetPlayer.Name .. " начата")
    
    -- Сохраняем начальную координату при старте телепортации
    TeleportConfig.OriginalPosition = root.Position
    print("СОХРАНЕНА НАЧАЛЬНАЯ КООРДИНАТА: " .. tostring(TeleportConfig.OriginalPosition))
    
    -- Включаем NoClip для прохождения сквозь препятствия
    if not isNoClipping then
        startNoClip()
    end
    
    -- Создаем соединение для скрытой телепортации
    local stealthTeleportLoop = RunService.Heartbeat:Connect(function()
        if not isTeleporting or not targetChar or not targetChar.Parent then
            print("Телепортация остановлена - игрок не найден")
            return
        end
        
        local currentTargetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if currentTargetRoot then
            local targetPos = currentTargetRoot.Position
            local currentPos = root.Position
            local distance = (targetPos - currentPos).Magnitude
            
            print("Расстояние до игрока: " .. distance .. " | Позиция игрока: " .. tostring(targetPos) .. " | Моя позиция: " .. tostring(currentPos))
            
            -- Сверхбыстрая телепортация к игроку
            local bv = root:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            
            local direction = (targetPos - currentPos).Unit
            local moveSpeed = 500 -- Сверхвысокая скорость для почти моментального движения
            bv.Velocity = direction * moveSpeed
            
            print("Сверхбыстрая телепортация к игроку со скоростью: " .. moveSpeed)
        end
    end)
    
    table.insert(teleportConnections, stealthTeleportLoop)
end

local function startTeleport()
    if not TeleportConfig.TargetPlayer then 
        print("Не выбран игрок для телепортации")
        return 
    end
    
    local char = Players.LocalPlayer.Character
    local targetChar = TeleportConfig.TargetPlayer.Character
    if not char or not targetChar then 
        print("Персонаж не найден")
        return 
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then 
        print("HumanoidRootPart не найден")
        return 
    end
    
    isTeleporting = true
    print("Телепортация к " .. TeleportConfig.TargetPlayer.Name .. " начата")
    
    -- Сохраняем начальную координату при старте телепортации
    TeleportConfig.OriginalPosition = root.Position
    print("СОХРАНЕНА НАЧАЛЬНАЯ КООРДИНАТА: " .. tostring(TeleportConfig.OriginalPosition))
    
    -- Включаем NoClip для телепортации
    if not isNoClipping then
        startNoClip()
        print("NoClip включен для телепортации к игроку")
    end
    
    -- Обновляем GUI - кнопка "СТАРТ ТЕЛЕПОРТ" становится красной
    if startTeleportBtn then
        startTeleportBtn.Text = "ТЕЛЕПОРТАЦИЯ АКТИВНА"
        startTeleportBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
    if stopTeleportBtn then
        stopTeleportBtn.Text = "ОСТАНОВИТЬ ТЕЛЕПОРТАЦИЮ"
        stopTeleportBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    end
    
    -- Всегда используем скрытную функцию телепортации
    createStealthTeleport()
end

local function stopTeleport()
    print("Остановка телепортации к игроку")
    isTeleporting = false
    TeleportConfig.Enabled = false
    
    local char = Players.LocalPlayer.Character
    if not char then 
        print("Персонаж не найден при остановке")
        return 
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- Отключаем все соединения телепортации к игроку
    for _, connection in ipairs(teleportConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            end
        end
    end
    teleportConnections = {}
    
    -- Удаляем BodyVelocity от телепортации к игроку
    local bv = root and root:FindFirstChild("BodyVelocity")
    if bv then
        bv:Destroy()
    end
    
    if root and TeleportConfig.OriginalPosition then
        -- Быстрый возврат на исходную позицию с постоянным движением
        print("Быстрый возврат на исходную позицию: " .. tostring(TeleportConfig.OriginalPosition))
        
        -- Создаем двухэтапное движение к исходной позиции
        local returnStartTime = tick()
        local fastPhaseComplete = false
        
        -- Включаем NoClip для возврата
        if not isNoClipping then
            startNoClip()
            print("NoClip включен для возврата на исходную позицию")
        end
        
        local returnLoop = RunService.Heartbeat:Connect(function()
            if not root or not root.Parent then
                return
            end
            
            local currentPos = root.Position
            local returnPos = TeleportConfig.OriginalPosition
            local distance = (returnPos - currentPos).Magnitude
            local elapsedTime = tick() - returnStartTime
            
            print("Расстояние до исходной позиции: " .. distance .. " | Время: " .. elapsedTime)
            
                    if distance > 5 then
            -- Продолжаем движение к начальной координате
            local returnBv = root:FindFirstChild("BodyVelocity")
            if not returnBv then
                returnBv = Instance.new("BodyVelocity", root)
                returnBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            
            local returnDirection = (returnPos - currentPos).Unit
            local returnSpeed = 1000 -- Очень высокая скорость для быстрого возврата
            
            returnBv.Velocity = returnDirection * returnSpeed
            print("Быстрое движение к начальной координате: " .. distance .. " единиц осталось")
                else
            -- Достигли начальной координаты (в пределах 5 единиц)
            local returnBv = root:FindFirstChild("BodyVelocity")
            if returnBv then
                -- Останавливаем движение и застываем в воздухе на 2 секунды
                returnBv.Velocity = Vector3.new(0, 0, 0)
                print("ДОСТИГНУТА НАЧАЛЬНАЯ КООРДИНАТА! Застываем в воздухе на 2 секунды для сброса скорости...")
                task.wait(2) -- Ждем 2 секунды для полного сброса скорости
                returnBv:Destroy()
            end
            
            -- Финальная телепортация на точную начальную координату
            root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
            TeleportConfig.OriginalPosition = nil
            
            -- Откладываем отключение NoClip на 10 секунд после возврата
            print("NoClip будет отключен через 10 секунд...")
            task.spawn(function()
                task.wait(10)
                if isNoClipping then
                    stopNoClip()
                    print("NoClip отключен через 10 секунд после возврата")
                else
                    print("NoClip уже отключен")
                end
            end)
            
            -- Отключаем цикл возврата
            if returnLoop then
                returnLoop:Disconnect()
            end
            
            print("ВОЗВРАТ НА НАЧАЛЬНУЮ КООРДИНАТУ ЗАВЕРШЕН!")
            
            -- Дополнительная проверка: если не в радиусе 10 studs, продолжаем перемещение
            if TeleportConfig.OriginalPosition then
                print("ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА: Запускаем постоянное перемещение к исходной точке...")
                
                local finalCheckLoop = RunService.Heartbeat:Connect(function()
                    if not root or not root.Parent then
                        return
                    end
                    
                    local currentPos = root.Position
                    local targetPos = TeleportConfig.OriginalPosition
                    local distance = (targetPos - currentPos).Magnitude
                    
                    if distance > 10 then
                        -- Продолжаем перемещение к исходной точке
                        local finalBv = root:FindFirstChild("BodyVelocity")
                        if not finalBv then
                            finalBv = Instance.new("BodyVelocity", root)
                            finalBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        end
                        
                        local direction = (targetPos - currentPos).Unit
                        local speed = 800
                        finalBv.Velocity = direction * speed
                        
                        print("ДОПОЛНИТЕЛЬНОЕ ПЕРЕМЕЩЕНИЕ: " .. distance .. " studs до исходной точки")
                    else
                        -- Достигли радиуса 10 studs, останавливаемся
                        local finalBv = root:FindFirstChild("BodyVelocity")
                        if finalBv then
                            finalBv:Destroy()
                        end
                        
                        -- Финальная телепортация на точную позицию
                        root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
                        TeleportConfig.OriginalPosition = nil
                        
                        -- Отключаем дополнительную проверку
                        if finalCheckLoop then
                            finalCheckLoop:Disconnect()
                        end
                        
                        print("ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ЗАВЕРШЕНА: Достигнута исходная точка!")
                    end
                end)
                
                -- Добавляем соединение в список для очистки
                table.insert(teleportConnections, finalCheckLoop)
            end
        end
        end)
        
        -- Добавляем соединение в список для очистки
        table.insert(teleportConnections, returnLoop)
    end
    
    -- Отключаем все соединения
    for _, connection in ipairs(teleportConnections) do
        if connection then
            if typeof(connection) == "RBXScriptConnection" then
                pcall(function() connection:Disconnect() end)
            end
        end
    end
    teleportConnections = {}
    
    -- Восстанавливаем нормальные настройки движения
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
    
    -- Откладываем отключение NoClip на 10 секунд в конце функции stopTeleport
    print("NoClip будет отключен через 10 секунд в конце stopTeleport...")
    task.spawn(function()
        task.wait(10)
        if isNoClipping then
            stopNoClip()
            print("NoClip отключен через 10 секунд в конце stopTeleport")
        else
            print("NoClip уже отключен в конце stopTeleport")
        end
    end)
    
    -- Обновляем GUI - кнопка "СТАРТ ТЕЛЕПОРТ" становится зеленой
    if startTeleportBtn then
        startTeleportBtn.Text = "СТАРТ ТЕЛЕПОРТ"
        startTeleportBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    end
    if stopTeleportBtn then
        stopTeleportBtn.Text = "ВЫКЛЮЧИТЬ ТЕЛЕПОРТАЦИЮ"
        stopTeleportBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
    
    print("Телепортация к игроку остановлена, начинаем возврат на исходную позицию...")
    
    -- Автоматически начинаем возврат на начальную координату
    if root and TeleportConfig.OriginalPosition then
        print("НАЧИНАЕМ ВОЗВРАТ НА НАЧАЛЬНУЮ КООРДИНАТУ: " .. tostring(TeleportConfig.OriginalPosition))
        
        -- Включаем NoClip для возврата
        if not isNoClipping then
            startNoClip()
            print("NoClip включен для возврата на начальную координату")
        end
        
        -- Создаем движение к начальной координате
        local returnStartTime = tick()
        local returnAttempts = 0
        local maxAttempts = 300 -- Максимум 5 секунд (300 кадров при 60 FPS)
        
        local returnLoop = RunService.Heartbeat:Connect(function()
            returnAttempts = returnAttempts + 1
            
            -- Проверяем, не застряли ли мы
            if returnAttempts > maxAttempts then
                print("ПРЕДУПРЕЖДЕНИЕ: Возврат занимает слишком много времени, принудительная телепортация...")
                root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
                TeleportConfig.OriginalPosition = nil
                if isNoClipping then
                    stopNoClip()
                    print("NoClip отключен после принудительного возврата")
                end
                if returnLoop then
                    returnLoop:Disconnect()
                end
                print("ПРИНУДИТЕЛЬНЫЙ ВОЗВРАТ НА НАЧАЛЬНУЮ КООРДИНАТУ ЗАВЕРШЕН!")
                
                -- Дополнительная проверка для принудительного возврата
                if TeleportConfig.OriginalPosition then
                    print("ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ПРИНУДИТЕЛЬНОГО ВОЗВРАТА: Запускаем постоянное перемещение...")
                    
                    local finalCheckLoop = RunService.Heartbeat:Connect(function()
                        if not root or not root.Parent then
                            return
                        end
                        
                        local currentPos = root.Position
                        local targetPos = TeleportConfig.OriginalPosition
                        local distance = (targetPos - currentPos).Magnitude
                        
                        if distance > 10 then
                            -- Продолжаем перемещение к исходной точке
                            local finalBv = root:FindFirstChild("BodyVelocity")
                            if not finalBv then
                                finalBv = Instance.new("BodyVelocity", root)
                                finalBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            end
                            
                            local direction = (targetPos - currentPos).Unit
                            local speed = 800
                            finalBv.Velocity = direction * speed
                            
                            print("ДОПОЛНИТЕЛЬНОЕ ПЕРЕМЕЩЕНИЕ (ПРИНУДИТЕЛЬНОЕ): " .. distance .. " studs до исходной точки")
                        else
                            -- Достигли радиуса 10 studs, останавливаемся
                            local finalBv = root:FindFirstChild("BodyVelocity")
                            if finalBv then
                                finalBv:Destroy()
                            end
                            
                            -- Финальная телепортация на точную позицию
                            root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
                            TeleportConfig.OriginalPosition = nil
                            
                            -- Отключаем дополнительную проверку
                            if finalCheckLoop then
                                finalCheckLoop:Disconnect()
                            end
                            
                            print("ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ПРИНУДИТЕЛЬНОГО ВОЗВРАТА ЗАВЕРШЕНА!")
                        end
                    end)
                    
                    -- Добавляем соединение в список для очистки
                    table.insert(teleportConnections, finalCheckLoop)
                end
                return
            end
            
            if not root or not root.Parent then
                print("ОШИБКА: Персонаж не найден во время возврата")
                if returnLoop then
                    returnLoop:Disconnect()
                end
                return
            end
            
            local currentPos = root.Position
            local returnPos = TeleportConfig.OriginalPosition
            local distance = (returnPos - currentPos).Magnitude
            
            print("Расстояние до начальной координаты: " .. distance .. " | Попытка: " .. returnAttempts)
            
            if distance > 3 then
                -- Продолжаем движение к начальной координате
                local returnBv = root:FindFirstChild("BodyVelocity")
                if not returnBv then
                    returnBv = Instance.new("BodyVelocity", root)
                    returnBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                end
                
                local returnDirection = (returnPos - currentPos).Unit
                local returnSpeed = 1500 -- Увеличиваем скорость для более быстрого возврата
                
                returnBv.Velocity = returnDirection * returnSpeed
                print("Быстрое движение к начальной координате: " .. distance .. " единиц осталось")
            else
                -- Достигли начальной координаты (в пределах 3 единиц)
                local returnBv = root:FindFirstChild("BodyVelocity")
                if returnBv then
                    -- Останавливаем движение и застываем в воздухе на 2 секунды
                    returnBv.Velocity = Vector3.new(0, 0, 0)
                    print("ДОСТИГНУТА НАЧАЛЬНАЯ КООРДИНАТА! Застываем в воздухе на 2 секунды для сброса скорости...")
                    task.wait(2) -- Ждем 2 секунды для полного сброса скорости
                    returnBv:Destroy()
                end
                
                -- Финальная телепортация на точную начальную координату
                root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
                TeleportConfig.OriginalPosition = nil
                
                -- Откладываем отключение NoClip на 10 секунд после возврата
                print("NoClip будет отключен через 10 секунд...")
                task.spawn(function()
                    task.wait(10)
                    if isNoClipping then
                        stopNoClip()
                        print("NoClip отключен через 10 секунд после возврата")
                    else
                        print("NoClip уже отключен")
                    end
                end)
                
                -- Отключаем цикл возврата
                if returnLoop then
                    returnLoop:Disconnect()
                end
                
                print("ВОЗВРАТ НА НАЧАЛЬНУЮ КООРДИНАТУ ЗАВЕРШЕН!")
                
                -- Дополнительная проверка: если не в радиусе 10 studs, продолжаем перемещение
                if TeleportConfig.OriginalPosition then
                    print("ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА: Запускаем постоянное перемещение к исходной точке...")
                    
                    local finalCheckLoop = RunService.Heartbeat:Connect(function()
                        if not root or not root.Parent then
                            return
                        end
                        
                        local currentPos = root.Position
                        local targetPos = TeleportConfig.OriginalPosition
                        local distance = (targetPos - currentPos).Magnitude
                        
                        if distance > 10 then
                            -- Продолжаем перемещение к исходной точке
                            local finalBv = root:FindFirstChild("BodyVelocity")
                            if not finalBv then
                                finalBv = Instance.new("BodyVelocity", root)
                                finalBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            end
                            
                            local direction = (targetPos - currentPos).Unit
                            local speed = 800
                            finalBv.Velocity = direction * speed
                            
                            print("ДОПОЛНИТЕЛЬНОЕ ПЕРЕМЕЩЕНИЕ: " .. distance .. " studs до исходной точки")
                        else
                            -- Достигли радиуса 10 studs, останавливаемся
                            local finalBv = root:FindFirstChild("BodyVelocity")
                            if finalBv then
                                finalBv:Destroy()
                            end
                            
                            -- Финальная телепортация на точную позицию
                            root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
                            TeleportConfig.OriginalPosition = nil
                            
                            -- Отключаем дополнительную проверку
                            if finalCheckLoop then
                                finalCheckLoop:Disconnect()
                            end
                            
                            print("ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ЗАВЕРШЕНА: Достигнута исходная точка!")
                        end
                    end)
                    
                    -- Добавляем соединение в список для очистки
                    table.insert(teleportConnections, finalCheckLoop)
                end
            end
        end)
        
        -- Добавляем соединение в список для очистки
        table.insert(teleportConnections, returnLoop)
    else
        print("ОШИБКА: Нет сохраненной начальной координаты или персонаж не найден!")
        print("Попытка принудительного возврата...")
        
        -- Принудительный возврат если что-то пошло не так
        if root and TeleportConfig.OriginalPosition then
            root.CFrame = CFrame.new(TeleportConfig.OriginalPosition)
            TeleportConfig.OriginalPosition = nil
            if isNoClipping then
                stopNoClip()
                print("NoClip отключен после принудительного возврата")
            end
            print("ПРИНУДИТЕЛЬНЫЙ ВОЗВРАТ ВЫПОЛНЕН!")
        end
    end
end

local function getAlivePlayers()
    local alivePlayers = {}
    
    print("=== ПОИСК ЖИВЫХ ИГРОКОВ ===")
    
    -- Простая и надежная проверка
    if not Players then
        print("Players сервис не найден!")
        return alivePlayers
    end
    
    if not Players.LocalPlayer then
        print("LocalPlayer не найден!")
        return alivePlayers
    end
    
    local allPlayers = Players:GetPlayers()
    if not allPlayers then
        print("Не удалось получить список игроков!")
        return alivePlayers
    end
    
    print("Всего игроков на сервере: " .. #allPlayers)
    print("Локальный игрок: " .. Players.LocalPlayer.Name)
    
    for i, player in ipairs(allPlayers) do
        if player then
            print("Проверяем игрока " .. i .. ": " .. player.Name)
            
            if player ~= Players.LocalPlayer then
                print("  - Это не локальный игрок")
                
                if player.Character then
                    print("  - У игрока есть персонаж")
                    
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        print("  - У игрока есть Humanoid, здоровье: " .. humanoid.Health)
                        
                        if humanoid.Health > 0 then
                            print("  - Игрок жив, добавляем в список")
                            table.insert(alivePlayers, player)
                        else
                            print("  - Игрок мертв")
                        end
                    else
                        print("  - У игрока нет Humanoid")
                    end
                else
                    print("  - У игрока нет персонажа")
                end
            else
                print("  - Это локальный игрок, пропускаем")
            end
        else
            print("Игрок " .. i .. " равен nil")
        end
    end
    
    print("Найдено живых игроков: " .. #alivePlayers)
    return alivePlayers
end

-- Обработка горячих клавиш для полета, NoClip и SpeedHack
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if FlyConfig.ToggleKey and input.KeyCode == FlyConfig.ToggleKey then
            FlyConfig.Enabled = not FlyConfig.Enabled
            if FlyConfig.Enabled then 
                startFly() 
            else 
                stopFly() 
            end
            -- Обновляем GUI
            if guiCallbacks.fly then
                guiCallbacks.fly.Text = "Fly: " .. (FlyConfig.Enabled and "ON" or "OFF")
            end
        elseif NoClipConfig.ToggleKey and input.KeyCode == NoClipConfig.ToggleKey then
            NoClipConfig.Enabled = not NoClipConfig.Enabled
            if NoClipConfig.Enabled then 
                startNoClip() 
            else 
                stopNoClip() 
            end
            -- Обновляем GUI
            if guiCallbacks.noClip then
                guiCallbacks.noClip.Text = "NoClip: " .. (NoClipConfig.Enabled and "ON" or "OFF")
            end
        elseif SpeedHackConfig.ToggleKey and input.KeyCode == SpeedHackConfig.ToggleKey then
            SpeedHackConfig.Enabled = not SpeedHackConfig.Enabled
            if SpeedHackConfig.Enabled then 
                startSpeedHack() 
            else 
                stopSpeedHack() 
            end
            -- Обновляем GUI
            if guiCallbacks.speedHack then
                guiCallbacks.speedHack.Text = "SpeedHack: " .. (SpeedHackConfig.Enabled and "ON" or "OFF")
            end
        elseif TeleportConfig.ToggleKey and input.KeyCode == TeleportConfig.ToggleKey then
            if TeleportConfig.Enabled then
                stopTeleport()
                TeleportConfig.Enabled = false
            else
                if TeleportConfig.TargetPlayer then
                    startTeleport()
                    TeleportConfig.Enabled = true
                else
                    print("Сначала выберите игрока для телепортации")
                end
            end
            -- Обновляем GUI
            if guiCallbacks.teleport then
                guiCallbacks.teleport.Text = "Выбранный игрок: " .. (TeleportConfig.SelectedPlayerName or "Не выбран")
            end
        end
    end
end)

-- State
local ESPs, Lines = {}, {}
local FOVCircle

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Utils
local function getName(p)
    return p.Name
end
local function getHealth(p)
    local h = p.Character and p.Character:FindFirstChild("Humanoid")
    return (h and h.Health>0) and math.floor(h.Health) or 0
end
local function isAlive(p) return getHealth(p)>0 end
local function getRainbow() return Color3.fromHSV((tick()%5)/5,1,1) end
local function getESPColor(p)
    if Config.ESP.Rainbow then return getRainbow() end
    if Config.ESP.TeamCheck then return (p.TeamColor==Players.LocalPlayer.TeamColor) and Config.ESP.TeamColor or Config.ESP.EnemyColor end
    return Config.ESP.FillColor
end
local function getOutlineColor(p)
    if Config.ESP.Rainbow then return getRainbow() end
    if Config.ESP.TeamCheck then return (p.TeamColor==Players.LocalPlayer.TeamColor) and Config.ESP.TeamColor or Config.ESP.EnemyColor end
    return Config.ESP.OutlineColor
end
local function rayVisible(p)
    if not Config.Aimbot.VisibilityCheck then return true end
    local cam=workspace.CurrentCamera
    local head=p.Character and p.Character:FindFirstChild("Head") if not head then return false end
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={Players.LocalPlayer.Character,p.Character}
    return not workspace:Raycast(cam.CFrame.Position, head.Position-cam.CFrame.Position, rp)
end

-- ESP handlers
local function createOrUpdateESP(p)
    if not ESPs[p] then
        local hl=Instance.new("Highlight"); hl.Adornee=p.Character; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=p.Character
        local bg=Instance.new("BillboardGui",p.Character); bg.AlwaysOnTop=true; bg.Size=UDim2.new(0,200,0,30); bg.StudsOffset=Vector3.new(0,2,0)
        local tl=Instance.new("TextLabel",bg); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Font=Config.ESP.Font; tl.TextSize=18
        ESPs[p]={hl=hl,bg=bg,tl=tl}
    end
    local d=ESPs[p]
    d.hl.FillColor=getESPColor(p); d.hl.FillTransparency=Config.ESP.FillTransparency
    d.hl.OutlineColor=getOutlineColor(p); d.hl.OutlineTransparency=Config.ESP.ShowOutline and Config.ESP.OutlineTransparency or 1
    d.tl.TextColor3=Config.ESP.TextColor
    d.tl.Text=string.format("%s | HP:%d | %dm",getName(p),getHealth(p),math.floor((Players.LocalPlayer.Character.HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude))
end

local function removeESP(p)
    if ESPs[p] then 
        if ESPs[p].hl and ESPs[p].hl.Parent then ESPs[p].hl:Destroy() end
        if ESPs[p].bg and ESPs[p].bg.Parent then ESPs[p].bg:Destroy() end
        ESPs[p]=nil 
    end
    if Lines[p] then Lines[p]:Remove(); Lines[p]=nil end
end

-- Улучшенная система отслеживания игроков
local function isPlayerAlive(player)
    if not player then 
        print("Player is nil")
        return false 
    end
    
    -- Проверяем, что у игрока есть имя
    if not player.Name then
        print("Player has no name")
        return false
    end
    
    if not player.Character then 
        print("Player " .. tostring(player.Name) .. " has no character")
        return false 
    end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then 
        print("Player " .. tostring(player.Name) .. " has no humanoid")
        return false 
    end
    local isAlive = humanoid.Health > 0
    print("Player " .. tostring(player.Name) .. " health: " .. tostring(humanoid.Health) .. ", alive: " .. tostring(isAlive))
    return isAlive
end

local function isPlayerOnServer(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0 and humanoid.Parent ~= nil
end

-- Обработка смерти и респавна игроков
local function onPlayerDied(player)
    removeESP(player)
end

local function onPlayerRespawned(player)
    if Config.ESP.Enabled and player ~= Players.LocalPlayer then
        spawn(function()
            wait(2) -- Увеличиваем задержку для полного респавна
            if isPlayerAlive(player) then
                createOrUpdateESP(player)
            end
        end)
    end
end

-- Подключение обработчиков для каждого игрока
local function setupPlayerESP(player)
    if player == Players.LocalPlayer then return end
    
    -- Обработка смерти
    local function onCharacterAdded(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        -- Обработка смерти
        humanoid.Died:Connect(function()
            onPlayerDied(player)
        end)
        
        -- Обработка респавна через StateChanged
        humanoid.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Dead then
                onPlayerDied(player)
            elseif new == Enum.HumanoidStateType.Running then
                onPlayerRespawned(player)
            end
        end)
        
        -- Дополнительная проверка через CharacterRemoving
        char.AncestryChanged:Connect(function(_, parent)
            if not parent then
                onPlayerDied(player)
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(function()
        onPlayerDied(player)
    end)
end

-- Настройка ESP для существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayerESP(player)
end

-- Настройка ESP для новых игроков
Players.PlayerAdded:Connect(setupPlayerESP)

-- Clean up on player leaving
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

local function getClosestTarget()
    local cam = workspace.CurrentCamera
    local closest, minDist = nil, Config.Aimbot.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p == Players.LocalPlayer then continue end
        if Config.Aimbot.TeamCheck and p.Team == Players.LocalPlayer.Team then continue end
        if not isAlive(p) then continue end
        if Config.Aimbot.VisibilityCheck and not rayVisible(p) then continue end

        local head = p.Character and p.Character:FindFirstChild("Head")
        if not head then continue end
        local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
        if dist < minDist then
            closest = head
            minDist = dist
        end
    end
    return closest
end

-- Render loop: only alive players on server
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Players.LocalPlayer then continue end
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if isPlayerAlive(player) and root then
            if Config.ESP.Enabled then
                createOrUpdateESP(player)
                if Config.ESP.ShowLines then
                    if not Lines[player] then
                        local ln = Drawing.new("Line")
                        ln.Thickness = 2
                        ln.Transparency = 1
                        Lines[player] = ln
                    end
                    local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                    Lines[player].Visible = onScreen
                    if onScreen then
                        Lines[player].From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                        Lines[player].To = Vector2.new(pos.X, pos.Y)
                        Lines[player].Color = getESPColor(player)
                    end
                elseif Lines[player] then
                    Lines[player].Visible = false
                end
            else
                removeESP(player)
            end
        else
            -- Убираем ESP если игрок мертв
            removeESP(player)
        end
    end

    -- Aimbot
if Config.Aimbot.Enabled then
    local target = getClosestTarget()
    if target then
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
    end
end

-- FOV Circle update
local cam = workspace.CurrentCamera
FOVCircle.Visible = Config.Aimbot.Enabled
FOVCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
FOVCircle.Color = Config.Aimbot.FOVRainbow and getRainbow() or Config.Aimbot.FOVColor
FOVCircle.Radius = Config.Aimbot.FOV


    -- Aimbot logic unchanged below...
end)

-- Hotkeys binding
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        if Config.ESP.ToggleKey and inp.KeyCode == Config.ESP.ToggleKey then
            Config.ESP.Enabled = not Config.ESP.Enabled
            print("ESP toggled:", Config.ESP.Enabled)
        elseif Config.Aimbot.ToggleKey and inp.KeyCode == Config.Aimbot.ToggleKey then
            Config.Aimbot.Enabled = not Config.Aimbot.Enabled
            print("Aimbot toggled:", Config.Aimbot.Enabled)
        end
    end
end)

-- GUI Setup 
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "SslkinGui"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Name = "MainFrame"
frame.Position = UDim2.new(0, 20, 0.5, -200)
frame.Size = UDim2.new(0, 300, 0, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local titleBar = Instance.new("Frame", frame)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "SSLKIN UNI-GUI"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.TextXAlignment = Enum.TextXAlignment.Left

local collapseBtn = Instance.new("TextButton", titleBar)
collapseBtn.Name = "Collapse"
collapseBtn.Size = UDim2.new(0, 26, 0, 26)
collapseBtn.Position = UDim2.new(1, -30, 0.5, -13)
collapseBtn.Text = "−"
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.TextSize = 18
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
Instance.new("UICorner", collapseBtn).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0, 0, 0, 30)
scroll.Size = UDim2.new(1, 0, 1, -46)
scroll.CanvasSize = UDim2.new(0, 0, 3, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ClipsDescendants = true

local innerContainer = Instance.new("Frame", scroll)
innerContainer.Name = "InnerContainer"
innerContainer.BackgroundTransparency = 1
innerContainer.Size = UDim2.new(1, -20, 0, 0)
innerContainer.Position = UDim2.new(0, 10, 0, 0)
innerContainer.AutomaticSize = Enum.AutomaticSize.Y
innerContainer.ClipsDescendants = false

local function toggleMenu()
    Config.MenuCollapsed = not Config.MenuCollapsed
    local collapsed = Config.MenuCollapsed
    local size = collapsed and UDim2.new(0, 280, 0, 40) or UDim2.new(0, 280, 0, 800)
    local text = collapsed and "+" or "−"
    local color = collapsed and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)

    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = size
    }):Play()

    TweenService:Create(collapseBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = color
    }):Play()

    collapseBtn.Text = text
    scroll.Visible = not collapsed
end

collapseBtn.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        toggleMenu()
    end
end)

local UIListLayout = Instance.new("UIListLayout", innerContainer)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper functions
local function sectionHeader(text)
	-- Добавляем отступ перед заголовком
	local spacer = Instance.new("Frame", innerContainer)
	spacer.Size = UDim2.new(1, 0, 0, 10)
	spacer.BackgroundTransparency = 1
	
	local lbl = Instance.new("TextLabel", innerContainer)
	lbl.Text = text
	lbl.Size = UDim2.new(1, -10, 0, 30)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 16
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.BackgroundTransparency = 1
end

local function toggle(label, default, callback)
	local btn = Instance.new("TextButton", innerContainer)
	btn.Size = UDim2.new(1, -10, 0, 28)
	btn.Text = label .. ": " .. (default and "ON" or "OFF")
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

	btn.MouseButton1Click:Connect(function()
		default = not default
		btn.Text = label .. ": " .. (default and "ON" or "OFF")
		callback(default)
	end)
	
	return btn
end

local function slider(label, min, max, value, callback)
	local container = Instance.new("Frame", innerContainer)
	container.Size = UDim2.new(1, -10, 0, 36)
	container.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel", container)
	lbl.Text = label .. ": " .. value
	lbl.Size = UDim2.new(1, 0, 0.5, 0)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.BackgroundTransparency = 1

	local sliderBack = Instance.new("Frame", container)
	sliderBack.Position = UDim2.new(0,0,0.5,4)
	sliderBack.Size = UDim2.new(1, 0, 0, 6)
	sliderBack.BackgroundColor3 = Color3.fromRGB(50,50,50)
	Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(1,0)

	local sliderFill = Instance.new("Frame", sliderBack)
	sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,0)

	local dragging = false
	sliderBack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	RunService.RenderStepped:Connect(function()
		if dragging then
			local pos = UserInputService:GetMouseLocation().X
			local abs = sliderBack.AbsolutePosition.X
			local width = sliderBack.AbsoluteSize.X
			local pct = math.clamp((pos - abs) / width, 0, 1)
			local newVal = math.floor((min + (max - min) * pct) * 10) / 10
			sliderFill.Size = UDim2.new(pct, 0, 1, 0)
			lbl.Text = label .. ": " .. newVal
			callback(newVal)
		end
	end)
end

local function colorPicker(labelText, currentColor, callback)
    local lbl = Instance.new("TextLabel", innerContainer)
    lbl.Text = labelText
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14

    local colors = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(128, 128, 128),
        Color3.fromRGB(255, 165, 0),
    }

    local row = Instance.new("Frame", innerContainer)
    row.Size = UDim2.new(1, -10, 0, 28)
    row.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", row)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Padding = UDim.new(0, 4)

    for _, clr in pairs(colors) do
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.BackgroundColor3 = clr
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.MouseButton1Click:Connect(function()
            callback(clr)
        end)
    end
end

local function speedInput(label, currentSpeed, callback)
    local container = Instance.new("Frame", innerContainer)
    container.Size = UDim2.new(1, -10, 0, 36)
    container.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", container)
    lbl.Text = label .. ": " .. currentSpeed
    lbl.Size = UDim2.new(0.7, 0, 0.5, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1

    local inputBox = Instance.new("TextBox", container)
    inputBox.Position = UDim2.new(0.7, 5, 0.25, 0)
    inputBox.Size = UDim2.new(0.3, -5, 0.5, 0)
    inputBox.Text = tostring(currentSpeed)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    inputBox.TextColor3 = Color3.new(1,1,1)
    inputBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    inputBox.PlaceholderText = "Speed"
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,4)

    inputBox.FocusLost:Connect(function()
        local newSpeed = tonumber(inputBox.Text)
        if newSpeed and newSpeed > 0 then
            callback(newSpeed)
            lbl.Text = label .. ": " .. newSpeed
        else
            inputBox.Text = tostring(currentSpeed)
        end
    end)

    return lbl, inputBox
end

local function playerSelector(label, currentPlayer, callback)
    local container = Instance.new("Frame", innerContainer)
    container.Size = UDim2.new(1, -10, 0, 36)
    container.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", container)
    lbl.Text = label .. ": " .. (currentPlayer and currentPlayer.Name or "None")
    lbl.Size = UDim2.new(0.7, 0, 0.5, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1

    local selectBtn = Instance.new("TextButton", container)
    selectBtn.Position = UDim2.new(0.7, 5, 0.25, 0)
    selectBtn.Size = UDim2.new(0.3, -5, 0.5, 0)
    selectBtn.Text = "Выбрать игрока"
    selectBtn.Font = Enum.Font.Gotham
    selectBtn.TextSize = 12
    selectBtn.TextColor3 = Color3.new(1,1,1)
    selectBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0,4)

    selectBtn.MouseButton1Click:Connect(function()
        print("=== КНОПКА ВЫБОРА ИГРОКА НАЖАТА ===")
        
        -- Используем новую функцию создания окна выбора игрока
        createPlayerSelectionWindow()
        
        -- Обновляем текст после выбора игрока
        if TeleportConfig.TargetPlayer then
            lbl.Text = label .. ": " .. TeleportConfig.TargetPlayer.Name
            callback(TeleportConfig.TargetPlayer)
        end
    end)

    return lbl, selectBtn
end

-- 🔥 Горячие клавиши переключения ESP / Aimbot / Fly
local function keyBindButton(name, currentKey, callback)
    local btn = Instance.new("TextButton", innerContainer)
    btn.Size = UDim2.new(1, -10, 0, 24)
    btn.Text = name .. " Hotkey: [" .. (currentKey and tostring(currentKey.Name) or "None") .. "]"
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        btn.Text = name .. " Hotkey: [Press any key]"
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.UserInputType == Enum.UserInputType.Keyboard then
                conn:Disconnect()
                callback(input.KeyCode)
                btn.Text = name .. " Hotkey: [" .. tostring(input.KeyCode.Name) .. "]"
            end
        end)
    end)
end

-- Кнопки назначения горячих клавиш
keyBindButton("ESP", Config.ESP.ToggleKey, function(newKey)
    Config.ESP.ToggleKey = newKey
end)

keyBindButton("Aimbot", Config.Aimbot.ToggleKey, function(newKey)
    Config.Aimbot.ToggleKey = newKey
end)

keyBindButton("Fly", FlyConfig.ToggleKey, function(newKey)
    FlyConfig.ToggleKey = newKey
end)

keyBindButton("NoClip", NoClipConfig.ToggleKey, function(newKey)
    NoClipConfig.ToggleKey = newKey
end)

keyBindButton("SpeedHack", SpeedHackConfig.ToggleKey, function(newKey)
    SpeedHackConfig.ToggleKey = newKey
end)

keyBindButton("Teleport", TeleportConfig.ToggleKey, function(newKey)
    TeleportConfig.ToggleKey = newKey
end)



-- 🟦 ESP
sectionHeader("🔷ESP Settings")
toggle("ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
toggle("Team Check", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
toggle("Show Outline", Config.ESP.ShowOutline, function(v) Config.ESP.ShowOutline = v end)
toggle("Show Lines", Config.ESP.ShowLines, function(v) Config.ESP.ShowLines = v end)
toggle("Rainbow Colors", Config.ESP.Rainbow, function(v) Config.ESP.Rainbow = v end)

colorPicker("Fill Color", Config.ESP.FillColor, function(c) Config.ESP.FillColor = c end)
colorPicker("Outline Color", Config.ESP.OutlineColor, function(c) Config.ESP.OutlineColor = c end)
colorPicker("Text Color", Config.ESP.TextColor, function(c) Config.ESP.TextColor = c end)
slider("Fill Transparency", 0, 1, Config.ESP.FillTransparency, function(v) Config.ESP.FillTransparency = v end)
slider("Outline Transparency", 0, 1, Config.ESP.OutlineTransparency, function(v) Config.ESP.OutlineTransparency = v end)

-- Разделитель
local divider1 = Instance.new("Frame", innerContainer)
divider1.Size = UDim2.new(1, -10, 0, 2)
divider1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
divider1.BorderSizePixel = 0

-- 🟥 Aimbot
sectionHeader("🔷Aimbot Settings")
toggle("Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
toggle("Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
toggle("Visibility Check", Config.Aimbot.VisibilityCheck, function(v) Config.Aimbot.VisibilityCheck = v end)
slider("FOV Radius", 10, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
toggle("FOV Rainbow", Config.Aimbot.FOVRainbow, function(v) Config.Aimbot.FOVRainbow = v end)
colorPicker("Aimbot FOV Color", Config.Aimbot.FOVColor, function(c) Config.Aimbot.FOVColor = c end)

-- Разделитель
local divider2 = Instance.new("Frame", innerContainer)
divider2.Size = UDim2.new(1, -10, 0, 2)
divider2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
divider2.BorderSizePixel = 0

-- Система обновления GUI
local guiCallbacks = {}

-- Функция для обновления отображения статуса в реальном времени
local function updateStatusDisplay()
    if guiCallbacks.fly then
        guiCallbacks.fly.Text = "Fly: " .. (FlyConfig.Enabled and "ON" or "OFF")
    end
    if guiCallbacks.noClip then
        guiCallbacks.noClip.Text = "NoClip: " .. (NoClipConfig.Enabled and "ON" or "OFF")
    end
    if guiCallbacks.speedHack then
        guiCallbacks.speedHack.Text = "SpeedHack: " .. (SpeedHackConfig.Enabled and "ON" or "OFF")
    end
    if guiCallbacks.teleport then
        guiCallbacks.teleport.Text = "Выбранный игрок: " .. (TeleportConfig.SelectedPlayerName or "Не выбран")
    end
end

-- Обновляем отображение каждые 0.5 секунды
RunService.Heartbeat:Connect(function()
    updateStatusDisplay()
end)

-- 🟨 Fly System Integration
sectionHeader("🟨 Fly Settings")

local flyToggleBtn = toggle("Fly", FlyConfig.Enabled, function(v)
    FlyConfig.Enabled = v
    if v then startFly() else stopFly() end
    -- Обновляем текст кнопки
    if guiCallbacks.fly then
        guiCallbacks.fly.Text = "Fly: " .. (v and "ON" or "OFF")
    end
end)
guiCallbacks.fly = flyToggleBtn

slider("Fly Speed", 0.1, 10, FlyConfig.Speed, function(v)
    FlyConfig.Speed = v
end)

-- Кастомный ввод скорости для полета
speedInput("Custom Fly Speed", FlyConfig.Speed, function(v)
    FlyConfig.Speed = v
end)

-- Разделитель
local divider3 = Instance.new("Frame", innerContainer)
divider3.Size = UDim2.new(1, -10, 0, 2)
divider3.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
divider3.BorderSizePixel = 0

-- 🟪 NoClip System Integration
sectionHeader("🟪 NoClip Settings")

local noClipToggleBtn = toggle("NoClip", NoClipConfig.Enabled, function(v)
    NoClipConfig.Enabled = v
    if v then startNoClip() else stopNoClip() end
    -- Обновляем текст кнопки
    if guiCallbacks.noClip then
        guiCallbacks.noClip.Text = "NoClip: " .. (v and "ON" or "OFF")
    end
end)
guiCallbacks.noClip = noClipToggleBtn

-- Разделитель
local divider4 = Instance.new("Frame", innerContainer)
divider4.Size = UDim2.new(1, -10, 0, 2)
divider4.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
divider4.BorderSizePixel = 0

-- 🟦 SpeedHack System Integration
sectionHeader("🟦 SpeedHack Settings")

local speedHackToggleBtn = toggle("SpeedHack", SpeedHackConfig.Enabled, function(v)
    SpeedHackConfig.Enabled = v
    if v then startSpeedHack() else stopSpeedHack() end
    -- Обновляем текст кнопки
    if guiCallbacks.speedHack then
        guiCallbacks.speedHack.Text = "SpeedHack: " .. (v and "ON" or "OFF")
    end
end)
guiCallbacks.speedHack = speedHackToggleBtn

toggle("Use JumpPower Method", SpeedHackConfig.UseJumpPower, function(v)
    SpeedHackConfig.UseJumpPower = v
    -- Перезапускаем SpeedHack если он активен
    if SpeedHackConfig.Enabled then
        stopSpeedHack()
        startSpeedHack()
    end
end)

slider("SpeedHack Speed", 0.1, 10, SpeedHackConfig.Speed, function(v)
    SpeedHackConfig.Speed = v
    -- Обновляем скорость если SpeedHack активен
    if SpeedHackConfig.Enabled then
        local char = Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v * 16
            if SpeedHackConfig.UseJumpPower then
                hum.JumpPower = v * 50
            end
        end
    end
end)

-- Кастомный ввод скорости для SpeedHack
speedInput("Custom SpeedHack Speed", SpeedHackConfig.Speed, function(v)
    SpeedHackConfig.Speed = v
    -- Обновляем скорость если SpeedHack активен
    if SpeedHackConfig.Enabled then
        local char = Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v * 16
            if SpeedHackConfig.UseJumpPower then
                hum.JumpPower = v * 50
            end
        end
    end
end)

-- Разделитель
local divider5 = Instance.new("Frame", innerContainer)
divider5.Size = UDim2.new(1, -10, 0, 2)
divider5.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
divider5.BorderSizePixel = 0

-- 🟩 Teleport System Integration
sectionHeader("🟩 Настройки телепортации")

-- Показываем выбранного игрока
local selectedPlayerLabel = Instance.new("TextLabel", innerContainer)
selectedPlayerLabel.Size = UDim2.new(1, -10, 0, 24)
selectedPlayerLabel.Text = "Выбранный игрок: " .. (TeleportConfig.SelectedPlayerName or "Не выбран")
selectedPlayerLabel.Font = Enum.Font.GothamBold
selectedPlayerLabel.TextSize = 14
selectedPlayerLabel.TextColor3 = Color3.new(1,1,1)
selectedPlayerLabel.BackgroundTransparency = 1
selectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка старт телепорт
local startTeleportBtn = Instance.new("TextButton", innerContainer)
startTeleportBtn.Size = UDim2.new(1, -10, 0, 28)
startTeleportBtn.Text = "СТАРТ ТЕЛЕПОРТ"
startTeleportBtn.Font = Enum.Font.GothamBold
startTeleportBtn.TextSize = 14
startTeleportBtn.TextColor3 = Color3.new(1,1,1)
startTeleportBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
startTeleportBtn.AutoButtonColor = false
Instance.new("UICorner", startTeleportBtn).CornerRadius = UDim.new(0,6)

startTeleportBtn.MouseButton1Click:Connect(function()
    if not TeleportConfig.TargetPlayer then
        startTeleportBtn.Text = "Сначала выберите игрока!"
        task.wait(2)
        startTeleportBtn.Text = "СТАРТ ТЕЛЕПОРТ"
        return
    end
    
    if TeleportConfig.Enabled then
        -- Останавливаем телепортацию
        stopTeleport()
        TeleportConfig.Enabled = false
        startTeleportBtn.Text = "СТАРТ ТЕЛЕПОРТ"
        startTeleportBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    else
        -- Запускаем телепортацию
        startTeleport()
        TeleportConfig.Enabled = true
        startTeleportBtn.Text = "ОСТАНОВИТЬ ТЕЛЕПОРТ"
        startTeleportBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)

-- Кнопка выключить телепортацию
local stopTeleportBtn = Instance.new("TextButton", innerContainer)
stopTeleportBtn.Size = UDim2.new(1, -10, 0, 28)
stopTeleportBtn.Text = "ВЫКЛЮЧИТЬ ТЕЛЕПОРТАЦИЮ"
stopTeleportBtn.Font = Enum.Font.GothamBold
stopTeleportBtn.TextSize = 14
stopTeleportBtn.TextColor3 = Color3.new(1,1,1)
stopTeleportBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
stopTeleportBtn.AutoButtonColor = false
Instance.new("UICorner", stopTeleportBtn).CornerRadius = UDim.new(0,6)

stopTeleportBtn.MouseButton1Click:Connect(function()
    if TeleportConfig.Enabled then
        stopTeleport()
        TeleportConfig.Enabled = false
        startTeleportBtn.Text = "СТАРТ ТЕЛЕПОРТ"
        startTeleportBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        stopTeleportBtn.Text = "Телепортация остановлена"
        task.wait(2)
        stopTeleportBtn.Text = "ВЫКЛЮЧИТЬ ТЕЛЕПОРТАЦИЮ"
    else
        stopTeleportBtn.Text = "Телепортация не активна"
        task.wait(2)
        stopTeleportBtn.Text = "ВЫКЛЮЧИТЬ ТЕЛЕПОРТАЦИЮ"
    end
end)

-- Создаем список игроков прямо в меню
local function createPlayerListInMenu()
    local allPlayers = Players:GetPlayers()
    local alivePlayers = {}
    
    -- Получаем список всех игроков кроме локального
    for _, player in ipairs(allPlayers) do
        if player and player ~= Players.LocalPlayer then
            table.insert(alivePlayers, player)
        end
    end
    
    -- Сортируем игроков по алфавиту (по имени)
    table.sort(alivePlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    print("Создаем отсортированный список игроков в меню: " .. #alivePlayers .. " игроков")
    
    -- Создаем кнопки для каждого игрока
    local currentLetter = ""
    for i, player in ipairs(alivePlayers) do
        local firstLetter = player.Name:sub(1,1):upper()
        
        -- Добавляем разделитель для новой буквы
        if firstLetter ~= currentLetter then
            currentLetter = firstLetter
            
            -- Создаем заголовок для буквы
            local letterHeader = Instance.new("TextLabel", innerContainer)
            letterHeader.Size = UDim2.new(1, -10, 0, 20)
            letterHeader.Text = "--- " .. firstLetter .. " ---"
            letterHeader.Font = Enum.Font.GothamBold
            letterHeader.TextSize = 12
            letterHeader.TextColor3 = Color3.fromRGB(255,255,0)
            letterHeader.BackgroundColor3 = Color3.fromRGB(30,30,40)
            letterHeader.BorderSizePixel = 0
            letterHeader.TextXAlignment = Enum.TextXAlignment.Center
            Instance.new("UICorner", letterHeader).CornerRadius = UDim.new(0,4)
        end
        
        local playerBtn = Instance.new("TextButton", innerContainer)
        playerBtn.Size = UDim2.new(1, -10, 0, 30)
        playerBtn.Text = player.Name
        playerBtn.Font = Enum.Font.Gotham
        playerBtn.TextSize = 12
        playerBtn.TextColor3 = Color3.new(1,1,1)
        playerBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
        playerBtn.AutoButtonColor = false
        playerBtn.BorderSizePixel = 1
        playerBtn.BorderColor3 = Color3.fromRGB(100,100,120)
        Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0,4)
        
        -- Эффекты при наведении
        playerBtn.MouseEnter:Connect(function()
            playerBtn.BackgroundColor3 = Color3.fromRGB(70,70,80)
            playerBtn.BorderColor3 = Color3.fromRGB(150,150,170)
        end)
        
        playerBtn.MouseLeave:Connect(function()
            playerBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
            playerBtn.BorderColor3 = Color3.fromRGB(100,100,120)
        end)
        
        -- Обработка выбора игрока
        playerBtn.MouseButton1Click:Connect(function()
            -- Сбрасываем цвет всех кнопок игроков (но не кнопок настроек)
            for _, btn in ipairs(innerContainer:GetChildren()) do
                if btn:IsA("TextButton") and 
                   btn ~= startTeleportBtn and 
                   btn ~= stopTeleportBtn and 
                   btn ~= updatePlayersBtn and
                   btn.Size.Y.Offset == 30 then -- Только кнопки игроков имеют высоту 30
                    btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
                    btn.BorderColor3 = Color3.fromRGB(100,100,120)
                end
            end
            
            -- Выделяем выбранную кнопку
            playerBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
            playerBtn.BorderColor3 = Color3.fromRGB(0,200,0)
            
            TeleportConfig.TargetPlayer = player
            TeleportConfig.SelectedPlayerName = player.Name
            selectedPlayerLabel.Text = "Выбранный игрок: " .. player.Name
            print("Выбран игрок: " .. player.Name)
        end)
    end
end

-- Создаем список игроков
createPlayerListInMenu()

-- Принудительная телепортация и кнопка скрытного режима удалены - телепорт всегда работает в скрытном режиме

-- Кнопка возврата удалена - теперь возврат происходит автоматически при остановке телепортации

-- Обновляем GUI при выборе игрока
guiCallbacks.teleport = selectedPlayerLabel

-- Функция обновления списка игроков
local function updatePlayerList()
    print("ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ...")
    
    -- Создаем временный контейнер для нового списка
    local tempContainer = Instance.new("Frame")
    tempContainer.Name = "TempPlayerList"
    tempContainer.Parent = nil -- Не добавляем в GUI пока
    
    -- Получаем актуальный список игроков
    local allPlayers = Players:GetPlayers()
    local alivePlayers = {}
    for _, player in ipairs(allPlayers) do
        if player and player ~= Players.LocalPlayer then
            table.insert(alivePlayers, player)
        end
    end
    
    -- Сортируем игроков по алфавиту
    table.sort(alivePlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    print("Создаем новый список игроков: " .. #alivePlayers .. " игроков")
    
    -- Создаем кнопки для каждого игрока во временном контейнере
    local currentLetter = ""
    for i, player in ipairs(alivePlayers) do
        local firstLetter = player.Name:sub(1,1):upper()
        
        -- Добавляем разделитель для новой буквы
        if firstLetter ~= currentLetter then
            currentLetter = firstLetter
            
            -- Создаем заголовок для буквы
            local letterHeader = Instance.new("TextLabel", tempContainer)
            letterHeader.Size = UDim2.new(1, -10, 0, 20)
            letterHeader.Text = "--- " .. firstLetter .. " ---"
            letterHeader.Font = Enum.Font.GothamBold
            letterHeader.TextSize = 12
            letterHeader.TextColor3 = Color3.fromRGB(255,255,0)
            letterHeader.BackgroundColor3 = Color3.fromRGB(30,30,40)
            letterHeader.BorderSizePixel = 0
            letterHeader.TextXAlignment = Enum.TextXAlignment.Center
            Instance.new("UICorner", letterHeader).CornerRadius = UDim.new(0,4)
        end
        
        local playerBtn = Instance.new("TextButton", tempContainer)
        playerBtn.Size = UDim2.new(1, -10, 0, 30)
        playerBtn.Text = player.Name
        playerBtn.Font = Enum.Font.Gotham
        playerBtn.TextSize = 12
        playerBtn.TextColor3 = Color3.new(1,1,1)
        playerBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
        playerBtn.AutoButtonColor = false
        playerBtn.BorderSizePixel = 1
        playerBtn.BorderColor3 = Color3.fromRGB(100,100,120)
        Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0,4)
        
        -- Эффекты при наведении
        playerBtn.MouseEnter:Connect(function()
            playerBtn.BackgroundColor3 = Color3.fromRGB(70,70,80)
            playerBtn.BorderColor3 = Color3.fromRGB(150,150,170)
        end)
        
        playerBtn.MouseLeave:Connect(function()
            playerBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
            playerBtn.BorderColor3 = Color3.fromRGB(100,100,120)
        end)
        
        -- Обработка выбора игрока
        playerBtn.MouseButton1Click:Connect(function()
            -- Сбрасываем цвет всех кнопок игроков (но не кнопок настроек)
            for _, btn in ipairs(innerContainer:GetChildren()) do
                if btn:IsA("TextButton") and 
                   btn ~= startTeleportBtn and 
                   btn ~= stopTeleportBtn and 
                   btn ~= updatePlayersBtn and
                   btn.Size.Y.Offset == 30 then -- Только кнопки игроков имеют высоту 30
                    btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
                    btn.BorderColor3 = Color3.fromRGB(100,100,120)
                end
            end
            
            -- Выделяем выбранную кнопку
            playerBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
            playerBtn.BorderColor3 = Color3.fromRGB(0,200,0)
            
            TeleportConfig.TargetPlayer = player
            TeleportConfig.SelectedPlayerName = player.Name
            selectedPlayerLabel.Text = "Выбранный игрок: " .. player.Name
            print("Выбран игрок: " .. player.Name)
        end)
    end
    
    -- Теперь безопасно удаляем ТОЛЬКО старые кнопки игроков и заголовки
    for _, child in ipairs(innerContainer:GetChildren()) do
        if child:IsA("TextButton") then
            -- Проверяем, что это кнопка игрока (не кнопка настроек)
            if child.Text and child.Text:len() > 0 and 
               not child.Text:find("ОБНОВИТЬ") and 
               not child.Text:find("ESP") and 
               not child.Text:find("Aimbot") and 
               not child.Text:find("Fly") and 
               not child.Text:find("NoClip") and 
               not child.Text:find("SpeedHack") and 
               not child.Text:find("Team Check") and 
               not child.Text:find("Show Outline") and 
               not child.Text:find("Show Lines") and 
               not child.Text:find("Rainbow Colors") and 
               not child.Text:find("Fill Color") and 
               not child.Text:find("Outline Color") and 
               not child.Text:find("Text Color") and 
               not child.Text:find("Fill Transparency") and 
               not child.Text:find("Outline Transparency") and 
               not child.Text:find("Visibility Check") and 
               not child.Text:find("FOV Radius") and 
               not child.Text:find("FOV Rainbow") and 
               not child.Text:find("Aimbot FOV Color") and 
               not child.Text:find("Fly Speed") and 
               not child.Text:find("Custom Fly Speed") and 
               not child.Text:find("Use JumpPower Method") and 
               not child.Text:find("SpeedHack Speed") and 
               not child.Text:find("Custom SpeedHack Speed") and 
               not child.Text:find("СТАРТ ТЕЛЕПОРТ") and 
               not child.Text:find("ВЫКЛЮЧИТЬ ТЕЛЕПОРТАЦИЮ") and 
               not child.Text:find("Hotkey:") and 
               child.Size.Y.Offset == 30 then -- Кнопки игроков имеют высоту 30
                child:Destroy()
            end
        end
    end
    
    -- Удаляем старые заголовки букв
    for _, child in ipairs(innerContainer:GetChildren()) do
        if child:IsA("TextLabel") and child.Text and child.Text:find("---") then
            child:Destroy()
        end
    end
    
    -- Перемещаем новые кнопки в основной контейнер
    for _, child in ipairs(tempContainer:GetChildren()) do
        child.Parent = innerContainer
    end
    
    -- Удаляем временный контейнер
    tempContainer:Destroy()
    
    print("СПИСОК ИГРОКОВ ОБНОВЛЕН! Найдено игроков: " .. #alivePlayers)
end

-- Кнопка для обновления списка игроков
local updatePlayersBtn = Instance.new("TextButton", innerContainer)
updatePlayersBtn.Size = UDim2.new(1, -10, 0, 28)
updatePlayersBtn.Text = "ОБНОВИТЬ СПИСОК ИГРОКОВ"
updatePlayersBtn.Font = Enum.Font.GothamBold
updatePlayersBtn.TextSize = 14
updatePlayersBtn.TextColor3 = Color3.new(1,1,1)
updatePlayersBtn.BackgroundColor3 = Color3.fromRGB(100,150,255)
updatePlayersBtn.AutoButtonColor = false
Instance.new("UICorner", updatePlayersBtn).CornerRadius = UDim.new(0,6)

updatePlayersBtn.MouseButton1Click:Connect(function()
    updatePlayersBtn.Text = "ОБНОВЛЯЕМ..."
    updatePlayerList()
    task.wait(1)
    updatePlayersBtn.Text = "СПИСОК ОБНОВЛЕН!"
    task.wait(2)
    updatePlayersBtn.Text = "ОБНОВИТЬ СПИСОК ИГРОКОВ"
    
    -- Через 5 секунд восстанавливаем все кнопки настроек
    task.spawn(function()
        task.wait(5)
        print("Восстанавливаем кнопки настроек через 5 секунд...")
        -- Здесь можно добавить дополнительную логику восстановления если нужно
    end)
end)

-- Автоматическое обновление списка игроков каждые 30 секунд
task.spawn(function()
    while true do
        task.wait(30) -- Ждем 30 секунд
        print("АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ...")
        updatePlayerList()
    end
end) 
