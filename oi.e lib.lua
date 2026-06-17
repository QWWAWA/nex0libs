local Services = setmetatable({}, { __index = function(_, k) return game:GetService(k) end })
local TweenService     = Services.TweenService
local UserInputService = Services.UserInputService
local RunService       = Services.RunService
local CoreGui          = Services.CoreGui
local Players          = Services.Players

local function round(num, places)
    local mult = 10 ^ (places or 0)
    return math.floor(num * mult + 0.5) / mult
end
local function clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end

local function tween(obj, t, props, style, dir)
    local info = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function corner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    return c
end

local function stroke(color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 58)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function padding(t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop, p.PaddingBottom = UDim.new(0, t or 0), UDim.new(0, b or 0)
    p.PaddingLeft, p.PaddingRight = UDim.new(0, l or 0), UDim.new(0, r or 0)
    return p
end

local function makeFrame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.Color or Color3.fromRGB(34, 34, 40)
    f.BackgroundTransparency = props.Transparency or 0
    f.BorderSizePixel = 0
    f.Size = props.Size
    f.Position = props.Position
    f.AnchorPoint = props.AnchorPoint
    f.Name = props.Name
    f.Parent = props.Parent
    if props.CornerRadius then corner(props.CornerRadius).Parent = f end
    if props.Stroke then stroke(props.Stroke[1], props.Stroke[2], props.Stroke[3]).Parent = f end
    return f
end

local function makeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = props.Font or Enum.Font.GothamSemibold
    l.Text = props.Text or ""
    l.TextColor3 = props.Color or Color3.fromRGB(235, 235, 240)
    l.TextSize = props.TextSize or 14
    l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    l.Size = props.Size
    l.Position = props.Position
    l.AnchorPoint = props.AnchorPoint
    l.Name = props.Name
    l.Parent = props.Parent
    return l
end

local IconCache = {}

local function getCustomAssetSafe(content)
    local funcs = { "getcustomasset", "get_custom_asset", "writecustomasset" }
    for _, name in ipairs(funcs) do
        local fn = getgenv and getgenv()[name] or (rawget(_G, name))
        if type(fn) == "function" then
            local ok, res = pcall(fn, content)
            if ok and res then return res end
        end
    end
    return nil
end

local function downloadIcon(url)
    if IconCache[url] then return IconCache[url] end
    local ok, data = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not data or #data == 0 then return nil end

    local ext = ".png"
    local low = string.lower(url)
    if string.find(low, "%.jpg") or string.find(low, "%.jpeg") then ext = ".jpg"
    elseif string.find(low, "%.webp") then ext = ".webp" end

    local fname = "oie_" .. tostring(tick()):gsub("%.", "") .. ext
    local path = fname
    pcall(function()
        if writefile then writefile(fname, data) end
    end)

    local assetId = getCustomAssetSafe(path) or getCustomAssetSafe(fname)
    if assetId then IconCache[url] = assetId end
    return assetId
end

local Splash = {}
Splash.__index = Splash

function Splash.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Splash)

    local accent = opts.Accent or Color3.fromRGB(192, 97, 203)

    if CoreGui:FindFirstChild("oie_Splash") then
        CoreGui.oie_Splash:Destroy()
    end

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "oie_Splash"
    self.Gui.ResetOnSpawn = false
    self.Gui.IgnoreGuiInset = true
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.Parent = CoreGui

    self.Backdrop = Instance.new("Frame")
    self.Backdrop.Size = UDim2.new(1, 0, 1, 0)
    self.Backdrop.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    self.Backdrop.BorderSizePixel = 0
    self.Backdrop.Parent = self.Gui

    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new(Color3.fromRGB(28, 20, 38), Color3.fromRGB(8, 8, 12))
    bgGrad.Rotation = 45
    bgGrad.Parent = self.Backdrop

    self.Card = Instance.new("Frame")
    self.Card.Size = UDim2.new(0, 380, 0, 200)
    self.Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Card.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    self.Card.BorderSizePixel = 0
    self.Card.ClipsDescendants = true
    self.Card.Parent = self.Backdrop
    corner(UDim.new(0, 14)).Parent = self.Card
    local cs = stroke(accent, 1, 0.5)
    cs.Parent = self.Card

    self.Logo = Instance.new("TextLabel")
    self.Logo.Size = UDim2.new(0, 56, 0, 56)
    self.Logo.Position = UDim2.new(0.5, 0, 0, 28)
    self.Logo.AnchorPoint = Vector2.new(0.5, 0)
    self.Logo.BackgroundTransparency = 1
    self.Logo.Text = "◆"
    self.Logo.TextColor3 = accent
    self.Logo.Font = Enum.Font.GothamBold
    self.Logo.TextSize = 46
    self.Logo.Parent = self.Card
    local lg = stroke(accent, 2, 0.6); lg.Parent = self.Logo

    self.Title = Instance.new("TextLabel")
    self.Title.Size = UDim2.new(1, 0, 0, 26)
    self.Title.Position = UDim2.new(0, 0, 0, 92)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = opts.Title or "oi.e"
    self.Title.TextColor3 = Color3.fromRGB(235, 235, 240)
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextSize = 22
    self.Title.Parent = self.Card

    self.Status = Instance.new("TextLabel")
    self.Status.Size = UDim2.new(1, -24, 0, 16)
    self.Status.Position = UDim2.new(0, 12, 0, 124)
    self.Status.BackgroundTransparency = 1
    self.Status.Text = opts.Status or "Loading..."
    self.Status.TextColor3 = Color3.fromRGB(150, 150, 160)
    self.Status.Font = Enum.Font.Gotham
    self.Status.TextSize = 13
    self.Status.TextXAlignment = Enum.TextXAlignment.Left
    self.Status.Parent = self.Card

    self.Sub = Instance.new("TextLabel")
    self.Sub.Size = UDim2.new(1, -24, 0, 14)
    self.Sub.Position = UDim2.new(0, 12, 0, 142)
    self.Sub.BackgroundTransparency = 1
    self.Sub.Text = ""
    self.Sub.TextColor3 = Color3.fromRGB(110, 110, 120)
    self.Sub.Font = Enum.Font.Code
    self.Sub.TextSize = 11
    self.Sub.TextTruncate = Enum.TextTruncate.AtEnd
    self.Sub.TextXAlignment = Enum.TextXAlignment.Left
    self.Sub.Parent = self.Card

    self.BarBg = Instance.new("Frame")
    self.BarBg.Size = UDim2.new(0, 320, 0, 6)
    self.BarBg.Position = UDim2.new(0.5, 0, 0, 166)
    self.BarBg.AnchorPoint = Vector2.new(0.5, 0)
    self.BarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    self.BarBg.BorderSizePixel = 0
    self.BarBg.Parent = self.Card
    corner(UDim.new(1, 0)).Parent = self.BarBg

    self.BarFill = Instance.new("Frame")
    self.BarFill.Size = UDim2.new(0, 0, 1, 0)
    self.BarFill.BackgroundColor3 = accent
    self.BarFill.BorderSizePixel = 0
    self.BarFill.Parent = self.BarBg
    corner(UDim.new(1, 0)).Parent = self.BarFill

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(
        Color3.fromRGB(150, 70, 200),
        Color3.fromRGB(225, 125, 235)
    )
    grad.Parent = self.BarFill

    self.Percent = Instance.new("TextLabel")
    self.Percent.Size = UDim2.new(0, 40, 0, 14)
    self.Percent.Position = UDim2.new(1, -12, 0, 142)
    self.Percent.AnchorPoint = Vector2.new(1, 0)
    self.Percent.BackgroundTransparency = 1
    self.Percent.Text = "0%"
    self.Percent.TextColor3 = accent
    self.Percent.Font = Enum.Font.GothamBold
    self.Percent.TextSize = 12
    self.Percent.TextXAlignment = Enum.TextXAlignment.Right
    self.Percent.Parent = self.Card

    self.Card.Size = UDim2.new(0, 0, 0, 0)
    task.wait()
    tween(self.Card, 0.5, { Size = UDim2.new(0, 380, 0, 200) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    self.SpinConn = RunService.RenderStepped:Connect(function(dt)
        self.Logo.Rotation = (self.Logo.Rotation + 130 * dt) % 360
    end)

    return self
end

function Splash:SetProgress(p, status, sub)
    p = clamp(p, 0, 1)
    tween(self.BarFill, 0.25, { Size = UDim2.new(p, 0, 1, 0) })
    self.Percent.Text = tostring(math.floor(p * 100 + 0.5)) .. "%"
    if status then self.Status.Text = status end
    if sub then self.Sub.Text = sub end
end

function Splash:Finish(cb)
    if self.SpinConn then self.SpinConn:Disconnect() end
    self:SetProgress(1, "Ready!", "")
    task.wait(0.35)
    tween(self.Backdrop, 0.4, { BackgroundTransparency = 1 })
    tween(self.Card, 0.4, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.wait(0.4)
    if self.Gui then self.Gui:Destroy() end
    if cb then task.spawn(cb) end
end

function Splash:LoadAssets(urls, done)
    urls = urls or {}
    local total = #urls
    if total == 0 then
        if done then done() end
        return
    end
    for i, url in ipairs(urls) do
        self:SetProgress((i - 1) / total, "Fetching assets...", url)
        downloadIcon(url)
        self:SetProgress(i / total, "Fetching assets...", url)
    end
    if done then done() end
end

local Notifications = {}
Notifications.__index = Notifications

function Notifications.new(theme)
    local self = setmetatable({}, Notifications)
    self.Theme = theme
    return self
end

function Notifications:Notify(title, text, duration, typee)
    duration = duration or 3
    typee = typee or "info"
    local theme = self.Theme

    if not self.Container then
        self.Container = Instance.new("Frame")
        self.Container.Name = "oie_Notifications"
        self.Container.BackgroundTransparency = 1
        self.Container.Size = UDim2.new(0, 300, 1, 0)
        self.Container.Position = UDim2.new(1, -320, 0, 20)
        self.Container.Parent = self.Parent
        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0, 8)
        lay.HorizontalAlignment = Enum.HorizontalAlignment.Right
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Parent = self.Container
    end

    local color = theme.Accent
    if typee == "success" then color = theme.Success
    elseif typee == "danger" then color = theme.Danger end

    local n = makeFrame({
        Size = UDim2.new(1, 0, 0, 0), Color = theme.Panel,
        CornerRadius = theme.CornerRadius, Stroke = { theme.Border, 1, 0.3 },
        Parent = self.Container, Name = "Notification",
    })
    n.AutomaticSize = Enum.AutomaticSize.Y
    n.ClipsDescendants = true

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = n
    corner(UDim.new(0, 2)).Parent = bar

    padding(8, 8, 12, 12).Parent = n

    makeLabel({
        Text = title, Color = color, TextSize = 14,
        Size = UDim2.new(1, 0, 0, 16), Parent = n, Name = "Title",
    })
    local body = makeLabel({
        Text = text, Color = theme.TextDim, TextSize = 13,
        Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 18),
        Parent = n, Name = "Text", YAlign = Enum.TextYAlignment.Top,
    })
    body.TextWrapped = true
    body.AutomaticSize = Enum.AutomaticSize.Y

    n.Size = UDim2.new(0, 0, 0, 0)
    n.Position = UDim2.new(1, 0, 0, 0)
    task.wait()
    n.AutomaticSize = Enum.AutomaticSize.Y
    tween(n, 0.35, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        tween(n, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(1, 20, 0, 0),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.3)
        n:Destroy()
    end)
end

local DefaultTheme = {
    Accent         = Color3.fromRGB(192, 97, 203),
    AccentDark     = Color3.fromRGB(150, 70, 160),
    Background     = Color3.fromRGB(24, 24, 28),
    Panel          = Color3.fromRGB(34, 34, 40),
    PanelLight     = Color3.fromRGB(44, 44, 52),
    Border         = Color3.fromRGB(50, 50, 58),
    Text           = Color3.fromRGB(235, 235, 240),
    TextDim        = Color3.fromRGB(150, 150, 160),
    TextDark       = Color3.fromRGB(110, 110, 120),
    ToggleOff      = Color3.fromRGB(60, 60, 70),
    Success        = Color3.fromRGB(80, 200, 120),
    Danger         = Color3.fromRGB(220, 80, 90),
    CornerRadius   = UDim.new(0, 8),
    CornerRadiusSm = UDim.new(0, 5),
    CornerRadiusLg = UDim.new(0, 12),
    Font           = Enum.Font.GothamSemibold,
    TextSize       = 14,
    TextSizeTitle  = 18,
    AnimationSpeed = 0.18,
    AnimationStyle = Enum.EasingStyle.Quart,
    AnimationDir   = Enum.EasingDirection.Out,
}

local Component = {}

function Component.Toggle(parent, theme, cfg)
    local state = cfg.Default or false
    local cbs = { cfg.Callback }

    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 36), Transparency = 1,
        Parent = parent, Name = "Toggle_" .. (cfg.Name or ""),
    })
    makeLabel({
        Text = cfg.Name, Color = theme.Text, TextSize = theme.TextSize,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), Parent = holder,
    })

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -50, 0.5, -10)
    track.BackgroundColor3 = state and theme.Accent or theme.ToggleOff
    track.AutoButtonColor = false
    track.Text = ""
    track.Parent = holder
    corner(UDim.new(1, 0)).Parent = track
    stroke(theme.Border, 1, 0.5).Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(UDim.new(1, 0)).Parent = knob

    local function update(anim)
        if state then
            if anim then
                tween(track, theme.AnimationSpeed, { BackgroundColor3 = theme.Accent })
                tween(knob, theme.AnimationSpeed, { Position = UDim2.new(1, -18, 0.5, -8) })
            else
                track.BackgroundColor3 = theme.Accent
                knob.Position = UDim2.new(1, -18, 0.5, -8)
            end
        else
            if anim then
                tween(track, theme.AnimationSpeed, { BackgroundColor3 = theme.ToggleOff })
                tween(knob, theme.AnimationSpeed, { Position = UDim2.new(0, 2, 0.5, -8) })
            else
                track.BackgroundColor3 = theme.ToggleOff
                knob.Position = UDim2.new(0, 2, 0.5, -8)
            end
        end
    end

    track.MouseButton1Click:Connect(function()
        state = not state
        update(true)
        for _, c in ipairs(cbs) do if c then task.spawn(c, state) end end
    end)

    return {
        Frame = holder,
        Set = function(v) state = v; update(true); for _, c in ipairs(cbs) do if c then task.spawn(c, state) end end end,
        Get = function() return state end,
        OnChange = function(c) table.insert(cbs, c) end,
    }
