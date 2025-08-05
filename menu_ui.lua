-- Frostware Modern Menu - UI Components Only
-- This file contains only the UI components for the menu interface

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Create main GUI
local FrostwareGui = Instance.new("ScreenGui", CoreGui)
FrostwareGui.Name = "FrostwareGui"
FrostwareGui.ResetOnSpawn = false

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

-- Menu visibility function
local function setMenuVisible(visible)
    mainFrame.Visible = visible
    showBtn.Visible = not visible
end
setMenuVisible(true)

-- Close button (X)
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, -15)
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

-- Insert key support
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

-- Tab definitions
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
        if callback then callback(on) end
    end

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
        if callback then callback(newVal) end
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
    colorBtn.BackgroundColor3 = currentColor or Color3.fromRGB(255, 255, 255)
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
        if callback then callback(newColor) end
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
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
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
    container.Position = UDim2.new(0, 10, 0, 50)
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

-- Example content for each tab (you can customize these)
local function createExampleContent()
    -- ESP Tab
    local espContainer = tabContainers["ESP"]
    createToggle(espContainer, "ESP", false, function(v) print("ESP:", v) end)
    createToggle(espContainer, "Team Check", false, function(v) print("Team Check:", v) end)
    createToggle(espContainer, "Show Outline", true, function(v) print("Show Outline:", v) end)
    createColorPicker(espContainer, "Fill Color", Color3.fromRGB(255, 255, 255), function(c) print("Fill Color:", c) end)
    createSlider(espContainer, "Fill Transparency", 0, 1, 0.5, function(v) print("Fill Transparency:", v) end)

    -- Aimbot Tab
    local aimbotContainer = tabContainers["Aimbot"]
    createToggle(aimbotContainer, "Aimbot", false, function(v) print("Aimbot:", v) end)
    createToggle(aimbotContainer, "Team Check", false, function(v) print("Team Check:", v) end)
    createSlider(aimbotContainer, "FOV Radius", 10, 500, 100, function(v) print("FOV Radius:", v) end)

    -- Fly Tab
    local flyContainer = tabContainers["Fly"]
    createToggle(flyContainer, "Fly", false, function(v) print("Fly:", v) end)
    createSlider(flyContainer, "Fly Speed", 0.1, 10, 1, function(v) print("Fly Speed:", v) end)

    -- NoClip Tab
    local noClipContainer = tabContainers["NoClip"]
    createToggle(noClipContainer, "NoClip", false, function(v) print("NoClip:", v) end)
    createButton(noClipContainer, "Force NoClip Toggle", function() print("Force NoClip Toggle clicked") end)

    -- Speed Tab
    local speedContainer = tabContainers["Speed"]
    createToggle(speedContainer, "SpeedHack", false, function(v) print("SpeedHack:", v) end)
    createSlider(speedContainer, "SpeedHack Speed", 0.1, 10, 1, function(v) print("SpeedHack Speed:", v) end)

    -- Jump Tab
    local jumpContainer = tabContainers["Jump"]
    createToggle(jumpContainer, "Long Jump", false, function(v) print("Long Jump:", v) end)
    createToggle(jumpContainer, "Infinite Jump", false, function(v) print("Infinite Jump:", v) end)
    createSlider(jumpContainer, "Jump Power", 50, 500, 100, function(v) print("Jump Power:", v) end)

    -- YBA Tab
    local ybaContainer = tabContainers["YBA"]
    createToggle(ybaContainer, "Stand Range Hack", false, function(v) print("Stand Range Hack:", v) end)
    createToggle(ybaContainer, "Underground Flight", false, function(v) print("Underground Flight:", v) end)
    createToggle(ybaContainer, "Item ESP", false, function(v) print("Item ESP:", v) end)

    -- Teleport Tab
    local teleportContainer = tabContainers["Teleport"]
    createToggle(teleportContainer, "Teleport", false, function(v) print("Teleport:", v) end)
    createButton(teleportContainer, "Start Teleport", function() print("Start Teleport clicked") end)
    createButton(teleportContainer, "Stop Teleport", function() print("Stop Teleport clicked") end)

    -- Settings Tab
    local settingsContainer = tabContainers["Settings"]
    createButton(settingsContainer, "Update Player List", function() print("Update Player List clicked") end)
    sectionHeader(settingsContainer, "Hotkeys")
    createButton(settingsContainer, "ESP Hotkey: [None]", function() print("ESP Hotkey clicked") end)
    createButton(settingsContainer, "Aimbot Hotkey: [None]", function() print("Aimbot Hotkey clicked") end)
end

-- Create example content
createExampleContent()

-- Return the main GUI and containers for external use
return {
    Gui = FrostwareGui,
    MainFrame = mainFrame,
    TabContainers = tabContainers,
    TabFrames = tabFrames,
    TabButtons = tabButtons,
    setMenuVisible = setMenuVisible
}