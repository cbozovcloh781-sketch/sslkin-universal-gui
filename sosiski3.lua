-- Frostware Modern Menu - Fixed Version

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local FrostwareGui = Instance.new("ScreenGui", CoreGui)
FrostwareGui.Name = "FrostwareGui"
FrostwareGui.ResetOnSpawn = false

-- Default configurations (if not defined elsewhere)
if not Config then
    Config = {
        ESP = {
            Enabled = false,
            TeamCheck = false,
            ShowOutline = true,
            ShowLines = false,
            Rainbow = false,
            FillColor = Color3.fromRGB(255, 255, 255),
            OutlineColor = Color3.fromRGB(255, 0, 0),
            TextColor = Color3.fromRGB(255, 255, 255),
            FillTransparency = 0.5,
            OutlineTransparency = 0,
            ToggleKey = nil
        },
        Aimbot = {
            Enabled = false,
            TeamCheck = false,
            VisibilityCheck = true,
            FOV = 100,
            FOVRainbow = false,
            FOVColor = Color3.fromRGB(255, 255, 255),
            ToggleKey = nil
        }
    }
end

if not FlyConfig then
    FlyConfig = {
        Enabled = false,
        Speed = 1,
        ToggleKey = nil
    }
end

if not NoClipConfig then
    NoClipConfig = {
        Enabled = false,
        ToggleKey = nil
    }
end

if not SpeedHackConfig then
    SpeedHackConfig = {
        Enabled = false,
        Speed = 1,
        UseJumpPower = false,
        ToggleKey = nil
    }
end

if not LongJumpConfig then
    LongJumpConfig = {
        Enabled = false,
        JumpPower = 100
    }
end

if not InfiniteJumpConfig then
    InfiniteJumpConfig = {
        Enabled = false,
        JumpPower = 50
    }
end

if not YBAConfig then
    YBAConfig = {
        Enabled = false,
        ToggleKey = nil,
        ItemESP = {
            Enabled = false,
            Items = {}
        },
        UndergroundControl = {
            FlightSpeed = 100
        }
    }
end

if not TeleportConfig then
    TeleportConfig = {
        Enabled = false,
        TargetPlayer = nil,
        SelectedPlayerName = nil,
        OriginalPosition = nil,
        ToggleKey = nil
    }
end

-- Placeholder functions (if not defined elsewhere)
local function startFly() print("Fly started") end
local function stopFly() print("Fly stopped") end
local function startNoClip() print("NoClip started") end
local function stopNoClip() print("NoClip stopped") end
local function startSpeedHack() print("SpeedHack started") end
local function stopSpeedHack() print("SpeedHack stopped") end
local function startLongJump() print("LongJump started") end
local function stopLongJump() print("LongJump stopped") end
local function startInfiniteJump() print("InfiniteJump started") end
local function stopInfiniteJump() print("InfiniteJump stopped") end
local function startYBA() print("YBA started") end
local function stopYBA() print("YBA stopped") end
local function startUndergroundControl() print("UndergroundControl started") end
local function stopUndergroundControl() print("UndergroundControl stopped") end
local function startItemESP() print("ItemESP started") end
local function stopItemESP() print("ItemESP stopped") end
local function startTeleport() print("Teleport started") end
local function stopTeleport() print("Teleport stopped") end

local isNoClipping = false

-- Main frame
local mainFrame = Instance.new("Frame", FrostwareGui)
mainFrame.Name = "MainFrame"
mainFrame.Position = UDim2.new(0, 60, 0.5, -220)
mainFrame.Size = UDim2.new(0, 420, 0, 440)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Hide/Show button
local showBtn = Instance.new("TextButton", FrostwareGui)
showBtn.Size = UDim2.new(0, 40, 0, 40)
showBtn.Position = UDim2.new(1, -60, 0, 20)
showBtn.AnchorPoint = Vector2.new(1, 0)
showBtn.Text = "≡"
showBtn.Font = Enum.Font.GothamBold
showBtn.TextSize = 24
showBtn.TextColor3 = Color3.fromRGB(220,220,240)
showBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(1, 20)
showBtn.Visible = false

-- Скрытие/открытие меню
local function setMenuVisible(visible)
    mainFrame.Visible = visible
    showBtn.Visible = not visible
end
setMenuVisible(true)

-- Кнопка скрытия (крестик)
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 4)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(220,100,100)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 16)

closeBtn.MouseButton1Click:Connect(function()
    setMenuVisible(false)
end)
showBtn.MouseButton1Click:Connect(function()
    setMenuVisible(true)
end)

-- Поддержка клавиши Insert
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        setMenuVisible(not mainFrame.Visible)
    end
end)

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 110, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

local tabList = Instance.new("Frame", sidebar)
tabList.Size = UDim2.new(1, 0, 1, 0)
tabList.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabList)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 8)