end

function Component.Slider(parent, theme, cfg)
    local mn, mx, step = cfg.Min or 0, cfg.Max or 100, cfg.Step or 1
    local suffix = cfg.Suffix or ""
    local value = cfg.Default or mn
    local cbs = { cfg.Callback }

    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 50), Transparency = 1,
        Parent = parent, Name = "Slider_" .. (cfg.Name or ""),
    })
    makeLabel({
        Text = cfg.Name, Color = theme.Text, TextSize = theme.TextSize,
        Position = UDim2.new(0, 12, 0, 4), Size = UDim2.new(1, -50, 0, 16), Parent = holder,
    })
    local valL = makeLabel({
        Text = tostring(value) .. suffix, Color = theme.Accent, TextSize = theme.TextSize,
        Position = UDim2.new(1, -12, 0, 4), AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 90, 0, 16), XAlign = Enum.TextXAlignment.Right, Parent = holder,
    })

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = theme.ToggleOff
    track.BorderSizePixel = 0
    track.Parent = holder
    corner(UDim.new(1, 0)).Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - mn) / (mx - mn), 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(UDim.new(1, 0)).Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(1, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = fill
    corner(UDim.new(1, 0)).Parent = knob

    local dragging = false
    local function upd(x)
        local rel = clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = mn + (mx - mn) * rel
        value = clamp(round(raw / step) * step, mn, mx)
        fill.Size = UDim2.new((value - mn) / (mx - mn), 0, 1, 0)
        valL.Text = tostring(value) .. suffix
        for _, c in ipairs(cbs) do if c then task.spawn(c, value) end end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; upd(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)

    return {
        Frame = holder,
        Set = function(v)
            value = clamp(v, mn, mx)
            fill.Size = UDim2.new((value - mn) / (mx - mn), 0, 1, 0)
            valL.Text = tostring(value) .. suffix
            for _, c in ipairs(cbs) do if c then task.spawn(c, value) end end
        end,
        Get = function() return value end,
        OnChange = function(c) table.insert(cbs, c) end,
    }
end

function Component.Dropdown(parent, theme, cfg)
    local options = cfg.Options or {}
    local value = cfg.Default or (options[1] or "")
    local cbs = { cfg.Callback }
    local open = false

    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 34), Transparency = 1,
        Parent = parent, Name = "Dropdown_" .. (cfg.Name or ""),
    })
    makeLabel({
        Text = cfg.Name, Color = theme.TextDim, TextSize = 13,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 0, 14), Parent = holder,
    })

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 20)
    btn.Position = UDim2.new(0, 12, 0, 14)
    btn.BackgroundColor3 = theme.ToggleOff
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = holder
    corner(theme.CornerRadiusSm).Parent = btn

    local bt = makeLabel({ Text = value, Color = theme.Text, TextSize = theme.TextSize,
        Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -28, 1, 0), Parent = btn })
    local ar = makeLabel({ Text = "▼", Color = theme.TextDim, TextSize = 10,
        Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(0, 12, 1, 0),
        XAlign = Enum.TextXAlignment.Center, Parent = btn })

    local list = makeFrame({
        Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 36),
        Color = theme.Panel, Transparency = 1, Parent = holder, Name = "List",
    })
    list.Visible = false
    list.ZIndex = 5
    list.ClipsDescendants = true
    corner(theme.CornerRadiusSm).Parent = list
    stroke(theme.Border, 1, 0.3).Parent = list
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 2); ll.Parent = list
    padding(4, 4, 4, 4).Parent = list

    local function rebuild()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(options) do
            local it = Instance.new("TextButton")
            it.Size = UDim2.new(1, 0, 0, 22)
            it.BackgroundColor3 = (opt == value) and theme.PanelLight or theme.Panel
            it.AutoButtonColor = false
            it.Text = ""
            it.ZIndex = 5
            it.Parent = list
            corner(UDim.new(0, 4)).Parent = it
            local itx = makeLabel({ Text = opt, Color = (opt == value) and theme.Accent or theme.Text,
                TextSize = 13, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -12, 1, 0), Parent = it })
            itx.ZIndex = 5
            it.MouseEnter:Connect(function() if opt ~= value then tween(it, 0.1, { BackgroundColor3 = theme.PanelLight }) end end)
            it.MouseLeave:Connect(function() if opt ~= value then tween(it, 0.1, { BackgroundColor3 = theme.Panel }) end end)
            it.MouseButton1Click:Connect(function()
                value = opt; bt.Text = value; list.Visible = false; open = false
                tween(ar, theme.AnimationSpeed, { TextColor3 = theme.TextDim })
                rebuild()
                for _, c in ipairs(cbs) do if c then task.spawn(c, value) end end
            end)
        end
        list.Size = UDim2.new(1, -24, 0, 8 + #options * 24)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        list.Visible = open
        if open then
            rebuild()
            list.BackgroundTransparency = 1
            tween(list, theme.AnimationSpeed, { BackgroundTransparency = 0 })
            tween(ar, theme.AnimationSpeed, { TextColor3 = theme.Accent })
        else
            tween(ar, theme.AnimationSpeed, { TextColor3 = theme.TextDim })
        end
    end)

    return {
        Frame = holder,
        Set = function(v) value = v; bt.Text = value; for _, c in ipairs(cbs) do if c then task.spawn(c, value) end end end,
        Get = function() return value end,
        OnChange = function(c) table.insert(cbs, c) end,
    }
