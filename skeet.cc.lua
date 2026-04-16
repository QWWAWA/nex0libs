-- skeet.cc / gamesense стиль для Roblox
-- Автор: адаптировано под запрос

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {
    Theme = {
        WindowBg      = Color3.fromRGB(12, 12, 12),
        GroupboxBg    = Color3.fromRGB(12, 12, 12),
        ElementBg     = Color3.fromRGB(35, 35, 40),
        ElementHover  = Color3.fromRGB(45, 45, 50),
        Accent        = Color3.fromRGB(59, 115, 205),
        Text          = Color3.fromRGB(200, 200, 200),
        TextDark      = Color3.fromRGB(100, 100, 100),
        OutlineOuter  = Color3.fromRGB(0, 0, 0),
        OutlineInner  = Color3.fromRGB(45, 45, 45),
        DropdownBg    = Color3.fromRGB(20, 20, 20),
        ScrollBar     = Color3.fromRGB(59, 115, 205)
    }
}

-- Утилита создания тройных границ (как в ImGui)
local function CreateImGuiFrame(ParentObj, OverrideInner)
    local BorderOuter = Instance.new("Frame")
    BorderOuter.Name = "OuterLayer"
    BorderOuter.Size = UDim2.new(1, 2, 1, 2)
    BorderOuter.Position = UDim2.new(0, -1, 0, -1)
    BorderOuter.BackgroundColor3 = Library.Theme.OutlineOuter
    BorderOuter.BorderSizePixel = 0
    BorderOuter.ZIndex = ParentObj.ZIndex - 2
    BorderOuter.Parent = ParentObj

    local BorderInner = Instance.new("Frame")
    BorderInner.Name = "InnerHighlightLayer"
    BorderInner.Size = UDim2.new(1, -2, 1, -2)
    BorderInner.Position = UDim2.new(0, 1, 0, 1)
    BorderInner.BackgroundColor3 = OverrideInner or Library.Theme.OutlineInner
    BorderInner.BorderSizePixel = 0
    BorderInner.ZIndex = ParentObj.ZIndex - 1
    BorderInner.Parent = BorderOuter

    local Content = Instance.new("Frame")
    Content.Name = "MainContentBox"
    Content.Size = UDim2.new(1, -2, 1, -2)
    Content.Position = UDim2.new(0, 1, 0, 1)
    Content.BackgroundColor3 = ParentObj.BackgroundColor3
    Content.BorderSizePixel = 0
    Content.ZIndex = ParentObj.ZIndex
    Content.Parent = BorderInner

    ParentObj.BackgroundTransparency = 1
    return Content, BorderOuter
end

