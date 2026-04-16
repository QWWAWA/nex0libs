local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Пытаемся безопасно получить функции экзекутора для кастомных иконок
local getasset = getcustomasset or getsynasset
local request_func = request or http_request or (syn and syn.request)

local Library = {
    Theme = {
        Background = Color3.fromRGB(17, 17, 17), -- Основной темный фон
        GroupboxBg = Color3.fromRGB(24, 24, 24), -- Фон внутри рамок
        Accent = Color3.fromRGB(100, 140, 250), -- Синий акцент (как на скрине)
        Text = Color3.fromRGB(210, 210, 210),
        TextDark = Color3.fromRGB(130, 130, 130),
        BorderOuter = Color3.fromRGB(0, 0, 0), -- Черная внешняя обводка
        BorderInner = Color3.fromRGB(45, 45, 45), -- Серая внутренняя обводка
        TopGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 150, 250)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 50, 250)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 200, 50))
        })
    }
}

-- Функция для скачивания иконок по URL
function Library:LoadWebIcon(url, filename)
    if not getasset or not request_func then return "" end
    local path = "SkeetUI_Icons"
    if not isfolder(path) then makefolder(path) end
    local filepath = path .. "/" .. filename .. ".png"
    
    if not isfile(filepath) then
        local res = request_func({Url = url, Method = "GET"})
        if res.Success then
            writefile(filepath, res.Body)
        else
            return ""
        end
    end
    return getasset(filepath)
end

-- Функция создания двойной обводки (Skeet style)
local function CreateBorders(parent)
    local Outer = Instance.new("UIStroke")
    Outer.Color = Library.Theme.BorderOuter
    Outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Outer.LineJoinMode = Enum.LineJoinMode.Miter
    Outer.Parent = parent

    local Inner = Instance.new("Frame")
    Inner.Name = "InnerBorder"
    Inner.Size = UDim2.new(1, -2, 1, -2)
    Inner.Position = UDim2.new(0, 1, 0, 1)
    Inner.BackgroundColor3 = parent.BackgroundColor3
    Inner.BorderSizePixel = 1
    Inner.BorderColor3 = Library.Theme.BorderInner
    Inner.ZIndex = parent.ZIndex
    Inner.Parent = parent
    return Inner
end