end

function Component.Keybind(parent, theme, cfg)
    local key = cfg.Default or Enum.KeyCode.E
    local listening = false
    local cbs = { cfg.Callback }

    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 36), Transparency = 1,
        Parent = parent, Name = "Keybind_" .. (cfg.Name or ""),
    })
    makeLabel({ Text = cfg.Name, Color = theme.Text, TextSize = theme.TextSize,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), Parent = holder })

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 22)
    btn.Position = UDim2.new(1, -82, 0.5, -11)
    btn.BackgroundColor3 = theme.ToggleOff
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = holder
    corner(theme.CornerRadiusSm).Parent = btn
    local btx = makeLabel({ Text = key and key.Name or "None", Color = theme.Text, TextSize = 12,
        Size = UDim2.new(1, 0, 1, 0), XAlign = Enum.TextXAlignment.Center, Parent = btn })

    local function setTx(t, col) btx.Text = t; tween(btn, 0.1, { BackgroundColor3 = col or theme.ToggleOff }) end

    btn.MouseButton1Click:Connect(function() listening = true; setTx("...", theme.AccentDark) end)
    UserInputService.InputBegan:Connect(function(i, gp)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                key = i.KeyCode; listening = false; setTx(key.Name, theme.ToggleOff)
                for _, c in ipairs(cbs) do if c then task.spawn(c, key) end end
            end
        elseif i.KeyCode == key and not gp then
            for _, c in ipairs(cbs) do if c then task.spawn(c, key) end end
        end
    end)

    return {
        Frame = holder,
        Set = function(k) key = k; setTx(key.Name, theme.ToggleOff) end,
        Get = function() return key end,
        OnChange = function(c) table.insert(cbs, c) end,
    }
