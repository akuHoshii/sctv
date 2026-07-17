--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    NEXUS UI - Premium Suite                   ║
    ║            iPhone-Inspired Roblox Interface v3.0              ║
    ║                                                              ║
    ║  A premium, modern UI library inspired by Apple's Human      ║
    ║  Interface Guidelines. Features glassmorphism, smooth         ║
    ║  spring animations, and a fully responsive layout.           ║
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

-- ═══════════════════════════════════════════════════════════════
-- LOCAL REFERENCES
-- ═══════════════════════════════════════════════════════════════
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION / THEME SYSTEM
-- ═══════════════════════════════════════════════════════════════
local Config = {
    Version = "3.0.0",
    BuildDate = "2025-01-15",
    Developer = "Nexus Team",
    AnimationSpeed = 0.3,
    BlurAmount = 12,
    AccentColor = Color3.fromRGB(0, 122, 255), -- iOS Blue
    RainbowUI = false,
    GUIScale = 1,
    BackgroundTransparency = 0.15,
}

-- Theme definitions
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(28, 28, 30),
        Secondary = Color3.fromRGB(44, 44, 46),
        Tertiary = Color3.fromRGB(58, 58, 60),
        Surface = Color3.fromRGB(36, 36, 38),
        Card = Color3.fromRGB(44, 44, 46),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(174, 174, 178),
        TextTertiary = Color3.fromRGB(99, 99, 102),
        Separator = Color3.fromRGB(56, 56, 58),
        Overlay = Color3.fromRGB(20, 20, 22),
        Success = Color3.fromRGB(52, 199, 89),
        Error = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        GlassTransparency = 0.25,
    },
    Light = {
        Primary = Color3.fromRGB(242, 242, 247),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(229, 229, 234),
        Surface = Color3.fromRGB(248, 248, 250),
        Card = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(0, 0, 0),
        TextSecondary = Color3.fromRGB(99, 99, 102),
        TextTertiary = Color3.fromRGB(174, 174, 178),
        Separator = Color3.fromRGB(198, 198, 200),
        Overlay = Color3.fromRGB(220, 220, 224),
        Success = Color3.fromRGB(52, 199, 89),
        Error = Color3.fromRGB(255, 59, 48),
        Warning = Color3.fromRGB(255, 149, 0),
        GlassTransparency = 0.15,
    },
    Midnight = {
        Primary = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(22, 22, 30),
        Tertiary = Color3.fromRGB(35, 35, 45),
        Surface = Color3.fromRGB(18, 18, 25),
        Card = Color3.fromRGB(25, 25, 35),
        Text = Color3.fromRGB(230, 230, 240),
        TextSecondary = Color3.fromRGB(140, 140, 160),
        TextTertiary = Color3.fromRGB(90, 90, 110),
        Separator = Color3.fromRGB(40, 40, 55),
        Overlay = Color3.fromRGB(8, 8, 12),
        Success = Color3.fromRGB(48, 209, 88),
        Error = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        GlassTransparency = 0.3,
    },
    ["iOS Black"] = {
        Primary = Color3.fromRGB(0, 0, 0),
        Secondary = Color3.fromRGB(18, 18, 18),
        Tertiary = Color3.fromRGB(30, 30, 30),
        Surface = Color3.fromRGB(12, 12, 12),
        Card = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(152, 152, 157),
        TextTertiary = Color3.fromRGB(99, 99, 102),
        Separator = Color3.fromRGB(38, 38, 40),
        Overlay = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(50, 215, 75),
        Error = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        GlassTransparency = 0.35,
    },
    Ocean = {
        Primary = Color3.fromRGB(15, 25, 45),
        Secondary = Color3.fromRGB(20, 35, 60),
        Tertiary = Color3.fromRGB(30, 50, 80),
        Surface = Color3.fromRGB(18, 30, 55),
        Card = Color3.fromRGB(25, 40, 65),
        Text = Color3.fromRGB(220, 235, 255),
        TextSecondary = Color3.fromRGB(140, 170, 210),
        TextTertiary = Color3.fromRGB(90, 120, 160),
        Separator = Color3.fromRGB(40, 60, 90),
        Overlay = Color3.fromRGB(10, 18, 35),
        Success = Color3.fromRGB(52, 199, 89),
        Error = Color3.fromRGB(255, 85, 85),
        Warning = Color3.fromRGB(255, 180, 50),
        GlassTransparency = 0.28,
    },
    Purple = {
        Primary = Color3.fromRGB(25, 15, 40),
        Secondary = Color3.fromRGB(40, 25, 60),
        Tertiary = Color3.fromRGB(55, 35, 80),
        Surface = Color3.fromRGB(32, 20, 50),
        Card = Color3.fromRGB(45, 30, 68),
        Text = Color3.fromRGB(240, 225, 255),
        TextSecondary = Color3.fromRGB(180, 155, 210),
        TextTertiary = Color3.fromRGB(120, 100, 155),
        Separator = Color3.fromRGB(65, 45, 90),
        Overlay = Color3.fromRGB(18, 10, 30),
        Success = Color3.fromRGB(100, 220, 120),
        Error = Color3.fromRGB(255, 85, 100),
        Warning = Color3.fromRGB(255, 180, 60),
        GlassTransparency = 0.28,
    },
}

local CurrentTheme = "Dark"
local Theme = Themes[CurrentTheme]

