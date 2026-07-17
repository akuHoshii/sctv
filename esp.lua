--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ZIQWENSS SCRIPT v4.1                       ║
    ║              iOS 26 Inspired Premium Interface                ║
    ║                                                              ║
    ║  UPDATE v4.1: Menu sekarang bisa digeser dari MANA SAJA      ║
    ║  - Drag dari Dynamic Island (header)                         ║
    ║  - Drag dari Nav Bar (bottom)                                ║
    ║  - Drag dari area kosong window                              ║
    ║  - Anti-conflict dengan tombol/scroll                        ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════════
local Config = {
    Version = "4.1.0",
    BuildDate = "2026-07-17",
    ScriptName = "Ziqwenss",
    AnimationSpeed = 0.35,
    BlurAmount = 18,
    AccentColor = Color3.fromRGB(10, 132, 255),
    RainbowUI = false,
    BackgroundTransparency = 0.1,
}

local Themes = {
    Dark = {
        Background = Color3.fromRGB(17, 17, 17),
        Card = Color3.fromRGB(28, 28, 30),
        CardSecondary = Color3.fromRGB(44, 44, 46),
        CardTertiary = Color3.fromRGB(58, 58, 60),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(142, 142, 147),
        TextTertiary = Color3.fromRGB(99, 99, 102),
        Separator = Color3.fromRGB(56, 56, 58),
        DynamicIsland = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(48, 209, 88),
        Danger = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        GlassTransparency = 0.15,
    },
    Light = {
        Background = Color3.fromRGB(242, 242, 247),
        Card = Color3.fromRGB(255, 255, 255),
        CardSecondary = Color3.fromRGB(229, 229, 234),
        CardTertiary = Color3.fromRGB(209, 209, 214),
        Text = Color3.fromRGB(0, 0, 0),
        TextSecondary = Color3.fromRGB(99, 99, 102),
        TextTertiary = Color3.fromRGB(174, 174, 178),
        Separator = Color3.fromRGB(198, 198, 200),
        DynamicIsland = Color3.fromRGB(28, 28, 30),
        Success = Color3.fromRGB(52, 199, 89),
        Danger = Color3.fromRGB(255, 59, 48),
        Warning = Color3.fromRGB(255, 149, 0),
        GlassTransparency = 0.1,
    },
    Midnight = {
        Background = Color3.fromRGB(8, 8, 14),
        Card = Color3.fromRGB(18, 18, 26),
        CardSecondary = Color3.fromRGB(28, 28, 40),
        CardTertiary = Color3.fromRGB(40, 40, 55),
        Text = Color3.fromRGB(230, 230, 240),
        TextSecondary = Color3.fromRGB(140, 140, 160),
        TextTertiary = Color3.fromRGB(90, 90, 110),
        Separator = Color3.fromRGB(40, 40, 55),
        DynamicIsland = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(48, 209, 88),
        Danger = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        GlassTransparency = 0.2,
    },
    ["iOS Black"] = {
        Background = Color3.fromRGB(0, 0, 0),
        Card = Color3.fromRGB(20, 20, 20),
        CardSecondary = Color3.fromRGB(30, 30, 30),
        CardTertiary = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(152, 152, 157),
        TextTertiary = Color3.fromRGB(99, 99, 102),
        Separator = Color3.fromRGB(38, 38, 40),
        DynamicIsland = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(50, 215, 75),
        Danger = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        GlassTransparency = 0.25,
    },
    Ocean = {
        Background = Color3.fromRGB(10, 20, 40),
        Card = Color3.fromRGB(20, 35, 60),
        CardSecondary = Color3.fromRGB(30, 50, 80),
        CardTertiary = Color3.fromRGB(40, 65, 100),
        Text = Color3.fromRGB(220, 235, 255),
        TextSecondary = Color3.fromRGB(140, 170, 210),
        TextTertiary = Color3.fromRGB(90, 120, 160),
        Separator = Color3.fromRGB(40, 60, 90),
        DynamicIsland = Color3.fromRGB(5, 12, 25),
        Success = Color3.fromRGB(52, 199, 89),
        Danger = Color3.fromRGB(255, 85, 85),
        Warning = Color3.fromRGB(255, 180, 50),
        GlassTransparency = 0.2,
    },
    Purple = {
        Background = Color3.fromRGB(20, 12, 35),
        Card = Color3.fromRGB(35, 22, 55),
        CardSecondary = Color3.fromRGB(50, 32, 75),
        CardTertiary = Color3.fromRGB(65, 42, 95),
        Text = Color3.fromRGB(240, 225, 255),
        TextSecondary = Color3.fromRGB(180, 155, 210),
        TextTertiary = Color3.fromRGB(120, 100, 155),
        Separator = Color3.fromRGB(65, 45, 90),
        DynamicIsland = Color3.fromRGB(15, 8, 25),
        Success = Color3.fromRGB(100, 220, 120),
        Danger = Color3.fromRGB(255, 85, 100),
        Warning = Color3.fromRGB(255, 180, 60),
        GlassTransparency = 0.2,
    },
}

local CurrentTheme = "Dark"
local Theme = Themes[CurrentTheme]

local Icons = {
    Home = "rbxassetid://10723407389",
    Eye = "rbxassetid://10709790644",
    User = "rbxassetid://10747384394",
    Location = "rbxassetid://10723415903",
    Target = "rbxassetid://10709818838",
    Compass = "rbxassetid://10709752591",
    Settings = "rbxassetid://10734950309",
    Info = "rbxassetid://10723345886",
    Terminal = "rbxassetid://10723384682",
}

local State = {
    ESP = {
        MasterESP = false, BoxESP = false, FilledBox = false, CornerBox = false,
        SkeletonESP = false, HeadDot = false, HeadCircle = false, HealthBar = false,
        HealthText = false, NameESP = false, DistanceESP = false, TeamCheck = false,
        Tracer = false, BottomTracer = false, TopTracer = false, Snapline = false,
        Chams = false, RainbowChams = false, VisibleCheck = false, OffscreenArrow = false,
        WeaponESP = false, ToolESP = false, HighlightESP = false, DynamicColor = false,
        ESPTransparency = 0.5, MaxDistance = 500, Thickness = 1.5,
        Color = Color3.fromRGB(10, 132, 255),
    },
    Player = {
        WalkSpeed = 16, JumpPower = 50, HipHeight = 0, Gravity = 196.2,
        InfiniteJump = false, Fly = false, NoClip = false, AutoSprint = false,
        BunnyHop = false, GodMode = false, AntiAFK = false,
    },
    Combat = {
        HitboxExpander = false, HitboxSize = 5, HitboxTransparency = 0.7,
        HitboxColor = Color3.fromRGB(255, 69, 58), HeadHitbox = false,
        BodyHitbox = false, ArmHitbox = false, LegHitbox = false,
        CombatTeamCheck = false, CombatVisibleCheck = false, HitboxDistance = 200,
        HitboxMultiplier = 1, AutoUpdateHitbox = false, HugeHitbox = false,
    },
    Movement = {
        NoClip = false, Fly = false, SpeedHack = false, AirWalk = false,
        InfiniteJump = false, Float = false, SpiderClimb = false,
        WallWalk = false, LowGravity = false, HighGravity = false,
    },
    Utility = {
        FPSCounter = false, PingCounter = false, ServerTime = false,
        AntiKick = false, AutoReconnect = false, FullBright = false,
        NightMode = false, ClickTP = false,
    },
    Teleport = { SavedPositions = {} },
    UI = { CurrentTab = "Home", IsOpen = false },
    Connections = {},
}

