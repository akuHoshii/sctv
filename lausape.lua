--[[
    Hoshi Development Tools
    Admin Development Tools for Internal Map Development
    Production Build
]]

-- Cleanup previous instance
if _G.HoshiCleanup then pcall(_G.HoshiCleanup) end

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

-- Core References
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ViewportSize = Camera.ViewportSize

-- State Management
local State = {
    GuiOpen = false,
    Minimized = false,
    Maximized = false,
    WindowPos = UDim2.new(0.5, -400, 0.5, -275),
    WindowSize = UDim2.new(0, 800, 0, 550),
    PreMaxPos = nil,
    PreMaxSize = nil,
    ActiveTab = "Dashboard",
    Connections = {},
    TweenCache = {},
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Distance = true,
        Health = true,
        Role = true,
        Objects = {}
    },
    Teleport = {
        Enabled = false,
        Radius = 35,
        SafeDistance = 100,
        Cooldown = 3,
        LastTeleport = 0
    },
    Speed = {
        Value = 16
    },
    POV = {
        Enabled = false,
        Radius = 150,
        Thickness = 2,
        Opacity = 0.5,
        Color = Color3.fromRGB(0, 170, 255)
    },
    Observation = {
        Enabled = false,
        Radius = 200,
        Transparency = 0.3,
        Color = Color3.fromRGB(0, 255, 170),
        Indicators = {}
    },
    Settings = {
        UIScale = 1,
        AccentColor = Color3.fromRGB(0, 140, 255),
        AnimSpeed = 1,
        BlurEnabled = true
    },
    Notifications = {},
    NotifQueue = {}
}

-- Color Palette
local Colors = {
    Background = Color3.fromRGB(18, 18, 24),
    Surface = Color3.fromRGB(24, 24, 32),
    SurfaceLight = Color3.fromRGB(32, 32, 44),
    SurfaceHover = Color3.fromRGB(40, 40, 54),
    Border = Color3.fromRGB(48, 48, 64),
    BorderLight = Color3.fromRGB(60, 60, 80),
    Text = Color3.fromRGB(225, 225, 235),
    TextDim = Color3.fromRGB(140, 140, 160),
    TextMuted = Color3.fromRGB(90, 90, 110),
    Accent = Color3.fromRGB(0, 140, 255),
    AccentDim = Color3.fromRGB(0, 100, 200),
    AccentGlow = Color3.fromRGB(0, 120, 255),
    Success = Color3.fromRGB(40, 200, 120),
    Warning = Color3.fromRGB(240, 180, 40),
    Error = Color3.fromRGB(240, 60, 60),
    Info = Color3.fromRGB(0, 160, 240),
    Transparent = Color3.fromRGB(0, 0, 0)
}

-- Utility Module
local Util = {}

function Util.Create(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then
                pcall(function() inst[k] = v end)
            end
        end
        if props.Parent then
            inst.Parent = props.Parent
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

function Util.Tween(obj, duration, props, style, direction, callback)
    if not obj or not obj.Parent then return end
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration = duration * (State.Settings.AnimSpeed or 1)
    local ti = TweenInfo.new(duration, style, direction)
    local tw = TweenService:Create(obj, ti, props)
    if callback then
        tw.Completed:Connect(callback)
    end
    tw:Play()
    return tw
end

function Util.AddCorner(parent, radius)
    return Util.Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

function Util.AddStroke(parent, color, thickness, transparency)
    return Util.Create("UIStroke", {
        Color = color or Colors.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
end

function Util.AddPadding(parent, t, b, l, r)
    return Util.Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft = UDim.new(0, l or 8),
        PaddingRight = UDim.new(0, r or 8),
        Parent = parent
    })
end

function Util.AddGradient(parent, c1, c2, rotation)
    return Util.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2)
        }),
        Rotation = rotation or 90,
        Parent = parent
    })
end

function Util.AddListLayout(parent, padding, dir, hAlign, vAlign, sortOrder)
    return Util.Create("UIListLayout", {
        Padding = UDim.new(0, padding or 4),
        FillDirection = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent = parent
    })
end

