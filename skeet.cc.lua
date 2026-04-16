local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local Library = {
    AccentObjects = {}, -- Хранит все элементы, которые должны менять цвет
    Theme = {
        Background = Color3.fromRGB(17, 17, 17),
        Groupbox = Color3.fromRGB(23, 23, 23),
        ElementBg = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(200, 50, 250), -- Стартовый цвет (Розовый как на скрине)
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(140, 140, 140),
        OutlineOuter = Color3.fromRGB(0, 0, 0),
        OutlineInner = Color3.fromRGB(45, 45, 45),
    }
}

-- Функция обновления акцентного цвета всего меню
function Library:UpdateAccent(color)
    Library.Theme.Accent = color
    for obj, prop in pairs(Library.AccentObjects) do
        if obj then obj[prop] = color end
    end
end

local function RegisterAccent(obj, property)
    Library.AccentObjects[obj] = property
    obj[property] = Library.Theme.Accent
end

-- Идеальные Skeet-рамки
local function CreateBorders(parent)
    local Outer = Instance.new("Frame")
    Outer.Name = "OuterBorder"
    Outer.Size = UDim2.new(1, 2, 1, 2)
    Outer.Position = UDim2.new(0, -1, 0, -1)
    Outer.BackgroundColor3 = Library.Theme.OutlineOuter
    Outer.BorderSizePixel = 0
    Outer.ZIndex = parent.ZIndex - 2
    Outer.Parent = parent

    local Inner = Instance.new("Frame")
    Inner.Name = "InnerBorder"
    Inner.Size = UDim2.new(1, -2, 1, -2)
    Inner.Position = UDim2.new(0, 1, 0, 1)
    Inner.BackgroundColor3 = Library.Theme.OutlineInner
    Inner.BorderSizePixel = 0
    Inner.ZIndex = parent.ZIndex - 1
    Inner.Parent = Outer

    local Bg = Instance.new("Frame")
    Bg.Name = "MainBg"
    Bg.Size = UDim2.new(1, -2, 1, -2)
    Bg.Position = UDim2.new(0, 1, 0, 1)
    Bg.BackgroundColor3 = parent.BackgroundColor3
    Bg.BorderSizePixel = 0
    Bg.ZIndex = parent.ZIndex
    Bg.Parent = Inner

    parent.BackgroundTransparency = 1
    return Bg
end