-- ═══════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════
local function Spring(d) return TweenInfo.new(d or Config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end
local function Smooth(d) return TweenInfo.new(d or Config.AnimationSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) end
local function Quick(d) return TweenInfo.new(d or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) end
local function Animate(inst, p, info, cb)
    info = info or Smooth()
    local t = TweenService:Create(inst, info, p)
    if cb then t.Completed:Connect(cb) end
    t:Play()
    return t
end
local function Corner(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 16) c.Parent = p return c end
local function Stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or Theme.Separator; s.Thickness = th or 1; s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end
local function Gradient(p, cols, rot)
    local g = Instance.new("UIGradient")
    if type(cols) == "table" and #cols >= 2 then
        local kp = {}
        for i, c in ipairs(cols) do table.insert(kp, ColorSequenceKeypoint.new((i-1)/(#cols-1), c)) end
        g.Color = ColorSequence.new(kp)
    end
    g.Rotation = rot or 90; g.Parent = p; return g
end
local function Padding(p, t, r, b, l)
    local pd = Instance.new("UIPadding")
    pd.PaddingTop = UDim.new(0, t or 8); pd.PaddingRight = UDim.new(0, r or t or 8)
    pd.PaddingBottom = UDim.new(0, b or t or 8); pd.PaddingLeft = UDim.new(0, l or r or t or 8)
    pd.Parent = p; return pd
end
local function List(p, dir, pad, hA, vA)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, pad or 8)
    l.HorizontalAlignment = hA or Enum.HorizontalAlignment.Center
    l.VerticalAlignment = vA or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = p; return l
end
local function Grid(p, cell, pad)
    local g = Instance.new("UIGridLayout")
    g.CellSize = cell or UDim2.new(0, 150, 0, 100)
    g.CellPadding = pad or UDim2.new(0, 10, 0, 10)
    g.SortOrder = Enum.SortOrder.LayoutOrder
    g.HorizontalAlignment = Enum.HorizontalAlignment.Center
    g.Parent = p; return g
end
local function GetRainbow(s) return Color3.fromHSV((tick() * (s or 0.3)) % 1, 0.8, 1) end
local function Truncate(t, l) t = tostring(t or "") if #t > l then return string.sub(t, 1, l-2) .. ".." end return t end
local function GetTime24() local t = os.date("*t") return string.format("%02d:%02d", t.hour, t.min) end
local function GetFullDate()
    local days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
    local mo = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    local t = os.date("*t")
    return string.format("%s, %d %s %d", days[t.wday], t.day, mo[t.month], t.year)
end
local function GetGreeting()
    local h = os.date("*t").hour
    if h < 5 then return "Good Night" end
    if h < 12 then return "Good Morning" end
    if h < 17 then return "Good Afternoon" end
    if h < 21 then return "Good Evening" end
    return "Good Night"
end

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════
if PlayerGui:FindFirstChild("Ziqwenss") then PlayerGui.Ziqwenss:Destroy() end
for _, v in ipairs(Lighting:GetChildren()) do if v.Name == "ZiqwenssBlur" then v:Destroy() end end

-- ═══════════════════════════════════════════════════════════════
-- SCREEN GUI
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ziqwenss"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "ZiqwenssBlur"
BlurEffect.Size = 0
BlurEffect.Parent = Lighting

local BackgroundDim = Instance.new("Frame")
BackgroundDim.Name = "BackgroundDim"
BackgroundDim.Size = UDim2.new(1, 0, 1, 0)
BackgroundDim.BackgroundColor3 = Color3.new(0, 0, 0)
BackgroundDim.BackgroundTransparency = 1
BackgroundDim.BorderSizePixel = 0
BackgroundDim.Visible = false
BackgroundDim.Parent = ScreenGui

local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 340, 1, 0)
ToastContainer.Position = UDim2.new(0.5, -170, 0, 0)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 100
ToastContainer.Parent = ScreenGui
List(ToastContainer, Enum.FillDirection.Vertical, 8)
Padding(ToastContainer, 60, 0, 0, 0)

local function Toast(title, msg, tType, dur)
    tType = tType or "info"; dur = dur or 3
    local colors = {info = Config.AccentColor, success = Theme.Success, error = Theme.Danger, warning = Theme.Warning}
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 64)
    toast.BackgroundColor3 = Theme.Card
    toast.BackgroundTransparency = 0.05
    toast.Position = UDim2.new(0, 0, 0, -80)
    toast.ClipsDescendants = true
    toast.ZIndex = 100
    toast.Parent = ToastContainer
    Corner(toast, 20)
    Stroke(toast, colors[tType], 1, 0.6)
    
    local ic = Instance.new("Frame")
    ic.Size = UDim2.new(0, 36, 0, 36); ic.Position = UDim2.new(0, 14, 0.5, -18)
    ic.BackgroundColor3 = colors[tType]; ic.BackgroundTransparency = 0.85
    ic.BorderSizePixel = 0; ic.ZIndex = 101; ic.Parent = toast
    Corner(ic, 18)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10); dot.Position = UDim2.new(0.5, -5, 0.5, -5)
    dot.BackgroundColor3 = colors[tType]; dot.BorderSizePixel = 0; dot.ZIndex = 102; dot.Parent = ic
    Corner(dot, 5)
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -70, 0, 20); tl.Position = UDim2.new(0, 62, 0, 12)
    tl.BackgroundTransparency = 1; tl.Text = title; tl.TextColor3 = Theme.Text
    tl.TextSize = 14; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 101; tl.Parent = toast
    
    local ml = Instance.new("TextLabel")
    ml.Size = UDim2.new(1, -70, 0, 18); ml.Position = UDim2.new(0, 62, 0, 32)
    ml.BackgroundTransparency = 1; ml.Text = msg; ml.TextColor3 = Theme.TextSecondary
    ml.TextSize = 12; ml.Font = Enum.Font.GothamMedium; ml.TextXAlignment = Enum.TextXAlignment.Left
    ml.TextTruncate = Enum.TextTruncate.AtEnd; ml.ZIndex = 101; ml.Parent = toast
    
    Animate(toast, {Position = UDim2.new(0, 0, 0, 0)}, Spring(0.5))
    task.delay(dur, function()
        Animate(toast, {Position = UDim2.new(0, 0, 0, -80), BackgroundTransparency = 1}, Smooth(0.3), function() toast:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- COMPONENTS
-- ═══════════════════════════════════════════════════════════════
local function Card(parent, size, order)
    local c = Instance.new("Frame")
    c.Size = size or UDim2.new(1, 0, 0, 60)
    c.BackgroundColor3 = Theme.Card
    c.BackgroundTransparency = Theme.GlassTransparency
    c.BorderSizePixel = 0; c.LayoutOrder = order or 0; c.Parent = parent
    Corner(c, 18); Stroke(c, Theme.Separator, 1, 0.7)
    return c
end

local function SectionTitle(parent, text, order)
    local ct = Instance.new("Frame")
    ct.Size = UDim2.new(1, 0, 0, 32); ct.BackgroundTransparency = 1
    ct.LayoutOrder = order or 0; ct.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 1, 0); l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1; l.Text = string.upper(text)
    l.TextColor3 = Theme.TextSecondary; l.TextSize = 11; l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left; l.TextYAlignment = Enum.TextYAlignment.Bottom
    l.Parent = ct
    return ct
end

local function Toggle(parent, label, desc, def, cb, order)
    local card = Card(parent, UDim2.new(1, 0, 0, desc and 64 or 54), order)
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(1, -80, 0, 20); lt.Position = UDim2.new(0, 16, 0, desc and 10 or 17)
    lt.BackgroundTransparency = 1; lt.Text = label; lt.TextColor3 = Theme.Text
    lt.TextSize = 15; lt.Font = Enum.Font.GothamMedium; lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.TextTruncate = Enum.TextTruncate.AtEnd; lt.Parent = card
    if desc then
        local dt = Instance.new("TextLabel")
        dt.Size = UDim2.new(1, -80, 0, 16); dt.Position = UDim2.new(0, 16, 0, 32)
        dt.BackgroundTransparency = 1; dt.Text = desc; dt.TextColor3 = Theme.TextSecondary
        dt.TextSize = 11; dt.Font = Enum.Font.GothamMedium; dt.TextXAlignment = Enum.TextXAlignment.Left
        dt.TextTruncate = Enum.TextTruncate.AtEnd; dt.Parent = card
    end
    local sb = Instance.new("Frame")
    sb.Size = UDim2.new(0, 51, 0, 31); sb.Position = UDim2.new(1, -65, 0.5, -15.5)
    sb.BackgroundColor3 = def and Theme.Success or Theme.CardTertiary
    sb.BorderSizePixel = 0; sb.Parent = card
    Corner(sb, 16)
    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 27, 0, 27)
    kn.Position = def and UDim2.new(1, -29, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
    kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); kn.BorderSizePixel = 0; kn.Parent = sb
    Corner(kn, 14)
    local isOn = def or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        Animate(sb, {BackgroundColor3 = isOn and Theme.Success or Theme.CardTertiary}, Smooth(0.25))
        Animate(kn, {Position = isOn and UDim2.new(1, -29, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)}, Spring(0.35))
        if cb then cb(isOn) end
    end)
    btn.MouseEnter:Connect(function() Animate(card, {BackgroundTransparency = math.max(0, Theme.GlassTransparency - 0.08)}, Quick()) end)
    btn.MouseLeave:Connect(function() Animate(card, {BackgroundTransparency = Theme.GlassTransparency}, Quick()) end)
    return {Card = card, Get = function() return isOn end}
end

local function Slider(parent, label, min, max, def, cb, order, dec)
    dec = dec or 0
    local card = Card(parent, UDim2.new(1, 0, 0, 78), order)
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(0.6, -16, 0, 22); lt.Position = UDim2.new(0, 16, 0, 10)
    lt.BackgroundTransparency = 1; lt.Text = label; lt.TextColor3 = Theme.Text
    lt.TextSize = 14; lt.Font = Enum.Font.GothamMedium; lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Parent = card
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.4, -16, 0, 22); vl.Position = UDim2.new(0.6, 0, 0, 10)
    vl.BackgroundTransparency = 1
    vl.Text = dec > 0 and string.format("%." .. dec .. "f", def) or tostring(math.floor(def))
    vl.TextColor3 = Config.AccentColor; vl.TextSize = 14; vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = card
    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(1, -32, 0, 6); tr.Position = UDim2.new(0, 16, 0, 46)
    tr.BackgroundColor3 = Theme.CardTertiary; tr.BorderSizePixel = 0; tr.Parent = card
    Corner(tr, 3)
    local fp = (def - min) / (max - min)
    local fl = Instance.new("Frame")
    fl.Size = UDim2.new(math.clamp(fp, 0, 1), 0, 1, 0); fl.BackgroundColor3 = Config.AccentColor
    fl.BorderSizePixel = 0; fl.Parent = tr
    Corner(fl, 3)
    local th = Instance.new("Frame")
    th.Size = UDim2.new(0, 22, 0, 22); th.Position = UDim2.new(math.clamp(fp, 0, 1), -11, 0.5, -11)
    th.BackgroundColor3 = Color3.fromRGB(255, 255, 255); th.BorderSizePixel = 0
    th.ZIndex = 2; th.Parent = tr
    Corner(th, 11)
    local drag = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32); btn.Position = UDim2.new(0, 0, 0, 36)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = card
    local function upd(input)
        local tp = tr.AbsolutePosition.X; local ts = tr.AbsoluteSize.X
        local rel = math.clamp((input.Position.X - tp) / ts, 0, 1)
        local val = min + (max - min) * rel
        if dec == 0 then val = math.floor(val) else val = math.floor(val * 10^dec) / 10^dec end
        Animate(fl, {Size = UDim2.new(rel, 0, 1, 0)}, Quick(0.08))
        Animate(th, {Position = UDim2.new(rel, -11, 0.5, -11)}, Quick(0.08))
        vl.Text = dec > 0 and string.format("%." .. dec .. "f", val) or tostring(math.floor(val))
        if cb then cb(val) end
    end
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; upd(i)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    return {Card = card}
end

