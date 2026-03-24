local Library = {}
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local Theme = {
    Background = Color3.fromRGB(12, 12, 14),
    Outline = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(136, 146, 214),
    TextWhite = Color3.fromRGB(220, 220, 220),
    TextHover = Color3.fromRGB(170, 170, 175), -- Цвет при наведении
    TextDark = Color3.fromRGB(100, 100, 105),
    ElementBg = Color3.fromRGB(18, 18, 20),
    Font = Enum.Font.RobotoMono
}

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do inst[k] = v end
    return inst
end

-- Функция для быстрых анимаций
local function Tween(instance, properties, duration)
    TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

function Library:CreateWindow(config)
    local Window = {}
    config.Name = config.Name or "menu"
    
    if CoreGui:FindFirstChild("Nex0Library") then CoreGui.Nex0Library:Destroy() end
    
    local ScreenGui = Create("ScreenGui", { Name = "Nex0Library", Parent = CoreGui })
    
    local MainFrame = Create("Frame", {
        Size = UDim2.new(0, 680, 0, 430),
        Position = UDim2.new(0.5, -340, 0.5, -215),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0, Parent = ScreenGui, Active = true, Draggable = true,
        ClipsDescendants = true
    })
    Create("UIStroke", { Parent = MainFrame, Color = Theme.Outline, Thickness = 1 })
    
    -- TopBar
    local TopBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = MainFrame })
    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = TopBar })
    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = TopBar })
    
    Create("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = config.Name, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar })
    
    local dateStr = os.date("%A, %d %b %Y"):lower()
    Create("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, -10, 0, 0), BackgroundTransparency = 1, Text = dateStr, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = TopBar })

    -- Sidebar & Content
    local Sidebar = Create("Frame", { Size = UDim2.new(0, 140, 1, -27), Position = UDim2.new(0, 0, 0, 27), BackgroundTransparency = 1, Parent = MainFrame })
    Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = Sidebar })
    local ContentArea = Create("Frame", { Size = UDim2.new(1, -141, 1, -27), Position = UDim2.new(0, 141, 0, 27), BackgroundTransparency = 1, Parent = MainFrame })

    local TabsContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, -140), Position = UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1, Parent = Sidebar })

    -- Logo Area (Доработано)
    local LogoFrame = Create("Frame", { Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0, 10, 1, -130), BackgroundColor3 = Theme.Background, Parent = Sidebar })
    Create("UIStroke", { Parent = LogoFrame, Color = Theme.Outline, Thickness = 1 })
    Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -25), BackgroundTransparency = 1, Text = "a m n e s i a", TextColor3 = Theme.Accent, Font = Theme.Font, TextSize = 13, Parent = LogoFrame })
    
    local LogoImage = Create("ImageLabel", { 
        Size = UDim2.new(0, 75, 0, 75), -- Сделал чуть крупнее для читаемости
        Position = UDim2.new(0.5, -37.5, 0, 12), 
        BackgroundTransparency = 1, 
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit, 
        Parent = LogoFrame 
    })

    task.spawn(function()
        local success, imgData = pcall(function() return game:HttpGet("https://i.ibb.co/v6zxWBhw/edited-photo.png") end)
        if success and imgData then
            pcall(function()
                writefile("nex0_logo_custom.png", imgData)
                LogoImage.Image = getcustomasset("nex0_logo_custom.png")
            end)
        end
    end)

    Window.Tabs = {}
    local currentTab = nil

    function Window:AddTab(name)
        local Tab = { SubTabs = {} }
        local tabCount = #Window.Tabs
        
        -- Кнопка теперь прозрачная, текст и полоска живут раздельно (исправлен баг наложения)
        local TabBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, tabCount * 32), BackgroundTransparency = 1, Text = "", Parent = TabsContainer })
        local TabText = Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabBtn })
        local ActiveLine = Create("Frame", { Size = UDim2.new(0, 2, 1, -12), Position = UDim2.new(0, 8, 0, 6), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = TabBtn })
        
        local TabContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentArea })
        local SubTabsContainer = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = TabContainer })
        Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = SubTabsContainer })
        local GroupboxesContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Parent = TabContainer })

        -- Плавные анимации при наведении
        TabBtn.MouseEnter:Connect(function()
            if currentTab.Btn ~= TabBtn then Tween(TabText, {TextColor3 = Theme.TextHover}, 0.15) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if currentTab.Btn ~= TabBtn then Tween(TabText, {TextColor3 = Theme.TextDark}, 0.15) end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if currentTab then
                Tween(currentTab.Text, {TextColor3 = Theme.TextDark}, 0.2)
                Tween(currentTab.Line, {BackgroundTransparency = 1}, 0.2)
                currentTab.Container.Visible = false
            end
            currentTab = { Btn = TabBtn, Text = TabText, Line = ActiveLine, Container = TabContainer }
            Tween(TabText, {TextColor3 = Theme.TextWhite}, 0.2)
            Tween(ActiveLine, {BackgroundTransparency = 0}, 0.2)
            TabContainer.Visible = true
        end)

        if #Window.Tabs == 0 then 
            TabText.TextColor3 = Theme.TextWhite
            ActiveLine.BackgroundTransparency = 0
            TabContainer.Visible = true
            currentTab = { Btn = TabBtn, Text = TabText, Line = ActiveLine, Container = TabContainer } 
        end
        table.insert(Window.Tabs, Tab)

        local currentSubTab = nil

        function Tab:AddSubTab(subName)
            local SubTab = {}
            local subCount = #Tab.SubTabs
            
            local STabBtn = Create("TextButton", { Size = UDim2.new(1/3, 0, 1, 0), Position = UDim2.new((1/3) * subCount, 0, 0, 0), BackgroundTransparency = 1, Text = subName, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, Parent = SubTabsContainer })
            local SActiveLine = Create("Frame", { Size = UDim2.new(0.6, 0, 0, 2), Position = UDim2.new(0.2, 0, 1, -1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = STabBtn })
            local STabContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = GroupboxesContainer })

            STabBtn.MouseEnter:Connect(function() if currentSubTab.Btn ~= STabBtn then Tween(STabBtn, {TextColor3 = Theme.TextHover}, 0.15) end end)
            STabBtn.MouseLeave:Connect(function() if currentSubTab.Btn ~= STabBtn then Tween(STabBtn, {TextColor3 = Theme.TextDark}, 0.15) end end)

            STabBtn.MouseButton1Click:Connect(function()
                if currentSubTab then
                    Tween(currentSubTab.Btn, {TextColor3 = Theme.TextDark}, 0.2)
                    Tween(currentSubTab.Line, {BackgroundTransparency = 1}, 0.2)
                    currentSubTab.Container.Visible = false
                end
                currentSubTab = { Btn = STabBtn, Line = SActiveLine, Container = STabContainer }
                Tween(STabBtn, {TextColor3 = Theme.TextWhite}, 0.2)
                Tween(SActiveLine, {BackgroundTransparency = 0}, 0.2)
                STabContainer.Visible = true
            end)

            if #Tab.SubTabs == 0 then 
                STabBtn.TextColor3 = Theme.TextWhite
                SActiveLine.BackgroundTransparency = 0
                STabContainer.Visible = true
                currentSubTab = { Btn = STabBtn, Line = SActiveLine, Container = STabContainer } 
            end
            table.insert(Tab.SubTabs, SubTab)

            function SubTab:AddGroupBox(gbName, side)
                local GroupBox = {}
                local gbPos = side == "Left" and UDim2.new(0, 15, 0, 20) or UDim2.new(0.5, 5, 0, 20)
                local gbSize = side == "Left" and UDim2.new(0.5, -25, 1, -40) or UDim2.new(0.5, -20, 1, -40)

                local GBFrame = Create("Frame", { Size = gbSize, Position = gbPos, BackgroundTransparency = 1, Parent = STabContainer })
                Create("UIStroke", { Parent = GBFrame, Color = Theme.Outline, Thickness = 1 })
                
                local TitleBg = Create("Frame", { Size = UDim2.new(0, string.len(gbName)*8, 0, 10), Position = UDim2.new(0.5, -(string.len(gbName)*4), 0, -5), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = GBFrame })
                Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = gbName, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, Parent = TitleBg })

                local ItemsContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1, Parent = GBFrame })
                local GBLayout = Create("UIListLayout", { Parent = ItemsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
                Create("UIPadding", { Parent = ItemsContainer, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15) })

                function GroupBox:AddToggle(text, default, hasKeybind, callback)
                    callback = callback or function() end
                    local state = default or false
                    
                    local ToggleFrame = Create("TextButton", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = "", Parent = ItemsContainer })
                    local Box = Create("Frame", { Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0, 0, 0, 2), BackgroundColor3 = state and Theme.Accent or Theme.ElementBg, BorderSizePixel = 0, Parent = ToggleFrame })
                    local TglText = Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleFrame })
                    
                    if hasKeybind then
                        local KBBox = Create("Frame", { Size = UDim2.new(0, 20, 0, 12), Position = UDim2.new(1, -20, 0, 1), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, Parent = ToggleFrame })
                        Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "-", TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 12, Parent = KBBox })
                    end

                    ToggleFrame.MouseButton1Click:Connect(function()
                        state = not state
                        Tween(Box, {BackgroundColor3 = state and Theme.Accent or Theme.ElementBg}, 0.15)
                        callback(state)
                    end)
                end

                function GroupBox:AddSlider(text, min, max, default, callback)
                    callback = callback or function() end
                    local val = default or min
                    
                    local SliderFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = ItemsContainer })
                    Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = SliderFrame })
                    
                    local Track = Create("TextButton", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, Text = "", Parent = SliderFrame })
                    local Fill = Create("Frame", { Size = UDim2.new((val-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = Track })
                    local ValBg = Create("Frame", { Size = UDim2.new(0, 30, 0, 14), Position = UDim2.new((val-min)/(max-min), -15, 0, -4), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, Parent = Track })
                    local ValText = Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 11, Parent = ValBg })

                    local dragging = false
                    Track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local pct = math.clamp((Mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                            val = math.floor(min + ((max - min) * pct) * 10) / 10
                            Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                            Tween(ValBg, {Position = UDim2.new(pct, -15, 0, -4)}, 0.05)
                            ValText.Text = tostring(val)
                            callback(val)
                        end
                    end)
                end

                function GroupBox:AddDropdown(text, default)
                    local DropFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = ItemsContainer })
                    Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = DropFrame })
                    local Box = Create("Frame", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, Parent = DropFrame })
                    Create("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = default, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Box })
                end

                function GroupBox:AddButton(text, callback)
                    local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, Text = text, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, Parent = ItemsContainer })
                    Btn.MouseEnter:Connect(function() Tween(Btn, {TextColor3 = Theme.TextWhite}, 0.15) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {TextColor3 = Theme.TextDark}, 0.15) end)
                    Btn.MouseButton1Click:Connect(callback or function() end)
                end

                function GroupBox:AddLabel(text)
                    Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = ItemsContainer })
                end

                function GroupBox:AddListBox(items, activeIndex)
                    local ListFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 180), BackgroundColor3 = Theme.Background, Parent = ItemsContainer })
                    Create("UIStroke", { Parent = ListFrame, Color = Theme.Outline, Thickness = 1 })
                    local ListScroll = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, BorderSizePixel = 0, Parent = ListFrame })
                    local ListLayout = Create("UIListLayout", { Parent = ListScroll, SortOrder = Enum.SortOrder.LayoutOrder })
                    
                    for i, item in ipairs(items) do
                        local isSelected = (i == activeIndex)
                        local slotBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "  " .. item, TextColor3 = isSelected and Theme.Accent or Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = ListScroll })
                        Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = slotBtn })
                        
                        if not isSelected then
                            slotBtn.MouseEnter:Connect(function() Tween(slotBtn, {TextColor3 = Theme.TextHover}, 0.1) end)
                            slotBtn.MouseLeave:Connect(function() Tween(slotBtn, {TextColor3 = Theme.TextDark}, 0.1) end)
                        end
                    end
                end

                return GroupBox
            end
            return SubTab
        end
        return Tab
    end
    return Window
end

return Library
