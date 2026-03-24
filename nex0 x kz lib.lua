local Library = {}
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local Theme = {
    Background = Color3.fromRGB(15, 15, 17), Outline = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(136, 146, 214), TextWhite = Color3.fromRGB(220, 220, 220),
    TextHover = Color3.fromRGB(170, 170, 175), TextDark = Color3.fromRGB(100, 100, 105),
    ElementBg = Color3.fromRGB(20, 20, 22), Font = Enum.Font.RobotoMono
}

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
    local Window = { Tabs = {} }
    if CoreGui:FindFirstChild("Nex0Library") then CoreGui.Nex0Library:Destroy() end
    local ScreenGui = Create("ScreenGui", { Name = "Nex0Library", Parent = CoreGui })
    
    local MainFrame = Create("Frame", { Size = UDim2.new(0, 680, 0, 430), Position = UDim2.new(0.5, -340, 0.5, -215), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = ScreenGui, Active = true, Draggable = true, ClipsDescendants = true })
    Create("UIStroke", { Parent = MainFrame, Color = Theme.Outline, Thickness = 1 })
    
    local TopBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = MainFrame })
    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = TopBar })
    Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 1), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = TopBar })
    Create("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = config.Name or "menu", TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar })

    local Sidebar = Create("Frame", { Size = UDim2.new(0, 140, 1, -27), Position = UDim2.new(0, 0, 0, 27), BackgroundTransparency = 1, Parent = MainFrame })
    Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = Sidebar })
    local ContentArea = Create("Frame", { Size = UDim2.new(1, -141, 1, -27), Position = UDim2.new(0, 141, 0, 27), BackgroundTransparency = 1, Parent = MainFrame })
    local TabsContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, -140), Position = UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1, Parent = Sidebar })

    local currentTab = nil
    function Window:AddTab(name)
        local Tab = { SubTabs = {} }
        local TabBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, #Window.Tabs * 32), BackgroundTransparency = 1, Text = "", Parent = TabsContainer })
        local TabText = Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabBtn })
        local ActiveLine = Create("Frame", { Size = UDim2.new(0, 2, 1, -12), Position = UDim2.new(0, 8, 0, 6), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = TabBtn })
        
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
                        callback(state) 
                    end)
                    task.spawn(function() callback(state) end)
                end

                function GroupBox:AddSlider(text, min, max, default, callback)
                    local val = default or min
                    local SliderFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = ItemsContainer })
                    local InfoText = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = text .. " : " .. tostring(val), TextColor3 = Theme.TextWhite, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = SliderFrame })
                    local Track = Create("TextButton", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0, Text = "", Parent = SliderFrame })
                    local Fill = Create("Frame", { Size = UDim2.new((val-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = Track })
                    
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

                    local SlidersArea = Create("Frame", { Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1, Parent = CPContainer })
                    
                    local function createCSlider(yPos, isH, isS, isV)
                        local Track = Create("TextButton", { Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 0, yPos), BackgroundColor3 = Theme.ElementBg, Text = "", Parent = SlidersArea })
                        local Marker = Create("Frame", { Size = UDim2.new(0, 4, 0, 12), Position = UDim2.new(isH and h or isS and s or v, -2, 0, -2), BackgroundColor3 = Theme.Accent, Parent = Track })
                        local dragging = false
                        Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                        UserInputService.InputChanged:Connect(function(i)
                            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                                local pct = math.clamp((Mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                                Marker.Position = UDim2.new(pct, -2, 0, -2)
                                if isH then h = pct elseif isS then s = pct else v = pct end
                                color = Color3.fromHSV(h, s, v)
                                Preview.BackgroundColor3 = color
                                callback(color)
                            end
                        end)
                    end
                    createCSlider(0, true, false, false); createCSlider(20, false, true, false); createCSlider(40, false, false, true)

                    local open = false
                    TopBtn.MouseButton1Click:Connect(function()
                        open = not open
                        Tween(CPContainer, {Size = UDim2.new(1, 0, 0, open and 85 or 20)}, 0.2)
                    end)
                    task.spawn(function() callback(color) end)
                end

                function GroupBox:AddListBox(items, defaultIdx, callback)
                    local ListBoxFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, #items * 20), BackgroundColor3 = Theme.Background, Parent = ItemsContainer })
                    Create("UIStroke", { Parent = ListBoxFrame, Color = Theme.Outline, Thickness = 1 })
                    local Layout = Create("UIListLayout", { Parent = ListBoxFrame, SortOrder = Enum.SortOrder.LayoutOrder })
                    
                    local buttons = {}
                    for i, item in ipairs(items) do
                        local btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "  " .. item, TextColor3 = (i == defaultIdx) and Theme.Accent or Theme.TextDark, Font = Theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = ListBoxFrame })
                        table.insert(buttons, btn)
                        btn.MouseButton1Click:Connect(function()
                            for _, b in ipairs(buttons) do b.TextColor3 = Theme.TextDark end
                            btn.TextColor3 = Theme.Accent
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
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then ScreenGui.Enabled = not ScreenGui.Enabled end
    end)
    return Window
end

return Library