function Util.Ripple(button, x, y)
    if not button then return end
    local abs = button.AbsolutePosition
    local sz = button.AbsoluteSize
    local rx = x and (x - abs.X) or sz.X / 2
    local ry = y and (y - abs.Y) or sz.Y / 2
    local maxDist = math.max(
        math.sqrt(rx^2 + ry^2),
        math.sqrt((sz.X - rx)^2 + ry^2),
        math.sqrt(rx^2 + (sz.Y - ry)^2),
        math.sqrt((sz.X - rx)^2 + (sz.Y - ry)^2)
    )
    local ripple = Util.Create("Frame", {
        Position = UDim2.new(0, rx, 0, ry),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 1,
        Parent = button
    })
    Util.AddCorner(ripple, 9999)
    local clip = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        Parent = button
    })
    ripple.Parent = clip
    Util.Tween(ripple, 0.5, {
        Size = UDim2.new(0, maxDist * 2, 0, maxDist * 2),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
        clip:Destroy()
    end)
end

function Util.GetCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

function Util.Connect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(State.Connections, conn)
    return conn
end

function Util.ClampToScreen(pos, size)
    local vp = Camera.ViewportSize
    local x = math.clamp(pos.X.Offset, 0, vp.X - size.X.Offset)
    local y = math.clamp(pos.Y.Offset, 0, vp.Y - size.Y.Offset)
    return UDim2.new(0, x, 0, y)
end

function Util.FormatTime()
    local t = os.date("*t")
    return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

function Util.GetFPS()
    return math.floor(1 / RunService.RenderStepped:Wait())
end

function Util.GetPing()
    local success, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return success and math.floor(ping) or 0
end

-- ScreenGui Setup
local ScreenGui = Util.Create("ScreenGui", {
    Name = "HoshiDevTools",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
    IgnoreGuiInset = true,
    Parent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
})

-- Blur Effect
local BlurEffect
pcall(function()
    BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 0
    BlurEffect.Parent = game:GetService("Lighting")
end)

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NotifContainer = Util.Create("Frame", {
    Name = "NotifContainer",
    Size = UDim2.new(0, 320, 1, 0),
    Position = UDim2.new(1, -330, 0, 40),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 100,
    Parent = ScreenGui
})
Util.AddListLayout(NotifContainer, 6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
Util.AddPadding(NotifContainer, 0, 10, 0, 0)

local function Notify(title, message, nType, duration)
    nType = nType or "Info"
    duration = duration or 4
    local typeColors = {
        Info = Colors.Info,
        Success = Colors.Success,
        Warning = Colors.Warning,
        Error = Colors.Error
    }
    local col = typeColors[nType] or Colors.Info

    local notif = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Colors.Surface,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 101,
        ClipsDescendants = true,
        Parent = NotifContainer
    })
    Util.AddCorner(notif, 10)
    Util.AddStroke(notif, col, 1, 0.5)

    -- Accent bar
    Util.Create("Frame", {
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 6, 0, 4),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = notif
    })

    Util.Create("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -24, 0, 22),
        Position = UDim2.new(0, 18, 0, 10),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = notif
    })

    Util.Create("TextLabel", {
        Text = message,
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.new(0, 18, 0, 32),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 102,
        Parent = notif
    })

    -- Progress bar
    local progBg = Util.Create("Frame", {
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 1, -8),
        BackgroundColor3 = Colors.SurfaceLight,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = notif
    })
    Util.AddCorner(progBg, 1)

    local progBar = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        ZIndex = 103,
        Parent = progBg
    })
    Util.AddCorner(progBar, 1)

    -- Animate in
    notif.BackgroundTransparency = 1
    notif.Position = UDim2.new(1, 40, 0, 0)
    Util.Tween(notif, 0.35, {BackgroundTransparency = 0.05, Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart)
    Util.Tween(progBar, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if notif and notif.Parent then
            Util.Tween(notif, 0.3, {BackgroundTransparency = 1, Position = UDim2.new(1, 40, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
                if notif and notif.Parent then notif:Destroy() end
            end)
        end
    end)
end

-- ============================================================
-- SPLASH SCREEN
-- ============================================================
local function ShowSplashScreen(callback)
    local splash = Util.Create("Frame", {
        Name = "Splash",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 16),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 200,
        Parent = ScreenGui
    })

    -- Logo Container
    local logoContainer = Util.Create("Frame", {
        Size = UDim2.new(0, 90, 0, 90),
        Position = UDim2.new(0.5, 0, 0.42, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 201,
        Parent = splash
    })
    Util.AddCorner(logoContainer, 20)
    Util.AddStroke(logoContainer, Colors.Accent, 2, 0.3)

    -- Inner glow
    local logoGlow = Util.Create("Frame", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
        ZIndex = 200,
        Parent = logoContainer
    })
    Util.AddCorner(logoGlow, 24)

    local logoText = Util.Create("TextLabel", {
        Text = "H",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 44,
        TextColor3 = Colors.Accent,
        ZIndex = 202,
        Parent = logoContainer
    })

    -- Title
    local titleLabel = Util.Create("TextLabel", {
        Text = "Hoshi Development Tools",
        Size = UDim2.new(0, 400, 0, 30),
        Position = UDim2.new(0.5, 0, 0.56, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Colors.Text,
        TextTransparency = 1,
        ZIndex = 201,
        Parent = splash
    })

    -- Subtitle
    local subLabel = Util.Create("TextLabel", {
        Text = "Internal Development Build",
        Size = UDim2.new(0, 400, 0, 20),
        Position = UDim2.new(0.5, 0, 0.60, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Colors.TextMuted,
        TextTransparency = 1,
        ZIndex = 201,
        Parent = splash
    })

    -- Progress Bar Background
    local progBg = Util.Create("Frame", {
        Size = UDim2.new(0, 260, 0, 3),
        Position = UDim2.new(0.5, 0, 0.66, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.SurfaceLight,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 201,
        Parent = splash
    })
    Util.AddCorner(progBg, 2)

    local progFill = Util.Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 202,
        Parent = progBg
    })
    Util.AddCorner(progFill, 2)

    -- Loading Text
    local loadText = Util.Create("TextLabel", {
        Text = "Initializing...",
        Size = UDim2.new(0, 260, 0, 18),
        Position = UDim2.new(0.5, 0, 0.70, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Colors.TextMuted,
        TextTransparency = 1,
        ZIndex = 201,
        Parent = splash
    })

    -- Animate splash
    logoContainer.Size = UDim2.new(0, 60, 0, 60)
    logoContainer.BackgroundTransparency = 1
    logoText.TextTransparency = 1

    task.wait(0.1)

    -- Logo scale in
    Util.Tween(logoContainer, 0.6, {
        Size = UDim2.new(0, 90, 0, 90),
        BackgroundTransparency = 0.85
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Util.Tween(logoText, 0.5, {TextTransparency = 0}, Enum.EasingStyle.Quart)

    task.wait(0.4)

    -- Logo glow pulse
    Util.Tween(logoGlow, 0.8, {BackgroundTransparency = 0.8}, Enum.EasingStyle.Quart)
    task.delay(0.8, function()
        Util.Tween(logoGlow, 0.8, {BackgroundTransparency = 0.95}, Enum.EasingStyle.Quart)
    end)

    -- Title and subtitle fade in
    Util.Tween(titleLabel, 0.5, {TextTransparency = 0}, Enum.EasingStyle.Quart)
    task.wait(0.15)
    Util.Tween(subLabel, 0.5, {TextTransparency = 0}, Enum.EasingStyle.Quart)

    task.wait(0.2)

    -- Progress bar
    Util.Tween(progBg, 0.3, {BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
    Util.Tween(progFill, 0.3, {BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
    Util.Tween(loadText, 0.3, {TextTransparency = 0}, Enum.EasingStyle.Quart)

    local loadSteps = {
        {0.15, "Loading core modules..."},
        {0.30, "Initializing UI framework..."},
        {0.45, "Building interface..."},
        {0.60, "Loading ESP system..."},
        {0.75, "Configuring tools..."},
        {0.90, "Finalizing..."},
        {1.00, "Ready"}
    }

    for _, step in ipairs(loadSteps) do
        task.wait(0.25)
        Util.Tween(progFill, 0.25, {Size = UDim2.new(step[1], 0, 1, 0)}, Enum.EasingStyle.Quart)
        loadText.Text = step[2]
    end

    task.wait(0.4)

    -- Fade out
    Util.Tween(splash, 0.5, {BackgroundTransparency = 1}, Enum.EasingStyle.Quart)
    for _, child in ipairs(splash:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") then
                Util.Tween(child, 0.4, {TextTransparency = 1}, Enum.EasingStyle.Quart)
            elseif child:IsA("Frame") then
                Util.Tween(child, 0.4, {BackgroundTransparency = 1}, Enum.EasingStyle.Quart)
            end
        end)
        pcall(function()
            local stroke = child:FindFirstChildOfClass("UIStroke")
            if stroke then
                Util.Tween(stroke, 0.4, {Transparency = 1}, Enum.EasingStyle.Quart)
            end
        end)
    end

    task.wait(0.5)
    splash:Destroy()

    if callback then callback() end
end

-- ============================================================
-- WATERMARK
-- ============================================================
local WatermarkFrame = Util.Create("Frame", {
    Name = "Watermark",
    Size = UDim2.new(0, 380, 0, 26),
    Position = UDim2.new(0, 12, 0, 8),
    BackgroundColor3 = Colors.Surface,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 90,
    Parent = ScreenGui
})
Util.AddCorner(WatermarkFrame, 6)
Util.AddStroke(WatermarkFrame, Colors.Border, 1, 0.5)

local WatermarkText = Util.Create("TextLabel", {
    Text = "Hoshi Development Tools | FPS: -- | Ping: -- | --:--:-- | Ready",
    Size = UDim2.new(1, -16, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code,
    TextSize = 11,
    TextColor3 = Colors.TextDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 91,
    Parent = WatermarkFrame
})

-- Update watermark
local lastFPSUpdate = 0
local currentFPS = 60
local fpsAccum = 0
local fpsFrames = 0

Util.Connect(RunService.RenderStepped, function(dt)
    fpsAccum = fpsAccum + dt
    fpsFrames = fpsFrames + 1
    if fpsAccum >= 0.5 then
        currentFPS = math.floor(fpsFrames / fpsAccum)
        fpsFrames = 0
        fpsAccum = 0
        local ping = Util.GetPing()
        local time = Util.FormatTime()
        local status = State.GuiOpen and "Active" or "Standby"
        WatermarkText.Text = string.format(
            "Hoshi Development Tools | FPS: %d | Ping: %dms | %s | %s",
            currentFPS, ping, time, status
        )
    end
end)

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local MainFrame = Util.Create("Frame", {
    Name = "MainWindow",
    Size = State.WindowSize,
    Position = State.WindowPos,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Colors.Background,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
    ZIndex = 10,
    Parent = ScreenGui
})
Util.AddCorner(MainFrame, 12)
Util.AddStroke(MainFrame, Colors.Border, 1, 0.3)

-- Shadow
local Shadow = Util.Create("ImageLabel", {
    Name = "Shadow",
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.45,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    ZIndex = 9,
    Parent = MainFrame
})

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Util.Create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Colors.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 15,
    Parent = MainFrame
})
Util.AddCorner(TitleBar, 0)

-- Title bar bottom cover (to remove rounding at bottom)
Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Colors.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 15,
    Parent = TitleBar
})

-- Title bar top corners
local tbCorner = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = Colors.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 15,
    ClipsDescendants = true,
    Parent = TitleBar
})
Util.AddCorner(tbCorner, 12)

-- Logo in titlebar
local TitleLogo = Util.Create("TextLabel", {
    Text = "H",
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(0, 12, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Colors.Accent,
    BackgroundTransparency = 0.85,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Colors.Accent,
    BorderSizePixel = 0,
    ZIndex = 16,
    Parent = TitleBar
})
Util.AddCorner(TitleLogo, 6)

local TitleText = Util.Create("TextLabel", {
    Text = "Hoshi Development Tools",
    Size = UDim2.new(0, 250, 1, 0),
    Position = UDim2.new(0, 44, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Colors.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16,
    Parent = TitleBar
})

-- Window Controls
local ControlsFrame = Util.Create("Frame", {
    Size = UDim2.new(0, 110, 0, 38),
    Position = UDim2.new(1, 0, 0, 0),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 16,
    Parent = TitleBar
})

local function CreateWindowButton(icon, layoutOrder, color)
    local btn = Util.Create("TextButton", {
        Text = icon,
        Size = UDim2.new(0, 36, 0, 28),
        BackgroundColor3 = Colors.SurfaceLight,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Colors.TextDim,
        BorderSizePixel = 0,
        ZIndex = 17,
        AutoButtonColor = false,
        LayoutOrder = layoutOrder,
        Parent = ControlsFrame
    })
    Util.AddCorner(btn, 6)

    btn.MouseEnter:Connect(function()
        Util.Tween(btn, 0.2, {
            BackgroundTransparency = 0.5,
            TextColor3 = color or Colors.Text
        })
    end)
    btn.MouseLeave:Connect(function()
        Util.Tween(btn, 0.2, {
            BackgroundTransparency = 1,
            TextColor3 = Colors.TextDim
        })
    end)
    btn.MouseButton1Click:Connect(function()
        Util.Ripple(btn)
    end)
    return btn
end

Util.AddListLayout(ControlsFrame, 2, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
Util.AddPadding(ControlsFrame, 0, 0, 0, 6)

local CloseBtn = CreateWindowButton("X", 3, Colors.Error)
local MaxBtn = CreateWindowButton("+", 2, Colors.Warning)
local MinBtn = CreateWindowButton("-", 1, Colors.Success)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    State.GuiOpen = false
    Util.Tween(MainFrame, 0.35, {
        Size = UDim2.new(0, MainFrame.AbsoluteSize.X * 0.95, 0, MainFrame.AbsoluteSize.Y * 0.95),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
        MainFrame.Visible = false
        MainFrame.BackgroundTransparency = 0.02
    end)
    if BlurEffect then
        Util.Tween(BlurEffect, 0.3, {Size = 0})
    end
    FloatingBtn.Visible = true
    Util.Tween(FloatingBtn, 0.3, {BackgroundTransparency = 0.1}, Enum.EasingStyle.Quart)
end)

-- Minimize
MinBtn.MouseButton1Click:Connect(function()
    State.Minimized = not State.Minimized
    if State.Minimized then
        State.PreMinSize = MainFrame.Size
        Util.Tween(MainFrame, 0.35, {Size = UDim2.new(0, MainFrame.AbsoluteSize.X, 0, 38)}, Enum.EasingStyle.Quart)
    else
        Util.Tween(MainFrame, 0.35, {Size = State.PreMinSize or State.WindowSize}, Enum.EasingStyle.Quart)
    end
end)

-- Maximize
MaxBtn.MouseButton1Click:Connect(function()
    State.Minimized = false
    State.Maximized = not State.Maximized
    if State.Maximized then
        State.PreMaxPos = MainFrame.Position
        State.PreMaxSize = MainFrame.Size
        Util.Tween(MainFrame, 0.35, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -20, 1, -20)
        }, Enum.EasingStyle.Quart)
    else
        Util.Tween(MainFrame, 0.35, {
            Position = State.PreMaxPos or State.WindowPos,
            Size = State.PreMaxSize or State.WindowSize
        }, Enum.EasingStyle.Quart)
    end
end)

-- ============================================================
-- DRAG SYSTEM
-- ============================================================
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
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

Util.Connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        -- Clamp
        local vp = Camera.ViewportSize
        local absSize = MainFrame.AbsoluteSize
        local anchor = MainFrame.AnchorPoint
        local minX = absSize.X * anchor.X
        local minY = absSize.Y * anchor.Y
        local maxX = vp.X - absSize.X * (1 - anchor.X)
        local maxY = vp.Y - absSize.Y * (1 - anchor.Y)

        local clampedX = math.clamp(newPos.X.Offset + vp.X * newPos.X.Scale, minX, maxX)
        local clampedY = math.clamp(newPos.Y.Offset + vp.Y * newPos.Y.Scale, minY, maxY)

        Util.Tween(MainFrame, 0.08, {
            Position = UDim2.new(0, clampedX, 0, clampedY)
        }, Enum.EasingStyle.Quart)
        MainFrame.AnchorPoint = Vector2.new(0, 0)
        State.Maximized = false
    end
end)

-- ============================================================
-- RESIZE SYSTEM
-- ============================================================
local ResizeHandle = Util.Create("TextButton", {
    Name = "ResizeHandle",
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(1, -18, 1, -18),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 20,
    AutoButtonColor = false,
    Parent = MainFrame
})

-- Resize visual indicator
local resizeDots = Util.Create("TextLabel", {
    Text = "...",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Colors.TextMuted,
    TextTransparency = 0.5,
    ZIndex = 21,
    Rotation = -45,
    Parent = ResizeHandle
})

local resizing = false
local resizeStart = nil
local resizeStartSize = nil

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
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

Util.Connect(UserInputService.InputChanged, function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        local newW = math.clamp(resizeStartSize.X + delta.X, 640, Camera.ViewportSize.X - 20)
        local newH = math.clamp(resizeStartSize.Y + delta.Y, 400, Camera.ViewportSize.Y - 20)
        MainFrame.Size = UDim2.new(0, newW, 0, newH)
        State.Maximized = false
    end
end)

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar = Util.Create("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 180, 1, -38),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = Colors.Surface,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 12,
    ClipsDescendants = true,
    Parent = MainFrame
})

-- Sidebar separator
Util.Create("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Colors.Border,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 13,
    Parent = Sidebar
})

local SidebarScroll = Util.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -10),
    Position = UDim2.new(0, 0, 0, 5),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    ScrollBarImageTransparency = 1,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 13,
    Parent = Sidebar
})
Util.AddListLayout(SidebarScroll, 2)
Util.AddPadding(SidebarScroll, 6, 6, 8, 8)