end

function Component.ColorPicker(parent, theme, cfg)
    local color = cfg.Default or theme.Accent
    local cbs = { cfg.Callback }

    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 36), Transparency = 1,
        Parent = parent, Name = "ColorPicker_" .. (cfg.Name or ""),
    })
    makeLabel({ Text = cfg.Name, Color = theme.Text, TextSize = theme.TextSize,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), Parent = holder })

    local swatch = Instance.new("TextButton")
    swatch.Size = UDim2.new(0, 40, 0, 20)
    swatch.Position = UDim2.new(1, -52, 0.5, -10)
    swatch.BackgroundColor3 = color
    swatch.AutoButtonColor = false
    swatch.Text = ""
    swatch.Parent = holder
    corner(theme.CornerRadiusSm).Parent = swatch
    stroke(theme.Border, 1, 0.4).Parent = swatch

    local popup = makeFrame({
        Size = UDim2.new(0, 180, 0, 160), Position = UDim2.new(1, -52, 0, 26),
        Color = theme.Panel, Transparency = 1, Parent = holder, Name = "Popup",
    })
    popup.Visible = false; popup.ZIndex = 10
    corner(theme.CornerRadius).Parent = popup
    stroke(theme.Border, 1, 0.2).Parent = popup
    padding(8, 8, 8, 8).Parent = popup

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(1, 0, 0, 12)
    hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueBar.BorderSizePixel = 0
    hueBar.Parent = popup
    corner(UDim.new(1, 0)).Parent = hueBar
    local hg = Instance.new("UIGradient")
    hg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })
    hg.Parent = hueBar

    local hueKnob = Instance.new("Frame")
    hueKnob.Size = UDim2.new(0, 6, 0, 16)
    hueKnob.Position = UDim2.new(0, 0, 0.5, -8)
    hueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueKnob.BorderSizePixel = 0
    hueKnob.ZIndex = 11
    hueKnob.Parent = hueBar
    corner(UDim.new(1, 0)).Parent = hueKnob
    stroke(Color3.fromRGB(0, 0, 0), 1, 0.3).Parent = hueKnob

    local svArea = Instance.new("Frame")
    svArea.Size = UDim2.new(1, 0, 0, 100)
    svArea.Position = UDim2.new(0, 0, 0, 22)
    svArea.BackgroundColor3 = color
    svArea.BorderSizePixel = 0
    svArea.Parent = popup
    corner(theme.CornerRadiusSm).Parent = svArea

    local wg = Instance.new("UIGradient")
    wg.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255))
    wg.Transparency = NumberSequence.new(0, 1)
    wg.Parent = svArea

    local bo = Instance.new("Frame")
    bo.Size = UDim2.new(1, 0, 1, 0)
    bo.BackgroundTransparency = 1
    bo.BorderSizePixel = 0
    bo.Parent = svArea
    local bg2 = Instance.new("UIGradient")
    bg2.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
    bg2.Transparency = NumberSequence.new(1, 0)
    bg2.Rotation = 90
    bg2.Parent = bo

    local svKnob = Instance.new("Frame")
    svKnob.Size = UDim2.new(0, 8, 0, 8)
    svKnob.Position = UDim2.new(1, -4, 0, -4)
    svKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    svKnob.BorderSizePixel = 0
    svKnob.ZIndex = 11
    svKnob.Parent = svArea
    corner(UDim.new(1, 0)).Parent = svKnob
    stroke(Color3.fromRGB(0, 0, 0), 1, 0.2).Parent = svKnob

    local function upd()
        swatch.BackgroundColor3 = color
        for _, c in ipairs(cbs) do if c then task.spawn(c, color) end end
    end

    local hueDrag = false
    hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end end)
    hueBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end end)
    RunService.RenderStepped:Connect(function()
        if hueDrag then
            local mp = UserInputService:GetMouseLocation()
            local rel = clamp((mp.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            hueKnob.Position = UDim2.new(rel, -3, 0.5, -8)
            svArea.BackgroundColor3 = Color3.fromHSV(rel, 1, 1)
            local svx = svKnob.Position.X.Scale
            local svy = svKnob.Position.Y.Scale
            color = Color3.fromHSV(rel, clamp(svx, 0, 1), clamp(1 - svy, 0, 1))
            upd()
        end
    end)

    local svDrag = false
    svArea.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = true end end)
    svArea.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end end)
    RunService.RenderStepped:Connect(function()
        if svDrag then
            local mp = UserInputService:GetMouseLocation()
            local rx = clamp((mp.X - svArea.AbsolutePosition.X) / svArea.AbsoluteSize.X, 0, 1)
            local ry = clamp((mp.Y - svArea.AbsolutePosition.Y) / svArea.AbsoluteSize.Y, 0, 1)
            svKnob.Position = UDim2.new(rx, -4, ry, -4)
            color = Color3.fromHSV(hueKnob.Position.X.Scale, rx, 1 - ry)
            upd()
        end
    end)

    swatch.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
        if popup.Visible then
            popup.BackgroundTransparency = 1
            tween(popup, theme.AnimationSpeed, { BackgroundTransparency = 0 })
        end
    end)
    UserInputService.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and popup.Visible then
            local mp = UserInputService:GetMouseLocation()
            local pp, ps = popup.AbsolutePosition, popup.AbsoluteSize
            local sp, ss = swatch.AbsolutePosition, swatch.AbsoluteSize
            local inPop = mp.X >= pp.X and mp.X <= pp.X + ps.X and mp.Y >= pp.Y and mp.Y <= pp.Y + ps.Y
            local inSw = mp.X >= sp.X and mp.X <= sp.X + ss.X and mp.Y >= sp.Y and mp.Y <= sp.Y + ss.Y
            if not inPop and not inSw then popup.Visible = false end
        end
    end)

    return {
        Frame = holder,
        Set = function(c) color = c; swatch.BackgroundColor3 = c; for _, cb in ipairs(cbs) do if cb then task.spawn(cb, c) end end end,
        Get = function() return color end,
        OnChange = function(c) table.insert(cbs, c) end,
    }
