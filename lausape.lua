--[[
    Hoshi Development Tools
    Production-Ready Admin Development Tools
    For internal map development, testing, debugging, and QA
]]

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    Version = "1.0.0",
    Name = "Hoshi Development Tools",
    ShortName = "HDT",
    
    Colors = {
        Background = Color3.fromRGB(18, 18, 24),
        Surface = Color3.fromRGB(24, 24, 32),
        SurfaceLight = Color3.fromRGB(32, 32, 42),
        SurfaceHover = Color3.fromRGB(38, 38, 50),
        Border = Color3.fromRGB(45, 45, 58),
        BorderLight = Color3.fromRGB(55, 55, 70),
        
        AccentPrimary = Color3.fromRGB(56, 145, 255),
        AccentSecondary = Color3.fromRGB(30, 110, 220),
        AccentGlow = Color3.fromRGB(56, 145, 255),
        AccentDim = Color3.fromRGB(35, 85, 155),
        
        TextPrimary = Color3.fromRGB(225, 228, 235),
        TextSecondary = Color3.fromRGB(145, 150, 165),
        TextDim = Color3.fromRGB(95, 100, 115),
        TextAccent = Color3.fromRGB(100, 175, 255),
        
        Success = Color3.fromRGB(45, 190, 120),
        Warning = Color3.fromRGB(230, 180, 50),
        Error = Color3.fromRGB(220, 65, 75),
        Info = Color3.fromRGB(56, 145, 255),
        
        Transparent = Color3.fromRGB(0, 0, 0),
    },
    
    Sizes = {
        WindowMinWidth = 750,
        WindowMinHeight = 480,
        WindowDefaultWidth = 880,
        WindowDefaultHeight = 540,
        SidebarWidth = 180,
        TitleBarHeight = 38,
        CornerRadius = UDim.new(0, 8),
        CornerRadiusSmall = UDim.new(0, 5),
        CornerRadiusLarge = UDim.new(0, 12),
        FloatingButtonSize = 44,
    },
    
    Animation = {
        SpeedMultiplier = 1,
        DefaultDuration = 0.25,
        FastDuration = 0.15,
        SlowDuration = 0.4,
        SplashDuration = 2.5,
    },
    
    ESP = {
        Enabled = false,
        BoxEnabled = true,
        NameEnabled = true,
        DistanceEnabled = true,
        HealthEnabled = true,
        RoleEnabled = true,
        RefreshRate = 0.1,
        MaxDistance = 2000,
    },
    
    TeleportSafety = {
        Enabled = false,
        DetectionRadius = 35,
        SafeDistance = 100,
        Cooldown = 3,
        RaycastHeight = 50,
    },
    
    Speed = {
        Current = 16,
        Min = 1,
        Max = 10,
        Multiplier = 16,
    },
    
    POVCircle = {
        Enabled = false,
        Radius = 120,
        Thickness = 2,
        Opacity = 0.6,
        Color = Color3.fromRGB(56, 145, 255),
    },
    
    Observation = {
        Enabled = false,
        Radius = 120,
        Transparency = 0.5,
        Color = Color3.fromRGB(255, 200, 50),
        SmoothFactor = 0.15,
    },
    
    Settings = {
        UIScale = 1,
        AnimationSpeed = 1,
        BlurEnabled = true,
    },
    
    Window = {
        Position = nil,
        Size = nil,
        Maximized = false,
        Minimized = false,
    },
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- UTILITIES
-- ============================================================
local Util = {}
local Connections = {}
local TweenCache = {}

function Util.AddConnection(conn)
    table.insert(Connections, conn)
    return conn
end

function Util.Tween(obj, props, duration, easingStyle, easingDir)
    if not obj then return end
    duration = (duration or Config.Animation.DefaultDuration) * Config.Animation.SpeedMultiplier
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDir = easingDir or Enum.EasingDirection.Out
    
    local key = tostring(obj) .. tostring(props)
    if TweenCache[key] then
        TweenCache[key]:Cancel()
    end
    
    local info = TweenInfo.new(duration, easingStyle, easingDir)
    local tween = TweenService:Create(obj, info, props)
    TweenCache[key] = tween
    tween:Play()
    return tween
end

function Util.Create(className, properties, children)
    local inst = Instance.new(className)
    if properties then
        for k, v in pairs(properties) do
            if k ~= "Parent" then
                pcall(function() inst[k] = v end)
            end
        end
        if properties.Parent then
            inst.Parent = properties.Parent
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

function Util.AddCorner(parent, radius)
    return Util.Create("UICorner", {
        CornerRadius = radius or Config.Sizes.CornerRadius,
        Parent = parent,
    })
end

function Util.AddStroke(parent, color, thickness, transparency)
    return Util.Create("UIStroke", {
        Color = color or Config.Colors.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

function Util.AddPadding(parent, top, right, bottom, left)
    return Util.Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 8),
        PaddingRight = UDim.new(0, right or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft = UDim.new(0, left or 8),
        Parent = parent,
    })
end

function Util.AddGradient(parent, c1, c2, rotation)
    return Util.Create("UIGradient", {
        Color = ColorSequence.new(c1 or Config.Colors.AccentPrimary, c2 or Config.Colors.AccentSecondary),
        Rotation = rotation or 45,
        Parent = parent,
    })
end

function Util.Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

function Util.GetScreenSize()
    return Camera.ViewportSize
end

function Util.GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function Util.GetHumanoid()
    local char = Util.GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Util.GetRootPart()
    local char = Util.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Util.FormatTime()
    return os.date("%H:%M:%S")
end

function Util.GetFPS()
    return math.floor(1 / RunService.RenderStepped:Wait())
end

function Util.GetPing()
    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return ping
end

function Util.Lerp(a, b, t)
    return a + (b - a) * t
end

function Util.RaycastDown(position)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = Util.GetCharacter()
    if char then
        params.FilterDescendantsInstances = {char}
    end
    local result = Workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -500, 0), params)
    return result
end

function Util.IsPositionSafe(position)
    local result = Util.RaycastDown(position)
    if not result then return false end
    if result.Position.Y < -50 then return false end
    
    local checkParams = RaycastParams.new()
    local char = Util.GetCharacter()
    if char then
        checkParams.FilterDescendantsInstances = {char}
    end
    checkParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local headCheck = Workspace:Raycast(result.Position + Vector3.new(0, 0.5, 0), Vector3.new(0, 6, 0), checkParams)
    if headCheck then return false end
    
    return true, result.Position + Vector3.new(0, 3, 0)
end

-- ============================================================
-- CLEANUP
-- ============================================================
local Cleanup = {}

function Cleanup.Run()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
    TweenCache = {}
    
    pcall(function()
        local existing = CoreGui:FindFirstChild("HoshiDevTools")
        if existing then existing:Destroy() end
    end)
    pcall(function()
        local existing = CoreGui:FindFirstChild("HoshiSplash")
        if existing then existing:Destroy() end
    end)
    pcall(function()
        local existing = CoreGui:FindFirstChild("HoshiFloat")
        if existing then existing:Destroy() end
    end)
    pcall(function()
        local existing = CoreGui:FindFirstChild("HoshiWatermark")
        if existing then existing:Destroy() end
    end)
    pcall(function()
        local existing = CoreGui:FindFirstChild("HoshiNotify")
        if existing then existing:Destroy() end
    end)
    pcall(function()
        local blur = Lighting:FindFirstChild("HoshiBlur")
        if blur then blur:Destroy() end
    end)
end

Cleanup.Run()

-- ============================================================
-- SCREEN GUI SETUP
-- ============================================================
local MainGui = Util.Create("ScreenGui", {
    Name = "HoshiDevTools",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 100,
    IgnoreGuiInset = true,
    Parent = CoreGui,
})

local FloatGui = Util.Create("ScreenGui", {
    Name = "HoshiFloat",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 99,
    IgnoreGuiInset = true,
    Parent = CoreGui,
})

local WatermarkGui = Util.Create("ScreenGui", {
    Name = "HoshiWatermark",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 98,
    IgnoreGuiInset = true,
    Parent = CoreGui,
})

local NotifyGui = Util.Create("ScreenGui", {
    Name = "HoshiNotify",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 101,
    IgnoreGuiInset = true,
    Parent = CoreGui,
})

local SplashGui = Util.Create("ScreenGui", {
    Name = "HoshiSplash",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 200,
    IgnoreGuiInset = true,
    Parent = CoreGui,
})

-- ============================================================
-- BLUR
-- ============================================================
local BlurEffect = Util.Create("BlurEffect", {
    Name = "HoshiBlur",
    Size = 0,
    Parent = Lighting,
})

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NotificationSystem = {}
local NotifyQueue = {}
local NotifyContainer