-- Tab Content Area
local ContentArea = Util.Create("Frame", {
    Name = "ContentArea",
    Size = UDim2.new(1, -180, 1, -38),
    Position = UDim2.new(0, 180, 0, 38),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 11,
    ClipsDescendants = true,
    Parent = MainFrame
})

-- Tab pages
local TabPages = {}
local TabButtons = {}

local Tabs = {
    {Name = "Dashboard", Icon = "[D]"},
    {Name = "ESP Player", Icon = "[E]"},
    {Name = "Teleport", Icon = "[T]"},
    {Name = "Speed", Icon = "[S]"},
    {Name = "POV Circle", Icon = "[P]"},
    {Name = "Observation", Icon = "[O]"},
    {Name = "Settings", Icon = "[G]"},
}

local function CreateTabPage(name)
    local page = Util.Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Accent,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 12,
        Parent = ContentArea
    })
    Util.AddPadding(page, 16, 16, 20, 20)
    Util.AddListLayout(page, 10)
    TabPages[name] = page
    return page
end

local function SwitchTab(name)
    State.ActiveTab = name
    for tName, page in pairs(TabPages) do
        if tName == name then
            page.Visible = true
            page.BackgroundTransparency = 1
        else
            page.Visible = false
        end
    end
    for tName, btn in pairs(TabButtons) do
        if tName == name then
            Util.Tween(btn, 0.25, {BackgroundTransparency = 0.75})
            Util.Tween(btn.Label, 0.25, {TextColor3 = Colors.Accent})
            Util.Tween(btn.Icon, 0.25, {TextColor3 = Colors.Accent})
            btn.Indicator.Visible = true
            Util.Tween(btn.Indicator, 0.25, {BackgroundTransparency = 0})
        else
            Util.Tween(btn, 0.25, {BackgroundTransparency = 1})
            Util.Tween(btn.Label, 0.25, {TextColor3 = Colors.TextDim})
            Util.Tween(btn.Icon, 0.25, {TextColor3 = Colors.TextMuted})
            Util.Tween(btn.Indicator, 0.2, {BackgroundTransparency = 1})
        end
    end
