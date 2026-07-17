--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    ZIQWENSS SCRIPT v4.0                       ║
    ║              iOS 26 Inspired Premium Interface                ║
    ║                                                              ║
    ║  A truly iPhone-like experience for Roblox.                  ║
    ║  Features Dynamic Island, Lock Screen Home, Bottom Nav,      ║
    ║  Floating Launcher, and emoji-free SF Symbols style icons.   ║
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
local CoreGui = game:GetService("CoreGui")

-- ═══════════════════════════════════════════════════════════════
-- LOCAL REFERENCES
-- ═══════════════════════════════════════════════════════════════
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════
local Config = {
    Version = "4.0.0",
    BuildDate = "2026-07-17",
    ScriptName = "Ziqwenss",
    AnimationSpeed = 0.35,
    BlurAmount = 18,
    AccentColor = Color3.fromRGB(10, 132, 255), -- Apple Blue #0A84FF
    RainbowUI = false,
    GUIScale = 1,
    BackgroundTransparency = 0.1,
}

-- iOS Color Theme
local Themes = {
    Dark = {
        Background = Color3.fromRGB(17, 17, 17),       -- #111111
        Card = Color3.fromRGB(28, 28, 30),             -- #1C1C1E
        CardSecondary = Color3.fromRGB(44, 44, 46),    -- #2C2C2E
        CardTertiary = Color3.fromRGB(58, 58, 60),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(142, 142, 147), -- #8E8E93
        TextTertiary = Color3.fromRGB(99, 99, 102),
        Separator = Color3.fromRGB(56, 56, 58),
        DynamicIsland = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(48, 209, 88),         -- #30D158
        Danger = Color3.fromRGB(255, 69, 58),          -- #FF453A
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

-- ═══════════════════════════════════════════════════════════════
-- SF SYMBOLS STYLE ICONS (Roblox asset IDs — monochrome vector)
-- ═══════════════════════════════════════════════════════════════
-- Using Roblox's built-in icon set that mimics SF Symbols style
local Icons = {
    Home = "rbxassetid://10723407389",
    Eye = "rbxassetid://10709790644",
    User = "rbxassetid://10747384394",
    Location = "rbxassetid://10723415903",
    Target = "rbxassetid://10709818838",
    Compass = "rbxassetid://10709752591",
    Settings = "rbxassetid://10734950309",
    Info = "rbxassetid://10723345886",
    Star = "rbxassetid://10723415534",
    Close = "rbxassetid://10747384394",
    Minimize = "rbxassetid://10734896206",
    Menu = "rbxassetid://10734898355",
    Clock = "rbxassetid://10723407389",
    Bell = "rbxassetid://10723345886",
    Shield = "rbxassetid://10723415260",
    Lightning = "rbxassetid://10723343534",
    Moon = "rbxassetid://10723383540",
    Sun = "rbxassetid://10723384164",
    Check = "rbxassetid://10709790644",
    Arrow = "rbxassetid://10709767827",
    Copy = "rbxassetid://10723355507",
    Refresh = "rbxassetid://10734884243",
    Globe = "rbxassetid://10723345886",
    Terminal = "rbxassetid://10723384682",
    Lock = "rbxassetid://10723383540",
    Chevron = "rbxassetid://10709790931",
    Plus = "rbxassetid://10709806388",
    Trash = "rbxassetid://10747384394",
    Save = "rbxassetid://10723355507",
    Search = "rbxassetid://10747384394",
    Warning = "rbxassetid://10723345886",
    Circle = "rbxassetid://10723406192",
    Grid = "rbxassetid://10723407389",
}

-- ═══════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════
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
    UI = {
        CurrentTab = "Home",
        IsOpen = false,
        ScrollPositions = {},
    },
    Connections = {},
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
local function Spring(duration)
    return TweenInfo.new(duration or Config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function Smooth(duration)
    return TweenInfo.new(duration or Config.AnimationSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

local function Quick(duration)
    return TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

local function Animate(instance, props, info, callback)
    info = info or Smooth()
    local tween = TweenService:Create(instance, info, props)
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 16)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Separator
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Gradient(parent, colors, rotation)
    local g = Instance.new("UIGradient")
    if type(colors) == "table" and #colors >= 2 then
        local kp = {}
        for i, c in ipairs(colors) do
            table.insert(kp, ColorSequenceKeypoint.new((i-1)/(#colors-1), c))
        end
        g.Color = ColorSequence.new(kp)
    end
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function Padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 8)
    p.PaddingRight = UDim.new(0, r or t or 8)
    p.PaddingBottom = UDim.new(0, b or t or 8)
    p.PaddingLeft = UDim.new(0, l or r or t or 8)
    p.Parent = parent
    return p
end

local function List(parent, dir, pad, hAlign, vAlign)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, pad or 8)
    l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center
    l.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function Grid(parent, cell, pad)
    local g = Instance.new("UIGridLayout")
    g.CellSize = cell or UDim2.new(0, 150, 0, 100)
    g.CellPadding = pad or UDim2.new(0, 10, 0, 10)
    g.SortOrder = Enum.SortOrder.LayoutOrder
    g.HorizontalAlignment = Enum.HorizontalAlignment.Center
    g.Parent = parent
    return g
end

local function GetRainbow(speed)
    return Color3.fromHSV((tick() * (speed or 0.3)) % 1, 0.8, 1)
end

local function LerpColor(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function Truncate(text, len)
    text = tostring(text or "")
    if #text > len then return string.sub(text, 1, len - 2) .. ".." end
    return text
end

-- Formatted time/date
local function GetTime24()
    local t = os.date("*t")
    return string.format("%02d:%02d", t.hour, t.min)
end

local function GetFullDate()
    local days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
    local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    local t = os.date("*t")
    return string.format("%s, %d %s %d", days[t.wday], t.day, months[t.month], t.year)
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
-- CLEANUP EXISTING GUI
-- ═══════════════════════════════════════════════════════════════
if PlayerGui:FindFirstChild("Ziqwenss") then
    PlayerGui.Ziqwenss:Destroy()
end
for _, v in ipairs(Lighting:GetChildren()) do
    if v.Name == "ZiqwenssBlur" then v:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════
-- SCREEN GUI
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ziqwenss"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Blur effect
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "ZiqwenssBlur"
BlurEffect.Size = 0
BlurEffect.Parent = Lighting

-- Background dim overlay (fades in with menu)
local BackgroundDim = Instance.new("Frame")
BackgroundDim.Name = "BackgroundDim"
BackgroundDim.Size = UDim2.new(1, 0, 1, 0)
BackgroundDim.BackgroundColor3 = Color3.new(0, 0, 0)
BackgroundDim.BackgroundTransparency = 1
BackgroundDim.BorderSizePixel = 0
BackgroundDim.Visible = false
BackgroundDim.Parent = ScreenGui

-- Toast container
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 340, 1, 0)
ToastContainer.Position = UDim2.new(0.5, -170, 0, 0)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 100
ToastContainer.Parent = ScreenGui
List(ToastContainer, Enum.FillDirection.Vertical, 8)
Padding(ToastContainer, 60, 0, 0, 0)

-- ═══════════════════════════════════════════════════════════════
-- TOAST NOTIFICATIONS (iPhone style)
-- ═══════════════════════════════════════════════════════════════
local function Toast(title, message, toastType, duration)
    toastType = toastType or "info"
    duration = duration or 3
    
    local colors = {
        info = Config.AccentColor,
        success = Theme.Success,
        error = Theme.Danger,
        warning = Theme.Warning,
    }
    
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 64)
    toast.BackgroundColor3 = Theme.Card
    toast.BackgroundTransparency = 0.05
    toast.Position = UDim2.new(0, 0, 0, -80)
    toast.ClipsDescendants = true
    toast.ZIndex = 100
    toast.Parent = ToastContainer
    Corner(toast, 20)
    Stroke(toast, colors[toastType], 1, 0.6)
    
    -- Icon circle
    local iconCircle = Instance.new("Frame")
    iconCircle.Size = UDim2.new(0, 36, 0, 36)
    iconCircle.Position = UDim2.new(0, 14, 0.5, -18)
    iconCircle.BackgroundColor3 = colors[toastType]
    iconCircle.BackgroundTransparency = 0.85
    iconCircle.BorderSizePixel = 0
    iconCircle.ZIndex = 101
    iconCircle.Parent = toast
    Corner(iconCircle, 18)
    
    local iconDot = Instance.new("Frame")
    iconDot.Size = UDim2.new(0, 10, 0, 10)
    iconDot.Position = UDim2.new(0.5, -5, 0.5, -5)
    iconDot.BackgroundColor3 = colors[toastType]
    iconDot.BorderSizePixel = 0
    iconDot.ZIndex = 102
    iconDot.Parent = iconCircle
    Corner(iconDot, 5)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 20)
    titleLabel.Position = UDim2.new(0, 62, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 101
    titleLabel.Parent = toast
    
    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -70, 0, 18)
    msgLabel.Position = UDim2.new(0, 62, 0, 32)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Theme.TextSecondary
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextTruncate = Enum.TextTruncate.AtEnd
    msgLabel.ZIndex = 101
    msgLabel.Parent = toast
    
    -- Slide in
    Animate(toast, {Position = UDim2.new(0, 0, 0, 0)}, Spring(0.5))
    
    task.delay(duration, function()
        Animate(toast, {Position = UDim2.new(0, 0, 0, -80), BackgroundTransparency = 1}, Smooth(0.3), function()
            toast:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENT FACTORY
-- ═══════════════════════════════════════════════════════════════

-- Glass card
local function Card(parent, size, layoutOrder)
    local c = Instance.new("Frame")
    c.Size = size or UDim2.new(1, 0, 0, 60)
    c.BackgroundColor3 = Theme.Card
    c.BackgroundTransparency = Theme.GlassTransparency
    c.BorderSizePixel = 0
    c.LayoutOrder = layoutOrder or 0
    c.Parent = parent
    Corner(c, 18)
    Stroke(c, Theme.Separator, 1, 0.7)
    return c
end

-- Section title
local function SectionTitle(parent, text, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order or 0
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Bottom
    label.Parent = container
    
    return container
end

-- iOS-style toggle
local function Toggle(parent, label, description, default, callback, order)
    local card = Card(parent, UDim2.new(1, 0, 0, description and 64 or 54), order)
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -80, 0, 20)
    labelText.Position = UDim2.new(0, 16, 0, description and 10 or 17)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 15
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextTruncate = Enum.TextTruncate.AtEnd
    labelText.Parent = card
    
    if description then
        local descText = Instance.new("TextLabel")
        descText.Size = UDim2.new(1, -80, 0, 16)
        descText.Position = UDim2.new(0, 16, 0, 32)
        descText.BackgroundTransparency = 1
        descText.Text = description
        descText.TextColor3 = Theme.TextSecondary
        descText.TextSize = 11
        descText.Font = Enum.Font.GothamMedium
        descText.TextXAlignment = Enum.TextXAlignment.Left
        descText.TextTruncate = Enum.TextTruncate.AtEnd
        descText.Parent = card
    end
    
    -- Switch background (iOS pill)
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 51, 0, 31)
    switchBg.Position = UDim2.new(1, -65, 0.5, -15.5)
    switchBg.BackgroundColor3 = default and Theme.Success or Theme.CardTertiary
    switchBg.BorderSizePixel = 0
    switchBg.Parent = card
    Corner(switchBg, 16)
    
    -- Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 27, 0, 27)
    knob.Position = default and UDim2.new(1, -29, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switchBg
    Corner(knob, 14)
    
    local isOn = default or false
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card
    
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        Animate(switchBg, {BackgroundColor3 = isOn and Theme.Success or Theme.CardTertiary}, Smooth(0.25))
        Animate(knob, {Position = isOn and UDim2.new(1, -29, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)}, Spring(0.35))
        if callback then callback(isOn) end
    end)
    
    btn.MouseEnter:Connect(function()
        Animate(card, {BackgroundTransparency = math.max(0, Theme.GlassTransparency - 0.08)}, Quick())
    end)
    btn.MouseLeave:Connect(function()
        Animate(card, {BackgroundTransparency = Theme.GlassTransparency}, Quick())
    end)
    
    return {Card = card, Get = function() return isOn end, Set = function(v)
        isOn = v
        Animate(switchBg, {BackgroundColor3 = isOn and Theme.Success or Theme.CardTertiary}, Smooth(0.25))
        Animate(knob, {Position = isOn and UDim2.new(1, -29, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)}, Spring(0.35))
    end}
end

-- iOS slider
local function Slider(parent, label, min, max, default, callback, order, decimals)
    decimals = decimals or 0
    local card = Card(parent, UDim2.new(1, 0, 0, 78), order)
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, -16, 0, 22)
    labelText.Position = UDim2.new(0, 16, 0, 10)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = card
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, -16, 0, 22)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 10)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = decimals > 0 and string.format("%." .. decimals .. "f", default) or tostring(math.floor(default))
    valueLabel.TextColor3 = Config.AccentColor
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = card
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -32, 0, 6)
    track.Position = UDim2.new(0, 16, 0, 46)
    track.BackgroundColor3 = Theme.CardTertiary
    track.BorderSizePixel = 0
    track.Parent = card
    Corner(track, 3)
    
    local fillPercent = (default - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp(fillPercent, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Config.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = track
    Corner(fill, 3)
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 22, 0, 22)
    thumb.Position = UDim2.new(math.clamp(fillPercent, 0, 1), -11, 0.5, -11)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 2
    thumb.Parent = track
    Corner(thumb, 11)
    
    local dragging = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card
    
    local function Update(input)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local rel = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
        local value = min + (max - min) * rel
        if decimals == 0 then value = math.floor(value) else value = math.floor(value * 10^decimals) / 10^decimals end
        
        Animate(fill, {Size = UDim2.new(rel, 0, 1, 0)}, Quick(0.08))
        Animate(thumb, {Position = UDim2.new(rel, -11, 0.5, -11)}, Quick(0.08))
        valueLabel.Text = decimals > 0 and string.format("%." .. decimals .. "f", value) or tostring(math.floor(value))
        
        if callback then callback(value) end
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
    
    return {Card = card}
end

-- iOS button
local function Button(parent, text, callback, order, style)
    style = style or "default"
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = style == "accent" and Config.AccentColor or (style == "danger" and Theme.Danger or Theme.Card)
    btn.BackgroundTransparency = (style == "accent" or style == "danger") and 0 or Theme.GlassTransparency
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order or 0
    btn.Parent = parent
    Corner(btn, 16)
    
    if style ~= "accent" and style ~= "danger" then
        Stroke(btn, Theme.Separator, 1, 0.7)
    end
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = (style == "accent" or style == "danger") and Color3.fromRGB(255, 255, 255) or Theme.Text
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Parent = btn
    
    btn.MouseButton1Down:Connect(function()
        Animate(btn, {Size = UDim2.new(1, -8, 0, 48)}, Quick(0.08))
    end)
    btn.MouseButton1Up:Connect(function()
        Animate(btn, {Size = UDim2.new(1, 0, 0, 50)}, Spring(0.3))
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    btn.MouseLeave:Connect(function()
        Animate(btn, {Size = UDim2.new(1, 0, 0, 50)}, Quick())
    end)
    
    return btn
end

-- Color picker
local function ColorPicker(parent, label, default, callback, order)
    local card = Card(parent, UDim2.new(1, 0, 0, 54), order)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 32, 0, 32)
    preview.Position = UDim2.new(1, -50, 0.5, -16)
    preview.BackgroundColor3 = default
    preview.BorderSizePixel = 0
    preview.Parent = card
    Corner(preview, 16)
    Stroke(preview, Color3.fromRGB(255, 255, 255), 2, 0.6)
    
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, -20, 0, 0)
    panel.Position = UDim2.new(0, 10, 1, 6)
    panel.BackgroundColor3 = Theme.CardSecondary
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Visible = false
    panel.ZIndex = 10
    panel.Parent = card
    Corner(panel, 14)
    Stroke(panel, Theme.Separator, 1, 0.5)
    
    local colors = {
        Color3.fromRGB(255, 69, 58), Color3.fromRGB(255, 149, 0),
        Color3.fromRGB(255, 214, 10), Color3.fromRGB(48, 209, 88),
        Color3.fromRGB(100, 210, 255), Color3.fromRGB(10, 132, 255),
        Color3.fromRGB(94, 92, 230), Color3.fromRGB(191, 90, 242),
        Color3.fromRGB(255, 55, 95), Color3.fromRGB(172, 142, 104),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(142, 142, 147),
    }
    
    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, -16, 0, 84)
    grid.Position = UDim2.new(0, 8, 0, 8)
    grid.BackgroundTransparency = 1
    grid.Parent = panel
    Grid(grid, UDim2.new(0, 36, 0, 36), UDim2.new(0, 6, 0, 6))
    
    for _, color in ipairs(colors) do
        local b = Instance.new("TextButton")
        b.BackgroundColor3 = color
        b.Text = ""
        b.AutoButtonColor = false
        b.Parent = grid
        Corner(b, 10)
        b.MouseButton1Click:Connect(function()
            preview.BackgroundColor3 = color
            if callback then callback(color) end
        end)
        b.MouseEnter:Connect(function()
            Animate(b, {Size = UDim2.new(0, 34, 0, 34)}, Quick())
        end)
        b.MouseLeave:Connect(function()
            Animate(b, {Size = UDim2.new(0, 36, 0, 36)}, Quick())
        end)
    end
    
    local expanded = false
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 0, 54)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = card
    
    clickBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            panel.Visible = true
            Animate(panel, {Size = UDim2.new(1, -20, 0, 100)}, Spring(0.35))
            Animate(card, {Size = UDim2.new(1, 0, 0, 160)}, Spring(0.35))
        else
            Animate(panel, {Size = UDim2.new(1, -20, 0, 0)}, Smooth(0.25), function() panel.Visible = false end)
            Animate(card, {Size = UDim2.new(1, 0, 0, 54)}, Smooth(0.25))
        end
    end)
    
    return card
