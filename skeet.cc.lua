-- ui_library.lua
local Library = {}
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Удаляем старый GUI, если он есть (для удобства перезапуска скрипта)
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "CSGOGui" then gui:Destroy() end
end

-- Настройки стилей (цвета как на скриншоте)
local Styles = {
    Background = Color3.fromRGB(15, 15, 15),
    TabSection = Color3.fromRGB(10, 10, 10),
    ElementBg = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(70, 130, 250), -- Синий акцент
    Text = Color3.fromRGB(200, 200, 200),
    Border = Color3.fromRGB(40, 40, 40)
}

function Library:CreateWindow(title)
    local Window = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CSGOGui"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Styles.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Styles.Border
    MainStroke.Parent = MainFrame
    
    -- Боковая панель для вкладок
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 60, 1, 0)
    Sidebar.BackgroundColor3 = Styles.TabSection
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = Styles.Border
    SidebarStroke.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 10)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = Sidebar
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 20)
    SidebarPadding.Parent = Sidebar

    -- Контейнер для содержимого вкладок
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -70, 1, -20)
    ContentContainer.Position = UDim2.new(0, 65, 0, 10)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Простой скрипт для перетаскивания окна (Drag)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local currentTab = nil

    function Window:CreateTab(iconId)
        local Tab = {}
        
        local TabButton = Instance.new("ImageButton")
        TabButton.Size = UDim2.new(0, 35, 0, 35)
        TabButton.BackgroundTransparency = 1
        TabButton.Image = iconId
        TabButton.ImageColor3 = Color3.fromRGB(100, 100, 100)
        TabButton.Parent = Sidebar
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 2
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent
        
        -- Логика переключения вкладок
        TabButton.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("ImageButton") then child.ImageColor3 = Color3.fromRGB(100, 100, 100) end
            end
            TabContent.Visible = true
            TabButton.ImageColor3 = Styles.Accent
        end)

        -- Если это первая вкладка, открываем её
        if not currentTab then
            currentTab = TabContent
            TabContent.Visible = true
            TabButton.ImageColor3 = Styles.Accent
        end

        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = TabContent
            
            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 14, 0, 14)
            Checkbox.Position = UDim2.new(0, 0, 0.5, -7)
            Checkbox.BackgroundColor3 = state and Styles.Accent or Styles.ElementBg
            Checkbox.Text = ""
            Checkbox.Parent = ToggleFrame
            
            local CheckboxStroke = Instance.new("UIStroke")
            CheckboxStroke.Color = Styles.Border
            CheckboxStroke.Parent = Checkbox
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -25, 1, 0)
            Label.Position = UDim2.new(0, 25, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Styles.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Font = Enum.Font.SourceSansSemibold
            Label.TextSize = 14
            Label.Parent = ToggleFrame
            
            Checkbox.MouseButton1Click:Connect(function()
                state = not state
                Checkbox.BackgroundColor3 = state and Styles.Accent or Styles.ElementBg
                if callback then callback(state) end
            end)
            
            if callback then callback(state) end
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -20, 0, 35)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = TabContent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Styles.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Font = Enum.Font.SourceSansSemibold
            Label.TextSize = 14
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 15)
            ValueLabel.Position = UDim2.new(1, -50, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Styles.Text
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Font = Enum.Font.SourceSansSemibold
            ValueLabel.TextSize = 14
            ValueLabel.Parent = SliderFrame
            
            local SliderBg = Instance.new("Frame")
            SliderBg.Size = UDim2.new(1, 0, 0, 6)
            SliderBg.Position = UDim2.new(0, 0, 0, 22)
            SliderBg.BackgroundColor3 = Styles.ElementBg
            SliderBg.BorderSizePixel = 0
            SliderBg.Parent = SliderFrame
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Styles.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBg
            
            local dragging = false
            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local sliderPos = SliderBg.AbsolutePosition.X
                    local sliderSize = SliderBg.AbsoluteSize.X
                    local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                    local value = math.floor(min + (max - min) * percentage)
                    
                    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    if callback then callback(value) end
                end
            end)
        end
        
        return Tab
    end
    
    return Window
end

return Library