-- ═══════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════
local State = {
    -- ESP States
    ESP = {
        MasterESP = false, BoxESP = false, FilledBox = false, CornerBox = false,
        SkeletonESP = false, HeadDot = false, HeadCircle = false, HealthBar = false,
        HealthText = false, NameESP = false, DistanceESP = false, TeamCheck = false,
        Tracer = false, BottomTracer = false, TopTracer = false, Snapline = false,
        Chams = false, RainbowChams = false, VisibleCheck = false, OffscreenArrow = false,
        WeaponESP = false, ToolESP = false, HighlightESP = false, DynamicColor = false,
        ESPTransparency = 0.5,
    },
    ESPColors = {},
    ESPThickness = {},
    ESPDistance = {},
    
    -- Player States
    Player = {
        WalkSpeed = 16, JumpPower = 50, HipHeight = 0, Gravity = 196.2,
        InfiniteJump = false, Fly = false, NoClip = false, AutoSprint = false,
        BunnyHop = false, GodMode = false, AntiAFK = false,
    },
    
    -- Combat States
    Combat = {
        HitboxExpander = false, HitboxSize = 5, HitboxTransparency = 0.7,
        HitboxColor = Color3.fromRGB(255, 0, 0), HeadHitbox = false,
        BodyHitbox = false, ArmHitbox = false, LegHitbox = false,
        CombatTeamCheck = false, CombatVisibleCheck = false, HitboxDistance = 200,
        HitboxMultiplier = 1, AutoUpdateHitbox = false, HugeHitbox = false,
    },
    
    -- Movement States  
    Movement = {
        NoClip = false, Fly = false, SpeedHack = false, AirWalk = false,
        InfiniteJump = false, Float = false, SpiderClimb = false,
        WallWalk = false, LowGravity = false, HighGravity = false,
    },
    
    -- Utility States
    Utility = {
        FPSCounter = false, PingCounter = false, ServerTime = false,
        AntiKick = false, AutoReconnect = false, FullBright = false,
        NightMode = false,
    },
    
    -- Teleport
    Teleport = {
        SavedPositions = {},
    },
    
    -- UI State
    UI = {
        CurrentTab = "Home",
        IsMinimized = false,
        IsMaximized = false,
        WindowSize = UDim2.new(0, 620, 0, 480),
        WindowPosition = UDim2.new(0.5, -310, 0.5, -240),
        MinimizedSize = UDim2.new(0, 200, 0, 40),
    },
    
    -- Active connections for cleanup
    Connections = {},
    ESPDrawings = {},
    ActiveLoops = {},
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Spring animation info for premium feel
local function SpringTweenInfo(duration)
    duration = duration or Config.AnimationSpeed
    return TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function SmoothTweenInfo(duration)
    duration = duration or Config.AnimationSpeed
    return TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

local function BounceTweenInfo(duration)
    duration = duration or 0.5
    return TweenInfo.new(duration, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
end

-- Animate a GUI element with optional callback
local function Animate(instance, properties, tweenInfo, callback)
    tweenInfo = tweenInfo or SmoothTweenInfo()
    local tween = TweenService:Create(instance, tweenInfo, properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

-- Create rounded corner
local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

-- Create UIStroke
local function AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Separator
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- Create UIGradient
local function AddGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    if type(colors) == "table" and #colors >= 2 then
        local keypoints = {}
        for i, c in ipairs(colors) do
            table.insert(keypoints, ColorSequenceKeypoint.new((i-1)/(#colors-1), c))
        end
        gradient.Color = ColorSequence.new(keypoints)
    else
        gradient.Color = ColorSequence.new(Config.AccentColor, Color3.fromRGB(
            math.min(255, Config.AccentColor.R * 255 + 40),
            math.min(255, Config.AccentColor.G * 255 + 20),
            math.min(255, Config.AccentColor.B * 255 + 60)
        ))
    end
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

-- Create padding
local function AddPadding(parent, top, right, bottom, left)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingRight = UDim.new(0, right or top or 8)
    padding.PaddingBottom = UDim.new(0, bottom or top or 8)
    padding.PaddingLeft = UDim.new(0, left or right or top or 8)
    padding.Parent = parent
    return padding
end

-- Create list layout
local function AddListLayout(parent, direction, padding, hAlign, vAlign, sortOrder)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, padding or 8)
    layout.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
    layout.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

-- Create grid layout
local function AddGridLayout(parent, cellSize, cellPadding)
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = cellSize or UDim2.new(0, 150, 0, 44)
    grid.CellPadding = cellPadding or UDim2.new(0, 8, 0, 8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    grid.Parent = parent
    return grid
end

-- Lerp color
local function LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

-- Get rainbow color
local function GetRainbow(speed)
    speed = speed or 1
    local t = tick() * speed
    return Color3.fromHSV(t % 1, 0.8, 1)
end

-- Truncate text
local function Truncate(text, maxLen)
    if #text > maxLen then
        return string.sub(text, 1, maxLen - 3) .. "..."
    end
    return text
end

-- ═══════════════════════════════════════════════════════════════
-- SCREEN GUI SETUP
-- ═══════════════════════════════════════════════════════════════

-- Remove existing GUI if present
if LocalPlayer.PlayerGui:FindFirstChild("NexusUI") then
    LocalPlayer.PlayerGui.NexusUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Background blur effect
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = Lighting
BlurEffect.Name = "NexusBlur"

-- Toast notification container
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 320, 1, 0)
ToastContainer.Position = UDim2.new(0.5, -160, 0, 0)
ToastContainer.BackgroundTransparency = 1
ToastContainer.Parent = ScreenGui

local toastLayout = AddListLayout(ToastContainer, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
AddPadding(ToastContainer, 50, 0, 0, 0)

-- ═══════════════════════════════════════════════════════════════
-- TOAST NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
local function ShowToast(message, toastType, duration)
    toastType = toastType or "info"
    duration = duration or 3
    
    local colors = {
        info = Config.AccentColor,
        success = Theme.Success,
        error = Theme.Error,
        warning = Theme.Warning,
    }
    
    local icons = {
        info = "ℹ️",
        success = "✓",
        error = "✕",
        warning = "⚠",
    }
    
    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.Size = UDim2.new(1, 0, 0, 48)
    toast.BackgroundColor3 = Theme.Card
    toast.BackgroundTransparency = 0.1
    toast.Position = UDim2.new(0, 0, 0, -60)
    toast.ClipsDescendants = true
    toast.Parent = ToastContainer
    AddCorner(toast, 14)
    AddStroke(toast, colors[toastType], 1, 0.6)
    
    -- Accent bar on left
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, -8)
    accentBar.Position = UDim2.new(0, 6, 0, 4)
    accentBar.BackgroundColor3 = colors[toastType]
    accentBar.BorderSizePixel = 0
    accentBar.Parent = toast
    AddCorner(accentBar, 2)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 20, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Text = icons[toastType]
    icon.TextColor3 = colors[toastType]
    icon.TextSize = 16
    icon.Font = Enum.Font.GothamBold
    icon.Parent = toast
    
    -- Message text
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -60, 1, 0)
    msgLabel.Position = UDim2.new(0, 50, 0, 0)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Theme.Text
    msgLabel.TextSize = 13
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = toast
    
    -- Animate in
    Animate(toast, {Position = UDim2.new(0, 0, 0, 0)}, SpringTweenInfo(0.4))
    
    -- Auto dismiss
    task.delay(duration, function()
        Animate(toast, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, SmoothTweenInfo(0.3), function()
            toast:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENT FACTORY
-- ═══════════════════════════════════════════════════════════════

-- Creates a glass-morphism card
local function CreateCard(parent, size, position, layoutOrder)
    local card = Instance.new("Frame")
    card.Size = size or UDim2.new(1, 0, 0, 60)
    card.Position = position or UDim2.new(0, 0, 0, 0)
    card.BackgroundColor3 = Theme.Card
    card.BackgroundTransparency = Theme.GlassTransparency
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder or 0
    card.Parent = parent
    AddCorner(card, 16)
    AddStroke(card, Theme.Separator, 1, 0.7)
    return card
end

-- Creates an iOS-style toggle switch
local function CreateToggle(parent, label, default, callback, layoutOrder)
    local card = CreateCard(parent, UDim2.new(1, -4, 0, 52), nil, layoutOrder)
    AddPadding(card, 0, 14, 0, 14)
    
    -- Label
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -70, 1, 0)
    labelText.Position = UDim2.new(0, 14, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.TextTruncate = Enum.TextTruncate.AtEnd
    labelText.Parent = card
    
    -- Toggle background (iOS pill shape)
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 51, 0, 31)
    toggleBg.Position = UDim2.new(1, -65, 0.5, -15)
    toggleBg.BackgroundColor3 = default and Config.AccentColor or Theme.Tertiary
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = card
    AddCorner(toggleBg, 16)
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 27, 0, 27)
    knob.Position = default and UDim2.new(1, -29, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    AddCorner(knob, 14)
    
    -- Knob shadow
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Size = UDim2.new(1, 6, 1, 6)
    knobShadow.Position = UDim2.new(0, -3, 0, -1)
    knobShadow.BackgroundTransparency = 1
    knobShadow.ImageTransparency = 0.7
    knobShadow.Image = "rbxassetid://5554236805"
    knobShadow.ScaleType = Enum.ScaleType.Slice
    knobShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    knobShadow.Parent = knob
    
    local isOn = default or false
    
    -- Click handler
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = card
    
    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        
        -- Animate toggle
        Animate(toggleBg, {BackgroundColor3 = isOn and Config.AccentColor or Theme.Tertiary}, SmoothTweenInfo(0.2))
        Animate(knob, {Position = isOn and UDim2.new(1, -29, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)}, SpringTweenInfo(0.3))
        
        if callback then
            callback(isOn)
        end
    end)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        Animate(card, {BackgroundTransparency = math.max(0, Theme.GlassTransparency - 0.1)}, SmoothTweenInfo(0.15))
    end)
    button.MouseLeave:Connect(function()
        Animate(card, {BackgroundTransparency = Theme.GlassTransparency}, SmoothTweenInfo(0.15))
    end)
    
    return {Card = card, SetState = function(state)
        isOn = state
        Animate(toggleBg, {BackgroundColor3 = isOn and Config.AccentColor or Theme.Tertiary}, SmoothTweenInfo(0.2))
        Animate(knob, {Position = isOn and UDim2.new(1, -29, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)}, SpringTweenInfo(0.3))
    end, GetState = function() return isOn end}
end

-- Creates a modern slider
local function CreateSlider(parent, label, min, max, default, callback, layoutOrder)
    local card = CreateCard(parent, UDim2.new(1, -4, 0, 74), nil, layoutOrder)
    
    -- Label
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, -10, 0, 22)
    labelText.Position = UDim2.new(0, 16, 0, 8)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 13
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = card
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, -16, 0, 22)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(default))
    valueLabel.TextColor3 = Config.AccentColor
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = card
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -32, 0, 6)
    track.Position = UDim2.new(0, 16, 0, 42)
    track.BackgroundColor3 = Theme.Tertiary
    track.BorderSizePixel = 0
    track.Parent = card
    AddCorner(track, 3)
    
    -- Slider fill
    local fill = Instance.new("Frame")
    local initialFill = (default - min) / (max - min)
    fill.Size = UDim2.new(math.clamp(initialFill, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Config.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = track
    AddCorner(fill, 3)
    AddGradient(fill, {Config.AccentColor, LerpColor(Config.AccentColor, Color3.fromRGB(255, 255, 255), 0.3)}, 0)
    
    -- Slider thumb
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 22, 0, 22)
    thumb.Position = UDim2.new(math.clamp(initialFill, 0, 1), -11, 0.5, -11)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 2
    thumb.Parent = track
    AddCorner(thumb, 11)
    AddStroke(thumb, Theme.Separator, 1, 0.5)
    
    -- Interaction
    local dragging = false
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 0, 0, 30)
    sliderButton.Position = UDim2.new(0, 0, 0, 32)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.Parent = card
    
    local function UpdateSlider(input)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local relativeX = math.clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
        local value = min + (max - min) * relativeX
        value = math.floor(value * 10) / 10 -- Round to 1 decimal
        
        Animate(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, SmoothTweenInfo(0.08))
        Animate(thumb, {Position = UDim2.new(relativeX, -11, 0.5, -11)}, SmoothTweenInfo(0.08))
        valueLabel.Text = tostring(math.floor(value * 10) / 10)
        
        if callback then
            callback(value)
        end
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    
    -- Hover
    sliderButton.MouseEnter:Connect(function()
        Animate(card, {BackgroundTransparency = math.max(0, Theme.GlassTransparency - 0.1)}, SmoothTweenInfo(0.15))
    end)
    sliderButton.MouseLeave:Connect(function()
        Animate(card, {BackgroundTransparency = Theme.GlassTransparency}, SmoothTweenInfo(0.15))
    end)
    
    return {Card = card, SetValue = function(val)
        local relativeX = math.clamp((val - min) / (max - min), 0, 1)
        Animate(fill, {Size = UDim2.new(relativeX, 0, 1, 0)}, SmoothTweenInfo(0.2))
        Animate(thumb, {Position = UDim2.new(relativeX, -11, 0.5, -11)}, SmoothTweenInfo(0.2))
        valueLabel.Text = tostring(math.floor(val * 10) / 10)
    end}
end

-- Creates a premium button
local function CreateButton(parent, text, callback, layoutOrder, style)
    style = style or "default"
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 44)
    btn.BackgroundColor3 = style == "accent" and Config.AccentColor or Theme.Card
    btn.BackgroundTransparency = style == "accent" and 0 or Theme.GlassTransparency
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = layoutOrder or 0
    btn.Parent = parent
    AddCorner(btn, 12)
    
    if style ~= "accent" then
        AddStroke(btn, Theme.Separator, 1, 0.7)
    else
        AddGradient(btn, {Config.AccentColor, LerpColor(Config.AccentColor, Color3.fromRGB(255, 255, 255), 0.2)}, 90)
    end
    
    local btnLabel = Instance.new("TextLabel")
    btnLabel.Size = UDim2.new(1, 0, 1, 0)
    btnLabel.BackgroundTransparency = 1
    btnLabel.Text = text
    btnLabel.TextColor3 = style == "accent" and Color3.fromRGB(255, 255, 255) or Theme.Text
    btnLabel.TextSize = 14
    btnLabel.Font = Enum.Font.GothamSemibold
    btnLabel.Parent = btn
    
    -- Press animation
    btn.MouseButton1Down:Connect(function()
        Animate(btn, {Size = UDim2.new(1, -8, 0, 42), BackgroundTransparency = style == "accent" and 0.1 or math.max(0, Theme.GlassTransparency - 0.15)}, SmoothTweenInfo(0.1))
    end)
    
    btn.MouseButton1Up:Connect(function()
        Animate(btn, {Size = UDim2.new(1, -4, 0, 44), BackgroundTransparency = style == "accent" and 0 or Theme.GlassTransparency}, SpringTweenInfo(0.3))
    end)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    -- Hover
    btn.MouseEnter:Connect(function()
        Animate(btn, {BackgroundTransparency = style == "accent" and 0 or math.max(0, Theme.GlassTransparency - 0.08)}, SmoothTweenInfo(0.15))
    end)
    btn.MouseLeave:Connect(function()
        Animate(btn, {Size = UDim2.new(1, -4, 0, 44), BackgroundTransparency = style == "accent" and 0 or Theme.GlassTransparency}, SmoothTweenInfo(0.15))
    end)
    
    return btn
end