do
    NotifyContainer = Util.Create("Frame", {
        Name = "Container",
        Size = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -330, 0, 10),
        BackgroundTransparency = 1,
        Parent = NotifyGui,
    })
    
    Util.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotifyContainer,
    })
end

function NotificationSystem.Send(title, message, notifType, duration)
    notifType = notifType or "Info"
    duration = duration or 4
    
    local accentColor = Config.Colors.Info
    if notifType == "Success" then accentColor = Config.Colors.Success
    elseif notifType == "Warning" then accentColor = Config.Colors.Warning
    elseif notifType == "Error" then accentColor = Config.Colors.Error end
    
    local card = Util.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Config.Colors.Surface,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = NotifyContainer,
    })
    Util.AddCorner(card, Config.Sizes.CornerRadiusSmall)
    Util.AddStroke(card, Config.Colors.Border, 1, 1)
    
    local accentBar = Util.Create("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 1,
        Parent = card,
    })
    Util.AddCorner(accentBar, UDim.new(0, 2))
    
    local titleLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.new(0, 18, 0, 10),
        BackgroundTransparency = 1,
        Text = title or "Notification",
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        Parent = card,
    })
    
    local msgLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 14),
        Position = UDim2.new(0, 18, 0, 30),
        BackgroundTransparency = 1,
        Text = message or "",
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })
    
    local progressBg = Util.Create("Frame", {
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 1, -10),
        BackgroundColor3 = Config.Colors.SurfaceLight,
        BackgroundTransparency = 1,
        Parent = card,
    })
    Util.AddCorner(progressBg, UDim.new(0, 1))
    
    local progressFill = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 1,
        Parent = progressBg,
    })
    Util.AddCorner(progressFill, UDim.new(0, 1))
    
    -- Animate in
    card.Position = UDim2.new(1, 50, 0, 0)
    Util.Tween(card, {BackgroundTransparency = 0.08, Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart)
    
    local stroke = card:FindFirstChildOfClass("UIStroke")
    if stroke then Util.Tween(stroke, {Transparency = 0.6}, 0.3) end
    
    Util.Tween(accentBar, {BackgroundTransparency = 0}, 0.3)
    Util.Tween(titleLabel, {TextTransparency = 0}, 0.3)
    Util.Tween(msgLabel, {TextTransparency = 0}, 0.3)
    Util.Tween(progressBg, {BackgroundTransparency = 0.6}, 0.3)
    Util.Tween(progressFill, {BackgroundTransparency = 0.2}, 0.3)
    
    -- Progress countdown
    Util.Tween(progressFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    
    task.delay(duration, function()
        if card and card.Parent then
            Util.Tween(card, {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            Util.Tween(titleLabel, {TextTransparency = 1}, 0.2)
            Util.Tween(msgLabel, {TextTransparency = 1}, 0.2)
            Util.Tween(accentBar, {BackgroundTransparency = 1}, 0.2)
            if stroke then Util.Tween(stroke, {Transparency = 1}, 0.2) end
            task.delay(0.35, function()
                if card and card.Parent then
                    card:Destroy()
                end
            end)
        end
    end)
end

-- ============================================================
-- WATERMARK
-- ============================================================
local WatermarkModule = {}

do
    local wmFrame = Util.Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 420, 0, 26),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Config.Colors.Surface,
        BackgroundTransparency = 0.15,
        Parent = WatermarkGui,
    })
    Util.AddCorner(wmFrame, UDim.new(0, 4))
    Util.AddStroke(wmFrame, Config.Colors.Border, 1, 0.5)
    
    local wmLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = "Hoshi Development Tools | FPS: -- | Ping: -- | --:--:-- | Ready",
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wmFrame,
    })
    
    local lastFPSUpdate = 0
    local cachedFPS = 0
    
    Util.AddConnection(RunService.RenderStepped:Connect(function(dt)
        lastFPSUpdate = lastFPSUpdate + dt
        if lastFPSUpdate >= 0.5 then
            lastFPSUpdate = 0
            cachedFPS = math.floor(1 / dt)
            local ping = Util.GetPing()
            local time = Util.FormatTime()
            local status = "Active"
            wmLabel.Text = string.format(
                "Hoshi Development Tools | FPS: %d | Ping: %dms | %s | %s",
                cachedFPS, ping, time, status
            )
        end
    end))
end

-- ============================================================
-- SPLASH SCREEN
-- ============================================================
local SplashScreen = {}

function SplashScreen.Show(callback)
    local bg = Util.Create("Frame", {
        Name = "SplashBg",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 16),
        BackgroundTransparency = 1,
        Parent = SplashGui,
    })
    
    local centerFrame = Util.Create("Frame", {
        Name = "Center",
        Size = UDim2.new(0, 260, 0, 200),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = bg,
    })
    
    local logoFrame = Util.Create("Frame", {
        Name = "LogoBg",
        Size = UDim2.new(0, 70, 0, 70),
        Position = UDim2.new(0.5, 0, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 1,
        Parent = centerFrame,
    })
    Util.AddCorner(logoFrame, UDim.new(0, 16))
    
    local glowFrame = Util.Create("Frame", {
        Name = "Glow",
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 1,
        Parent = logoFrame,
    })
    Util.AddCorner(glowFrame, UDim.new(0, 20))
    
    local logoLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "H",
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 36,
        Font = Enum.Font.GothamBold,
        TextTransparency = 1,
        Parent = logoFrame,
    })
    
    local titleLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 105),
        BackgroundTransparency = 1,
        Text = "Hoshi Development Tools",
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextTransparency = 1,
        Parent = centerFrame,
    })
    
    local subLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 128),
        BackgroundTransparency = 1,
        Text = "v" .. Config.Version,
        TextColor3 = Config.Colors.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        Parent = centerFrame,
    })
    
    local progressBg = Util.Create("Frame", {
        Size = UDim2.new(0.7, 0, 0, 3),
        Position = UDim2.new(0.15, 0, 0, 160),
        BackgroundColor3 = Config.Colors.SurfaceLight,
        BackgroundTransparency = 1,
        Parent = centerFrame,
    })
    Util.AddCorner(progressBg, UDim.new(0, 2))
    
    local progressFill = Util.Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 1,
        Parent = progressBg,
    })
    Util.AddCorner(progressFill, UDim.new(0, 2))
    
    local loadText = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 172),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Config.Colors.TextDim,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        Parent = centerFrame,
    })
    
    -- Animate blur
    Util.Tween(BlurEffect, {Size = 24}, 0.5)
    
    -- Fade in background
    Util.Tween(bg, {BackgroundTransparency = 0.05}, 0.4)
    
    task.wait(0.15)
    
    -- Scale and fade logo
    logoFrame.Size = UDim2.new(0, 50, 0, 50)
    Util.Tween(logoFrame, {
        Size = UDim2.new(0, 70, 0, 70),
        BackgroundTransparency = 0.05
    }, 0.5, Enum.EasingStyle.Quint)
    Util.Tween(glowFrame, {BackgroundTransparency = 0.85}, 0.6, Enum.EasingStyle.Quint)
    Util.Tween(logoLabel, {TextTransparency = 0}, 0.4)
    
    task.wait(0.2)
    Util.Tween(titleLabel, {TextTransparency = 0}, 0.35)
    task.wait(0.1)
    Util.Tween(subLabel, {TextTransparency = 0}, 0.3)
    task.wait(0.1)
    
    -- Show progress
    Util.Tween(progressBg, {BackgroundTransparency = 0.5}, 0.3)
    Util.Tween(progressFill, {BackgroundTransparency = 0}, 0.3)
    Util.Tween(loadText, {TextTransparency = 0}, 0.3)
    
    -- Loading steps
    local loadingSteps = {
        {0.15, "Loading modules..."},
        {0.35, "Initializing UI framework..."},
        {0.55, "Building interface..."},
        {0.75, "Loading configurations..."},
        {0.90, "Finalizing..."},
        {1.00, "Ready"},
    }
    
    for i, step in ipairs(loadingSteps) do
        local dur = (Config.Animation.SplashDuration / #loadingSteps) * 0.7
        Util.Tween(progressFill, {Size = UDim2.new(step[1], 0, 1, 0)}, dur, Enum.EasingStyle.Quart)
        loadText.Text = step[2]
        task.wait(dur * 0.85)
    end
    
    task.wait(0.2)
    
    -- Glow pulse on complete
    Util.Tween(glowFrame, {BackgroundTransparency = 0.65}, 0.2)
    task.wait(0.15)
    Util.Tween(glowFrame, {BackgroundTransparency = 0.9}, 0.3)
    
    -- Fade out
    task.wait(0.15)
    Util.Tween(bg, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quart)
    Util.Tween(logoFrame, {BackgroundTransparency = 1}, 0.35)
    Util.Tween(glowFrame, {BackgroundTransparency = 1}, 0.35)
    Util.Tween(logoLabel, {TextTransparency = 1}, 0.3)
    Util.Tween(titleLabel, {TextTransparency = 1}, 0.3)
    Util.Tween(subLabel, {TextTransparency = 1}, 0.3)
    Util.Tween(progressBg, {BackgroundTransparency = 1}, 0.3)
    Util.Tween(progressFill, {BackgroundTransparency = 1}, 0.3)
    Util.Tween(loadText, {TextTransparency = 1}, 0.3)
    
    if not Config.Settings.BlurEnabled then
        Util.Tween(BlurEffect, {Size = 0}, 0.4)
    end
    
    task.wait(0.5)
    bg:Destroy()
    
    if callback then callback() end
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local Window = {}
local MainFrame, TitleBar, ContentFrame, SidebarFrame, PageContainer
local CurrentPage = "Dashboard"
local Pages = {}
local SidebarButtons = {}
local IsWindowOpen = false
local WindowState = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    Resizing = false,
    ResizeStart = nil,
    ResizeStartSize = nil,
}