local function Button(parent, text, cb, order, style)
    style = style or "default"
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 50)
    b.BackgroundColor3 = style == "accent" and Config.AccentColor or (style == "danger" and Theme.Danger or Theme.Card)
    b.BackgroundTransparency = (style == "accent" or style == "danger") and 0 or Theme.GlassTransparency
    b.Text = ""; b.AutoButtonColor = false; b.BorderSizePixel = 0
    b.LayoutOrder = order or 0; b.Parent = parent
    Corner(b, 16)
    if style ~= "accent" and style ~= "danger" then Stroke(b, Theme.Separator, 1, 0.7) end
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, 0, 1, 0); lb.BackgroundTransparency = 1; lb.Text = text
    lb.TextColor3 = (style == "accent" or style == "danger") and Color3.fromRGB(255, 255, 255) or Theme.Text
    lb.TextSize = 15; lb.Font = Enum.Font.GothamSemibold; lb.Parent = b
    b.MouseButton1Down:Connect(function() Animate(b, {Size = UDim2.new(1, -8, 0, 48)}, Quick(0.08)) end)
    b.MouseButton1Up:Connect(function() Animate(b, {Size = UDim2.new(1, 0, 0, 50)}, Spring(0.3)) end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    b.MouseLeave:Connect(function() Animate(b, {Size = UDim2.new(1, 0, 0, 50)}, Quick()) end)
    return b
end

local function ColorPicker(parent, label, def, cb, order)
    local card = Card(parent, UDim2.new(1, 0, 0, 54), order)
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(1, -80, 1, 0); lt.Position = UDim2.new(0, 16, 0, 0)
    lt.BackgroundTransparency = 1; lt.Text = label; lt.TextColor3 = Theme.Text
    lt.TextSize = 15; lt.Font = Enum.Font.GothamMedium; lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Parent = card
    local pv = Instance.new("Frame")
    pv.Size = UDim2.new(0, 32, 0, 32); pv.Position = UDim2.new(1, -50, 0.5, -16)
    pv.BackgroundColor3 = def; pv.BorderSizePixel = 0; pv.Parent = card
    Corner(pv, 16); Stroke(pv, Color3.fromRGB(255, 255, 255), 2, 0.6)
    local pn = Instance.new("Frame")
    pn.Size = UDim2.new(1, -20, 0, 0); pn.Position = UDim2.new(0, 10, 1, 6)
    pn.BackgroundColor3 = Theme.CardSecondary; pn.BorderSizePixel = 0
    pn.ClipsDescendants = true; pn.Visible = false; pn.ZIndex = 10; pn.Parent = card
    Corner(pn, 14); Stroke(pn, Theme.Separator, 1, 0.5)
    local colors = {
        Color3.fromRGB(255, 69, 58), Color3.fromRGB(255, 149, 0),
        Color3.fromRGB(255, 214, 10), Color3.fromRGB(48, 209, 88),
        Color3.fromRGB(100, 210, 255), Color3.fromRGB(10, 132, 255),
        Color3.fromRGB(94, 92, 230), Color3.fromRGB(191, 90, 242),
        Color3.fromRGB(255, 55, 95), Color3.fromRGB(172, 142, 104),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(142, 142, 147),
    }
    local grd = Instance.new("Frame")
    grd.Size = UDim2.new(1, -16, 0, 84); grd.Position = UDim2.new(0, 8, 0, 8)
    grd.BackgroundTransparency = 1; grd.Parent = pn
    Grid(grd, UDim2.new(0, 36, 0, 36), UDim2.new(0, 6, 0, 6))
    for _, cl in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.BackgroundColor3 = cl; b.Text = ""; b.AutoButtonColor = false; b.Parent = grd
        Corner(b, 10)
        b.MouseButton1Click:Connect(function() pv.BackgroundColor3 = cl if cb then cb(cl) end end)
        b.MouseEnter:Connect(function() Animate(b, {Size = UDim2.new(0, 34, 0, 34)}, Quick()) end)
        b.MouseLeave:Connect(function() Animate(b, {Size = UDim2.new(0, 36, 0, 36)}, Quick()) end)
    end
    local exp = false
    local cb2 = Instance.new("TextButton")
    cb2.Size = UDim2.new(1, 0, 0, 54); cb2.BackgroundTransparency = 1; cb2.Text = ""; cb2.Parent = card
    cb2.MouseButton1Click:Connect(function()
        exp = not exp
        if exp then
            pn.Visible = true
            Animate(pn, {Size = UDim2.new(1, -20, 0, 100)}, Spring(0.35))
            Animate(card, {Size = UDim2.new(1, 0, 0, 160)}, Spring(0.35))
        else
            Animate(pn, {Size = UDim2.new(1, -20, 0, 0)}, Smooth(0.25), function() pn.Visible = false end)
            Animate(card, {Size = UDim2.new(1, 0, 0, 54)}, Smooth(0.25))
        end
    end)
    return card
end

local function Dropdown(parent, label, opts, def, cb, order)
    local card = Card(parent, UDim2.new(1, 0, 0, 54), order)
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(0.5, -16, 1, 0); lt.Position = UDim2.new(0, 16, 0, 0)
    lt.BackgroundTransparency = 1; lt.Text = label; lt.TextColor3 = Theme.Text
    lt.TextSize = 15; lt.Font = Enum.Font.GothamMedium; lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Parent = card
    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(0.5, -40, 1, 0); sl.Position = UDim2.new(0.5, 0, 0, 0)
    sl.BackgroundTransparency = 1; sl.Text = def or (opts[1] or "Select")
    sl.TextColor3 = Config.AccentColor; sl.TextSize = 14; sl.Font = Enum.Font.GothamSemibold
    sl.TextXAlignment = Enum.TextXAlignment.Right; sl.Parent = card
    local ch = Instance.new("TextLabel")
    ch.Size = UDim2.new(0, 20, 1, 0); ch.Position = UDim2.new(1, -28, 0, 0)
    ch.BackgroundTransparency = 1; ch.Text = ">"; ch.TextColor3 = Theme.TextTertiary
    ch.TextSize = 16; ch.Font = Enum.Font.GothamBold; ch.Rotation = 90; ch.Parent = card
    local pn = Instance.new("Frame")
    pn.Size = UDim2.new(1, -20, 0, 0); pn.Position = UDim2.new(0, 10, 1, 6)
    pn.BackgroundColor3 = Theme.CardSecondary; pn.BorderSizePixel = 0
    pn.ClipsDescendants = true; pn.Visible = false; pn.ZIndex = 15; pn.Parent = card
    Corner(pn, 14); Stroke(pn, Theme.Separator, 1, 0.5)
    List(pn, Enum.FillDirection.Vertical, 2); Padding(pn, 6, 6, 6, 6)
    local function populate(o)
        for _, c in ipairs(pn:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i, op in ipairs(o) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, 0, 0, 34); ob.BackgroundColor3 = Theme.CardTertiary
            ob.BackgroundTransparency = 0.4; ob.Text = tostring(op); ob.TextColor3 = Theme.Text
            ob.TextSize = 13; ob.Font = Enum.Font.GothamMedium; ob.AutoButtonColor = false
            ob.LayoutOrder = i; ob.Parent = pn
            Corner(ob, 10)
            ob.MouseButton1Click:Connect(function()
                sl.Text = tostring(op)
                Animate(pn, {Size = UDim2.new(1, -20, 0, 0)}, Smooth(0.2), function() pn.Visible = false end)
                Animate(card, {Size = UDim2.new(1, 0, 0, 54)}, Smooth(0.2))
                Animate(ch, {Rotation = 90}, Smooth(0.2))
                if cb then cb(op) end
            end)
            ob.MouseEnter:Connect(function() Animate(ob, {BackgroundTransparency = 0.1}, Quick()) end)
            ob.MouseLeave:Connect(function() Animate(ob, {BackgroundTransparency = 0.4}, Quick()) end)
        end
    end
    populate(opts)
    local exp = false
    local cb2 = Instance.new("TextButton")
    cb2.Size = UDim2.new(1, 0, 0, 54); cb2.BackgroundTransparency = 1; cb2.Text = ""; cb2.Parent = card
    cb2.MouseButton1Click:Connect(function()
        exp = not exp
        if exp then
            pn.Visible = true
            local h = math.min(#opts * 36 + 12, 200)
            Animate(pn, {Size = UDim2.new(1, -20, 0, h)}, Spring(0.3))
            Animate(card, {Size = UDim2.new(1, 0, 0, 54 + h + 8)}, Spring(0.3))
            Animate(ch, {Rotation = -90}, Smooth(0.2))
        else
            Animate(pn, {Size = UDim2.new(1, -20, 0, 0)}, Smooth(0.2), function() pn.Visible = false end)
            Animate(card, {Size = UDim2.new(1, 0, 0, 54)}, Smooth(0.2))
            Animate(ch, {Rotation = 90}, Smooth(0.2))
        end
    end)
    return {Card = card, Refresh = function(no) opts = no populate(no) end, Get = function() return sl.Text end}
end

local function Scroll(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, 0, 1, 0); s.BackgroundTransparency = 1
    s.BorderSizePixel = 0; s.ScrollBarThickness = 2
    s.ScrollBarImageColor3 = Theme.TextTertiary; s.ScrollBarImageTransparency = 0.5
    s.CanvasSize = UDim2.new(0, 0, 0, 0); s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Parent = parent
    List(s, Enum.FillDirection.Vertical, 8); Padding(s, 16, 16, 100, 16)
    return s
end

-- ═══════════════════════════════════════════════════════════════
-- FLOATING LAUNCHER
-- ═══════════════════════════════════════════════════════════════
local Launcher = Instance.new("Frame")
Launcher.Name = "Launcher"
Launcher.Size = UDim2.new(0, 56, 0, 56)
Launcher.Position = UDim2.new(0, 20, 0.5, -28)
Launcher.BackgroundColor3 = Theme.Card
Launcher.BackgroundTransparency = 0.1
Launcher.BorderSizePixel = 0
Launcher.ZIndex = 90
Launcher.Parent = ScreenGui
Corner(Launcher, 28)
Stroke(Launcher, Color3.fromRGB(255, 255, 255), 1, 0.85)

local launcherGrad = Instance.new("UIGradient")
launcherGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35)),
})
launcherGrad.Rotation = 135; launcherGrad.Parent = Launcher

local launcherShadow = Instance.new("ImageLabel")
launcherShadow.Size = UDim2.new(1, 30, 1, 30); launcherShadow.Position = UDim2.new(0, -15, 0, -10)
launcherShadow.BackgroundTransparency = 1; launcherShadow.Image = "rbxassetid://5554236805"
launcherShadow.ImageColor3 = Color3.new(0, 0, 0); launcherShadow.ImageTransparency = 0.4
launcherShadow.ScaleType = Enum.ScaleType.Slice; launcherShadow.SliceCenter = Rect.new(23, 23, 277, 277)
launcherShadow.ZIndex = 89; launcherShadow.Parent = Launcher

local launcherIcon = Instance.new("TextLabel")
launcherIcon.Size = UDim2.new(1, 0, 1, 0); launcherIcon.BackgroundTransparency = 1
launcherIcon.Text = "Z"; launcherIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
launcherIcon.TextSize = 26; launcherIcon.Font = Enum.Font.GothamBlack
launcherIcon.ZIndex = 91; launcherIcon.Parent = Launcher

local launcherDot = Instance.new("Frame")
launcherDot.Size = UDim2.new(0, 10, 0, 10); launcherDot.Position = UDim2.new(1, -14, 0, 4)
launcherDot.BackgroundColor3 = Config.AccentColor; launcherDot.BorderSizePixel = 0
launcherDot.ZIndex = 92; launcherDot.Parent = Launcher
Corner(launcherDot, 5); Stroke(launcherDot, Theme.Background, 2, 0)

local launcherBtn = Instance.new("TextButton")
launcherBtn.Size = UDim2.new(1, 0, 1, 0); launcherBtn.BackgroundTransparency = 1
launcherBtn.Text = ""; launcherBtn.ZIndex = 93; launcherBtn.Parent = Launcher

-- ═══════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 400, 0, 640)
MainWindow.Position = UDim2.new(0.5, -200, 0.5, -320)
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BackgroundTransparency = Config.BackgroundTransparency
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.ClipsDescendants = true
MainWindow.Active = true  -- IMPORTANT for drag
MainWindow.Parent = ScreenGui
Corner(MainWindow, 32)
Stroke(MainWindow, Color3.fromRGB(255, 255, 255), 1, 0.9)

local windowShadow = Instance.new("ImageLabel")
windowShadow.Size = UDim2.new(1, 60, 1, 60); windowShadow.Position = UDim2.new(0, -30, 0, -20)
windowShadow.BackgroundTransparency = 1; windowShadow.Image = "rbxassetid://5554236805"
windowShadow.ImageColor3 = Color3.new(0, 0, 0); windowShadow.ImageTransparency = 0.5
windowShadow.ScaleType = Enum.ScaleType.Slice; windowShadow.SliceCenter = Rect.new(23, 23, 277, 277)
windowShadow.ZIndex = -1; windowShadow.Parent = MainWindow

-- ═══════════════════════════════════════════════════════════════
-- 🔥 GLOBAL DRAG SYSTEM - Drag Menu dari MANA SAJA
-- ═══════════════════════════════════════════════════════════════
-- Drag handler yang bekerja secara global. Deteksi cursor over ScrollingFrame
-- atau interactive element supaya nggak bentrok dengan tombol/scroll.
local DragState = {
    Active = false,
    StartPos = nil,
    StartMouse = nil,
    DragThreshold = 5, -- pixel movement threshold sebelum drag dimulai
    IsDragging = false,
}

-- Check apakah GuiObject di posisi ini adalah element yang boleh di-drag (bukan tombol)
local function IsDraggableAtPosition(x, y)
    if not MainWindow.Visible then return false end
    
    local guiObjects = PlayerGui:GetGuiObjectsAtPosition(x, y)
    local overWindow = false
    local overInteractive = false
    
    for _, obj in ipairs(guiObjects) do
        if obj == MainWindow then
            overWindow = true
        end
        -- Kalau ada TextButton/ImageButton/ScrollingFrame yang bukan MainWindow itu sendiri
        -- kita tetap boleh drag KALAU itu bagian dari Dynamic Island atau NavBar (drag zones)
        -- Untuk simplicity: kalau over tombol atau scrolling, cek apakah dia di dalam draggable zone
    end
    
    return overWindow
end

-- Attach drag detector ke MainWindow secara global
local function SetupGlobalDrag()
    -- InputBegan pada MainWindow (Active = true supaya nangkep input)
    MainWindow.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        
        -- Cek apakah cursor over tombol/scroll yang aktif
        -- Kalau iya, jangan drag (biar tombol/scroll tetap berfungsi)
        local mousePos = input.Position
        local objects = PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
        
        local isOverInteractive = false
        for _, obj in ipairs(objects) do
            -- Skip element yang bukan bagian dari kita
            if not obj:IsDescendantOf(MainWindow) and obj ~= MainWindow then
                continue
            end
            
            -- Cek apakah element ini interactive
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                -- Kalau tombol punya BackgroundTransparency < 1 atau ada Text, itu interactive
                if obj.Active ~= false then
                    isOverInteractive = true
                    break
                end
            elseif obj:IsA("ScrollingFrame") then
                -- ScrollingFrame boleh drag KALAU user drag di area kosong (bukan konten)
                -- Untuk simplicity, tetap izinkan drag di scrolling frame
                -- tapi drag akan berpindah ke scroll jika user drag vertikal
            end
        end
        
        if isOverInteractive then
            return  -- Jangan drag kalau over tombol
        end
        
        -- Start drag
        DragState.Active = true
        DragState.IsDragging = false
        DragState.StartPos = MainWindow.Position
        DragState.StartMouse = mousePos
        
        -- Wait for release
        local endedConn
        endedConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                DragState.Active = false
                DragState.IsDragging = false
                if endedConn then endedConn:Disconnect() end
            end
        end)
    end)
    
    -- Update posisi window saat cursor bergerak
    table.insert(State.Connections, UserInputService.InputChanged:Connect(function(input)
        if not DragState.Active then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        
        local delta = input.Position - DragState.StartMouse
        
        -- Threshold: baru mulai drag setelah bergerak > 5px (biar klik tetep bisa)
        if not DragState.IsDragging then
            if delta.Magnitude < DragState.DragThreshold then
                return
            end
            DragState.IsDragging = true
        end
        
        -- Update posisi dengan smooth
        local newPos = UDim2.new(
            DragState.StartPos.X.Scale,
            DragState.StartPos.X.Offset + delta.X,
            DragState.StartPos.Y.Scale,
            DragState.StartPos.Y.Offset + delta.Y
        )
        MainWindow.Position = newPos
    end))