end

function Component.Button(parent, theme, cfg)
    local cbs = { cfg.Callback }
    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 34), Transparency = 1,
        Parent = parent, Name = "Button_" .. (cfg.Name or ""),
    })
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 30)
    btn.Position = UDim2.new(0, 12, 0, 2)
    btn.BackgroundColor3 = theme.PanelLight
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = holder
    corner(theme.CornerRadiusSm).Parent = btn
    stroke(theme.Border, 1, 0.4).Parent = btn
    local btx = makeLabel({ Text = cfg.Name, Color = theme.Text, TextSize = theme.TextSize,
        Size = UDim2.new(1, 0, 1, 0), XAlign = Enum.TextXAlignment.Center, Parent = btn })

    btn.MouseEnter:Connect(function()
        tween(btn, theme.AnimationSpeed, { BackgroundColor3 = theme.Accent })
        tween(btx, theme.AnimationSpeed, { TextColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, theme.AnimationSpeed, { BackgroundColor3 = theme.PanelLight })
        tween(btx, theme.AnimationSpeed, { TextColor3 = theme.Text })
    end)
    btn.MouseButton1Click:Connect(function()
        for _, c in ipairs(cbs) do if c then task.spawn(c) end end
    end)

    return { Frame = holder, OnClick = function(c) table.insert(cbs, c) end }
end

function Component.Label(parent, theme, cfg)
    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 22), Transparency = 1,
        Parent = parent, Name = "Label_" .. (cfg.Name or ""),
    })
    makeLabel({ Text = cfg.Text, Color = cfg.Color or theme.TextDim,
        TextSize = cfg.TextSize or theme.TextSize,
        Position = UDim2.new(1, 12, 0, 0), Size = UDim2.new(1, -24, 1, 0), Parent = holder })
    return { Frame = holder, Set = function(t) holder:FindFirstChildWhichIsA("TextLabel").Text = t end }