function Window.Create()
    local screenSize = Util.GetScreenSize()
    local defaultW = Config.Sizes.WindowDefaultWidth
    local defaultH = Config.Sizes.WindowDefaultHeight
    
    MainFrame = Util.Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, defaultW, 0, defaultH),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Colors.Background,
        BackgroundTransparency = 0.02,
        ClipsDescendants = true,
        Visible = false,
        Parent = MainGui,
    })
    Util.AddCorner(MainFrame, Config.Sizes.CornerRadiusLarge)
    Util.AddStroke(MainFrame, Config.Colors.Border, 1, 0.3)
    
    -- Title Bar
    TitleBar = Util.Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, Config.Sizes.TitleBarHeight),
        BackgroundColor3 = Config.Colors.Surface,
        BackgroundTransparency = 0.3,
        Parent = MainFrame,
    })
    
    -- Title bar bottom line
    Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Config.Colors.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = TitleBar,
    })
    
    -- Logo in title bar
    local titleLogo = Util.Create("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 0.1,
        Parent = TitleBar,
    })
    Util.AddCorner(titleLogo, UDim.new(0, 5))
    
    Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "H",
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Parent = titleLogo,
    })
    
    Util.Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = "Hoshi Development Tools",
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar,
    })
    
    -- Window Controls
    local controlsFrame = Util.Create("Frame", {
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        BackgroundTransparency = 1,
        Parent = TitleBar,
    })
    
    local function CreateWindowButton(text, offset, color, onClick)
        local btn = Util.Create("TextButton", {
            Size = UDim2.new(0, 30, 0, 24),
            Position = UDim2.new(1, offset, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Config.Colors.SurfaceLight,
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Config.Colors.TextSecondary,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Parent = controlsFrame,
        })
        Util.AddCorner(btn, UDim.new(0, 4))
        
        btn.MouseEnter:Connect(function()
            Util.Tween(btn, {BackgroundTransparency = 0.3, TextColor3 = color or Config.Colors.TextPrimary}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Util.Tween(btn, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextSecondary}, 0.15)
        end)
        btn.MouseButton1Click:Connect(onClick)
        return btn
    end
    
    CreateWindowButton("_", -95, Config.Colors.TextPrimary, function()
        Window.Minimize()
    end)
    
    CreateWindowButton("+", -62, Config.Colors.TextPrimary, function()
        Window.ToggleMaximize()
    end)
    
    CreateWindowButton("x", -29, Config.Colors.Error, function()
        Window.Close()
    end)
    
    -- Drag functionality
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Config.Window.Maximized then return end
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
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
    
    Util.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            MainFrame.Position = newPos
        end
    end))
    
    -- Resize handle
    local resizeHandle = Util.Create("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        Text = "",
        Parent = MainFrame,
        ZIndex = 10,
    })
    
    local resizeDots = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "...",
        TextColor3 = Config.Colors.TextDim,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Rotation = -45,
        Parent = resizeHandle,
    })
    
    local resizing, resizeInput, resizeStart, resizeStartSize
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Config.Window.Maximized then return end
            resizing = true
            resizeStart = input.Position
            resizeStartSize = MainFrame.AbsoluteSize
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    resizeHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            resizeInput = input
        end
    end)
    
    Util.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input == resizeInput) then
            local delta = input.Position - resizeStart
            local newW = math.max(Config.Sizes.WindowMinWidth, resizeStartSize.X + delta.X)
            local newH = math.max(Config.Sizes.WindowMinHeight, resizeStartSize.Y + delta.Y)
            MainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end))
    
    -- Content area (below title bar)
    ContentFrame = Util.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -Config.Sizes.TitleBarHeight),
        Position = UDim2.new(0, 0, 0, Config.Sizes.TitleBarHeight),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })
    
    -- Sidebar
    SidebarFrame = Util.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, Config.Sizes.SidebarWidth, 1, 0),
        BackgroundColor3 = Config.Colors.Surface,
        BackgroundTransparency = 0.2,
        Parent = ContentFrame,
    })
    
    -- Sidebar right border
    Util.Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Config.Colors.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = SidebarFrame,
    })
    
    local sidebarList = Util.Create("Frame", {
        Name = "ButtonList",
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        Parent = SidebarFrame,
    })
    
    Util.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = sidebarList,
    })
    
    -- Page container
    PageContainer = Util.Create("ScrollingFrame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -Config.Sizes.SidebarWidth, 1, 0),
        Position = UDim2.new(0, Config.Sizes.SidebarWidth, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.Colors.AccentDim,
        ScrollBarImageTransparency = 0.3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = ContentFrame,
    })
    
    Util.AddPadding(PageContainer, 14, 14, 14, 14)
end

function Window.AddSidebarButton(name, layoutOrder)
    local btn = Util.Create("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 1,
        Text = "",
        LayoutOrder = layoutOrder or 0,
        Parent = SidebarFrame:FindFirstChild("ButtonList"),
    })
    Util.AddCorner(btn, UDim.new(0, 5))
    
    local label = Util.Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    
    local indicator = Util.Create("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 1,
        Parent = btn,
    })
    Util.AddCorner(indicator, UDim.new(0, 2))
    
    SidebarButtons[name] = {Button = btn, Label = label, Indicator = indicator}
    
    btn.MouseEnter:Connect(function()
        if CurrentPage ~= name then
            Util.Tween(btn, {BackgroundTransparency = 0.85}, 0.15)
            Util.Tween(label, {TextColor3 = Config.Colors.TextPrimary}, 0.15)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if CurrentPage ~= name then
            Util.Tween(btn, {BackgroundTransparency = 1}, 0.15)
            Util.Tween(label, {TextColor3 = Config.Colors.TextSecondary}, 0.15)
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        Window.SwitchPage(name)
    end)
    
    return btn
end

function Window.SwitchPage(name)
    if not Pages[name] then return end
    CurrentPage = name
    
    for pageName, frame in pairs(Pages) do
        frame.Visible = (pageName == name)
    end
    
    for btnName, data in pairs(SidebarButtons) do
        if btnName == name then
            Util.Tween(data.Button, {BackgroundTransparency = 0.8}, 0.2)
            Util.Tween(data.Label, {TextColor3 = Config.Colors.TextAccent}, 0.2)
            Util.Tween(data.Indicator, {BackgroundTransparency = 0}, 0.2)
        else
            Util.Tween(data.Button, {BackgroundTransparency = 1}, 0.2)
            Util.Tween(data.Label, {TextColor3 = Config.Colors.TextSecondary}, 0.2)
            Util.Tween(data.Indicator, {BackgroundTransparency = 1}, 0.2)
        end
    end
    
    PageContainer.CanvasPosition = Vector2.new(0, 0)
end

function Window.CreatePage(name)
    local page = Util.Create("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = PageContainer,
    })
    
    Util.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = page,
    })
    
    Pages[name] = page
    return page
end

function Window.Show()
    IsWindowOpen = true
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, Config.Sizes.WindowDefaultWidth - 40, 0, Config.Sizes.WindowDefaultHeight - 40)
    MainFrame.BackgroundTransparency = 1
    
    local stroke = MainFrame:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Transparency = 1 end
    
    Util.Tween(MainFrame, {
        Size = UDim2.new(0, Config.Sizes.WindowDefaultWidth, 0, Config.Sizes.WindowDefaultHeight),
        BackgroundTransparency = 0.02,
    }, 0.35, Enum.EasingStyle.Quint)
    
    if stroke then
        Util.Tween(stroke, {Transparency = 0.3}, 0.35)
    end
    
    if Config.Settings.BlurEnabled then
        Util.Tween(BlurEffect, {Size = 12}, 0.3)
    end
    
    FloatingButton.Hide()
end