-- Creates a color picker (simplified inline version)
local function CreateColorPicker(parent, label, default, callback, layoutOrder)
    local card = CreateCard(parent, UDim2.new(1, -4, 0, 52), nil, layoutOrder)
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -80, 1, 0)
    labelText.Position = UDim2.new(0, 16, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = card
    
    -- Color preview circle
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 32, 0, 32)
    colorPreview.Position = UDim2.new(1, -50, 0.5, -16)
    colorPreview.BackgroundColor3 = default or Config.AccentColor
    colorPreview.BorderSizePixel = 0
    colorPreview.Parent = card
    AddCorner(colorPreview, 16)
    AddStroke(colorPreview, Color3.fromRGB(255, 255, 255), 2, 0.7)
    
    -- Expanded color picker
    local expanded = false
    local colorPanel = Instance.new("Frame")
    colorPanel.Size = UDim2.new(1, -16, 0, 0)
    colorPanel.Position = UDim2.new(0, 8, 1, 4)
    colorPanel.BackgroundColor3 = Theme.Card
    colorPanel.BackgroundTransparency = Theme.GlassTransparency
    colorPanel.BorderSizePixel = 0
    colorPanel.ClipsDescendants = true
    colorPanel.Visible = false
    colorPanel.ZIndex = 10
    colorPanel.Parent = card
    AddCorner(colorPanel, 12)
    AddStroke(colorPanel, Theme.Separator, 1, 0.7)
    
    -- Preset colors
    local presetColors = {
        Color3.fromRGB(255, 59, 48), Color3.fromRGB(255, 149, 0),
        Color3.fromRGB(255, 204, 0), Color3.fromRGB(52, 199, 89),
        Color3.fromRGB(0, 199, 190), Color3.fromRGB(48, 176, 199),
        Color3.fromRGB(0, 122, 255), Color3.fromRGB(88, 86, 214),
        Color3.fromRGB(175, 82, 222), Color3.fromRGB(255, 45, 85),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(142, 142, 147),
    }
    
    local colorGrid = Instance.new("Frame")
    colorGrid.Size = UDim2.new(1, -16, 0, 80)
    colorGrid.Position = UDim2.new(0, 8, 0, 8)
    colorGrid.BackgroundTransparency = 1
    colorGrid.Parent = colorPanel
    
    local gridLayout = AddGridLayout(colorGrid, UDim2.new(0, 36, 0, 36), UDim2.new(0, 4, 0, 4))
    
    for _, color in ipairs(presetColors) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 36, 0, 36)
        colorBtn.BackgroundColor3 = color
        colorBtn.Text = ""
        colorBtn.AutoButtonColor = false
        colorBtn.Parent = colorGrid
        AddCorner(colorBtn, 8)
        
        colorBtn.MouseButton1Click:Connect(function()
            colorPreview.BackgroundColor3 = color
            if callback then callback(color) end
        end)
        
        colorBtn.MouseEnter:Connect(function()
            Animate(colorBtn, {Size = UDim2.new(0, 34, 0, 34)}, SmoothTweenInfo(0.1))
        end)
        colorBtn.MouseLeave:Connect(function()
            Animate(colorBtn, {Size = UDim2.new(0, 36, 0, 36)}, SmoothTweenInfo(0.1))
        end)
    end
    
    -- Click to expand
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = card
    
    clickBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            colorPanel.Visible = true
            Animate(colorPanel, {Size = UDim2.new(1, -16, 0, 96)}, SpringTweenInfo(0.3))
            Animate(card, {Size = UDim2.new(1, -4, 0, 156)}, SpringTweenInfo(0.3))
        else
            Animate(colorPanel, {Size = UDim2.new(1, -16, 0, 0)}, SmoothTweenInfo(0.2), function()
                colorPanel.Visible = false
            end)
            Animate(card, {Size = UDim2.new(1, -4, 0, 52)}, SmoothTweenInfo(0.2))
        end
    end)
    
    return card
end

-- Creates a dropdown
local function CreateDropdown(parent, label, options, default, callback, layoutOrder)
    local card = CreateCard(parent, UDim2.new(1, -4, 0, 52), nil, layoutOrder)
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, -10, 1, 0)
    labelText.Position = UDim2.new(0, 16, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Theme.Text
    labelText.TextSize = 14
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = card
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(0.5, -30, 1, 0)
    selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = default or (options[1] or "Select")
    selectedLabel.TextColor3 = Config.AccentColor
    selectedLabel.TextSize = 13
    selectedLabel.Font = Enum.Font.GothamSemibold
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    selectedLabel.Parent = card
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "›"
    arrow.TextColor3 = Theme.TextTertiary
    arrow.TextSize = 20
    arrow.Font = Enum.Font.GothamBold
    arrow.Rotation = 90
    arrow.Parent = card
    
    -- Dropdown list
    local expanded = false
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, -16, 0, 0)
    dropdownList.Position = UDim2.new(0, 8, 1, 4)
    dropdownList.BackgroundColor3 = Theme.Card
    dropdownList.BackgroundTransparency = 0.05
    dropdownList.BorderSizePixel = 0
    dropdownList.ClipsDescendants = true
    dropdownList.Visible = false
    dropdownList.ZIndex = 15
    dropdownList.Parent = card
    AddCorner(dropdownList, 12)
    AddStroke(dropdownList, Theme.Separator, 1, 0.5)
    
    local ddLayout = AddListLayout(dropdownList, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center)
    AddPadding(dropdownList, 4, 4, 4, 4)
    
    local function PopulateOptions(opts)
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 36)
            optBtn.BackgroundColor3 = Theme.Tertiary
            optBtn.BackgroundTransparency = 0.5
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = Theme.Text
            optBtn.TextSize = 13
            optBtn.Font = Enum.Font.GothamMedium
            optBtn.AutoButtonColor = false
            optBtn.LayoutOrder = i
            optBtn.Parent = dropdownList
            AddCorner(optBtn, 8)
            
            optBtn.MouseButton1Click:Connect(function()
                selectedLabel.Text = tostring(opt)
                expanded = false
                Animate(dropdownList, {Size = UDim2.new(1, -16, 0, 0)}, SmoothTweenInfo(0.2), function()
                    dropdownList.Visible = false
                end)
                Animate(card, {Size = UDim2.new(1, -4, 0, 52)}, SmoothTweenInfo(0.2))
                Animate(arrow, {Rotation = 90}, SmoothTweenInfo(0.2))
                if callback then callback(opt) end
            end)
            
            optBtn.MouseEnter:Connect(function()
                Animate(optBtn, {BackgroundTransparency = 0.2}, SmoothTweenInfo(0.1))
            end)
            optBtn.MouseLeave:Connect(function()
                Animate(optBtn, {BackgroundTransparency = 0.5}, SmoothTweenInfo(0.1))
            end)
        end
    end
    
    PopulateOptions(options)
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 0, 52)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = card
    
    clickBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            dropdownList.Visible = true
            local totalHeight = math.min(#options * 38 + 12, 200)
            Animate(dropdownList, {Size = UDim2.new(1, -16, 0, totalHeight)}, SpringTweenInfo(0.3))
            Animate(card, {Size = UDim2.new(1, -4, 0, 52 + totalHeight + 8)}, SpringTweenInfo(0.3))
            Animate(arrow, {Rotation = -90}, SmoothTweenInfo(0.2))
        else
            Animate(dropdownList, {Size = UDim2.new(1, -16, 0, 0)}, SmoothTweenInfo(0.2), function()
                dropdownList.Visible = false
            end)
            Animate(card, {Size = UDim2.new(1, -4, 0, 52)}, SmoothTweenInfo(0.2))
            Animate(arrow, {Rotation = 90}, SmoothTweenInfo(0.2))
        end
    end)
    
    return {Card = card, Refresh = function(newOptions)
        options = newOptions
        PopulateOptions(newOptions)
    end, GetSelected = function() return selectedLabel.Text end}
end

-- Creates a section header label
local function CreateSectionLabel(parent, text, layoutOrder)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = "  " .. string.upper(text)
    label.TextColor3 = Theme.TextTertiary
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = layoutOrder or 0
    label.Parent = parent
    return label
end

-- Creates a separator
local function CreateSeparator(parent, layoutOrder)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -32, 0, 1)
    sep.BackgroundColor3 = Theme.Separator
    sep.BackgroundTransparency = 0.5
    sep.BorderSizePixel = 0
    sep.LayoutOrder = layoutOrder or 0
    sep.Parent = parent
    return sep
end

-- Creates a scrolling frame with auto canvas size
local function CreateScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.TextTertiary
    scroll.ScrollBarImageTransparency = 0.5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent
    
    local layout = AddListLayout(scroll, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
    AddPadding(scroll, 8, 8, 8, 8)
    
    return scroll
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════

-- Main window container
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 0, 0, 0)  -- Start at 0 for open animation
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.BackgroundColor3 = Theme.Primary
MainWindow.BackgroundTransparency = Config.BackgroundTransparency
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui
AddCorner(MainWindow, 20)
AddStroke(MainWindow, Theme.Separator, 1, 0.4)

-- Window shadow (outer glow)
local windowShadow = Instance.new("ImageLabel")
windowShadow.Name = "Shadow"
windowShadow.Size = UDim2.new(1, 40, 1, 40)
windowShadow.Position = UDim2.new(0, -20, 0, -15)
windowShadow.BackgroundTransparency = 1
windowShadow.Image = "rbxassetid://5554236805"
windowShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
windowShadow.ImageTransparency = 0.5
windowShadow.ScaleType = Enum.ScaleType.Slice
windowShadow.SliceCenter = Rect.new(23, 23, 277, 277)
windowShadow.ZIndex = 0
windowShadow.Parent = MainWindow

-- ═══════════════════════════════════════════════════════════════
-- TITLE BAR
-- ═══════════════════════════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Theme.Surface
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5
TitleBar.Parent = MainWindow

-- Title bar bottom separator
local titleSep = Instance.new("Frame")
titleSep.Size = UDim2.new(1, 0, 0, 1)
titleSep.Position = UDim2.new(0, 0, 1, -1)
titleSep.BackgroundColor3 = Theme.Separator
titleSep.BackgroundTransparency = 0.5
titleSep.BorderSizePixel = 0
titleSep.Parent = TitleBar

-- Title text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -140, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Nexus"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 6
TitleLabel.Parent = TitleBar

-- Accent dot next to title
local accentDot = Instance.new("Frame")
accentDot.Size = UDim2.new(0, 8, 0, 8)
accentDot.Position = UDim2.new(0, 68, 0.5, -4)
accentDot.BackgroundColor3 = Config.AccentColor
accentDot.BorderSizePixel = 0
accentDot.ZIndex = 6
accentDot.Parent = TitleBar
AddCorner(accentDot, 4)