end

function Component.TextBox(parent, theme, cfg)
    local cbs = { cfg.Callback }
    local value = cfg.Default or ""
    local holder = makeFrame({
        Size = UDim2.new(1, 0, 0, 36), Transparency = 1,
        Parent = parent, Name = "TextBox_" .. (cfg.Name or ""),
    })
    makeLabel({ Text = cfg.Name, Color = theme.Text, TextSize = theme.TextSize,
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), Parent = holder })

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 120, 0, 22)
    box.Position = UDim2.new(1, -132, 0.5, -11)
    box.BackgroundColor3 = theme.ToggleOff
    box.BorderSizePixel = 0
    box.Text = value
    box.PlaceholderText = cfg.Placeholder or ""
    box.PlaceholderColor3 = theme.TextDark
    box.TextColor3 = theme.Text
    box.Font = theme.Font
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = holder
    corner(theme.CornerRadiusSm).Parent = box
    padding(0, 0, 6, 6).Parent = box

    box.FocusLost:Connect(function()
        value = box.Text
        for _, c in ipairs(cbs) do if c then task.spawn(c, value) end end
    end)

    return {
        Frame = holder,
        Set = function(v) value = v; box.Text = v end,
        Get = function() return box.Text end,
        OnChange = function(c) table.insert(cbs, c) end,
    }
end

local Tab = {}
Tab.__index = Tab

function Tab.new(window, theme, name, icon)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Theme = theme
    self.Name = name
    self.Sections = {}
    self.Active = false

    self.Button = Instance.new("TextButton")
    self.Button.Size = UDim2.new(1, -16, 0, 32)
    self.Button.BackgroundColor3 = theme.Panel
    self.Button.AutoButtonColor = false
    self.Button.Text = ""
    self.Button.Parent = window.TabList
    corner(theme.CornerRadiusSm).Parent = self.Button
    padding(0, 0, 4, 4).Parent = self.Button

    local isURL = type(icon) == "string" and (icon:sub(1, 7) == "http://" or icon:sub(1, 8) == "https://")
    local fallbackEmoji = "◆"
    if type(icon) == "string" and not isURL then fallbackEmoji = icon end

    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 20, 1, 0)
    iconFrame.Position = UDim2.new(0, 8, 0, 0)
    iconFrame.BackgroundTransparency = 1
    iconFrame.Parent = self.Button

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(0, 16, 0, 16)
    iconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconImg.AnchorPoint = Vector2.new(0.5, 0.5)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = ""
    iconImg.ImageTransparency = 1
    iconImg.Parent = iconFrame

    local iconTxt = makeLabel({
        Text = fallbackEmoji, Color = theme.TextDim, TextSize = 14,
        Size = UDim2.new(1, 0, 1, 0), XAlign = Enum.TextXAlignment.Center, Parent = iconFrame,
    })

    if isURL then
        local cached = IconCache[icon]
        if cached then
            iconImg.Image = "rbxassetid://" .. tostring(cached)
            iconImg.ImageTransparency = 0
            iconTxt.Text = ""
        else
            task.spawn(function()
                local id = downloadIcon(icon)
                if id then
                    iconImg.Image = "rbxassetid://" .. tostring(id)
                    tween(iconTxt, 0.15, { TextTransparency = 1 })
                    tween(iconImg, 0.2, { ImageTransparency = 0 })
                end
            end)
        end
    end

    local label = makeLabel({
        Text = name, Color = theme.TextDim, TextSize = theme.TextSize,
        Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -40, 1, 0), Parent = self.Button,
    })

    self.Page = makeFrame({
        Size = UDim2.new(1, 0, 1, 0), Transparency = 1,
        Parent = window.PagesHolder, Name = "Page_" .. name,
    })
    self.Page.Visible = false

    self.Scroll = Instance.new("ScrollingFrame")
    self.Scroll.Size = UDim2.new(1, -16, 1, -16)
    self.Scroll.Position = UDim2.new(0, 8, 0, 8)
    self.Scroll.BackgroundTransparency = 1
    self.Scroll.BorderSizePixel = 0
    self.Scroll.ScrollBarThickness = 4
    self.Scroll.ScrollBarImageColor3 = theme.Accent
    self.Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.Scroll.Parent = self.Page
    local sl = Instance.new("UIListLayout"); sl.Padding = UDim.new(0, 10); sl.Parent = self.Scroll
    padding(0, 8, 0, 8).Parent = self.Scroll

    self.IconLabel = iconTxt
    self.IconImage = iconImg
    self.Label = label

    self.Button.MouseEnter:Connect(function()
        if not self.Active then
            tween(self.Button, theme.AnimationSpeed, { BackgroundColor3 = theme.PanelLight })
            tween(label, theme.AnimationSpeed, { TextColor3 = theme.Text })
            tween(iconTxt, theme.AnimationSpeed, { TextColor3 = theme.Text })
        end
    end)
    self.Button.MouseLeave:Connect(function()
        if not self.Active then
            tween(self.Button, theme.AnimationSpeed, { BackgroundColor3 = theme.Panel })
            tween(label, theme.AnimationSpeed, { TextColor3 = theme.TextDim })
            tween(iconTxt, theme.AnimationSpeed, { TextColor3 = theme.TextDim })
        end
    end)
    self.Button.MouseButton1Click:Connect(function() self:Select() end)

    return self