function Window.Close()
    IsWindowOpen = false
    
    local stroke = MainFrame:FindFirstChildOfClass("UIStroke")
    
    Util.Tween(MainFrame, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, Config.Sizes.WindowDefaultWidth - 30, 0, Config.Sizes.WindowDefaultHeight - 30),
    }, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    
    if stroke then
        Util.Tween(stroke, {Transparency = 1}, 0.2)
    end
    
    Util.Tween(BlurEffect, {Size = 0}, 0.3)
    
    task.delay(0.28, function()
        if not IsWindowOpen then
            MainFrame.Visible = false
            Config.Window.Maximized = false
        end
    end)
    
    FloatingButton.Show()
end

function Window.Minimize()
    Window.Close()
end

function Window.ToggleMaximize()
    local screenSize = Util.GetScreenSize()
    if Config.Window.Maximized then
        Config.Window.Maximized = false
        Util.Tween(MainFrame, {
            Size = UDim2.new(0, Config.Sizes.WindowDefaultWidth, 0, Config.Sizes.WindowDefaultHeight),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, 0.3, Enum.EasingStyle.Quint)
    else
        Config.Window.Maximized = true
        Util.Tween(MainFrame, {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, 0.3, Enum.EasingStyle.Quint)
    end
end

-- ============================================================
-- UI COMPONENTS
-- ============================================================
local Components = {}

function Components.SectionTitle(parent, text, layoutOrder)
    local label = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    return label
end

function Components.Description(parent, text, layoutOrder)
    local label = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.Colors.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    return label
end

function Components.Card(parent, height, layoutOrder)
    local card = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 0),
        AutomaticSize = (height == nil) and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        BackgroundColor3 = Config.Colors.Surface,
        BackgroundTransparency = 0.15,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    Util.AddCorner(card, Config.Sizes.CornerRadius)
    Util.AddStroke(card, Config.Colors.Border, 1, 0.6)
    Util.AddPadding(card, 12, 12, 12, 12)
    
    Util.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = card,
    })
    
    return card
end

function Components.Toggle(parent, label, default, callback, layoutOrder)
    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    
    local textLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, -52, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local toggleBg = Util.Create("TextButton", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = default and Config.Colors.AccentPrimary or Config.Colors.SurfaceLight,
        Text = "",
        Parent = container,
    })
    Util.AddCorner(toggleBg, UDim.new(0, 10))
    
    local toggleCircle = Util.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = default and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Colors.TextPrimary,
        Parent = toggleBg,
    })
    Util.AddCorner(toggleCircle, UDim.new(0, 7))
    
    local state = default or false
    
    toggleBg.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Util.Tween(toggleBg, {BackgroundColor3 = Config.Colors.AccentPrimary}, 0.2)
            Util.Tween(toggleCircle, {Position = UDim2.new(1, -17, 0.5, 0)}, 0.2, Enum.EasingStyle.Quint)
        else
            Util.Tween(toggleBg, {BackgroundColor3 = Config.Colors.SurfaceLight}, 0.2)
            Util.Tween(toggleCircle, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.2, Enum.EasingStyle.Quint)
        end
        if callback then callback(state) end
    end)
    
    return container, function() return state end, function(v)
        state = v
        if state then
            Util.Tween(toggleBg, {BackgroundColor3 = Config.Colors.AccentPrimary}, 0.2)
            Util.Tween(toggleCircle, {Position = UDim2.new(1, -17, 0.5, 0)}, 0.2, Enum.EasingStyle.Quint)
        else
            Util.Tween(toggleBg, {BackgroundColor3 = Config.Colors.SurfaceLight}, 0.2)
            Util.Tween(toggleCircle, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.2, Enum.EasingStyle.Quint)
        end
    end
end

function Components.Slider(parent, label, min, max, default, callback, layoutOrder)
    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    
    local textLabel = Util.Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local valueBox = Util.Create("TextBox", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -50, 0, -2),
        BackgroundColor3 = Config.Colors.SurfaceLight,
        BackgroundTransparency = 0.3,
        Text = tostring(default or min),
        TextColor3 = Config.Colors.TextAccent,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false,
        Parent = container,
    })
    Util.AddCorner(valueBox, UDim.new(0, 4))
    
    local sliderBg = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = Config.Colors.SurfaceLight,
        Parent = container,
    })
    Util.AddCorner(sliderBg, UDim.new(0, 3))
    
    local normalizedDefault = ((default or min) - min) / (max - min)
    
    local sliderFill = Util.Create("Frame", {
        Size = UDim2.new(normalizedDefault, 0, 1, 0),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        Parent = sliderBg,
    })
    Util.AddCorner(sliderFill, UDim.new(0, 3))
    
    local sliderKnob = Util.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(normalizedDefault, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Colors.TextPrimary,
        ZIndex = 2,
        Parent = sliderBg,
    })
    Util.AddCorner(sliderKnob, UDim.new(0, 7))
    
    local sliding = false
    local currentValue = default or min
    
    local function UpdateSlider(inputX)
        local relX = inputX - sliderBg.AbsolutePosition.X
        local ratio = Util.Clamp(relX / sliderBg.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * ratio)
        
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderKnob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueBox.Text = tostring(currentValue)
        
        if callback then callback(currentValue) end
    end
    
    local sliderButton = Util.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
        Parent = container,
    })
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSlider(input.Position.X)
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    
    Util.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position.X)
        end
    end))
    
    Util.AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end))
    
    valueBox.FocusLost:Connect(function()
        local val = tonumber(valueBox.Text)
        if val then
            val = Util.Clamp(math.floor(val), min, max)
            currentValue = val
            local ratio = (val - min) / (max - min)
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            sliderKnob.Position = UDim2.new(ratio, 0, 0.5, 0)
            valueBox.Text = tostring(val)
            if callback then callback(val) end
        else
            valueBox.Text = tostring(currentValue)
        end
    end)
    
    return container, function() return currentValue end
end

function Components.Button(parent, text, callback, layoutOrder, isPrimary)
    local btn = Util.Create("TextButton", {
        Size = UDim2.new(0, 140, 0, 30),
        BackgroundColor3 = isPrimary and Config.Colors.AccentPrimary or Config.Colors.SurfaceLight,
        BackgroundTransparency = isPrimary and 0.1 or 0.3,
        Text = text,
        TextColor3 = isPrimary and Config.Colors.TextPrimary or Config.Colors.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    Util.AddCorner(btn, Config.Sizes.CornerRadiusSmall)
    
    btn.MouseEnter:Connect(function()
        Util.Tween(btn, {BackgroundTransparency = 0}, 0.15)
        Util.Tween(btn, {TextColor3 = Config.Colors.TextPrimary}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Util.Tween(btn, {BackgroundTransparency = isPrimary and 0.1 or 0.3}, 0.15)
        Util.Tween(btn, {TextColor3 = isPrimary and Config.Colors.TextPrimary or Config.Colors.TextSecondary}, 0.15)
    end)
    
    btn.MouseButton1Click:Connect(function()
        -- Ripple effect
        local ripple = Util.Create("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Config.Colors.TextPrimary,
            BackgroundTransparency = 0.7,
            Parent = btn,
        })
        Util.AddCorner(ripple, UDim.new(0.5, 0))
        
        Util.Tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quart)
        task.delay(0.4, function()
            if ripple and ripple.Parent then ripple:Destroy() end
        end)
        
        if callback then callback() end
    end)
    
    return btn
end

function Components.InfoRow(parent, label, defaultValue, layoutOrder)
    local row = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    
    Util.Create("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.Colors.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    
    local valueLabel = Util.Create("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = defaultValue or "--",
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    
    return row, valueLabel
end

function Components.Separator(parent, layoutOrder)
    return Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Config.Colors.Border,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
end

function Components.ColorInput(parent, label, default, callback, layoutOrder)
    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    
    Util.Create("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local colorPreview = Util.Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 20),
        Position = UDim2.new(1, -28, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = default or Config.Colors.AccentPrimary,
        Text = "",
        Parent = container,
    })
    Util.AddCorner(colorPreview, UDim.new(0, 4))
    Util.AddStroke(colorPreview, Config.Colors.BorderLight, 1, 0.3)
    
    return container
end

-- ============================================================
-- FLOATING BUTTON
-- ============================================================
FloatingButton = {}
local FloatBtn

do
    local size = Config.Sizes.FloatingButtonSize
    
    FloatBtn = Util.Create("TextButton", {
        Name = "FloatBtn",
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 0.05,
        Text = "",
        Visible = false,
        ZIndex = 50,
        Parent = FloatGui,
    })
    Util.AddCorner(FloatBtn, UDim.new(0, 12))
    Util.AddStroke(FloatBtn, Config.Colors.AccentGlow, 1, 0.5)
    
    local floatLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "H",
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        ZIndex = 51,
        Parent = FloatBtn,
    })
    
    -- Glow behind
    local floatGlow = Util.Create("Frame", {
        Size = UDim2.new(1, 12, 1, 12),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Colors.AccentPrimary,
        BackgroundTransparency = 0.85,
        ZIndex = 49,
        Parent = FloatBtn,
    })
    Util.AddCorner(floatGlow, UDim.new(0, 16))
    
    -- Idle pulse animation
    task.spawn(function()
        while true do
            if FloatBtn and FloatBtn.Parent and FloatBtn.Visible then
                Util.Tween(floatGlow, {BackgroundTransparency = 0.75, Size = UDim2.new(1, 18, 1, 18)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
                Util.Tween(floatGlow, {BackgroundTransparency = 0.9, Size = UDim2.new(1, 10, 1, 10)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(1.2)
            else
                task.wait(0.5)
            end
        end
    end)
    
    -- Hover
    FloatBtn.MouseEnter:Connect(function()
        Util.Tween(FloatBtn, {BackgroundTransparency = 0, Size = UDim2.new(0, size + 4, 0, size + 4)}, 0.2, Enum.EasingStyle.Quint)
    end)
    
    FloatBtn.MouseLeave:Connect(function()
        Util.Tween(FloatBtn, {BackgroundTransparency = 0.05, Size = UDim2.new(0, size, 0, size)}, 0.2, Enum.EasingStyle.Quint)
    end)
    
    -- Click to open
    FloatBtn.MouseButton1Click:Connect(function()
        -- Ripple
        local ripple = Util.Create("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Config.Colors.TextPrimary,
            BackgroundTransparency = 0.6,
            ZIndex = 52,
            Parent = FloatBtn,
        })
        Util.AddCorner(ripple, UDim.new(0.5, 0))
        Util.Tween(ripple, {Size = UDim2.new(3, 0, 3, 0), BackgroundTransparency = 1}, 0.5)
        task.delay(0.5, function()
            if ripple and ripple.Parent then ripple:Destroy() end
        end)
        
        Window.Show()
    end)
    
    -- Drag floating button
    local fbDragging, fbDragStart, fbStartPos
    
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fbDragging = true
            fbDragStart = input.Position
            fbStartPos = FloatBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fbDragging = false
                end
            end)
        end
    end)
    
    Util.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if fbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - fbDragStart
            local screenSize = Util.GetScreenSize()
            local newX = Util.Clamp(fbStartPos.X.Offset + delta.X, 0, screenSize.X - size)
            local newY = Util.Clamp(fbStartPos.Y.Offset + delta.Y, -screenSize.Y/2, screenSize.Y/2 - size)
            FloatBtn.Position = UDim2.new(0, newX, 0.5, newY)
        end
    end))