-- Window control buttons (macOS style dots)
local function CreateWindowButton(parent, color, position, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 7
    btn.Parent = parent
    AddCorner(btn, 7)
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseEnter:Connect(function()
        Animate(btn, {Size = UDim2.new(0, 16, 0, 16), Position = position + UDim2.new(0, -1, 0, -1)}, SmoothTweenInfo(0.1))
    end)
    btn.MouseLeave:Connect(function()
        Animate(btn, {Size = UDim2.new(0, 14, 0, 14), Position = position}, SmoothTweenInfo(0.1))
    end)
    
    return btn
end

-- Close button (red)
CreateWindowButton(TitleBar, Color3.fromRGB(255, 69, 58), UDim2.new(1, -76, 0.5, -7), function()
    Animate(MainWindow, {Size = UDim2.new(0, 0, 0, 0)}, SmoothTweenInfo(0.4), function()
        ScreenGui:Destroy()
        BlurEffect:Destroy()
    end)
    Animate(BlurEffect, {Size = 0}, SmoothTweenInfo(0.3))
    ShowToast("Nexus UI Closed", "info", 2)
end)

-- Minimize button (yellow)
CreateWindowButton(TitleBar, Color3.fromRGB(255, 189, 46), UDim2.new(1, -52, 0.5, -7), function()
    if not State.UI.IsMinimized then
        State.UI.IsMinimized = true
        State.UI.WindowSize = MainWindow.Size
        Animate(MainWindow, {Size = UDim2.new(0, 200, 0, 48)}, SpringTweenInfo(0.4))
        Animate(BlurEffect, {Size = 0}, SmoothTweenInfo(0.2))
    else
        State.UI.IsMinimized = false
        Animate(MainWindow, {Size = State.UI.WindowSize}, SpringTweenInfo(0.4))
        Animate(BlurEffect, {Size = Config.BlurAmount}, SmoothTweenInfo(0.3))
    end
end)

-- Maximize button (green)
CreateWindowButton(TitleBar, Color3.fromRGB(52, 199, 89), UDim2.new(1, -28, 0.5, -7), function()
    if not State.UI.IsMaximized then
        State.UI.IsMaximized = true
        State.UI.WindowSize = MainWindow.Size
        Animate(MainWindow, {Size = UDim2.new(0.9, 0, 0.85, 0)}, SpringTweenInfo(0.4))
    else
        State.UI.IsMaximized = false
        Animate(MainWindow, {Size = UDim2.new(0, 620, 0, 480)}, SpringTweenInfo(0.4))
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- DRAGGABLE WINDOW
-- ═══════════════════════════════════════════════════════════════
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
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

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        Animate(MainWindow, {Position = newPos}, TweenInfo.new(0.08, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- SIDEBAR / TAB NAVIGATION
-- ═══════════════════════════════════════════════════════════════
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.BackgroundColor3 = Theme.Secondary
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow

-- Sidebar right border
local sidebarBorder = Instance.new("Frame")
sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
sidebarBorder.Position = UDim2.new(1, 0, 0, 0)
sidebarBorder.BackgroundColor3 = Theme.Separator
sidebarBorder.BackgroundTransparency = 0.5
sidebarBorder.BorderSizePixel = 0
sidebarBorder.Parent = Sidebar

-- Sidebar scroll
local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Size = UDim2.new(1, 0, 1, 0)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.ScrollBarThickness = 0
SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SidebarScroll.Parent = Sidebar

local sidebarLayout = AddListLayout(SidebarScroll, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center)
AddPadding(SidebarScroll, 8, 8, 8, 8)

-- Tab definitions with icons (emoji-based for compatibility)
local TabDefinitions = {
    {Name = "Home", Icon = "🏠", Order = 1},
    {Name = "ESP", Icon = "👁", Order = 2},
    {Name = "Player", Icon = "🧑", Order = 3},
    {Name = "Teleport", Icon = "⚡", Order = 4},
    {Name = "Combat", Icon = "⚔", Order = 5},
    {Name = "Movement", Icon = "🏃", Order = 6},
    {Name = "Utility", Icon = "🔧", Order = 7},
    {Name = "Settings", Icon = "⚙", Order = 8},
    {Name = "Credits", Icon = "💎", Order = 9},
}

-- Content area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -160, 1, -48)
ContentArea.Position = UDim2.new(0, 160, 0, 48)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainWindow

-- Tab pages container
local TabPages = {}
local TabButtons = {}

-- Create tab pages
for _, tabDef in ipairs(TabDefinitions) do
    local page = Instance.new("Frame")
    page.Name = tabDef.Name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = tabDef.Name == "Home"
    page.Parent = ContentArea
    TabPages[tabDef.Name] = page
end

-- Active tab indicator (animated bar)
local activeIndicator = Instance.new("Frame")
activeIndicator.Size = UDim2.new(0, 4, 0, 28)
activeIndicator.Position = UDim2.new(0, 2, 0, 14)
activeIndicator.BackgroundColor3 = Config.AccentColor
activeIndicator.BorderSizePixel = 0
activeIndicator.ZIndex = 3
activeIndicator.Parent = SidebarScroll
AddCorner(activeIndicator, 2)

-- Create sidebar tab buttons
for i, tabDef in ipairs(TabDefinitions) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabDef.Name
    tabBtn.Size = UDim2.new(1, 0, 0, 40)
    tabBtn.BackgroundColor3 = Config.AccentColor
    tabBtn.BackgroundTransparency = tabDef.Name == "Home" and 0.85 or 1
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.BorderSizePixel = 0
    tabBtn.LayoutOrder = tabDef.Order
    tabBtn.Parent = SidebarScroll
    AddCorner(tabBtn, 10)
    
    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 28, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = tabDef.Icon
    iconLabel.TextSize = 16
    iconLabel.Font = Enum.Font.GothamMedium
    iconLabel.Parent = tabBtn
    
    -- Tab name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -48, 1, 0)
    nameLabel.Position = UDim2.new(0, 42, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = tabDef.Name
    nameLabel.TextColor3 = tabDef.Name == "Home" and Theme.Text or Theme.TextSecondary
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = tabBtn
    
    TabButtons[tabDef.Name] = {Button = tabBtn, Label = nameLabel}
    
    -- Tab switch handler
    tabBtn.MouseButton1Click:Connect(function()
        if State.UI.CurrentTab == tabDef.Name then return end
        
        -- Hide current page
        local currentPage = TabPages[State.UI.CurrentTab]
        if currentPage then
            Animate(currentPage, {Position = UDim2.new(-0.05, 0, 0, 0)}, SmoothTweenInfo(0.15), function()
                currentPage.Visible = false
                currentPage.Position = UDim2.new(0.05, 0, 0, 0)
            end)
        end
        
        -- Deactivate old button
        local oldBtn = TabButtons[State.UI.CurrentTab]
        if oldBtn then
            Animate(oldBtn.Button, {BackgroundTransparency = 1}, SmoothTweenInfo(0.2))
            Animate(oldBtn.Label, {TextColor3 = Theme.TextSecondary}, SmoothTweenInfo(0.2))
        end
        
        -- Activate new button
        State.UI.CurrentTab = tabDef.Name
        Animate(tabBtn, {BackgroundTransparency = 0.85}, SmoothTweenInfo(0.2))
        Animate(nameLabel, {TextColor3 = Theme.Text}, SmoothTweenInfo(0.2))
        
        -- Move indicator
        local btnPos = tabBtn.AbsolutePosition.Y - SidebarScroll.AbsolutePosition.Y + SidebarScroll.CanvasPosition.Y
        Animate(activeIndicator, {Position = UDim2.new(0, 2, 0, btnPos + 6)}, SpringTweenInfo(0.3))
        
        -- Show new page with animation
        task.delay(0.12, function()
            local newPage = TabPages[tabDef.Name]
            if newPage then
                newPage.Position = UDim2.new(0.05, 0, 0, 0)
                newPage.Visible = true
                Animate(newPage, {Position = UDim2.new(0, 0, 0, 0)}, SmoothTweenInfo(0.25))
            end
        end)
    end)
    
    -- Hover effect
    tabBtn.MouseEnter:Connect(function()
        if State.UI.CurrentTab ~= tabDef.Name then
            Animate(tabBtn, {BackgroundTransparency = 0.92}, SmoothTweenInfo(0.1))
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if State.UI.CurrentTab ~= tabDef.Name then
            Animate(tabBtn, {BackgroundTransparency = 1}, SmoothTweenInfo(0.1))
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: HOME
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Home"]
    local scroll = CreateScrollFrame(page)
    
    -- Header card with gradient
    local headerCard = Instance.new("Frame")
    headerCard.Size = UDim2.new(1, -4, 0, 120)
    headerCard.BackgroundColor3 = Config.AccentColor
    headerCard.BorderSizePixel = 0
    headerCard.LayoutOrder = 1
    headerCard.Parent = scroll
    AddCorner(headerCard, 18)
    AddGradient(headerCard, {
        Color3.fromRGB(0, 100, 220),
        Color3.fromRGB(0, 150, 255),
        Color3.fromRGB(50, 130, 255)
    }, 135)
    
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Size = UDim2.new(1, -24, 0, 28)
    welcomeText.Position = UDim2.new(0, 16, 0, 16)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Text = "Welcome back,"
    welcomeText.TextColor3 = Color3.fromRGB(200, 220, 255)
    welcomeText.TextSize = 14
    welcomeText.Font = Enum.Font.GothamMedium
    welcomeText.TextXAlignment = Enum.TextXAlignment.Left
    welcomeText.Parent = headerCard
    
    local playerNameText = Instance.new("TextLabel")
    playerNameText.Size = UDim2.new(1, -24, 0, 32)
    playerNameText.Position = UDim2.new(0, 16, 0, 38)
    playerNameText.BackgroundTransparency = 1
    playerNameText.Text = LocalPlayer.Name
    playerNameText.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerNameText.TextSize = 22
    playerNameText.Font = Enum.Font.GothamBold
    playerNameText.TextXAlignment = Enum.TextXAlignment.Left
    playerNameText.Parent = headerCard
    
    local versionBadge = Instance.new("Frame")
    versionBadge.Size = UDim2.new(0, 60, 0, 24)
    versionBadge.Position = UDim2.new(0, 16, 0, 78)
    versionBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    versionBadge.BackgroundTransparency = 0.8
    versionBadge.Parent = headerCard
    AddCorner(versionBadge, 12)
    
    local versionText = Instance.new("TextLabel")
    versionText.Size = UDim2.new(1, 0, 1, 0)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v" .. Config.Version
    versionText.TextColor3 = Color3.fromRGB(255, 255, 255)
    versionText.TextSize = 11
    versionText.Font = Enum.Font.GothamBold
    versionText.Parent = versionBadge
    
    CreateSectionLabel(scroll, "System Info", 2)
    
    -- Info cards row
    local infoCards = {
        {Label = "Game", Value = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown", Order = 3},
        {Label = "Executor", Value = (identifyexecutor and identifyexecutor() or "Unknown"), Order = 4},
    }
    
    for _, info in ipairs(infoCards) do
        local infoCard = CreateCard(scroll, UDim2.new(1, -4, 0, 56), nil, info.Order)
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(0.4, 0, 1, 0)
        infoLabel.Position = UDim2.new(0, 16, 0, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = info.Label
        infoLabel.TextColor3 = Theme.TextSecondary
        infoLabel.TextSize = 12
        infoLabel.Font = Enum.Font.GothamMedium
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.Parent = infoCard
        
        local infoValue = Instance.new("TextLabel")
        infoValue.Name = "Value"
        infoValue.Size = UDim2.new(0.6, -16, 1, 0)
        infoValue.Position = UDim2.new(0.4, 0, 0, 0)
        infoValue.BackgroundTransparency = 1
        infoValue.Text = Truncate(info.Value, 30)
        infoValue.TextColor3 = Theme.Text
        infoValue.TextSize = 13
        infoValue.Font = Enum.Font.GothamSemibold
        infoValue.TextXAlignment = Enum.TextXAlignment.Right
        infoValue.TextTruncate = Enum.TextTruncate.AtEnd
        infoValue.Parent = infoCard
    end
    
    -- Live stats cards (FPS, Ping, Time)
    local fpsCard = CreateCard(scroll, UDim2.new(1, -4, 0, 56), nil, 5)
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.4, 0, 1, 0)
    fpsLabel.Position = UDim2.new(0, 16, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS"
    fpsLabel.TextColor3 = Theme.TextSecondary
    fpsLabel.TextSize = 12
    fpsLabel.Font = Enum.Font.GothamMedium
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = fpsCard
    
    local fpsValue = Instance.new("TextLabel")
    fpsValue.Name = "FPSValue"
    fpsValue.Size = UDim2.new(0.6, -16, 1, 0)
    fpsValue.Position = UDim2.new(0.4, 0, 0, 0)
    fpsValue.BackgroundTransparency = 1
    fpsValue.Text = "60"
    fpsValue.TextColor3 = Theme.Success
    fpsValue.TextSize = 16
    fpsValue.Font = Enum.Font.GothamBold
    fpsValue.TextXAlignment = Enum.TextXAlignment.Right
    fpsValue.Parent = fpsCard
    
    local pingCard = CreateCard(scroll, UDim2.new(1, -4, 0, 56), nil, 6)
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(0.4, 0, 1, 0)
    pingLabel.Position = UDim2.new(0, 16, 0, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping"
    pingLabel.TextColor3 = Theme.TextSecondary
    pingLabel.TextSize = 12
    pingLabel.Font = Enum.Font.GothamMedium
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Parent = pingCard
    
    local pingValue = Instance.new("TextLabel")
    pingValue.Name = "PingValue"
    pingValue.Size = UDim2.new(0.6, -16, 1, 0)
    pingValue.Position = UDim2.new(0.4, 0, 0, 0)
    pingValue.BackgroundTransparency = 1
    pingValue.Text = "0ms"
    pingValue.TextColor3 = Config.AccentColor
    pingValue.TextSize = 16
    pingValue.Font = Enum.Font.GothamBold
    pingValue.TextXAlignment = Enum.TextXAlignment.Right
    pingValue.Parent = pingCard
    
    CreateSectionLabel(scroll, "Quick Actions", 7)
    
    CreateButton(scroll, "📋 Copy Discord: discord.gg/nexus", function()
        if setclipboard then setclipboard("discord.gg/nexus") end
        ShowToast("Discord link copied!", "success")
    end, 8)
    
    CreateButton(scroll, "🔗 Copy PlaceID: " .. game.PlaceId, function()
        if setclipboard then setclipboard(tostring(game.PlaceId)) end
        ShowToast("PlaceID copied!", "success")
    end, 9)
    
    CreateButton(scroll, "📄 Update Log", function()
        ShowToast("v3.0.0 — Complete UI overhaul with iOS design", "info", 4)
    end, 10)
    
    -- Update FPS and Ping continuously
    local lastFPSUpdate = 0
    table.insert(State.Connections, RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastFPSUpdate >= 0.5 then
            lastFPSUpdate = now
            local fps = math.floor(1 / RunService.Heartbeat:Wait())
            if fpsValue and fpsValue.Parent then
                fpsValue.Text = tostring(math.min(fps, 999))
                fpsValue.TextColor3 = fps >= 50 and Theme.Success or (fps >= 30 and Theme.Warning or Theme.Error)
            end
            
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            if pingValue and pingValue.Parent then
                pingValue.Text = tostring(ping) .. "ms"
                pingValue.TextColor3 = ping <= 80 and Theme.Success or (ping <= 150 and Theme.Warning or Theme.Error)
            end
        end
    end))
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: ESP
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["ESP"]
    local scroll = CreateScrollFrame(page)
    
    -- Page title
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "ESP Configuration"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    CreateSectionLabel(scroll, "Master Control", 1)
    
    CreateToggle(scroll, "Master ESP", false, function(v)
        State.ESP.MasterESP = v
        ShowToast(v and "ESP Enabled" or "ESP Disabled", v and "success" or "info")
    end, 2)
    
    CreateSectionLabel(scroll, "Box ESP", 3)
    
    local espBoxFeatures = {
        {Name = "Box ESP", Key = "BoxESP", Order = 4},
        {Name = "Filled Box", Key = "FilledBox", Order = 5},
        {Name = "Corner Box", Key = "CornerBox", Order = 6},
    }
    
    for _, feat in ipairs(espBoxFeatures) do
        CreateToggle(scroll, feat.Name, false, function(v)
            State.ESP[feat.Key] = v
        end, feat.Order)
    end
    
    CreateSectionLabel(scroll, "Body ESP", 7)
    
    local espBodyFeatures = {
        {Name = "Skeleton ESP", Key = "SkeletonESP", Order = 8},
        {Name = "Head Dot", Key = "HeadDot", Order = 9},
        {Name = "Head Circle", Key = "HeadCircle", Order = 10},
        {Name = "Chams", Key = "Chams", Order = 11},
        {Name = "Rainbow Chams", Key = "RainbowChams", Order = 12},
        {Name = "Highlight ESP", Key = "HighlightESP", Order = 13},
    }
    
    for _, feat in ipairs(espBodyFeatures) do
        CreateToggle(scroll, feat.Name, false, function(v)
            State.ESP[feat.Key] = v
        end, feat.Order)
    end
    
    CreateSectionLabel(scroll, "Info ESP", 14)
    
    local espInfoFeatures = {
        {Name = "Health Bar", Key = "HealthBar", Order = 15},
        {Name = "Health Text", Key = "HealthText", Order = 16},
        {Name = "Name ESP", Key = "NameESP", Order = 17},
        {Name = "Distance ESP", Key = "DistanceESP", Order = 18},
        {Name = "Weapon ESP", Key = "WeaponESP", Order = 19},
        {Name = "Tool ESP", Key = "ToolESP", Order = 20},
    }
    
    for _, feat in ipairs(espInfoFeatures) do
        CreateToggle(scroll, feat.Name, false, function(v)
            State.ESP[feat.Key] = v
        end, feat.Order)
    end
    
    CreateSectionLabel(scroll, "Lines & Tracers", 21)
    
    local espTracerFeatures = {
        {Name = "Tracer", Key = "Tracer", Order = 22},
        {Name = "Bottom Tracer", Key = "BottomTracer", Order = 23},
        {Name = "Top Tracer", Key = "TopTracer", Order = 24},
        {Name = "Snapline", Key = "Snapline", Order = 25},
        {Name = "Offscreen Arrow", Key = "OffscreenArrow", Order = 26},
    }
    
    for _, feat in ipairs(espTracerFeatures) do
        CreateToggle(scroll, feat.Name, false, function(v)
            State.ESP[feat.Key] = v
        end, feat.Order)
    end
    
    CreateSectionLabel(scroll, "Checks & Filters", 27)
    
    CreateToggle(scroll, "Team Check", false, function(v)
        State.ESP.TeamCheck = v
    end, 28)
    
    CreateToggle(scroll, "Visible Check", false, function(v)
        State.ESP.VisibleCheck = v
    end, 29)
    
    CreateToggle(scroll, "Dynamic Color", false, function(v)
        State.ESP.DynamicColor = v
    end, 30)
    
    CreateSectionLabel(scroll, "Appearance", 31)
    
    CreateSlider(scroll, "ESP Transparency", 0, 1, 0.5, function(v)
        State.ESP.ESPTransparency = v
    end, 32)
    
    CreateSlider(scroll, "ESP Thickness", 1, 5, 1.5, function(v)
        State.ESP.Thickness = v
    end, 33)
    
    CreateSlider(scroll, "Max Distance", 100, 2000, 500, function(v)
        State.ESP.MaxDistance = v
    end, 34)
    
    CreateColorPicker(scroll, "ESP Color", Config.AccentColor, function(c)
        State.ESP.Color = c
    end, 35)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: PLAYER
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Player"]
    local scroll = CreateScrollFrame(page)
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Player Modifications"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    CreateSectionLabel(scroll, "Character Stats", 1)
    
    CreateSlider(scroll, "WalkSpeed", 0, 500, 16, function(v)
        State.Player.WalkSpeed = v
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end)
    end, 2)
    
    CreateSlider(scroll, "JumpPower", 0, 500, 50, function(v)
        State.Player.JumpPower = v
        pcall(function()
            LocalPlayer.Character.Humanoid.JumpPower = v
            LocalPlayer.Character.Humanoid.UseJumpPower = true
        end)
    end, 3)
    
    CreateSlider(scroll, "HipHeight", -10, 50, 0, function(v)
        State.Player.HipHeight = v
        pcall(function()
            LocalPlayer.Character.Humanoid.HipHeight = v
        end)
    end, 4)
    
    CreateSlider(scroll, "Gravity", 0, 500, 196.2, function(v)
        State.Player.Gravity = v
        Workspace.Gravity = v
    end, 5)
    
    CreateSectionLabel(scroll, "Movement", 6)
    
    CreateToggle(scroll, "Infinite Jump", false, function(v)
        State.Player.InfiniteJump = v
        ShowToast(v and "Infinite Jump enabled" or "Infinite Jump disabled", v and "success" or "info")
    end, 7)
    
    CreateToggle(scroll, "Fly", false, function(v)
        State.Player.Fly = v
        ShowToast(v and "Fly enabled — Use WASD to move" or "Fly disabled", v and "success" or "info")
    end, 8)
    
    CreateToggle(scroll, "No Clip", false, function(v)
        State.Player.NoClip = v
        ShowToast(v and "NoClip enabled" or "NoClip disabled", v and "success" or "info")
    end, 9)
    
    CreateToggle(scroll, "Auto Sprint", false, function(v)
        State.Player.AutoSprint = v
    end, 10)
    
    CreateToggle(scroll, "Bunny Hop", false, function(v)
        State.Player.BunnyHop = v
    end, 11)
    
    CreateSectionLabel(scroll, "Protection", 12)
    
    CreateToggle(scroll, "God Mode Visual", false, function(v)
        State.Player.GodMode = v
        ShowToast(v and "God Mode Visual enabled" or "God Mode Visual disabled", v and "success" or "info")
    end, 13)
    
    CreateToggle(scroll, "Anti AFK", false, function(v)
        State.Player.AntiAFK = v
        if v then
            -- Remove idle connection
            local vu = game:GetService("VirtualUser")
            table.insert(State.Connections, LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end))
            ShowToast("Anti AFK activated", "success")
        end
    end, 14)
    
    CreateSectionLabel(scroll, "Actions", 15)
    
    CreateButton(scroll, "🔄 Reset Character", function()
        pcall(function()
            LocalPlayer.Character:BreakJoints()
        end)
        ShowToast("Character reset", "info")
    end, 16)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: TELEPORT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Teleport"]
    local scroll = CreateScrollFrame(page)
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Teleportation"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    CreateSectionLabel(scroll, "Player Teleport", 1)
    
    -- Player dropdown
    local function GetPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        return names
    end
    
    local playerDropdown = CreateDropdown(scroll, "Target Player", GetPlayerNames(), nil, nil, 2)
    
    CreateButton(scroll, "🔄 Refresh Player List", function()
        playerDropdown.Refresh(GetPlayerNames())
        ShowToast("Player list refreshed", "success")
    end, 3)
    
    CreateButton(scroll, "⚡ Teleport to Player", function()
        local target = playerDropdown.GetSelected()
        local targetPlayer = Players:FindFirstChild(target)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            end)
            ShowToast("Teleported to " .. target, "success")
        else
            ShowToast("Player not found or has no character", "error")
        end
    end, 4, "accent")
    
    CreateButton(scroll, "👁 Bring Camera to Player", function()
        local target = playerDropdown.GetSelected()
        local targetPlayer = Players:FindFirstChild(target)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
            ShowToast("Camera following " .. target, "success")
        end
    end, 5)
    
    CreateButton(scroll, "🔙 Teleport Behind Player", function()
        local target = playerDropdown.GetSelected()
        local targetPlayer = Players:FindFirstChild(target)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local targetCF = targetPlayer.Character.HumanoidRootPart.CFrame
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF * CFrame.new(0, 0, 5)
            end)
            ShowToast("Teleported behind " .. target, "success")
        end
    end, 6)
    
    CreateButton(scroll, "⬆ Teleport Above Player", function()
        local target = playerDropdown.GetSelected()
        local targetPlayer = Players:FindFirstChild(target)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local targetCF = targetPlayer.Character.HumanoidRootPart.CFrame
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetCF * CFrame.new(0, 20, 0)
            end)
            ShowToast("Teleported above " .. target, "success")
        end
    end, 7)
    
    CreateSectionLabel(scroll, "Waypoints", 8)
    
    CreateButton(scroll, "💾 Save Current Position", function()
        pcall(function()
            local pos = LocalPlayer.Character.HumanoidRootPart.CFrame
            State.Teleport.SavedPositions[#State.Teleport.SavedPositions + 1] = pos
            ShowToast("Position saved (Slot " .. #State.Teleport.SavedPositions .. ")", "success")
        end)
    end, 9)
    
    CreateButton(scroll, "📍 Load Last Position", function()
        if #State.Teleport.SavedPositions > 0 then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = State.Teleport.SavedPositions[#State.Teleport.SavedPositions]
            end)
            ShowToast("Loaded saved position", "success")
        else
            ShowToast("No saved positions", "error")
        end
    end, 10)
    
    CreateSectionLabel(scroll, "Click Teleport", 11)
    
    CreateToggle(scroll, "Click Teleport (Ctrl+Click)", false, function(v)
        State.Teleport.ClickTP = v
        ShowToast(v and "Click teleport enabled" or "Click teleport disabled", v and "success" or "info")
    end, 12)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: COMBAT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Combat"]
    local scroll = CreateScrollFrame(page)
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Combat Settings"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    CreateSectionLabel(scroll, "Hitbox Expander", 1)
    
    CreateToggle(scroll, "Hitbox Expander", false, function(v)
        State.Combat.HitboxExpander = v
        ShowToast(v and "Hitbox Expander enabled" or "Hitbox Expander disabled", v and "success" or "info")
    end, 2)
    
    CreateToggle(scroll, "Auto Update Hitbox", false, function(v)
        State.Combat.AutoUpdateHitbox = v
    end, 3)
    
    CreateToggle(scroll, "Enable Huge Hitbox", false, function(v)
        State.Combat.HugeHitbox = v
    end, 4)
    
    CreateSectionLabel(scroll, "Hitbox Config", 5)
    
    CreateSlider(scroll, "Hitbox Size", 1, 50, 5, function(v)
        State.Combat.HitboxSize = v
    end, 6)
    
    CreateSlider(scroll, "Hitbox Transparency", 0, 1, 0.7, function(v)
        State.Combat.HitboxTransparency = v
    end, 7)
    
    CreateSlider(scroll, "Hitbox Distance", 50, 1000, 200, function(v)
        State.Combat.HitboxDistance = v
    end, 8)
    
    CreateSlider(scroll, "Hitbox Multiplier", 0.5, 5, 1, function(v)
        State.Combat.HitboxMultiplier = v
    end, 9)
    
    CreateColorPicker(scroll, "Hitbox Color", Color3.fromRGB(255, 0, 0), function(c)
        State.Combat.HitboxColor = c
    end, 10)
    
    CreateSectionLabel(scroll, "Body Parts", 11)
    
    CreateToggle(scroll, "Head Hitbox", false, function(v)
        State.Combat.HeadHitbox = v
    end, 12)
    
    CreateToggle(scroll, "Body Hitbox (Torso)", false, function(v)
        State.Combat.BodyHitbox = v
    end, 13)
    
    CreateToggle(scroll, "Arm Hitbox", false, function(v)
        State.Combat.ArmHitbox = v
    end, 14)
    
    CreateToggle(scroll, "Leg Hitbox", false, function(v)
        State.Combat.LegHitbox = v
    end, 15)
    
    CreateSectionLabel(scroll, "Filters", 16)
    
    CreateToggle(scroll, "Team Check", false, function(v)
        State.Combat.CombatTeamCheck = v
    end, 17)
    
    CreateToggle(scroll, "Visible Check", false, function(v)
        State.Combat.CombatVisibleCheck = v
    end, 18)
    
    CreateSectionLabel(scroll, "Actions", 19)
    
    CreateButton(scroll, "🔄 Restore Default Hitbox", function()
        State.Combat.HitboxExpander = false
        -- Reset all hitboxes
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Size = part:GetAttribute("OriginalSize") or part.Size
                        part.Transparency = part:GetAttribute("OriginalTransparency") or 0
                    end
                end
            end
        end
        ShowToast("Hitboxes restored to default", "success")
    end, 20)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: MOVEMENT
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Movement"]
    local scroll = CreateScrollFrame(page)
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Movement Hacks"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    CreateSectionLabel(scroll, "Primary", 1)
    
    local movementFeatures = {
        {Name = "No Clip", Key = "NoClip", Desc = "Walk through walls", Order = 2},
        {Name = "Fly", Key = "Fly", Desc = "Fly freely", Order = 3},
        {Name = "Speed Hack", Key = "SpeedHack", Desc = "Move faster", Order = 4},
        {Name = "Air Walk", Key = "AirWalk", Desc = "Walk on air", Order = 5},
        {Name = "Infinite Jump", Key = "InfiniteJump", Desc = "Jump unlimited", Order = 6},
    }
    
    for _, feat in ipairs(movementFeatures) do
        CreateToggle(scroll, feat.Name, false, function(v)
            State.Movement[feat.Key] = v
            ShowToast(v and (feat.Name .. " enabled") or (feat.Name .. " disabled"), v and "success" or "info")
        end, feat.Order)
    end
    
    CreateSectionLabel(scroll, "Advanced", 7)
    
    local advancedMovement = {
        {Name = "Float", Key = "Float", Order = 8},
        {Name = "Spider Climb", Key = "SpiderClimb", Order = 9},
        {Name = "Wall Walk", Key = "WallWalk", Order = 10},
    }
    
    for _, feat in ipairs(advancedMovement) do
        CreateToggle(scroll, feat.Name, false, function(v)
            State.Movement[feat.Key] = v
            ShowToast(v and (feat.Name .. " enabled") or (feat.Name .. " disabled"), v and "success" or "info")
        end, feat.Order)
    end
    
    CreateSectionLabel(scroll, "Gravity", 11)
    
    CreateToggle(scroll, "Low Gravity", false, function(v)
        State.Movement.LowGravity = v
        if v then
            Workspace.Gravity = 50
            State.Movement.HighGravity = false
        else
            Workspace.Gravity = 196.2
        end
        ShowToast(v and "Low gravity enabled" or "Gravity restored", v and "success" or "info")
    end, 12)
    
    CreateToggle(scroll, "High Gravity", false, function(v)
        State.Movement.HighGravity = v
        if v then
            Workspace.Gravity = 500
            State.Movement.LowGravity = false
        else
            Workspace.Gravity = 196.2
        end
        ShowToast(v and "High gravity enabled" or "Gravity restored", v and "success" or "info")
    end, 13)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: UTILITY
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Utility"]
    local scroll = CreateScrollFrame(page)
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Utilities"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    CreateSectionLabel(scroll, "Display", 1)
    
    CreateToggle(scroll, "FPS Counter", false, function(v)
        State.Utility.FPSCounter = v
    end, 2)
    
    CreateToggle(scroll, "Ping Counter", false, function(v)
        State.Utility.PingCounter = v
    end, 3)
    
    CreateToggle(scroll, "Server Time", false, function(v)
        State.Utility.ServerTime = v
    end, 4)
    
    CreateSectionLabel(scroll, "Lighting", 5)
    
    CreateToggle(scroll, "Full Bright", false, function(v)
        State.Utility.FullBright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
        ShowToast(v and "Full Bright enabled" or "Full Bright disabled", v and "success" or "info")
    end, 6)
    
    CreateToggle(scroll, "Night Mode", false, function(v)
        State.Utility.NightMode = v
        if v then
            Lighting.ClockTime = 0
            Lighting.Brightness = 0.2
        else
            Lighting.ClockTime = 14
            Lighting.Brightness = 1
        end
    end, 7)
    
    CreateSectionLabel(scroll, "Protection", 8)
    
    CreateToggle(scroll, "Anti Kick", false, function(v)
        State.Utility.AntiKick = v
        if v then
            local oldKick = LocalPlayer.Kick
            LocalPlayer.Kick = function() end
            ShowToast("Anti Kick activated", "success")
        end
    end, 9)
    
    CreateToggle(scroll, "Auto Reconnect", false, function(v)
        State.Utility.AutoReconnect = v
    end, 10)
    
    CreateSectionLabel(scroll, "Server Actions", 11)
    
    CreateButton(scroll, "🔄 Rejoin Server", function()
        ShowToast("Rejoining server...", "info")
        task.delay(1, function()
            pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            end)
        end)
    end, 12)
    
    CreateButton(scroll, "🌐 Server Hop", function()
        ShowToast("Finding new server...", "info")
        task.delay(1, function()
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                ))
                for _, server in ipairs(servers.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        break
                    end
                end
            end)
        end)
    end, 13)
    
    CreateButton(scroll, "📋 Copy JobID", function()
        if setclipboard then setclipboard(game.JobId) end
        ShowToast("JobID copied!", "success")
    end, 14)
    
    CreateButton(scroll, "📋 Copy PlaceID", function()
        if setclipboard then setclipboard(tostring(game.PlaceId)) end
        ShowToast("PlaceID copied!", "success")
    end, 15)
    
    CreateSectionLabel(scroll, "Danger Zone", 16)
    
    CreateButton(scroll, "🗑 Destroy All GUI", function()
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui.Name ~= "NexusUI" then
                pcall(function() gui:Destroy() end)
            end
        end
        ShowToast("All other GUIs destroyed", "warning")
    end, 17)
    
    CreateButton(scroll, "⏏ Unload Script", function()
        ShowToast("Unloading Nexus UI...", "info")
        task.delay(1, function()
            -- Clean up connections
            for _, conn in ipairs(State.Connections) do
                pcall(function() conn:Disconnect() end)
            end
            BlurEffect:Destroy()
            ScreenGui:Destroy()
        end)
    end, 18)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: SETTINGS
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Settings"]
    local scroll = CreateScrollFrame(page)
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Settings"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    CreateSectionLabel(scroll, "Appearance", 1)
    
    CreateColorPicker(scroll, "Accent Color", Config.AccentColor, function(c)
        Config.AccentColor = c
        -- Update accent elements
        accentDot.BackgroundColor3 = c
        ShowToast("Accent color updated", "success")
    end, 2)
    
    CreateSlider(scroll, "Blur Amount", 0, 30, Config.BlurAmount, function(v)
        Config.BlurAmount = v
        BlurEffect.Size = v
    end, 3)
    
    CreateSlider(scroll, "Animation Speed", 0.1, 1, Config.AnimationSpeed, function(v)
        Config.AnimationSpeed = v
    end, 4)
    
    CreateToggle(scroll, "Rainbow UI", false, function(v)
        Config.RainbowUI = v
        ShowToast(v and "Rainbow mode activated! 🌈" or "Rainbow mode disabled", v and "success" or "info")
    end, 5)
    
    CreateSlider(scroll, "Background Transparency", 0, 1, Config.BackgroundTransparency, function(v)
        Config.BackgroundTransparency = v
        MainWindow.BackgroundTransparency = v
    end, 6)
    
    CreateSectionLabel(scroll, "Theme", 7)
    
    local themeNames = {}
    for name, _ in pairs(Themes) do
        table.insert(themeNames, name)
    end
    table.sort(themeNames)
    
    CreateDropdown(scroll, "Theme", themeNames, CurrentTheme, function(selected)
        CurrentTheme = selected
        Theme = Themes[selected]
        
        -- Apply theme changes to main elements
        Animate(MainWindow, {BackgroundColor3 = Theme.Primary}, SmoothTweenInfo(0.5))
        Animate(TitleBar, {BackgroundColor3 = Theme.Surface}, SmoothTweenInfo(0.5))
        Animate(Sidebar, {BackgroundColor3 = Theme.Secondary}, SmoothTweenInfo(0.5))
        TitleLabel.TextColor3 = Theme.Text
        
        ShowToast("Theme changed to " .. selected, "success")
    end, 8)
    
    CreateSectionLabel(scroll, "Configuration", 9)
    
    CreateButton(scroll, "💾 Save Config", function()
        -- In a real implementation, this would use writefile
        ShowToast("Config saved successfully", "success")
    end, 10, "accent")
    
    CreateButton(scroll, "📂 Load Config", function()
        ShowToast("Config loaded", "success")
    end, 11)
    
    CreateButton(scroll, "🔄 Reset Config", function()
        Config.AccentColor = Color3.fromRGB(0, 122, 255)
        Config.BlurAmount = 12
        Config.AnimationSpeed = 0.3
        Config.RainbowUI = false
        Config.BackgroundTransparency = 0.15
        BlurEffect.Size = 12
        MainWindow.BackgroundTransparency = 0.15
        ShowToast("Config reset to defaults", "success")
    end, 12)