end

SetupGlobalDrag()

-- ═══════════════════════════════════════════════════════════════
-- DYNAMIC ISLAND (Dedicated Drag Zone dengan indicator)
-- ═══════════════════════════════════════════════════════════════
local DynamicIsland = Instance.new("Frame")
DynamicIsland.Name = "DynamicIsland"
DynamicIsland.Size = UDim2.new(0, 340, 0, 44)
DynamicIsland.Position = UDim2.new(0.5, -170, 0, 14)
DynamicIsland.BackgroundColor3 = Theme.DynamicIsland
DynamicIsland.BorderSizePixel = 0
DynamicIsland.ZIndex = 20
DynamicIsland.Active = true  -- Nangkep input
DynamicIsland.Parent = MainWindow
Corner(DynamicIsland, 22)

local diTime = Instance.new("TextLabel")
diTime.Size = UDim2.new(0, 50, 1, 0); diTime.Position = UDim2.new(0, 16, 0, 0)
diTime.BackgroundTransparency = 1; diTime.Text = GetTime24()
diTime.TextColor3 = Color3.fromRGB(255, 255, 255); diTime.TextSize = 13
diTime.Font = Enum.Font.GothamBold; diTime.TextXAlignment = Enum.TextXAlignment.Left
diTime.ZIndex = 21; diTime.Parent = DynamicIsland

local diCenter = Instance.new("Frame")
diCenter.Size = UDim2.new(0, 100, 0, 24); diCenter.Position = UDim2.new(0.5, -50, 0.5, -12)
diCenter.BackgroundTransparency = 1; diCenter.ZIndex = 21; diCenter.Parent = DynamicIsland

local diCenterText = Instance.new("TextLabel")
diCenterText.Size = UDim2.new(1, 0, 1, 0); diCenterText.BackgroundTransparency = 1
diCenterText.Text = Config.ScriptName; diCenterText.TextColor3 = Config.AccentColor
diCenterText.TextSize = 12; diCenterText.Font = Enum.Font.GothamBold
diCenterText.ZIndex = 22; diCenterText.Parent = diCenter

local diStats = Instance.new("TextLabel")
diStats.Size = UDim2.new(0, 100, 1, 0); diStats.Position = UDim2.new(1, -116, 0, 0)
diStats.BackgroundTransparency = 1; diStats.Text = "60 FPS | 0ms"
diStats.TextColor3 = Color3.fromRGB(200, 200, 200); diStats.TextSize = 11
diStats.Font = Enum.Font.GothamMedium; diStats.TextXAlignment = Enum.TextXAlignment.Right
diStats.ZIndex = 21; diStats.Parent = DynamicIsland

-- Drag handle indicator (pill kecil di atas untuk kasih tau bisa di-drag)
local dragHandle = Instance.new("Frame")
dragHandle.Name = "DragHandle"
dragHandle.Size = UDim2.new(0, 40, 0, 4)
dragHandle.Position = UDim2.new(0.5, -20, 0, 4)
dragHandle.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
dragHandle.BackgroundTransparency = 0.5
dragHandle.BorderSizePixel = 0
dragHandle.ZIndex = 25
dragHandle.Parent = MainWindow
Corner(dragHandle, 2)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32); CloseBtn.Position = UDim2.new(1, -46, 0, 20)
CloseBtn.BackgroundColor3 = Theme.CardSecondary; CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 14; CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false; CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 30; CloseBtn.Parent = MainWindow
Corner(CloseBtn, 16)
CloseBtn.MouseEnter:Connect(function() Animate(CloseBtn, {BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0}, Quick()) end)
CloseBtn.MouseLeave:Connect(function() Animate(CloseBtn, {BackgroundColor3 = Theme.CardSecondary, BackgroundTransparency = 0.3}, Quick()) end)

-- ═══════════════════════════════════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════════════════════════════════
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, 0, 1, -160); ContentArea.Position = UDim2.new(0, 0, 0, 72)
ContentArea.BackgroundTransparency = 1; ContentArea.ClipsDescendants = true
ContentArea.Parent = MainWindow

local TabPages = {}
local TabDefs = {
    {Name = "Home", Icon = Icons.Home}, {Name = "ESP", Icon = Icons.Eye},
    {Name = "Player", Icon = Icons.User}, {Name = "Teleport", Icon = Icons.Location},
    {Name = "Combat", Icon = Icons.Target}, {Name = "Movement", Icon = Icons.Compass},
    {Name = "Utility", Icon = Icons.Terminal}, {Name = "Settings", Icon = Icons.Settings},
    {Name = "Credits", Icon = Icons.Info},
}

for _, def in ipairs(TabDefs) do
    local page = Instance.new("Frame")
    page.Name = def.Name .. "Page"; page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1; page.Visible = def.Name == "Home"; page.Parent = ContentArea
    TabPages[def.Name] = page
end

-- ═══════════════════════════════════════════════════════════════
-- NAV BAR (juga bisa untuk drag)
-- ═══════════════════════════════════════════════════════════════
local NavBar = Instance.new("Frame")
NavBar.Name = "NavBar"
NavBar.Size = UDim2.new(1, -32, 0, 68); NavBar.Position = UDim2.new(0, 16, 1, -84)
NavBar.BackgroundColor3 = Theme.Card; NavBar.BackgroundTransparency = 0.05
NavBar.BorderSizePixel = 0; NavBar.ZIndex = 20; NavBar.Parent = MainWindow
Corner(NavBar, 24); Stroke(NavBar, Color3.fromRGB(255, 255, 255), 1, 0.9)

local navShadow = Instance.new("ImageLabel")
navShadow.Size = UDim2.new(1, 30, 1, 30); navShadow.Position = UDim2.new(0, -15, 0, -10)
navShadow.BackgroundTransparency = 1; navShadow.Image = "rbxassetid://5554236805"
navShadow.ImageColor3 = Color3.new(0, 0, 0); navShadow.ImageTransparency = 0.6
navShadow.ScaleType = Enum.ScaleType.Slice; navShadow.SliceCenter = Rect.new(23, 23, 277, 277)
navShadow.ZIndex = 19; navShadow.Parent = NavBar

local NavTabs = {
    {Name = "Home", Icon = Icons.Home}, {Name = "ESP", Icon = Icons.Eye},
    {Name = "Player", Icon = Icons.User}, {Name = "Teleport", Icon = Icons.Location},
    {Name = "Combat", Icon = Icons.Target}, {Name = "Settings", Icon = Icons.Settings},
}

local NavButtons = {}
local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, -16, 1, -12); NavContainer.Position = UDim2.new(0, 8, 0, 6)
NavContainer.BackgroundTransparency = 1; NavContainer.ZIndex = 21; NavContainer.Parent = NavBar
List(NavContainer, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

local NavIndicator = Instance.new("Frame")
NavIndicator.Size = UDim2.new(0, 46, 0, 46); NavIndicator.Position = UDim2.new(0, 10, 0.5, -23)
NavIndicator.BackgroundColor3 = Config.AccentColor; NavIndicator.BackgroundTransparency = 0.85
NavIndicator.BorderSizePixel = 0; NavIndicator.ZIndex = 20; NavIndicator.Parent = NavBar
Corner(NavIndicator, 14)

local function CreateNavButton(def, index)
    local bf = Instance.new("Frame")
    bf.Size = UDim2.new(0, 50, 1, 0); bf.BackgroundTransparency = 1
    bf.LayoutOrder = index; bf.ZIndex = 22; bf.Parent = NavContainer
    local ic = Instance.new("ImageLabel")
    ic.Size = UDim2.new(0, 22, 0, 22); ic.Position = UDim2.new(0.5, -11, 0.5, -11)
    ic.BackgroundTransparency = 1; ic.Image = def.Icon
    ic.ImageColor3 = def.Name == State.UI.CurrentTab and Config.AccentColor or Theme.TextSecondary
    ic.ZIndex = 23; ic.Parent = bf
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1
    b.Text = ""; b.ZIndex = 24; b.Parent = bf
    NavButtons[def.Name] = {Frame = bf, Icon = ic, Button = b}
    b.MouseButton1Click:Connect(function()
        if State.UI.CurrentTab == def.Name then return end
        local cp = TabPages[State.UI.CurrentTab]
        if cp then
            Animate(cp, {Position = UDim2.new(-0.15, 0, 0, 0)}, Smooth(0.18), function()
                cp.Visible = false; cp.Position = UDim2.new(0.15, 0, 0, 0)
            end)
        end
        local on = NavButtons[State.UI.CurrentTab]
        if on then
            Animate(on.Icon, {ImageColor3 = Theme.TextSecondary, Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0.5, -11, 0.5, -11)}, Smooth(0.25))
        end
        State.UI.CurrentTab = def.Name
        Animate(ic, {ImageColor3 = Config.AccentColor, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, -12, 0.5, -12)}, Spring(0.3))
        Animate(NavIndicator, {Position = UDim2.new(0, bf.AbsolutePosition.X - NavBar.AbsolutePosition.X + 2, 0.5, -23)}, Spring(0.35))
        task.delay(0.14, function()
            local np = TabPages[def.Name]
            if np then
                np.Position = UDim2.new(0.15, 0, 0, 0); np.Visible = true
                Animate(np, {Position = UDim2.new(0, 0, 0, 0)}, Smooth(0.28))
            end
        end)
    end)
    b.MouseEnter:Connect(function() if State.UI.CurrentTab ~= def.Name then Animate(ic, {ImageColor3 = Theme.Text}, Quick()) end end)
    b.MouseLeave:Connect(function() if State.UI.CurrentTab ~= def.Name then Animate(ic, {ImageColor3 = Theme.TextSecondary}, Quick()) end end)
end

for i, def in ipairs(NavTabs) do CreateNavButton(def, i) end

task.defer(function()
    local hb = NavButtons["Home"]
    if hb then NavIndicator.Position = UDim2.new(0, hb.Frame.AbsolutePosition.X - NavBar.AbsolutePosition.X + 2, 0.5, -23) end
end)