function Library:CreateWindow(config)
    config = config or {}
    local WindowTitle = config.Title or "gamesense"
    
    if CoreGui:FindFirstChild("GamesenseUI") then
        CoreGui.GamesenseUI:Destroy()
    end

    local UI = Instance.new("ScreenGui")
    UI.Name = "GamesenseUI"
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.ResetOnSpawn = false
    UI.IgnoreGuiInset = true
    UI.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 680, 0, 520)
    Main.Position = UDim2.new(0.5, -340, 0.5, -260)
    Main.BackgroundColor3 = Library.Theme.WindowBg
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ZIndex = 10
    Main.Parent = UI

    -- Градиент сверху (3px)
    local TopGradientBox = Instance.new("Frame")
    TopGradientBox.Size = UDim2.new(1, 0, 0, 3)
    TopGradientBox.BackgroundColor3 = Color3.new(1,1,1)
    TopGradientBox.BorderSizePixel = 0
    TopGradientBox.ZIndex = 15
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(55, 125, 218)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(202, 72, 203)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(203, 70, 70)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(228, 226, 68)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(160, 201, 42))
    })
    UIGradient.Parent = TopGradientBox
    TopGradientBox.Parent = Main

    -- Заголовок окна
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 20)
    TitleBar.BackgroundTransparency = 1
    TitleBar.ZIndex = 20
    TitleBar.Parent = Main

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = WindowTitle
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 21
    TitleLabel.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 16)
    CloseBtn.Position = UDim2.new(1, -25, 0, 2)
    CloseBtn.BackgroundColor3 = Library.Theme.ElementBg
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Library.Theme.Text
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 12
    CloseBtn.ZIndex = 21
    CloseBtn.Parent = TitleBar
    CreateImGuiFrame(CloseBtn)
    CloseBtn.MouseButton1Click:Connect(function() UI:Destroy() end)

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 16)
    MinimizeBtn.Position = UDim2.new(1, -50, 0, 2)
    MinimizeBtn.BackgroundColor3 = Library.Theme.ElementBg
    MinimizeBtn.Text = "–"
    MinimizeBtn.TextColor3 = Library.Theme.Text
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.TextSize = 14
    MinimizeBtn.ZIndex = 21
    MinimizeBtn.Parent = TitleBar
    CreateImGuiFrame(MinimizeBtn)
    -- Минимизация оставлена как заглушка, можно доработать

    -- Drag окна (только за заголовок)
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local ActualMain = CreateImGuiFrame(Main)
    TopGradientBox.Parent = ActualMain

    -- Слой для отрисовки дропдаунов и попапов (поверх всего)
    local RenderTargetLayer = Instance.new("Frame")
    RenderTargetLayer.Size = UDim2.new(1,0,1,0)
    RenderTargetLayer.BackgroundTransparency = 1
    RenderTargetLayer.ZIndex = 900
    RenderTargetLayer.Parent = UI

    -- Боковое меню иконок
    local SidebarBox = Instance.new("Frame")
    SidebarBox.Size = UDim2.new(0, 60, 1, -23)
    SidebarBox.Position = UDim2.new(0, 0, 0, 23)
    SidebarBox.BackgroundColor3 = Library.Theme.WindowBg
    SidebarBox.BorderSizePixel = 0
    SidebarBox.ZIndex = Main.ZIndex + 1
    SidebarBox.Parent = ActualMain

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Library.Theme.OutlineInner
    SidebarLine.BorderSizePixel = 0
    SidebarLine.ZIndex = SidebarBox.ZIndex
    SidebarLine.Parent = SidebarBox

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -61, 1, -23)
    TabContainer.Position = UDim2.new(0, 61, 0, 23)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = ActualMain

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 12)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = SidebarBox
    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 15)
    Pad.Parent = SidebarBox

    local WindowData = { ActiveTabFrame = nil, Tabs = {} }

    function WindowData:CreateTab(icon)
        -- icon может быть числом (AssetId) или строкой (URL)
        local imagePath
        if type(icon) == "number" then
            imagePath = "rbxassetid://" .. tostring(icon)
        elseif type(icon) == "string" then
            imagePath = icon
        else
            error("CreateTab: icon must be number (AssetId) or string (URL)")
        end

        local IconButton = Instance.new("ImageButton")
        IconButton.Size = UDim2.new(0, 28, 0, 28)
        IconButton.BackgroundTransparency = 1
        IconButton.Image = imagePath
        IconButton.ImageColor3 = Library.Theme.TextDark
        IconButton.ZIndex = SidebarBox.ZIndex + 1
        IconButton.Parent = SidebarBox

        local TabContentBox = Instance.new("Frame")
        TabContentBox.Size = UDim2.new(1, 0, 1, 0)
        TabContentBox.BackgroundTransparency = 1
        TabContentBox.Visible = false
        TabContentBox.Parent = TabContainer

        -- Левая и правая колонки
        local CLeft = Instance.new("Frame")
        CLeft.Size = UDim2.new(0.5, -10, 1, -20)
        CLeft.Position = UDim2.new(0, 5, 0, 10)
        CLeft.BackgroundTransparency = 1
        CLeft.Parent = TabContentBox
        local CLLayout = Instance.new("UIListLayout")
        CLLayout.Padding = UDim.new(0, 12)
        CLLayout.Parent = CLeft

        local CRight = Instance.new("Frame")
        CRight.Size = UDim2.new(0.5, -10, 1, -20)
        CRight.Position = UDim2.new(0.5, 5, 0, 10)
        CRight.BackgroundTransparency = 1
        CRight.Parent = TabContentBox
        local CRLayout = Instance.new("UIListLayout")
        CRLayout.Padding = UDim.new(0, 12)
        CRLayout.Parent = CRight

        IconButton.MouseButton1Click:Connect(function()
            for _, frm in pairs(TabContainer:GetChildren()) do frm.Visible = false end
            for _, btn in pairs(SidebarBox:GetChildren()) do
                if btn:IsA("ImageButton") then btn.ImageColor3 = Library.Theme.TextDark end
            end
            TabContentBox.Visible = true
            IconButton.ImageColor3 = Library.Theme.Text
        end)

        if not WindowData.ActiveTabFrame then
            WindowData.ActiveTabFrame = TabContentBox
            TabContentBox.Visible = true
            IconButton.ImageColor3 = Library.Theme.Text
        end

        local TabExt = {}
        function TabExt:Groupbox(Title, TargetSide)
            local ContainerSpace = Instance.new("Frame")
            ContainerSpace.BackgroundColor3 = Library.Theme.GroupboxBg
            ContainerSpace.Size = UDim2.new(1, 0, 0, 50)
            ContainerSpace.ZIndex = Main.ZIndex + 2
            ContainerSpace.Parent = TargetSide == "Left" and CLeft or CRight

            local ContainerActual = CreateImGuiFrame(ContainerSpace)
            
            local TxtLabel = Instance.new("TextLabel")
            TxtLabel.Size = UDim2.new(0, 10, 0, 12)
            TxtLabel.Position = UDim2.new(0, 12, 0, -6)
            TxtLabel.BackgroundColor3 = Library.Theme.WindowBg
            TxtLabel.BorderSizePixel = 0
            TxtLabel.Text = " " .. Title .. " "
            TxtLabel.Font = Enum.Font.Arial
            TxtLabel.TextSize = 12
            TxtLabel.TextColor3 = Library.Theme.Text
            TxtLabel.ZIndex = ContainerActual.ZIndex + 5
            TxtLabel.AutomaticSize = Enum.AutomaticSize.X
            TxtLabel.Parent = ContainerSpace

            local InnerLayoutSpace = Instance.new("Frame")
            InnerLayoutSpace.Size = UDim2.new(1,0,1,0)
            InnerLayoutSpace.BackgroundTransparency = 1
            InnerLayoutSpace.Parent = ContainerActual

            local UIPadding = Instance.new("UIPadding")
            UIPadding.PaddingTop = UDim.new(0, 14)
            UIPadding.PaddingLeft = UDim.new(0, 12)
            UIPadding.PaddingRight = UDim.new(0, 12)
            UIPadding.PaddingBottom = UDim.new(0, 10)
            UIPadding.Parent = InnerLayoutSpace

            local BoxListLayout = Instance.new("UIListLayout")
            BoxListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            BoxListLayout.Padding = UDim.new(0, 6)
            BoxListLayout.Parent = InnerLayoutSpace

            BoxListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ContainerSpace.Size = UDim2.new(1, 0, 0, BoxListLayout.AbsoluteContentSize.Y + 28)
            end)

            local GroupBuilder = {}

            -- === TOGGLE (Checkbox) ===
            function GroupBuilder:Toggle(LabelText, StateDefault, KeybindText, Callback)
                local State = StateDefault or false
                local Frm = Instance.new("Frame")
                Frm.Size = UDim2.new(1, 0, 0, 14)
                Frm.BackgroundTransparency = 1
                Frm.Parent = InnerLayoutSpace

                local Sq = Instance.new("TextButton")
                Sq.Size = UDim2.new(0, 8, 0, 8)
                Sq.Position = UDim2.new(0, 0, 0.5, -4)
                Sq.BackgroundColor3 = State and Library.Theme.Accent or Library.Theme.ElementBg
                Sq.Text = ""
                Sq.ZIndex = ContainerActual.ZIndex + 3
                Sq.Parent = Frm
                local SqInternal = CreateImGuiFrame(Sq)

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -16, 1, 0)
                Lbl.Position = UDim2.new(0, 16, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = LabelText
                Lbl.TextColor3 = State and Color3.fromRGB(255,255,255) or Library.Theme.TextDark
                Lbl.Font = Enum.Font.Arial
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.ZIndex = ContainerActual.ZIndex + 3
                Lbl.Parent = Frm

                if KeybindText then
                    local KBind = Instance.new("TextLabel")
                    KBind.Size = UDim2.new(0, 40, 1, 0)
                    KBind.Position = UDim2.new(1, -40, 0, 0)
                    KBind.BackgroundTransparency = 1
                    KBind.Text = "[" .. KeybindText .. "]"
                    KBind.TextColor3 = Library.Theme.TextDark
                    KBind.Font = Enum.Font.Code
                    KBind.TextSize = 11
                    KBind.TextXAlignment = Enum.TextXAlignment.Right
                    KBind.ZIndex = ContainerActual.ZIndex + 3
                    KBind.Parent = Frm
                end

                Sq.MouseButton1Click:Connect(function()
                    State = not State
                    Sq.BackgroundColor3 = State and Library.Theme.Accent or Library.Theme.ElementBg
                    Lbl.TextColor3 = State and Color3.fromRGB(255,255,255) or Library.Theme.TextDark
                    if Callback then Callback(State) end
                end)
            end

            -- === SLIDER ===
            function GroupBuilder:Slider(LabelText, Min, Max, Default, Suffix, IsFloat, Callback)
                local SFrame = Instance.new("Frame")
                SFrame.Size = UDim2.new(1, 0, 0, 26)
                SFrame.BackgroundTransparency = 1
                SFrame.Parent = InnerLayoutSpace

                local LblText = Instance.new("TextLabel")
                LblText.Size = UDim2.new(1, 0, 0, 12)
                LblText.BackgroundTransparency = 1
                LblText.Text = LabelText
                LblText.TextColor3 = Library.Theme.Text
                LblText.Font = Enum.Font.Arial
                LblText.TextSize = 12
                LblText.TextXAlignment = Enum.TextXAlignment.Left
                LblText.ZIndex = ContainerActual.ZIndex + 3
                LblText.Parent = SFrame

                local TrackWrap = Instance.new("Frame")
                TrackWrap.Size = UDim2.new(1, 0, 0, 8)
                TrackWrap.Position = UDim2.new(0, 0, 0, 16)
                TrackWrap.BackgroundColor3 = Library.Theme.ElementBg
                TrackWrap.ZIndex = ContainerActual.ZIndex + 3
                TrackWrap.Parent = SFrame
                local TrackInternal = CreateImGuiFrame(TrackWrap)

                local FBar = Instance.new("Frame")
                local p = math.clamp((Default - Min) / (Max - Min), 0, 1)
                FBar.Size = UDim2.new(p, 0, 1, 0)
                FBar.BackgroundColor3 = Library.Theme.Accent
                FBar.BorderSizePixel = 0
                FBar.ZIndex = TrackInternal.ZIndex + 2
                FBar.Parent = TrackInternal

                local formatStr = IsFloat and "%.2f" or "%d"
                local LblVal = Instance.new("TextLabel")
                LblVal.Size = UDim2.new(1, -4, 1, 0)
                LblVal.Position = UDim2.new(0, 4, 0, 0)
                LblVal.BackgroundTransparency = 1
                LblVal.Text = string.format(formatStr, Default) .. (Suffix or "")
                LblVal.TextColor3 = Color3.fromRGB(255, 255, 255)
                LblVal.Font = Enum.Font.Arial
                LblVal.TextSize = 10
                LblVal.TextStrokeTransparency = 0.2
                LblVal.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                LblVal.TextXAlignment = Enum.TextXAlignment.Left
                LblVal.ZIndex = TrackInternal.ZIndex + 4
                LblVal.Parent = TrackWrap

                local isDragging = false
                local function updateValue(pcnt)
                    local val = Min + ((Max - Min) * pcnt)
                    if not IsFloat then val = math.floor(val) end
                    FBar.Size = UDim2.new(pcnt, 0, 1, 0)
                    LblVal.Text = string.format(formatStr, val) .. (Suffix or "")
                    if Callback then Callback(val) end
                end

                TrackWrap.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        local locX = UserInputService:GetMouseLocation().X
                        local barX, barSz = TrackWrap.AbsolutePosition.X, TrackWrap.AbsoluteSize.X
                        updateValue(math.clamp((locX - barX) / barSz, 0, 1))
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local locX = UserInputService:GetMouseLocation().X
                        local barX, barSz = TrackWrap.AbsolutePosition.X, TrackWrap.AbsoluteSize.X
                        updateValue(math.clamp((locX - barX) / barSz, 0, 1))
                    end
                end)
            end

            -- === COMBO ===
            function GroupBuilder:Combo(LabelText, TableValues, Default, Callback)
                local CFrm = Instance.new("Frame")
                CFrm.Size = UDim2.new(1, 0, 0, 34)
                CFrm.BackgroundTransparency = 1
                CFrm.Parent = InnerLayoutSpace

                local LblTop = Instance.new("TextLabel")
                LblTop.Size = UDim2.new(1, 0, 0, 12)
                LblTop.BackgroundTransparency = 1
                LblTop.Text = LabelText
                LblTop.TextColor3 = Library.Theme.Text
                LblTop.Font = Enum.Font.Arial
                LblTop.TextSize = 12
                LblTop.TextXAlignment = Enum.TextXAlignment.Left
                LblTop.ZIndex = ContainerActual.ZIndex + 3
                LblTop.Parent = CFrm

                local CBGWrap = Instance.new("Frame")
                CBGWrap.Size = UDim2.new(1, 0, 0, 16)
                CBGWrap.Position = UDim2.new(0, 0, 0, 16)
                CBGWrap.BackgroundColor3 = Library.Theme.ElementBg
                CBGWrap.ZIndex = ContainerActual.ZIndex + 3
                CBGWrap.Parent = CFrm
                local CBGInner = CreateImGuiFrame(CBGWrap)

                local TopBtn = Instance.new("TextButton")
                TopBtn.Size = UDim2.new(1, 0, 1, 0)
                TopBtn.BackgroundTransparency = 1
                TopBtn.Text = ""
                TopBtn.ZIndex = CBGInner.ZIndex + 3
                TopBtn.Parent = CBGInner

                local ResText = Instance.new("TextLabel")
                ResText.Size = UDim2.new(1, -20, 1, 0)
                ResText.Position = UDim2.new(0, 6, 0, 0)
                ResText.BackgroundTransparency = 1
                ResText.Text = Default or TableValues[1]
                ResText.TextColor3 = Library.Theme.TextDark
                ResText.Font = Enum.Font.Arial
                ResText.TextSize = 11
                ResText.TextXAlignment = Enum.TextXAlignment.Left
                ResText.ZIndex = TopBtn.ZIndex + 1
                ResText.Parent = TopBtn

                local ArrowSign = Instance.new("TextLabel")
                ArrowSign.Size = UDim2.new(0, 20, 1, 0)
                ArrowSign.Position = UDim2.new(1, -20, 0, 0)
                ArrowSign.BackgroundTransparency = 1
                ArrowSign.Text = "▼"
                ArrowSign.TextColor3 = Library.Theme.TextDark
                ArrowSign.Font = Enum.Font.Arial
                ArrowSign.TextSize = 8
                ArrowSign.ZIndex = TopBtn.ZIndex + 1
                ArrowSign.Parent = TopBtn

                TopBtn.MouseButton1Click:Connect(function()
                    RenderTargetLayer:ClearAllChildren()
                    local ItemHeight = 16
                    local ComboOpenWrap = Instance.new("Frame")
                    ComboOpenWrap.Size = UDim2.new(0, CBGWrap.AbsoluteSize.X, 0, (#TableValues * ItemHeight))
                    ComboOpenWrap.Position = UDim2.new(0, CBGWrap.AbsolutePosition.X, 0, CBGWrap.AbsolutePosition.Y + 17)
                    ComboOpenWrap.BackgroundColor3 = Library.Theme.DropdownBg
                    ComboOpenWrap.ZIndex = 1000
                    ComboOpenWrap.Parent = RenderTargetLayer
                    local ListDrawActual = CreateImGuiFrame(ComboOpenWrap)

                    local VLay = Instance.new("UIListLayout", ListDrawActual)
                    
                    for _, valstr in pairs(TableValues) do
                        local IOBtn = Instance.new("TextButton")
                        IOBtn.Size = UDim2.new(1, 0, 0, ItemHeight)
                        IOBtn.BackgroundColor3 = Library.Theme.ElementHover
                        IOBtn.BackgroundTransparency = 1
                        IOBtn.Text = "  " .. valstr
                        IOBtn.TextColor3 = (valstr == ResText.Text) and Library.Theme.Accent or Library.Theme.TextDark
                        IOBtn.Font = Enum.Font.Arial
                        IOBtn.TextSize = 11
                        IOBtn.TextXAlignment = Enum.TextXAlignment.Left
                        IOBtn.ZIndex = ListDrawActual.ZIndex + 5
                        IOBtn.Parent = ListDrawActual

                        IOBtn.MouseEnter:Connect(function() IOBtn.BackgroundTransparency = 0 end)
                        IOBtn.MouseLeave:Connect(function() IOBtn.BackgroundTransparency = 1 end)

                        IOBtn.MouseButton1Click:Connect(function()
                            ResText.Text = valstr
                            if Callback then Callback(valstr) end
                            RenderTargetLayer:ClearAllChildren()
                        end)
                    end

                    local BackDropBlocker = Instance.new("TextButton")
                    BackDropBlocker.Size = UDim2.new(10, 0, 10, 0)
                    BackDropBlocker.Position = UDim2.new(-5, 0, -5, 0)
                    BackDropBlocker.BackgroundTransparency = 1
                    BackDropBlocker.ZIndex = 901
                    BackDropBlocker.Text = ""
                    BackDropBlocker.Parent = RenderTargetLayer
                    BackDropBlocker.MouseButton1Click:Connect(function() RenderTargetLayer:ClearAllChildren() end)
                end)
            end

            -- === COLOR PICKER ===
            function GroupBuilder:ColorPicker(LabelText, DefaultColor, Callback)
                local currentColor = DefaultColor or Color3.fromRGB(255, 255, 255)
                local CFrm = Instance.new("Frame")
                CFrm.Size = UDim2.new(1, 0, 0, 28)
                CFrm.BackgroundTransparency = 1
                CFrm.Parent = InnerLayoutSpace

                local LblTop = Instance.new("TextLabel")
                LblTop.Size = UDim2.new(1, -30, 0, 12)
                LblTop.BackgroundTransparency = 1
                LblTop.Text = LabelText
                LblTop.TextColor3 = Library.Theme.Text
                LblTop.Font = Enum.Font.Arial
                LblTop.TextSize = 12
                LblTop.TextXAlignment = Enum.TextXAlignment.Left
                LblTop.ZIndex = ContainerActual.ZIndex + 3
                LblTop.Parent = CFrm

                local ColorPreview = Instance.new("Frame")
                ColorPreview.Size = UDim2.new(0, 18, 0, 14)
                ColorPreview.Position = UDim2.new(1, -24, 0, -2)
                ColorPreview.BackgroundColor3 = currentColor
                ColorPreview.BorderSizePixel = 0
                ColorPreview.ZIndex = ContainerActual.ZIndex + 3
                ColorPreview.Parent = CFrm
                CreateImGuiFrame(ColorPreview)

                local PickBtn = Instance.new("TextButton")
                PickBtn.Size = UDim2.new(0, 20, 0, 14)
                PickBtn.Position = UDim2.new(1, -20, 0, 0)
                PickBtn.BackgroundColor3 = Library.Theme.ElementBg
                PickBtn.Text = "▼"
                PickBtn.TextColor3 = Library.Theme.TextDark
                PickBtn.Font = Enum.Font.Code
                PickBtn.TextSize = 10
                PickBtn.ZIndex = ContainerActual.ZIndex + 3
                PickBtn.Parent = CFrm
                CreateImGuiFrame(PickBtn)

                PickBtn.MouseButton1Click:Connect(function()
                    RenderTargetLayer:ClearAllChildren()
                    local PickerFrame = Instance.new("Frame")
                    PickerFrame.Size = UDim2.new(0, 180, 0, 90)
                    PickerFrame.Position = UDim2.new(0, ColorPreview.AbsolutePosition.X - 160, 0, ColorPreview.AbsolutePosition.Y + 20)
                    PickerFrame.BackgroundColor3 = Library.Theme.DropdownBg
                    PickerFrame.ZIndex = 1000
                    PickerFrame.Parent = RenderTargetLayer
                    local PickerContent = CreateImGuiFrame(PickerFrame)

                    local RSlider, GSlider, BSlider
                    local function updateColor()
                        local r = RSlider.Value
                        local g = GSlider.Value
                        local b = BSlider.Value
                        currentColor = Color3.fromRGB(r, g, b)
                        ColorPreview.BackgroundColor3 = currentColor
                        if Callback then Callback(currentColor) end
                    end

                    local function createSlider(name, defaultVal, yPos)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0, 15, 0, 12)
                        lbl.Position = UDim2.new(0, 5, 0, yPos)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = name
                        lbl.TextColor3 = Library.Theme.Text
                        lbl.Font = Enum.Font.Code
                        lbl.TextSize = 11
                        lbl.Parent = PickerContent

                        local sliderFrame = Instance.new("Frame")
                        sliderFrame.Size = UDim2.new(1, -30, 0, 8)
                        sliderFrame.Position = UDim2.new(0, 20, 0, yPos+2)
                        sliderFrame.BackgroundColor3 = Library.Theme.ElementBg
                        sliderFrame.Parent = PickerContent
                        local sliderInner = CreateImGuiFrame(sliderFrame)

                        local fill = Instance.new("Frame")
                        fill.Size = UDim2.new(defaultVal/255, 0, 1, 0)
                        fill.BackgroundColor3 = Library.Theme.Accent
                        fill.BorderSizePixel = 0
                        fill.Parent = sliderInner

                        local val = defaultVal
                        local isDrag = false
                        sliderFrame.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                isDrag = true
                                local locX = UserInputService:GetMouseLocation().X
                                local barX = sliderFrame.AbsolutePosition.X
                                local barSz = sliderFrame.AbsoluteSize.X
                                val = math.clamp(math.floor(((locX - barX) / barSz) * 255), 0, 255)
                                fill.Size = UDim2.new(val/255, 0, 1, 0)
                                updateColor()
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDrag = false end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if isDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                local locX = UserInputService:GetMouseLocation().X
                                local barX = sliderFrame.AbsolutePosition.X
                                local barSz = sliderFrame.AbsoluteSize.X
                                val = math.clamp(math.floor(((locX - barX) / barSz) * 255), 0, 255)
                                fill.Size = UDim2.new(val/255, 0, 1, 0)
                                updateColor()
                            end
                        end)
                        return { Value = val, Fill = fill }
                    end

                    RSlider = createSlider("R", math.floor(currentColor.R * 255), 5)
                    GSlider = createSlider("G", math.floor(currentColor.G * 255), 30)
                    BSlider = createSlider("B", math.floor(currentColor.B * 255), 55)

                    local BackDropBlocker = Instance.new("TextButton")
                    BackDropBlocker.Size = UDim2.new(10, 0, 10, 0)
                    BackDropBlocker.Position = UDim2.new(-5, 0, -5, 0)
                    BackDropBlocker.BackgroundTransparency = 1
                    BackDropBlocker.ZIndex = 901
                    BackDropBlocker.Text = ""
                    BackDropBlocker.Parent = RenderTargetLayer
                    BackDropBlocker.MouseButton1Click:Connect(function() RenderTargetLayer:ClearAllChildren() end)
                end)
            end

            -- === KEYBIND PICKER ===
            function GroupBuilder:Keybind(LabelText, DefaultKey, Callback)
                local currentKey = DefaultKey or "M5"
                local Frm = Instance.new("Frame")
                Frm.Size = UDim2.new(1, 0, 0, 20)
                Frm.BackgroundTransparency = 1
                Frm.Parent = InnerLayoutSpace

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(0.5, 0, 1, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = LabelText
                Lbl.TextColor3 = Library.Theme.Text
                Lbl.Font = Enum.Font.Arial
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = Frm

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.new(0, 50, 1, -2)
                KeyBtn.Position = UDim2.new(1, -50, 0, 1)
                KeyBtn.BackgroundColor3 = Library.Theme.ElementBg
                KeyBtn.Text = "[" .. currentKey .. "]"
                KeyBtn.TextColor3 = Library.Theme.TextDark
                KeyBtn.Font = Enum.Font.Code
                KeyBtn.TextSize = 11
                KeyBtn.ZIndex = ContainerActual.ZIndex + 3
                KeyBtn.Parent = Frm
                CreateImGuiFrame(KeyBtn)

                local listening = false
                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "[...]"
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if listening and not gameProcessed then
                            local keyName
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                keyName = "M1"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                keyName = "M2"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                                keyName = "M3"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton4 then
                                keyName = "M4"
                            elseif input.UserInputType == Enum.UserInputType.MouseButton5 then
                                keyName = "M5"
                            elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                                keyName = input.KeyCode.Name
                            else
                                return
                            end
                            currentKey = keyName
                            KeyBtn.Text = "[" .. currentKey .. "]"
                            if Callback then Callback(currentKey) end
                            listening = false
                            conn:Disconnect()
                        end
                    end)
                    task.delay(5, function()
                        if listening then
                            listening = false
                            KeyBtn.Text = "[" .. currentKey .. "]"
                            conn:Disconnect()
                        end
                    end)
                end)
            end

            -- === TEXTBOX ===
            function GroupBuilder:Textbox(LabelText, Placeholder, DefaultText, Callback)
                local TFrm = Instance.new("Frame")
                TFrm.Size = UDim2.new(1, 0, 0, 28)
                TFrm.BackgroundTransparency = 1
                TFrm.Parent = InnerLayoutSpace

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, 0, 0, 12)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = LabelText
                Lbl.TextColor3 = Library.Theme.Text
                Lbl.Font = Enum.Font.Arial
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = TFrm

                local BoxWrap = Instance.new("Frame")
                BoxWrap.Size = UDim2.new(1, 0, 0, 16)
                BoxWrap.Position = UDim2.new(0, 0, 0, 14)
                BoxWrap.BackgroundColor3 = Library.Theme.ElementBg
                BoxWrap.ZIndex = ContainerActual.ZIndex + 3
                BoxWrap.Parent = TFrm
                local BoxInner = CreateImGuiFrame(BoxWrap)

                local TxtBox = Instance.new("TextBox")
                TxtBox.Size = UDim2.new(1, -4, 1, 0)
                TxtBox.Position = UDim2.new(0, 4, 0, 0)
                TxtBox.BackgroundTransparency = 1
                TxtBox.Text = DefaultText or ""
                TxtBox.PlaceholderText = Placeholder or ""
                TxtBox.TextColor3 = Library.Theme.Text
                TxtBox.PlaceholderColor3 = Library.Theme.TextDark
                TxtBox.Font = Enum.Font.Code
                TxtBox.TextSize = 11
                TxtBox.TextXAlignment = Enum.TextXAlignment.Left
                TxtBox.ZIndex = BoxInner.ZIndex + 1
                TxtBox.Parent = BoxInner

                TxtBox.FocusLost:Connect(function(enterPressed)
                    if Callback then Callback(TxtBox.Text) end
                end)
            end

            -- === LABEL ===
            function GroupBuilder:Label(Text)
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, 0, 0, 12)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = Text
                Lbl.TextColor3 = Library.Theme.Text
                Lbl.Font = Enum.Font.Arial
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = InnerLayoutSpace
            end

            return GroupBuilder
        end
        return TabExt
    end
    return WindowData
end

return Library
