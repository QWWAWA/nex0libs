local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Удаление старой версии при перезапуске
if CoreGui:FindFirstChild("SkeetReborn") then
    CoreGui.SkeetReborn:Destroy()
end

local Library = {
    -- Эта палитра точно имитирует последнюю (зеленую) версию со скрина.
    Theme = {
        Background    = Color3.fromRGB(15, 15, 15),     -- Почти черный, главный фон
        GroupboxBg    = Color3.fromRGB(22, 22, 22),     -- Фон коробок
        ElementBg     = Color3.fromRGB(28, 28, 28),     -- Темный фон слайдеров и кнопок
        ElementHover  = Color3.fromRGB(35, 35, 35),     -- Подсветка кнопок
        Accent        = Color3.fromRGB(160, 205, 50),   -- Тот самый кислотно-оливковый (зеленый)
        Text          = Color3.fromRGB(230, 230, 230),  -- Светло-серый/белый текст
        TextDark      = Color3.fromRGB(130, 130, 130),  -- Выключенный (неактивный) текст
        OutlineOuter  = Color3.fromRGB(0, 0, 0),        -- Внешняя абсолютная тень 1px
        OutlineInner  = Color3.fromRGB(42, 42, 42),     -- Световая обводка внутри 1px
        LineSeperator = Color3.fromRGB(35, 35, 35)      -- Разделительные полосы
    },
    ActiveDrawings = {}
}

-- Имитация тройных пиксельных границ C++ ImGui: "Black border > Dark Grey Highlight > Inner Box"
-- Эта функция — залог отсутствия роблоксовской мыльной рисовки
local function CreateImGuiFrame(ParentObj)
    local BorderOuter = Instance.new("Frame")
    BorderOuter.Name = "OuterLayer"
    BorderOuter.Size = UDim2.new(1, 2, 1, 2)
    BorderOuter.Position = UDim2.new(0, -1, 0, -1)
    BorderOuter.BackgroundColor3 = Library.Theme.OutlineOuter
    BorderOuter.BorderSizePixel = 0
    BorderOuter.ZIndex = ParentObj.ZIndex
    BorderOuter.Parent = ParentObj

    local BorderInner = Instance.new("Frame")
    BorderInner.Name = "InnerHighlightLayer"
    BorderInner.Size = UDim2.new(1, -2, 1, -2)
    BorderInner.Position = UDim2.new(0, 1, 0, 1)
    BorderInner.BackgroundColor3 = Library.Theme.OutlineInner
    BorderInner.BorderSizePixel = 0
    BorderInner.ZIndex = BorderOuter.ZIndex + 1
    BorderInner.Parent = BorderOuter

    local Content = Instance.new("Frame")
    Content.Name = "MainContentBox"
    Content.Size = UDim2.new(1, -2, 1, -2)
    Content.Position = UDim2.new(0, 1, 0, 1)
    Content.BackgroundColor3 = ParentObj.BackgroundColor3
    Content.BorderSizePixel = 0
    Content.ZIndex = BorderInner.ZIndex + 1
    Content.Parent = BorderInner

    ParentObj.BackgroundTransparency = 1
    return Content
end