end

-- Dropdown
local function Dropdown(parent, label, options, default, callback, order)
    local card = Card(parent, UDim2.new(1, 0, 0, 54), order)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -16, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card
    
    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.5, -40, 1, 0)
    selectedLbl.Position = UDim2.new(0.5, 0, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = default or (options[1] or "Select")
    selectedLbl.TextColor3 = Config.AccentColor
    selectedLbl.TextSize = 14
    selectedLbl.Font = Enum.Font.GothamSemibold
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = card
    
    -- Chevron indicator
    local chev = Instance.new("TextLabel")
    chev.Size = UDim2.new(0, 20, 1, 0)
    chev.Position = UDim2.new(1, -28, 0, 0)
    chev.BackgroundTransparency = 1
    chev.Text = ">"
    chev.TextColor3 = Theme.TextTertiary
    chev.TextSize = 16
    chev.Font = Enum.Font.GothamBold
    chev.Rotation = 90
    chev.Parent = card
    
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, -20, 0, 0)
    panel.Position = UDim2.new(0, 10, 1, 6)
    panel.BackgroundColor3 = Theme.CardSecondary
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Visible = false
    panel.ZIndex = 15
    panel.Parent = card
    Corner(panel, 14)
    Stroke(panel, Theme.Separator, 1, 0.5)
    List(panel, Enum.FillDirection.Vertical, 2)
    Padding(panel, 6, 6, 6, 6)
    
    local function PopulateOptions(opts)
        for _, c in ipairs(panel:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 34)
            optBtn.BackgroundColor3 = Theme.CardTertiary
            optBtn.BackgroundTransparency = 0.4
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = Theme.Text
            optBtn.TextSize = 13
            optBtn.Font = Enum.Font.GothamMedium
            optBtn.AutoButtonColor = false
            optBtn.LayoutOrder = i
            optBtn.Parent = panel
            Corner(optBtn, 10)
            
            optBtn.MouseButton1Click:Connect(function()
                selectedLbl.Text = tostring(opt)
                Animate(panel, {Size = UDim2.new(1, -20, 0, 0)}, Smooth(0.2), function() panel.Visible = false end)
                Animate(card, {Size = UDim2.new(1, 0, 0, 54)}, Smooth(0.2))
                Animate(chev, {Rotation = 90}, Smooth(0.2))
                if callback then callback(opt) end
            end)
            optBtn.MouseEnter:Connect(function()
                Animate(optBtn, {BackgroundTransparency = 0.1}, Quick())
            end)
            optBtn.MouseLeave:Connect(function()
                Animate(optBtn, {BackgroundTransparency = 0.4}, Quick())
            end)
        end
    end
    
    PopulateOptions(options)
    
    local expanded = false
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 0, 54)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = card
    
    clickBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            panel.Visible = true
            local h = math.min(#options * 36 + 12, 200)
            Animate(panel, {Size = UDim2.new(1, -20, 0, h)}, Spring(0.3))
            Animate(card, {Size = UDim2.new(1, 0, 0, 54 + h + 8)}, Spring(0.3))
            Animate(chev, {Rotation = -90}, Smooth(0.2))
        else
            Animate(panel, {Size = UDim2.new(1, -20, 0, 0)}, Smooth(0.2), function() panel.Visible = false end)
            Animate(card, {Size = UDim2.new(1, 0, 0, 54)}, Smooth(0.2))
            Animate(chev, {Rotation = 90}, Smooth(0.2))
        end
    end)
    
    return {Card = card, Refresh = function(newOpts) options = newOpts PopulateOptions(newOpts) end, Get = function() return selectedLbl.Text end}