end

function Tab:Select()
    for _, t in ipairs(self.Window.Tabs) do
        t.Active = false
        t.Page.Visible = false
        tween(t.Button, self.Theme.AnimationSpeed, { BackgroundColor3 = self.Theme.Panel })
        tween(t.Label, self.Theme.AnimationSpeed, { TextColor3 = self.Theme.TextDim })
        tween(t.IconLabel, self.Theme.AnimationSpeed, { TextColor3 = self.Theme.TextDim })
    end
    self.Active = true
    self.Page.Visible = true
    tween(self.Button, self.Theme.AnimationSpeed, { BackgroundColor3 = self.Theme.PanelLight })
    tween(self.Label, self.Theme.AnimationSpeed, { TextColor3 = self.Theme.Accent })
    tween(self.IconLabel, self.Theme.AnimationSpeed, { TextColor3 = self.Theme.Accent })
end

function Tab:CreateSection(title)
    local th = self.Theme
    local section = makeFrame({
        Size = UDim2.new(1, 0, 0, 0), Color = th.Panel,
        CornerRadius = th.CornerRadius, Stroke = { th.Border, 1, 0.4 },
        Parent = self.Scroll, Name = "Section_" .. (title or ""),
    })
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.ClipsDescendants = true
    padding(28, 10, 12, 12).Parent = section

    makeLabel({
        Text = string.upper(title or "SECTION"), Color = th.Accent, TextSize = 13,
        Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -24, 0, 16), Parent = section,
    })

    local container = makeFrame({
        Size = UDim2.new(1, 0, 0, 0), Transparency = 1,
        Position = UDim2.new(0, 0, 0, 24), Parent = section, Name = "Container",
    })
    container.AutomaticSize = Enum.AutomaticSize.Y
    local cl = Instance.new("UIListLayout"); cl.Padding = UDim.new(0, 4); cl.Parent = container

    local obj = { Frame = section, Container = container, Components = {}, _theme = th }
    for _, name in ipairs({ "Toggle", "Slider", "Dropdown", "Keybind", "ColorPicker", "Button", "Label", "TextBox" }) do
        obj[name] = function(_, cfg)
            local c = Component[name](container, th, cfg)
            table.insert(obj.Components, c)
            return c
        end
    end

    table.insert(self.Sections, obj)
    return obj
end

local function autoSection(self)
    if not self.DefaultSection then self.DefaultSection = self:CreateSection("General") end
    return self.DefaultSection
end
for _, name in ipairs({ "Toggle", "Slider", "Dropdown", "Keybind", "ColorPicker", "Button", "Label", "TextBox" }) do
    Tab["Create" .. name] = function(self, cfg) return autoSection(self)[name](autoSection(self), cfg) end
end

local Window = {}
Window.__index = Window