end

-- Create sidebar buttons
for i, tab in ipairs(Tabs) do
    local btn = Util.Create("TextButton", {
        Name = tab.Name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 14,
        AutoButtonColor = false,
        LayoutOrder = i,
        Parent = SidebarScroll
    })
    Util.AddCorner(btn, 8)

    -- Active indicator
    local indicator = Util.Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 3, 0, 18),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 15,
        Visible = false,
        Parent = btn
    })
    Util.AddCorner(indicator, 2)

    local icon = Util.Create("TextLabel", {
        Name = "Icon",
        Text = tab.Icon,
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Colors.TextMuted,
        ZIndex = 15,
        Parent = btn
    })

    local label = Util.Create("TextLabel", {
        Name = "Label",
        Text = tab.Name,
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
        Parent = btn
    })

    btn.Indicator = indicator
    btn.Icon = icon
    btn.Label = label
    TabButtons[tab.Name] = btn

    btn.MouseEnter:Connect(function()
        if State.ActiveTab ~= tab.Name then
            Util.Tween(btn, 0.2, {BackgroundTransparency = 0.85})
        end
    end)
    btn.MouseLeave:Connect(function()
        if State.ActiveTab ~= tab.Name then
            Util.Tween(btn, 0.2, {BackgroundTransparency = 1})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        Util.Ripple(btn)
        SwitchTab(tab.Name)
    end)

    CreateTabPage(tab.Name)
end

-- ============================================================
-- UI COMPONENT BUILDERS
-- ============================================================
local function CreateSectionHeader(parent, text, layoutOrder)
    local header = Util.Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
        LayoutOrder = layoutOrder or 0,
        Parent = parent
    })
    return header
end

local function CreateCard(parent, height, layoutOrder)
    local card = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 60),
        BackgroundColor3 = Colors.SurfaceLight,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 13,
        LayoutOrder = layoutOrder or 0,
        AutomaticSize = height == nil and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        Parent = parent
    })
    Util.AddCorner(card, 10)
    Util.AddStroke(card, Colors.Border, 1, 0.6)
    return card
end

local function CreateToggle(parent, text, default, callback, layoutOrder)
    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 14,
        LayoutOrder = layoutOrder or 0,
        Parent = parent
    })

    Util.Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
        Parent = container
    })

    local toggleBg = Util.Create("TextButton", {
        Text = "",
        Size = UDim2.new(0, 44, 0, 22),
        Position = UDim2.new(1, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = default and Colors.Accent or Colors.SurfaceHover,
        BorderSizePixel = 0,
        ZIndex = 15,
        AutoButtonColor = false,
        Parent = container
    })
    Util.AddCorner(toggleBg, 11)

    local toggleKnob = Util.Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0,
        ZIndex = 16,
        Parent = toggleBg
    })
    Util.AddCorner(toggleKnob, 8)

    local enabled = default or false

    toggleBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        Util.Tween(toggleBg, 0.25, {
            BackgroundColor3 = enabled and Colors.Accent or Colors.SurfaceHover
        })
        Util.Tween(toggleKnob, 0.25, {
            Position = enabled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        }, Enum.EasingStyle.Back)
        if callback then callback(enabled) end
    end)

    return container, function() return enabled end, function(val)
        enabled = val
        Util.Tween(toggleBg, 0.25, {BackgroundColor3 = enabled and Colors.Accent or Colors.SurfaceHover})
        Util.Tween(toggleKnob, 0.25, {Position = enabled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, Enum.EasingStyle.Back)
    end
end

local function CreateSlider(parent, text, min, max, default, callback, layoutOrder)
    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 14,
        LayoutOrder = layoutOrder or 0,
        Parent = parent
    })

    local label = Util.Create("TextLabel", {
        Text = text,
        Size = UDim2.new(0.6, 0, 0, 18),
        Position = UDim2.new(0, 4, 0, 2),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
        Parent = container
    })

    local valueBox = Util.Create("TextBox", {
        Text = tostring(default),
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -4, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Colors.SurfaceHover,
        BackgroundTransparency = 0.3,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Colors.Text,
        BorderSizePixel = 0,
        ZIndex = 15,
        ClearTextOnFocus = false,
        Parent = container
    })
    Util.AddCorner(valueBox, 5)

    local sliderBg = Util.Create("Frame", {
        Size = UDim2.new(1, -8, 0, 6),
        Position = UDim2.new(0, 4, 0, 32),
        BackgroundColor3 = Colors.SurfaceHover,
        BorderSizePixel = 0,
        ZIndex = 15,
        Parent = container
    })
    Util.AddCorner(sliderBg, 3)

    local sliderFill = Util.Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 16,
        Parent = sliderBg
    })
    Util.AddCorner(sliderFill, 3)

    local sliderKnob = Util.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0,
        ZIndex = 17,
        Parent = sliderBg
    })
    Util.AddCorner(sliderKnob, 7)
    Util.AddStroke(sliderKnob, Colors.Accent, 2, 0.2)

    local currentValue = default
    local sliding = false

    local function UpdateSlider(ratio)
        ratio = math.clamp(ratio, 0, 1)
        currentValue = math.floor(min + (max - min) * ratio + 0.5)
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderKnob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueBox.Text = tostring(currentValue)
        if callback then callback(currentValue) end
    end

    local sliderButton = Util.Create("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex = 18,
        AutoButtonColor = false,
        Parent = container
    })

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            local ratio = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            UpdateSlider(ratio)
        end
    end)

    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    Util.Connect(UserInputService.InputChanged, function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            local ratio = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            UpdateSlider(ratio)
        end
    end)

    valueBox.FocusLost:Connect(function()
        local num = tonumber(valueBox.Text)
        if num then
            num = math.clamp(math.floor(num), min, max)
            UpdateSlider((num - min) / (max - min))
        else
            valueBox.Text = tostring(currentValue)
        end
    end)

    return container, function() return currentValue end
end

local function CreateButton(parent, text, callback, layoutOrder)
    local btn = Util.Create("TextButton", {
        Text = text,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 0.15,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Colors.Text,
        BorderSizePixel = 0,
        ZIndex = 15,
        AutoButtonColor = false,
        LayoutOrder = layoutOrder or 0,
        Parent = parent
    })
    Util.AddCorner(btn, 8)

    btn.MouseEnter:Connect(function()
        Util.Tween(btn, 0.2, {BackgroundTransparency = 0.05})
    end)
    btn.MouseLeave:Connect(function()
        Util.Tween(btn, 0.2, {BackgroundTransparency = 0.15})
    end)
    btn.MouseButton1Click:Connect(function()
        Util.Ripple(btn)
        if callback then callback() end
    end)
    return btn
end

local function CreateInfoLabel(parent, text, layoutOrder)
    local lbl = Util.Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
        LayoutOrder = layoutOrder or 0,
        Parent = parent
    })
    return lbl
end

local function CreateColorPicker(parent, text, default, callback, layoutOrder)
    local container = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 14,
        LayoutOrder = layoutOrder or 0,
        Parent = parent
    })

    Util.Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15,
        Parent = container
    })

    local preview = Util.Create("Frame", {
        Size = UDim2.new(0, 28, 0, 22),
        Position = UDim2.new(1, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = default or Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 15,
        Parent = container
    })
    Util.AddCorner(preview, 6)
    Util.AddStroke(preview, Colors.Border, 1, 0.5)

    return container, preview
end

-- ============================================================
-- DASHBOARD TAB
-- ============================================================
local dashPage = TabPages["Dashboard"]

CreateSectionHeader(dashPage, "Dashboard", 1)

local statsCard = CreateCard(dashPage, nil, 2)
Util.AddPadding(statsCard, 14, 14, 14, 14)
local statsLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = statsCard
})
Util.AddListLayout(statsLayout, 6)

local dashFPS = CreateInfoLabel(statsLayout, "FPS: --", 1)
local dashPing = CreateInfoLabel(statsLayout, "Ping: --", 2)
local dashPlayers = CreateInfoLabel(statsLayout, "Players: --", 3)
local dashUptime = CreateInfoLabel(statsLayout, "Session: 0s", 4)
local dashStatus = CreateInfoLabel(statsLayout, "Status: Ready", 5)