function Library:CreateWindow(titleText)
    local UI = Instance.new("ScreenGui")
    UI.Name = "SkeetReborn"
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
    UI.ResetOnSpawn = false
    UI.IgnoreGuiInset = true
    UI.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 710, 0, 560)
    Main.Position = UDim2.new(0.5, -355, 0.5, -280)
    Main.BackgroundColor3 = Library.Theme.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = UI

    local TopGradientBox = Instance.new("Frame")
    TopGradientBox.Size = UDim2.new(1, 0, 0, 2)
    TopGradientBox.BackgroundColor3 = Color3.new(1,1,1)
    TopGradientBox.BorderSizePixel = 0
    TopGradientBox.Parent = Main
    local UIGradient = Instance.new("UIGradient")
    -- Можно поменять на кислотный, оставим градиент или можно сделать его solid зеленым.
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 174, 214)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(202, 72, 203)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 226, 68))
    })
    UIGradient.Parent = TopGradientBox

    -- Перенос окон
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = Main.Position end
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
    TopGradientBox.Parent = ActualMain -- перемещаем наверх после обводки

    -- Специальный оверлей для отрисовки пикеров поверх границ (ВАЖНО для дропдаунов)
    local RenderTargetLayer = Instance.new("Frame")
    RenderTargetLayer.Size = UDim2.new(1,0,1,0)
    RenderTargetLayer.BackgroundTransparency = 1
    RenderTargetLayer.ZIndex = 900
    RenderTargetLayer.Parent = UI

    -- Боковое меню вкладок
    local SidebarBox = Instance.new("Frame")
    SidebarBox.Size = UDim2.new(0, 70, 1, -2)
    SidebarBox.Position = UDim2.new(0, 0, 0, 2)
    SidebarBox.BackgroundColor3 = Library.Theme.Background
    SidebarBox.BorderSizePixel = 0
    SidebarBox.ZIndex = ActualMain.ZIndex
    SidebarBox.Parent = ActualMain

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Library.Theme.OutlineInner
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = SidebarBox

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -71, 1, -2)
    TabContainer.Position = UDim2.new(0, 71, 0, 2)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = ActualMain

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 14)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = SidebarBox
    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 30)
    Pad.Parent = SidebarBox

    local WindowData = {
        ActiveTabFrame = nil,
        SetTab = function() end
    }

    function WindowData:CreateTab(IconRbxAssetID)
        local Btn = Instance.new("ImageButton")
        Btn.Size = UDim2.new(0, 32, 0, 32)
        Btn.BackgroundTransparency = 1
        Btn.Image = IconRbxAssetID
        Btn.ImageColor3 = Library.Theme.TextDark
        Btn.Parent = SidebarBox

        local TabContentBox = Instance.new("Frame")
        TabContentBox.Size = UDim2.new(1, 0, 1, 0)
        TabContentBox.BackgroundTransparency = 1
        TabContentBox.Visible = false
        TabContentBox.Parent = TabContainer

        local CLeft = Instance.new("Frame")
        CLeft.Size = UDim2.new(0.5, -15, 1, -20)
        CLeft.Position = UDim2.new(0, 10, 0, 10)
        CLeft.BackgroundTransparency = 1
        CLeft.Parent = TabContentBox
        local CLLayout = Instance.new("UIListLayout")
        CLLayout.Padding = UDim.new(0, 15)
        CLLayout.Parent = CLeft

        local CRight = Instance.new("Frame")
        CRight.Size = UDim2.new(0.5, -15, 1, -20)
        CRight.Position = UDim2.new(0.5, 5, 0, 10)
        CRight.BackgroundTransparency = 1
        CRight.Parent = TabContentBox
        local CRLayout = Instance.new("UIListLayout")
        CRLayout.Padding = UDim.new(0, 15)
        CRLayout.Parent = CRight

        Btn.MouseButton1Click:Connect(function()
            for _, frm in pairs(TabContainer:GetChildren()) do frm.Visible = false end
            for _, img in pairs(SidebarBox:GetChildren()) do
                if img:IsA("ImageButton") then img.ImageColor3 = Library.Theme.TextDark end
            end
            TabContentBox.Visible = true
            Btn.ImageColor3 = Library.Theme.Accent
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
            ContainerSpace.Parent = TargetSide == "Left" and CLeft or CRight

            local ContainerActual = CreateImGuiFrame(ContainerSpace)

            local TxtLabel = Instance.new("TextLabel")
            TxtLabel.Size = UDim2.new(0, 10, 0, 14)
            TxtLabel.Position = UDim2.new(0, 14, 0, -7)
            TxtLabel.BackgroundColor3 = Library.Theme.Background -- Прячет задний контур
            TxtLabel.BorderSizePixel = 0
            TxtLabel.Text = " " .. Title .. " "
            TxtLabel.Font = Enum.Font.Arial -- Arial дает самый правильный мелкий C++ стиль
            TxtLabel.TextSize = 13
            TxtLabel.TextColor3 = Library.Theme.Text
            TxtLabel.ZIndex = ContainerActual.ZIndex + 5
            TxtLabel.AutomaticSize = Enum.AutomaticSize.X
            TxtLabel.Parent = ContainerSpace

            local InnerLayoutSpace = Instance.new("Frame")
            InnerLayoutSpace.Size = UDim2.new(1,0,1,0)
            InnerLayoutSpace.BackgroundTransparency = 1
            InnerLayoutSpace.Parent = ContainerActual

            local UIPadding = Instance.new("UIPadding")
            UIPadding.PaddingTop = UDim.new(0, 15)
            UIPadding.PaddingLeft = UDim.new(0, 12)
            UIPadding.PaddingRight = UDim.new(0, 12)
            UIPadding.PaddingBottom = UDim.new(0, 12)
            UIPadding.Parent = InnerLayoutSpace

            local BoxListLayout = Instance.new("UIListLayout")
            BoxListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            BoxListLayout.Padding = UDim.new(0, 8)
            BoxListLayout.Parent = InnerLayoutSpace

            BoxListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ContainerSpace.Size = UDim2.new(1, 0, 0, BoxListLayout.AbsoluteContentSize.Y + 30)
            end)

            local GroupBuilder = {}

            function GroupBuilder:Toggle(LabelText, StateDefault, FuncCB)
                local State = StateDefault or false
                local Frm = Instance.new("Frame")
                Frm.Size = UDim2.new(1, 0, 0, 14)
                Frm.BackgroundTransparency = 1
                Frm.Parent = InnerLayoutSpace

                local Sq = Instance.new("TextButton")
                Sq.Size = UDim2.new(0, 10, 0, 10)
                Sq.Position = UDim2.new(0, 0, 0.5, -5)
                Sq.BackgroundColor3 = Library.Theme.ElementBg
                Sq.Text = ""
                Sq.Parent = Frm
                local SqInternal = CreateImGuiFrame(Sq)

                local SqFill = Instance.new("Frame")
                SqFill.Size = UDim2.new(1, 0, 1, 0)
                SqFill.BackgroundColor3 = Library.Theme.Accent
                SqFill.BorderSizePixel = 0
                SqFill.Visible = State
                SqFill.ZIndex = SqInternal.ZIndex + 2
                SqFill.Parent = SqInternal

                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -18, 1, 0)
                Lbl.Position = UDim2.new(0, 18, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = LabelText
                Lbl.TextColor3 = State and Library.Theme.Text or Library.Theme.TextDark
                Lbl.Font = Enum.Font.Arial
                Lbl.TextSize = 13
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = Frm

                Sq.MouseButton1Click:Connect(function()
                    State = not State
                    SqFill.Visible = State
                    Lbl.TextColor3 = State and Library.Theme.Text or Library.Theme.TextDark
                    if FuncCB then FuncCB(State) end
                end)
            end

            -- Очень плоские тонкие слайдеры, как на зеленых скринах (Primordial V1 / Onetap)
            function GroupBuilder:Slider(LabelText, Min, Max, Def, FuncCB)
                local SFrame = Instance.new("Frame")
                SFrame.Size = UDim2.new(1, 0, 0, 30)
                SFrame.BackgroundTransparency = 1
                SFrame.Parent = InnerLayoutSpace

                local LblText = Instance.new("TextLabel")
                LblText.Size = UDim2.new(1, 0, 0, 14)
                LblText.BackgroundTransparency = 1
                LblText.Text = LabelText
                LblText.TextColor3 = Library.Theme.Text
                LblText.Font = Enum.Font.Arial
                LblText.TextSize = 13
                LblText.TextXAlignment = Enum.TextXAlignment.Left
                LblText.Parent = SFrame

                local LblVal = Instance.new("TextLabel")
                LblVal.Size = UDim2.new(1, 0, 0, 14)
                LblVal.BackgroundTransparency = 1
                LblVal.Text = tostring(Def)
                LblVal.TextColor3 = Library.Theme.Text
                LblVal.Font = Enum.Font.Arial
                LblVal.TextSize = 13
                LblVal.TextXAlignment = Enum.TextXAlignment.Right
                LblVal.Parent = SFrame

                local TrackWrap = Instance.new("Frame")
                TrackWrap.Size = UDim2.new(1, 0, 0, 6) -- Очень узкая полоска 6px в высоту!
                TrackWrap.Position = UDim2.new(0, 0, 0, 20)
                TrackWrap.BackgroundColor3 = Library.Theme.ElementBg
                TrackWrap.Parent = SFrame
                local TrackInternal = CreateImGuiFrame(TrackWrap)

                local FBar = Instance.new("Frame")
                local p = math.clamp((Def - Min) / (Max - Min), 0, 1)
                FBar.Size = UDim2.new(p, 0, 1, 0)
                FBar.BackgroundColor3 = Library.Theme.Accent
                FBar.BorderSizePixel = 0
                FBar.ZIndex = TrackInternal.ZIndex + 2
                FBar.Parent = TrackInternal

                local isDragging = false
                TrackWrap.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end end)
                UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
                
                UserInputService.InputChanged:Connect(function(inp)
                    if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local locX = UserInputService:GetMouseLocation().X
                        local barX, barSz = TrackWrap.AbsolutePosition.X, TrackWrap.AbsoluteSize.X
                        local pcnt = math.clamp((locX - barX) / barSz, 0, 1)
                        local roundedValue = math.floor(Min + ((Max - Min) * pcnt))
                        
                        FBar.Size = UDim2.new(pcnt, 0, 1, 0)
                        LblVal.Text = tostring(roundedValue)
                        if FuncCB then FuncCB(roundedValue) end
                    end
                end)
            end

            -- Выпадающие списки (Абсолютно переработанные: никаких багающихся zIndex!)
            function GroupBuilder:Combo(LabelText, TableValues, DefaultSel, FuncCB)
                local CFrm = Instance.new("Frame")
                CFrm.Size = UDim2.new(1, 0, 0, 44)
                CFrm.BackgroundTransparency = 1
                CFrm.Parent = InnerLayoutSpace

                local LblTop = Instance.new("TextLabel")
                LblTop.Size = UDim2.new(1, 0, 0, 14)
                LblTop.BackgroundTransparency = 1
                LblTop.Text = LabelText
                LblTop.TextColor3 = Library.Theme.TextDark
                LblTop.Font = Enum.Font.Arial
                LblTop.TextSize = 13
                LblTop.TextXAlignment = Enum.TextXAlignment.Left
                LblTop.Parent = CFrm

                local CBGWrap = Instance.new("Frame")
                CBGWrap.Size = UDim2.new(1, 0, 0, 22)
                CBGWrap.Position = UDim2.new(0, 0, 0, 18)
                CBGWrap.BackgroundColor3 = Library.Theme.ElementBg
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
                ResText.Position = UDim2.new(0, 10, 0, 0)
                ResText.BackgroundTransparency = 1
                ResText.Text = DefaultSel or TableValues[1]
                ResText.TextColor3 = Library.Theme.Text
                ResText.Font = Enum.Font.Arial
                ResText.TextSize = 13
                ResText.TextXAlignment = Enum.TextXAlignment.Left
                ResText.ZIndex = TopBtn.ZIndex
                ResText.Parent = TopBtn

                local ArrowSign = Instance.new("TextLabel")
                ArrowSign.Size = UDim2.new(0, 20, 1, 0)
                ArrowSign.Position = UDim2.new(1, -20, 0, 0)
                ArrowSign.BackgroundTransparency = 1
                ArrowSign.Text = "[-]"
                ArrowSign.TextColor3 = Library.Theme.TextDark
                ArrowSign.Font = Enum.Font.Code
                ArrowSign.TextSize = 13
                ArrowSign.ZIndex = TopBtn.ZIndex
                ArrowSign.Parent = TopBtn

                TopBtn.MouseButton1Click:Connect(function()
                    RenderTargetLayer:ClearAllChildren()

                    local ComboOpenWrap = Instance.new("Frame")
                    ComboOpenWrap.Size = UDim2.new(0, CBGWrap.AbsoluteSize.X, 0, (#TableValues * 22) + 2)
                    -- Отрисовывается абсолютно там, где кликнуто в мировых координатах UI
                    ComboOpenWrap.Position = UDim2.new(0, CBGWrap.AbsolutePosition.X, 0, CBGWrap.AbsolutePosition.Y + 23)
                    ComboOpenWrap.BackgroundColor3 = Library.Theme.ElementBg
                    ComboOpenWrap.ZIndex = 1000
                    ComboOpenWrap.Parent = RenderTargetLayer
                    local ListDrawActual = CreateImGuiFrame(ComboOpenWrap)

                    local VLay = Instance.new("UIListLayout", ListDrawActual)
                    
                    for _, valstr in pairs(TableValues) do
                        local IOBtn = Instance.new("TextButton")
                        IOBtn.Size = UDim2.new(1, 0, 0, 22)
                        IOBtn.BackgroundTransparency = 1
                        IOBtn.Text = "  " .. valstr
                        IOBtn.TextColor3 = (valstr == ResText.Text) and Library.Theme.Accent or Library.Theme.TextDark
                        IOBtn.Font = Enum.Font.Arial
                        IOBtn.TextSize = 13
                        IOBtn.TextXAlignment = Enum.TextXAlignment.Left
                        IOBtn.ZIndex = ListDrawActual.ZIndex + 5
                        IOBtn.Parent = ListDrawActual

                        -- Ховер
                        IOBtn.MouseEnter:Connect(function() IOBtn.BackgroundColor3 = Library.Theme.ElementHover; IOBtn.BackgroundTransparency = 0 end)
                        IOBtn.MouseLeave:Connect(function() IOBtn.BackgroundTransparency = 1 end)

                        IOBtn.MouseButton1Click:Connect(function()
                            ResText.Text = valstr
                            RenderTargetLayer:ClearAllChildren()
                            if FuncCB then FuncCB(valstr) end
                        end)
                    end

                    -- Если пользователь кликает по фону оверлея — выпадающий список исчезает.
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

            -- Очень плоская кнопка (Flat C++)
            function GroupBuilder:Button(TxtInfo, ActBlock)
                local BFrameSpace = Instance.new("Frame")
                BFrameSpace.Size = UDim2.new(1, 0, 0, 24)
                BFrameSpace.BackgroundColor3 = Library.Theme.ElementBg
                BFrameSpace.Parent = InnerLayoutSpace
                local RealBtnImGuiFrame = CreateImGuiFrame(BFrameSpace)

                local RTClickBtn = Instance.new("TextButton")
                RTClickBtn.Size = UDim2.new(1, 0, 1, 0)
                RTClickBtn.BackgroundTransparency = 1
                RTClickBtn.Text = TxtInfo
                RTClickBtn.Font = Enum.Font.Arial
                RTClickBtn.TextSize = 13
                RTClickBtn.TextColor3 = Library.Theme.Text
                RTClickBtn.ZIndex = RealBtnImGuiFrame.ZIndex + 5
                RTClickBtn.Parent = RealBtnImGuiFrame

                RTClickBtn.MouseEnter:Connect(function() RealBtnImGuiFrame.BackgroundColor3 = Library.Theme.ElementHover end)
                RTClickBtn.MouseLeave:Connect(function() RealBtnImGuiFrame.BackgroundColor3 = Library.Theme.ElementBg end)
                RTClickBtn.MouseButton1Click:Connect(function() if ActBlock then ActBlock() end end)
            end

            return GroupBuilder
        end
        
        return TabExt
    end

    return WindowData
end

return Library
