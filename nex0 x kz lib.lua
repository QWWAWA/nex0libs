local Library = {}
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Mouse = Players.LocalPlayer:GetMouse()

local Theme = {
    Background = Color3.fromRGB(15, 15, 17), Outline = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(136, 146, 214), TextWhite = Color3.fromRGB(220, 220, 220),
    TextHover = Color3.fromRGB(170, 170, 175), TextDark = Color3.fromRGB(100, 100, 105),
    ElementBg = Color3.fromRGB(20, 20, 22), Font = Enum.Font.RobotoMono
}

-- Таблица для хранения элементов, которые должны менять цвет при смене темы
local ColoredElements = { Backgrounds = {}, Texts = {} }

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do inst[k] = v end
    return inst
end

local function Tween(instance, properties, duration)
    TweenService:Create(instance, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

-- Система уведомлений
if CoreGui:FindFirstChild("Nex0NotifyGui") then CoreGui.Nex0NotifyGui:Destroy() end
local NotifyGui = Create("ScreenGui", { Name = "Nex0NotifyGui", Parent = CoreGui })
local NotifyContainer = Create("Frame", { Size = UDim2.new(0, 220, 1, -40), Position = UDim2.new(1, -240, 0, 20), BackgroundTransparency = 1, Parent = NotifyGui })
Create("UIListLayout", { Parent = NotifyContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom })

function Library:Notify(text, duration)
    task.spawn(function()
        duration = duration or 3
        local Notif = Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Background, BackgroundTransparency = 1, Parent = NotifyContainer })
        local Stroke = Create("UIStroke", { Parent = Notif, Color = Theme.Outline, Thickness = 1, Transparency = 1 })
        local Line = Create("Frame", { Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = Notif, BackgroundTransparency = 1 })
        table.insert(ColoredElements.Backgrounds, Line) -- Добавляем в регистр для смены темы
        
        local Label = Create("TextLabel", { Size = UDim2.new(1, -15, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Notif, TextTransparency = 1 })
        
        Tween(Notif, {BackgroundTransparency = 0}, 0.3); Tween(Stroke, {Transparency = 0}, 0.3)
        Tween(Line, {BackgroundTransparency = 0}, 0.3); Tween(Label, {TextTransparency = 0}, 0.3)
        
        task.wait(duration)
        Tween(Notif, {BackgroundTransparency = 1}, 0.3); Tween(Stroke, {Transparency = 1}, 0.3)
        Tween(Line, {BackgroundTransparency = 1}, 0.3); Tween(Label, {TextTransparency = 1}, 0.3)
        task.wait(0.3); Notif:Destroy()
    end)
end