function Window.new(lib, cfg)
    local self = setmetatable({}, Window)
    self.Lib = lib
    self.Theme = lib.Theme
    self.Tabs = {}

    local wname = cfg.Name or "Window"
    if CoreGui:FindFirstChild("oie_" .. wname) then CoreGui["oie_" .. wname]:Destroy() end

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "oie_" .. wname
    self.Gui.ResetOnSpawn = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.Parent = CoreGui

    local winSize = cfg.Size or UDim2.new(0, 640, 0, 440)
    self.Main = makeFrame({
        Size = winSize, Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        Color = self.Theme.Background, CornerRadius = self.Theme.CornerRadiusLg,
        Stroke = { self.Theme.Border, 1, 0.4 }, Parent = self.Gui, Name = "Main",
    })
    self.Main.ClipsDescendants = true

    local titleBar = makeFrame({
        Size = UDim2.new(1, 0, 0, 40), Color = self.Theme.Panel, Transparency = 1,
        Parent = self.Main, Name = "TitleBar",
    })

    makeLabel({
        Text = "◆", Color = self.Theme.Accent, TextSize = 16,
        Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0, 20, 1, 0),
        XAlign = Enum.TextXAlignment.Center, Parent = titleBar,
    })
    makeLabel({
        Text = cfg.Name or "oi.e", Color = self.Theme.Text, TextSize = self.Theme.TextSizeTitle,
        Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(0, 240, 1, 0), Parent = titleBar,
    })
    makeLabel({
        Text = cfg.Description or "v1.0", Color = self.Theme.TextDim, TextSize = 12,
        Position = UDim2.new(1, -100, 0, 0), Size = UDim2.new(0, 86, 1, 0),
        XAlign = Enum.TextXAlignment.Right, Parent = titleBar,
    })

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundColor3 = self.Theme.Danger
    closeBtn.BackgroundTransparency = 1
    closeBtn.AutoButtonColor = false
    closeBtn.Text = ""
    closeBtn.Parent = titleBar
    corner(self.Theme.CornerRadiusSm).Parent = closeBtn
    local closeIco = makeLabel({ Text = "✕", Color = self.Theme.TextDim, TextSize = 14,
        Size = UDim2.new(1, 0, 1, 0), XAlign = Enum.TextXAlignment.Center, Parent = closeBtn })
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, self.Theme.AnimationSpeed, { BackgroundTransparency = 0 })
        tween(closeIco, self.Theme.AnimationSpeed, { TextColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, self.Theme.AnimationSpeed, { BackgroundTransparency = 1 })
        tween(closeIco, self.Theme.AnimationSpeed, { TextColor3 = self.Theme.TextDim })
    end)
    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -66, 0.5, -14)
    minBtn.BackgroundColor3 = self.Theme.ToggleOff
    minBtn.BackgroundTransparency = 1
    minBtn.AutoButtonColor = false
    minBtn.Text = ""
    minBtn.Parent = titleBar
    corner(self.Theme.CornerRadiusSm).Parent = minBtn
    local minIco = makeLabel({ Text = "—", Color = self.Theme.TextDim, TextSize = 14,
        Size = UDim2.new(1, 0, 1, 0), XAlign = Enum.TextXAlignment.Center, Parent = minBtn })
    local minimized = false
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, self.Theme.AnimationSpeed, { BackgroundTransparency = 0 })
        tween(minIco, self.Theme.AnimationSpeed, { TextColor3 = self.Theme.Text })
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, self.Theme.AnimationSpeed, { BackgroundTransparency = 1 })
        tween(minIco, self.Theme.AnimationSpeed, { TextColor3 = self.Theme.TextDim })
    end)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(self.Main, 0.3, { Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 40) })
        else
            tween(self.Main, 0.3, { Size = winSize })
        end
    end)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 0, 40)
    sep.BackgroundColor3 = self.Theme.Border
    sep.BorderSizePixel = 0
    sep.BackgroundTransparency = 0.5
    sep.Parent = self.Main

    self.TabList = makeFrame({
        Size = UDim2.new(0, 150, 1, -41), Position = UDim2.new(0, 0, 0, 41),
        Color = self.Theme.Panel, Transparency = 1, Parent = self.Main, Name = "TabList",
    })
    padding(8, 8, 8, 8).Parent = self.TabList
    local tl = Instance.new("UIListLayout"); tl.Padding = UDim.new(0, 4); tl.Parent = self.TabList

    local sideSep = Instance.new("Frame")
    sideSep.Size = UDim2.new(0, 1, 1, 0)
    sideSep.Position = UDim2.new(0, 150, 0, 0)
    sideSep.BackgroundColor3 = self.Theme.Border
    sideSep.BorderSizePixel = 0
    sideSep.BackgroundTransparency = 0.5
    sideSep.Parent = self.Main

    self.PagesHolder = makeFrame({
        Size = UDim2.new(1, -150, 1, -41), Position = UDim2.new(0, 150, 0, 41),
        Transparency = 1, Parent = self.Main, Name = "PagesHolder",
    })

    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = self.Main.Position
        end
    end)
    titleBar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            tween(self.Main, 0.05, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y),
            }, Enum.EasingStyle.Linear)
        end
    end)

    self.Main.Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, winSize.Y.Scale, 0)
    task.wait()
    tween(self.Main, 0.4, { Size = winSize }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    if cfg.ToggleKey then
        UserInputService.InputBegan:Connect(function(i, gp)
            if not gp and i.KeyCode == cfg.ToggleKey then
                self.Main.Visible = not self.Main.Visible
            end
        end)
    end

    self.Lib.Notif.Parent = self.Gui
    return self
end

function Window:CreateTab(name, icon)
    local t = Tab.new(self, self.Theme, name, icon)
    table.insert(self.Tabs, t)
    if #self.Tabs == 1 then t:Select() end
    return t
end

function Window:Notify(title, text, duration, typee)
    self.Lib.Notif:Notify(title, text, duration, typee)
end

function Window:Destroy()
    if self.Gui then self.Gui:Destroy() end
end

local oi_e = {}
oi_e.__index = oi_e
oi_e.Theme = DefaultTheme
oi_e.IconCache = IconCache

function oi_e:LoadIcons(urls, onProgress, onDone)
    urls = urls or {}
    local total = #urls
    if total == 0 then if onDone then onDone() end return end
    for i, url in ipairs(urls) do
        if onProgress then onProgress(i, total, url) end
        downloadIcon(url)
    end
    if onDone then onDone() end
end

function oi_e:ShowSplash(opts)
    return Splash.new(opts)
end

function oi_e:CreateWindow(cfg)
    return Window.new(self, cfg or {})
end

function oi_e:SetTheme(key, value) self.Theme[key] = value end
function oi_e:GetTheme() return self.Theme end
function oi_e:SetAccent(c) self.Theme.Accent = c end
function oi_e:SetCornerRadius(px)
    self.Theme.CornerRadius = UDim.new(0, px)
    self.Theme.CornerRadiusSm = UDim.new(0, math.max(2, px - 3))
    self.Theme.CornerRadiusLg = UDim.new(0, px + 4)
end

local function boot()
    local noSplash = (getgenv and getgenv().oie_NoSplash) or false
    local icons = (getgenv and getgenv().oie_PreloadIcons) or {}

    local self = setmetatable({}, oi_e)
    self.Theme = DefaultTheme
    self.Notif = Notifications.new(self.Theme)
    self.Notif.Parent = CoreGui

    if noSplash then
        return self
    end

    local splash = Splash.new({ Title = "oi.e", Status = "Initializing..." })
    splash:SetProgress(0.05, "Loading library...")

    if #icons > 0 then
        splash:LoadAssets(icons, function()
            splash:Finish(function()
                if getgenv and getgenv().oie_OnLoaded then
                    getgenv().oie_OnLoaded(self)
                end
            end)
        end)
    else
        task.spawn(function()
            splash:SetProgress(0.3, "Building modules...")
            task.wait(0.25)
            splash:SetProgress(0.6, "Applying theme...")
            task.wait(0.25)
            splash:Finish(function()
                if getgenv and getgenv().oie_OnLoaded then
                    getgenv().oie_OnLoaded(self)
                end
            end)
        end)
    end

    return self
end

return boot