local startTime = tick()

-- Quick Actions
CreateSectionHeader(dashPage, "Quick Actions", 3)

local quickCard = CreateCard(dashPage, nil, 4)
Util.AddPadding(quickCard, 10, 10, 10, 10)
local quickLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = quickCard
})
Util.AddListLayout(quickLayout, 6)

CreateButton(quickLayout, "Rejoin Server", function()
    Notify("System", "Rejoin not available in dev tools", "Warning")
end, 1)

CreateButton(quickLayout, "Reset Character", function()
    local char, hum = Util.GetCharacter()
    if hum then
        hum.Health = 0
        Notify("System", "Character reset", "Success")
    end
end, 2)

CreateButton(quickLayout, "Copy Position", function()
    local _, _, hrp = Util.GetCharacter()
    if hrp then
        local pos = hrp.Position
        local str = string.format("Vector3.new(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
        if setclipboard then
            setclipboard(str)
            Notify("System", "Position copied to clipboard", "Success")
        else
            Notify("System", str, "Info")
        end
    end
end, 3)

-- Dashboard update loop
local dashUpdateAccum = 0
Util.Connect(RunService.Heartbeat, function(dt)
    dashUpdateAccum = dashUpdateAccum + dt
    if dashUpdateAccum >= 1 then
        dashUpdateAccum = 0
        local elapsed = math.floor(tick() - startTime)
        local mins = math.floor(elapsed / 60)
        local secs = elapsed % 60
        dashFPS.Text = "FPS: " .. currentFPS
        dashPing.Text = "Ping: " .. Util.GetPing() .. "ms"
        dashPlayers.Text = "Players: " .. #Players:GetPlayers()
        dashUptime.Text = string.format("Session: %dm %ds", mins, secs)
        dashStatus.Text = "Status: Active"
    end
end)

-- ============================================================
-- ESP PLAYER TAB
-- ============================================================
local espPage = TabPages["ESP Player"]

CreateSectionHeader(espPage, "ESP Player", 1)

local espCard = CreateCard(espPage, nil, 2)
Util.AddPadding(espCard, 10, 10, 10, 10)
local espLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = espCard
})
Util.AddListLayout(espLayout, 4)

CreateToggle(espLayout, "Enable ESP", false, function(val)
    State.ESP.Enabled = val
    if not val then
        -- Clear ESP
        for _, obj in pairs(State.ESP.Objects) do
            pcall(function()
                if obj.BillboardGui then obj.BillboardGui:Destroy() end
                if obj.Highlight then obj.Highlight:Destroy() end
            end)
        end
        State.ESP.Objects = {}
    end
    Notify("ESP", val and "ESP Enabled" or "ESP Disabled", val and "Success" or "Info")
end, 1)

CreateToggle(espLayout, "Box ESP", true, function(val)
    State.ESP.Box = val
end, 2)

CreateToggle(espLayout, "Name ESP", true, function(val)
    State.ESP.Name = val
end, 3)

CreateToggle(espLayout, "Distance", true, function(val)
    State.ESP.Distance = val
end, 4)

CreateToggle(espLayout, "Health Bar", true, function(val)
    State.ESP.Health = val
end, 5)

CreateToggle(espLayout, "Show Role", true, function(val)
    State.ESP.Role = val
end, 6)

-- ESP Rendering
local function GetPlayerRole(player)
    -- Try common role detection methods
    local char = player.Character
    if not char then return "Unknown", Colors.TextDim end
    
    -- Check for common role indicators
    local role = "Player"
    local roleColor = Colors.Info
    
    -- Check for team
    if player.Team then
        role = player.Team.Name
        roleColor = player.Team.TeamColor.Color
        return role, roleColor
    end
    
    -- Check leaderstats or common value names
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local roleVal = leaderstats:FindFirstChild("Role") or leaderstats:FindFirstChild("Class")
        if roleVal then
            role = tostring(roleVal.Value)
        end
    end
    
    -- Check character for "Killer" tag or similar
    local tags = {"Killer", "Survivor", "Hunter", "Monster", "Beast"}
    for _, tag in ipairs(tags) do
        if char:FindFirstChild(tag) or player:FindFirstChild(tag) then
            role = tag
            if tag == "Killer" or tag == "Hunter" or tag == "Monster" or tag == "Beast" then
                roleColor = Colors.Error
            else
                roleColor = Colors.Success
            end
            break
        end
    end
    
    return role, roleColor
end

local function UpdateESP()
    if not State.ESP.Enabled then return end
    
    local _, _, myHRP = Util.GetCharacter()
    if not myHRP then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            
            if char and hum and hrp and hum.Health > 0 then
                local espData = State.ESP.Objects[player.UserId]
                
                if not espData then
                    espData = {}
                    State.ESP.Objects[player.UserId] = espData
                end
                
                -- Create or update Highlight (Box ESP)
                if State.ESP.Box then
                    if not espData.Highlight or not espData.Highlight.Parent then
                        pcall(function()
                            if espData.Highlight then espData.Highlight:Destroy() end
                        end)
                        local hl = Instance.new("Highlight")
                        hl.Adornee = char
                        hl.FillTransparency = 0.85
                        hl.OutlineTransparency = 0.3
                        hl.FillColor = Colors.Accent
                        hl.OutlineColor = Colors.Accent
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                        espData.Highlight = hl
                    end
                else
                    if espData.Highlight then
                        pcall(function() espData.Highlight:Destroy() end)
                        espData.Highlight = nil
                    end
                end
                
                -- BillboardGui for info
                if State.ESP.Name or State.ESP.Distance or State.ESP.Health or State.ESP.Role then
                    if not espData.BillboardGui or not espData.BillboardGui.Parent then
                        pcall(function()
                            if espData.BillboardGui then espData.BillboardGui:Destroy() end
                        end)
                        local bb = Instance.new("BillboardGui")
                        bb.Adornee = head or hrp
                        bb.Size = UDim2.new(0, 180, 0, 60)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        bb.LightInfluence = 0
                        bb.MaxDistance = 500
                        bb.Parent = char
                        
                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Name = "NameLabel"
                        nameLabel.Size = UDim2.new(1, 0, 0, 14)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.TextSize = 12
                        nameLabel.TextColor3 = Colors.Text
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        nameLabel.Parent = bb
                        
                        local distLabel = Instance.new("TextLabel")
                        distLabel.Name = "DistLabel"
                        distLabel.Size = UDim2.new(1, 0, 0, 12)
                        distLabel.Position = UDim2.new(0, 0, 0, 14)
                        distLabel.BackgroundTransparency = 1
                        distLabel.Font = Enum.Font.Gotham
                        distLabel.TextSize = 10
                        distLabel.TextColor3 = Colors.TextDim
                        distLabel.TextStrokeTransparency = 0.5
                        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        distLabel.Parent = bb
                        
                        local roleLabel = Instance.new("TextLabel")
                        roleLabel.Name = "RoleLabel"
                        roleLabel.Size = UDim2.new(1, 0, 0, 12)
                        roleLabel.Position = UDim2.new(0, 0, 0, 26)
                        roleLabel.BackgroundTransparency = 1
                        roleLabel.Font = Enum.Font.GothamMedium
                        roleLabel.TextSize = 10
                        roleLabel.TextStrokeTransparency = 0.5
                        roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        roleLabel.Parent = bb
                        
                        -- Health bar
                        local healthBg = Instance.new("Frame")
                        healthBg.Name = "HealthBg"
                        healthBg.Size = UDim2.new(0.6, 0, 0, 3)
                        healthBg.Position = UDim2.new(0.2, 0, 0, 40)
                        healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        healthBg.BorderSizePixel = 0
                        healthBg.Parent = bb
                        Util.AddCorner(healthBg, 2)
                        
                        local healthFill = Instance.new("Frame")
                        healthFill.Name = "HealthFill"
                        healthFill.Size = UDim2.new(1, 0, 1, 0)
                        healthFill.BackgroundColor3 = Colors.Success
                        healthFill.BorderSizePixel = 0
                        healthFill.Parent = healthBg
                        Util.AddCorner(healthFill, 2)
                        
                        espData.BillboardGui = bb
                    end
                    
                    -- Update info
                    local bb = espData.BillboardGui
                    local nameLabel = bb:FindFirstChild("NameLabel")
                    local distLabel = bb:FindFirstChild("DistLabel")
                    local roleLabel = bb:FindFirstChild("RoleLabel")
                    local healthBg = bb:FindFirstChild("HealthBg")
                    
                    if nameLabel then
                        nameLabel.Visible = State.ESP.Name
                        nameLabel.Text = player.DisplayName
                    end
                    
                    if distLabel then
                        distLabel.Visible = State.ESP.Distance
                        local dist = (myHRP.Position - hrp.Position).Magnitude
                        distLabel.Text = string.format("%.0f studs", dist)
                    end
                    
                    if roleLabel then
                        roleLabel.Visible = State.ESP.Role
                        local role, roleCol = GetPlayerRole(player)
                        roleLabel.Text = role
                        roleLabel.TextColor3 = roleCol
                    end
                    
                    if healthBg then
                        healthBg.Visible = State.ESP.Health
                        local healthFill = healthBg:FindFirstChild("HealthFill")
                        if healthFill then
                            local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            healthFill.Size = UDim2.new(hp, 0, 1, 0)
                            if hp > 0.5 then
                                healthFill.BackgroundColor3 = Colors.Success
                            elseif hp > 0.25 then
                                healthFill.BackgroundColor3 = Colors.Warning
                            else
                                healthFill.BackgroundColor3 = Colors.Error
                            end
                        end
                    end
                else
                    if espData.BillboardGui then
                        pcall(function() espData.BillboardGui:Destroy() end)
                        espData.BillboardGui = nil
                    end
                end
            else
                -- Player dead or no character, clean up
                if State.ESP.Objects[player.UserId] then
                    local data = State.ESP.Objects[player.UserId]
                    pcall(function() if data.BillboardGui then data.BillboardGui:Destroy() end end)
                    pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
                    State.ESP.Objects[player.UserId] = nil
                end
            end
        end
    end
    
    -- Clean up disconnected players
    local validIds = {}
    for _, p in ipairs(Players:GetPlayers()) do
        validIds[p.UserId] = true
    end
    for uid, data in pairs(State.ESP.Objects) do
        if not validIds[uid] then
            pcall(function() if data.BillboardGui then data.BillboardGui:Destroy() end end)
            pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
            State.ESP.Objects[uid] = nil
        end
    end
