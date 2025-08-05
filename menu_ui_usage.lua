-- Frostware Modern Menu - UI Usage Examples
-- This file shows how to use the menu UI components

-- Load the menu UI
local menuUI = require(script.Parent.menu_ui) -- or wherever your menu_ui.lua is located

-- Access the main components
local gui = menuUI.Gui
local mainFrame = menuUI.MainFrame
local tabContainers = menuUI.TabContainers
local tabFrames = menuUI.TabFrames
local tabButtons = menuUI.TabButtons
local setMenuVisible = menuUI.setMenuVisible

-- Example: Adding custom content to tabs
local function addCustomContent()
    -- ESP Tab
    local espContainer = tabContainers["ESP"]
    
    -- Add custom toggle
    local customToggle = createToggle(espContainer, "Custom ESP Feature", false, function(enabled)
        print("Custom ESP Feature:", enabled)
        -- Your custom logic here
    end)
    
    -- Add custom slider
    local customSlider = createSlider(espContainer, "Custom Range", 0, 1000, 500, function(value)
        print("Custom Range:", value)
        -- Your custom logic here
    end)
    
    -- Add custom color picker
    local customColorPicker = createColorPicker(espContainer, "Custom Color", Color3.fromRGB(255, 0, 0), function(color)
        print("Custom Color:", color)
        -- Your custom logic here
    end)
    
    -- Add custom button
    local customButton = createButton(espContainer, "Custom Action", function()
        print("Custom Action clicked")
        -- Your custom logic here
    end)
    
    -- Add section header
    local customHeader = sectionHeader(espContainer, "Custom Section")
end

-- Example: Modifying existing content
local function modifyExistingContent()
    -- Get the ESP container
    local espContainer = tabContainers["ESP"]
    
    -- Clear existing content (optional)
    for _, child in pairs(espContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add your custom content
    createToggle(espContainer, "My ESP", false, function(v) 
        -- Your ESP logic
        print("My ESP toggled:", v)
    end)
    
    createSlider(espContainer, "My Range", 10, 500, 100, function(v)
        -- Your range logic
        print("My Range changed:", v)
    end)
end

-- Example: Creating a new tab
local function createNewTab()
    -- This would require modifying the original menu_ui.lua file
    -- to add a new tab to the tabs table
end

-- Example: Handling menu visibility
local function handleMenuVisibility()
    -- Hide menu
    setMenuVisible(false)
    
    -- Show menu
    setMenuVisible(true)
    
    -- Toggle menu
    setMenuVisible(not mainFrame.Visible)
end

-- Example: Adding hotkeys
local function addHotkeys()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.RightControl then
                -- Toggle menu with Right Control
                setMenuVisible(not mainFrame.Visible)
            elseif input.KeyCode == Enum.KeyCode.RightShift then
                -- Hide menu with Right Shift
                setMenuVisible(false)
            end
        end
    end)
end

-- Example: Custom styling
local function applyCustomStyling()
    -- Change main frame color
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    
    -- Change sidebar color
    local sidebar = mainFrame:FindFirstChild("Sidebar")
    if sidebar then
        sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
    
    -- Change tab button colors
    for _, button in pairs(tabButtons) do
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        button.TextColor3 = Color3.fromRGB(220, 220, 240)
    end
end

-- Example: Adding animations
local function addAnimations()
    -- Animate menu appearance
    local function animateMenuIn()
        mainFrame.Position = UDim2.new(0, -420, 0.5, -220)
        mainFrame:TweenPosition(UDim2.new(0, 60, 0.5, -220), "Out", "Back", 0.5, true)
    end
    
    local function animateMenuOut()
        mainFrame:TweenPosition(UDim2.new(0, -420, 0.5, -220), "In", "Back", 0.5, true)
    end
    
    -- Use these functions instead of setMenuVisible for animated transitions
end

-- Example: Saving and loading settings
local function saveSettings()
    local settings = {
        esp = {
            enabled = false,
            range = 100,
            color = Color3.fromRGB(255, 255, 255)
        },
        aimbot = {
            enabled = false,
            fov = 100
        }
        -- Add more settings as needed
    }
    
    -- Save to DataStore or other storage
    print("Settings saved:", settings)
end

local function loadSettings()
    -- Load from DataStore or other storage
    local settings = {
        esp = { enabled = false, range = 100, color = Color3.fromRGB(255, 255, 255) },
        aimbot = { enabled = false, fov = 100 }
    }
    
    -- Apply settings to UI
    local espContainer = tabContainers["ESP"]
    -- Update toggles, sliders, etc. based on loaded settings
    print("Settings loaded:", settings)
end

-- Example: Integration with your main script
local function integrateWithMainScript()
    -- Connect your main script functions to the UI
    
    -- ESP functions
    local espContainer = tabContainers["ESP"]
    createToggle(espContainer, "ESP", false, function(enabled)
        if enabled then
            -- Call your ESP start function
            if _G.startESP then
                _G.startESP()
            else
                print("ESP start function not found")
            end
        else
            -- Call your ESP stop function
            if _G.stopESP then
                _G.stopESP()
            else
                print("ESP stop function not found")
            end
        end
    end)
    
    -- Aimbot functions
    local aimbotContainer = tabContainers["Aimbot"]
    createToggle(aimbotContainer, "Aimbot", false, function(enabled)
        if enabled then
            if _G.startAimbot then
                _G.startAimbot()
            else
                print("Aimbot start function not found")
            end
        else
            if _G.stopAimbot then
                _G.stopAimbot()
            else
                print("Aimbot stop function not found")
            end
        end
    end)
    
    -- Add more integrations as needed
end

-- Example: Error handling
local function addErrorHandling()
    -- Wrap UI operations in pcall for error handling
    local success, result = pcall(function()
        -- Your UI operations here
        local espContainer = tabContainers["ESP"]
        if espContainer then
            createToggle(espContainer, "Safe Toggle", false, function(v)
                print("Safe toggle:", v)
            end)
        else
            error("ESP container not found")
        end
    end)
    
    if not success then
        warn("UI Error:", result)
    end
end

-- Example: Performance optimization
local function optimizePerformance()
    -- Use debouncing for frequent updates
    local debounce = {}
    
    local function debouncedCallback(name, callback, delay)
        delay = delay or 0.1
        if debounce[name] then
            debounce[name]:Disconnect()
        end
        
        debounce[name] = game:GetService("RunService").Heartbeat:Wait()
        task.wait(delay)
        callback()
    end
    
    -- Use this for expensive operations
    local espContainer = tabContainers["ESP"]
    createSlider(espContainer, "Performance Heavy Setting", 0, 100, 50, function(value)
        debouncedCallback("performanceSetting", function()
            print("Performance heavy operation with value:", value)
        end, 0.2)
    end)
end

-- Return the usage examples
return {
    addCustomContent = addCustomContent,
    modifyExistingContent = modifyExistingContent,
    handleMenuVisibility = handleMenuVisibility,
    addHotkeys = addHotkeys,
    applyCustomStyling = applyCustomStyling,
    addAnimations = addAnimations,
    saveSettings = saveSettings,
    loadSettings = loadSettings,
    integrateWithMainScript = integrateWithMainScript,
    addErrorHandling = addErrorHandling,
    optimizePerformance = optimizePerformance
}