-- Content frame
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Name = "ContentFrame"
contentFrame.Position = UDim2.new(0, 110, 0, 0)
contentFrame.Size = UDim2.new(1, -110, 1, 0)
contentFrame.BackgroundTransparency = 1

-- Tabs
local tabs = {
    {name = "ESP", icon = "👁"},
    {name = "Aimbot", icon = "🎯"},
    {name = "Fly", icon = "🦅"},
    {name = "NoClip", icon = "🚪"},
    {name = "Speed", icon = "⚡"},
    {name = "Jump", icon = "🦘"},
    {name = "YBA", icon = "👊"},
    {name = "Teleport", icon = "📍"},
    {name = "Settings", icon = "⚙️"},
}

local tabButtons = {}
local tabFrames = {}
local tabContainers = {}

-- Helper: Toggle switch
local function createToggle(parent, label, state, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Text = label
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("Frame", row)
    toggle.Size = UDim2.new(0, 44, 0, 22)
    toggle.Position = UDim2.new(1, -54, 0.5, -11)
    toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(60, 60, 60)
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 11)

    local knob = Instance.new("Frame", toggle)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 9)

    local function setState(on)
        state = on
        toggle.BackgroundColor3 = on and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(60, 60, 60)
        knob:TweenPosition(on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.15, true)
        callback(on)
    end

    -- Make the entire row clickable
    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not state)
        end
    end)
    
    return row
end

-- Helper: Slider
local function createSlider(parent, label, min, max, value, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Text = label .. ": " .. value
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBack = Instance.new("Frame", row)
    sliderBack.Position = UDim2.new(0.5, 10, 0.5, -7)
    sliderBack.Size = UDim2.new(0.45, -20, 0, 14)
    sliderBack.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(1,7)

    local sliderFill = Instance.new("Frame", sliderBack)
    sliderFill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1,7)

    local dragging = false
    local connection
    
    local function updateSlider(input)
        local pos = input.Position.X
        local abs = sliderBack.AbsolutePosition.X
        local width = sliderBack.AbsoluteSize.X
        local pct = math.clamp((pos - abs) / width, 0, 1)
        local newVal = math.floor((min + (max - min) * pct) * 10) / 10
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        lbl.Text = label .. ": " .. newVal
        callback(newVal)
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
            
            connection = UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    
    return row
end