end

function FloatingButton.Show()
    FloatBtn.Visible = true
    FloatBtn.BackgroundTransparency = 1
    Util.Tween(FloatBtn, {BackgroundTransparency = 0.05}, 0.3, Enum.EasingStyle.Quart)
end

function FloatingButton.Hide()
    Util.Tween(FloatBtn, {BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Quart)
    task.delay(0.2, function()
        if IsWindowOpen then
            FloatBtn.Visible = false
        end
    end)
end

-- ============================================================
-- ESP MODULE
-- ============================================================
local ESPModule = {}
local ESPObjects = {}
local ESPConnection = nil

function ESPModule.CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    local espData = {}
    
    -- Drawing objects for ESP
    local highlight = Instance.new("Highlight")
    highlight.Name = "HoshiESP"
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0.3
    highlight.FillColor = Config.Colors.AccentPrimary
    highlight.OutlineColor = Config.Colors.AccentPrimary
    highlight.Enabled = false
    
    -- BillboardGui for info
    local billboard = Util.Create("BillboardGui", {
        Name = "HoshiESPInfo",
        Size = UDim2.new(0, 200, 0, 80),
        StudsOffset = Vector3.new(0, 3.5, 0),
        AlwaysOnTop = true,
        LightInfluence = 0,
    })
    
    local infoFrame = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = billboard,
    })
    
    local nameLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = player.Name,
        TextColor3 = Config.Colors.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.new(0, 0, 0),
        Parent = infoFrame,
    })
    
    local distLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "0m",
        TextColor3 = Config.Colors.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.new(0, 0, 0),
        Parent = infoFrame,
    })
    
    local healthBg = Util.Create("Frame", {
        Size = UDim2.new(0.6, 0, 0, 4),
        Position = UDim2.new(0.2, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = 0.3,
        Parent = infoFrame,
    })
    Util.AddCorner(healthBg, UDim.new(0, 2))
    
    local healthFill = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Success,
        Parent = healthBg,
    })
    Util.AddCorner(healthFill, UDim.new(0, 2))
    
    local roleLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Config.Colors.TextAccent,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.new(0, 0, 0),
        Parent = infoFrame,
    })
    
    espData.Highlight = highlight
    espData.Billboard = billboard
    espData.NameLabel = nameLabel
    espData.DistLabel = distLabel
    espData.HealthFill = healthFill
    espData.RoleLabel = roleLabel
    espData.Player = player
    
    ESPObjects[player] = espData
end

function ESPModule.UpdateESP()
    local myRoot = Util.GetRootPart()
    if not myRoot then return end
    
    for player, data in pairs(ESPObjects) do
        if not player or not player.Parent then
            ESPModule.RemoveESP(player)
            continue
        end
        
        local char = player.Character
        if not char then
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
            continue
        end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        
        if not humanoid or not rootPart or humanoid.Health <= 0 then
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
            continue
        end
        
        -- Attach if needed
        if data.Highlight.Parent ~= char then
            data.Highlight.Parent = char
        end
        if data.Billboard.Parent ~= (head or rootPart) then
            data.Billboard.Parent = head or rootPart
        end
        
        data.Highlight.Enabled = Config.ESP.BoxEnabled
        data.Billboard.Enabled = true
        
        -- Distance
        local dist = (myRoot.Position - rootPart.Position).Magnitude
        if Config.ESP.DistanceEnabled then
            data.DistLabel.Text = string.format("%.0fm", dist)
            data.DistLabel.Visible = true
        else
            data.DistLabel.Visible = false
        end
        
        -- Health
        if Config.ESP.HealthEnabled then
            local healthRatio = Util.Clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            data.HealthFill.Size = UDim2.new(healthRatio, 0, 1, 0)
            if healthRatio > 0.5 then
                data.HealthFill.BackgroundColor3 = Config.Colors.Success
            elseif healthRatio > 0.25 then
                data.HealthFill.BackgroundColor3 = Config.Colors.Warning
            else
                data.HealthFill.BackgroundColor3 = Config.Colors.Error
            end
        end
        
        -- Name
        data.NameLabel.Visible = Config.ESP.NameEnabled
        
        -- Role detection
        if Config.ESP.RoleEnabled then
            local role = "Unknown"
            local roleColor = Config.Colors.TextSecondary
            
            -- Try to detect role from common game systems
            pcall(function()
                local leaderstats = player:FindFirstChild("leaderstats")
                if leaderstats then
                    local roleVal = leaderstats:FindFirstChild("Role") or leaderstats:FindFirstChild("Team")
                    if roleVal then
                        role = tostring(roleVal.Value)
                    end
                end
            end)
            
            -- Check team
            if player.Team then
                role = player.Team.Name
                roleColor = player.TeamColor.Color
            end
            
            -- Check for Killer/Survivor tags
            pcall(function()
                if char:FindFirstChild("Killer") or player:FindFirstChild("IsKiller") then
                    role = "Killer"
                    roleColor = Config.Colors.Error
                    data.Highlight.OutlineColor = Config.Colors.Error
                    data.Highlight.FillColor = Color3.fromRGB(180, 40, 40)
                elseif char:FindFirstChild("Survivor") or player:FindFirstChild("IsSurvivor") then
                    role = "Survivor"
                    roleColor = Config.Colors.Success
                    data.Highlight.OutlineColor = Config.Colors.Success
                    data.Highlight.FillColor = Color3.fromRGB(40, 140, 80)
                end
            end)
            
            data.RoleLabel.Text = role
            data.RoleLabel.TextColor3 = roleColor
            data.RoleLabel.Visible = true
        else
            data.RoleLabel.Visible = false
        end
        
        -- Hide if too far
        if dist > Config.ESP.MaxDistance then
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
        end
    end
end

function ESPModule.RemoveESP(player)
    if ESPObjects[player] then
        pcall(function() ESPObjects[player].Highlight:Destroy() end)
        pcall(function() ESPObjects[player].Billboard:Destroy() end)
        ESPObjects[player] = nil
    end
end