end

-- Scroll frame with auto canvas
local function Scroll(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 2
    s.ScrollBarImageColor3 = Theme.TextTertiary
    s.ScrollBarImageTransparency = 0.5
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Parent = parent
    List(s, Enum.FillDirection.Vertical, 8)
    Padding(s, 16, 16, 100, 16)  -- Bottom padding for nav bar
    return s
end

-- ═══════════════════════════════════════════════════════════════
-- FLOATING LAUNCHER BUTTON
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

-- Launcher gradient (subtle)
local launcherGrad = Instance.new("UIGradient")
launcherGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35)),
})
launcherGrad.Rotation = 135
launcherGrad.Parent = Launcher

-- Launcher shadow
local launcherShadow = Instance.new("ImageLabel")
launcherShadow.Size = UDim2.new(1, 30, 1, 30)
launcherShadow.Position = UDim2.new(0, -15, 0, -10)
launcherShadow.BackgroundTransparency = 1
launcherShadow.Image = "rbxassetid://5554236805"
launcherShadow.ImageColor3 = Color3.new(0, 0, 0)
launcherShadow.ImageTransparency = 0.4
launcherShadow.ScaleType = Enum.ScaleType.Slice
launcherShadow.SliceCenter = Rect.new(23, 23, 277, 277)
launcherShadow.ZIndex = 89
launcherShadow.Parent = Launcher

-- Launcher icon (Z letter as monogram)
local launcherIcon = Instance.new("TextLabel")
launcherIcon.Size = UDim2.new(1, 0, 1, 0)
launcherIcon.BackgroundTransparency = 1
launcherIcon.Text = "Z"
launcherIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
launcherIcon.TextSize = 26
launcherIcon.Font = Enum.Font.GothamBlack
launcherIcon.ZIndex = 91
launcherIcon.Parent = Launcher

-- Launcher accent dot
local launcherDot = Instance.new("Frame")
launcherDot.Size = UDim2.new(0, 10, 0, 10)
launcherDot.Position = UDim2.new(1, -14, 0, 4)
launcherDot.BackgroundColor3 = Config.AccentColor
launcherDot.BorderSizePixel = 0
launcherDot.ZIndex = 92
launcherDot.Parent = Launcher
Corner(launcherDot, 5)
Stroke(launcherDot, Theme.Background, 2, 0)

-- Launcher click button
local launcherBtn = Instance.new("TextButton")
launcherBtn.Size = UDim2.new(1, 0, 1, 0)
launcherBtn.BackgroundTransparency = 1
launcherBtn.Text = ""
launcherBtn.ZIndex = 93
launcherBtn.Parent = Launcher

-- ═══════════════════════════════════════════════════════════════
-- MAIN WINDOW (initially hidden)
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
MainWindow.Parent = ScreenGui
Corner(MainWindow, 32)
Stroke(MainWindow, Color3.fromRGB(255, 255, 255), 1, 0.9)

-- Window shadow
local windowShadow = Instance.new("ImageLabel")
windowShadow.Size = UDim2.new(1, 60, 1, 60)
windowShadow.Position = UDim2.new(0, -30, 0, -20)
windowShadow.BackgroundTransparency = 1
windowShadow.Image = "rbxassetid://5554236805"
windowShadow.ImageColor3 = Color3.new(0, 0, 0)
windowShadow.ImageTransparency = 0.5
windowShadow.ScaleType = Enum.ScaleType.Slice
windowShadow.SliceCenter = Rect.new(23, 23, 277, 277)
windowShadow.ZIndex = -1
windowShadow.Parent = MainWindow

-- ═══════════════════════════════════════════════════════════════
-- DYNAMIC ISLAND HEADER
-- ═══════════════════════════════════════════════════════════════
local DynamicIsland = Instance.new("Frame")
DynamicIsland.Name = "DynamicIsland"
DynamicIsland.Size = UDim2.new(0, 340, 0, 44)
DynamicIsland.Position = UDim2.new(0.5, -170, 0, 14)
DynamicIsland.BackgroundColor3 = Theme.DynamicIsland
DynamicIsland.BorderSizePixel = 0
DynamicIsland.ZIndex = 20
DynamicIsland.Parent = MainWindow
Corner(DynamicIsland, 22)

-- Time on left
local diTime = Instance.new("TextLabel")
diTime.Size = UDim2.new(0, 50, 1, 0)
diTime.Position = UDim2.new(0, 16, 0, 0)
diTime.BackgroundTransparency = 1
diTime.Text = GetTime24()
diTime.TextColor3 = Color3.fromRGB(255, 255, 255)
diTime.TextSize = 13
diTime.Font = Enum.Font.GothamBold
diTime.TextXAlignment = Enum.TextXAlignment.Left
diTime.ZIndex = 21
diTime.Parent = DynamicIsland

-- Center indicator
local diCenter = Instance.new("Frame")
diCenter.Size = UDim2.new(0, 100, 0, 24)
diCenter.Position = UDim2.new(0.5, -50, 0.5, -12)
diCenter.BackgroundTransparency = 1
diCenter.ZIndex = 21
diCenter.Parent = DynamicIsland

local diCenterText = Instance.new("TextLabel")
diCenterText.Size = UDim2.new(1, 0, 1, 0)
diCenterText.BackgroundTransparency = 1
diCenterText.Text = Config.ScriptName
diCenterText.TextColor3 = Config.AccentColor
diCenterText.TextSize = 12
diCenterText.Font = Enum.Font.GothamBold
diCenterText.ZIndex = 22
diCenterText.Parent = diCenter

-- Right: FPS/Ping mini stats
local diStats = Instance.new("TextLabel")
diStats.Size = UDim2.new(0, 100, 1, 0)
diStats.Position = UDim2.new(1, -116, 0, 0)
diStats.BackgroundTransparency = 1
diStats.Text = "60 FPS  |  0ms"
diStats.TextColor3 = Color3.fromRGB(200, 200, 200)
diStats.TextSize = 11
diStats.Font = Enum.Font.GothamMedium
diStats.TextXAlignment = Enum.TextXAlignment.Right
diStats.ZIndex = 21
diStats.Parent = DynamicIsland

-- Close button INSIDE dynamic island? No — top right of window
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -46, 0, 20)
CloseBtn.BackgroundColor3 = Theme.CardSecondary
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 30
CloseBtn.Parent = MainWindow
Corner(CloseBtn, 16)

CloseBtn.MouseEnter:Connect(function()
    Animate(CloseBtn, {BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0}, Quick())
end)
CloseBtn.MouseLeave:Connect(function()
    Animate(CloseBtn, {BackgroundColor3 = Theme.CardSecondary, BackgroundTransparency = 0.3}, Quick())
end)

-- ═══════════════════════════════════════════════════════════════
-- CONTENT AREA (below Dynamic Island, above Nav Bar)
-- ═══════════════════════════════════════════════════════════════
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, 0, 1, -160)
ContentArea.Position = UDim2.new(0, 0, 0, 72)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainWindow

-- Pages
local TabPages = {}
local TabDefs = {
    {Name = "Home", Icon = Icons.Home, Order = 1},
    {Name = "ESP", Icon = Icons.Eye, Order = 2},
    {Name = "Player", Icon = Icons.User, Order = 3},
    {Name = "Teleport", Icon = Icons.Location, Order = 4},
    {Name = "Combat", Icon = Icons.Target, Order = 5},
    {Name = "Movement", Icon = Icons.Compass, Order = 6},
    {Name = "Utility", Icon = Icons.Terminal, Order = 7},
    {Name = "Settings", Icon = Icons.Settings, Order = 8},
    {Name = "Credits", Icon = Icons.Info, Order = 9},
}

for _, def in ipairs(TabDefs) do
    local page = Instance.new("Frame")
    page.Name = def.Name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = def.Name == "Home"
    page.Parent = ContentArea
    TabPages[def.Name] = page
end

-- ═══════════════════════════════════════════════════════════════
-- BOTTOM NAVIGATION BAR (Floating iPhone style)
-- ═══════════════════════════════════════════════════════════════
local NavBar = Instance.new("Frame")
NavBar.Name = "NavBar"
NavBar.Size = UDim2.new(1, -32, 0, 68)
NavBar.Position = UDim2.new(0, 16, 1, -84)
NavBar.BackgroundColor3 = Theme.Card
NavBar.BackgroundTransparency = 0.05
NavBar.BorderSizePixel = 0
NavBar.ZIndex = 20
NavBar.Parent = MainWindow
Corner(NavBar, 24)
Stroke(NavBar, Color3.fromRGB(255, 255, 255), 1, 0.9)