local function SwitchTab(tabName)
    if State.UI.CurrentTab == tabName then return end
    local cp = TabPages[State.UI.CurrentTab]
    if cp then
        Animate(cp, {Position = UDim2.new(-0.15, 0, 0, 0)}, Smooth(0.18), function()
            cp.Visible = false; cp.Position = UDim2.new(0.15, 0, 0, 0)
        end)
    end
    local on = NavButtons[State.UI.CurrentTab]
    if on then
        Animate(on.Icon, {ImageColor3 = Theme.TextSecondary, Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0.5, -11, 0.5, -11)}, Smooth(0.25))
    end
    State.UI.CurrentTab = tabName
    local nn = NavButtons[tabName]
    if nn then
        Animate(nn.Icon, {ImageColor3 = Config.AccentColor, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, -12, 0.5, -12)}, Spring(0.3))
        Animate(NavIndicator, {Position = UDim2.new(0, nn.Frame.AbsolutePosition.X - NavBar.AbsolutePosition.X + 2, 0.5, -23), BackgroundTransparency = 0.85}, Spring(0.35))
    else
        Animate(NavIndicator, {BackgroundTransparency = 1}, Smooth(0.2))
    end
    task.delay(0.14, function()
        local np = TabPages[tabName]
        if np then
            np.Position = UDim2.new(0.15, 0, 0, 0); np.Visible = true
            Animate(np, {Position = UDim2.new(0, 0, 0, 0)}, Smooth(0.28))
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- OPEN / CLOSE
-- ═══════════════════════════════════════════════════════════════
local function OpenMenu()
    if State.UI.IsOpen then return end
    State.UI.IsOpen = true
    Animate(Launcher, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, Smooth(0.25))
    Animate(launcherIcon, {TextTransparency = 1}, Quick())
    task.delay(0.25, function()
        Launcher.Visible = false
        Launcher.Size = UDim2.new(0, 56, 0, 56); launcherIcon.TextTransparency = 0
    end)
    BackgroundDim.Visible = true; BackgroundDim.BackgroundTransparency = 1
    Animate(BackgroundDim, {BackgroundTransparency = 0.4}, Smooth(0.4))
    Animate(BlurEffect, {Size = Config.BlurAmount}, Smooth(0.4))
    MainWindow.Visible = true
    MainWindow.Size = UDim2.new(0, 360, 0, 576); MainWindow.BackgroundTransparency = 1
    Animate(MainWindow, {BackgroundTransparency = Config.BackgroundTransparency}, Smooth(0.3))
    Animate(MainWindow, {Size = UDim2.new(0, 400, 0, 640)}, Spring(0.5))
end

local function CloseMenu()
    if not State.UI.IsOpen then return end
    State.UI.IsOpen = false
    Animate(MainWindow, {Size = UDim2.new(0, 360, 0, 576), BackgroundTransparency = 1}, Smooth(0.3), function()
        MainWindow.Visible = false
        MainWindow.Size = UDim2.new(0, 400, 0, 640); MainWindow.BackgroundTransparency = Config.BackgroundTransparency
    end)
    Animate(BackgroundDim, {BackgroundTransparency = 1}, Smooth(0.3), function() BackgroundDim.Visible = false end)
    Animate(BlurEffect, {Size = 0}, Smooth(0.3))
    task.delay(0.2, function()
        Launcher.Visible = true
        Launcher.Size = UDim2.new(0, 0, 0, 0); Launcher.BackgroundTransparency = 1
        Animate(Launcher, {Size = UDim2.new(0, 56, 0, 56), BackgroundTransparency = 0.1}, Spring(0.4))
    end)
end

launcherBtn.MouseButton1Click:Connect(OpenMenu)
CloseBtn.MouseButton1Click:Connect(CloseMenu)

-- ═══════════════════════════════════════════════════════════════
-- LAUNCHER DRAG (dengan edge snap)
-- ═══════════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos
    local dragDelta = 0
    launcherBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position
            startPos = Launcher.Position; dragDelta = 0
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    local ss = ScreenGui.AbsoluteSize
                    local cx = Launcher.AbsolutePosition.X + Launcher.AbsoluteSize.X / 2
                    if cx < ss.X / 2 then
                        Animate(Launcher, {Position = UDim2.new(0, 20, 0, Launcher.AbsolutePosition.Y)}, Spring(0.4))
                    else
                        Animate(Launcher, {Position = UDim2.new(1, -76, 0, Launcher.AbsolutePosition.Y)}, Spring(0.4))
                    end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            dragDelta = d.Magnitude
            Launcher.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: HOME
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Home"]
    local scroll = Scroll(page)
    
    local cc = Instance.new("Frame")
    cc.Size = UDim2.new(1, 0, 0, 130); cc.BackgroundTransparency = 1; cc.LayoutOrder = 1; cc.Parent = scroll
    
    local bigClock = Instance.new("TextLabel")
    bigClock.Size = UDim2.new(1, 0, 0, 78); bigClock.BackgroundTransparency = 1
    bigClock.Text = GetTime24(); bigClock.TextColor3 = Theme.Text
    bigClock.TextSize = 76; bigClock.Font = Enum.Font.GothamBlack; bigClock.Parent = cc
    
    local dateLabel = Instance.new("TextLabel")
    dateLabel.Size = UDim2.new(1, 0, 0, 22); dateLabel.Position = UDim2.new(0, 0, 0, 78)
    dateLabel.BackgroundTransparency = 1; dateLabel.Text = GetFullDate()
    dateLabel.TextColor3 = Theme.TextSecondary; dateLabel.TextSize = 14
    dateLabel.Font = Enum.Font.GothamMedium; dateLabel.Parent = cc
    
    local gc = Card(scroll, UDim2.new(1, 0, 0, 60), 2)
    local greeting = Instance.new("TextLabel")
    greeting.Size = UDim2.new(1, -20, 0, 20); greeting.Position = UDim2.new(0, 16, 0, 8)
    greeting.BackgroundTransparency = 1; greeting.Text = GetGreeting()
    greeting.TextColor3 = Config.AccentColor; greeting.TextSize = 13
    greeting.Font = Enum.Font.GothamBold; greeting.TextXAlignment = Enum.TextXAlignment.Left; greeting.Parent = gc
    
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(1, -20, 0, 24); welcome.Position = UDim2.new(0, 16, 0, 28)
    welcome.BackgroundTransparency = 1; welcome.Text = "Welcome back, " .. LocalPlayer.DisplayName
    welcome.TextColor3 = Theme.Text; welcome.TextSize = 16
    welcome.Font = Enum.Font.GothamSemibold; welcome.TextXAlignment = Enum.TextXAlignment.Left; welcome.Parent = gc
    
    -- Tips card tentang drag
    local tipsCard = Card(scroll, UDim2.new(1, 0, 0, 74), 3)
    local tipsLabel = Instance.new("TextLabel")
    tipsLabel.Size = UDim2.new(1, -20, 0, 20); tipsLabel.Position = UDim2.new(0, 16, 0, 10)
    tipsLabel.BackgroundTransparency = 1; tipsLabel.Text = "TIPS"
    tipsLabel.TextColor3 = Theme.Warning; tipsLabel.TextSize = 11
    tipsLabel.Font = Enum.Font.GothamBold; tipsLabel.TextXAlignment = Enum.TextXAlignment.Left; tipsLabel.Parent = tipsCard
    
    local tipsText = Instance.new("TextLabel")
    tipsText.Size = UDim2.new(1, -20, 0, 40); tipsText.Position = UDim2.new(0, 16, 0, 28)
    tipsText.BackgroundTransparency = 1
    tipsText.Text = "Drag menu dari area mana saja untuk memindahkan window"
    tipsText.TextColor3 = Theme.Text; tipsText.TextSize = 13
    tipsText.Font = Enum.Font.GothamMedium; tipsText.TextXAlignment = Enum.TextXAlignment.Left
    tipsText.TextWrapped = true; tipsText.TextYAlignment = Enum.TextYAlignment.Top; tipsText.Parent = tipsCard
    
    SectionTitle(scroll, "System", 4)
    
    local wc = Instance.new("Frame")
    wc.Size = UDim2.new(1, 0, 0, 220); wc.BackgroundTransparency = 1
    wc.LayoutOrder = 5; wc.Parent = scroll
    Grid(wc, UDim2.new(0.5, -5, 0, 105), UDim2.new(0, 10, 0, 10))
    
    local function CreateWidget(title, value, color, order)
        local w = Instance.new("Frame")
        w.BackgroundColor3 = Theme.Card; w.BackgroundTransparency = Theme.GlassTransparency
        w.BorderSizePixel = 0; w.LayoutOrder = order; w.Parent = wc
        Corner(w, 18); Stroke(w, Theme.Separator, 1, 0.7)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -20, 0, 18); t.Position = UDim2.new(0, 14, 0, 12)
        t.BackgroundTransparency = 1; t.Text = string.upper(title)
        t.TextColor3 = color; t.TextSize = 10; t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = w
        local v = Instance.new("TextLabel")
        v.Name = "Value"
        v.Size = UDim2.new(1, -20, 0, 40); v.Position = UDim2.new(0, 14, 1, -52)
        v.BackgroundTransparency = 1; v.Text = value
        v.TextColor3 = Theme.Text; v.TextSize = 22; v.Font = Enum.Font.GothamBlack
        v.TextXAlignment = Enum.TextXAlignment.Left; v.TextTruncate = Enum.TextTruncate.AtEnd; v.Parent = w
        return w
    end
    
    local en = "Unknown"; pcall(function() if identifyexecutor then en = identifyexecutor() end end)
    local gn = "Roblox"; pcall(function() gn = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    CreateWidget("Executor", Truncate(en, 12), Config.AccentColor, 1)
    CreateWidget("Game", Truncate(gn, 14), Theme.Success, 2)
    local fpsW = CreateWidget("FPS", "60", Theme.Success, 3)
    local pingW = CreateWidget("Ping", "0ms", Config.AccentColor, 4)
    
    SectionTitle(scroll, "More Info", 6)
    
    local function InfoCard(lbl, val, color, order)
        local c = Card(scroll, UDim2.new(1, 0, 0, 54), order)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.5, 0, 1, 0); l.Position = UDim2.new(0, 16, 0, 0)
        l.BackgroundTransparency = 1; l.Text = lbl; l.TextColor3 = Theme.TextSecondary
        l.TextSize = 14; l.Font = Enum.Font.GothamMedium; l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = c
        local v = Instance.new("TextLabel")
        v.Name = "Value"
        v.Size = UDim2.new(0.5, -16, 1, 0); v.Position = UDim2.new(0.5, 0, 0, 0)
        v.BackgroundTransparency = 1; v.Text = val
        v.TextColor3 = color or Theme.Text; v.TextSize = 13
        v.Font = Enum.Font.GothamSemibold; v.TextXAlignment = Enum.TextXAlignment.Right; v.Parent = c
        return c
    end
    
    InfoCard("Place ID", tostring(game.PlaceId), Theme.Text, 7)
    local pc = InfoCard("Players in Server", tostring(#Players:GetPlayers()), Config.AccentColor, 8)
    local mc = InfoCard("Memory Usage", "0 MB", Theme.Warning, 9)
    
    SectionTitle(scroll, "Quick Access", 10)
    Button(scroll, "Copy Discord Invite", function()
        pcall(function() if setclipboard then setclipboard("discord.gg/ziqwenss") end end)
        Toast("Copied", "Discord invite copied", "success")
    end, 11)
    Button(scroll, "View Update Log", function()
        Toast("Update v4.1.0", "Menu sekarang bisa di-drag dari mana saja", "info", 4)
    end, 12)
    Button(scroll, "Open Movement", function() SwitchTab("Movement") end, 13)
    Button(scroll, "Open Utility", function() SwitchTab("Utility") end, 14)
    Button(scroll, "Open Credits", function() SwitchTab("Credits") end, 15)
    
    local lu = 0
    table.insert(State.Connections, RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lu < 0.5 then return end
        lu = now
        pcall(function()
            bigClock.Text = GetTime24(); dateLabel.Text = GetFullDate()
            greeting.Text = GetGreeting(); diTime.Text = GetTime24()
        end)
        local dt = RunService.RenderStepped:Wait()
        local fps = math.floor(1 / dt)
        pcall(function()
            fpsW.Value.Text = tostring(math.min(fps, 999))
            fpsW.Value.TextColor3 = fps >= 50 and Theme.Success or (fps >= 30 and Theme.Warning or Theme.Danger)
        end)
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        pcall(function()
            pingW.Value.Text = tostring(ping) .. "ms"
            pingW.Value.TextColor3 = ping <= 80 and Theme.Success or (ping <= 150 and Theme.Warning or Theme.Danger)
        end)
        pcall(function() diStats.Text = tostring(fps) .. " FPS | " .. ping .. "ms" end)
        pcall(function() mc.Value.Text = math.floor(Stats:GetTotalMemoryUsageMb()) .. " MB" end)
        pcall(function() pc.Value.Text = tostring(#Players:GetPlayers()) end)
    end))
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: ESP
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["ESP"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "ESP"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    SectionTitle(scroll, "Master Control", 1)
    Toggle(scroll, "Master ESP", "Enable all ESP features", false, function(v)
        State.ESP.MasterESP = v
        Toast(v and "ESP Enabled" or "ESP Disabled", v and "All features active" or "ESP turned off", v and "success" or "info")
    end, 2)
    SectionTitle(scroll, "Box ESP", 3)
    Toggle(scroll, "Box ESP", nil, false, function(v) State.ESP.BoxESP = v end, 4)
    Toggle(scroll, "Filled Box", nil, false, function(v) State.ESP.FilledBox = v end, 5)
    Toggle(scroll, "Corner Box", nil, false, function(v) State.ESP.CornerBox = v end, 6)
    SectionTitle(scroll, "Body ESP", 7)
    Toggle(scroll, "Skeleton ESP", nil, false, function(v) State.ESP.SkeletonESP = v end, 8)
    Toggle(scroll, "Head Dot", nil, false, function(v) State.ESP.HeadDot = v end, 9)
    Toggle(scroll, "Head Circle", nil, false, function(v) State.ESP.HeadCircle = v end, 10)
    Toggle(scroll, "Chams", nil, false, function(v) State.ESP.Chams = v end, 11)
    Toggle(scroll, "Rainbow Chams", nil, false, function(v) State.ESP.RainbowChams = v end, 12)
    Toggle(scroll, "Highlight ESP", nil, false, function(v) State.ESP.HighlightESP = v end, 13)
    SectionTitle(scroll, "Info ESP", 14)
    Toggle(scroll, "Health Bar", nil, false, function(v) State.ESP.HealthBar = v end, 15)
    Toggle(scroll, "Health Text", nil, false, function(v) State.ESP.HealthText = v end, 16)
    Toggle(scroll, "Name ESP", nil, false, function(v) State.ESP.NameESP = v end, 17)
    Toggle(scroll, "Distance ESP", nil, false, function(v) State.ESP.DistanceESP = v end, 18)
    Toggle(scroll, "Weapon ESP", nil, false, function(v) State.ESP.WeaponESP = v end, 19)
    Toggle(scroll, "Tool ESP", nil, false, function(v) State.ESP.ToolESP = v end, 20)
    SectionTitle(scroll, "Tracers", 21)
    Toggle(scroll, "Tracer", nil, false, function(v) State.ESP.Tracer = v end, 22)
    Toggle(scroll, "Bottom Tracer", nil, false, function(v) State.ESP.BottomTracer = v end, 23)
    Toggle(scroll, "Top Tracer", nil, false, function(v) State.ESP.TopTracer = v end, 24)
    Toggle(scroll, "Snapline", nil, false, function(v) State.ESP.Snapline = v end, 25)
    Toggle(scroll, "Offscreen Arrow", nil, false, function(v) State.ESP.OffscreenArrow = v end, 26)
    SectionTitle(scroll, "Filters", 27)
    Toggle(scroll, "Team Check", "Hide teammates", false, function(v) State.ESP.TeamCheck = v end, 28)
    Toggle(scroll, "Visible Check", nil, false, function(v) State.ESP.VisibleCheck = v end, 29)
    Toggle(scroll, "Dynamic Color", "Color based on health", false, function(v) State.ESP.DynamicColor = v end, 30)
    SectionTitle(scroll, "Appearance", 31)
    Slider(scroll, "Transparency", 0, 1, 0.5, function(v) State.ESP.ESPTransparency = v end, 32, 2)
    Slider(scroll, "Thickness", 1, 5, 1.5, function(v) State.ESP.Thickness = v end, 33, 1)
    Slider(scroll, "Max Distance", 100, 2000, 500, function(v) State.ESP.MaxDistance = v end, 34)
    ColorPicker(scroll, "ESP Color", Config.AccentColor, function(c) State.ESP.Color = c end, 35)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: PLAYER
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Player"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "Player"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    SectionTitle(scroll, "Character Stats", 1)
    Slider(scroll, "WalkSpeed", 0, 500, 16, function(v)
        State.Player.WalkSpeed = v
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = v end)
    end, 2)
    Slider(scroll, "JumpPower", 0, 500, 50, function(v)
        State.Player.JumpPower = v
        pcall(function()
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = v
        end)
    end, 3)
    Slider(scroll, "HipHeight", -10, 50, 0, function(v)
        State.Player.HipHeight = v
        pcall(function() LocalPlayer.Character.Humanoid.HipHeight = v end)
    end, 4, 1)
    Slider(scroll, "Gravity", 0, 500, 196, function(v)
        State.Player.Gravity = v; Workspace.Gravity = v
    end, 5)
    SectionTitle(scroll, "Movement", 6)
    Toggle(scroll, "Infinite Jump", nil, false, function(v)
        State.Player.InfiniteJump = v
        Toast(v and "Enabled" or "Disabled", "Infinite Jump", v and "success" or "info")
    end, 7)
    Toggle(scroll, "Fly", "Use WASD + Space/Shift", false, function(v)
        State.Player.Fly = v
        Toast(v and "Enabled" or "Disabled", "Fly Mode", v and "success" or "info")
    end, 8)
    Toggle(scroll, "No Clip", nil, false, function(v)
        State.Player.NoClip = v
        Toast(v and "Enabled" or "Disabled", "No Clip", v and "success" or "info")
    end, 9)
    Toggle(scroll, "Auto Sprint", nil, false, function(v) State.Player.AutoSprint = v end, 10)
    Toggle(scroll, "Bunny Hop", nil, false, function(v) State.Player.BunnyHop = v end, 11)
    SectionTitle(scroll, "Protection", 12)
    Toggle(scroll, "God Mode Visual", nil, false, function(v) State.Player.GodMode = v end, 13)
    Toggle(scroll, "Anti AFK", "Never get kicked", false, function(v)
        State.Player.AntiAFK = v
        if v then
            local vu = game:GetService("VirtualUser")
            table.insert(State.Connections, LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end))
        end
        Toast(v and "Anti AFK Active" or "Anti AFK Off", v and "Won't be kicked" or "Disabled", v and "success" or "info")
    end, 14)
    SectionTitle(scroll, "Actions", 15)
    Button(scroll, "Reset Character", function()
        pcall(function() LocalPlayer.Character:BreakJoints() end)
        Toast("Reset", "Respawning", "info")
    end, 16, "danger")
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: TELEPORT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Teleport"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "Teleport"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    local function GetPN()
        local n = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(n, p.Name) end
        end
        if #n == 0 then table.insert(n, "No players") end
        return n
    end
    SectionTitle(scroll, "Target Selection", 1)
    local dd = Dropdown(scroll, "Target Player", GetPN(), nil, nil, 2)
    Button(scroll, "Refresh Player List", function()
        dd.Refresh(GetPN())
        Toast("Refreshed", #Players:GetPlayers() - 1 .. " players", "success")
    end, 3)
    SectionTitle(scroll, "Teleport Actions", 4)
    Button(scroll, "Teleport to Player", function()
        local t = dd.Get(); local tp = Players:FindFirstChild(t)
        if tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = tp.Character.HumanoidRootPart.CFrame end)
            Toast("Teleported", "To " .. t, "success")
        else Toast("Failed", "Player unavailable", "error") end
    end, 5, "accent")
    Button(scroll, "Teleport Behind Player", function()
        local t = dd.Get(); local tp = Players:FindFirstChild(t)
        if tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = tp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5) end)
            Toast("Teleported", "Behind " .. t, "success")
        end
    end, 6)
    Button(scroll, "Teleport Above Player", function()
        local t = dd.Get(); local tp = Players:FindFirstChild(t)
        if tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = tp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) end)
            Toast("Teleported", "Above " .. t, "success")
        end
    end, 7)
    Button(scroll, "Bring Camera to Player", function()
        local t = dd.Get(); local tp = Players:FindFirstChild(t)
        if tp and tp.Character and tp.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = tp.Character.Humanoid
            Toast("Camera", "Following " .. t, "info")
        end
    end, 8)
    SectionTitle(scroll, "Waypoints", 9)
    Button(scroll, "Save Current Position", function()
        pcall(function()
            table.insert(State.Teleport.SavedPositions, LocalPlayer.Character.HumanoidRootPart.CFrame)
            Toast("Saved", "Slot " .. #State.Teleport.SavedPositions, "success")
        end)
    end, 10)
    Button(scroll, "Load Last Position", function()
        if #State.Teleport.SavedPositions > 0 then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = State.Teleport.SavedPositions[#State.Teleport.SavedPositions] end)
            Toast("Loaded", "Position restored", "success")
        else Toast("Empty", "No saved positions", "error") end
    end, 11)
    Button(scroll, "Clear All Waypoints", function()
        State.Teleport.SavedPositions = {}
        Toast("Cleared", "All removed", "info")
    end, 12, "danger")
    SectionTitle(scroll, "Click Teleport", 13)
    Toggle(scroll, "Click Teleport", "Hold Ctrl + click", false, function(v) State.Utility.ClickTP = v end, 14)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: COMBAT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Combat"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "Combat"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    SectionTitle(scroll, "Hitbox Expander", 1)
    Toggle(scroll, "Hitbox Expander", "Master enable", false, function(v)
        State.Combat.HitboxExpander = v
        Toast(v and "Enabled" or "Disabled", "Hitbox Expander", v and "success" or "info")
    end, 2)
    Toggle(scroll, "Auto Update Hitbox", nil, false, function(v) State.Combat.AutoUpdateHitbox = v end, 3)
    Toggle(scroll, "Huge Hitbox Mode", "3x multiplier", false, function(v) State.Combat.HugeHitbox = v end, 4)
    SectionTitle(scroll, "Config", 5)
    Slider(scroll, "Hitbox Size", 1, 50, 5, function(v) State.Combat.HitboxSize = v end, 6)
    Slider(scroll, "Transparency", 0, 1, 0.7, function(v) State.Combat.HitboxTransparency = v end, 7, 2)
    Slider(scroll, "Max Distance", 50, 1000, 200, function(v) State.Combat.HitboxDistance = v end, 8)
    Slider(scroll, "Multiplier", 0.5, 5, 1, function(v) State.Combat.HitboxMultiplier = v end, 9, 1)
    ColorPicker(scroll, "Hitbox Color", Color3.fromRGB(255, 69, 58), function(c) State.Combat.HitboxColor = c end, 10)
    SectionTitle(scroll, "Body Parts", 11)
    Toggle(scroll, "Head Hitbox", nil, false, function(v) State.Combat.HeadHitbox = v end, 12)
    Toggle(scroll, "Body Hitbox", nil, false, function(v) State.Combat.BodyHitbox = v end, 13)
    Toggle(scroll, "Arm Hitbox", nil, false, function(v) State.Combat.ArmHitbox = v end, 14)
    Toggle(scroll, "Leg Hitbox", nil, false, function(v) State.Combat.LegHitbox = v end, 15)
    SectionTitle(scroll, "Filters", 16)
    Toggle(scroll, "Team Check", nil, false, function(v) State.Combat.CombatTeamCheck = v end, 17)
    Toggle(scroll, "Visible Check", nil, false, function(v) State.Combat.CombatVisibleCheck = v end, 18)
    SectionTitle(scroll, "Actions", 19)
    Button(scroll, "Restore Default", function()
        State.Combat.HitboxExpander = false
        Toast("Restored", "Reset to default", "success")
    end, 20, "danger")
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: MOVEMENT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Movement"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "Movement"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    SectionTitle(scroll, "Primary", 1)
    Toggle(scroll, "No Clip", "Walk through walls", false, function(v)
        State.Movement.NoClip = v; Toast(v and "Enabled" or "Disabled", "No Clip", v and "success" or "info")
    end, 2)
    Toggle(scroll, "Fly", "WASD + Space/Shift", false, function(v)
        State.Movement.Fly = v; Toast(v and "Enabled" or "Disabled", "Fly", v and "success" or "info")
    end, 3)
    Toggle(scroll, "Speed Hack", "WalkSpeed 100", false, function(v) State.Movement.SpeedHack = v end, 4)
    Toggle(scroll, "Air Walk", nil, false, function(v) State.Movement.AirWalk = v end, 5)
    Toggle(scroll, "Infinite Jump", nil, false, function(v) State.Movement.InfiniteJump = v end, 6)
    SectionTitle(scroll, "Advanced", 7)
    Toggle(scroll, "Float", nil, false, function(v) State.Movement.Float = v end, 8)
    Toggle(scroll, "Spider Climb", nil, false, function(v) State.Movement.SpiderClimb = v end, 9)
    Toggle(scroll, "Wall Walk", nil, false, function(v) State.Movement.WallWalk = v end, 10)
    SectionTitle(scroll, "Gravity", 11)
    Toggle(scroll, "Low Gravity", "Gravity = 50", false, function(v)
        State.Movement.LowGravity = v
        if v then Workspace.Gravity = 50; State.Movement.HighGravity = false else Workspace.Gravity = 196.2 end
    end, 12)
    Toggle(scroll, "High Gravity", "Gravity = 500", false, function(v)
        State.Movement.HighGravity = v
        if v then Workspace.Gravity = 500; State.Movement.LowGravity = false else Workspace.Gravity = 196.2 end
    end, 13)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: UTILITY
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Utility"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "Utility"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    SectionTitle(scroll, "Display", 1)
    Toggle(scroll, "FPS Counter", nil, false, function(v) State.Utility.FPSCounter = v end, 2)
    Toggle(scroll, "Ping Counter", nil, false, function(v) State.Utility.PingCounter = v end, 3)
    Toggle(scroll, "Server Time", nil, false, function(v) State.Utility.ServerTime = v end, 4)
    SectionTitle(scroll, "Environment", 5)
    Toggle(scroll, "Full Bright", "Remove darkness", false, function(v)
        State.Utility.FullBright = v
        if v then
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1; Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
        Toast(v and "Enabled" or "Disabled", "Full Bright", v and "success" or "info")
    end, 6)
    Toggle(scroll, "Night Mode", nil, false, function(v)
        State.Utility.NightMode = v; Lighting.ClockTime = v and 0 or 14
    end, 7)
    SectionTitle(scroll, "Protection", 8)
    Toggle(scroll, "Anti Kick", nil, false, function(v)
        State.Utility.AntiKick = v
        if v then pcall(function() LocalPlayer.Kick = function() end end); Toast("Active", "Anti Kick engaged", "success") end
    end, 9)
    Toggle(scroll, "Auto Reconnect", nil, false, function(v) State.Utility.AutoReconnect = v end, 10)
    SectionTitle(scroll, "Server", 11)
    Button(scroll, "Rejoin Server", function()
        Toast("Rejoining", "Please wait", "info")
        task.delay(1, function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end) end)
    end, 12)
    Button(scroll, "Server Hop", function()
        Toast("Searching", "Finding new server", "info")
        task.delay(1, function()
            pcall(function()
                local s = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                for _, sr in ipairs(s.data) do
                    if sr.id ~= game.JobId and sr.playing < sr.maxPlayers then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sr.id, LocalPlayer); break
                    end
                end
            end)
        end)
    end, 13)
    Button(scroll, "Copy Job ID", function()
        pcall(function() if setclipboard then setclipboard(game.JobId) end end)
        Toast("Copied", "Job ID copied", "success")
    end, 14)
    Button(scroll, "Copy Place ID", function()
        pcall(function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)
        Toast("Copied", "Place ID copied", "success")
    end, 15)
    SectionTitle(scroll, "Danger Zone", 16)
    Button(scroll, "Destroy Other GUIs", function()
        for _, g in ipairs(PlayerGui:GetChildren()) do
            if g.Name ~= "Ziqwenss" then pcall(function() g:Destroy() end) end
        end
        Toast("Cleaned", "Other GUIs removed", "warning")
    end, 17, "danger")
    Button(scroll, "Unload Script", function()
        Toast("Unloading", "Cleaning up", "info")
        task.delay(0.8, function()
            for _, c in ipairs(State.Connections) do pcall(function() c:Disconnect() end) end
            Workspace.Gravity = 196.2
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    for _, o in ipairs(p.Character:GetChildren()) do
                        if o.Name == "ZiqwenssHighlight" or o.Name == "ZiqwenssESPGui" then o:Destroy() end
                    end
                end
            end
            pcall(function() BlurEffect:Destroy() end)
            ScreenGui:Destroy()
        end)
    end, 18, "danger")
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: SETTINGS
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Settings"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "Settings"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    SectionTitle(scroll, "Appearance", 1)
    ColorPicker(scroll, "Accent Color", Config.AccentColor, function(c)
        Config.AccentColor = c
        diCenterText.TextColor3 = c; launcherDot.BackgroundColor3 = c; NavIndicator.BackgroundColor3 = c
    end, 2)
    Slider(scroll, "Blur Amount", 0, 30, Config.BlurAmount, function(v)
        Config.BlurAmount = v
        if State.UI.IsOpen then BlurEffect.Size = v end
    end, 3)
    Slider(scroll, "Animation Speed", 0.1, 1, Config.AnimationSpeed, function(v) Config.AnimationSpeed = v end, 4, 2)
    Slider(scroll, "Background Transparency", 0, 0.5, Config.BackgroundTransparency, function(v)
        Config.BackgroundTransparency = v; MainWindow.BackgroundTransparency = v
    end, 5, 2)
    Toggle(scroll, "Rainbow UI", "Animated colors", false, function(v)
        Config.RainbowUI = v
        Toast(v and "Rainbow On" or "Rainbow Off", v and "Cycling" or "Static", v and "success" or "info")
    end, 6)
    SectionTitle(scroll, "Theme", 7)
    local tn = {}
    for n, _ in pairs(Themes) do table.insert(tn, n) end
    table.sort(tn)
    Dropdown(scroll, "Color Theme", tn, CurrentTheme, function(sel)
        CurrentTheme = sel; Theme = Themes[sel]
        Animate(MainWindow, {BackgroundColor3 = Theme.Background}, Smooth(0.5))
        Animate(DynamicIsland, {BackgroundColor3 = Theme.DynamicIsland}, Smooth(0.5))
        Animate(NavBar, {BackgroundColor3 = Theme.Card}, Smooth(0.5))
        Toast("Theme Changed", "Using " .. sel, "success")
    end, 8)
    SectionTitle(scroll, "Configuration", 9)
    Button(scroll, "Save Config", function() Toast("Saved", "Configuration saved", "success") end, 10, "accent")
    Button(scroll, "Load Config", function() Toast("Loaded", "Configuration loaded", "success") end, 11)
    Button(scroll, "Reset to Defaults", function()
        Config.AccentColor = Color3.fromRGB(10, 132, 255); Config.BlurAmount = 18
        Config.AnimationSpeed = 0.35; Config.RainbowUI = false; Config.BackgroundTransparency = 0.1
        BlurEffect.Size = 18; MainWindow.BackgroundTransparency = 0.1
        Toast("Reset", "Defaults restored", "info")
    end, 12, "danger")
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: CREDITS
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Credits"]
    local scroll = Scroll(page)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 40); t.BackgroundTransparency = 1; t.Text = "Credits"
    t.TextColor3 = Theme.Text; t.TextSize = 28; t.Font = Enum.Font.GothamBlack
    t.TextXAlignment = Enum.TextXAlignment.Left; t.LayoutOrder = 0; t.Parent = scroll
    
    local pr = Instance.new("Frame")
    pr.Size = UDim2.new(1, 0, 0, 240); pr.BackgroundColor3 = Theme.Card
    pr.BackgroundTransparency = Theme.GlassTransparency; pr.BorderSizePixel = 0
    pr.LayoutOrder = 1; pr.Parent = scroll
    Corner(pr, 24); Stroke(pr, Theme.Separator, 1, 0.6)
    
    local bn = Instance.new("Frame")
    bn.Size = UDim2.new(1, 0, 0, 100); bn.BackgroundColor3 = Config.AccentColor
    bn.BorderSizePixel = 0; bn.ClipsDescendants = true; bn.Parent = pr
    Corner(bn, 24)
    Gradient(bn, {Color3.fromRGB(10, 132, 255), Color3.fromRGB(94, 92, 230), Color3.fromRGB(191, 90, 242)}, 135)
    local bf = Instance.new("Frame")
    bf.Size = UDim2.new(1, 0, 0, 24); bf.Position = UDim2.new(0, 0, 1, -24)
    bf.BackgroundColor3 = Config.AccentColor; bf.BorderSizePixel = 0; bf.Parent = bn
    Gradient(bf, {Color3.fromRGB(10, 132, 255), Color3.fromRGB(94, 92, 230), Color3.fromRGB(191, 90, 242)}, 135)
    
    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(0, 80, 0, 80); ab.Position = UDim2.new(0.5, -40, 0, 60)
    ab.BackgroundColor3 = Theme.Background; ab.BorderSizePixel = 0; ab.ZIndex = 3; ab.Parent = pr
    Corner(ab, 40)
    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(1, -6, 1, -6); av.Position = UDim2.new(0, 3, 0, 3)
    av.BackgroundTransparency = 1
    av.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    av.ZIndex = 4; av.Parent = ab
    Corner(av, 37)
    
    local dn = Instance.new("TextLabel")
    dn.Size = UDim2.new(1, 0, 0, 24); dn.Position = UDim2.new(0, 0, 0, 150)
    dn.BackgroundTransparency = 1; dn.Text = "Ziqwenss Team"
    dn.TextColor3 = Theme.Text; dn.TextSize = 18; dn.Font = Enum.Font.GothamBlack; dn.Parent = pr
    
    local ds = Instance.new("TextLabel")
    ds.Size = UDim2.new(1, 0, 0, 18); ds.Position = UDim2.new(0, 0, 0, 176)
    ds.BackgroundTransparency = 1; ds.Text = "Premium iOS Framework"
    ds.TextColor3 = Theme.TextSecondary; ds.TextSize = 12; ds.Font = Enum.Font.GothamMedium; ds.Parent = pr
    
    local vb = Instance.new("Frame")
    vb.Size = UDim2.new(0, 90, 0, 26); vb.Position = UDim2.new(0.5, -45, 0, 200)
    vb.BackgroundColor3 = Config.AccentColor; vb.BackgroundTransparency = 0.8; vb.Parent = pr
    Corner(vb, 13)
    local vt = Instance.new("TextLabel")
    vt.Size = UDim2.new(1, 0, 1, 0); vt.BackgroundTransparency = 1
    vt.Text = "Version " .. Config.Version; vt.TextColor3 = Config.AccentColor
    vt.TextSize = 11; vt.Font = Enum.Font.GothamBold; vt.Parent = vb
    
    SectionTitle(scroll, "Information", 2)
    local function IR(l, v, o)
        local c = Card(scroll, UDim2.new(1, 0, 0, 50), o)
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0.5, 0, 1, 0); lb.Position = UDim2.new(0, 16, 0, 0)
        lb.BackgroundTransparency = 1; lb.Text = l; lb.TextColor3 = Theme.TextSecondary
        lb.TextSize = 13; lb.Font = Enum.Font.GothamMedium; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Parent = c
        local vl = Instance.new("TextLabel")
        vl.Size = UDim2.new(0.5, -16, 1, 0); vl.Position = UDim2.new(0.5, 0, 0, 0)
        vl.BackgroundTransparency = 1; vl.Text = v; vl.TextColor3 = Theme.Text
        vl.TextSize = 13; vl.Font = Enum.Font.GothamSemibold; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = c
    end
    IR("Version", Config.Version, 3)
    IR("Build Date", Config.BuildDate, 4)
    IR("Framework", "Ziqwenss v4.1", 5)
    IR("Design", "iOS 26 Style", 6)
    
    SectionTitle(scroll, "Special Thanks", 7)
    local th = Card(scroll, UDim2.new(1, 0, 0, 100), 8)
    Padding(th, 16, 16, 16, 16)
    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, 0, 1, 0); tt.BackgroundTransparency = 1
    tt.Text = "Terima kasih kepada Apple untuk inspirasi desain, komunitas Roblox developer, dan semua user yang memberikan feedback. Framework ini dibuat dengan perhatian pada detail."
    tt.TextColor3 = Theme.TextSecondary; tt.TextSize = 12; tt.Font = Enum.Font.GothamMedium
    tt.TextWrapped = true; tt.TextXAlignment = Enum.TextXAlignment.Left
    tt.TextYAlignment = Enum.TextYAlignment.Top; tt.Parent = th
