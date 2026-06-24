--[[
    nex0libs / gamesense.lua
    skeet.cc-style UI library for Roblox (loadstring-ready)

    Load:
        local Library = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/QWWAWA/nex0libs/refs/heads/main/gamesense.lua"
        ))()

    Features:
      * Skeet-style window, dark theme, accent color, sidebar with URL icons
      * Tab icons loaded from the web (icons8 etc.) with customizable tint color
      * Built-in asset loader (download -> writefile -> getcustomasset)
      * Standard cheat tabs (Combat / Visuals / Movement / Misc / Config)
      * Toggle, Slider, Dropdown, Multi-select, ColorPicker, Keybind, Button, Label
      * Keybind for a function: MIDDLE-CLICK the toggle's switch to bind a key
      * Notifications (top-right, sliding), watermark, config save/load
]]

--==========================================================================
-- Services & environment shims
--==========================================================================
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- safe parent for the ScreenGui
local _gethui = gethui -- capture executor global before local shadows it
local function resolveGuiParent()
    if _gethui then return _gethui() end
    if syn and syn.protect_gui then return CoreGui end
    local ok = pcall(function() return CoreGui.Name end)
    return ok and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

-- HTTP request resolver (works across most executors)
local function httpRequest(url)
    local r = request or http_request or (syn and syn.request) or (http and http.request)
    if not r then return nil, "no http" end
    local ok, res = pcall(r, { Url = url, Method = "GET" })
    if not ok or not res then return nil, "request failed" end
    return res.Body, res.StatusCode or (res.Success and 200)
end

local function jsonEncode(t)
    local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
    if ok then return s end
end
local function jsonDecode(s)
    local ok, t = pcall(function() return HttpService:JSONDecode(s) end)
    if ok then return t end
end

--==========================================================================
-- Theme
--==========================================================================
local Theme = {
    Background = Color3.fromRGB(30, 30, 32),
    Sidebar    = Color3.fromRGB(24, 24, 26),
    Topbar     = Color3.fromRGB(22, 22, 24),
    Section    = Color3.fromRGB(36, 36, 40),
    Element    = Color3.fromRGB(46, 46, 52),
    ElementHi  = Color3.fromRGB(58, 58, 66),
    Text       = Color3.fromRGB(232, 232, 236),
    TextDim    = Color3.fromRGB(140, 140, 150),
    Stroke     = Color3.fromRGB(52, 52, 58),
    Accent     = Color3.fromRGB(95, 168, 211), -- skeet blue
    Good       = Color3.fromRGB(96, 200, 120),
    Bad        = Color3.fromRGB(220, 90, 90),
    Font       = Enum.Font.Code,
    FontBold   = Enum.Font.GothamBold,
}

--==========================================================================
-- Small instance helpers
--==========================================================================
local function make(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(inst, r) make("UICorner", { CornerRadius = UDim.new(0, r or 4), Parent = inst }) end
local function stroke(inst, col, th) make("UIStroke", { Color = col or Theme.Stroke, Thickness = th or 1, Transparency = 0.1, Parent = inst }) end
local function pad(inst, all) make("UIPadding", {
    PaddingTop = UDim.new(0, all), PaddingBottom = UDim.new(0, all),
    PaddingLeft = UDim.new(0, all), PaddingRight = UDim.new(0, all), Parent = inst }) end
local function layout(inst, dir, gap, align)
    make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap or 6),
        FillDirection = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = align or Enum.HorizontalAlignment.Center, Parent = inst })