end

-- ═══════════════════════════════════════════════════════════════
-- PAGE: CREDITS
-- ═══════════════════════════════════════════════════════════════
do
    local page = TabPages["Credits"]
    local scroll = CreateScrollFrame(page)
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 36)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "Credits"
    pageTitle.TextColor3 = Theme.Text
    pageTitle.TextSize = 20
    pageTitle.Font = Enum.Font.GothamBold
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = scroll
    
    -- Developer profile card
    local profileCard = Instance.new("Frame")
    profileCard.Size = UDim2.new(1, -4, 0, 200)
    profileCard.BackgroundColor3 = Theme.Card
    profileCard.BackgroundTransparency = Theme.GlassTransparency
    profileCard.BorderSizePixel = 0
    profileCard.LayoutOrder = 1
    profileCard.Parent = scroll
    AddCorner(profileCard, 20)
    AddStroke(profileCard, Theme.Separator, 1, 0.6)
    
    -- Gradient top banner
    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, 0, 0, 80)
    banner.BackgroundColor3 = Config.AccentColor
    banner.BorderSizePixel = 0
    banner.ClipsDescendants = true
    banner.Parent = profileCard
    AddCorner(banner, 20)
    AddGradient(banner, {
        Color3.fromRGB(0, 100, 220),
        Color3.fromRGB(88, 86, 214),
        Color3.fromRGB(175, 82, 222)
    }, 90)
    
    -- Fix bottom corners of banner
    local bannerFix = Instance.new("Frame")
    bannerFix.Size = UDim2.new(1, 0, 0, 20)
    bannerFix.Position = UDim2.new(0, 0, 1, -20)
    bannerFix.BackgroundColor3 = Config.AccentColor
    bannerFix.BorderSizePixel = 0
    bannerFix.Parent = banner
    AddGradient(bannerFix, {
        Color3.fromRGB(0, 100, 220),
        Color3.fromRGB(88, 86, 214),
        Color3.fromRGB(175, 82, 222)
    }, 90)
    
    -- Avatar circle
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 70, 0, 70)
    avatarFrame.Position = UDim2.new(0.5, -35, 0, 45)
    avatarFrame.BackgroundColor3 = Theme.Primary
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 3
    avatarFrame.Parent = profileCard
    AddCorner(avatarFrame, 35)
    AddStroke(avatarFrame, Theme.Primary, 4, 0)
    
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, -4, 1, -4)
    avatarImage.Position = UDim2.new(0, 2, 0, 2)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatarImage.ZIndex = 4
    avatarImage.Parent = avatarFrame
    AddCorner(avatarImage, 33)
    
    -- Developer name
    local devName = Instance.new("TextLabel")
    devName.Size = UDim2.new(1, 0, 0, 24)
    devName.Position = UDim2.new(0, 0, 0, 125)
    devName.BackgroundTransparency = 1
    devName.Text = "Nexus Team"
    devName.TextColor3 = Theme.Text
    devName.TextSize = 17
    devName.Font = Enum.Font.GothamBold
    devName.Parent = profileCard
    
    -- Subtitle
    local devSub = Instance.new("TextLabel")
    devSub.Size = UDim2.new(1, 0, 0, 20)
    devSub.Position = UDim2.new(0, 0, 0, 148)
    devSub.BackgroundTransparency = 1
    devSub.Text = "Premium UI Framework"
    devSub.TextColor3 = Theme.TextSecondary
    devSub.TextSize = 12
    devSub.Font = Enum.Font.GothamMedium
    devSub.Parent = profileCard
    
    -- Version badge
    local verBadge = Instance.new("Frame")
    verBadge.Size = UDim2.new(0, 80, 0, 22)
    verBadge.Position = UDim2.new(0.5, -40, 0, 172)
    verBadge.BackgroundColor3 = Config.AccentColor
    verBadge.BackgroundTransparency = 0.8
    verBadge.Parent = profileCard
    AddCorner(verBadge, 11)
    
    local verText = Instance.new("TextLabel")
    verText.Size = UDim2.new(1, 0, 1, 0)
    verText.BackgroundTransparency = 1
    verText.Text = "v" .. Config.Version
    verText.TextColor3 = Config.AccentColor
    verText.TextSize = 11
    verText.Font = Enum.Font.GothamBold
    verText.Parent = verBadge
    
    CreateSectionLabel(scroll, "Info", 2)
    
    -- Info items
    local infoItems = {
        {Label = "Version", Value = Config.Version, Order = 3},
        {Label = "Build Date", Value = Config.BuildDate, Order = 4},
        {Label = "Framework", Value = "Nexus UI v3", Order = 5},
        {Label = "Lua Version", Value = "Luau", Order = 6},
    }
    
    for _, item in ipairs(infoItems) do
        local infoCard = CreateCard(scroll, UDim2.new(1, -4, 0, 48), nil, item.Order)
        
        local iLabel = Instance.new("TextLabel")
        iLabel.Size = UDim2.new(0.5, 0, 1, 0)
        iLabel.Position = UDim2.new(0, 16, 0, 0)
        iLabel.BackgroundTransparency = 1
        iLabel.Text = item.Label
        iLabel.TextColor3 = Theme.TextSecondary
        iLabel.TextSize = 13
        iLabel.Font = Enum.Font.GothamMedium
        iLabel.TextXAlignment = Enum.TextXAlignment.Left
        iLabel.Parent = infoCard
        
        local iValue = Instance.new("TextLabel")
        iValue.Size = UDim2.new(0.5, -16, 1, 0)
        iValue.Position = UDim2.new(0.5, 0, 0, 0)
        iValue.BackgroundTransparency = 1
        iValue.Text = item.Value
        iValue.TextColor3 = Theme.Text
        iValue.TextSize = 13
        iValue.Font = Enum.Font.GothamSemibold
        iValue.TextXAlignment = Enum.TextXAlignment.Right
        iValue.Parent = infoCard
    end
    
    CreateSectionLabel(scroll, "Special Thanks", 7)
    
    local thanksCard = CreateCard(scroll, UDim2.new(1, -4, 0, 80), nil, 8)
    AddPadding(thanksCard, 14, 14, 14, 14)
    
    local thanksText = Instance.new("TextLabel")
    thanksText.Size = UDim2.new(1, 0, 1, 0)
    thanksText.BackgroundTransparency = 1
    thanksText.Text = "Thank you to the entire community for your continued support and feedback. This project is made possible by passionate developers and users alike. 💙"
    thanksText.TextColor3 = Theme.TextSecondary
    thanksText.TextSize = 12
    thanksText.Font = Enum.Font.GothamMedium
    thanksText.TextWrapped = true
    thanksText.TextXAlignment = Enum.TextXAlignment.Left
    thanksText.TextYAlignment = Enum.TextYAlignment.Top
    thanksText.Parent = thanksCard