function ESPModule.Enable()
    Config.ESP.Enabled = true
    
    -- Create ESP for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        ESPModule.CreateESP(player)
    end
    
    -- Listen for new players
    Util.AddConnection(Players.PlayerAdded:Connect(function(player)
        if Config.ESP.Enabled then
            ESPModule.CreateESP(player)
        end
    end))
    
    Util.AddConnection(Players.PlayerRemoving:Connect(function(player)
        ESPModule.RemoveESP(player)
    end))
    
    -- Update loop
    if not ESPConnection then
        local accumulator = 0
        ESPConnection = RunService.Heartbeat:Connect(function(dt)
            if not Config.ESP.Enabled then return end
            accumulator = accumulator + dt
            if accumulator >= Config.ESP.RefreshRate then
                accumulator = 0
                ESPModule.UpdateESP()
            end
        end)
        Util.AddConnection(ESPConnection)
    end
    
    NotificationSystem.Send("ESP", "Player ESP enabled", "Success")
end

function ESPModule.Disable()
    Config.ESP.Enabled = false
    for player, _ in pairs(ESPObjects) do
        ESPModule.RemoveESP(player)
    end
    ESPObjects = {}
    
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    
    NotificationSystem.Send("ESP", "Player ESP disabled", "Info")
end

-- ============================================================
-- TELEPORT SAFETY MODULE
-- ============================================================
local TeleportSafety = {}
local TeleportSafetyConnection = nil
local LastTeleportTime = 0

function TeleportSafety.FindKillers()
    local killers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if root and humanoid and humanoid.Health > 0 then
                    local isKiller = false
                    pcall(function()
                        if char:FindFirstChild("Killer") or player:FindFirstChild("IsKiller") then
                            isKiller = true
                        end
                        if player.Team and player.Team.Name:lower():find("killer") then
                            isKiller = true
                        end
                    end)
                    if isKiller then
                        table.insert(killers, root.Position)
                    end
                end
            end
        end
    end
    return killers
end

function TeleportSafety.FindSafePosition(killerPositions)
    local myRoot = Util.GetRootPart()
    if not myRoot then return nil end
    
    local bestPos = nil
    local bestDist = 0
    local attempts = 36
    
    for i = 1, attempts do
        local angle = (i / attempts) * math.pi * 2
        local distance = Config.TeleportSafety.SafeDistance + math.random(0, 50)
        local testPos = myRoot.Position + Vector3.new(
            math.cos(angle) * distance,
            0,
            math.sin(angle) * distance
        )
        
        local isSafe, safePos = Util.IsPositionSafe(testPos)
        if isSafe and safePos then
            local minDistToKiller = math.huge
            for _, kPos in ipairs(killerPositions) do
                local d = (safePos - kPos).Magnitude
                if d < minDistToKiller then
                    minDistToKiller = d
                end
            end
            
            if minDistToKiller > bestDist then
                bestDist = minDistToKiller
                bestPos = safePos
            end
        end
    end
    
    -- Fallback: try random positions
    if not bestPos then
        for _ = 1, 20 do
            local rndAngle = math.random() * math.pi * 2
            local rndDist = Config.TeleportSafety.SafeDistance + math.random(20, 100)
            local testPos = myRoot.Position + Vector3.new(
                math.cos(rndAngle) * rndDist,
                0,
                math.sin(rndAngle) * rndDist
            )
            local isSafe, safePos = Util.IsPositionSafe(testPos)
            if isSafe and safePos then
                bestPos = safePos
                break
            end
        end
    end
    
    return bestPos
end

function TeleportSafety.Enable()
    Config.TeleportSafety.Enabled = true
    
    if TeleportSafetyConnection then
        TeleportSafetyConnection:Disconnect()
    end
    
    TeleportSafetyConnection = RunService.Heartbeat:Connect(function()
        if not Config.TeleportSafety.Enabled then return end
        
        local now = tick()
        if now - LastTeleportTime < Config.TeleportSafety.Cooldown then return end
        
        local myRoot = Util.GetRootPart()
        if not myRoot then return end
        
        local killerPositions = TeleportSafety.FindKillers()
        if #killerPositions == 0 then return end
        
        for _, kPos in ipairs(killerPositions) do
            local dist = (myRoot.Position - kPos).Magnitude
            if dist <= Config.TeleportSafety.DetectionRadius then
                local safePos = TeleportSafety.FindSafePosition(killerPositions)
                if safePos then
                    myRoot.CFrame = CFrame.new(safePos)
                    LastTeleportTime = now
                    NotificationSystem.Send("Teleport Safety", string.format("Moved to safe position (%.0fm away)", (safePos - kPos).Magnitude), "Warning", 3)
                else
                    NotificationSystem.Send("Teleport Safety", "Could not find safe position", "Error", 3)
                end
                break
            end
        end
    end)
    Util.AddConnection(TeleportSafetyConnection)
    
    NotificationSystem.Send("Teleport Safety", "Safety teleport enabled", "Success")
end

function TeleportSafety.Disable()
    Config.TeleportSafety.Enabled = false
    if TeleportSafetyConnection then
        TeleportSafetyConnection:Disconnect()
        TeleportSafetyConnection = nil
    end
    NotificationSystem.Send("Teleport Safety", "Safety teleport disabled", "Info")
end

-- ============================================================
-- SPEED CONTROLLER MODULE
-- ============================================================
local SpeedController = {}

function SpeedController.SetSpeed(multiplier)
    Config.Speed.Current = multiplier
    local humanoid = Util.GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = multiplier * Config.Speed.Multiplier
    end
end

-- ============================================================
-- POV CIRCLE MODULE
-- ============================================================
local POVCircle = {}
local POVCircleFrame = nil
local POVCircleInner = nil

function POVCircle.Create()
    if POVCircleFrame then return end
    
    POVCircleFrame = Util.Create("Frame", {
        Name = "POVCircle",
        Size = UDim2.new(0, Config.POVCircle.Radius * 2, 0, Config.POVCircle.Radius * 2),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 5,
        Parent = MainGui,
    })
    
    -- Outer ring
    local ring = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = POVCircleFrame,
    })
    Util.AddCorner(ring, UDim.new(0.5, 0))
    
    local ringStroke = Util.Create("UIStroke", {
        Color = Config.POVCircle.Color,
        Thickness = Config.POVCircle.Thickness,
        Transparency = 1 - Config.POVCircle.Opacity,
        Parent = ring,
    })
    
    -- Center dot
    local centerDot = Util.Create("Frame", {
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.POVCircle.Color,
        BackgroundTransparency = 0.3,
        Parent = POVCircleFrame,
    })
    Util.AddCorner(centerDot, UDim.new(0.5, 0))
    
    -- Cross lines
    local lineH = Util.Create("Frame", {
        Size = UDim2.new(0, 12, 0, 1),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.POVCircle.Color,
        BackgroundTransparency = 0.4,
        Parent = POVCircleFrame,
    })
    
    local lineV = Util.Create("Frame", {
        Size = UDim2.new(0, 1, 0, 12),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.POVCircle.Color,
        BackgroundTransparency = 0.4,
        Parent = POVCircleFrame,
    })
    
    POVCircle.RingStroke = ringStroke
    POVCircle.CenterDot = centerDot
end

function POVCircle.Update()
    if not POVCircleFrame then return end
    local diameter = Config.POVCircle.Radius * 2
    POVCircleFrame.Size = UDim2.new(0, diameter, 0, diameter)
    
    if POVCircle.RingStroke then
        POVCircle.RingStroke.Color = Config.POVCircle.Color
        POVCircle.RingStroke.Thickness = Config.POVCircle.Thickness
        POVCircle.RingStroke.Transparency = 1 - Config.POVCircle.Opacity
    end
end

function POVCircle.Toggle(enabled)
    Config.POVCircle.Enabled = enabled
    if POVCircleFrame then
        POVCircleFrame.Visible = enabled
    end
end

-- ============================================================
-- OBSERVATION MODULE
-- ============================================================
local ObservationModule = {}
local ObservationMarkers = {}
local ObservationConnection = nil