end
local function tween(inst, time, props)
    local t = TweenService:Create(inst, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play() return t
end

--==========================================================================
-- Asset loader  (download url -> file -> custom asset id)
--==========================================================================
local AssetLoader = { _n = 0, cache = {}, queue = {}, loading = {} }

function AssetLoader._resolve()
    local get = getcustomasset or getsynasset or get_customasset
    return get
end

-- synchronous load (blocks the thread until done; ok for short icons)
function AssetLoader.load(url)
    if not url or url == "" then return nil end
    if AssetLoader.cache[url] then return AssetLoader.cache[url] end
    local body = httpRequest(url)
    if not body or #body < 64 then return nil end
    local get = AssetLoader._resolve()
    if not get then return nil end
    AssetLoader._n = AssetLoader._n + 1
    local ext = url:lower():find("%.png") and ".png" or (url:lower():find("%.jpg") and ".jpg" or ".png")
    local fname = ("nex0_asset_%d%s"):format(AssetLoader._n, ext)
    local ok = pcall(function() writefile(fname, body) end)
    if not ok then return nil end
    local id
    local pok = pcall(function() id = get(fname) end)
    if not pok or not id then return nil end
    AssetLoader.cache[url] = id
    return id
end

-- async load: applies the resulting image to any number of ImageLabels
function AssetLoader.applyAsync(url, callback)
    if not url or url == "" then return end
    if AssetLoader.cache[url] then callback(AssetLoader.cache[url]); return end
    if AssetLoader.loading[url] then table.insert(AssetLoader.loading[url], callback); return end
    AssetLoader.loading[url] = { callback }
    task.spawn(function()
        local id = AssetLoader.load(url)
        for _, cb in ipairs(AssetLoader.loading[url] or {}) do
            local ok = pcall(cb, id)
        end
        AssetLoader.loading[url] = nil
    end)
end

--==========================================================================
-- Notifications
--==========================================================================
local NotificationManager = {}
function NotificationManager.build(parent)
    local holder = make("Frame", {
        Name = "Notifications", Parent = parent,
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.new(0, 280, 1, -24), BackgroundTransparency = 1,
    })
    layout(holder, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Right)
    make("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Top, Parent = holder })
        .SortOrder = Enum.SortOrder.LayoutOrder
    NotificationManager.holder = holder
    return holder
end

function NotificationManager.notify(cfg)
    local holder = NotificationManager.holder
    if not holder then return end
    cfg = cfg or {}
    local title = cfg.Title or "skeet"
    local desc  = cfg.Description or ""
    local dur   = cfg.Duration or 4

    local card = make("Frame", {
        Parent = holder, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Section, BorderSizePixel = 0,
    })
    corner(card, 6) stroke(card, Theme.Stroke, 1)

    local bar = make("Frame", {
        Parent = card, Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = cfg.Color or Theme.Accent, BorderSizePixel = 0,
    })
    corner(bar, 2)

    local content = make("Frame", {
        Parent = card, Size = UDim2.new(1, -14, 0, 0), Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
    })
    layout(content, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left)

    make("TextLabel", {
        Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
        Font = Theme.FontBold, Text = title, TextColor3 = Theme.Text,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    })
    if desc ~= "" then
        make("TextLabel", {
            Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.Y,
            Font = Theme.Font, Text = desc, TextColor3 = Theme.TextDim,
            TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        })
    end

    -- initial state for slide-in
    card.Position = UDim2.new(1, 30, 0, 0)
    card.BackgroundTransparency = 1
    bar.BackgroundTransparency = 1
    task.wait()
    card.Size = UDim2.new(1, 0, 0, 0) -- keep auto height
    tween(card, 0.18, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0 })
    tween(bar, 0.18, { BackgroundTransparency = 0 })

    task.delay(dur, function()
        tween(card, 0.25, { Position = UDim2.new(1, 30, 0, 0), BackgroundTransparency = 1 })
        task.wait(0.27)
        card:Destroy()
    end)
end

--==========================================================================
-- Library
--==========================================================================
local Library = {
    Theme = Theme,
    AssetLoader = AssetLoader,
    Notify = function(cfg) NotificationManager.notify(cfg) end,
    _accentBindings = {}, -- things that react to accent changes
    _keybinds = {},       -- registered key actions
}

function Library.SetAccent(color)
    Theme.Accent = color
    for _, fn in ipairs(Library._accentBindings) do fn(color) end
end

--==========================================================================
-- Window
--==========================================================================
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local size = cfg.Size or Vector2.new(640, 420)
    local accent = cfg.Accent or Theme.Accent
    Theme.Accent = accent

    local gui = make("ScreenGui", {
        Name = "nex0_" .. (cfg.Name or "skeet"),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, Parent = resolveGuiParent(),
    })
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end

    local root = make("Frame", {
        Name = "Window", Parent = gui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, cfg.PositionX or 0, 0.5, cfg.PositionY or 0),
        Size = UDim2.new(0, size.X, 0, size.Y),
        BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
        Active = true,
    })
    corner(root, 8) stroke(root, Theme.Stroke, 1)

    -- top bar
    local topbar = make("Frame", {
        Name = "TopBar", Parent = root,
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Topbar, BorderSizePixel = 0,
    })
    -- round only top corners
    make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = topbar })
    make("Frame", { Parent = topbar, Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0 })

    make("TextLabel", {
        Name = "Title", Parent = topbar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 200, 1, 0),
        Font = Theme.FontBold, Text = cfg.Title or "skeet",
        TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- top right controls
    local controls = make("Frame", {
        Parent = topbar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 18), BackgroundTransparency = 1,
    })
    layout(controls, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Right)

    local function topBtn(text, onClick)
        local b = make("TextButton", {
            Parent = controls, Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Theme.Element,
            Text = text, Font = Theme.FontBold, TextSize = 10, TextColor3 = Theme.TextDim, BorderSizePixel = 0,
        })
        corner(b, 4)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = Theme.ElementHi }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = Theme.Element }) end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end
    topBtn("-", function() root.Visible = false; task.delay(0.2, function() NotificationManager.notify({Title="skeet", Description="Hidden. Press RightShift to toggle.", Duration=3}) end) end)
    topBtn("X", function() gui:Destroy() end)

    -- body
    local body = make("Frame", {
        Name = "Body", Parent = root,
        Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 1, -32),
        BackgroundTransparency = 1,
    })

    -- sidebar
    local sidebar = make("Frame", {
        Name = "Sidebar", Parent = body,
        Size = UDim2.new(0, 96, 1, 0), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0,
    })
    local sidebarList = make("Frame", {
        Name = "List", Parent = sidebar,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -12, 1, -12), BackgroundTransparency = 1,
    })
    layout(sidebarList, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)

    -- content area (right of sidebar)
    local contentArea = make("Frame", {
        Name = "Content", Parent = body,
        Position = UDim2.new(0, 96, 0, 0), Size = UDim2.new(1, -96, 1, 0), BackgroundTransparency = 1,
    })
    pad(contentArea, 10)

    -- drag
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = root.Position
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- watermark
    if cfg.Watermark ~= false then
        local wm = make("TextLabel", {
            Name = "Watermark", Parent = gui,
            AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(0, 0, 0, 22), BackgroundColor3 = Theme.Section, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
            Font = Theme.Font, Text = "  skeet.cc  ", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        })
        corner(wm, 4) stroke(wm, Theme.Stroke, 1)
        local wmAccent = make("Frame", { Parent = wm, Size = UDim2.new(0, 3, 1, -4), Position = UDim2.new(0, 0, 0, 2), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0 })
        corner(wmAccent, 2)
        table.insert(Library._accentBindings, function(c) wmAccent.BackgroundColor3 = c end)
        local fps, frames, t0 = 0, 0, tick()
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
            if tick() - t0 >= 1 then fps = frames; frames = 0; t0 = tick() end
            local ping = LocalPlayer:GetNetworkPing and math.floor(LocalPlayer:GetNetworkPing() * 1000) or 0
            wm.Text = ("  skeet.cc | %d fps | %dms  "):format(fps, ping)
        end)
    end

    NotificationManager.build(gui)

    -- RightShift toggles window
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            root.Visible = not root.Visible
        end
    end)

    local Window = { _gui = gui, _root = root, _tabs = {}, _sidebar = sidebarList, _content = contentArea, selected = nil }

    --======================================================================
    -- Tab
    --======================================================================
    function Window:CreateTab(tcfg)
        tcfg = tcfg or {}
        local tab = {
            name = tcfg.Name or "Tab",
            icon = tcfg.Icon,
            iconColor = tcfg.IconColor,
            sections = { Left = {}, Right = {} },
        }

        -- sidebar button (icon + label)
        local btn = make("TextButton", {
            Parent = self._sidebar, Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false,
        })
        local indicator = make("Frame", {
            Parent = btn, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 2, 0, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
        })
        corner(indicator, 1)
        local iconColor = tab.iconColor or Theme.TextDim
        local icon = make("ImageLabel", {
            Parent = btn, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6),
            Size = UDim2.new(0, 26, 0, 26), BackgroundTransparency = 1, Image = "",
            ImageColor3 = iconColor, ImageTransparency = 0.4,
        })
        -- load icon asynchronously
        if tab.icon then
            AssetLoader.applyAsync(tab.icon, function(id) if id then icon.Image = id end end)
        end
        local label = make("TextLabel", {
            Parent = btn, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, -16),
            Size = UDim2.new(1, -4, 0, 12), BackgroundTransparency = 1,
            Font = Theme.Font, Text = tab.name, TextColor3 = Theme.TextDim, TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        -- tab page
        local page = make("Frame", {
            Name = tab.name .. "_Page", Parent = self._content,
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
        })
        -- two columns
        local colL = make("ScrollingFrame", {
            Name = "Left", Parent = page, Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -5, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Stroke, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        })
        local colR = make("ScrollingFrame", {
            Name = "Right", Parent = page, Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0.5, -5, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Stroke, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        })
        for _, col in ipairs({colL, colR}) do layout(col, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Full) end

        function tab.select()
            for _, t in ipairs(self._tabs) do
                t.page.Visible = false
                tween(t.indicator, 0.15, { Size = UDim2.new(0, 2, 0, 0) })
                tween(t.icon, 0.15, { ImageTransparency = 0.4, ImageColor3 = t.iconColor or Theme.TextDim })
                tween(t.label, 0.15, { TextColor3 = Theme.TextDim })
            end
            page.Visible = true
            tween(indicator, 0.15, { Size = UDim2.new(0, 2, 0, 28) })
            tween(icon, 0.15, { ImageTransparency = 0, ImageColor3 = tab.iconColor or Theme.Accent })
            tween(label, 0.15, { TextColor3 = Theme.Text })
            self.selected = tab
        end

        btn.MouseButton1Click:Connect(function() tab.select() end)

        -- section creation
        local tabObj = { name = tab.name, page = page, columns = { Left = colL, Right = colR } }

        function tabObj:CreateSection(name, side)
            return Library._newSection(self, name, side or "Left")
        end

        tab.indicator = indicator
        tab.icon = icon
        tab.label = label
        tab.page = page
        table.insert(self._tabs, setmetatable(tab, { __index = tabObj }))

        if #self._tabs == 1 then tab.select() end
        return setmetatable(tab, { __index = tabObj })
    end

    -- notifications proxy
    function Window:Notify(cfg) NotificationManager.notify(cfg) end

    -- config save/load
    function Window:SaveConfig(name)
        local data = {}
        for _, t in ipairs(self._tabs) do
            for side, sections in pairs(t.sections) do
                for _, sec in ipairs(sections) do
                    for _, item in ipairs(sec.items) do
                        if item.flag and item.GetValue then
                            local v = item:GetValue()
                            data[item.flag] = (typeof(v) == "Color3") and {v.R,v.G,v.B} or v
                        end
                    end
                end
            end
        end
        local s = jsonEncode(data)
        if s then pcall(function() writefile("nex0_config_" .. name .. ".json", s) end)
            NotificationManager.notify({Title="Config", Description="Saved '"..name.."'", Duration=3}) end
    end
    function Window:LoadConfig(name)
        local s
        pcall(function() s = readfile("nex0_config_" .. name .. ".json") end)
        if not s then return end
        local data = jsonDecode(s) or {}
        for _, t in ipairs(self._tabs) do
            for side, sections in pairs(t.sections) do
                for _, sec in ipairs(sections) do
                    for _, item in ipairs(sec.items) do
                        if item.flag and data[item.flag] ~= nil and item.SetValue then
                            item:SetValue(item._isColor and Color3.new(table.unpack(data[item.flag])) or data[item.flag])
                        end
                    end
                end
            end
        end
        NotificationManager.notify({Title="Config", Description="Loaded '"..name.."'", Duration=3})
    end

    Library._window = Window
    return Window
end

--==========================================================================
-- Section
--==========================================================================
function Library._newSection(tab, name, side)
    local col = tab.columns[side] or tab.columns.Left
    local sec = make("Frame", {
        Name = name, Parent = col, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Section, BorderSizePixel = 0,
    })
    corner(sec, 6) stroke(sec, Theme.Stroke, 1)

    local header = make("Frame", {
        Parent = sec, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Element, BorderSizePixel = 0,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = header })
    make("Frame", { Parent = header, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0 })
    make("TextLabel", {
        Parent = header, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -16, 1, 0),
        Font = Theme.FontBold, Text = name, TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    })

    local list = make("Frame", {
        Parent = sec, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 1, -28), BackgroundTransparency = 1,
    })
    pad(list, 8)
    layout(list, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Full)

    local sectionObj = { frame = sec, list = list, items = {}, tab = tab }
    if not tab.sections[side] then tab.sections[side] = {} end
    table.insert(tab.sections[side], sectionObj)

    -- item factories
    function sectionObj:AddLabel(text)
        local lbl = make("TextLabel", {
            Parent = list, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Font = Theme.Font, Text = text, TextColor3 = Theme.TextDim, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local o = { flag = nil, type = "Label", label = lbl }
        function o:Set(t) lbl.Text = t end
        table.insert(self.items, o); return o
    end

    function sectionObj:AddButton(text, onClick)
        local b = make("TextButton", {
            Parent = list, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Theme.Element,
            Text = text, Font = Theme.FontBold, TextColor3 = Theme.Text, TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0,
        })
        corner(b, 4)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = Theme.Accent }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = Theme.Element }) end)
        b.MouseButton1Click:Connect(function() if onClick then onClick() end end)
        local o = { flag = nil, type = "Button" }; table.insert(self.items, o); return o
    end

    --============================ Toggle =================================
    function sectionObj:AddToggle(cfg)
        cfg = cfg or {}
        local state = cfg.State or false
        local row = make("Frame", { Parent = list, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 })
        make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -52, 1, 0),
            Font = Theme.Font, Text = cfg.Text or "Toggle", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        })

        local sw = make("TextButton", {
            Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 34, 0, 16), BackgroundColor3 = Theme.Element, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        })
        corner(sw, 8); stroke(sw, Theme.Stroke, 1)
        local knob = make("Frame", {
            Parent = sw, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Theme.TextDim, BorderSizePixel = 0,
        })
        corner(knob, 6)

        local o = { flag = cfg.Flag, type = "Toggle", state = state, key = nil, callbacks = {}, keyMode = "Toggle" }

        function o:GetValue() return o.state end
        function o:SetValue(v) o.state = v and true or false; o._refresh() end
        function o:OnChanged(fn) table.insert(o.callbacks, fn); fn(o.state) end

        function o._refresh()
            tween(sw, 0.12, { BackgroundColor3 = o.state and Theme.Accent or Theme.Element })
            tween(knob, 0.12, {
                BackgroundColor3 = o.state and Color3.fromRGB(255,255,255) or Theme.TextDim,
                Position = UDim2.new(0, o.state and 20 or 2, 0.5, 0),
            })
            for _, fn in ipairs(o.callbacks) do fn(o.state) end
        end

        -- left click toggles
        sw.MouseButton1Click:Connect(function() o.state = not o.state; o._refresh() end)

        -- MIDDLE CLICK => open keybind capture for this toggle
        sw.MouseButton2Click:Connect(function() end) -- placeholder (right)
        sw.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton3 then
                Library:OpenKeybindCapture(function(key)
                    if key then
                        o.key = key
                        Library:RegisterKeybind(key, function()
                            if o.keyMode == "Toggle" then o.state = not o.state; o._refresh()
                            elseif o.keyMode == "Hold" then o.state = true; o._refresh() end
                        end, function()
                            if o.keyMode == "Hold" then o.state = false; o._refresh() end
                        end)
                        NotificationManager.notify({Title="Keybind", Description=(cfg.Text or "function").." -> "..tostring(key.Name), Duration=2.5})
                    end
                end)
            end
        end)

        o._refresh()
        table.insert(self.items, o)
        return o
    end

    --============================ Slider =================================
    function sectionObj:AddSlider(cfg)
        cfg = cfg or {}
        local min, max, default, suffix = cfg.Min or 0, cfg.Max or 100, cfg.Default or 0, cfg.Suffix or ""
        local decimals = cfg.Decimals or 0
        local value = math.clamp(default, min, max)
        local row = make("Frame", { Parent = list, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 })
        make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.6, 0, 1, 0),
            Font = Theme.Font, Text = cfg.Text or "Slider", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        })
        local valLbl = make("TextLabel", {
            Parent = row, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 60, 1, 0),
            BackgroundTransparency = 1, Font = Theme.Font, Text = tostring(value), TextColor3 = Theme.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
        })

        local track = make("TextButton", {
            Parent = list, Size = UDim2.new(1, 0, 0, 8), BackgroundColor3 = Theme.Element, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        })
        corner(track, 4)
        local fill = make("Frame", { Parent = track, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0 })
        corner(fill, 4)

        local o = { flag = cfg.Flag, type = "Slider", value = value, callbacks = {} }
        function o:GetValue() return o.value end
        function o:SetValue(v) o.value = math.clamp(v, min, max); o._refresh() end
        function o:OnChanged(fn) table.insert(o.callbacks, fn); fn(o.value) end
        function o._refresh()
            local pct = (o.value - min) / math.max(1e-6, (max - min))
            fill.Size = UDim2.new(pct, 0, 1, 0)
            if decimals > 0 then
                valLbl.Text = ("%."..decimals.."f"):format(o.value) .. suffix
            else
                valLbl.Text = tostring(math.floor(o.value + 0.5)) .. suffix
            end
            for _, fn in ipairs(o.callbacks) do fn(o.value) end
        end

        local dragging = false
        local function setFromMouse(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
            o.value = min + (max - min) * rel
            if decimals == 0 then o.value = math.floor(o.value + 0.5) end
            o._refresh()
        end
        track.MouseButton1Down:Connect(function() dragging = true; setFromMouse(UserInputService:GetMouseLocation().X) end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then setFromMouse(i.Position.X) end end)

        o._refresh()
        table.insert(self.items, o)
        return o
    end

    --============================ Dropdown ===============================
    function sectionObj:AddDropdown(cfg)
        cfg = cfg or {}
        local options = cfg.Options or {}
        local value = cfg.Default or (options[1] or "")
        local multi = cfg.Multi or false
        local selected = multi and {} or value

        local row = make("TextButton", {
            Parent = list, Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Theme.Element, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        })
        corner(row, 4); stroke(row, Theme.Stroke, 1)
        make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
            Font = Theme.Font, Text = cfg.Text or "Dropdown", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        })
        local valLbl = make("TextLabel", {
            Parent = row, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(0.5, -8, 1, 0),
            BackgroundTransparency = 1, Font = Theme.Font, Text = tostring(value), TextColor3 = Theme.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd,
        })
        make("TextLabel", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Text = "v", Font = Theme.Font, TextColor3 = Theme.TextDim, TextSize = 12 })

        local o = { flag = cfg.Flag, type = "Dropdown", callbacks = {}, multi = multi }
        function o:GetValue() return selected end
        function o:OnChanged(fn) table.insert(o.callbacks, fn); fn(selected) end
        local function refreshText()
            if multi then
                local n = 0; for _ in pairs(selected) do n = n + 1 end
                valLbl.Text = (n == 0) and "None" or (n == 1 and (next(selected)) or (n.." selected"))
            else valLbl.Text = tostring(selected) end
            for _, fn in ipairs(o.callbacks) do fn(selected) end
        end

        -- dropdown list
        local list_frame
        local function buildList()
            if list_frame then list_frame:Destroy() end
            list_frame = make("Frame", {
                Parent = list, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Element, BorderSizePixel = 0,
            })
            corner(list_frame, 4); stroke(list_frame, Theme.Stroke, 1)
            pad(list_frame, 4)
            layout(list_frame, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Full)
            for _, opt in ipairs(options) do
                local b = make("TextButton", {
                    Parent = list_frame, Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Theme.Background, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
                })
                corner(b, 3)
                local lit = multi and selected[opt] or (selected == opt)
                make("TextLabel", {
                    Parent = b, BackgroundTransparency = 1, Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(1, -6, 1, 0),
                    Font = Theme.Font, Text = tostring(opt), TextColor3 = lit and Theme.Accent or Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
                })
                b.MouseButton1Click:Connect(function()
                    if multi then selected[opt] = not selected[opt]; if not selected[opt] then selected[opt] = nil end
                    else selected = opt end
                    refreshText(); buildList()
                end)
            end
        end
        local opened = false
        row.MouseButton1Click:Connect(function()
            opened = not opened
            if opened then buildList() else if list_frame then list_frame:Destroy(); list_frame = nil end end
        end)

        refreshText()
        table.insert(self.items, o)
        return o
    end

    --============================ ColorPicker ============================
    function sectionObj:AddColorPicker(cfg)
        cfg = cfg or {}
        local color = cfg.Default or Theme.Accent
        local row = make("Frame", { Parent = list, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 })
        make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -40, 1, 0),
            Font = Theme.Font, Text = cfg.Text or "Color", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        })
        local swatch = make("TextButton", {
            Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 30, 0, 14), BackgroundColor3 = color, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        })
        corner(swatch, 4); stroke(swatch, Theme.Stroke, 1)

        local o = { flag = cfg.Flag, type = "Color", _isColor = true, callbacks = {} }
        function o:GetValue() return color end
        function o:SetValue(c) color = c; swatch.BackgroundColor3 = c; for _, fn in ipairs(o.callbacks) do fn(c) end end
        function o:OnChanged(fn) table.insert(o.callbacks, fn); fn(color) end

        local palette
        swatch.MouseButton1Click:Connect(function()
            if palette then palette:Destroy(); palette = nil; return end
            palette = make("Frame", { Parent = list, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Element, BorderSizePixel = 0 })
            corner(palette, 4); stroke(palette, Theme.Stroke, 1)
            pad(palette, 6)
            local pl = make("Frame", { Parent = palette, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
            layout(pl, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Full)

            o._r, o._g, o._b = color.R, color.G, color.B
            local function commit()
                o:SetValue(Color3.fromRGB(math.floor(o._r*255), math.floor(o._g*255), math.floor(o._b*255)))
            end

            local function bar(label, ch)
                local r = make("Frame", { Parent = pl, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1 })
                make("TextLabel", { Parent = r, BackgroundTransparency = 1, Size = UDim2.new(0, 14, 1, 0), Font = Theme.Font, Text = label, TextColor3 = Theme.TextDim, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left })
                local tb = make("TextButton", { Parent = r, Position = UDim2.new(0, 18, 0, 2), Size = UDim2.new(1, -18, 0, 10), BackgroundColor3 = Theme.Background, Text = "", AutoButtonColor = false, BorderSizePixel = 0 })
                corner(tb, 3)
                local f = make("Frame", { Parent = tb, Size = UDim2.new(o[ch], 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0 }); corner(f, 3)
                local drag
                local function upd(x)
                    local rel = math.clamp((x - tb.AbsolutePosition.X) / math.max(1, tb.AbsoluteSize.X), 0, 1)
                    o[ch] = rel; f.Size = UDim2.new(rel, 0, 1, 0); commit()
                end
                tb.MouseButton1Down:Connect(function() drag = true; upd(UserInputService:GetMouseLocation().X) end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
                UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
            end
            bar("R", "_r"); bar("G", "_g"); bar("B", "_b")
        end)

        table.insert(self.items, o)
        return o
    end

    --============================ Keybind (standalone) ==================
    function sectionObj:AddKeybind(cfg)
        cfg = cfg or {}
        local row = make("Frame", { Parent = list, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 })
        make("TextLabel", {
            Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -60, 1, 0),
            Font = Theme.Font, Text = cfg.Text or "Keybind", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        })
        local btn = make("TextButton", {
            Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 56, 0, 16), BackgroundColor3 = Theme.Element, Text = cfg.Default and cfg.Default.Name or "[none]", Font = Theme.Font, TextColor3 = Theme.TextDim, TextSize = 11, AutoButtonColor = false, BorderSizePixel = 0,
        })
        corner(btn, 4); stroke(btn, Theme.Stroke, 1)

        local o = { flag = cfg.Flag, type = "Keybind", key = cfg.Default, callbacks = {} }
        function o:GetValue() return o.key end
        function o:OnPressed(fn) o._onPress = fn end
        btn.MouseButton1Click:Connect(function()
            Library:OpenKeybindCapture(function(key)
                o.key = key
                btn.Text = key and key.Name or "[none]"
                if key then Library:RegisterKeybind(key, function() if o._onPress then o._onPress() end end) end
            end)
        end)
        if cfg.Default and o._onPress then Library:RegisterKeybind(cfg.Default, function() if o._onPress then o._onPress() end end) end
        table.insert(self.items, o)
        return o
    end

    return sectionObj
end

--==========================================================================
-- Keybind capture popup + global keybind registry
--==========================================================================
local KeybindPopup

function Library:OpenKeybindCapture(onDone)
    if KeybindPopup then KeybindPopup:Destroy() end
    local gui = Library._window and Library._window._gui
    if not gui then return end

    KeybindPopup = make("Frame", {
        Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 220, 0, 70), BackgroundColor3 = Theme.Section, BorderSizePixel = 0,
    })
    corner(KeybindPopup, 6); stroke(KeybindPopup, Theme.Accent, 1)
    make("TextLabel", {
        Parent = KeybindPopup, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 8), Size = UDim2.new(1, 0, 0, 16),
        Font = Theme.FontBold, Text = "Press a key...", TextColor3 = Theme.Text, TextSize = 13,
    })
    local sub = make("TextLabel", {
        Parent = KeybindPopup, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 14),
        Font = Theme.Font, Text = "ESC = cancel  /  Backspace = clear", TextColor3 = Theme.TextDim, TextSize = 11,
    })

    local done = false
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if done then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.Escape then
            done = true; KeybindPopup:Destroy(); KeybindPopup = nil; conn:Disconnect(); onDone(nil); return
        end
        if key == Enum.KeyCode.Backspace then
            done = true; KeybindPopup:Destroy(); KeybindPopup = nil; conn:Disconnect(); onDone(false); return
        end
        if key ~= Enum.KeyCode.Unknown and key.EnumType == Enum.KeyCode then
            done = true; KeybindPopup:Destroy(); KeybindPopup = nil; conn:Disconnect(); onDone(key); return
        end
    end)
end

function Library:RegisterKeybind(key, onPress, onRelease)
    if not key then return end
    Library._keybinds[key] = { press = onPress, release = onRelease }
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local bind = Library._keybinds[input.KeyCode]
    if bind and bind.press then bind.press() end
end)
UserInputService.InputEnded:Connect(function(input)
    local bind = Library._keybinds[input.KeyCode]
    if bind and bind.release then bind.release() end
end)

return Library