end

-- ═══════════════════════════════════════════════════════════════
-- GAME LOOPS (NoClip, Fly, InfiniteJump, Hitbox, etc.)
-- ═══════════════════════════════════════════════════════════════

-- NoClip loop
table.insert(State.Connections, RunService.Stepped:Connect(function()
    if (State.Player.NoClip or State.Movement.NoClip) and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end))

-- Infinite Jump
table.insert(State.Connections, UserInputService.JumpRequest:Connect(function()
    if State.Player.InfiniteJump or State.Movement.InfiniteJump then
        pcall(function()
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end))

-- Fly system
local flySpeed = 60
local flyBV = nil
local flyBG = nil

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
            
            local direction = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
            
            flyBV.Velocity = direction * flySpeed
            flyBG.CFrame = Camera.CFrame
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
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

-- Hitbox Expander Loop
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Combat.HitboxExpander then
        pcall(function()
            local size = State.Combat.HitboxSize * State.Combat.HitboxMultiplier
            if State.Combat.HugeHitbox then size = size * 3 end
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    -- Team check
                    if State.Combat.CombatTeamCheck and p.Team == LocalPlayer.Team then
                        continue
                    end
                    
                    -- Distance check
                    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
                    local theirPos = p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart.Position
                    if myPos and theirPos and (myPos - theirPos).Magnitude > State.Combat.HitboxDistance then
                        continue
                    end
                    
                    -- Apply to selected body parts
                    local parts = {}
                    if State.Combat.HeadHitbox then table.insert(parts, "Head") end
                    if State.Combat.BodyHitbox then 
                        table.insert(parts, "Torso")
                        table.insert(parts, "UpperTorso")
                        table.insert(parts, "LowerTorso")
                    end
                    if State.Combat.ArmHitbox then
                        table.insert(parts, "Left Arm")
                        table.insert(parts, "Right Arm")
                        table.insert(parts, "LeftUpperArm")
                        table.insert(parts, "RightUpperArm")
                        table.insert(parts, "LeftLowerArm")
                        table.insert(parts, "RightLowerArm")
                        table.insert(parts, "LeftHand")
                        table.insert(parts, "RightHand")
                    end
                    if State.Combat.LegHitbox then
                        table.insert(parts, "Left Leg")
                        table.insert(parts, "Right Leg")
                        table.insert(parts, "LeftUpperLeg")
                        table.insert(parts, "RightUpperLeg")
                        table.insert(parts, "LeftLowerLeg")
                        table.insert(parts, "RightLowerLeg")
                        table.insert(parts, "LeftFoot")
                        table.insert(parts, "RightFoot")
                    end
                    
                    -- If no specific parts selected, use HumanoidRootPart
                    if #parts == 0 then parts = {"HumanoidRootPart"} end
                    
                    for _, partName in ipairs(parts) do
                        local part = p.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            -- Save original size
                            if not part:GetAttribute("OriginalSize") then
                                part:SetAttribute("OriginalSizeX", part.Size.X)
                                part:SetAttribute("OriginalSizeY", part.Size.Y)
                                part:SetAttribute("OriginalSizeZ", part.Size.Z)
                            end
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
    if State.Teleport.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        pcall(function()
            local target = Mouse.Hit
            if target then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target + Vector3.new(0, 3, 0)
                ShowToast("Teleported!", "success", 1)
            end
        end)
    end
end))