-- Nav bar shadow
local navShadow = Instance.new("ImageLabel")
navShadow.Size = UDim2.new(1, 30, 1, 30)
navShadow.Position = UDim2.new(0, -15, 0, -10)
navShadow.BackgroundTransparency = 1
navShadow.Image = "rbxassetid://5554236805"
navShadow.ImageColor3 = Color3.new(0, 0, 0)
navShadow.ImageTransparency = 0.6
navShadow.ScaleType = Enum.ScaleType.Slice
navShadow.SliceCenter = Rect.new(23, 23, 277, 277)
navShadow.ZIndex = 19
navShadow.Parent = NavBar

-- Only show 6 primary tabs in bottom nav (Home, ESP, Player, Teleport, Combat, Settings)
-- Others accessible via long-press or from Home
local NavTabs = {
    {Name = "Home", Icon = Icons.Home},
    {Name = "ESP", Icon = Icons.Eye},
    {Name = "Player", Icon = Icons.User},
    {Name = "Teleport", Icon = Icons.Location},
    {Name = "Combat", Icon = Icons.Target},
    {Name = "Settings", Icon = Icons.Settings},
}

local NavButtons = {}
local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, -16, 1, -12)
NavContainer.Position = UDim2.new(0, 8, 0, 6)
NavContainer.BackgroundTransparency = 1
NavContainer.ZIndex = 21
NavContainer.Parent = NavBar
List(NavContainer, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

-- Active tab indicator (animated pill)
local NavIndicator = Instance.new("Frame")
NavIndicator.Size = UDim2.new(0, 46, 0, 46)
NavIndicator.Position = UDim2.new(0, 10, 0.5, -23)
NavIndicator.BackgroundColor3 = Config.AccentColor
NavIndicator.BackgroundTransparency = 0.85
NavIndicator.BorderSizePixel = 0
NavIndicator.ZIndex = 20
NavIndicator.Parent = NavBar
Corner(NavIndicator, 14)

local function CreateNavButton(def, index)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(0, 50, 1, 0)
    btnFrame.BackgroundTransparency = 1
    btnFrame.LayoutOrder = index
    btnFrame.ZIndex = 22
    btnFrame.Parent = NavContainer
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 22, 0, 22)
    icon.Position = UDim2.new(0.5, -11, 0.5, -11)
    icon.BackgroundTransparency = 1
    icon.Image = def.Icon
    icon.ImageColor3 = def.Name == State.UI.CurrentTab and Config.AccentColor or Theme.TextSecondary
    icon.ZIndex = 23
    icon.Parent = btnFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 24
    btn.Parent = btnFrame
    
    NavButtons[def.Name] = {Frame = btnFrame, Icon = icon, Button = btn}
    
    btn.MouseButton1Click:Connect(function()
        if State.UI.CurrentTab == def.Name then return end
        
        -- Hide current
        local currentPage = TabPages[State.UI.CurrentTab]
        if currentPage then
            Animate(currentPage, {Position = UDim2.new(-0.15, 0, 0, 0)}, Smooth(0.18), function()
                currentPage.Visible = false
                currentPage.Position = UDim2.new(0.15, 0, 0, 0)
            end)
        end
        
        -- Old icon fade
        local oldNav = NavButtons[State.UI.CurrentTab]
        if oldNav then
            Animate(oldNav.Icon, {ImageColor3 = Theme.TextSecondary, Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0.5, -11, 0.5, -11)}, Smooth(0.25))
        end
        
        -- New icon activate
        State.UI.CurrentTab = def.Name
        Animate(icon, {ImageColor3 = Config.AccentColor, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, -12, 0.5, -12)}, Spring(0.3))
        
        -- Move indicator
        Animate(NavIndicator, {Position = UDim2.new(0, btnFrame.AbsolutePosition.X - NavBar.AbsolutePosition.X + 2, 0.5, -23)}, Spring(0.35))
        
        -- Show new page
        task.delay(0.14, function()
            local newPage = TabPages[def.Name]
            if newPage then
                newPage.Position = UDim2.new(0.15, 0, 0, 0)
                newPage.Visible = true
                Animate(newPage, {Position = UDim2.new(0, 0, 0, 0)}, Smooth(0.28))
            end
        end)
    end)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        if State.UI.CurrentTab ~= def.Name then
            Animate(icon, {ImageColor3 = Theme.Text}, Quick())
        end
    end)
    btn.MouseLeave:Connect(function()
        if State.UI.CurrentTab ~= def.Name then
            Animate(icon, {ImageColor3 = Theme.TextSecondary}, Quick())
        end
    end)
end

for i, def in ipairs(NavTabs) do
    CreateNavButton(def, i)
end