function Library:CreateWindow(config)
    local Window = { Tabs = {}, ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift }
    config.Name = config.Name or "menu"
    config.LogoText = config.LogoText or "a m n e s i a"
    config.LogoImage = config.LogoImage or "https://i.ibb.co/v6zxWBhw/edited-photo.png"
    config.ShowLoading = config.ShowLoading ~= false -- Включено по умолчанию
    
    if config.Theme then
        for k, v in pairs(config.Theme) do Theme[k] = v end
    end

    if CoreGui:FindFirstChild("Nex0Library") then CoreGui.Nex0Library:Destroy() end
    local ScreenGui = Create("ScreenGui", { Name = "Nex0Library", Parent = CoreGui, IgnoreGuiInset = true, Enabled = false })
    
    -- === ЭКРАН ЗАГРУЗКИ ===
    if config.ShowLoading then
        local LoadGui = Create("ScreenGui", { Name = "Nex0LoadGui", Parent = CoreGui, IgnoreGuiInset = true })
        local Overlay = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, Parent = LoadGui })
        local LoadBox = Create("Frame", { Size = UDim2.new(0, 300, 0, 100), Position = UDim2.new(0.5, -150, 0.5, -50), BackgroundColor3 = Theme.Background, BackgroundTransparency = 1, Parent = LoadGui })
        local LoadStroke = Create("UIStroke", { Parent = LoadBox, Color = Theme.Outline, Thickness = 1, Transparency = 1 })
        
        local LoadText = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1, Text = "loading: 0%", TextColor3 = Theme.Accent, Font = Theme.Font, TextSize = 14, TextTransparency = 1, Parent = LoadBox })
        
        -- Прогресс бар
        local BarBg = Create("Frame", { Size = UDim2.new(1, -40, 0, 6), Position = UDim2.new(0, 20, 0, 60), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = LoadBox })
        local BarFill = Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = BarBg })
        
        -- Спиннер
        local Spinner = Create("ImageLabel", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 20, 1, -25), BackgroundTransparency = 1, Image = "rbxassetid://10008518402", ImageColor3 = Theme.Accent, ImageTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Parent = LoadBox })
        Spinner.Position = UDim2.new(0, 30, 0, 25) -- Перенос спиннера влево к тексту

        -- Анимация появления
        Tween(Overlay, {BackgroundTransparency = 0.4}, 0.5)
        Tween(LoadBox, {BackgroundTransparency = 0}, 0.5); Tween(LoadStroke, {Transparency = 0}, 0.5)
        Tween(LoadText, {TextTransparency = 0}, 0.5); Tween(BarBg, {BackgroundTransparency = 0}, 0.5); Tween(BarFill, {BackgroundTransparency = 0}, 0.5)
        Tween(Spinner, {ImageTransparency = 0}, 0.5)
        task.wait(0.5)

        -- Логика загрузки (Плавный фейк + ожидание ContentProvider)
        local spinConn = RunService.RenderStepped:Connect(function(dt)
            Spinner.Rotation = Spinner.Rotation + (dt * 300)
        end)

        local progress = 0
        while progress < 100 do
            local queue = ContentProvider.RequestQueueSize
            local jump = math.random(1, 5)
            if queue > 0 then jump = jump * 0.5 end -- Замедляем, если игра еще грузится
            
            progress = math.clamp(progress + jump, 0, 100)
            LoadText.Text = "loading: " .. tostring(math.floor(progress)) .. "%"
            Tween(BarFill, {Size = UDim2.new(progress/100, 0, 1, 0)}, 0.1)
            task.wait(0.05)
        end
        LoadText.Text = "loading: complete!"
        task.wait(0.5)

        -- Исчезновение загрузки
        spinConn:Disconnect()
        Tween(Overlay, {BackgroundTransparency = 1}, 0.5)
        Tween(LoadBox, {BackgroundTransparency = 1}, 0.5); Tween(LoadStroke, {Transparency = 1}, 0.5)
        Tween(LoadText, {TextTransparency = 1}, 0.5); Tween(BarBg, {BackgroundTransparency = 1}, 0.5); Tween(BarFill, {BackgroundTransparency = 1}, 0.5)
        Tween(Spinner, {ImageTransparency = 1}, 0.5)
        task.wait(0.5)
        LoadGui:Destroy()
    end

    ScreenGui.Enabled = true -- Показываем главное меню

    -- === ОСНОВНОЕ МЕНЮ ===
    local MainFrame = Create("Frame", { Size = UDim2.new(0, 680, 0, 430), Position = UDim2.new(0.5, -340, 0.5, -215), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = ScreenGui, Active = true, Draggable = true, ClipsDescendants = true })
    Create("UIStroke", { Parent = MainFrame, Color = Theme.Outline, Thickness = 1 })
    
    local TopBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = MainFrame })
    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = TopBar })
    
    local TopLine = Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = TopBar })
    table.insert(ColoredElements.Backgrounds, TopLine)

    Create("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = config.Name, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar })
    Create("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, -10, 0, 0), BackgroundTransparency = 1, Text = os.date("%A, %d %b %Y"):lower(), TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = TopBar })

    local Sidebar = Create("Frame", { Size = UDim2.new(0, 140, 1, -27), Position = UDim2.new(0, 0, 0, 27), BackgroundTransparency = 1, Parent = MainFrame })
    Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = Sidebar })
    local ContentArea = Create("Frame", { Size = UDim2.new(1, -141, 1, -27), Position = UDim2.new(0, 141, 0, 27), BackgroundTransparency = 1, Parent = MainFrame })
    local TabsContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, -140), Position = UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1, Parent = Sidebar })

    local LogoFrame = Create("Frame", { Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0, 10, 1, -130), BackgroundColor3 = Theme.Background, Parent = Sidebar })
    Create("UIStroke", { Parent = LogoFrame, Color = Theme.Outline, Thickness = 1 })
    
    local LogoTextLabel = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -25), BackgroundTransparency = 1, Text = config.LogoText, TextColor3 = Theme.Accent, Font = Theme.Font, TextSize = 13, Parent = LogoFrame })
    table.insert(ColoredElements.Texts, LogoTextLabel)

    local LogoImage = Create("ImageLabel", { Size = UDim2.new(0, 75, 0, 75), Position = UDim2.new(0.5, -37.5, 0, 12), BackgroundTransparency = 1, ImageColor3 = Color3.fromRGB(255, 255, 255), ScaleType = Enum.ScaleType.Fit, Parent = LogoFrame })
    task.spawn(function()
        local s, d = pcall(function() return game:HttpGet(config.LogoImage) end)
        if s and d then pcall(function() writefile("nex0_logo_custom.png", d) LogoImage.Image = getcustomasset("nex0_logo_custom.png") end) end
    end)

    -- ФУНКЦИЯ ДЛЯ СМЕНЫ ТЕМЫ
    function Window:SetAccentColor(newColor)
        Theme.Accent = newColor
        for _, elem in pairs(ColoredElements.Backgrounds) do elem.BackgroundColor3 = newColor end
        for _, elem in pairs(ColoredElements.Texts) do elem.TextColor3 = newColor end
    end

    function Window:SetToggleKey(key)
        Window.ToggleKey = key
    end

    local currentTab = nil
    function Window:AddTab(name)
        local Tab = { SubTabs = {} }
        local TabBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, #Window.Tabs * 32), BackgroundTransparency = 1, Text = "", Parent = TabsContainer })
        local TabText = Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabBtn })
        local ActiveLine = Create("Frame", { Size = UDim2.new(0, 2, 1, -12), Position = UDim2.new(0, 8, 0, 6), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = TabBtn })
        table.insert(ColoredElements.Backgrounds, ActiveLine)

        local TabContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentArea })
        local SubTabsContainer = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = TabContainer })
        Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = SubTabsContainer })
        local GroupboxesContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Parent = TabContainer })

        TabBtn.MouseButton1Click:Connect(function()
            if currentTab then Tween(currentTab.Text, {TextColor3 = Theme.TextDark}, 0.2); Tween(currentTab.Line, {BackgroundTransparency = 1}, 0.2); currentTab.Container.Visible = false end
            currentTab = { Btn = TabBtn, Text = TabText, Line = ActiveLine, Container = TabContainer }
            Tween(TabText, {TextColor3 = Theme.TextWhite}, 0.2); Tween(ActiveLine, {BackgroundTransparency = 0}, 0.2); TabContainer.Visible = true
        end)
        if #Window.Tabs == 0 then TabText.TextColor3 = Theme.TextWhite; ActiveLine.BackgroundTransparency = 0; TabContainer.Visible = true; currentTab = { Btn = TabBtn, Text = TabText, Line = ActiveLine, Container = TabContainer } end
        table.insert(Window.Tabs, Tab)

        local currentSubTab = nil
        function Tab:AddSubTab(subName)
            local SubTab = {}
            local STabBtn = Create("TextButton", { Size = UDim2.new(1/3, 0, 1, 0), Position = UDim2.new((1/3) * #Tab.SubTabs, 0, 0, 0), BackgroundTransparency = 1, Text = subName, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, Parent = SubTabsContainer })
            local SActiveLine = Create("Frame", { Size = UDim2.new(0.6, 0, 0, 2), Position = UDim2.new(0.2, 0, 1, -1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = STabBtn })
            table.insert(ColoredElements.Backgrounds, SActiveLine)
            
            local STabContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = GroupboxesContainer })

            STabBtn.MouseButton1Click:Connect(function()
                if currentSubTab then Tween(currentSubTab.Btn, {TextColor3 = Theme.TextDark}, 0.2); Tween(currentSubTab.Line, {BackgroundTransparency = 1}, 0.2); currentSubTab.Container.Visible = false end
                currentSubTab = { Btn = STabBtn, Line = SActiveLine, Container = STabContainer }
                Tween(STabBtn, {TextColor3 = Theme.TextWhite}, 0.2); Tween(SActiveLine, {BackgroundTransparency = 0}, 0.2); STabContainer.Visible = true
            end)
            if #Tab.SubTabs == 0 then STabBtn.TextColor3 = Theme.TextWhite; SActiveLine.BackgroundTransparency = 0; STabContainer.Visible = true; currentSubTab = { Btn = STabBtn, Line = SActiveLine, Container = STabContainer } end
            table.insert(Tab.SubTabs, SubTab)

            function SubTab:AddGroupBox(gbName, side)
                local GroupBox = {}
                local gbPos = side == "Left" and UDim2.new(0, 15, 0, 20) or UDim2.new(0.5, 5, 0, 20)
                local GBFrame = Create("Frame", { Size = UDim2.new(0.5, -20, 1, -40), Position = gbPos, BackgroundTransparency = 1, Parent = STabContainer })
                Create("UIStroke", { Parent = GBFrame, Color = Theme.Outline, Thickness = 1 })
                local TitleBg = Create("Frame", { Size = UDim2.new(0, string.len(gbName)*8, 0, 10), Position = UDim2.new(0.5, -(string.len(gbName)*4), 0, -5), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = GBFrame })
                Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = gbName, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, Parent = TitleBg })

                local ItemsContainer = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = GBFrame })
                Create("UIListLayout", { Parent = ItemsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
                Create("UIPadding", { Parent = ItemsContainer, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15) })

                function GroupBox:AddToggle(text, default, callback)
                    local state = default or false
                    local ToggleFrame = Create("TextButton", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = "", Parent = ItemsContainer })
                    local Box = Create("Frame", { Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0, 0, 0, 2), BackgroundColor3 = state and Theme.Accent or Theme.ElementBg, BorderSizePixel = 0, Parent = ToggleFrame })
                    Create("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleFrame })
                    
                    ToggleFrame.MouseButton1Click:Connect(function() 
                        state = not state 
                        Tween(Box, {BackgroundColor3 = state and Theme.Accent or Theme.ElementBg}, 0.15)
                        if state then table.insert(ColoredElements.Backgrounds, Box) else 
                            for i, v in ipairs(ColoredElements.Backgrounds) do if v == Box then table.remove(ColoredElements.Backgrounds, i) end end 
                        end
                        callback(state) 
                    end)
                    if state then table.insert(ColoredElements.Backgrounds, Box) end
                    task.spawn(function() callback(state) end)
                end

                function GroupBox:AddSlider(text, min, max, default, callback)
                    local val = default or min
                    local SliderFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = ItemsContainer })
                    local InfoText = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = text .. " : " .. tostring(val), TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = SliderFrame })
                    local Track = Create("TextButton", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, Text = "", Parent = SliderFrame })
                    local Fill = Create("Frame", { Size = UDim2.new((val-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = Track })
                    table.insert(ColoredElements.Backgrounds, Fill)

                    local dragging = false
                    Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                    UserInputService.InputChanged:Connect(function(i)
                        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                            local pct = math.clamp((Mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                            val = math.floor(min + ((max - min) * pct))
                            Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                            InfoText.Text = text .. " : " .. tostring(val)
                            callback(val)
                        end
                    end)
                    task.spawn(function() callback(val) end)
                end

                function GroupBox:AddColorPicker(text, defaultColor, callback)
                    local color = defaultColor or Color3.fromRGB(255, 255, 255)
                    local h, s, v = Color3.toHSV(color)
                    
                    local CPContainer = Create("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = ItemsContainer, ClipsDescendants = true })
                    local TopBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "", Parent = CPContainer })
                    Create("TextLabel", { Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBtn })
                    local Preview = Create("Frame", { Size = UDim2.new(0, 24, 0, 12), Position = UDim2.new(1, -24, 0, 4), BackgroundColor3 = color, Parent = TopBtn })
                    Create("UIStroke", { Parent = Preview, Color = Theme.Outline, Thickness = 1 })

                    local PickerArea = Create("Frame", { Size = UDim2.new(1, 0, 0, 80), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1, Parent = CPContainer })
                    
                    local SVBox = Create("TextButton", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromHSV(h, 1, 1), Text = "", AutoButtonColor = false, Parent = PickerArea })
                    Create("UIStroke", { Parent = SVBox, Color = Theme.Outline, Thickness = 1 })
                    local WhiteGrad = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = SVBox })
                    Create("UIGradient", { Parent = WhiteGrad, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}) }) 
                    local BlackGrad = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = SVBox })
                    Create("UIGradient", { Parent = BlackGrad, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))}), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}) }) 
                    
                    local SVCursor = Create("Frame", { Size = UDim2.new(0, 4, 0, 4), BackgroundColor3 = Color3.new(1,1,1), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(s, 0, 1-v, 0), Parent = SVBox })
                    Create("UIStroke", { Parent = SVCursor, Color = Color3.new(0,0,0), Thickness = 1 })
                    Create("UICorner", { Parent = SVCursor, CornerRadius = UDim.new(1, 0) })

                    local HueBox = Create("TextButton", { Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(1, -12, 0, 0), BackgroundColor3 = Color3.new(1,1,1), Text = "", AutoButtonColor = false, Parent = PickerArea })
                    Create("UIStroke", { Parent = HueBox, Color = Theme.Outline, Thickness = 1 })
                    Create("UIGradient", { Parent = HueBox, Rotation = 90, Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.166, Color3.new(1,1,0)),
                        ColorSequenceKeypoint.new(0.333, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
                        ColorSequenceKeypoint.new(0.666, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.833, Color3.new(1,0,1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
                    })})
                    local HueCursor = Create("Frame", { Size = UDim2.new(1, 2, 0, 2), Position = UDim2.new(0, -1, h, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = HueBox })
                    Create("UIStroke", { Parent = HueCursor, Color = Color3.new(0,0,0), Thickness = 1 })

                    local function UpdateColor()
                        color = Color3.fromHSV(h, s, v)
                        Preview.BackgroundColor3 = color
                        SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        SVCursor.Position = UDim2.new(s, 0, 1-v, 0)
                        HueCursor.Position = UDim2.new(0, -1, h, 0)
                        callback(color)
                    end

                    local draggingSV, draggingHue = false, false
                    SVBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true; s = math.clamp((Mouse.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1); v = 1 - math.clamp((Mouse.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1); UpdateColor() end end)
                    HueBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true; h = math.clamp((Mouse.Y - HueBox.AbsolutePosition.Y) / HueBox.AbsoluteSize.Y, 0, 1); UpdateColor() end end)
                    
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false; draggingHue = false end end)
                    UserInputService.InputChanged:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement then
                            if draggingSV then s = math.clamp((Mouse.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1); v = 1 - math.clamp((Mouse.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1); UpdateColor() end
                            if draggingHue then h = math.clamp((Mouse.Y - HueBox.AbsolutePosition.Y) / HueBox.AbsoluteSize.Y, 0, 1); UpdateColor() end
                        end
                    end)

                    local open = false
                    TopBtn.MouseButton1Click:Connect(function()
                        open = not open
                        Tween(CPContainer, {Size = UDim2.new(1, 0, 0, open and 110 or 20)}, 0.2)
                    end)
                    task.spawn(function() UpdateColor() end)
                end

                function GroupBox:AddListBox(items, defaultIdx, callback)
                    local ListBoxFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, #items * 20), BackgroundColor3 = Theme.Background, Parent = ItemsContainer })
                    Create("UIStroke", { Parent = ListBoxFrame, Color = Theme.Outline, Thickness = 1 })
                    local Layout = Create("UIListLayout", { Parent = ListBoxFrame, SortOrder = Enum.SortOrder.LayoutOrder })
                    
                    local buttons = {}
                    local currentActiveText = nil
                    for i, item in ipairs(items) do
                        local btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "  " .. item, TextColor3 = (i == defaultIdx) and Theme.Accent or Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = ListBoxFrame })
                        table.insert(buttons, btn)
                        if i == defaultIdx then currentActiveText = btn; table.insert(ColoredElements.Texts, btn) end

                        btn.MouseButton1Click:Connect(function()
                            for _, b in ipairs(buttons) do 
                                b.TextColor3 = Theme.TextDark 
                                -- Удаляем старые тексты из регистра цветов
                                for idx, v in ipairs(ColoredElements.Texts) do if v == b then table.remove(ColoredElements.Texts, idx) end end
                            end
                            btn.TextColor3 = Theme.Accent
                            table.insert(ColoredElements.Texts, btn)
                            callback(item)
                        end)
                    end
                    task.spawn(function() callback(items[defaultIdx]) end)
                end

                return GroupBox
            end
            return SubTab
        end
        return Tab
    end
    
    -- 100% Рабочее скрытие окна (не работает, если игрок пишет в чат)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Window.ToggleKey then 
            ScreenGui.Enabled = not ScreenGui.Enabled 
        end
    end)

    return Window
end

return Library