-- Helper: Color picker
local function createColorPicker(parent, label, currentColor, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Text = label
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local colorBtn = Instance.new("TextButton", row)
    colorBtn.Size = UDim2.new(0, 32, 0, 24)
    colorBtn.Position = UDim2.new(1, -40, 0.5, -12)
    colorBtn.BackgroundColor3 = currentColor
    colorBtn.Text = ""
    colorBtn.AutoButtonColor = true
    Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(1, 12)

    local colors = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(128, 0, 128),
        Color3.fromRGB(0, 128, 0),
    }

    local colorIndex = 1
    colorBtn.MouseButton1Click:Connect(function()
        colorIndex = (colorIndex % #colors) + 1
        local newColor = colors[colorIndex]
        colorBtn.BackgroundColor3 = newColor
        callback(newColor)
    end)
    
    return row
end

-- Helper: Section header
local function sectionHeader(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Text = text
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(180,180,200)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- Helper: Button
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Create tabs
for i, tab in ipairs(tabs) do
    -- Tab button
    local btn = Instance.new("TextButton", tabList)
    btn.Size = UDim2.new(1, -16, 0, 38)
    btn.Text = tab.icon .. "  " .. tab.name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(220,220,240)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(30, 30, 40)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    tabButtons[tab.name] = btn

    -- Tab content frame
    local tabFrame = Instance.new("Frame", contentFrame)
    tabFrame.Name = tab.name .. "Tab"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = (i == 1)
    tabFrames[tab.name] = tabFrame

    -- Scrolling frame
    local scrollFrame = Instance.new("ScrollingFrame", tabFrame)
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ClipsDescendants = true

    -- Container
    local container = Instance.new("Frame", scrollFrame)
    container.Size = UDim2.new(1, -20, 0, 0)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Tab switching
    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end
        tabFrame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    end)

    -- Store container
    tabContainers[tab.name] = container
end

-- === ESP TAB ===
local espContainer = tabContainers["ESP"]

createToggle(espContainer, "ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
createToggle(espContainer, "Team Check", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
createToggle(espContainer, "Show Outline", Config.ESP.ShowOutline, function(v) Config.ESP.ShowOutline = v end)
createToggle(espContainer, "Show Lines", Config.ESP.ShowLines, function(v) Config.ESP.ShowLines = v end)
createToggle(espContainer, "Rainbow Colors", Config.ESP.Rainbow, function(v) Config.ESP.Rainbow = v end)
createColorPicker(espContainer, "Fill Color", Config.ESP.FillColor, function(c) Config.ESP.FillColor = c end)
createColorPicker(espContainer, "Outline Color", Config.ESP.OutlineColor, function(c) Config.ESP.OutlineColor = c end)
createColorPicker(espContainer, "Text Color", Config.ESP.TextColor, function(c) Config.ESP.TextColor = c end)
createSlider(espContainer, "Fill Transparency", 0, 1, Config.ESP.FillTransparency, function(v) Config.ESP.FillTransparency = v end)
createSlider(espContainer, "Outline Transparency", 0, 1, Config.ESP.OutlineTransparency, function(v) Config.ESP.OutlineTransparency = v end)

-- === AIMBOT TAB ===
local aimbotContainer = tabContainers["Aimbot"]

createToggle(aimbotContainer, "Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
createToggle(aimbotContainer, "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
createToggle(aimbotContainer, "Visibility Check", Config.Aimbot.VisibilityCheck, function(v) Config.Aimbot.VisibilityCheck = v end)
createSlider(aimbotContainer, "FOV Radius", 10, 500, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
createToggle(aimbotContainer, "FOV Rainbow", Config.Aimbot.FOVRainbow, function(v) Config.Aimbot.FOVRainbow = v end)
createColorPicker(aimbotContainer, "Aimbot FOV Color", Config.Aimbot.FOVColor, function(c) Config.Aimbot.FOVColor = c end)

-- === FLY TAB ===
local flyContainer = tabContainers["Fly"]

createToggle(flyContainer, "Fly", FlyConfig.Enabled, function(v) FlyConfig.Enabled = v if v then startFly() else stopFly() end end)
createSlider(flyContainer, "Fly Speed", 0.1, 10, FlyConfig.Speed, function(v) FlyConfig.Speed = v end)

-- === NOCLIP TAB ===
local noClipContainer = tabContainers["NoClip"]

createToggle(noClipContainer, "NoClip", NoClipConfig.Enabled, function(v) NoClipConfig.Enabled = v if v then startNoClip() else stopNoClip() end end)
createButton(noClipContainer, "Force NoClip Toggle", function()
    if isNoClipping then
        stopNoClip()
    else
        startNoClip()
    end
end)

-- === SPEED TAB ===
local speedContainer = tabContainers["Speed"]

createToggle(speedContainer, "SpeedHack", SpeedHackConfig.Enabled, function(v) SpeedHackConfig.Enabled = v if v then startSpeedHack() else stopSpeedHack() end end)
createToggle(speedContainer, "Use JumpPower Method", SpeedHackConfig.UseJumpPower, function(v) SpeedHackConfig.UseJumpPower = v end)
createSlider(speedContainer, "SpeedHack Speed", 0.1, 10, SpeedHackConfig.Speed, function(v) SpeedHackConfig.Speed = v end)

-- === JUMP TAB ===
local jumpContainer = tabContainers["Jump"]

createToggle(jumpContainer, "Long Jump", LongJumpConfig.Enabled, function(v) LongJumpConfig.Enabled = v if v then startLongJump() else stopLongJump() end end)
createSlider(jumpContainer, "Long Jump Power", 50, 500, LongJumpConfig.JumpPower, function(v) LongJumpConfig.JumpPower = v end)
createToggle(jumpContainer, "Infinite Jump", InfiniteJumpConfig.Enabled, function(v) InfiniteJumpConfig.Enabled = v if v then startInfiniteJump() else stopInfiniteJump() end end)
createSlider(jumpContainer, "Infinite Jump Power", 20, 150, InfiniteJumpConfig.JumpPower, function(v) InfiniteJumpConfig.JumpPower = v end)

-- === YBA TAB ===
local ybaContainer = tabContainers["YBA"]

createToggle(ybaContainer, "Stand Range Hack", YBAConfig.Enabled, function(v) YBAConfig.Enabled = v if v then startYBA() else stopYBA() end end)
createToggle(ybaContainer, "Underground Flight", false, function(v) if v then startUndergroundControl() else stopUndergroundControl() end end)
createToggle(ybaContainer, "Item ESP", YBAConfig.ItemESP.Enabled, function(v) YBAConfig.ItemESP.Enabled = v if v then startItemESP() else stopItemESP() end end)
createSlider(ybaContainer, "Flight & Stand Speed", 25, 300, YBAConfig.UndergroundControl.FlightSpeed, function(v) YBAConfig.UndergroundControl.FlightSpeed = math.floor(v) end)

-- Item selection for YBA
sectionHeader(ybaContainer, "Item Selection")
local itemNames = {
    "Mysterious Arrow", "Rokakaka", "Pure Rokakaka", "Diamond", "Gold Coin", "Steel Ball", "Clackers",
    "Caesar's Headband", "Zeppeli's Hat", "Zeppeli's Scarf", "Quinton's Glove", "Stone Mask",
    "Rib Cage of The Saint's Corpse", "Ancient Scroll", "DIO's Diary", "DIO's Bone", "DIO's Diary Page",
    "Lucky Stone Mask", "Lucky Arrow"
}

for _, itemName in ipairs(itemNames) do
    createToggle(ybaContainer, itemName, YBAConfig.ItemESP.Items[itemName], function(v)
        YBAConfig.ItemESP.Items[itemName] = v
    end)
end

-- === TELEPORT TAB ===
local teleportContainer = tabContainers["Teleport"]

createToggle(teleportContainer, "Teleport", TeleportConfig.Enabled, function(v) TeleportConfig.Enabled = v if v then startTeleport() else stopTeleport() end end)
createButton(teleportContainer, "Start Teleport", function()
    if not TeleportConfig.TargetPlayer then
        print("Select player first!")
        return
    end
    if TeleportConfig.Enabled then
        stopTeleport()
        TeleportConfig.Enabled = false
    else
        startTeleport()
        TeleportConfig.Enabled = true
    end
end)
createButton(teleportContainer, "Stop Teleport", function()
    if TeleportConfig.Enabled then
        stopTeleport()
        TeleportConfig.Enabled = false
    end
end)
createButton(teleportContainer, "Stop Return", function()
    if _G.returnConnections then
        for _, connection in ipairs(_G.returnConnections) do
            if connection then pcall(function() connection:Disconnect() end) end
        end
        _G.returnConnections = nil
    end
    if _G.returnLoop then
        pcall(function() _G.returnLoop:Disconnect() end)
        _G.returnLoop = nil
    end
    TeleportConfig.OriginalPosition = nil
end)

-- Player selection for teleport
sectionHeader(teleportContainer, "Player Selection")
local function createPlayerList(parent)
    local allPlayers = Players:GetPlayers()
    local alivePlayers = {}
    
    for _, player in ipairs(allPlayers) do
        if player and player ~= Players.LocalPlayer then
            table.insert(alivePlayers, player)
        end
    end
    
    table.sort(alivePlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    for _, player in ipairs(alivePlayers) do
        local playerBtn = Instance.new("TextButton", parent)
        playerBtn.Size = UDim2.new(1, 0, 0, 30)
        playerBtn.Text = player.Name
        playerBtn.Font = Enum.Font.Gotham
        playerBtn.TextSize = 12
        playerBtn.TextColor3 = Color3.new(1,1,1)
        playerBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
        playerBtn.AutoButtonColor = false
        Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0,4)
        
        playerBtn.MouseButton1Click:Connect(function()
            TeleportConfig.TargetPlayer = player
            TeleportConfig.SelectedPlayerName = player.Name
            print("Selected player: " .. player.Name)
        end)
    end
end

createPlayerList(teleportContainer)

-- === SETTINGS TAB ===
local settingsContainer = tabContainers["Settings"]

createButton(settingsContainer, "Update Player List", function()
    print("Player list updated")
end)

-- Hotkey settings
sectionHeader(settingsContainer, "Hotkeys")
createButton(settingsContainer, "ESP Hotkey: [" .. (Config.ESP.ToggleKey and tostring(Config.ESP.ToggleKey.Name) or "None") .. "]", function()
    -- Hotkey binding logic
end)
createButton(settingsContainer, "Aimbot Hotkey: [" .. (Config.Aimbot.ToggleKey and tostring(Config.Aimbot.ToggleKey.Name) or "None") .. "]", function()
    -- Hotkey binding logic
end)
createButton(settingsContainer, "Fly Hotkey: [" .. (FlyConfig.ToggleKey and tostring(FlyConfig.ToggleKey.Name) or "None") .. "]", function()
    -- Hotkey binding logic
end)
createButton(settingsContainer, "NoClip Hotkey: [" .. (NoClipConfig.ToggleKey and tostring(NoClipConfig.ToggleKey.Name) or "None") .. "]", function()
    -- Hotkey binding logic
end)
createButton(settingsContainer, "SpeedHack Hotkey: [" .. (SpeedHackConfig.ToggleKey and tostring(SpeedHackConfig.ToggleKey.Name) or "None") .. "]", function()
    -- Hotkey binding logic
end)
createButton(settingsContainer, "Teleport Hotkey: [" .. (TeleportConfig.ToggleKey and tostring(TeleportConfig.ToggleKey.Name) or "None") .. "]", function()
    -- Hotkey binding logic
end)
createButton(settingsContainer, "Stand Range Hack Hotkey: [" .. (YBAConfig.ToggleKey and tostring(YBAConfig.ToggleKey.Name) or "None") .. "]", function()
    -- Hotkey binding logic
end)