function Library:CreateWindow(title)
    local Window = {}
    
    -- Очистка старого GUI
    if CoreGui:FindFirstChild("SkeetUI") then CoreGui.SkeetUI:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeetUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 650, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
    MainFrame.BackgroundColor3 = Library.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    CreateBorders(MainFrame)
    
    -- Skeet градиентная полоска сверху
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 2)
    TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 5
    TopBar.Parent = MainFrame
    
    local TopGradient = Instance.new("UIGradient")
    TopGradient.Color = Library.Theme.TopGradient
    TopGradient.Parent = TopBar

    -- Левое меню иконок
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 60, 1, -2)
    Sidebar.Position = UDim2.new(0, 0, 0, 2)
    Sidebar.BackgroundColor3 = Library.Theme.Background
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2
    Sidebar.Parent = MainFrame
    
    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Library.Theme.BorderInner
    SidebarLine.BorderSizePixel = 0
    SidebarLine.ZIndex = 3
    SidebarLine.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = Sidebar
    
    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.PaddingTop = UDim.new(0, 15)
    SidebarPad.Parent = Sidebar

    -- Контейнер для контента
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -61, 1, -2)
    ContentContainer.Position = UDim2.new(0, 61, 0, 2)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 2
    ContentContainer.Parent = MainFrame

    -- Dragging logic
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local currentTab = nil

    function Window:CreateTab(iconId)
        local Tab = {}
        
        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 32, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Image = iconId
        TabBtn.ImageColor3 = Library.Theme.TextDark
        TabBtn.ZIndex = 4
        TabBtn.Parent = Sidebar
        
        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ZIndex = 2
        TabFrame.Parent = ContentContainer
        
        -- Колонки (Skeet style)
        local LeftCol = Instance.new("Frame")
        LeftCol.Size = UDim2.new(0.5, -15, 1, -20)
        LeftCol.Position = UDim2.new(0, 10, 0, 10)
        LeftCol.BackgroundTransparency = 1
        LeftCol.ZIndex = 2
        LeftCol.Parent = TabFrame
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 15)
        LeftLayout.Parent = LeftCol
        
        local RightCol = Instance.new("Frame")
        RightCol.Size = UDim2.new(0.5, -15, 1, -20)
        RightCol.Position = UDim2.new(0.5, 5, 0, 10)
        RightCol.BackgroundTransparency = 1
        RightCol.ZIndex = 2
        RightCol.Parent = TabFrame
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 15)
        RightLayout.Parent = RightCol

        TabBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentContainer:GetChildren()) do
                if child:IsA("Frame") then child.Visible = false end
            end
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("ImageButton") then child.ImageColor3 = Library.Theme.TextDark end
            end
            TabFrame.Visible = true
            TabBtn.ImageColor3 = Library.Theme.Text
        end)

        if not currentTab then
            currentTab = TabFrame
            TabFrame.Visible = true
            TabBtn.ImageColor3 = Library.Theme.Text
        end

        function Tab:CreateGroupbox(title, side)
            local Groupbox = {}
            local col = (side:lower() == "left") and LeftCol or RightCol
            
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1, 0, 0, 20) -- Высота авто-обновляется
            BoxFrame.BackgroundColor3 = Library.Theme.GroupboxBg
            BoxFrame.BorderSizePixel = 0
            BoxFrame.ZIndex = 3
            BoxFrame.Parent = col
            
            local Inner = CreateBorders(BoxFrame)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0, 100, 0, 14)
            TitleLabel.Position = UDim2.new(0, 12, 0, -7) -- Сдвиг на границу
            TitleLabel.BackgroundColor3 = Library.Theme.Background -- Чтобы "перекрыть" линию
            TitleLabel.BorderSizePixel = 0
            TitleLabel.Text = " " .. title .. " "
            TitleLabel.TextColor3 = Library.Theme.Text
            TitleLabel.Font = Enum.Font.SourceSansBold
            TitleLabel.TextSize = 13
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.ZIndex = 5
            TitleLabel.Parent = BoxFrame

            -- Авто-изменение размера Groupbox
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 6)
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Parent = Inner
            
            local BoxPad = Instance.new("UIPadding")
            BoxPad.PaddingTop = UDim.new(0, 12)
            BoxPad.PaddingLeft = UDim.new(0, 10)
            BoxPad.PaddingRight = UDim.new(0, 10)
            BoxPad.PaddingBottom = UDim.new(0, 10)
            BoxPad.Parent = Inner
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                BoxFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 22)
            end)

            function Groupbox:CreateToggle(text, keybind, default, callback)
                local state = default or false
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 14)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.ZIndex = 4
                ToggleFrame.Parent = Inner
                
                local Checkbox = Instance.new("TextButton")
                Checkbox.Size = UDim2.new(0, 10, 0, 10)
                Checkbox.Position = UDim2.new(0, 0, 0.5, -5)
                Checkbox.BackgroundColor3 = Library.Theme.GroupboxBg
                Checkbox.Text = ""
                Checkbox.ZIndex = 5
                Checkbox.Parent = ToggleFrame
                
                local CheckOuter = Instance.new("UIStroke")
                CheckOuter.Color = Library.Theme.BorderOuter
                CheckOuter.Parent = Checkbox
                
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(1, -2, 1, -2)
                Fill.Position = UDim2.new(0, 1, 0, 1)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Visible = state
                Fill.ZIndex = 6
                Fill.Parent = Checkbox
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.Position = UDim2.new(0, 20, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Library.Theme.TextDark
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 5
                Label.Parent = ToggleFrame

                if keybind then
                    local KeyLabel = Instance.new("TextLabel")
                    KeyLabel.Size = UDim2.new(0, 20, 1, 0)
                    KeyLabel.Position = UDim2.new(1, -20, 0, 0)
                    KeyLabel.BackgroundTransparency = 1
                    KeyLabel.Text = "[" .. keybind .. "]"
                    KeyLabel.TextColor3 = Library.Theme.TextDark
                    KeyLabel.Font = Enum.Font.SourceSans
                    KeyLabel.TextSize = 12
                    KeyLabel.TextXAlignment = Enum.TextXAlignment.Right
                    KeyLabel.ZIndex = 5
                    KeyLabel.Parent = ToggleFrame
                end

                Checkbox.MouseButton1Click:Connect(function()
                    state = not state
                    Fill.Visible = state
                    Label.TextColor3 = state and Library.Theme.Text or Library.Theme.TextDark
                    if callback then callback(state) end
                end)
                if state then Label.TextColor3 = Library.Theme.Text end
            end

            function Groupbox:CreateSlider(text, min, max, default, callback)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 30)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.ZIndex = 4
                SliderFrame.Parent = Inner
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 14)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 5
                Label.Parent = SliderFrame
                
                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(1, 0, 0, 14)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(default)
                ValLabel.TextColor3 = Library.Theme.Text
                ValLabel.Font = Enum.Font.SourceSans
                ValLabel.TextSize = 13
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.ZIndex = 5
                ValLabel.Parent = SliderFrame
                
                local BarBg = Instance.new("Frame")
                BarBg.Size = UDim2.new(1, 0, 0, 8)
                BarBg.Position = UDim2.new(0, 0, 0, 18)
                BarBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                BarBg.BorderSizePixel = 0
                BarBg.ZIndex = 5
                BarBg.Parent = SliderFrame
                
                local BarOuter = Instance.new("UIStroke")
                BarOuter.Color = Library.Theme.BorderOuter
                BarOuter.Parent = BarBg
                
                local Fill = Instance.new("Frame")
                local pct = (default - min) / (max - min)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.ZIndex = 6
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

            function Groupbox:CreateButton(text, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 22)
                Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Btn.BorderSizePixel = 0
                Btn.Text = text
                Btn.TextColor3 = Library.Theme.Text
                Btn.Font = Enum.Font.SourceSansBold
                Btn.TextSize = 13
                Btn.ZIndex = 5
                Btn.Parent = Inner
                
                CreateBorders(Btn)
                
                Btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            return Groupbox
        end
        return Tab
    end
    return Window
end

return Library