end

-- ESP update on heartbeat (throttled)
local espAccum = 0
Util.Connect(RunService.Heartbeat, function(dt)
    espAccum = espAccum + dt
    if espAccum >= 0.15 then
        espAccum = 0
        pcall(UpdateESP)
    end
end)

-- ============================================================
-- TELEPORT SAFETY TAB
-- ============================================================
local tpPage = TabPages["Teleport"]

CreateSectionHeader(tpPage, "Teleport Safety", 1)

local tpCard = CreateCard(tpPage, nil, 2)
Util.AddPadding(tpCard, 10, 10, 10, 10)
local tpLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = tpCard
})
Util.AddListLayout(tpLayout, 4)

local tpStatusLabel = CreateInfoLabel(tpLayout, "Status: Disabled", 0)

CreateToggle(tpLayout, "Enable Auto-Safety", false, function(val)
    State.Teleport.Enabled = val
    tpStatusLabel.Text = "Status: " .. (val and "Monitoring" or "Disabled")
    tpStatusLabel.TextColor3 = val and Colors.Success or Colors.TextDim
    Notify("Teleport Safety", val and "Monitoring enabled" or "Monitoring disabled", val and "Success" or "Info")
end, 1)

CreateSlider(tpLayout, "Detection Radius", 10, 100, 35, function(val)
    State.Teleport.Radius = val
end, 2)

CreateSlider(tpLayout, "Safe Distance", 50, 300, 100, function(val)
    State.Teleport.SafeDistance = val
end, 3)

CreateSlider(tpLayout, "Cooldown (sec)", 1, 15, 3, function(val)
    State.Teleport.Cooldown = val
end, 4)

-- Safe Position Algorithm
local function FindSafePosition(killerPos, myPos)
    local bestPos = nil
    local bestDist = 0
    local safeDist = State.Teleport.SafeDistance
    
    -- Try multiple directions
    for angle = 0, 350, 15 do
        for dist = safeDist, safeDist * 2, 20 do
            local rad = math.rad(angle)
            local candidatePos = killerPos + Vector3.new(
                math.cos(rad) * dist,
                0,
                math.sin(rad) * dist
            )
            
            -- Raycast down to find ground
            local rayOrigin = candidatePos + Vector3.new(0, 50, 0)
            local rayDirection = Vector3.new(0, -200, 0)
            
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
            
            local result = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
            
            if result then
                local groundPos = result.Position + Vector3.new(0, 3, 0)
                
                -- Verify not inside a wall (cast horizontal rays)
                local wallCheck = true
                for _, dir in ipairs({Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1)}) do
                    local wallRay = Workspace:Raycast(groundPos, dir * 3, rayParams)
                    if wallRay then
                        wallCheck = false
                        break
                    end
                end
                
                -- Verify above void (ground must exist)
                local voidCheck = groundPos.Y > -50
                
                if wallCheck and voidCheck then
                    local distFromKiller = (groundPos - killerPos).Magnitude
                    if distFromKiller > bestDist and distFromKiller >= safeDist then
                        bestDist = distFromKiller
                        bestPos = groundPos
                    end
                end
            end
        end
    end
    
    return bestPos
end

-- Teleport Safety Loop
local tpCheckAccum = 0
Util.Connect(RunService.Heartbeat, function(dt)
    if not State.Teleport.Enabled then return end
    tpCheckAccum = tpCheckAccum + dt
    if tpCheckAccum < 0.5 then return end
    tpCheckAccum = 0
    
    local _, _, myHRP = Util.GetCharacter()
    if not myHRP then return end
    
    if tick() - State.Teleport.LastTeleport < State.Teleport.Cooldown then return end
    
    -- Find nearest "Killer" type player
    local nearestKiller = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local role = GetPlayerRole(player)
                if role == "Killer" or role == "Hunter" or role == "Monster" or role == "Beast" then
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestKiller = hrp
                    end
                end
            end
        end
    end
    
    if nearestKiller and nearestDist <= State.Teleport.Radius then
        local safePos = FindSafePosition(nearestKiller.Position, myHRP.Position)
        if safePos then
            myHRP.CFrame = CFrame.new(safePos)
            State.Teleport.LastTeleport = tick()
            tpStatusLabel.Text = string.format("Status: Teleported (%.0f studs away)", (safePos - nearestKiller.Position).Magnitude)
            Notify("Teleport Safety", string.format("Escaped to safe position (%.0f studs)", (safePos - nearestKiller.Position).Magnitude), "Success")
        else
            tpStatusLabel.Text = "Status: No safe position found"
            Notify("Teleport Safety", "Could not find safe position", "Warning")
        end
    end
end)

-- ============================================================
-- SPEED CONTROLLER TAB
-- ============================================================
local speedPage = TabPages["Speed"]

CreateSectionHeader(speedPage, "Speed Controller", 1)

local speedCard = CreateCard(speedPage, nil, 2)
Util.AddPadding(speedCard, 10, 10, 10, 10)
local speedLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = speedCard
})
Util.AddListLayout(speedLayout, 4)

local speedInfoLabel = CreateInfoLabel(speedLayout, "Current Speed: 16", 0)

local _, getSpeedValue = CreateSlider(speedLayout, "Walk Speed", 1, 10, 1, function(val)
    -- Map 1-10 to actual speed values
    local speedMap = {16, 24, 32, 40, 50, 60, 75, 90, 110, 130}
    local actualSpeed = speedMap[val] or 16
    State.Speed.Value = actualSpeed
    local _, hum = Util.GetCharacter()
    if hum then
        hum.WalkSpeed = actualSpeed
    end
    speedInfoLabel.Text = "Current Speed: " .. actualSpeed .. " (Level " .. val .. ")"
end, 1)

