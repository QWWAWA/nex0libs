local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Утилиты
local function create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function tween(instance, time, goals, easingStyle, easingDirection)
    local t = TweenService:Create(instance, TweenInfo.new(time, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out), goals)
    t:Play()
    return t
end

-- Закрытие всех открытых дропдаунов при клике вне
local openDropdowns = {}
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        for i = #openDropdowns, 1, -1 do
            local dd = openDropdowns[i]
            if dd and dd.listFrame and dd.parent then
                local absPos = dd.listFrame.AbsolutePosition
                local absSize = dd.listFrame.AbsoluteSize
                if not (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                        mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y) then
                    if dd.button ~= nil and not (mousePos.X >= dd.button.AbsolutePosition.X and mousePos.X <= dd.button.AbsolutePosition.X + dd.button.AbsoluteSize.X and
                                                  mousePos.Y >= dd.button.AbsolutePosition.Y and mousePos.Y <= dd.button.AbsolutePosition.Y + dd.button.AbsoluteSize.Y) then
                        dd:Close()
                        table.remove(openDropdowns, i)
                    end
                end
            else
                table.remove(openDropdowns, i)
            end
        end
    end
end)

-- =============================================
-- Основной класс GUI
-- =============================================
local Library = {}
Library.Windows = {}

function Library:CreateWindow(title)
    -- Проверка на существование
    if CoreGui:FindFirstChild("MacOS_LiquidGUI") then
        CoreGui.MacOS_LiquidGUI:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "MacOS_LiquidGUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- Тень
    local shadow = create("Frame", {
        Name = "Shadow",
        Parent = gui,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250 + 4, 0.5, -175 + 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    local shadowCorner = create("UICorner", {
        Parent = shadow,
        CornerRadius = UDim.new(0, 14),
    })

    -- Главное окно
    local mainFrame = create("Frame", {
        Name = "Main",
        Parent = gui,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
    })
    local mainCorner = create("UICorner", {
        Parent = mainFrame,
        CornerRadius = UDim.new(0, 14),
    })

    -- Градиент для эффекта жидкого стекла
    local glassGradient = create("UIGradient", {
        Parent = mainFrame,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(1, 0.95),
        }),
        Rotation = 90,
    })

    -- Обводка
    local stroke = create("UIStroke", {
        Parent = mainFrame,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.85,
        Thickness = 1,
    })

    -- Заголовок (TitleBar)
    local titleBar = create("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
    })

    -- Кнопки-индикаторы MacOS (красная, жёлтая, зелёная)
    local closeButton = create("TextButton", {
        Name = "Close",
        Parent = titleBar,
        BackgroundColor3 = Color3.fromRGB(255, 95, 86),
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 14, 0.5, -6),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    })
    create("UICorner", {Parent = closeButton, CornerRadius = UDim.new(1, 0)})

    local minimizeButton = create("TextButton", {
        Name = "Minimize",
        Parent = titleBar,
        BackgroundColor3 = Color3.fromRGB(255, 189, 46),
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 30, 0.5, -6),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = false, -- опционально
    })
    create("UICorner", {Parent = minimizeButton, CornerRadius = UDim.new(1, 0)})

    local maximizeButton = create("TextButton", {
        Name = "Maximize",
        Parent = titleBar,
        BackgroundColor3 = Color3.fromRGB(39, 201, 63),
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 46, 0.5, -6),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
    })
    create("UICorner", {Parent = maximizeButton, CornerRadius = UDim.new(1, 0)})

    local titleLabel = create("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 70, 0, 0),
        Text = title or "Window",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- Контейнер боковой панели (табы)
    local tabBar = create("Frame", {
        Name = "TabBar",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 120, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
    })
    local tabScrolling = create("ScrollingFrame", {
        Name = "TabScrolling",
        Parent = tabBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180),
        VerticalScrollBarInset = Enum.ScrollBarInset.Always,
    })
    local tabList = create("UIListLayout", {
        Parent = tabScrolling,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })

    -- Контейнер контента
    local contentContainer = create("Frame", {
        Name = "Content",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -120, 1, -40),
        Position = UDim2.new(0, 120, 0, 40),
    })

    -- Перемещение окна за заголовок
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Vector2.new(mouse.X, mouse.Y)
            startPos = mainFrame.Position
            input.UserInputState = Enum.UserInputState.Begin
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(mouse.X, mouse.Y) - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Закрытие
    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Анимация появления
    mainFrame.Size = UDim2.new(0, 500, 0, 0) -- начальное состояние
    tween(mainFrame, 0.5, {Size = UDim2.new(0, 500, 0, 350)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    shadow.Size = UDim2.new(0, 500, 0, 0)
    tween(shadow, 0.5, {Size = UDim2.new(0, 500, 0, 350)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ========= API Окна =========
    local window = {}
    window.Tabs = {}
    window.TabButtons = {}
    window.TabContentFrames = {}

    function window:Tab(tabName)
        -- Кнопка таба
        local tabBtn = create("TextButton", {
            Name = tabName,
            Parent = tabScrolling,
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, -16, 0, 32),
            Position = UDim2.new(0, 8, 0, 0),
            Text = tabName,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 13,
            Font = Enum.Font.Gotham,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        })
        create("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 8)})
        -- градиент для таб-кнопки
        local tabGrad = create("UIGradient", {
            Parent = tabBtn,
            Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
            Transparency = NumberSequence.new(0.9, 0.95),
            Rotation = 90,
        })

        -- Фрейм контента таба
        local contentFrame = create("ScrollingFrame", {
            Name = tabName,
            Parent = contentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(160, 160, 160),
        })
        local contentList = create("UIListLayout", {
            Parent = contentFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })

        local tab = { 
            Button = tabBtn, 
            Frame = contentFrame, 
            List = contentList, 
            Sections = {} 
        }

        -- Переключение табов
        tabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(window.Tabs) do
                t.Frame.Visible = false
                t.Button.BackgroundTransparency = 0.4
            end
            contentFrame.Visible = true
            tabBtn.BackgroundTransparency = 0.2
        end)

        table.insert(window.Tabs, tab)
        -- Если первый таб, активировать сразу
        if #window.Tabs == 1 then
            contentFrame.Visible = true
            tabBtn.BackgroundTransparency = 0.2
        end

        -- Метод добавления секции в таб
        function tab:AddSection(sectionName)
            local sectionFrame = create("Frame", {
                Name = sectionName,
                Parent = contentFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 0),
            })
            local sectionList = create("UIListLayout", {
                Parent = sectionFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            })

            local sectionTitle = create("TextLabel", {
                Name = "SectionTitle",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Text = sectionName,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
            })

            -- Пересчёт размера секции
            local function updateSize()
                local totalHeight = 20
                for _, child in ipairs(sectionFrame:GetChildren()) do
                    if child:IsA("Frame") and child ~= sectionFrame then
                        totalHeight = totalHeight + child.AbsoluteSize.Y + 6
                    end
                end
                sectionFrame.Size = UDim2.new(1, -16, 0, totalHeight)
                contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 16)
            end

            local section = { Frame = sectionFrame, List = sectionList, Title = sectionTitle, UpdateSize = updateSize }

            -- ====== Элементы ======
            function section:AddToggle(text, default, callback)
                local toggleFrame = create("Frame", {
                    Name = "Toggle",
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 36),
                    Position = UDim2.new(0, 5, 0, 0),
                })
                local label = create("TextLabel", {
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = text,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })
                local toggleBackground = create("Frame", {
                    Parent = toggleFrame,
                    BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 80),
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    BorderSizePixel = 0,
                })
                create("UICorner", {Parent = toggleBackground, CornerRadius = UDim.new(1, 0)})
                local toggleKnob = create("Frame", {
                    Parent = toggleBackground,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, default and 22 or 2, 0.5, -8),
                    BorderSizePixel = 0,
                })
                create("UICorner", {Parent = toggleKnob, CornerRadius = UDim.new(1, 0)})

                local state = default or false
                local function updateVisual()
                    toggleBackground.BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 80)
                    tween(toggleKnob, 0.2, {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)})
                end

                toggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        updateVisual()
                        if callback then callback(state) end
                    end
                end)

                local toggle = {}
                function toggle:Get() return state end
                function toggle:Set(value)
                    state = value
                    updateVisual()
                end
                updateSize()
                return toggle
            end

            function section:AddSlider(text, min, max, default, callback, showValue)
                local sliderFrame = create("Frame", {
                    Name = "Slider",
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 50),
                    Position = UDim2.new(0, 5, 0, 0),
                })
                local header = create("Frame", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                })
                local label = create("TextLabel", {
                    Parent = header,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Text = text,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })
                local valueLabel = create("TextLabel", {
                    Parent = header,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.3, 0, 1, 0),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    Text = tostring(default),
                    TextColor3 = Color3.fromRGB(180, 180, 180),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })
                local track = create("Frame", {
                    Parent = sliderFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 30),
                    BorderSizePixel = 0,
                })
                create("UICorner", {Parent = track, CornerRadius = UDim.new(1, 0)})
                local fill = create("Frame", {
                    Parent = track,
                    BackgroundColor3 = Color3.fromRGB(100, 160, 255),
                    Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                    BorderSizePixel = 0,
                })
                create("UICorner", {Parent = fill, CornerRadius = UDim.new(1, 0)})
                local knob = create("Frame", {
                    Parent = fill,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -7, 0.5, -7),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                })
                create("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

                local value = default
                local draggingSlider = false
                local function setValue(newVal)
                    value = math.clamp(newVal, min, max)
                    local fraction = (value - min) / (max - min)
                    fill.Size = UDim2.new(fraction, 0, 1, 0)
                    if showValue ~= false then
                        valueLabel.Text = tostring(math.floor(value * 100 + 0.5) / 100)
                    end
                    if callback then callback(value) end
                end

                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                    end
                end)
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouseX = mouse.X - track.AbsolutePosition.X
                        local fraction = math.clamp(mouseX / track.AbsoluteSize.X, 0, 1)
                        setValue(min + fraction * (max - min))
                        draggingSlider = true
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouseX = mouse.X - track.AbsolutePosition.X
                        local fraction = math.clamp(mouseX / track.AbsoluteSize.X, 0, 1)
                        setValue(min + fraction * (max - min))
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                local slider = {}
                function slider:Get() return value end
                function slider:Set(val) setValue(val) end
                updateSize()
                return slider
            end

            function section:AddDropdown(text, options, defaultIndex, callback)
                local dropdownFrame = create("Frame", {
                    Name = "Dropdown",
                    Parent = sectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 36),
                    Position = UDim2.new(0, 5, 0, 0),
                    ClipsDescendants = false,
                })
                local label = create("TextLabel", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 80, 1, 0),
                    Text = text,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })
                local button = create("TextButton", {
                    Name = "DropdownBtn",
                    Parent = dropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, -90, 0, 30),
                    Position = UDim2.new(0, 85, 0.5, -15),
                    BorderSizePixel = 0,
                    Text = options[defaultIndex or 1] or "Select...",
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false,
                })
                create("UICorner", {Parent = button, CornerRadius = UDim.new(0, 8)})
                local arrow = create("TextLabel", {
                    Parent = button,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    Text = "▼",
                    TextColor3 = Color3.fromRGB(180, 180, 180),
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local listFrame = create("Frame", {
                    Name = "DropdownList",
                    Parent = dropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, -90, 0, 0),
                    Position = UDim2.new(0, 85, 1, 0),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 10,
                })
                create("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 8)})
                local listLayout = create("UIListLayout", {
                    Parent = listFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                local selectedIndex = defaultIndex or 1
                local isOpen = false

                local function buildOptions()
                    for _, child in ipairs(listFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for i, opt in ipairs(options) do
                        local optBtn = create("TextButton", {
                            Parent = listFrame,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0.9,
                            Size = UDim2.new(1, 0, 0, 28),
                            Text = opt,
                            TextColor3 = Color3.fromRGB(230, 230, 230),
                            TextSize = 13,
                            Font = Enum.Font.Gotham,
                            BorderSizePixel = 0,
                            AutoButtonColor = false,
                            ZIndex = 12,
                        })
                        optBtn.MouseButton1Click:Connect(function()
                            selectedIndex = i
                            button.Text = opt
                            if callback then callback(opt, i) end
                            self:Close()
                        end)
                    end
                end
                buildOptions()

                local dropdown = {}
                dropdown.button = button
                dropdown.listFrame = listFrame
                dropdown.parent = dropdownFrame

                function dropdown:Open()
                    isOpen = true
                    listFrame.Visible = true
                    tween(listFrame, 0.25, {Size = UDim2.new(1, -90, 0, #options * 28)})
                    -- Добавить в список открытых
                    if not table.find(openDropdowns, dropdown) then
                        table.insert(openDropdowns, dropdown)
                    end
                end

                function dropdown:Close()
                    isOpen = false
                    tween(listFrame, 0.25, {Size = UDim2.new(1, -90, 0, 0)}):Wait()
                    listFrame.Visible = false
                    -- Убрать из списка
                    local idx = table.find(openDropdowns, dropdown)
                    if idx then table.remove(openDropdowns, idx) end
                end

                button.MouseButton1Click:Connect(function()
                    if isOpen then
                        dropdown:Close()
                    else
                        dropdown:Open()
                    end
                end)

                -- Снаружи клик обрабатывается глобально (в начале скрипта)

                updateSize()
                return dropdown
            end

            function section:AddButton(text, callback)
                local buttonFrame = create("TextButton", {
                    Name = "Button",
                    Parent = sectionFrame,
                    BackgroundColor3 = Color3.fromRGB(70, 130, 255),
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, -10, 0, 36),
                    Position = UDim2.new(0, 5, 0, 0),
                    BorderSizePixel = 0,
                    Text = text,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    AutoButtonColor = false,
                })
                create("UICorner", {Parent = buttonFrame, CornerRadius = UDim.new(0, 8)})
                local btnGrad = create("UIGradient", {
                    Parent = buttonFrame,
                    Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                    Transparency = NumberSequence.new(0.85, 0.95),
                    Rotation = 90,
                })
                buttonFrame.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                updateSize()
                return buttonFrame
            end

            table.insert(tab.Sections, section)
            updateSize()
            return section
        end

        table.insert(window.TabButtons, tab)
        return tab
    end

    table.insert(Library.Windows, window)
    return window
end

return Library