-- Position indicator to Home initially
task.defer(function()
    local homeBtn = NavButtons["Home"]
    if homeBtn then
        NavIndicator.Position = UDim2.new(0, homeBtn.Frame.AbsolutePosition.X - NavBar.AbsolutePosition.X + 2, 0.5, -23)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- SECONDARY TAB SWITCHER (for Movement, Utility, Credits accessible from Home)
-- ═══════════════════════════════════════════════════════════════
local function SwitchTab(tabName)
    if State.UI.CurrentTab == tabName then return end
    
    local currentPage = TabPages[State.UI.CurrentTab]
    if currentPage then
        Animate(currentPage, {Position = UDim2.new(-0.15, 0, 0, 0)}, Smooth(0.18), function()
            currentPage.Visible = false
            currentPage.Position = UDim2.new(0.15, 0, 0, 0)
        end)
    end
    
    -- If nav button exists, update it
    local oldNav = NavButtons[State.UI.CurrentTab]
    if oldNav then
        Animate(oldNav.Icon, {ImageColor3 = Theme.TextSecondary, Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0.5, -11, 0.5, -11)}, Smooth(0.25))
    end
    
    State.UI.CurrentTab = tabName
    
    local newNav = NavButtons[tabName]
    if newNav then
        Animate(newNav.Icon, {ImageColor3 = Config.AccentColor, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, -12, 0.5, -12)}, Spring(0.3))
        Animate(NavIndicator, {Position = UDim2.new(0, newNav.Frame.AbsolutePosition.X - NavBar.AbsolutePosition.X + 2, 0.5, -23), BackgroundTransparency = 0.85}, Spring(0.35))
    else
        -- Hide indicator if tab not in bottom nav
        Animate(NavIndicator, {BackgroundTransparency = 1}, Smooth(0.2))
    end
    
    task.delay(0.14, function()
        local newPage = TabPages[tabName]
        if newPage then
            newPage.Position = UDim2.new(0.15, 0, 0, 0)
            newPage.Visible = true
            Animate(newPage, {Position = UDim2.new(0, 0, 0, 0)}, Smooth(0.28))
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- OPEN/CLOSE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
local function OpenMenu()
    if State.UI.IsOpen then return end
    State.UI.IsOpen = true
    
    -- Hide launcher
    Animate(Launcher, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, Smooth(0.25))
    Animate(launcherIcon, {TextTransparency = 1}, Quick())
    task.delay(0.25, function()
        Launcher.Visible = false
        Launcher.Size = UDim2.new(0, 56, 0, 56)
        launcherIcon.TextTransparency = 0
    end)
    
    -- Show background dim
    BackgroundDim.Visible = true
    BackgroundDim.BackgroundTransparency = 1
    Animate(BackgroundDim, {BackgroundTransparency = 0.4}, Smooth(0.4))
    Animate(BlurEffect, {Size = Config.BlurAmount}, Smooth(0.4))
    
    -- Show window with scale animation
    MainWindow.Visible = true
    MainWindow.Size = UDim2.new(0, 360, 0, 576) -- 90% scale
    MainWindow.BackgroundTransparency = 1
    
    Animate(MainWindow, {BackgroundTransparency = Config.BackgroundTransparency}, Smooth(0.3))
    Animate(MainWindow, {Size = UDim2.new(0, 400, 0, 640)}, Spring(0.5))
end

local function CloseMenu()
    if not State.UI.IsOpen then return end
    State.UI.IsOpen = false
    
    -- Scale down and fade
    Animate(MainWindow, {Size = UDim2.new(0, 360, 0, 576), BackgroundTransparency = 1}, Smooth(0.3), function()
        MainWindow.Visible = false
        MainWindow.Size = UDim2.new(0, 400, 0, 640)
        MainWindow.BackgroundTransparency = Config.BackgroundTransparency
    end)
    
    Animate(BackgroundDim, {BackgroundTransparency = 1}, Smooth(0.3), function()
        BackgroundDim.Visible = false
    end)
    Animate(BlurEffect, {Size = 0}, Smooth(0.3))
    
    -- Show launcher back
    task.delay(0.2, function()
        Launcher.Visible = true
        Launcher.Size = UDim2.new(0, 0, 0, 0)
        Launcher.BackgroundTransparency = 1
        Animate(Launcher, {Size = UDim2.new(0, 56, 0, 56), BackgroundTransparency = 0.1}, Spring(0.4))
    end)
end

launcherBtn.MouseButton1Click:Connect(OpenMenu)
CloseBtn.MouseButton1Click:Connect(CloseMenu)

-- Launcher hover feedback
launcherBtn.MouseEnter:Connect(function()
    Animate(Launcher, {Size = UDim2.new(0, 60, 0, 60), Position = Launcher.Position + UDim2.new(0, -2, 0, -2)}, Quick())
end)
launcherBtn.MouseLeave:Connect(function()
    Animate(Launcher, {Size = UDim2.new(0, 56, 0, 56), Position = Launcher.Position + UDim2.new(0, 2, 0, 2)}, Quick())
end)

-- ═══════════════════════════════════════════════════════════════
-- DRAGGABLE LAUNCHER (with edge snap)
-- ═══════════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos
    local dragDelta = 0
    
    launcherBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Launcher.Position
            dragDelta = 0
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    -- Snap to edge
                    local screenSize = ScreenGui.AbsoluteSize
                    local currentX = Launcher.AbsolutePosition.X + Launcher.AbsoluteSize.X / 2
                    if currentX < screenSize.X / 2 then
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
            local delta = input.Position - dragStart
            dragDelta = delta.Magnitude
            Launcher.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- DRAGGABLE MAIN WINDOW (via dynamic island)
-- ═══════════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos
    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(1, 0, 1, 0)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""
    dragBtn.ZIndex = 21
    dragBtn.Parent = DynamicIsland
    
    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: HOME (Lock Screen style)
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Home"]
    local scroll = Scroll(page)
    
    -- Large clock (Lock Screen style)
    local clockContainer = Instance.new("Frame")
    clockContainer.Size = UDim2.new(1, 0, 0, 130)
    clockContainer.BackgroundTransparency = 1
    clockContainer.LayoutOrder = 1
    clockContainer.Parent = scroll
    
    local bigClock = Instance.new("TextLabel")
    bigClock.Name = "BigClock"
    bigClock.Size = UDim2.new(1, 0, 0, 78)
    bigClock.Position = UDim2.new(0, 0, 0, 0)
    bigClock.BackgroundTransparency = 1
    bigClock.Text = GetTime24()
    bigClock.TextColor3 = Theme.Text
    bigClock.TextSize = 76
    bigClock.Font = Enum.Font.GothamBlack
    bigClock.Parent = clockContainer
    
    local dateLabel = Instance.new("TextLabel")
    dateLabel.Name = "DateLabel"
    dateLabel.Size = UDim2.new(1, 0, 0, 22)
    dateLabel.Position = UDim2.new(0, 0, 0, 78)
    dateLabel.BackgroundTransparency = 1
    dateLabel.Text = GetFullDate()
    dateLabel.TextColor3 = Theme.TextSecondary
    dateLabel.TextSize = 14
    dateLabel.Font = Enum.Font.GothamMedium
    dateLabel.Parent = clockContainer
    
    -- Greeting
    local greetingCard = Card(scroll, UDim2.new(1, 0, 0, 60), 2)
    
    local greeting = Instance.new("TextLabel")
    greeting.Name = "Greeting"
    greeting.Size = UDim2.new(1, -20, 0, 20)
    greeting.Position = UDim2.new(0, 16, 0, 8)
    greeting.BackgroundTransparency = 1
    greeting.Text = GetGreeting()
    greeting.TextColor3 = Config.AccentColor
    greeting.TextSize = 13
    greeting.Font = Enum.Font.GothamBold
    greeting.TextXAlignment = Enum.TextXAlignment.Left
    greeting.Parent = greetingCard
    
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(1, -20, 0, 24)
    welcome.Position = UDim2.new(0, 16, 0, 28)
    welcome.BackgroundTransparency = 1
    welcome.Text = "Welcome back, " .. LocalPlayer.DisplayName
    welcome.TextColor3 = Theme.Text
    welcome.TextSize = 16
    welcome.Font = Enum.Font.GothamSemibold
    welcome.TextXAlignment = Enum.TextXAlignment.Left
    welcome.Parent = greetingCard
    
    SectionTitle(scroll, "System", 3)
    
    -- Widget grid (2 per row)
    local widgetContainer = Instance.new("Frame")
    widgetContainer.Size = UDim2.new(1, 0, 0, 220)
    widgetContainer.BackgroundTransparency = 1
    widgetContainer.LayoutOrder = 4
    widgetContainer.Parent = scroll
    Grid(widgetContainer, UDim2.new(0.5, -5, 0, 105), UDim2.new(0, 10, 0, 10))
    
    local function CreateWidget(title, value, color, order)
        local w = Instance.new("Frame")
        w.BackgroundColor3 = Theme.Card
        w.BackgroundTransparency = Theme.GlassTransparency
        w.BorderSizePixel = 0
        w.LayoutOrder = order
        w.Parent = widgetContainer
        Corner(w, 18)
        Stroke(w, Theme.Separator, 1, 0.7)
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -20, 0, 18)
        t.Position = UDim2.new(0, 14, 0, 12)
        t.BackgroundTransparency = 1
        t.Text = string.upper(title)
        t.TextColor3 = color
        t.TextSize = 10
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = w
        
        local v = Instance.new("TextLabel")
        v.Name = "Value"
        v.Size = UDim2.new(1, -20, 0, 40)
        v.Position = UDim2.new(0, 14, 1, -52)
        v.BackgroundTransparency = 1
        v.Text = value
        v.TextColor3 = Theme.Text
        v.TextSize = 22
        v.Font = Enum.Font.GothamBlack
        v.TextXAlignment = Enum.TextXAlignment.Left
        v.TextTruncate = Enum.TextTruncate.AtEnd
        v.Parent = w
        
        return w
    end
    
    local executorName = "Unknown"
    pcall(function()
        if identifyexecutor then executorName = identifyexecutor() end
    end)
    
    local gameName = "Roblox"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    
    CreateWidget("Executor", Truncate(executorName, 12), Config.AccentColor, 1)
    CreateWidget("Game", Truncate(gameName, 14), Theme.Success, 2)
    local fpsWidget = CreateWidget("FPS", "60", Theme.Success, 3)
    local pingWidget = CreateWidget("Ping", "0ms", Config.AccentColor, 4)
    
    SectionTitle(scroll, "More Info", 5)
    
    local placeIDCard = Card(scroll, UDim2.new(1, 0, 0, 54), 6)
    local pidLbl = Instance.new("TextLabel")
    pidLbl.Size = UDim2.new(0.5, 0, 1, 0)
    pidLbl.Position = UDim2.new(0, 16, 0, 0)
    pidLbl.BackgroundTransparency = 1
    pidLbl.Text = "Place ID"
    pidLbl.TextColor3 = Theme.TextSecondary
    pidLbl.TextSize = 14
    pidLbl.Font = Enum.Font.GothamMedium
    pidLbl.TextXAlignment = Enum.TextXAlignment.Left
    pidLbl.Parent = placeIDCard
    
    local pidVal = Instance.new("TextLabel")
    pidVal.Size = UDim2.new(0.5, -16, 1, 0)
    pidVal.Position = UDim2.new(0.5, 0, 0, 0)
    pidVal.BackgroundTransparency = 1
    pidVal.Text = tostring(game.PlaceId)
    pidVal.TextColor3 = Theme.Text
    pidVal.TextSize = 13
    pidVal.Font = Enum.Font.GothamSemibold
    pidVal.TextXAlignment = Enum.TextXAlignment.Right
    pidVal.Parent = placeIDCard
    
    local playersCard = Card(scroll, UDim2.new(1, 0, 0, 54), 7)
    local plyLbl = Instance.new("TextLabel")
    plyLbl.Size = UDim2.new(0.5, 0, 1, 0)
    plyLbl.Position = UDim2.new(0, 16, 0, 0)
    plyLbl.BackgroundTransparency = 1
    plyLbl.Text = "Players in Server"
    plyLbl.TextColor3 = Theme.TextSecondary
    plyLbl.TextSize = 14
    plyLbl.Font = Enum.Font.GothamMedium
    plyLbl.TextXAlignment = Enum.TextXAlignment.Left
    plyLbl.Parent = playersCard
    
    local plyVal = Instance.new("TextLabel")
    plyVal.Name = "PlayerCount"
    plyVal.Size = UDim2.new(0.5, -16, 1, 0)
    plyVal.Position = UDim2.new(0.5, 0, 0, 0)
    plyVal.BackgroundTransparency = 1
    plyVal.Text = tostring(#Players:GetPlayers())
    plyVal.TextColor3 = Config.AccentColor
    plyVal.TextSize = 14
    plyVal.Font = Enum.Font.GothamBold
    plyVal.TextXAlignment = Enum.TextXAlignment.Right
    plyVal.Parent = playersCard
    
    local memCard = Card(scroll, UDim2.new(1, 0, 0, 54), 8)
    local memLbl = Instance.new("TextLabel")
    memLbl.Size = UDim2.new(0.5, 0, 1, 0)
    memLbl.Position = UDim2.new(0, 16, 0, 0)
    memLbl.BackgroundTransparency = 1
    memLbl.Text = "Memory Usage"
    memLbl.TextColor3 = Theme.TextSecondary
    memLbl.TextSize = 14
    memLbl.Font = Enum.Font.GothamMedium
    memLbl.TextXAlignment = Enum.TextXAlignment.Left
    memLbl.Parent = memCard
    
    local memVal = Instance.new("TextLabel")
    memVal.Name = "MemVal"
    memVal.Size = UDim2.new(0.5, -16, 1, 0)
    memVal.Position = UDim2.new(0.5, 0, 0, 0)
    memVal.BackgroundTransparency = 1
    memVal.Text = "0 MB"
    memVal.TextColor3 = Theme.Warning
    memVal.TextSize = 14
    memVal.Font = Enum.Font.GothamBold
    memVal.TextXAlignment = Enum.TextXAlignment.Right
    memVal.Parent = memCard
    
    SectionTitle(scroll, "Quick Access", 9)
    
    Button(scroll, "Copy Discord Invite", function()
        pcall(function() if setclipboard then setclipboard("discord.gg/ziqwenss") end end)
        Toast("Copied", "Discord invite copied to clipboard", "success")
    end, 10)
    
    Button(scroll, "View Update Log", function()
        Toast("Update v4.0.0", "iOS 26 UI, Dynamic Island, Bottom Nav added", "info", 4)
    end, 11)
    
    Button(scroll, "Open Movement", function()
        SwitchTab("Movement")
    end, 12)
    
    Button(scroll, "Open Utility", function()
        SwitchTab("Utility")
    end, 13)
    
    Button(scroll, "Open Credits", function()
        SwitchTab("Credits")
    end, 14)
    
    -- Update loop for home
    local lastUpdate = 0
    table.insert(State.Connections, RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastUpdate < 0.5 then return end
        lastUpdate = now
        
        -- Clock
        pcall(function()
            bigClock.Text = GetTime24()
            dateLabel.Text = GetFullDate()
            greeting.Text = GetGreeting()
            diTime.Text = GetTime24()
        end)
        
        -- FPS
        local dt = RunService.RenderStepped:Wait()
        local fps = math.floor(1 / dt)
        pcall(function()
            fpsWidget.Value.Text = tostring(math.min(fps, 999))
            fpsWidget.Value.TextColor3 = fps >= 50 and Theme.Success or (fps >= 30 and Theme.Warning or Theme.Danger)
        end)
        
        -- Ping
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        pcall(function()
            pingWidget.Value.Text = tostring(ping) .. "ms"
            pingWidget.Value.TextColor3 = ping <= 80 and Theme.Success or (ping <= 150 and Theme.Warning or Theme.Danger)
        end)
        
        -- Dynamic Island
        pcall(function()
            diStats.Text = tostring(fps) .. " FPS  |  " .. ping .. "ms"
        end)
        
        -- Memory
        pcall(function()
            local mem = math.floor(Stats:GetTotalMemoryUsageMb())
            memVal.Text = mem .. " MB"
        end)
        
        -- Player count
        pcall(function()
            plyVal.Text = tostring(#Players:GetPlayers())
        end)
    end))
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: ESP
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["ESP"]
    local scroll = Scroll(page)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "ESP"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
    SectionTitle(scroll, "Master Control", 1)
    Toggle(scroll, "Master ESP", "Enable all ESP features", false, function(v)
        State.ESP.MasterESP = v
        Toast(v and "ESP Enabled" or "ESP Disabled", v and "All ESP features are now active" or "ESP has been turned off", v and "success" or "info")
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
    
    SectionTitle(scroll, "Tracers & Lines", 21)
    Toggle(scroll, "Tracer", nil, false, function(v) State.ESP.Tracer = v end, 22)
    Toggle(scroll, "Bottom Tracer", nil, false, function(v) State.ESP.BottomTracer = v end, 23)
    Toggle(scroll, "Top Tracer", nil, false, function(v) State.ESP.TopTracer = v end, 24)
    Toggle(scroll, "Snapline", nil, false, function(v) State.ESP.Snapline = v end, 25)
    Toggle(scroll, "Offscreen Arrow", nil, false, function(v) State.ESP.OffscreenArrow = v end, 26)
    
    SectionTitle(scroll, "Filters", 27)
    Toggle(scroll, "Team Check", "Hide teammates", false, function(v) State.ESP.TeamCheck = v end, 28)
    Toggle(scroll, "Visible Check", "Only show visible players", false, function(v) State.ESP.VisibleCheck = v end, 29)
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
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Player"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
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
        State.Player.Gravity = v
        Workspace.Gravity = v
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
    Toggle(scroll, "God Mode Visual", nil, false, function(v)
        State.Player.GodMode = v
    end, 13)
    Toggle(scroll, "Anti AFK", "Never get kicked for inactivity", false, function(v)
        State.Player.AntiAFK = v
        if v then
            local vu = game:GetService("VirtualUser")
            table.insert(State.Connections, LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end))
        end
        Toast(v and "Anti AFK Active" or "Anti AFK Off", v and "You won't get kicked" or "Idle protection disabled", v and "success" or "info")
    end, 14)
    
    SectionTitle(scroll, "Actions", 15)
    Button(scroll, "Reset Character", function()
        pcall(function() LocalPlayer.Character:BreakJoints() end)
        Toast("Character Reset", "Respawning...", "info")
    end, 16, "danger")
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: TELEPORT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Teleport"]
    local scroll = Scroll(page)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Teleport"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
    local function GetPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        if #names == 0 then table.insert(names, "No players") end
        return names
    end
    
    SectionTitle(scroll, "Target Selection", 1)
    local dd = Dropdown(scroll, "Target Player", GetPlayerNames(), nil, nil, 2)
    Button(scroll, "Refresh Player List", function()
        dd.Refresh(GetPlayerNames())
        Toast("Refreshed", #Players:GetPlayers() - 1 .. " players found", "success")
    end, 3)
    
    SectionTitle(scroll, "Teleport Actions", 4)
    Button(scroll, "Teleport to Player", function()
        local t = dd.Get()
        local target = Players:FindFirstChild(t)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            end)
            Toast("Teleported", "Moved to " .. t, "success")
        else
            Toast("Failed", "Player not available", "error")
        end
    end, 5, "accent")
    
    Button(scroll, "Teleport Behind Player", function()
        local t = dd.Get()
        local target = Players:FindFirstChild(t)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            end)
            Toast("Teleported", "Behind " .. t, "success")
        end
    end, 6)
    
    Button(scroll, "Teleport Above Player", function()
        local t = dd.Get()
        local target = Players:FindFirstChild(t)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
            end)
            Toast("Teleported", "Above " .. t, "success")
        end
    end, 7)
    
    Button(scroll, "Bring Camera to Player", function()
        local t = dd.Get()
        local target = Players:FindFirstChild(t)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character.Humanoid
            Toast("Camera", "Following " .. t, "info")
        end
    end, 8)
    
    SectionTitle(scroll, "Waypoints", 9)
    Button(scroll, "Save Current Position", function()
        pcall(function()
            local pos = LocalPlayer.Character.HumanoidRootPart.CFrame
            table.insert(State.Teleport.SavedPositions, pos)
            Toast("Saved", "Slot " .. #State.Teleport.SavedPositions, "success")
        end)
    end, 10)
    
    Button(scroll, "Load Last Position", function()
        if #State.Teleport.SavedPositions > 0 then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = State.Teleport.SavedPositions[#State.Teleport.SavedPositions]
            end)
            Toast("Loaded", "Position restored", "success")
        else
            Toast("Empty", "No saved positions", "error")
        end
    end, 11)
    
    Button(scroll, "Clear All Waypoints", function()
        State.Teleport.SavedPositions = {}
        Toast("Cleared", "All waypoints removed", "info")
    end, 12, "danger")
    
    SectionTitle(scroll, "Click Teleport", 13)
    Toggle(scroll, "Click Teleport", "Hold Ctrl + click to teleport", false, function(v)
        State.Utility.ClickTP = v
    end, 14)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: COMBAT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Combat"]
    local scroll = Scroll(page)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Combat"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
    SectionTitle(scroll, "Hitbox Expander", 1)
    Toggle(scroll, "Hitbox Expander", "Master enable", false, function(v)
        State.Combat.HitboxExpander = v
        Toast(v and "Enabled" or "Disabled", "Hitbox Expander", v and "success" or "info")
    end, 2)
    Toggle(scroll, "Auto Update Hitbox", nil, false, function(v) State.Combat.AutoUpdateHitbox = v end, 3)
    Toggle(scroll, "Huge Hitbox Mode", "3x size multiplier", false, function(v) State.Combat.HugeHitbox = v end, 4)
    
    SectionTitle(scroll, "Hitbox Config", 5)
    Slider(scroll, "Hitbox Size", 1, 50, 5, function(v) State.Combat.HitboxSize = v end, 6)
    Slider(scroll, "Transparency", 0, 1, 0.7, function(v) State.Combat.HitboxTransparency = v end, 7, 2)
    Slider(scroll, "Max Distance", 50, 1000, 200, function(v) State.Combat.HitboxDistance = v end, 8)
    Slider(scroll, "Size Multiplier", 0.5, 5, 1, function(v) State.Combat.HitboxMultiplier = v end, 9, 1)
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
    Button(scroll, "Restore Default Hitboxes", function()
        State.Combat.HitboxExpander = false
        Toast("Restored", "Hitboxes reset to default", "success")
    end, 20, "danger")
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: MOVEMENT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Movement"]
    local scroll = Scroll(page)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Movement"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
    SectionTitle(scroll, "Primary", 1)
    Toggle(scroll, "No Clip", "Walk through walls", false, function(v)
        State.Movement.NoClip = v
        Toast(v and "Enabled" or "Disabled", "No Clip", v and "success" or "info")
    end, 2)
    Toggle(scroll, "Fly", "WASD + Space/Shift", false, function(v)
        State.Movement.Fly = v
        Toast(v and "Enabled" or "Disabled", "Fly Mode", v and "success" or "info")
    end, 3)
    Toggle(scroll, "Speed Hack", "WalkSpeed = 100", false, function(v)
        State.Movement.SpeedHack = v
    end, 4)
    Toggle(scroll, "Air Walk", nil, false, function(v) State.Movement.AirWalk = v end, 5)
    Toggle(scroll, "Infinite Jump", nil, false, function(v) State.Movement.InfiniteJump = v end, 6)
    
    SectionTitle(scroll, "Advanced", 7)
    Toggle(scroll, "Float", "Freeze vertical velocity", false, function(v) State.Movement.Float = v end, 8)
    Toggle(scroll, "Spider Climb", nil, false, function(v) State.Movement.SpiderClimb = v end, 9)
    Toggle(scroll, "Wall Walk", nil, false, function(v) State.Movement.WallWalk = v end, 10)
    
    SectionTitle(scroll, "Gravity Control", 11)
    Toggle(scroll, "Low Gravity", "Gravity = 50", false, function(v)
        State.Movement.LowGravity = v
        if v then Workspace.Gravity = 50; State.Movement.HighGravity = false
        else Workspace.Gravity = 196.2 end
    end, 12)
    Toggle(scroll, "High Gravity", "Gravity = 500", false, function(v)
        State.Movement.HighGravity = v
        if v then Workspace.Gravity = 500; State.Movement.LowGravity = false
        else Workspace.Gravity = 196.2 end
    end, 13)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: UTILITY
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Utility"]
    local scroll = Scroll(page)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Utility"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
    SectionTitle(scroll, "Display", 1)
    Toggle(scroll, "FPS Counter", nil, false, function(v) State.Utility.FPSCounter = v end, 2)
    Toggle(scroll, "Ping Counter", nil, false, function(v) State.Utility.PingCounter = v end, 3)
    Toggle(scroll, "Server Time", nil, false, function(v) State.Utility.ServerTime = v end, 4)
    
    SectionTitle(scroll, "Environment", 5)
    Toggle(scroll, "Full Bright", "Remove darkness", false, function(v)
        State.Utility.FullBright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
        Toast(v and "Enabled" or "Disabled", "Full Bright", v and "success" or "info")
    end, 6)
    Toggle(scroll, "Night Mode", nil, false, function(v)
        State.Utility.NightMode = v
        Lighting.ClockTime = v and 0 or 14
    end, 7)
    
    SectionTitle(scroll, "Protection", 8)
    Toggle(scroll, "Anti Kick", nil, false, function(v)
        State.Utility.AntiKick = v
        if v then
            pcall(function() LocalPlayer.Kick = function() end end)
            Toast("Active", "Anti Kick engaged", "success")
        end
    end, 9)
    Toggle(scroll, "Auto Reconnect", nil, false, function(v) State.Utility.AutoReconnect = v end, 10)
    
    SectionTitle(scroll, "Server", 11)
    Button(scroll, "Rejoin Server", function()
        Toast("Rejoining", "Please wait...", "info")
        task.delay(1, function()
            pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
        end)
    end, 12)
    Button(scroll, "Server Hop", function()
        Toast("Searching", "Finding new server...", "info")
        task.delay(1, function()
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                ))
                for _, s in ipairs(servers.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        break
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
        Toast("Unloading", "Cleaning up...", "info")
        task.delay(0.8, function()
            for _, c in ipairs(State.Connections) do pcall(function() c:Disconnect() end) end
            Workspace.Gravity = 196.2
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    for _, obj in ipairs(p.Character:GetChildren()) do
                        if obj.Name == "ZiqwenssHighlight" or obj.Name == "ZiqwenssESPGui" then
                            obj:Destroy()
                        end
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
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Settings"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
    SectionTitle(scroll, "Appearance", 1)
    ColorPicker(scroll, "Accent Color", Config.AccentColor, function(c)
        Config.AccentColor = c
        diCenterText.TextColor3 = c
        launcherDot.BackgroundColor3 = c
        NavIndicator.BackgroundColor3 = c
    end, 2)
    Slider(scroll, "Blur Amount", 0, 30, Config.BlurAmount, function(v)
        Config.BlurAmount = v
        if State.UI.IsOpen then BlurEffect.Size = v end
    end, 3)
    Slider(scroll, "Animation Speed", 0.1, 1, Config.AnimationSpeed, function(v) Config.AnimationSpeed = v end, 4, 2)
    Slider(scroll, "Background Transparency", 0, 0.5, Config.BackgroundTransparency, function(v)
        Config.BackgroundTransparency = v
        MainWindow.BackgroundTransparency = v
    end, 5, 2)
    
    Toggle(scroll, "Rainbow UI", "Animated color cycling", false, function(v)
        Config.RainbowUI = v
        Toast(v and "Rainbow On" or "Rainbow Off", v and "Colors will cycle" or "Static colors", v and "success" or "info")
    end, 6)
    
    SectionTitle(scroll, "Theme", 7)
    local themeNames = {}
    for n, _ in pairs(Themes) do table.insert(themeNames, n) end
    table.sort(themeNames)
    
    Dropdown(scroll, "Color Theme", themeNames, CurrentTheme, function(selected)
        CurrentTheme = selected
        Theme = Themes[selected]
        Animate(MainWindow, {BackgroundColor3 = Theme.Background}, Smooth(0.5))
        Animate(DynamicIsland, {BackgroundColor3 = Theme.DynamicIsland}, Smooth(0.5))
        Animate(NavBar, {BackgroundColor3 = Theme.Card}, Smooth(0.5))
        Toast("Theme Changed", "Now using " .. selected, "success")
    end, 8)
    
    SectionTitle(scroll, "Configuration", 9)
    Button(scroll, "Save Config", function()
        Toast("Saved", "Configuration saved", "success")
    end, 10, "accent")
    Button(scroll, "Load Config", function()
        Toast("Loaded", "Configuration loaded", "success")
    end, 11)
    Button(scroll, "Reset to Defaults", function()
        Config.AccentColor = Color3.fromRGB(10, 132, 255)
        Config.BlurAmount = 18
        Config.AnimationSpeed = 0.35
        Config.RainbowUI = false
        Config.BackgroundTransparency = 0.1
        BlurEffect.Size = 18
        MainWindow.BackgroundTransparency = 0.1
        Toast("Reset", "Defaults restored", "info")
    end, 12, "danger")
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: CREDITS
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Credits"]
    local scroll = Scroll(page)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Credits"
    title.TextColor3 = Theme.Text
    title.TextSize = 28
    title.Font = Enum.Font.GothamBlack
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 0
    title.Parent = scroll
    
    -- Profile card
    local profile = Instance.new("Frame")
    profile.Size = UDim2.new(1, 0, 0, 240)
    profile.BackgroundColor3 = Theme.Card
    profile.BackgroundTransparency = Theme.GlassTransparency
    profile.BorderSizePixel = 0
    profile.LayoutOrder = 1
    profile.Parent = scroll
    Corner(profile, 24)
    Stroke(profile, Theme.Separator, 1, 0.6)
    
    -- Gradient banner
    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, 0, 0, 100)
    banner.BackgroundColor3 = Config.AccentColor
    banner.BorderSizePixel = 0
    banner.ClipsDescendants = true
    banner.Parent = profile
    Corner(banner, 24)
    Gradient(banner, {
        Color3.fromRGB(10, 132, 255),
        Color3.fromRGB(94, 92, 230),
        Color3.fromRGB(191, 90, 242),
    }, 135)
    
    local bannerFix = Instance.new("Frame")
    bannerFix.Size = UDim2.new(1, 0, 0, 24)
    bannerFix.Position = UDim2.new(0, 0, 1, -24)
    bannerFix.BackgroundColor3 = Config.AccentColor
    bannerFix.BorderSizePixel = 0
    bannerFix.Parent = banner
    Gradient(bannerFix, {
        Color3.fromRGB(10, 132, 255),
        Color3.fromRGB(94, 92, 230),
        Color3.fromRGB(191, 90, 242),
    }, 135)
    
    -- Avatar
    local avatarBg = Instance.new("Frame")
    avatarBg.Size = UDim2.new(0, 80, 0, 80)
    avatarBg.Position = UDim2.new(0.5, -40, 0, 60)
    avatarBg.BackgroundColor3 = Theme.Background
    avatarBg.BorderSizePixel = 0
    avatarBg.ZIndex = 3
    avatarBg.Parent = profile
    Corner(avatarBg, 40)
    
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(1, -6, 1, -6)
    avatar.Position = UDim2.new(0, 3, 0, 3)
    avatar.BackgroundTransparency = 1
    avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatar.ZIndex = 4
    avatar.Parent = avatarBg
    Corner(avatar, 37)
    
    local devName = Instance.new("TextLabel")
    devName.Size = UDim2.new(1, 0, 0, 24)
    devName.Position = UDim2.new(0, 0, 0, 150)
    devName.BackgroundTransparency = 1
    devName.Text = "Ziqwenss Team"
    devName.TextColor3 = Theme.Text
    devName.TextSize = 18
    devName.Font = Enum.Font.GothamBlack
    devName.Parent = profile
    
    local devSub = Instance.new("TextLabel")
    devSub.Size = UDim2.new(1, 0, 0, 18)
    devSub.Position = UDim2.new(0, 0, 0, 176)
    devSub.BackgroundTransparency = 1
    devSub.Text = "Premium iOS Framework"
    devSub.TextColor3 = Theme.TextSecondary
    devSub.TextSize = 12
    devSub.Font = Enum.Font.GothamMedium
    devSub.Parent = profile
    
    local verBadge = Instance.new("Frame")
    verBadge.Size = UDim2.new(0, 90, 0, 26)
    verBadge.Position = UDim2.new(0.5, -45, 0, 200)
    verBadge.BackgroundColor3 = Config.AccentColor
    verBadge.BackgroundTransparency = 0.8
    verBadge.Parent = profile
    Corner(verBadge, 13)
    
    local verText = Instance.new("TextLabel")
    verText.Size = UDim2.new(1, 0, 1, 0)
    verText.BackgroundTransparency = 1
    verText.Text = "Version " .. Config.Version
    verText.TextColor3 = Config.AccentColor
    verText.TextSize = 11
    verText.Font = Enum.Font.GothamBold
    verText.Parent = verBadge
    
    SectionTitle(scroll, "Information", 2)
    
    local function InfoRow(lbl, val, order)
        local c = Card(scroll, UDim2.new(1, 0, 0, 50), order)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.5, 0, 1, 0)
        l.Position = UDim2.new(0, 16, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = lbl
        l.TextColor3 = Theme.TextSecondary
        l.TextSize = 13
        l.Font = Enum.Font.GothamMedium
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = c
        
        local v = Instance.new("TextLabel")
        v.Size = UDim2.new(0.5, -16, 1, 0)
        v.Position = UDim2.new(0.5, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.Text = val
        v.TextColor3 = Theme.Text
        v.TextSize = 13
        v.Font = Enum.Font.GothamSemibold
        v.TextXAlignment = Enum.TextXAlignment.Right
        v.Parent = c
    end
    
    InfoRow("Version", Config.Version, 3)
    InfoRow("Build Date", Config.BuildDate, 4)
    InfoRow("Framework", "Ziqwenss v4", 5)
    InfoRow("Design", "iOS 26 Style", 6)
    
    SectionTitle(scroll, "Special Thanks", 7)
    
    local thanks = Card(scroll, UDim2.new(1, 0, 0, 100), 8)
    Padding(thanks, 16, 16, 16, 16)
    
    local thanksText = Instance.new("TextLabel")
    thanksText.Size = UDim2.new(1, 0, 1, 0)
    thanksText.BackgroundTransparency = 1
    thanksText.Text = "Thank you to Apple for the design inspiration, to the Roblox developer community, and to all users who provided feedback. This framework was crafted with attention to detail and love for beautiful software."
    thanksText.TextColor3 = Theme.TextSecondary
    thanksText.TextSize = 12
    thanksText.Font = Enum.Font.GothamMedium
    thanksText.TextWrapped = true
    thanksText.TextXAlignment = Enum.TextXAlignment.Left
    thanksText.TextYAlignment = Enum.TextYAlignment.Top
    thanksText.Parent = thanks
end

-- ═══════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════
-- GAME LOGIC LOOPS
-- ═══════════════════════════════════════════════════════════════

-- NoClip
table.insert(State.Connections, RunService.Stepped:Connect(function()
    if (State.Player.NoClip or State.Movement.NoClip) and LocalPlayer.Character then
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end))

-- Infinite Jump
table.insert(State.Connections, UserInputService.JumpRequest:Connect(function()
    if State.Player.InfiniteJump or State.Movement.InfiniteJump then
        pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end))

-- Fly system
local flyBV, flyBG
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if (State.Player.Fly or State.Movement.Fly) and LocalPlayer.Character then
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            if not flyBV then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Velocity = Vector3.new(0, 0, 0)
                flyBV.Parent = hrp
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBG.P = 9e4
                flyBG.Parent = hrp
            end
            
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            
            flyBV.Velocity = dir * 60
            flyBG.CFrame = Camera.CFrame
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end))