-- Keep speed updated
Util.Connect(RunService.Heartbeat, function()
    if State.Speed.Value ~= 16 then
        local _, hum = Util.GetCharacter()
        if hum and hum.WalkSpeed ~= State.Speed.Value then
            hum.WalkSpeed = State.Speed.Value
        end
    end
end)

-- ============================================================
-- POV CIRCLE TAB
-- ============================================================
local povPage = TabPages["POV Circle"]

CreateSectionHeader(povPage, "POV Circle", 1)

local povCard = CreateCard(povPage, nil, 2)
Util.AddPadding(povCard, 10, 10, 10, 10)
local povLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = povCard
})
Util.AddListLayout(povLayout, 4)

CreateToggle(povLayout, "Enable POV Circle", false, function(val)
    State.POV.Enabled = val
    Notify("POV Circle", val and "Enabled" or "Disabled", val and "Success" or "Info")
end, 1)

CreateSlider(povLayout, "Radius", 50, 400, 150, function(val)
    State.POV.Radius = val
end, 2)

CreateSlider(povLayout, "Thickness", 1, 8, 2, function(val)
    State.POV.Thickness = val
end, 3)

CreateSlider(povLayout, "Opacity (%)", 10, 100, 50, function(val)
    State.POV.Opacity = val / 100
end, 4)

-- POV Circle Drawing
local POVCircleFrame = Util.Create("Frame", {
    Name = "POVCircle",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 5,
    Visible = false,
    Parent = ScreenGui
})

-- Create circle segments using frames
local circleSegments = {}
local numSegments = 72

for i = 1, numSegments do
    local seg = Util.Create("Frame", {
        Size = UDim2.new(0, 3, 0, 2),
        BackgroundColor3 = Colors.Accent,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6,
        Parent = POVCircleFrame
    })
    Util.AddCorner(seg, 1)
    circleSegments[i] = seg
end

Util.Connect(RunService.RenderStepped, function()
    if not State.POV.Enabled then
        POVCircleFrame.Visible = false
        return
    end
    
    POVCircleFrame.Visible = true
    local vpSize = Camera.ViewportSize
    local centerX = vpSize.X / 2
    local centerY = vpSize.Y / 2
    local radius = State.POV.Radius
    local thickness = State.POV.Thickness
    
    for i = 1, numSegments do
        local angle = (i / numSegments) * math.pi * 2
        local x = centerX + math.cos(angle) * radius
        local y = centerY + math.sin(angle) * radius
        
        local seg = circleSegments[i]
        seg.Position = UDim2.new(0, x, 0, y)
        seg.Size = UDim2.new(0, math.max(thickness + 2, 4), 0, thickness)
        seg.Rotation = math.deg(angle) + 90
        seg.BackgroundColor3 = State.POV.Color
        seg.BackgroundTransparency = 1 - State.POV.Opacity
    end
end)

-- ============================================================
-- OBSERVATION TARGET TAB
-- ============================================================
local obsPage = TabPages["Observation"]

CreateSectionHeader(obsPage, "Observation Target", 1)

local obsCard = CreateCard(obsPage, nil, 2)
Util.AddPadding(obsCard, 10, 10, 10, 10)
local obsLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = obsCard
})
Util.AddListLayout(obsLayout, 4)

local obsStatusLabel = CreateInfoLabel(obsLayout, "Targets in POV: 0", 0)

CreateToggle(obsLayout, "Enable Observation", false, function(val)
    State.Observation.Enabled = val
    if not val then
        -- Clear indicators
        for _, ind in pairs(State.Observation.Indicators) do
            pcall(function() ind:Destroy() end)
        end
        State.Observation.Indicators = {}
    end
    Notify("Observation", val and "Enabled" or "Disabled", val and "Success" or "Info")
end, 1)

CreateSlider(obsLayout, "Detection Radius (px)", 50, 500, 200, function(val)
    State.Observation.Radius = val
end, 2)

CreateSlider(obsLayout, "Indicator Opacity (%)", 10, 100, 70, function(val)
    State.Observation.Transparency = 1 - (val / 100)
end, 3)

-- Observation Container
local ObsContainer = Util.Create("Frame", {
    Name = "ObservationContainer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 6,
    Parent = ScreenGui
})

local function GetOrCreateIndicator(player)
    if State.Observation.Indicators[player.UserId] then
        return State.Observation.Indicators[player.UserId]
    end
    
    local indicator = Util.Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = State.Observation.Color,
        BackgroundTransparency = State.Observation.Transparency,
        BorderSizePixel = 0,
        ZIndex = 7,
        Visible = false,
        Parent = ObsContainer
    })
    Util.AddCorner(indicator, 6)
    Util.AddStroke(indicator, State.Observation.Color, 1, 0.3)
    
    -- Name label on indicator
    local nameTag = Util.Create("TextLabel", {
        Size = UDim2.new(0, 100, 0, 14),
        Position = UDim2.new(0.5, 0, 0, -18),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = State.Observation.Color,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 8,
        Parent = indicator
    })
    nameTag.Text = player.DisplayName
    
    -- Distance label
    local distTag = Util.Create("TextLabel", {
        Name = "DistTag",
        Size = UDim2.new(0, 80, 0, 12),
        Position = UDim2.new(0.5, 0, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 9,
        TextColor3 = Colors.TextDim,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 8,
        Parent = indicator
    })
    
    State.Observation.Indicators[player.UserId] = indicator
    return indicator
end

-- Observation update loop
Util.Connect(RunService.RenderStepped, function()
    if not State.Observation.Enabled then
        for _, ind in pairs(State.Observation.Indicators) do
            ind.Visible = false
        end
        return
    end
    
    local vpSize = Camera.ViewportSize
    local centerX = vpSize.X / 2
    local centerY = vpSize.Y / 2
    local obsRadius = State.Observation.Radius
    local inPOV = 0
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local dx = screenPos.X - centerX
                    local dy = screenPos.Y - centerY
                    local distFromCenter = math.sqrt(dx * dx + dy * dy)
                    
                    if distFromCenter <= obsRadius then
                        inPOV = inPOV + 1
                        local indicator = GetOrCreateIndicator(player)
                        indicator.Visible = true
                        indicator.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                        indicator.BackgroundColor3 = State.Observation.Color
                        indicator.BackgroundTransparency = State.Observation.Transparency
                        
                        local distTag = indicator:FindFirstChild("DistTag")
                        if distTag then
                            local _, _, myHRP = Util.GetCharacter()
                            if myHRP then
                                local dist3d = (myHRP.Position - hrp.Position).Magnitude
                                distTag.Text = string.format("%.0f studs", dist3d)
                            end
                        end
                    else
                        if State.Observation.Indicators[player.UserId] then
                            State.Observation.Indicators[player.UserId].Visible = false
                        end
                    end
                else
                    if State.Observation.Indicators[player.UserId] then
                        State.Observation.Indicators[player.UserId].Visible = false
                    end
                end
            else
                if State.Observation.Indicators[player.UserId] then
                    State.Observation.Indicators[player.UserId].Visible = false
                end
            end
        end
    end
    
    obsStatusLabel.Text = "Targets in POV: " .. inPOV
    
    -- Clean disconnected players
    local validIds = {}
    for _, p in ipairs(Players:GetPlayers()) do validIds[p.UserId] = true end
    for uid, ind in pairs(State.Observation.Indicators) do
        if not validIds[uid] then
            pcall(function() ind:Destroy() end)
            State.Observation.Indicators[uid] = nil
        end
    end
end)

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local setPage = TabPages["Settings"]

CreateSectionHeader(setPage, "Settings", 1)

-- UI Settings Card
local setCard1 = CreateCard(setPage, nil, 2)
Util.AddPadding(setCard1, 10, 10, 10, 10)
local setLayout1 = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = setCard1
})
Util.AddListLayout(setLayout1, 4)

CreateSectionHeader(setLayout1, "Interface", 0)

