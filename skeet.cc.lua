local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Library = {
    Theme = {
        Background = Color3.fromRGB(23, 23, 23),
        Groupbox = Color3.fromRGB(17, 17, 17),
        Accent = Color3.fromRGB(140, 170, 250),
        Text = Color3.fromRGB(220, 220, 220),
        TextDark = Color3.fromRGB(130, 130, 130),
        BorderOuter = Color3.fromRGB(0, 0, 0),
        BorderInner = Color3.fromRGB(45, 45, 45),
        TopGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 174, 214)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(202, 72, 203)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 226, 68))
        })
    }
}

-- Вспомогательная функция для Skeet-обводки
local function CreateBorders(parent)
    local BorderOuter = Instance.new("Frame")
    BorderOuter.Name = "BorderOuter"
    BorderOuter.Size = UDim2.new(1, 2, 1, 2)
    BorderOuter.Position = UDim2.new(0, -1, 0, -1)
    BorderOuter.BackgroundColor3 = Library.Theme.BorderOuter
    BorderOuter.BorderSizePixel = 0
    BorderOuter.ZIndex = parent.ZIndex - 2
    BorderOuter.Parent = parent

    local BorderInner = Instance.new("Frame")
    BorderInner.Name = "BorderInner"
    BorderInner.Size = UDim2.new(1, 0, 1, 0)
    BorderInner.Position = UDim2.new(0, 0, 0, 0)
    BorderInner.BackgroundColor3 = Library.Theme.BorderInner
    BorderInner.BorderSizePixel = 0
    BorderInner.ZIndex = parent.ZIndex - 1
    BorderInner.Parent = BorderOuter

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(1, -2, 1, -2)
    Bg.Position = UDim2.new(0, 1, 0, 1)
    Bg.BackgroundColor3 = parent.BackgroundColor3
    Bg.BorderSizePixel = 0
    Bg.ZIndex = parent.ZIndex
    Bg.Parent = BorderInner

    parent.BackgroundTransparency = 1
    return Bg
end