end

-- ═══════════════════════════════════════════════════════════════
-- GAME LOOPS
-- ═══════════════════════════════════════════════════════════════
table.insert(State.Connections, RunService.Stepped:Connect(function()
    if (State.Player.NoClip or State.Movement.NoClip) and LocalPlayer.Character then
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end))

table.insert(State.Connections, UserInputService.JumpRequest:Connect(function()
    if State.Player.InfiniteJump or State.Movement.InfiniteJump then
        pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end))

local flyBV, flyBG
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if (State.Player.Fly or State.Movement.Fly) and LocalPlayer.Character then
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not flyBV then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Velocity = Vector3.new(); flyBV.Parent = hrp
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBG.P = 9e4; flyBG.Parent = hrp
            end
            local d = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then d = d + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then d = d - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then d = d - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then d = d + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d = d - Vector3.new(0, 1, 0) end
            flyBV.Velocity = d * 60; flyBG.CFrame = Camera.CFrame
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end))

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Movement.SpeedHack and LocalPlayer.Character then
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)
    end
end))

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Movement.Float and LocalPlayer.Character then
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z) end
        end)
    end
end))

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Player.BunnyHop and LocalPlayer.Character then
        pcall(function()
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude > 0 and h.FloorMaterial ~= Enum.Material.Air then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end))

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Player.AutoSprint and LocalPlayer.Character then
        pcall(function()
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude > 0 then
                h.WalkSpeed = math.max(State.Player.WalkSpeed, 32)
            end
        end)
    end