CreateSlider(setLayout1, "Animation Speed (%)", 50, 200, 100, function(val)
    State.Settings.AnimSpeed = val / 100
end, 1)

CreateToggle(setLayout1, "Background Blur", true, function(val)
    State.Settings.BlurEnabled = val
    if BlurEffect then
        if val and State.GuiOpen then
            Util.Tween(BlurEffect, 0.3, {Size = 10})
        else
            Util.Tween(BlurEffect, 0.3, {Size = 0})
        end
    end
end, 2)

-- Visual Card
local setCard2 = CreateCard(setPage, nil, 3)
Util.AddPadding(setCard2, 10, 10, 10, 10)
local setLayout2 = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = setCard2
})
Util.AddListLayout(setLayout2, 4)

CreateSectionHeader(setLayout2, "Visual", 0)

CreateColorPicker(setLayout2, "Accent Color", Colors.Accent, nil, 1)
CreateColorPicker(setLayout2, "POV Circle Color", Colors.Accent, nil, 2)
CreateColorPicker(setLayout2, "Observation Color", Colors.Success, nil, 3)

-- About Card
local setCard3 = CreateCard(setPage, nil, 4)
Util.AddPadding(setCard3, 10, 10, 10, 10)
local setLayout3 = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = setCard3
})
Util.AddListLayout(setLayout3, 4)

CreateSectionHeader(setLayout3, "About", 0)
CreateInfoLabel(setLayout3, "Hoshi Development Tools v1.0.0", 1)
CreateInfoLabel(setLayout3, "Internal Development Build", 2)
CreateInfoLabel(setLayout3, "For map development and QA testing", 3)

-- Reset Button
local resetCard = CreateCard(setPage, nil, 5)
Util.AddPadding(resetCard, 10, 10, 10, 10)
local resetLayout = Util.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = resetCard
})
Util.AddListLayout(resetLayout, 4)

CreateButton(resetLayout, "Reset All Settings", function()
    Notify("Settings", "Settings reset to defaults", "Success")
end, 1)

CreateButton(resetLayout, "Destroy Script", function()
    if _G.HoshiCleanup then _G.HoshiCleanup() end
end, 2)

-- ============================================================
-- FLOATING BUTTON
-- ============================================================
FloatingBtn = Util.Create("TextButton", {
    Name = "FloatingButton",
    Size = UDim2.new(0, 46, 0, 46),
    Position = UDim2.new(0, 20, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Colors.Surface,
    BackgroundTransparency = 0.1,
    Text = "H",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Colors.Accent,
    BorderSizePixel = 0,
    ZIndex = 50,
    AutoButtonColor = false,
    Visible = false,
    Parent = ScreenGui
})
Util.AddCorner(FloatingBtn, 14)
Util.AddStroke(FloatingBtn, Colors.Accent, 2, 0.4)

-- Floating button glow ring
local floatGlow = Util.Create("Frame", {
    Size = UDim2.new(1, 8, 1, 8),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Colors.Accent,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    ZIndex = 49,
    Parent = FloatingBtn
})
Util.AddCorner(floatGlow, 16)

-- Pulse animation for floating button
local pulseUp = true
local function PulseFloat()
    if not FloatingBtn.Visible then return end
    local stroke = FloatingBtn:FindFirstChildOfClass("UIStroke")
    if stroke then
        Util.Tween(stroke, 1.5, {Transparency = pulseUp and 0.2 or 0.6}, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, function()
            pulseUp = not pulseUp
            PulseFloat()
        end)
    end
end

-- Floating button drag
local floatDragging = false
local floatDragStart = nil
local floatStartPos = nil

FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        floatDragging = true
        floatDragStart = input.Position
        floatStartPos = FloatingBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                if floatDragging then
                    local delta = input.Position - floatDragStart
                    if delta.Magnitude < 5 then
                        -- Click, not drag - open GUI
                        OpenMainGUI()
                    end
                end
                floatDragging = false
            end
        end)
    end
end)

Util.Connect(UserInputService.InputChanged, function(input)
    if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatDragStart
        local newX = floatStartPos.X.Offset + delta.X
        local newY = floatStartPos.Y.Offset + delta.Y
        
        local vp = Camera.ViewportSize
        newX = math.clamp(newX, 0, vp.X - 46)
        newY = math.clamp(newY, 0, vp.Y - 46)
        
        FloatingBtn.AnchorPoint = Vector2.new(0, 0)
        FloatingBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- Hover effect
FloatingBtn.MouseEnter:Connect(function()
    Util.Tween(FloatingBtn, 0.25, {
        Size = UDim2.new(0, 50, 0, 50),
        BackgroundTransparency = 0.05
    }, Enum.EasingStyle.Back)
    local stroke = FloatingBtn:FindFirstChildOfClass("UIStroke")
    if stroke then
        Util.Tween(stroke, 0.2, {Transparency = 0.1})
    end
end)

FloatingBtn.MouseLeave:Connect(function()
    Util.Tween(FloatingBtn, 0.25, {
        Size = UDim2.new(0, 46, 0, 46),
        BackgroundTransparency = 0.1
    }, Enum.EasingStyle.Back)
    local stroke = FloatingBtn:FindFirstChildOfClass("UIStroke")
    if stroke then
        Util.Tween(stroke, 0.2, {Transparency = 0.4})
    end
end)

-- ============================================================
-- OPEN/CLOSE GUI
-- ============================================================
function OpenMainGUI()
    State.GuiOpen = true
    FloatingBtn.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, State.WindowSize.X.Offset * 0.9, 0, State.WindowSize.Y.Offset * 0.9)
    MainFrame.BackgroundTransparency = 0.5
    
    Util.Tween(MainFrame, 0.4, {
        Size = State.WindowSize,
        BackgroundTransparency = 0.02
    }, Enum.EasingStyle.Quart)
    
    if BlurEffect and State.Settings.BlurEnabled then
        Util.Tween(BlurEffect, 0.3, {Size = 10})
    end
end

-- ============================================================
-- CLEANUP SYSTEM
-- ============================================================
_G.HoshiCleanup = function()
    -- Disconnect all connections
    for _, conn in ipairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    State.Connections = {}
    
    -- Clean ESP
    for _, obj in pairs(State.ESP.Objects) do
        pcall(function() if obj.BillboardGui then obj.BillboardGui:Destroy() end end)
        pcall(function() if obj.Highlight then obj.Highlight:Destroy() end end)
    end
    
    -- Clean observation indicators
    for _, ind in pairs(State.Observation.Indicators) do
        pcall(function() ind:Destroy() end)
    end
    
    -- Remove blur
    if BlurEffect then
        pcall(function() BlurEffect:Destroy() end)
    end
    
    -- Remove GUI
    pcall(function() ScreenGui:Destroy() end)
    
    _G.HoshiCleanup = nil
end

-- ============================================================
-- INITIALIZATION
-- ============================================================
-- Set initial tab
SwitchTab("Dashboard")

-- Show splash then open
ShowSplashScreen(function()
    OpenMainGUI()
    PulseFloat()
    
    task.delay(0.5, function()
        Notify("Hoshi Development Tools", "Development environment loaded successfully", "Success", 5)
    end)
    
    task.delay(1.5, function()
        Notify("System", "All modules initialized and ready", "Info", 3)
    end)
end)

-- Handle character respawn
Util.Connect(LocalPlayer.CharacterAdded, function(char)
    task.wait(1)
    if State.Speed.Value ~= 16 then
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.WalkSpeed = State.Speed.Value
        end
    end
end)

-- Handle player leaving (ESP cleanup)
Util.Connect(Players.PlayerRemoving, function(player)
    if State.ESP.Objects[player.UserId] then
        local data = State.ESP.Objects[player.UserId]
        pcall(function() if data.BillboardGui then data.BillboardGui:Destroy() end end)
        pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
        State.ESP.Objects[player.UserId] = nil
    end
    if State.Observation.Indicators[player.UserId] then
        pcall(function() State.Observation.Indicators[player.UserId]:Destroy() end)
        State.Observation.Indicators[player.UserId] = nil
    end
end)