function ObservationModule.Enable()
    Config.Observation.Enabled = true
    
    if ObservationConnection then
        ObservationConnection:Disconnect()
    end
    
    -- Create marker container
    local markerContainer = MainGui:FindFirstChild("ObservationMarkers")
    if not markerContainer then
        markerContainer = Util.Create("Frame", {
            Name = "ObservationMarkers",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex = 4,
            Parent = MainGui,
        })
    end
    
    ObservationConnection = RunService.RenderStepped:Connect(function()
        if not Config.Observation.Enabled then return end
        
        local cam = Workspace.CurrentCamera
        if not cam then return end
        
        local screenCenter = cam.ViewportSize / 2
        local observeRadius = Config.Observation.Radius
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local char = player.Character
            if not char then continue end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid or humanoid.Health <= 0 then
                if ObservationMarkers[player] then
                    ObservationMarkers[player].Visible = false
                end
                continue
            end
            
            local screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                local distFromCenter = (screenVec - screenCenter).Magnitude
                
                if distFromCenter <= observeRadius then
                    -- Inside POV circle - show marker
                    if not ObservationMarkers[player] then
                        local marker = Util.Create("Frame", {
                            Size = UDim2.new(0, 16, 0, 16),
                            BackgroundColor3 = Config.Observation.Color,
                            BackgroundTransparency = Config.Observation.Transparency,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            ZIndex = 6,
                            Parent = markerContainer,
                        })
                        Util.AddCorner(marker, UDim.new(0.5, 0))
                        Util.AddStroke(marker, Config.Observation.Color, 1, 0.3)
                        
                        local nameTag = Util.Create("TextLabel", {
                            Size = UDim2.new(0, 100, 0, 14),
                            Position = UDim2.new(0.5, 0, 0, -18),
                            AnchorPoint = Vector2.new(0.5, 0),
                            BackgroundTransparency = 1,
                            Text = player.Name,
                            TextColor3 = Config.Observation.Color,
                            TextSize = 10,
                            Font = Enum.Font.GothamBold,
                            TextStrokeTransparency = 0.5,
                            TextStrokeColor3 = Color3.new(0, 0, 0),
                            ZIndex = 7,
                            Parent = marker,
                        })
                        
                        ObservationMarkers[player] = marker
                    end
                    
                    local marker = ObservationMarkers[player]
                    marker.Visible = true
                    
                    -- Smooth follow
                    local targetPos = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                    local currentPos = marker.Position
                    local smooth = Config.Observation.SmoothFactor
                    
                    local lerpedX = Util.Lerp(currentPos.X.Offset, targetPos.X.Offset, smooth)
                    local lerpedY = Util.Lerp(currentPos.Y.Offset, targetPos.Y.Offset, smooth)
                    
                    marker.Position = UDim2.new(0, lerpedX, 0, lerpedY)
                else
                    if ObservationMarkers[player] then
                        ObservationMarkers[player].Visible = false
                    end
                end
            else
                if ObservationMarkers[player] then
                    ObservationMarkers[player].Visible = false
                end
            end
        end
    end)
    Util.AddConnection(ObservationConnection)
    
    NotificationSystem.Send("Observation", "Target observation enabled", "Success")
end

function ObservationModule.Disable()
    Config.Observation.Enabled = false
    
    if ObservationConnection then
        ObservationConnection:Disconnect()
        ObservationConnection = nil
    end
    
    for player, marker in pairs(ObservationMarkers) do
        pcall(function() marker:Destroy() end)
    end
    ObservationMarkers = {}
    
    NotificationSystem.Send("Observation", "Target observation disabled", "Info")
end