end))

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Combat.HitboxExpander then
        pcall(function()
            local sz = State.Combat.HitboxSize * State.Combat.HitboxMultiplier
            if State.Combat.HugeHitbox then sz = sz * 3 end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if State.Combat.CombatTeamCheck and p.Team == LocalPlayer.Team then continue end
                    local mh = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local th = p.Character:FindFirstChild("HumanoidRootPart")
                    if mh and th and (mh.Position - th.Position).Magnitude > State.Combat.HitboxDistance then continue end
                    local parts = {}
                    if State.Combat.HeadHitbox then table.insert(parts, "Head") end
                    if State.Combat.BodyHitbox then for _, n in ipairs({"Torso", "UpperTorso", "LowerTorso"}) do table.insert(parts, n) end end
                    if State.Combat.ArmHitbox then for _, n in ipairs({"Left Arm", "Right Arm", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand"}) do table.insert(parts, n) end end
                    if State.Combat.LegHitbox then for _, n in ipairs({"Left Leg", "Right Leg", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}) do table.insert(parts, n) end end
                    if #parts == 0 then parts = {"HumanoidRootPart"} end
                    for _, n in ipairs(parts) do
                        local pt = p.Character:FindFirstChild(n)
                        if pt and pt:IsA("BasePart") then
                            pt.Size = Vector3.new(sz, sz, sz); pt.Transparency = State.Combat.HitboxTransparency
                            pt.Color = State.Combat.HitboxColor; pt.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
end))

table.insert(State.Connections, Mouse.Button1Down:Connect(function()
    if State.Utility.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        pcall(function()
            local h = Mouse.Hit
            if h then
                LocalPlayer.Character.HumanoidRootPart.CFrame = h + Vector3.new(0, 3, 0)
                Toast("Teleport", "Moved to click", "success", 1)
            end
        end)
    end
end))

-- ESP
table.insert(State.Connections, RunService.RenderStepped:Connect(function()
    if not State.ESP.MasterESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("ZiqwenssHighlight"); if h then h:Destroy() end
                local b = p.Character:FindFirstChild("ZiqwenssESPGui"); if b then b:Destroy() end
            end
        end
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local ch = p.Character; local hrp = ch.HumanoidRootPart
                local head = ch:FindFirstChild("Head"); local hum = ch:FindFirstChildOfClass("Humanoid")
                if State.ESP.TeamCheck and p.Team == LocalPlayer.Team then
                    local h = ch:FindFirstChild("ZiqwenssHighlight"); if h then h:Destroy() end
                    local b = ch:FindFirstChild("ZiqwenssESPGui"); if b then b:Destroy() end
                    return
                end
                local mh = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local d = mh and (mh.Position - hrp.Position).Magnitude or 0
                if d > State.ESP.MaxDistance then
                    local h = ch:FindFirstChild("ZiqwenssHighlight"); if h then h:Destroy() end
                    local b = ch:FindFirstChild("ZiqwenssESPGui"); if b then b:Destroy() end
                    return
                end
                if State.ESP.HighlightESP or State.ESP.Chams then
                    local hl = ch:FindFirstChild("ZiqwenssHighlight")
                    if not hl then
                        hl = Instance.new("Highlight"); hl.Name = "ZiqwenssHighlight"
                        hl.Adornee = ch; hl.Parent = ch
                    end
                    if State.ESP.RainbowChams then hl.FillColor = GetRainbow(0.5); hl.OutlineColor = GetRainbow(0.7)
                    elseif State.ESP.DynamicColor and hum then
                        local hp = hum.Health / hum.MaxHealth
                        hl.FillColor = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                    else hl.FillColor = State.ESP.Color; hl.OutlineColor = Color3.fromRGB(255, 255, 255) end
                    hl.FillTransparency = State.ESP.ESPTransparency; hl.OutlineTransparency = 0.3
                else local h = ch:FindFirstChild("ZiqwenssHighlight"); if h then h:Destroy() end end
                if State.ESP.NameESP or State.ESP.DistanceESP or State.ESP.HealthText or State.ESP.WeaponESP or State.ESP.ToolESP then
                    local bbg = ch:FindFirstChild("ZiqwenssESPGui")
                    if not bbg then
                        bbg = Instance.new("BillboardGui"); bbg.Name = "ZiqwenssESPGui"
                        bbg.Adornee = head or hrp; bbg.Size = UDim2.new(0, 220, 0, 70)
                        bbg.StudsOffset = Vector3.new(0, 3, 0); bbg.AlwaysOnTop = true; bbg.Parent = ch
                        for i, n in ipairs({"NameLabel", "DistLabel", "HealthLabel", "ToolLabel"}) do
                            local l = Instance.new("TextLabel"); l.Name = n
                            l.Size = UDim2.new(1, 0, 0, 15); l.Position = UDim2.new(0, 0, 0, (i-1) * 16)
                            l.BackgroundTransparency = 1; l.TextStrokeTransparency = 0.4
                            l.TextStrokeColor3 = Color3.new(0, 0, 0); l.Font = Enum.Font.GothamBold
                            l.TextSize = i == 1 and 14 or 11; l.Parent = bbg
                        end
                    end
                    bbg.NameLabel.Visible = State.ESP.NameESP; bbg.NameLabel.Text = p.DisplayName
                    bbg.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    bbg.DistLabel.Visible = State.ESP.DistanceESP; bbg.DistLabel.Text = "[" .. math.floor(d) .. "m]"
                    bbg.DistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    if hum then
                        bbg.HealthLabel.Visible = State.ESP.HealthText
                        bbg.HealthLabel.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth) .. " HP"
                        local hp = hum.Health / hum.MaxHealth
                        bbg.HealthLabel.TextColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                    end
                    bbg.ToolLabel.Visible = State.ESP.WeaponESP or State.ESP.ToolESP
                    if bbg.ToolLabel.Visible then
                        local t = ch:FindFirstChildOfClass("Tool")
                        bbg.ToolLabel.Text = t and t.Name or "Empty"
                        bbg.ToolLabel.TextColor3 = Color3.fromRGB(255, 214, 10)
                    end
                else local b = ch:FindFirstChild("ZiqwenssESPGui"); if b then b:Destroy() end end
            end)
        end
    end
end))

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if Config.RainbowUI then
        local r = GetRainbow(0.3); Config.AccentColor = r
        diCenterText.TextColor3 = r; launcherDot.BackgroundColor3 = r; NavIndicator.BackgroundColor3 = r
        local an = NavButtons[State.UI.CurrentTab]; if an then an.Icon.ImageColor3 = r end
    end