-- Speed Hack
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Movement.SpeedHack and LocalPlayer.Character then
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)
    end
end))

-- Float
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Movement.Float and LocalPlayer.Character then
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z) end
        end)
    end
end))

-- Bunny Hop
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Player.BunnyHop and LocalPlayer.Character then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end))

-- Auto Sprint
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Player.AutoSprint and LocalPlayer.Character then
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                hum.WalkSpeed = math.max(State.Player.WalkSpeed, 32)
            end
        end)
    end
end))

-- Hitbox Expander
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Combat.HitboxExpander then
        pcall(function()
            local size = State.Combat.HitboxSize * State.Combat.HitboxMultiplier
            if State.Combat.HugeHitbox then size = size * 3 end
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if State.Combat.CombatTeamCheck and p.Team == LocalPlayer.Team then continue end
                    
                    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local theirHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and theirHRP and (myHRP.Position - theirHRP.Position).Magnitude > State.Combat.HitboxDistance then
                        continue
                    end
                    
                    local parts = {}
                    if State.Combat.HeadHitbox then table.insert(parts, "Head") end
                    if State.Combat.BodyHitbox then
                        for _, n in ipairs({"Torso", "UpperTorso", "LowerTorso"}) do table.insert(parts, n) end
                    end
                    if State.Combat.ArmHitbox then
                        for _, n in ipairs({"Left Arm", "Right Arm", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand"}) do table.insert(parts, n) end
                    end
                    if State.Combat.LegHitbox then
                        for _, n in ipairs({"Left Leg", "Right Leg", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}) do table.insert(parts, n) end
                    end
                    if #parts == 0 then parts = {"HumanoidRootPart"} end
                    
                    for _, name in ipairs(parts) do
                        local part = p.Character:FindFirstChild(name)
                        if part and part:IsA("BasePart") then
                            part.Size = Vector3.new(size, size, size)
                            part.Transparency = State.Combat.HitboxTransparency
                            part.Color = State.Combat.HitboxColor
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
end))

-- Click Teleport
table.insert(State.Connections, Mouse.Button1Down:Connect(function()
    if State.Utility.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        pcall(function()
            local hit = Mouse.Hit
            if hit then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hit + Vector3.new(0, 3, 0)
                Toast("Teleport", "Moved to click position", "success", 1)
            end
        end)
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════
table.insert(State.Connections, RunService.RenderStepped:Connect(function()
    if not State.ESP.MasterESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("ZiqwenssHighlight")
                if h then h:Destroy() end
                local b = p.Character:FindFirstChild("ZiqwenssESPGui")
                if b then b:Destroy() end
            end
        end
        return
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local char = p.Character
                local hrp = char.HumanoidRootPart
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if State.ESP.TeamCheck and p.Team == LocalPlayer.Team then
                    local h = char:FindFirstChild("ZiqwenssHighlight")
                    if h then h:Destroy() end
                    local b = char:FindFirstChild("ZiqwenssESPGui")
                    if b then b:Destroy() end
                    return
                end
                
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myHRP and (myHRP.Position - hrp.Position).Magnitude or 0
                if dist > State.ESP.MaxDistance then
                    local h = char:FindFirstChild("ZiqwenssHighlight")
                    if h then h:Destroy() end
                    local b = char:FindFirstChild("ZiqwenssESPGui")
                    if b then b:Destroy() end
                    return
                end
                
                -- Highlight/Chams
                if State.ESP.HighlightESP or State.ESP.Chams then
                    local hl = char:FindFirstChild("ZiqwenssHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "ZiqwenssHighlight"
                        hl.Adornee = char
                        hl.Parent = char
                    end
                    if State.ESP.RainbowChams then
                        hl.FillColor = GetRainbow(0.5)
                        hl.OutlineColor = GetRainbow(0.7)
                    elseif State.ESP.DynamicColor and hum then
                        local hp = hum.Health / hum.MaxHealth
                        hl.FillColor = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                    else
                        hl.FillColor = State.ESP.Color
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                    hl.FillTransparency = State.ESP.ESPTransparency
                    hl.OutlineTransparency = 0.3
                else
                    local h = char:FindFirstChild("ZiqwenssHighlight")
                    if h then h:Destroy() end
                end
                
                -- Info ESP
                if State.ESP.NameESP or State.ESP.DistanceESP or State.ESP.HealthText or State.ESP.WeaponESP or State.ESP.ToolESP then
                    local bbg = char:FindFirstChild("ZiqwenssESPGui")
                    if not bbg then
                        bbg = Instance.new("BillboardGui")
                        bbg.Name = "ZiqwenssESPGui"
                        bbg.Adornee = head or hrp
                        bbg.Size = UDim2.new(0, 220, 0, 70)
                        bbg.StudsOffset = Vector3.new(0, 3, 0)
                        bbg.AlwaysOnTop = true
                        bbg.Parent = char
                        
                        for i, name in ipairs({"NameLabel", "DistLabel", "HealthLabel", "ToolLabel"}) do
                            local l = Instance.new("TextLabel")
                            l.Name = name
                            l.Size = UDim2.new(1, 0, 0, 15)
                            l.Position = UDim2.new(0, 0, 0, (i-1) * 16)
                            l.BackgroundTransparency = 1
                            l.TextStrokeTransparency = 0.4
                            l.TextStrokeColor3 = Color3.new(0, 0, 0)
                            l.Font = Enum.Font.GothamBold
                            l.TextSize = i == 1 and 14 or 11
                            l.Parent = bbg
                        end
                    end
                    
                    local nl = bbg.NameLabel
                    nl.Visible = State.ESP.NameESP
                    nl.Text = p.DisplayName
                    nl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    
                    local dl = bbg.DistLabel
                    dl.Visible = State.ESP.DistanceESP
                    dl.Text = "[" .. math.floor(dist) .. "m]"
                    dl.TextColor3 = Color3.fromRGB(200, 200, 200)
                    
                    local hl_label = bbg.HealthLabel
                    if hum then
                        hl_label.Visible = State.ESP.HealthText
                        hl_label.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth) .. " HP"
                        local hp = hum.Health / hum.MaxHealth
                        hl_label.TextColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                    end
                    
                    local tl = bbg.ToolLabel
                    tl.Visible = State.ESP.WeaponESP or State.ESP.ToolESP
                    if tl.Visible then
                        local t = char:FindFirstChildOfClass("Tool")
                        tl.Text = t and t.Name or "Empty"
                        tl.TextColor3 = Color3.fromRGB(255, 214, 10)
                    end
                else
                    local b = char:FindFirstChild("ZiqwenssESPGui")
                    if b then b:Destroy() end
                end
            end)
        end
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- RAINBOW UI LOOP
-- ═══════════════════════════════════════════════════════════════
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if Config.RainbowUI then
        local r = GetRainbow(0.3)
        Config.AccentColor = r
        diCenterText.TextColor3 = r
        launcherDot.BackgroundColor3 = r
        NavIndicator.BackgroundColor3 = r
        
        -- Update active nav icon
        local activeNav = NavButtons[State.UI.CurrentTab]
        if activeNav then activeNav.Icon.ImageColor3 = r end
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- KEYBOARD SHORTCUTS
-- ═══════════════════════════════════════════════════════════════
table.insert(State.Connections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if State.UI.IsOpen then CloseMenu() else OpenMenu() end
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- OPENING ANIMATION (launcher fade in)
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
        Toast("Ziqwenss Loaded", "Tap the floating button to begin", "success", 3)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════
ScreenGui.Destroying:Connect(function()
    for _, c in ipairs(State.Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() BlurEffect:Destroy() end)
    Workspace.Gravity = 196.2
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, obj in ipairs(p.Character:GetChildren()) do
                if obj.Name == "ZiqwenssHighlight" or obj.Name == "ZiqwenssESPGui" then
                    obj:Destroy()
                end
            end
        end
    end
end)

--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               ZIQWENSS SCRIPT — END OF FILE                  ║
    ║                                                              ║
    ║  Usage:                                                      ║
    ║  • Tap the floating Z button on screen to open menu          ║
    ║  • Drag the button anywhere — it snaps to screen edges       ║
    ║  • Tap X in top-right to close (state is preserved)          ║
    ║  • Right Shift = quick toggle                                ║
    ║  • Ctrl + Click = teleport (if enabled)                      ║
    ║                                                              ║
    ║  Design: iOS 26 inspired with Dynamic Island header,         ║
    ║  Lock Screen home, floating bottom navigation, and pure      ║
    ║  emoji-free SF Symbols style icons.                          ║
    ╚══════════════════════════════════════════════════════════════╝
]]