-- ============================================================
-- BUILD PAGES
-- ============================================================
local function BuildPages()
    -- ==================== DASHBOARD ====================
    local dashPage = Window.CreatePage("Dashboard")
    Window.AddSidebarButton("Dashboard", 1)
    
    Components.SectionTitle(dashPage, "Dashboard", 1)
    Components.Description(dashPage, "Hoshi Development Tools - Internal development and QA toolset", 2)
    
    Components.Separator(dashPage, 3)
    
    local infoCard = Components.Card(dashPage, nil, 4)
    Components.SectionTitle(infoCard, "System Information", 1)
    
    local _, playerVal = Components.InfoRow(infoCard, "Player", LocalPlayer.Name, 2)
    local _, gameVal = Components.InfoRow(infoCard, "Place ID", tostring(game.PlaceId), 3)
    local _, serverVal = Components.InfoRow(infoCard, "Server Job ID", string.sub(game.JobId, 1, 16) .. "...", 4)
    local _, playersVal = Components.InfoRow(infoCard, "Players", tostring(#Players:GetPlayers()), 5)
    
    -- Update player count
    Util.AddConnection(Players.PlayerAdded:Connect(function()
        playersVal.Text = tostring(#Players:GetPlayers())
    end))
    Util.AddConnection(Players.PlayerRemoving:Connect(function()
        task.wait(0.1)
        playersVal.Text = tostring(#Players:GetPlayers())
    end))
    
    local statusCard = Components.Card(dashPage, nil, 6)
    Components.SectionTitle(statusCard, "Module Status", 1)
    
    local _, espStatus = Components.InfoRow(statusCard, "ESP", "Disabled", 2)
    local _, tpStatus = Components.InfoRow(statusCard, "Teleport Safety", "Disabled", 3)
    local _, povStatus = Components.InfoRow(statusCard, "POV Circle", "Disabled", 4)
    local _, obsStatus = Components.InfoRow(statusCard, "Observation", "Disabled", 5)
    
    -- Status update loop
    task.spawn(function()
        while MainGui and MainGui.Parent do
            pcall(function()
                espStatus.Text = Config.ESP.Enabled and "Active" or "Disabled"
                espStatus.TextColor3 = Config.ESP.Enabled and Config.Colors.Success or Config.Colors.TextDim
                tpStatus.Text = Config.TeleportSafety.Enabled and "Active" or "Disabled"
                tpStatus.TextColor3 = Config.TeleportSafety.Enabled and Config.Colors.Success or Config.Colors.TextDim
                povStatus.Text = Config.POVCircle.Enabled and "Active" or "Disabled"
                povStatus.TextColor3 = Config.POVCircle.Enabled and Config.Colors.Success or Config.Colors.TextDim
                obsStatus.Text = Config.Observation.Enabled and "Active" or "Disabled"
                obsStatus.TextColor3 = Config.Observation.Enabled and Config.Colors.Success or Config.Colors.TextDim
            end)
            task.wait(1)
        end
    end)
    
    -- ==================== ESP PLAYER ====================
    local espPage = Window.CreatePage("ESP Player")
    Window.AddSidebarButton("ESP Player", 2)
    
    Components.SectionTitle(espPage, "ESP Player", 1)
    Components.Description(espPage, "Visual player tracking for development observation", 2)
    
    Components.Separator(espPage, 3)
    
    local espCard = Components.Card(espPage, nil, 4)
    
    Components.Toggle(espCard, "Enable ESP", false, function(state)
        if state then
            ESPModule.Enable()
        else
            ESPModule.Disable()
        end
    end, 1)
    
    Components.Separator(espCard, 2)
    
    Components.Toggle(espCard, "Box ESP", Config.ESP.BoxEnabled, function(state)
        Config.ESP.BoxEnabled = state
    end, 3)
    
    Components.Toggle(espCard, "Name ESP", Config.ESP.NameEnabled, function(state)
        Config.ESP.NameEnabled = state
    end, 4)
    
    Components.Toggle(espCard, "Distance", Config.ESP.DistanceEnabled, function(state)
        Config.ESP.DistanceEnabled = state
    end, 5)
    
    Components.Toggle(espCard, "Health Bar", Config.ESP.HealthEnabled, function(state)
        Config.ESP.HealthEnabled = state
    end, 6)
    
    Components.Toggle(espCard, "Role Display", Config.ESP.RoleEnabled, function(state)
        Config.ESP.RoleEnabled = state
    end, 7)
    
    Components.Separator(espCard, 8)
    
    Components.Slider(espCard, "Max Distance", 100, 2000, Config.ESP.MaxDistance, function(val)
        Config.ESP.MaxDistance = val
    end, 9)
    
    -- Player list
    local playerListCard = Components.Card(espPage, nil, 5)
    Components.SectionTitle(playerListCard, "Player List", 1)
    
    local function RefreshPlayerList()
        -- Remove old entries (keep title)
        for _, child in ipairs(playerListCard:GetChildren()) do
            if child:IsA("Frame") and child.Name == "PlayerEntry" then
                child:Destroy()
            end
        end
        
        for i, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local entry = Util.Create("Frame", {
                Name = "PlayerEntry",
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                LayoutOrder = 10 + i,
                Parent = playerListCard,
            })
            
            Util.Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = player.Name .. " [" .. player.UserId .. "]",
                TextColor3 = Config.Colors.TextSecondary,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = entry,
            })
        end
    end
    
    Components.Button(playerListCard, "Refresh List", RefreshPlayerList, 2)
    RefreshPlayerList()
    
    -- ==================== TELEPORT SAFETY ====================
    local tpPage = Window.CreatePage("Teleport Safety")
    Window.AddSidebarButton("Teleport Safety", 3)
    
    Components.SectionTitle(tpPage, "Teleport Safety", 1)
    Components.Description(tpPage, "Auto-teleport to safe position when Killer approaches", 2)
    
    Components.Separator(tpPage, 3)
    
    local tpCard = Components.Card(tpPage, nil, 4)
    
    local _, tpGetState, tpSetState = Components.Toggle(tpCard, "Enable Teleport Safety", false, function(state)
        if state then
            TeleportSafety.Enable()
        else
            TeleportSafety.Disable()
        end
    end, 1)
    
    Components.Separator(tpCard, 2)
    
    Components.Slider(tpCard, "Detection Radius (studs)", 10, 100, Config.TeleportSafety.DetectionRadius, function(val)
        Config.TeleportSafety.DetectionRadius = val
    end, 3)
    
    Components.Slider(tpCard, "Safe Distance (studs)", 50, 300, Config.TeleportSafety.SafeDistance, function(val)
        Config.TeleportSafety.SafeDistance = val
    end, 4)
    
    Components.Slider(tpCard, "Cooldown (seconds)", 1, 10, Config.TeleportSafety.Cooldown, function(val)
        Config.TeleportSafety.Cooldown = val
    end, 5)
    
    Components.Separator(tpCard, 6)
    
    local tpStatusCard = Components.Card(tpPage, nil, 5)
    Components.SectionTitle(tpStatusCard, "Safety Status", 1)
    local _, tpActiveStatus = Components.InfoRow(tpStatusCard, "Status", "Inactive", 2)
    local _, tpLastAction = Components.InfoRow(tpStatusCard, "Last Action", "None", 3)
    
    -- ==================== SPEED CONTROLLER ====================
    local speedPage = Window.CreatePage("Speed Controller")
    Window.AddSidebarButton("Speed Controller", 4)
    
    Components.SectionTitle(speedPage, "Speed Controller", 1)
    Components.Description(speedPage, "Adjust player movement speed for testing", 2)
    
    Components.Separator(speedPage, 3)
    
    local speedCard = Components.Card(speedPage, nil, 4)
    
    Components.Slider(speedCard, "Speed Multiplier", Config.Speed.Min, Config.Speed.Max, 1, function(val)
        SpeedController.SetSpeed(val)
    end, 1)
    
    Components.Separator(speedCard, 2)
    
    local _, speedVal = Components.InfoRow(speedCard, "Current WalkSpeed", "16", 3)
    
    -- Update speed display
    task.spawn(function()
        while MainGui and MainGui.Parent do
            pcall(function()
                local humanoid = Util.GetHumanoid()
                if humanoid then
                    speedVal.Text = tostring(math.floor(humanoid.WalkSpeed))
                end
            end)
            task.wait(0.5)
        end
    end)
    
    Components.Separator(speedCard, 4)
    
    local presetFrame = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = 5,
        Parent = speedCard,
    })
    
    Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        Parent = presetFrame,
    })
    
    local speedPresets = {1, 2, 3, 5, 8, 10}
    for _, preset in ipairs(speedPresets) do
        Components.Button(presetFrame, "x" .. preset, function()
            SpeedController.SetSpeed(preset)
            NotificationSystem.Send("Speed", "Speed set to x" .. preset, "Info", 2)
        end, preset)
    end
    
    -- ==================== POV CIRCLE ====================
    local povPage = Window.CreatePage("POV Circle")
    Window.AddSidebarButton("POV Circle", 5)
    
    Components.SectionTitle(povPage, "POV Circle", 1)
    Components.Description(povPage, "Screen-center observation circle for hitbox and collision testing", 2)
    
    Components.Separator(povPage, 3)
    
    local povCard = Components.Card(povPage, nil, 4)
    
    POVCircle.Create()
    
    Components.Toggle(povCard, "Enable POV Circle", false, function(state)
        POVCircle.Toggle(state)
    end, 1)
    
    Components.Separator(povCard, 2)
    
    Components.Slider(povCard, "Radius (px)", 30, 400, Config.POVCircle.Radius, function(val)
        Config.POVCircle.Radius = val
        POVCircle.Update()
    end, 3)
    
    Components.Slider(povCard, "Thickness (px)", 1, 6, Config.POVCircle.Thickness, function(val)
        Config.POVCircle.Thickness = val
        POVCircle.Update()
    end, 4)
    
    Components.Slider(povCard, "Opacity (%)", 10, 100, math.floor(Config.POVCircle.Opacity * 100), function(val)
        Config.POVCircle.Opacity = val / 100
        POVCircle.Update()
    end, 5)
    
    -- ==================== OBSERVATION ====================
    local obsPage = Window.CreatePage("Observation")
    Window.AddSidebarButton("Observation", 6)
    
    Components.SectionTitle(obsPage, "Observation Target", 1)
    Components.Description(obsPage, "Track targets within POV Circle area for hitbox and collision observation", 2)
    
    Components.Separator(obsPage, 3)
    
    local obsCard = Components.Card(obsPage, nil, 4)
    
    Components.Toggle(obsCard, "Enable Observation", false, function(state)
        if state then
            ObservationModule.Enable()
        else
            ObservationModule.Disable()
        end
    end, 1)
    
    Components.Separator(obsCard, 2)
    
    Components.Slider(obsCard, "Observation Radius (px)", 30, 400, Config.Observation.Radius, function(val)
        Config.Observation.Radius = val
    end, 3)
    
    Components.Slider(obsCard, "Marker Transparency (%)", 0, 90, math.floor(Config.Observation.Transparency * 100), function(val)
        Config.Observation.Transparency = val / 100
    end, 4)
    
    Components.Slider(obsCard, "Smooth Factor (%)", 5, 50, math.floor(Config.Observation.SmoothFactor * 100), function(val)
        Config.Observation.SmoothFactor = val / 100
    end, 5)
    
    Components.Separator(obsCard, 6)
    
    local obsInfoCard = Components.Card(obsPage, nil, 5)
    Components.SectionTitle(obsInfoCard, "Observation Info", 1)
    Components.Description(obsInfoCard, "Markers appear on targets inside the POV Circle area. Used for observing hitbox alignment, collision zones, and damage areas in real time.", 2)
    
    -- ==================== SETTINGS ====================
    local setPage = Window.CreatePage("Settings")
    Window.AddSidebarButton("Settings", 7)
    
    Components.SectionTitle(setPage, "Settings", 1)
    Components.Description(setPage, "Configure tool preferences", 2)
    
    Components.Separator(setPage, 3)
    
    local setCard = Components.Card(setPage, nil, 4)
    Components.SectionTitle(setCard, "Appearance", 1)
    
    Components.Slider(setCard, "UI Scale (%)", 70, 130, 100, function(val)
        Config.Settings.UIScale = val / 100
        -- Apply scale (simplified - affects main frame)
        if MainFrame then
            MainFrame.Size = UDim2.new(
                0, Config.Sizes.WindowDefaultWidth * (val / 100),
                0, Config.Sizes.WindowDefaultHeight * (val / 100)
            )
        end
    end, 2)
    
    Components.Slider(setCard, "Animation Speed (%)", 25, 200, 100, function(val)
        Config.Animation.SpeedMultiplier = val / 100
    end, 3)
    
    Components.Toggle(setCard, "Background Blur", Config.Settings.BlurEnabled, function(state)
        Config.Settings.BlurEnabled = state
        if not state then
            Util.Tween(BlurEffect, {Size = 0}, 0.3)
        elseif IsWindowOpen then
            Util.Tween(BlurEffect, {Size = 12}, 0.3)
        end
    end, 4)
    
    Components.Separator(setCard, 5)
    
    local resetCard = Components.Card(setPage, nil, 5)
    Components.SectionTitle(resetCard, "Reset", 1)
    Components.Description(resetCard, "Reset all settings to default values", 2)
    
    Components.Button(resetCard, "Reset Settings", function()
        -- Reset core values
        Config.Animation.SpeedMultiplier = 1
        Config.Settings.UIScale = 1
        Config.Settings.BlurEnabled = true
        
        if MainFrame then
            MainFrame.Size = UDim2.new(0, Config.Sizes.WindowDefaultWidth, 0, Config.Sizes.WindowDefaultHeight)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
        
        NotificationSystem.Send("Settings", "All settings reset to defaults", "Success")
    end, 3, true)
    
    -- Set default page
    Window.SwitchPage("Dashboard")
end

-- ============================================================
-- HUMANOID RECONNECTION
-- ============================================================
local function SetupCharacterReconnect()
    local function onCharacterAdded(char)
        task.wait(0.5)
        if Config.Speed.Current ~= 1 then
            SpeedController.SetSpeed(Config.Speed.Current)
        end
    end
    
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    Util.AddConnection(LocalPlayer.CharacterAdded:Connect(onCharacterAdded))
end

-- ============================================================
-- INITIALIZATION
-- ============================================================
local function Initialize()
    -- Build window
    Window.Create()
    
    -- Build all pages
    BuildPages()
    
    -- Setup character reconnection
    SetupCharacterReconnect()
    
    -- Show splash then open window
    SplashScreen.Show(function()
        Window.Show()
        NotificationSystem.Send("Hoshi Development Tools", "Tools initialized successfully", "Success", 4)
    end)
end

-- Run initialization
Initialize()

-- ============================================================
-- CLEANUP ON DESTROY
-- ============================================================
MainGui.Destroying:Connect(function()
    Cleanup.Run()
end)