function Library:CreateWindow(title)
    if CoreGui:FindFirstChild("SkeetUI") then CoreGui.SkeetUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeetUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 680, 0, 540)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -270)
    MainFrame.BackgroundColor3 = Library.Theme.Background
    MainFrame.Parent = ScreenGui
    CreateBorders(MainFrame)

    local OverlayLayer = Instance.new("Frame")
    OverlayLayer.Size = UDim2.new(1, 0, 1, 0)
    OverlayLayer.BackgroundTransparency = 1
    OverlayLayer.ZIndex = 100
    OverlayLayer.Parent = ScreenGui -- Вынесен в корень для перекрытия всего

    -- Радужная/Градиентная полоска сверху
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 2)
    TopBar.BackgroundColor3 = Color3.new(1,1,1)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    local TopGrad = Instance.new("UIGradient")
    TopGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 174, 214)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(202, 72, 203)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 226, 68))
    })
    TopGrad.Parent = TopBar

    -- Логика перетаскивания (Drag)
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
    Sidebar.Size = UDim2.new(0, 65, 1, -2)
    Sidebar.Position = UDim2.new(0, 0, 0, 2)
    Sidebar.BackgroundColor3 = Library.Theme.Background
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Library.Theme.OutlineInner
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 10)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = Sidebar
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 20)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -66, 1, -2)
    ContentContainer.Position = UDim2.new(0, 66, 0, 2)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local WindowObj = { CurrentTab = nil }

    function WindowObj:CreateTab(iconId)
        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 32, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Image = iconId
        TabBtn.ImageColor3 = Library.Theme.TextDark
        TabBtn.Parent = Sidebar

        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = ContentContainer

        local LeftCol = Instance.new("ScrollingFrame")
        LeftCol.Size = UDim2.new(0.5, -12, 1, -16)
        LeftCol.Position = UDim2.new(0, 8, 0, 8)
        LeftCol.BackgroundTransparency = 1
        LeftCol.ScrollBarThickness = 0
        LeftCol.Parent = TabFrame
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 15)
        LeftLayout.Parent = LeftCol

        local RightCol = Instance.new("ScrollingFrame")
        RightCol.Size = UDim2.new(0.5, -12, 1, -16)
        RightCol.Position = UDim2.new(0.5, 4, 0, 8)
        RightCol.BackgroundTransparency = 1
        RightCol.ScrollBarThickness = 0
        RightCol.Parent = TabFrame
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 15)
        RightLayout.Parent = RightCol

        -- Авто-скроллинг
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() LeftCol.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10) end)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() RightCol.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10) end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentContainer:GetChildren()) do child.Visible = false end
            for _, child in pairs(Sidebar:GetChildren()) do if child:IsA("ImageButton") then child.ImageColor3 = Library.Theme.TextDark end end
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
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(1, 0, 0, 20)
            Box.BackgroundColor3 = Library.Theme.Groupbox
            Box.Parent = (side:lower() == "left") and LeftCol or RightCol
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
            ContentLayout.Padding = UDim.new(0, 6)
            ContentLayout.Parent = Container
            Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 14); Container.UIPadding.PaddingBottom = UDim.new(0, 8); Container.UIPadding.PaddingLeft = UDim.new(0, 10); Container.UIPadding.PaddingRight = UDim.new(0, 10)

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Box.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 22)
            end)

            local GroupboxObj = {}

            function GroupboxObj:CreateToggle(text, default, callback)
                local state = default or false
                local TglFrame = Instance.new("Frame")
                TglFrame.Size = UDim2.new(1, 0, 0, 14)
                TglFrame.BackgroundTransparency = 1
                TglFrame.Parent = Container

                local Checkbox = Instance.new("TextButton")
                Checkbox.Size = UDim2.new(0, 10, 0, 10)
                Checkbox.Position = UDim2.new(0, 0, 0.5, -5)
                Checkbox.BackgroundColor3 = Library.Theme.ElementBg
                Checkbox.Text = ""
                Checkbox.Parent = TglFrame
                local CheckBg = CreateBorders(Checkbox)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(1, 0, 1, 0)
                Fill.BorderSizePixel = 0
                Fill.Visible = state
                Fill.Parent = CheckBg
                RegisterAccent(Fill, "BackgroundColor3")

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
                if state and callback then callback(state) end

                return {
                    AddKeybind = function(self, defaultKey, keyCallback)
                        local KeyBtn = Instance.new("TextButton")
                        KeyBtn.Size = UDim2.new(0, 30, 1, 0)
                        KeyBtn.Position = UDim2.new(1, -30, 0, 0)
                        KeyBtn.BackgroundTransparency = 1
                        KeyBtn.Text = "[" .. (defaultKey or "-") .. "]"
                        KeyBtn.TextColor3 = Library.Theme.TextDark
                        KeyBtn.Font = Enum.Font.SourceSans
                        KeyBtn.TextSize = 12
                        KeyBtn.TextXAlignment = Enum.TextXAlignment.Right
                        KeyBtn.Parent = TglFrame
                        
                        local binding = false
                        KeyBtn.MouseButton1Click:Connect(function()
                            binding = true; KeyBtn.Text = "[...]"; KeyBtn.TextColor3 = Library.Theme.Accent
                        end)
                        
                        UserInputService.InputBegan:Connect(function(input)
                            if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                                local keyStr = input.KeyCode.Name
                                KeyBtn.Text = "[" .. keyStr .. "]"
                                KeyBtn.TextColor3 = Library.Theme.TextDark
                                binding = false
                            elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == KeyBtn.Text:match("%[(.+)%]") then
                                if keyCallback then keyCallback() else
                                    state = not state; Fill.Visible = state; Label.TextColor3 = state and Library.Theme.Text or Library.Theme.TextDark
                                    if callback then callback(state) end
                                end
                            end
                        end)
                    end,
                    AddColorPicker = function(self, defaultColor, colorCallback)
                        local CPBtn = Instance.new("TextButton")
                        CPBtn.Size = UDim2.new(0, 16, 0, 10)
                        CPBtn.Position = UDim2.new(1, -16, 0.5, -5)
                        CPBtn.BackgroundColor3 = defaultColor or Library.Theme.Accent
                        CPBtn.Text = ""
                        CPBtn.Parent = TglFrame
                        CreateBorders(CPBtn)

                        CPBtn.MouseButton1Click:Connect(function()
                            OverlayLayer:ClearAllChildren()
                            
                            -- Попап окно Color Picker
                            local PickerWindow = Instance.new("Frame")
                            PickerWindow.Size = UDim2.new(0, 160, 0, 160)
                            PickerWindow.Position = UDim2.new(0, CPBtn.AbsolutePosition.X + 25, 0, CPBtn.AbsolutePosition.Y)
                            PickerWindow.BackgroundColor3 = Library.Theme.Groupbox
                            PickerWindow.ZIndex = 105
                            PickerWindow.Parent = OverlayLayer
                            CreateBorders(PickerWindow)

                            -- HSV Квадрат (настоящий Skeet-style без картинок!)
                            local SVBox = Instance.new("TextButton")
                            SVBox.Size = UDim2.new(0, 130, 0, 130)
                            SVBox.Position = UDim2.new(0, 10, 0, 10)
                            SVBox.AutoButtonColor = false
                            SVBox.Text = ""
                            SVBox.ZIndex = 106
                            SVBox.Parent = PickerWindow
                            CreateBorders(SVBox)

                            local WhiteGrad = Instance.new("Frame")
                            WhiteGrad.Size = UDim2.new(1,0,1,0); WhiteGrad.BackgroundColor3 = Color3.new(1,1,1); WhiteGrad.BorderSizePixel = 0; WhiteGrad.ZIndex = 107; WhiteGrad.Parent = SVBox
                            local WG = Instance.new("UIGradient"); WG.Transparency = ColorSequence.new({ColorSequenceKeypoint.new(0,0), ColorSequenceKeypoint.new(1,1)}); WG.Parent = WhiteGrad
                            
                            local BlackGrad = Instance.new("Frame")
                            BlackGrad.Size = UDim2.new(1,0,1,0); BlackGrad.BackgroundColor3 = Color3.new(0,0,0); BlackGrad.BorderSizePixel = 0; BlackGrad.ZIndex = 108; BlackGrad.Parent = SVBox
                            local BG = Instance.new("UIGradient"); BG.Rotation = 90; BG.Transparency = ColorSequence.new({ColorSequenceKeypoint.new(0,1), ColorSequenceKeypoint.new(1,0)}); BG.Parent = BlackGrad

                            local CursorSV = Instance.new("Frame")
                            CursorSV.Size = UDim2.new(0,4,0,4); CursorSV.BackgroundColor3 = Color3.new(1,1,1); CursorSV.ZIndex = 109; CursorSV.Parent = BlackGrad

                            -- Полоска Hue (Оттенок)
                            local HueBar = Instance.new("TextButton")
                            HueBar.Size = UDim2.new(0, 10, 0, 130)
                            HueBar.Position = UDim2.new(0, 145, 0, 10)
                            HueBar.AutoButtonColor = false
                            HueBar.Text = ""
                            HueBar.BackgroundColor3 = Color3.new(1,1,1)
                            HueBar.ZIndex = 106
                            HueBar.Parent = PickerWindow
                            CreateBorders(HueBar)

                            local HG = Instance.new("UIGradient")
                            HG.Rotation = 90
                            HG.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
                                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                                ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                            })
                            HG.Parent = HueBar
                            local CursorH = Instance.new("Frame")
                            CursorH.Size = UDim2.new(1,2,0,2); CursorH.Position = UDim2.new(0,-1,0,0); CursorH.BackgroundColor3 = Color3.new(1,1,1); CursorH.ZIndex = 109; CursorH.Parent = HueBar

                            local hue, sat, val = CPBtn.BackgroundColor3:ToHSV()
                            
                            local function UpdateColor()
                                local finalColor = Color3.fromHSV(hue, sat, val)
                                CPBtn.BackgroundColor3 = finalColor
                                SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                                if colorCallback then colorCallback(finalColor) end
                            end

                            local draggingSV, draggingH = false, false
                            SVBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end end)
                            HueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingH = true end end)
                            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false; draggingH = false end end)

                            UserInputService.InputChanged:Connect(function(input)
                                if draggingSV and input.UserInputType == Enum.UserInputType.MouseMovement then
                                    local mX, mY = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y - 36
                                    local pctX = math.clamp((mX - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                                    local pctY = math.clamp((mY - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                                    CursorSV.Position = UDim2.new(pctX, -2, pctY, -2)
                                    sat, val = pctX, 1 - pctY
                                    UpdateColor()
                                elseif draggingH and input.UserInputType == Enum.UserInputType.MouseMovement then
                                    local mY = UserInputService:GetMouseLocation().Y - 36
                                    local pctY = math.clamp((mY - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                                    CursorH.Position = UDim2.new(0, -1, pctY, -1)
                                    hue = 1 - pctY
                                    UpdateColor()
                                end
                            end)

                            -- Закрытие при клике вне
                            local CloseBlock = Instance.new("TextButton")
                            CloseBlock.Size = UDim2.new(20,0,20,0); CloseBlock.Position = UDim2.new(-10,0,-10,0); CloseBlock.BackgroundTransparency = 1; CloseBlock.Text = ""; CloseBlock.ZIndex = 101; CloseBlock.Parent = OverlayLayer
                            CloseBlock.MouseButton1Click:Connect(function() OverlayLayer:ClearAllChildren() end)
                        end)
                    end
                }
            end

            function GroupboxObj:CreateSlider(text, min, max, default, suffix, callback)
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
                ValLabel.Text = tostring(default) .. (suffix or "")
                ValLabel.TextColor3 = Library.Theme.Text
                ValLabel.Font = Enum.Font.SourceSans
                ValLabel.TextSize = 13
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = SFrame

                local Bar = Instance.new("Frame")
                Bar.Size = UDim2.new(1, 0, 0, 8)
                Bar.Position = UDim2.new(0, 0, 0, 18)
                Bar.BackgroundColor3 = Library.Theme.ElementBg
                Bar.Parent = SFrame
                local BarBg = CreateBorders(Bar)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                Fill.BorderSizePixel = 0
                Fill.Parent = BarBg
                RegisterAccent(Fill, "BackgroundColor3")

                local dragging = false
                BarBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouseX = UserInputService:GetMouseLocation().X
                        local pct = math.clamp((mouseX - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                        local val = math.floor(min + ((max - min) * pct))
                        Fill.Size = UDim2.new(pct, 0, 1, 0)
                        ValLabel.Text = tostring(val) .. (suffix or "")
                        if callback then callback(val) end
                    end
                end)
                if callback then callback(default) end
            end

            function GroupboxObj:CreateDropdown(text, list, default, callback)
                local DFrame = Instance.new("Frame")
                DFrame.Size = UDim2.new(1, 0, 0, 42)
                DFrame.BackgroundTransparency = 1
                DFrame.Parent = Container

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 14)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DFrame

                local MainBtnBox = Instance.new("Frame")
                MainBtnBox.Size = UDim2.new(1, 0, 0, 20)
                MainBtnBox.Position = UDim2.new(0, 0, 0, 18)
                MainBtnBox.BackgroundColor3 = Library.Theme.ElementBg
                MainBtnBox.Parent = DFrame
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

                MainBtn.MouseButton1Click:Connect(function()
                    OverlayLayer:ClearAllChildren()
                    local ListWin = Instance.new("Frame")
                    ListWin.Size = UDim2.new(0, MainBtnBox.AbsoluteSize.X, 0, math.min(#list * 20, 160))
                    ListWin.Position = UDim2.new(0, MainBtnBox.AbsolutePosition.X, 0, MainBtnBox.AbsolutePosition.Y + 22)
                    ListWin.BackgroundColor3 = Library.Theme.ElementBg
                    ListWin.ZIndex = 110
                    ListWin.Parent = OverlayLayer
                    local ListBg = CreateBorders(ListWin)

                    local Scroll = Instance.new("ScrollingFrame")
                    Scroll.Size = UDim2.new(1,0,1,0); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.BorderSizePixel = 0; Scroll.ZIndex = 111; Scroll.Parent = ListBg
                    local LL = Instance.new("UIListLayout"); LL.Parent = Scroll
                    LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0,0,0,LL.AbsoluteContentSize.Y) end)

                    for _, item in pairs(list) do
                        local ItemBtn = Instance.new("TextButton")
                        ItemBtn.Size = UDim2.new(1, 0, 0, 20)
                        ItemBtn.BackgroundTransparency = 1
                        ItemBtn.Text = "  " .. item
                        ItemBtn.TextColor3 = (item == MainBtn.Text) and Library.Theme.Accent or Library.Theme.TextDark
                        if item == MainBtn.Text then RegisterAccent(ItemBtn, "TextColor3") end
                        ItemBtn.Font = Enum.Font.SourceSans
                        ItemBtn.TextSize = 13
                        ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                        ItemBtn.ZIndex = 112
                        ItemBtn.Parent = Scroll

                        ItemBtn.MouseButton1Click:Connect(function()
                            MainBtn.Text = item
                            OverlayLayer:ClearAllChildren()
                            if callback then callback(item) end
                        end)
                    end
                    
                    local CloseBlock = Instance.new("TextButton")
                    CloseBlock.Size = UDim2.new(20,0,20,0); CloseBlock.Position = UDim2.new(-10,0,-10,0); CloseBlock.BackgroundTransparency = 1; CloseBlock.Text = ""; CloseBlock.ZIndex = 101; CloseBlock.Parent = OverlayLayer
                    CloseBlock.MouseButton1Click:Connect(function() OverlayLayer:ClearAllChildren() end)
                end)
                if callback then callback(default or list[1]) end
            end

            function GroupboxObj:CreateButton(text, callback)
                local BtnFrame = Instance.new("Frame")
                BtnFrame.Size = UDim2.new(1, 0, 0, 22)
                BtnFrame.BackgroundColor3 = Library.Theme.ElementBg
                BtnFrame.Parent = Container
                local BtnBg = CreateBorders(BtnFrame)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = text
                Btn.TextColor3 = Library.Theme.Text
                Btn.Font = Enum.Font.SourceSansBold
                Btn.TextSize = 13
                Btn.Parent = BtnBg

                Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
            end

            return GroupboxObj
        end
        return TabObj
    end
    return WindowObj
end

return Library
