local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local Library = {
    Theme = {
        WindowBg      = Color3.fromRGB(12, 12, 12),
        GroupboxBg    = Color3.fromRGB(12, 12, 12),
        ElementBg     = Color3.fromRGB(35, 35, 40),
        ElementHover  = Color3.fromRGB(45, 45, 50),
        Accent        = Color3.fromRGB(144, 195, 31),   -- Заменил на классический салатовый Skeet (или оставь свой синий 59, 115, 205)
        Text          = Color3.fromRGB(200, 200, 200),
        TextDark      = Color3.fromRGB(100, 100, 100),
        OutlineOuter  = Color3.fromRGB(0, 0, 0),
        OutlineInner  = Color3.fromRGB(45, 45, 45),
        DropdownBg    = Color3.fromRGB(20, 20, 20)
    }
}

-- Имитация тройных пиксельных границ C++ ImGui
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

function Library:CreateWindow()
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
    Main.Size = UDim2.new(0, 640, 0, 520)
    Main.Position = UDim2.new(0.5, -320, 0.5, -260)
    Main.BackgroundColor3 = Library.Theme.WindowBg
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ZIndex = 10
    Main.Parent = UI

    local TopGradientBox = Instance.new("Frame")
    TopGradientBox.Size = UDim2.new(1, 0, 0, 2)
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

    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < Main.AbsolutePosition.Y + 20 then 
            dragging = true dragStart = input.Position startPos = Main.Position 
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

    local RenderTargetLayer = Instance.new("Frame")
    RenderTargetLayer.Size = UDim2.new(1,0,1,0)
    RenderTargetLayer.BackgroundTransparency = 1
    RenderTargetLayer.ZIndex = 900
    RenderTargetLayer.Parent = UI

    -- ИСПРАВЛЕНИЕ: Добавлен ClipDescendants, чтобы иконки не вылезали
    local SidebarBox = Instance.new("Frame")
    SidebarBox.Size = UDim2.new(0, 64, 1, -2)
    SidebarBox.Position = UDim2.new(0, 0, 0, 2)
    SidebarBox.BackgroundColor3 = Library.Theme.WindowBg
    SidebarBox.BorderSizePixel = 0
    SidebarBox.ZIndex = Main.ZIndex + 1
    SidebarBox.ClipDescendants = true 
    SidebarBox.Parent = ActualMain

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Library.Theme.OutlineInner
    SidebarLine.BorderSizePixel = 0
    SidebarLine.ZIndex = SidebarBox.ZIndex
    SidebarLine.Parent = SidebarBox

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -65, 1, -2)
    TabContainer.Position = UDim2.new(0, 65, 0, 2)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = ActualMain

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 18)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = SidebarBox
    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 25)
    Pad.Parent = SidebarBox

    local WindowData = { ActiveTabFrame = nil }

    function WindowData:CreateTab(IconRbxAssetID)
        local Btn = Instance.new("ImageButton")
        Btn.Size = UDim2.new(0, 28, 0, 28) -- Чуть уменьшил размер иконки для аккуратности
        Btn.BackgroundTransparency = 1
        Btn.Image = IconRbxAssetID
        Btn.ImageColor3 = Library.Theme.TextDark
        Btn.ZIndex = SidebarBox.ZIndex + 1
        Btn.Parent = SidebarBox

        local TabContentBox = Instance.new("Frame")
        TabContentBox.Size = UDim2.new(1, 0, 1, 0)
        TabContentBox.BackgroundTransparency = 1
        TabContentBox.Visible = false
        TabContentBox.Parent = TabContainer

        local CLeft = Instance.new("Frame")
        CLeft.Size = UDim2.new(0.5, -16, 1, -20)
        CLeft.Position = UDim2.new(0, 10, 0, 10)
        CLeft.BackgroundTransparency = 1
        CLeft.Parent = TabContentBox
        local CLLayout = Instance.new("UIListLayout")
        CLLayout.Padding = UDim.new(0, 12)
        CLLayout.Parent = CLeft

        local CRight = Instance.new("Frame")
        CRight.Size = UDim2.new(0.5, -16, 1, -20)
        CRight.Position = UDim2.new(0.5, 6, 0, 10)
        CRight.BackgroundTransparency = 1
        CRight.Parent = TabContentBox
        local CRLayout = Instance.new("UIListLayout")
        CRLayout.Padding = UDim.new(0, 12)
        CRLayout.Parent = CRight

        Btn.MouseButton1Click:Connect(function()
            for _, frm in pairs(TabContainer:GetChildren()) do frm.Visible = false end
            for _, img in pairs(SidebarBox:GetChildren()) do
                if img:IsA("ImageButton") then img.ImageColor3 = Library.Theme.TextDark end
            end
            TabContentBox.Visible = true
            Btn.ImageColor3 = Library.Theme.Accent -- Активная иконка цвета Accent
        end)

        if not WindowData.ActiveTabFrame then
            WindowData.ActiveTabFrame = TabContentBox
            TabContentBox.Visible = true
            Btn.ImageColor3 = Library.Theme.Accent
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
            UIPadding.PaddingLeft = UDim.new(0, 14)
            UIPadding.PaddingRight = UDim.new(0, 14)
            UIPadding.PaddingBottom = UDim.new(0, 14)
            UIPadding.Parent = InnerLayoutSpace

            local BoxListLayout = Instance.new("UIListLayout")
            BoxListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            BoxListLayout.Padding = UDim.new(0, 6)
            BoxListLayout.Parent = InnerLayoutSpace

            BoxListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ContainerSpace.Size = UDim2.new(1, 0, 0, BoxListLayout.AbsoluteContentSize.Y + 28)
            end)

            local GroupBuilder = {}

            function GroupBuilder:Toggle(LabelText, StateDefault, KeybindText, FuncCB)
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
                    if FuncCB then FuncCB(State) end
                end)
            end

            -- НОВЫЙ ЭЛЕМЕНТ: ColorPicker (привязывается к предыдущему фрейму или работает сам по себе)
            function GroupBuilder:ColorPicker(LabelText, DefaultColor, FuncCB)
                local Frm = Instance.new("Frame")
                Frm.Size = UDim2.new(1, 0, 0, 14)
                Frm.BackgroundTransparency = 1
                Frm.Parent = InnerLayoutSpace

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -30, 1, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = LabelText
                Lbl.TextColor3 = Library.Theme.TextDark
                Lbl.Font = Enum.Font.Arial
                Lbl.TextSize = 12
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.ZIndex = ContainerActual.ZIndex + 3
                Lbl.Parent = Frm

                local ColBtnWrap = Instance.new("Frame")
                ColBtnWrap.Size = UDim2.new(0, 18, 0, 10)
                ColBtnWrap.Position = UDim2.new(1, -18, 0.5, -5)
                ColBtnWrap.BackgroundColor3 = DefaultColor or Color3.fromRGB(255, 0, 0)
                ColBtnWrap.ZIndex = ContainerActual.ZIndex + 3
                ColBtnWrap.Parent = Frm
                CreateImGuiFrame(ColBtnWrap)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1,0,1,0)
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                Btn.ZIndex = ColBtnWrap.ZIndex + 1
                Btn.Parent = ColBtnWrap

                -- Здесь можно добавить логику открытия палитры
                Btn.MouseButton1Click:Connect(function()
                    print("ColorPicker clicked for " .. LabelText)
                end)
            end

            function GroupBuilder:Slider(LabelText, Min, Max, Def, Suffix, IsFloat)
                -- Твой оригинальный код слайдера без изменений
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
                local p = math.clamp((Def - Min) / (Max - Min), 0, 1)
                FBar.Size = UDim2.new(p, 0, 1, 0)
                FBar.BackgroundColor3 = Library.Theme.Accent
                FBar.BorderSizePixel = 0
                FBar.ZIndex = TrackInternal.ZIndex + 2
                FBar.Parent = TrackInternal

                local formatStr = IsFloat and "%.2f" or "%d"
                local defStr = string.format(formatStr, Def)

                local LblVal = Instance.new("TextLabel")
                LblVal.Size = UDim2.new(1, -4, 1, 0)
                LblVal.Position = UDim2.new(0, 4, 0, 0)
                LblVal.BackgroundTransparency = 1
                LblVal.Text = defStr .. (Suffix or "")
                LblVal.TextColor3 = Color3.fromRGB(255, 255, 255)
                LblVal.Font = Enum.Font.Arial
                LblVal.TextSize = 10
                LblVal.TextStrokeTransparency = 0.2 
                LblVal.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                LblVal.TextXAlignment = Enum.TextXAlignment.Left
                LblVal.ZIndex = TrackInternal.ZIndex + 4
                LblVal.Parent = TrackWrap

                local isDragging = false
                TrackWrap.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end end)
                UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
                
                UserInputService.InputChanged:Connect(function(inp)
                    if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local locX = UserInputService:GetMouseLocation().X
                        local barX, barSz = TrackWrap.AbsolutePosition.X, TrackWrap.AbsoluteSize.X
                        local pcnt = math.clamp((locX - barX) / barSz, 0, 1)
                        
                        local realVal = Min + ((Max - Min) * pcnt)
                        local displayVal = IsFloat and realVal or math.floor(realVal)

                        FBar.Size = UDim2.new(pcnt, 0, 1, 0)
                        LblVal.Text = string.format(formatStr, displayVal) .. (Suffix or "")
                    end
                end)
            end

            -- НОВЫЙ ЭЛЕМЕНТ: MultiCombo (Выпадающий список с чекбоксами)
            function GroupBuilder:MultiCombo(LabelText, TableValues, DefaultSelTable)
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

                local SelectedItems = DefaultSelTable or {}
                
                local function GetSelectedString()
                    if #SelectedItems == 0 then return "-" end
                    local str = table.concat(SelectedItems, ", ")
                    if string.len(str) > 25 then return string.sub(str, 1, 22) .. "..." end
                    return str
                end

                local ResText = Instance.new("TextLabel")
                ResText.Size = UDim2.new(1, -20, 1, 0)
                ResText.Position = UDim2.new(0, 6, 0, 0)
                ResText.BackgroundTransparency = 1
                ResText.Text = GetSelectedString()
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
                        local isSelected = table.find(SelectedItems, valstr) ~= nil
                        local IOBtn = Instance.new("TextButton")
                        IOBtn.Size = UDim2.new(1, 0, 0, ItemHeight)
                        IOBtn.BackgroundColor3 = Library.Theme.ElementHover
                        IOBtn.BackgroundTransparency = 1
                        IOBtn.Text = "  " .. valstr
                        IOBtn.TextColor3 = isSelected and Library.Theme.Accent or Library.Theme.TextDark
                        IOBtn.Font = Enum.Font.Arial
                        IOBtn.TextSize = 11
                        IOBtn.TextXAlignment = Enum.TextXAlignment.Left
                        IOBtn.ZIndex = ListDrawActual.ZIndex + 5
                        IOBtn.Parent = ListDrawActual

                        IOBtn.MouseEnter:Connect(function() IOBtn.BackgroundTransparency = 0 end)
                        IOBtn.MouseLeave:Connect(function() IOBtn.BackgroundTransparency = 1 end)

                        IOBtn.MouseButton1Click:Connect(function()
                            if table.find(SelectedItems, valstr) then
                                table.remove(SelectedItems, table.find(SelectedItems, valstr))
                                IOBtn.TextColor3 = Library.Theme.TextDark
                            else
                                table.insert(SelectedItems, valstr)
                                IOBtn.TextColor3 = Library.Theme.Accent
                            end
                            ResText.Text = GetSelectedString()
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

            -- Combo (Dropdown)
            function GroupBuilder:Combo(LabelText, TableValues, DefaultSel)
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
                ResText.Text = DefaultSel or TableValues[1]
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

            return GroupBuilder
        end
        return TabExt
    end
    return WindowData
end

return Library
