# Frostware Modern Menu - UI Components

Этот проект содержит только UI компоненты для современного меню, извлеченные из основного скрипта.

## Структура файлов

- `menu_ui.lua` - Основные UI компоненты меню
- `menu_ui_usage.lua` - Примеры использования UI компонентов
- `README.md` - Документация

## Основные компоненты

### Главное окно меню
- **MainFrame** - Основная рамка меню (420x440 пикселей)
- **Sidebar** - Боковая панель с вкладками (110 пикселей ширины)
- **ContentFrame** - Область содержимого вкладок

### Вкладки
Меню содержит следующие вкладки:
1. **ESP** 👁 - Настройки ESP
2. **Aimbot** 🎯 - Настройки аимбота
3. **Fly** 🦅 - Настройки полета
4. **NoClip** 🚪 - Настройки NoClip
5. **Speed** ⚡ - Настройки скорости
6. **Jump** 🦘 - Настройки прыжков
7. **YBA** 👊 - Настройки YBA
8. **Teleport** 📍 - Настройки телепортации
9. **Settings** ⚙️ - Общие настройки

### UI элементы

#### Toggle Switch
```lua
createToggle(parent, label, state, callback)
```
Создает переключатель с анимацией.

#### Slider
```lua
createSlider(parent, label, min, max, value, callback)
```
Создает слайдер с возможностью перетаскивания.

#### Color Picker
```lua
createColorPicker(parent, label, currentColor, callback)
```
Создает выборщик цвета с предустановленными цветами.

#### Button
```lua
createButton(parent, text, callback)
```
Создает кнопку с закругленными углами.

#### Section Header
```lua
sectionHeader(parent, text)
```
Создает заголовок секции.

## Использование

### Базовое использование
```lua
-- Загрузить UI компоненты
local menuUI = require(script.Parent.menu_ui)

-- Получить доступ к компонентам
local gui = menuUI.Gui
local mainFrame = menuUI.MainFrame
local tabContainers = menuUI.TabContainers
local setMenuVisible = menuUI.setMenuVisible
```

### Добавление пользовательского содержимого
```lua
-- Добавить переключатель в вкладку ESP
local espContainer = tabContainers["ESP"]
createToggle(espContainer, "Мой ESP", false, function(enabled)
    print("ESP включен:", enabled)
    -- Ваша логика здесь
end)

-- Добавить слайдер
createSlider(espContainer, "Дальность", 10, 500, 100, function(value)
    print("Дальность:", value)
    -- Ваша логика здесь
end)
```

### Управление видимостью меню
```lua
-- Скрыть меню
setMenuVisible(false)

-- Показать меню
setMenuVisible(true)

-- Переключить видимость
setMenuVisible(not mainFrame.Visible)
```

### Горячие клавиши
```lua
-- Добавить горячие клавиши
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert then
            -- Переключить меню с Insert
            setMenuVisible(not mainFrame.Visible)
        elseif input.KeyCode == Enum.KeyCode.RightControl then
            -- Показать меню с Right Control
            setMenuVisible(true)
        end
    end
end)
```

## Стилизация

### Изменение цветов
```lua
-- Изменить цвет главной рамки
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)

-- Изменить цвет боковой панели
local sidebar = mainFrame:FindFirstChild("Sidebar")
if sidebar then
    sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
end

-- Изменить цвета кнопок вкладок
for _, button in pairs(tabButtons) do
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.TextColor3 = Color3.fromRGB(220, 220, 240)
end
```

### Анимации
```lua
-- Анимация появления меню
local function animateMenuIn()
    mainFrame.Position = UDim2.new(0, -420, 0.5, -220)
    mainFrame:TweenPosition(UDim2.new(0, 60, 0.5, -220), "Out", "Back", 0.5, true)
end

-- Анимация исчезновения меню
local function animateMenuOut()
    mainFrame:TweenPosition(UDim2.new(0, -420, 0.5, -220), "In", "Back", 0.5, true)
end
```

## Интеграция с основным скриптом

### Подключение функций
```lua
-- Подключить функции ESP
local espContainer = tabContainers["ESP"]
createToggle(espContainer, "ESP", false, function(enabled)
    if enabled then
        if _G.startESP then
            _G.startESP()
        else
            print("Функция startESP не найдена")
        end
    else
        if _G.stopESP then
            _G.stopESP()
        else
            print("Функция stopESP не найдена")
        end
    end
end)
```

### Обработка ошибок
```lua
-- Обернуть операции UI в pcall
local success, result = pcall(function()
    local espContainer = tabContainers["ESP"]
    if espContainer then
        createToggle(espContainer, "Безопасный переключатель", false, function(v)
            print("Безопасный переключатель:", v)
        end)
    else
        error("Контейнер ESP не найден")
    end
end)

if not success then
    warn("Ошибка UI:", result)
end
```

## Особенности

- **Современный дизайн** - Темная тема с закругленными углами
- **Адаптивный интерфейс** - Автоматическое изменение размера содержимого
- **Плавные анимации** - Анимации переключения и перетаскивания
- **Горячие клавиши** - Поддержка Insert для переключения меню
- **Модульная архитектура** - Легко расширяемый и настраиваемый

## Требования

- Roblox Studio или Roblox Client
- Lua 5.1+
- UserInputService
- CoreGui

## Лицензия

Этот код предоставляется "как есть" для образовательных целей.