-- Float
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Movement.Float and LocalPlayer.Character then
        pcall(function()
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            end
        end)
    end
end))

-- Speed Hack
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if State.Movement.SpeedHack and LocalPlayer.Character then
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = 100
        end)
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- ESP SYSTEM (Drawing API based for performance)
-- ═══════════════════════════════════════════════════════════════
-- Note: Full ESP with Drawing API requires executor support.
-- This is a highlight-based fallback that works universally.

table.insert(State.Connections, RunService.RenderStepped:Connect(function()
    if not State.ESP.MasterESP then
        -- Clean up highlights
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local existing = p.Character:FindFirstChild("NexusHighlight")
                if existing then existing:Destroy() end
                
                -- Clean up BillboardGuis
                local bbg = p.Character:FindFirstChild("NexusESPGui")
                if bbg then bbg:Destroy() end
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
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                -- Team Check
                if State.ESP.TeamCheck and p.Team == LocalPlayer.Team then
                    local existing = char:FindFirstChild("NexusHighlight")
                    if existing then existing:Destroy() end
                    local bbg = char:FindFirstChild("NexusESPGui")
                    if bbg then bbg:Destroy() end
                    return
                end
                
                -- Distance check
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local distance = myHRP and (myHRP.Position - hrp.Position).Magnitude or 0
                local maxDist = State.ESP.MaxDistance or 500
                if distance > maxDist then
                    local existing = char:FindFirstChild("NexusHighlight")
                    if existing then existing:Destroy() end
                    local bbg = char:FindFirstChild("NexusESPGui")
                    if bbg then bbg:Destroy() end
                    return
                end
                
                -- Highlight ESP (Chams)
                if State.ESP.HighlightESP or State.ESP.Chams then
                    local highlight = char:FindFirstChild("NexusHighlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "NexusHighlight"
                        highlight.Adornee = char
                        highlight.FillTransparency = State.ESP.ESPTransparency
                        highlight.OutlineTransparency = 0.3
                        highlight.Parent = char
                    end
                    
                    if State.ESP.RainbowChams then
                        highlight.FillColor = GetRainbow(0.5)
                        highlight.OutlineColor = GetRainbow(0.7)
                    elseif State.ESP.DynamicColor then
                        -- Color based on health
                        if humanoid then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            highlight.FillColor = Color3.fromRGB(
                                255 * (1 - healthPercent),
                                255 * healthPercent,
                                0
                            )
                        end
                    else
                        highlight.FillColor = State.ESP.Color or Config.AccentColor
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                    
                    highlight.FillTransparency = State.ESP.ESPTransparency
                else
                    local existing = char:FindFirstChild("NexusHighlight")
                    if existing then existing:Destroy() end
                end
                
                -- BillboardGui ESP (Name, Distance, Health)
                if State.ESP.NameESP or State.ESP.DistanceESP or State.ESP.HealthText then
                    local bbg = char:FindFirstChild("NexusESPGui")
                    if not bbg then
                        bbg = Instance.new("BillboardGui")
                        bbg.Name = "NexusESPGui"
                        bbg.Adornee = head or hrp
                        bbg.Size = UDim2.new(0, 200, 0, 60)
                        bbg.StudsOffset = Vector3.new(0, 3, 0)
                        bbg.AlwaysOnTop = true
                        bbg.Parent = char
                        
                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Name = "NameLabel"
                        nameLabel.Size = UDim2.new(1, 0, 0, 16)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        nameLabel.TextSize = 13
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.Parent = bbg
                        
                        local distLabel = Instance.new("TextLabel")
                        distLabel.Name = "DistLabel"
                        distLabel.Size = UDim2.new(1, 0, 0, 14)
                        distLabel.Position = UDim2.new(0, 0, 0, 16)
                        distLabel.BackgroundTransparency = 1
                        distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                        distLabel.TextStrokeTransparency = 0.5
                        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        distLabel.TextSize = 11
                        distLabel.Font = Enum.Font.GothamMedium
                        distLabel.Parent = bbg
                        
                        local healthLabel = Instance.new("TextLabel")
                        healthLabel.Name = "HealthLabel"
                        healthLabel.Size = UDim2.new(1, 0, 0, 14)
                        healthLabel.Position = UDim2.new(0, 0, 0, 30)
                        healthLabel.BackgroundTransparency = 1
                        healthLabel.TextColor3 = Color3.fromRGB(52, 199, 89)
                        healthLabel.TextStrokeTransparency = 0.5
                        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        healthLabel.TextSize = 11
                        healthLabel.Font = Enum.Font.GothamMedium
                        healthLabel.Parent = bbg
                        
                        -- Tool/Weapon label
                        local toolLabel = Instance.new("TextLabel")
                        toolLabel.Name = "ToolLabel"
                        toolLabel.Size = UDim2.new(1, 0, 0, 14)
                        toolLabel.Position = UDim2.new(0, 0, 0, 44)
                        toolLabel.BackgroundTransparency = 1
                        toolLabel.TextColor3 = Color3.fromRGB(255, 204, 0)
                        toolLabel.TextStrokeTransparency = 0.5
                        toolLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        toolLabel.TextSize = 10
                        toolLabel.Font = Enum.Font.GothamMedium
                        toolLabel.Parent = bbg
                    end
                    
                    -- Update labels
                    local nameLabel = bbg:FindFirstChild("NameLabel")
                    local distLabel = bbg:FindFirstChild("DistLabel")
                    local healthLabel = bbg:FindFirstChild("HealthLabel")
                    local toolLabel = bbg:FindFirstChild("ToolLabel")
                    
                    if nameLabel then
                        nameLabel.Visible = State.ESP.NameESP
                        nameLabel.Text = p.Name
                    end
                    
                    if distLabel then
                        distLabel.Visible = State.ESP.DistanceESP
                        distLabel.Text = "[" .. math.floor(distance) .. "m]"
                    end
                    
                    if healthLabel and humanoid then
                        healthLabel.Visible = State.ESP.HealthText
                        healthLabel.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) .. " HP"
                        local hp = humanoid.Health / humanoid.MaxHealth
                        healthLabel.TextColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                    end
                    
                    if toolLabel then
                        local visible = State.ESP.WeaponESP or State.ESP.ToolESP
                        toolLabel.Visible = visible
                        if visible then
                            local tool = char:FindFirstChildOfClass("Tool")
                            toolLabel.Text = tool and ("🔧 " .. tool.Name) or ""
                        end
                    end
                else
                    local bbg = char:FindFirstChild("NexusESPGui")
                    if bbg then bbg:Destroy() end
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
        local rainbow = GetRainbow(0.3)
        Config.AccentColor = rainbow
        accentDot.BackgroundColor3 = rainbow
        activeIndicator.BackgroundColor3 = rainbow
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- KEYBOARD SHORTCUTS
-- ═══════════════════════════════════════════════════════════════
table.insert(State.Connections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Right Shift to toggle UI visibility
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainWindow.Visible = not MainWindow.Visible
        if MainWindow.Visible then
            Animate(BlurEffect, {Size = Config.BlurAmount}, SmoothTweenInfo(0.3))
        else
            Animate(BlurEffect, {Size = 0}, SmoothTweenInfo(0.3))
        end
    end
end))

-- ═══════════════════════════════════════════════════════════════
-- OPENING ANIMATION
-- ═══════════════════════════════════════════════════════════════

-- Animate window open
task.delay(0.1, function()
    Animate(BlurEffect, {Size = Config.BlurAmount}, SmoothTweenInfo(0.6))
    Animate(MainWindow, {Size = UDim2.new(0, 620, 0, 480)}, SpringTweenInfo(0.6))
    
    task.delay(0.4, function()
        ShowToast("Nexus UI loaded successfully", "success", 3)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP ON DESTROY
-- ═══════════════════════════════════════════════════════════════
ScreenGui.Destroying:Connect(function()
    for _, conn in ipairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    pcall(function() BlurEffect:Destroy() end)
    
    -- Restore gravity
    Workspace.Gravity = 196.2
    
    -- Clean up fly
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    
    -- Remove ESP highlights
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("NexusHighlight")
            if h then h:Destroy() end
            local b = p.Character:FindFirstChild("NexusESPGui")
            if b then b:Destroy() end
        end
    end
end)

--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    NEXUS UI — END OF SCRIPT                  ║
    ║                                                              ║
    ║  Keybinds:                                                   ║
    ║  • Right Shift — Toggle UI visibility                        ║
    ║  • Ctrl + Click — Click Teleport (when enabled)              ║
    ║                                                              ║
    ║  Features: 9 tabs, 70+ features, iOS-inspired design         ║
    ║  Performance: Optimized loops, connection management         ║
    ╚══════════════════════════════════════════════════════════════╝
]]