function Library:CreateWindow(title)
    if CoreGui:FindFirstChild("SkeetV2") then CoreGui.SkeetV2:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeetV2"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 660, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -330, 0.5, -260)
    MainFrame.BackgroundColor3 = Library.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    CreateBorders(MainFrame)

    -- Контейнер для всплывающих окон (Дропдауны, Колор пикеры)
    local OverlayLayer = Instance.new("Frame")
    OverlayLayer.Size = UDim2.new(1, 0, 1, 0)
    OverlayLayer.BackgroundTransparency = 1
    OverlayLayer.ZIndex = 100
    OverlayLayer.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 2)
    TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = Library.Theme.TopGradient
    UIGradient.Parent = TopBar

    -- Drag Logic
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 70, 1, -2)
    Sidebar.Position = UDim2.new(0, 0, 0, 2)
    Sidebar.BackgroundColor3 = Library.Theme.Background
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Library.Theme.BorderInner
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 8)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = Sidebar
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 20)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -71, 1, -2)
    ContentContainer.Position = UDim2.new(0, 71, 0, 2)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local WindowObj = { CurrentTab = nil }

    function WindowObj:CreateTab(iconId)
        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 36, 0, 36)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Image = iconId
        TabBtn.ImageColor3 = Library.Theme.TextDark
        TabBtn.Parent = Sidebar

        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = ContentContainer

        local LeftCol = Instance.new("Frame")
        LeftCol.Size = UDim2.new(0.5, -12, 1, -20)
        LeftCol.Position = UDim2.new(0, 8, 0, 10)
        LeftCol.BackgroundTransparency = 1
        LeftCol.Parent = TabFrame
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 15)
        LeftLayout.Parent = LeftCol

        local RightCol = Instance.new("Frame")
        RightCol.Size = UDim2.new(0.5, -12, 1, -20)
        RightCol.Position = UDim2.new(0.5, 4, 0, 10)
        RightCol.BackgroundTransparency = 1
        RightCol.Parent = TabFrame
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 15)
        RightLayout.Parent = RightCol

        TabBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentContainer:GetChildren()) do child.Visible = false end
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("ImageButton") then child.ImageColor3 = Library.Theme.TextDark end
            end
            TabFrame.Visible = true
            TabBtn.ImageColor3 = Library.Theme.Text
        end)

        if not WindowObj.CurrentTab then
            WindowObj.CurrentTab = TabFrame
            TabFrame.Visible = true
            TabBtn.ImageColor3 = Library.Theme.Text
        end

        local TabObj = {}
        function TabObj:CreateGroupbox(title, side)
            local col = (side:lower() == "left") and LeftCol or RightCol
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(1, 0, 0, 20)
            Box.BackgroundColor3 = Library.Theme.Groupbox
            Box.Parent = col
            local InnerBg = CreateBorders(Box)

            local Title = Instance.new("TextLabel")
            Title.Position = UDim2.new(0, 12, 0, -7)
            Title.Size = UDim2.new(0, 10, 0, 14)
            Title.AutomaticSize = Enum.AutomaticSize.X
            Title.BackgroundColor3 = Library.Theme.Background
            Title.BorderSizePixel = 0
            Title.Text = " " .. title .. " "
            Title.TextColor3 = Library.Theme.Text
            Title.Font = Enum.Font.SourceSansBold
            Title.TextSize = 13
            Title.Parent = Box

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 1, 0)
            Container.BackgroundTransparency = 1
            Container.Parent = InnerBg

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 8)
            ContentLayout.Parent = Container
            
            local Padding = Instance.new("UIPadding")
            Padding.PaddingTop = UDim.new(0, 14)
            Padding.PaddingLeft = UDim.new(0, 10)
            Padding.PaddingRight = UDim.new(0, 10)
            Padding.PaddingBottom = UDim.new(0, 10)
            Padding.Parent = Container

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Box.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 24)
            end)

            local GroupboxObj = {}

            -- 1. TOGGLE (Чекбокс)
            function GroupboxObj:CreateToggle(text, default, callback)
                local state = default or false
                local TglFrame = Instance.new("Frame")
                TglFrame.Size = UDim2.new(1, 0, 0, 14)
                TglFrame.BackgroundTransparency = 1
                TglFrame.Parent = Container

                local Checkbox = Instance.new("TextButton")
                Checkbox.Size = UDim2.new(0, 10, 0, 10)
                Checkbox.Position = UDim2.new(0, 0, 0.5, -5)
                Checkbox.BackgroundColor3 = Library.Theme.Groupbox
                Checkbox.Text = ""
                Checkbox.Parent = TglFrame
                local CheckBg = CreateBorders(Checkbox)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(1, 0, 1, 0)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Visible = state
                Fill.Parent = CheckBg

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.Position = UDim2.new(0, 20, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = state and Library.Theme.Text or Library.Theme.TextDark
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = TglFrame

                Checkbox.MouseButton1Click:Connect(function()
                    state = not state
                    Fill.Visible = state
                    Label.TextColor3 = state and Library.Theme.Text or Library.Theme.TextDark
                    if callback then callback(state) end
                end)

                return {
                    -- Добавление бинда к тоглу
                    AddKeybind = function(self, defaultKey, keyCallback)
                        local KeyLabel = Instance.new("TextButton")
                        KeyLabel.Size = UDim2.new(0, 30, 1, 0)
                        KeyLabel.Position = UDim2.new(1, -30, 0, 0)
                        KeyLabel.BackgroundTransparency = 1
                        KeyLabel.Text = "[" .. (defaultKey or "-") .. "]"
                        KeyLabel.TextColor3 = Library.Theme.TextDark
                        KeyLabel.Font = Enum.Font.SourceSans
                        KeyLabel.TextSize = 12
                        KeyLabel.TextXAlignment = Enum.TextXAlignment.Right
                        KeyLabel.Parent = TglFrame
                        
                        local binding = false
                        KeyLabel.MouseButton1Click:Connect(function()
                            binding = true
                            KeyLabel.Text = "[...]"
                            KeyLabel.TextColor3 = Library.Theme.Accent
                        end)
                        
                        UserInputService.InputBegan:Connect(function(input)
                            if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                                local keyName = input.KeyCode.Name
                                KeyLabel.Text = "[" .. keyName .. "]"
                                KeyLabel.TextColor3 = Library.Theme.TextDark
                                binding = false
                            elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == KeyLabel.Text:match("%[(.+)%]") then
                                if keyCallback then keyCallback() else
                                    -- Если нет коллбека, переключаем тогл
                                    state = not state
                                    Fill.Visible = state
                                    Label.TextColor3 = state and Library.Theme.Text or Library.Theme.TextDark
                                    if callback then callback(state) end
                                end
                            end
                        end)
                    end,
                    -- Добавление колор пикера к тоглу
                    AddColorPicker = function(self, defaultColor, colorCallback)
                        local cpFrame = Instance.new("TextButton")
                        cpFrame.Size = UDim2.new(0, 16, 0, 10)
                        cpFrame.Position = UDim2.new(1, -16, 0.5, -5)
                        cpFrame.BackgroundColor3 = defaultColor or Color3.new(1, 0, 0)
                        cpFrame.Text = ""
                        cpFrame.Parent = TglFrame
                        CreateBorders(cpFrame)

                        -- Создание Color Wheel окна (Попап)
                        cpFrame.MouseButton1Click:Connect(function()
                            -- Очищаем старые попапы
                            for _, v in pairs(OverlayLayer:GetChildren()) do v:Destroy() end

                            local PickerWindow = Instance.new("Frame")
                            PickerWindow.Size = UDim2.new(0, 150, 0, 180)
                            PickerWindow.Position = UDim2.new(0, cpFrame.AbsolutePosition.X - MainFrame.AbsolutePosition.X + 25, 0, cpFrame.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y)
                            PickerWindow.BackgroundColor3 = Library.Theme.Groupbox
                            PickerWindow.ZIndex = 105
                            PickerWindow.Parent = OverlayLayer
                            CreateBorders(PickerWindow)

                            local Wheel = Instance.new("ImageButton")
                            Wheel.Size = UDim2.new(0, 130, 0, 130)
                            Wheel.Position = UDim2.new(0, 10, 0, 10)
                            Wheel.Image = "rbxassetid://6020299385" -- Круглое колесо цветов
                            Wheel.BackgroundTransparency = 1
                            Wheel.ZIndex = 106
                            Wheel.Parent = PickerWindow

                            local Cursor = Instance.new("Frame")
                            Cursor.Size = UDim2.new(0, 4, 0, 4)
                            Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                            Cursor.ZIndex = 107
                            Cursor.Parent = Wheel

                            local BrightnessSlider = Instance.new("Frame")
                            BrightnessSlider.Size = UDim2.new(1, -20, 0, 10)
                            BrightnessSlider.Position = UDim2.new(0, 10, 0, 150)
                            BrightnessSlider.BackgroundColor3 = Color3.new(1, 1, 1)
                            BrightnessSlider.ZIndex = 106
                            BrightnessSlider.Parent = PickerWindow
                            CreateBorders(BrightnessSlider)
                            
                            local UIGradient = Instance.new("UIGradient")
                            UIGradient.Color = ColorSequence.new(Color3.new(0,0,0), cpFrame.BackgroundColor3)
                            UIGradient.Parent = BrightnessSlider

                            local value = 1
                            local hue, sat = 0, 1

                            local function UpdateColor()
                                local newColor = Color3.fromHSV(hue, sat, value)
                                cpFrame.BackgroundColor3 = newColor
                                UIGradient.Color = ColorSequence.new(Color3.new(0,0,0), Color3.fromHSV(hue, sat, 1))
                                if colorCallback then colorCallback(newColor) end
                            end

                            local wheelDragging = false
                            Wheel.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then wheelDragging = true end end)
                            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then wheelDragging = false end end)
                            
                            UserInputService.InputChanged:Connect(function(input)
                                if wheelDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                    local center = Wheel.AbsolutePosition + Wheel.AbsoluteSize / 2
                                    local mouse = UserInputService:GetMouseLocation() - Vector2.new(0, 36) -- GuiInset offset correction
                                    local delta = mouse - center
                                    local dist = math.min(delta.Magnitude, Wheel.AbsoluteSize.X / 2)
                                    local angle = math.atan2(delta.Y, delta.X)
                                    
                                    Cursor.Position = UDim2.new(0.5, math.cos(angle) * dist - 2, 0.5, math.sin(angle) * dist - 2)
                                    hue = (angle + math.pi) / (math.pi * 2)
                                    sat = dist / (Wheel.AbsoluteSize.X / 2)
                                    UpdateColor()
                                end
                            end)

                            -- Закрытие при клике вне окна
                            local closeBtn = Instance.new("TextButton")
                            closeBtn.Size = UDim2.new(20,0,20,0)
                            closeBtn.Position = UDim2.new(-10,0,-10,0)
                            closeBtn.BackgroundTransparency = 1
                            closeBtn.ZIndex = 101
                            closeBtn.Text = ""
                            closeBtn.Parent = OverlayLayer
                            closeBtn.MouseButton1Click:Connect(function() OverlayLayer:ClearAllChildren() end)
                        end)
                    end
                }
            end

            -- 2. SLIDER (Ползунок)
            function GroupboxObj:CreateSlider(text, min, max, default, callback)
                local SFrame = Instance.new("Frame")
                SFrame.Size = UDim2.new(1, 0, 0, 32)
                SFrame.BackgroundTransparency = 1
                SFrame.Parent = Container

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 14)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(1, 0, 0, 14)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(default)
                ValLabel.TextColor3 = Library.Theme.Text
                ValLabel.Font = Enum.Font.SourceSans
                ValLabel.TextSize = 13
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = SFrame

                local Bar = Instance.new("Frame")
                Bar.Size = UDim2.new(1, 0, 0, 8)
                Bar.Position = UDim2.new(0, 0, 0, 18)
                Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                Bar.Parent = SFrame
                local BarBg = CreateBorders(Bar)

                local Fill = Instance.new("Frame")
                local pct = (default - min) / (max - min)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = BarBg

                local dragging = false
                BarBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouseX = UserInputService:GetMouseLocation().X
                        local barX = BarBg.AbsolutePosition.X
                        local barSize = BarBg.AbsoluteSize.X
                        local percentage = math.clamp((mouseX - barX) / barSize, 0, 1)
                        local value = math.floor(min + ((max - min) * percentage))
                        
                        Fill.Size = UDim2.new(percentage, 0, 1, 0)
                        ValLabel.Text = tostring(value)
                        if callback then callback(value) end
                    end
                end)
            end

            -- 3. BUTTON (Кнопка, баг исправлен)
            function GroupboxObj:CreateButton(text, callback)
                local BtnFrame = Instance.new("Frame")
                BtnFrame.Size = UDim2.new(1, 0, 0, 22)
                BtnFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
                BtnFrame.Parent = Container
                local BtnBg = CreateBorders(BtnFrame)

                -- Кнопка теперь ВНУТРИ рамки с фоном, чтобы текст не перекрывался
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = text
                Btn.TextColor3 = Library.Theme.Text
                Btn.Font = Enum.Font.SourceSansBold
                Btn.TextSize = 13
                Btn.Parent = BtnBg

                Btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            -- 4. DROPDOWN (Выпадающий список)
            function GroupboxObj:CreateDropdown(text, list, default, callback)
                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 40)
                DropFrame.BackgroundTransparency = 1
                DropFrame.Parent = Container

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 14)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropFrame

                local MainBtnBox = Instance.new("Frame")
                MainBtnBox.Size = UDim2.new(1, 0, 0, 20)
                MainBtnBox.Position = UDim2.new(0, 0, 0, 18)
                MainBtnBox.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
                MainBtnBox.Parent = DropFrame
                local MainBtnBg = CreateBorders(MainBtnBox)

                local MainBtn = Instance.new("TextButton")
                MainBtn.Size = UDim2.new(1, -10, 1, 0)
                MainBtn.Position = UDim2.new(0, 5, 0, 0)
                MainBtn.BackgroundTransparency = 1
                MainBtn.Text = default or list[1]
                MainBtn.TextColor3 = Library.Theme.TextDark
                MainBtn.Font = Enum.Font.SourceSans
                MainBtn.TextSize = 13
                MainBtn.TextXAlignment = Enum.TextXAlignment.Left
                MainBtn.Parent = MainBtnBg

                local Icon = Instance.new("TextLabel")
                Icon.Size = UDim2.new(0, 20, 1, 0)
                Icon.Position = UDim2.new(1, -20, 0, 0)
                Icon.BackgroundTransparency = 1
                Icon.Text = "-"
                Icon.TextColor3 = Library.Theme.TextDark
                Icon.Parent = MainBtnBg

                MainBtn.MouseButton1Click:Connect(function()
                    for _, v in pairs(OverlayLayer:GetChildren()) do v:Destroy() end

                    local ListWindow = Instance.new("Frame")
                    ListWindow.Size = UDim2.new(0, MainBtnBox.AbsoluteSize.X, 0, #list * 20)
                    ListWindow.Position = UDim2.new(0, MainBtnBox.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, MainBtnBox.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y + 22)
                    ListWindow.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
                    ListWindow.ZIndex = 110
                    ListWindow.Parent = OverlayLayer
                    local ListBg = CreateBorders(ListWindow)

                    local ListLayout = Instance.new("UIListLayout")
                    ListLayout.Parent = ListBg

                    for _, item in pairs(list) do
                        local ItemBtn = Instance.new("TextButton")
                        ItemBtn.Size = UDim2.new(1, 0, 0, 20)
                        ItemBtn.BackgroundTransparency = 1
                        ItemBtn.Text = "  " .. item
                        ItemBtn.TextColor3 = (item == MainBtn.Text) and Library.Theme.Accent or Library.Theme.TextDark
                        ItemBtn.Font = Enum.Font.SourceSans
                        ItemBtn.TextSize = 13
                        ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                        ItemBtn.ZIndex = 111
                        ItemBtn.Parent = ListBg

                        ItemBtn.MouseButton1Click:Connect(function()
                            MainBtn.Text = item
                            OverlayLayer:ClearAllChildren()
                            if callback then callback(item) end
                        end)
                    end
                    
                    local closeBtn = Instance.new("TextButton")
                    closeBtn.Size = UDim2.new(20,0,20,0)
                    closeBtn.Position = UDim2.new(-10,0,-10,0)
                    closeBtn.BackgroundTransparency = 1
                    closeBtn.ZIndex = 101
                    closeBtn.Text = ""
                    closeBtn.Parent = OverlayLayer
                    closeBtn.MouseButton1Click:Connect(function() OverlayLayer:ClearAllChildren() end)
                end)
            end

            return GroupboxObj
        end
        return TabObj
    end
    return WindowObj
end

return Library