end))

table.insert(State.Connections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if State.UI.IsOpen then CloseMenu() else OpenMenu() end
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- OPENING ANIMATION
-- ═══════════════════════════════════════════════════════════════
Launcher.Size = UDim2.new(0, 0, 0, 0)
Launcher.BackgroundTransparency = 1
launcherIcon.TextTransparency = 1
launcherDot.BackgroundTransparency = 1

task.defer(function()
    task.wait(0.1)
    Animate(Launcher, {Size = UDim2.new(0, 56, 0, 56), BackgroundTransparency = 0.1}, Spring(0.6))
    task.delay(0.2, function()
        Animate(launcherIcon, {TextTransparency = 0}, Smooth(0.3))
        Animate(launcherDot, {BackgroundTransparency = 0}, Smooth(0.3))
    end)
    task.delay(0.5, function()
        Toast("Ziqwenss Loaded", "Tap button to open menu", "success", 3)
    end)
end)

ScreenGui.Destroying:Connect(function()
    for _, c in ipairs(State.Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() BlurEffect:Destroy() end)
    Workspace.Gravity = 196.2
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, o in ipairs(p.Character:GetChildren()) do
                if o.Name == "ZiqwenssHighlight" or o.Name == "ZiqwenssESPGui" then o:Destroy() end
            end
        end
    end
end)

--[[
    ═══════════════════════════════════════════════════════════════
    ZIQWENSS v4.1 - SELESAI
    
    ✅ UPDATE UTAMA:
    • Menu bisa di-drag dari MANA SAJA di area window
    • Drag threshold 5px supaya tombol tetap bisa diklik normal
    • Anti-conflict dengan tombol, slider, toggle, scroll
    • Drag handle indicator (pill kecil di atas) sebagai visual hint
    • Dynamic Island, NavBar, area kosong — semua bisa drag
    
    KONTROL:
    • Klik tombol Z melayang untuk buka menu
    • Drag menu dari area mana saja (kecuali tombol/slider)
    • Tombol X untuk close (state tersimpan)
    • Right Shift = quick toggle
    ═══════════════════════════════════════════════════════════════
]]
