--[[
    ============================================================
    HOSHI DEVELOPMENT TOOLS v2.0
    Internal Admin Development Tools
    Production Build - Mobile & Desktop Compatible
    ============================================================
    
    Architecture:
    [Config] -> [Utility] -> [Animation] -> [Components]
    -> [Window] -> [Tabs] -> [Systems] -> [Init]
    
    ============================================================
]]

-- ============================================================
-- PHASE 0: CLEANUP PREVIOUS INSTANCE
-- ============================================================
if _G.HoshiDevTools then
    pcall(function() _G.HoshiDevTools:Destroy() end)
end
if _G.HoshiBlur then
    pcall(function() _G.HoshiBlur:Destroy() end)
end
_G.HoshiDevTools = nil
_G.HoshiBlur = nil

-- ============================================================
-- PHASE 1: SERVICES & CORE REFERENCES
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local GuiInset = GuiService:GetGuiInset()

-- ============================================================
-- PHASE 2: CONFIGURATION
-- ============================================================
local Config = {
    Version = "2.0.0",
    BuildType = "Production",
    
    Colors = {
        BgPrimary = Color3.fromRGB(13, 13, 20),
        BgSecondary = Color3.fromRGB(18, 18, 28),
        BgTertiary = Color3.fromRGB(24, 24, 36),
        BgElevated = Color3.fromRGB(30, 30, 44),
        BgHover = Color3.fromRGB(38, 38, 52),
        BgActive = Color3.fromRGB(44, 44, 60),
        
        Border = Color3.fromRGB(42, 42, 58),
        BorderLight = Color3.fromRGB(56, 56, 74),
        BorderFocus = Color3.fromRGB(0, 120, 215),
        
        TextPrimary = Color3.fromRGB(230, 232, 240),
        TextSecondary = Color3.fromRGB(160, 164, 180),
        TextTertiary = Color3.fromRGB(100, 104, 120),
        TextDisabled = Color3.fromRGB(65, 68, 80),
        
        Accent = Color3.fromRGB(0, 120, 215),
        AccentHover = Color3.fromRGB(20, 140, 235),
        AccentDim = Color3.fromRGB(0, 80, 160),
        AccentSurface = Color3.fromRGB(0, 120, 215),
        
        Success = Color3.fromRGB(35, 180, 105),
        SuccessDim = Color3.fromRGB(20, 120, 70),
        Warning = Color3.fromRGB(220, 170, 30),
        WarningDim = Color3.fromRGB(160, 120, 20),
        Error = Color3.fromRGB(220, 55, 55),
        ErrorDim = Color3.fromRGB(160, 35, 35),
        Info = Color3.fromRGB(0, 150, 220),
        
        Scrollbar = Color3.fromRGB(60, 60, 80),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    
    Window = {
        MinWidth = IsMobile and 340 or 680,
        MinHeight = IsMobile and 320 or 440,
        DefaultWidth = IsMobile and 370 or 820,
        DefaultHeight = IsMobile and 460 or 560,
        SidebarWidth = IsMobile and 52 or 185,
        TitleBarHeight = IsMobile and 42 or 40,
        CornerRadius = 10,
    },
    
    Animation = {
        SpeedMultiplier = 1,
        DefaultDuration = 0.3,
        FastDuration = 0.15,
        SlowDuration = 0.5,
    },
    
    ESP = {
        Enabled = false,
        ShowBox = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowRole = true,
        UpdateInterval = 0.15,
    },
    
    Teleport = {
        Enabled = false,
        DetectionRadius = 35,
        SafeDistance = 100,
        Cooldown = 3,
        LastUsed = 0,
    },
    
    Speed = {
        Level = 1,
        Values = {16, 22, 28, 36, 44, 54, 66, 80, 100, 130},
    },
    
    POVCircle = {
        Enabled = false,
        Radius = 150,
        Thickness = 2,
        Opacity = 0.5,
        Color = Color3.fromRGB(0, 120, 215),
        Segments = 64,
    },
    
    Observation = {
        Enabled = false,
        ScreenRadius = 200,
        Opacity = 0.7,
        Color = Color3.fromRGB(0, 200, 130),
    },
    
    Settings = {
        BlurEnabled = true,
        AnimSpeed = 100,
    },
}

-- ============================================================
-- PHASE 3: STATE MANAGEMENT
-- ============================================================
local AppState = {
    IsOpen = false,
    IsMinimized = false,
    IsMaximized = false,
    ActiveTab = "Dashboard",
    
    WindowPosition = nil,
    WindowSize = nil,
    PreMaxPosition = nil,
    PreMaxSize = nil,
    PreMinSize = nil,
    
    Connections = {},
    ESPObjects = {},
    ObservationIndicators = {},
    
    FPS = 60,
    Ping = 0,
    FrameCount = 0,
    FrameTimer = 0,
    StartTime = tick(),
}

-- ============================================================
-- PHASE 4: UTILITY MODULE
-- ============================================================
local Util = {}

function Util.new(className, properties, children)
    local instance = Instance.new(className)
    if properties then
        for key, value in pairs(properties) do
            if key ~= "Parent" then
                local ok = pcall(function() instance[key] = value end)
            end
        end
        if properties.Parent then
            instance.Parent = properties.Parent
        end
    end
    if children then
        for _, child in ipairs(children) do
            if child then child.Parent = instance end
        end
    end
    return instance
end

function Util.corner(parent, radius)
    return Util.new("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

function Util.stroke(parent, color, thickness, transparency)
    return Util.new("UIStroke", {
        Color = color or Config.Colors.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

function Util.padding(parent, top, bottom, left, right)
    return Util.new("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or top or 0),
        PaddingRight = UDim.new(0, right or left or top or 0),
        Parent = parent,
    })
end

function Util.list(parent, padding, direction, hAlign, vAlign)
    return Util.new("UIListLayout", {
        Padding = UDim.new(0, padding or 4),
        FillDirection = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

function Util.gradient(parent, c1, c2, rotation)
    return Util.new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        }),
        Rotation = rotation or 90,
        Parent = parent,
    })
end

function Util.connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(AppState.Connections, connection)
    return connection
end

function Util.disconnectAll()
    for _, conn in ipairs(AppState.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    AppState.Connections = {}
end

function Util.getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    return char, humanoid, rootPart
end

function Util.getViewportSize()
    return Camera.ViewportSize
end

function Util.formatTime()
    local t = os.date("*t")
    return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

function Util.getPing()
    local ok, val = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and math.floor(val) or 0
end

function Util.lerp(a, b, t)
    return a + (b - a) * t
end

function Util.lerpColor(c1, c2, t)
    return Color3.new(
        Util.lerp(c1.R, c2.R, t),
        Util.lerp(c1.G, c2.G, t),
        Util.lerp(c1.B, c2.B, t)
    )
end

-- ============================================================
-- PHASE 5: ANIMATION MODULE
-- ============================================================
local Anim = {}

function Anim.tween(object, duration, properties, easingStyle, easingDir, callback)
    if not object then return nil end
    local ok = pcall(function() local _ = object.Parent end)
    if not ok then return nil end
    
    duration = (duration or Config.Animation.DefaultDuration) * (Config.Animation.SpeedMultiplier or 1)
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDir = easingDir or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDir)
    local tween = TweenService:Create(object, tweenInfo, properties)
    
    if callback then
        tween.Completed:Once(callback)
    end
    
    tween:Play()
    return tween
end

function Anim.fadeIn(object, duration)
    if not object then return end
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        object.TextTransparency = 1
        Anim.tween(object, duration or 0.3, {TextTransparency = 0})
    end
    if object:IsA("GuiObject") then
        object.BackgroundTransparency = 1
        Anim.tween(object, duration or 0.3, {BackgroundTransparency = object:GetAttribute("TargetBgTransparency") or 0})
    end
end

function Anim.fadeOut(object, duration, callback)
    if not object then return end
    local props = {}
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        props.TextTransparency = 1
    end
    if object:IsA("GuiObject") then
        props.BackgroundTransparency = 1
    end
    Anim.tween(object, duration or 0.3, props, nil, nil, callback)
end

function Anim.ripple(button, inputPosition)
    if not button or not button.Parent then return end
    
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    
    local localX = inputPosition and (inputPosition.X - absPos.X) or (absSize.X / 2)
    local localY = inputPosition and (inputPosition.Y - absPos.Y) or (absSize.Y / 2)
    
    local maxRadius = math.max(
        math.sqrt(localX ^ 2 + localY ^ 2),
        math.sqrt((absSize.X - localX) ^ 2 + localY ^ 2),
        math.sqrt(localX ^ 2 + (absSize.Y - localY) ^ 2),
        math.sqrt((absSize.X - localX) ^ 2 + (absSize.Y - localY) ^ 2)
    ) * 2
    
    local clipFrame = Util.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 2,
        Parent = button,
    })
    
    local circle = Util.new("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, localX, 0, localY),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 3,
        Parent = clipFrame,
    })
    Util.corner(circle, 99999)
    
    Anim.tween(circle, 0.55, {
        Size = UDim2.new(0, maxRadius, 0, maxRadius),
        BackgroundTransparency = 1,
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
        pcall(function() clipFrame:Destroy() end)
    end)
end

function Anim.scaleIn(object, duration)
    if not object then return end
    local targetSize = object.Size
    object.Size = UDim2.new(
        targetSize.X.Scale * 0.85, targetSize.X.Offset * 0.85,
        targetSize.Y.Scale * 0.85, targetSize.Y.Offset * 0.85
    )
    Anim.tween(object, duration or 0.4, {Size = targetSize}, Enum.EasingStyle.Back)
end

function Anim.hover(object, isHovering, bgColor, textColor)
    if not object then return end
    if isHovering then
        Anim.tween(object, 0.2, {
            BackgroundColor3 = bgColor or Config.Colors.BgHover,
            BackgroundTransparency = 0.3,
        })
        if textColor and (object:IsA("TextLabel") or object:IsA("TextButton")) then
            Anim.tween(object, 0.2, {TextColor3 = textColor})
        end
    else
        Anim.tween(object, 0.2, {
            BackgroundColor3 = bgColor or Config.Colors.BgTertiary,
            BackgroundTransparency = 1,
        })
    end
end

-- ============================================================
-- PHASE 6: SCREEN GUI
-- ============================================================
local ScreenGui = Util.new("ScreenGui", {
    Name = "HoshiDevTools_v2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
    IgnoreGuiInset = true,
    Parent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui"),
})
_G.HoshiDevTools = ScreenGui

-- Background Blur
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Name = "HoshiBlur"
BlurEffect.Parent = Lighting
_G.HoshiBlur = BlurEffect

-- ============================================================
-- PHASE 7: NOTIFICATION SYSTEM
-- ============================================================
local NotificationModule = {}

local NotifContainer = Util.new("Frame", {
    Name = "Notifications",
    Size = UDim2.new(0, IsMobile and 280 or 320, 1, -20),
    Position = UDim2.new(1, IsMobile and -10 or -14, 0, 50),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 500,
    Parent = ScreenGui,
})
Util.list(NotifContainer, 6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)

function NotificationModule.send(title, message, nType, duration)
    nType = nType or "Info"
    duration = duration or 4
    
    local typeColorMap = {
        Info = Config.Colors.Info,
        Success = Config.Colors.Success,
        Warning = Config.Colors.Warning,
        Error = Config.Colors.Error,
    }
    local accentColor = typeColorMap[nType] or Config.Colors.Info
    
    local notif = Util.new("Frame", {
        Size = UDim2.new(1, 0, 0, IsMobile and 66 or 70),
        BackgroundColor3 = Config.Colors.BgSecondary,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 501,
        ClipsDescendants = true,
        Parent = NotifContainer,
    })
    Util.corner(notif, 10)
    Util.stroke(notif, accentColor, 1, 0.5)
    
    -- Left accent strip
    Util.new("Frame", {
        Size = UDim2.new(0, 3, 1, -10),
        Position = UDim2.new(0, 7, 0, 5),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 502,
        Parent = notif,
    })
    
    Util.new("TextLabel", {
        Text = title or "Notification",
        Size = UDim2.new(1, -28, 0, 20),
        Position = UDim2.new(0, 20, 0, 10),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = IsMobile and 12 or 13,
        TextColor3 = Config.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 502,
        Parent = notif,
    })
    
    Util.new("TextLabel", {
        Text = message or "",
        Size = UDim2.new(1, -28, 0, 16),
        Position = UDim2.new(0, 20, 0, 30),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = IsMobile and 10 or 11,
        TextColor3 = Config.Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 502,
        Parent = notif,
    })
    
    -- Progress bar
    local progressBg = Util.new("Frame", {
        Size = UDim2.new(1, -24, 0, 2),
        Position = UDim2.new(0, 12, 1, -9),
        BackgroundColor3 = Config.Colors.BgElevated,
        BorderSizePixel = 0,
        ZIndex = 502,
        Parent = notif,
    })
    Util.corner(progressBg, 1)
    
    local progressFill = Util.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 503,
        Parent = progressBg,
    })
    Util.corner(progressFill, 1)
    
    -- Slide in animation
    local targetPos = notif.Position
    notif.Position = UDim2.new(1.2, 0, targetPos.Y.Scale, targetPos.Y.Offset)
    notif.BackgroundTransparency = 0.8
    
    Anim.tween(notif, 0.35, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.05,
    }, Enum.EasingStyle.Quart)
    
    Anim.tween(progressFill, duration, {
        Size = UDim2.new(0, 0, 1, 0),
    }, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        if notif and notif.Parent then
            Anim.tween(notif, 0.3, {
                Position = UDim2.new(1.2, 0, 0, 0),
                BackgroundTransparency = 1,
            }, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
                pcall(function() notif:Destroy() end)
            end)
        end
    end)
end

-- ============================================================
-- PHASE 8: WATERMARK
-- ============================================================
local Watermark = Util.new("Frame", {
    Name = "Watermark",
    Size = UDim2.new(0, IsMobile and 320 or 400, 0, 24),
    Position = UDim2.new(0, 10, 0, 6),
    BackgroundColor3 = Config.Colors.BgSecondary,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 400,
    Parent = ScreenGui,
})
Util.corner(Watermark, 5)
Util.stroke(Watermark, Config.Colors.Border, 1, 0.6)

local WatermarkLabel = Util.new("TextLabel", {
    Text = "Hoshi Development Tools | Initializing...",
    Size = UDim2.new(1, -14, 1, 0),
    Position = UDim2.new(0, 7, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code,
    TextSize = IsMobile and 9 or 10,
    TextColor3 = Config.Colors.TextSecondary,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 401,
    Parent = Watermark,
})

-- ============================================================
-- PHASE 9: FLOATING BUTTON (ALWAYS CREATED FIRST)
-- ============================================================
local FloatingButton = Util.new("TextButton", {
    Name = "FloatingButton",
    Size = UDim2.new(0, IsMobile and 52 or 48, 0, IsMobile and 52 or 48),
    Position = UDim2.new(0, 16, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Config.Colors.BgSecondary,
    BackgroundTransparency = 0.08,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 600,
    AutoButtonColor = false,
    Visible = true,
    Active = true,
    Parent = ScreenGui,
})
Util.corner(FloatingButton, IsMobile and 16 or 14)

local FloatStroke = Util.stroke(FloatingButton, Config.Colors.Accent, 2, 0.3)

-- Glow ring behind button
local FloatGlow = Util.new("Frame", {
    Size = UDim2.new(1, 12, 1, 12),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Config.Colors.Accent,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    ZIndex = 599,
    Parent = FloatingButton,
})
Util.corner(FloatGlow, IsMobile and 20 or 18)

-- "H" letter
local FloatLabel = Util.new("TextLabel", {
    Text = "H",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = IsMobile and 24 or 22,
    TextColor3 = Config.Colors.Accent,
    ZIndex = 601,
    Parent = FloatingButton,
})

-- Floating button drag handling
local floatDragData = {
    isDragging = false,
    startInput = nil,
    startPos = nil,
    moved = false,
}

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        floatDragData.isDragging = true
        floatDragData.startInput = input.Position
        floatDragData.startPos = FloatingButton.Position
        floatDragData.moved = false
    end
end)

FloatingButton.InputChanged:Connect(function(input)
    if floatDragData.isDragging and
       (input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatDragData.startInput
        if delta.Magnitude > 5 then
            floatDragData.moved = true
        end
        local vp = Util.getViewportSize()
        local btnSize = FloatingButton.AbsoluteSize
        local newX = math.clamp(floatDragData.startPos.X.Offset + delta.X, 4, vp.X - btnSize.X - 4)
        local newY = math.clamp(floatDragData.startPos.Y.Offset + delta.Y, 4, vp.Y - btnSize.Y - 4)
        FloatingButton.AnchorPoint = Vector2.new(0, 0)
        FloatingButton.Position = UDim2.new(0, newX, 0, newY)
    end
end)

FloatingButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        if not floatDragData.moved then
            -- This is a click/tap - Open GUI
            if not AppState.IsOpen then
                OpenGUI()
            end
        end
        floatDragData.isDragging = false
        floatDragData.moved = false
    end
end)

-- Hover animations (desktop only)
if not IsMobile then
    FloatingButton.MouseEnter:Connect(function()
        Anim.tween(FloatingButton, 0.25, {
            Size = UDim2.new(0, 54, 0, 54),
            BackgroundTransparency = 0.02,
        }, Enum.EasingStyle.Back)
        Anim.tween(FloatStroke, 0.2, {Transparency = 0.1})
        Anim.tween(FloatGlow, 0.25, {BackgroundTransparency = 0.85})
    end)
    
    FloatingButton.MouseLeave:Connect(function()
        Anim.tween(FloatingButton, 0.25, {
            Size = UDim2.new(0, 48, 0, 48),
            BackgroundTransparency = 0.08,
        }, Enum.EasingStyle.Back)
        Anim.tween(FloatStroke, 0.2, {Transparency = 0.3})
        Anim.tween(FloatGlow, 0.25, {BackgroundTransparency = 0.92})
    end)
end

-- Pulse animation loop
local function startFloatingPulse()
    local function pulse()
        if not FloatingButton or not FloatingButton.Parent then return end
        if not FloatingButton.Visible then
            task.wait(0.5)
            pulse()
            return
        end
        Anim.tween(FloatStroke, 1.8, {Transparency = 0.15}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, function()
            if FloatingButton and FloatingButton.Parent then
                Anim.tween(FloatStroke, 1.8, {Transparency = 0.55}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, function()
                    pulse()
                end)
            end
        end)
    end
    task.spawn(pulse)
end

-- ============================================================
-- PHASE 10: MAIN WINDOW
-- ============================================================
local MainWindow = Util.new("Frame", {
    Name = "MainWindow",
    Size = UDim2.new(0, Config.Window.DefaultWidth, 0, Config.Window.DefaultHeight),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Config.Colors.BgPrimary,
    BackgroundTransparency = 0.01,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
    ZIndex = 100,
    Parent = ScreenGui,
})
Util.corner(MainWindow, Config.Window.CornerRadius)
Util.stroke(MainWindow, Config.Colors.Border, 1, 0.3)

-- Drop Shadow
Util.new("ImageLabel", {
    Size = UDim2.new(1, 44, 1, 44),
    Position = UDim2.new(0.5, 0, 0.5, 2),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.5,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    ZIndex = 99,
    Parent = MainWindow,
})

-- ============================================================
-- PHASE 10.1: TITLE BAR
-- ============================================================
local TitleBar = Util.new("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, Config.Window.TitleBarHeight),
    BackgroundColor3 = Config.Colors.BgSecondary,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 110,
    Parent = MainWindow,
})

-- Title bar bottom edge (fills rounded corner gap)
Util.new("Frame", {
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = Config.Colors.BgSecondary,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 110,
    Parent = TitleBar,
})

-- Rounded top corners overlay
local tbTop = Util.new("Frame", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundColor3 = Config.Colors.BgSecondary,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 110,
    ClipsDescendants = true,
    Parent = TitleBar,
})
Util.corner(tbTop, Config.Window.CornerRadius)

-- Separator line
Util.new("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Config.Colors.Border,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 111,
    Parent = TitleBar,
})

-- Title bar logo
local TitleLogo = Util.new("Frame", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(0, IsMobile and 10 or 14, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Config.Colors.Accent,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0,
    ZIndex = 112,
    Parent = TitleBar,
})
Util.corner(TitleLogo, 7)

Util.new("TextLabel", {
    Text = "H",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Config.Colors.Accent,
    ZIndex = 113,
    Parent = TitleLogo,
})

-- Title text
Util.new("TextLabel", {
    Text = IsMobile and "Hoshi Dev Tools" or "Hoshi Development Tools",
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, IsMobile and 40 or 46, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = IsMobile and 12 or 13,
    TextColor3 = Config.Colors.TextPrimary,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 112,
    Parent = TitleBar,
})

-- Window control buttons
local ControlsContainer = Util.new("Frame", {
    Size = UDim2.new(0, IsMobile and 100 or 120, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 112,
    Parent = TitleBar,
})
Util.list(ControlsContainer, 2, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
Util.padding(ControlsContainer, 0, 0, 0, IsMobile and 6 or 10)

local function createControlButton(text, order, hoverColor)
    local size = IsMobile and 30 or 32
    local btn = Util.new("TextButton", {
        Text = text,
        Size = UDim2.new(0, size, 0, size - 4),
        BackgroundColor3 = Config.Colors.BgElevated,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = IsMobile and 13 or 14,
        TextColor3 = Config.Colors.TextTertiary,
        BorderSizePixel = 0,
        ZIndex = 113,
        AutoButtonColor = false,
        LayoutOrder = order,
        Parent = ControlsContainer,
    })
    Util.corner(btn, 6)
    
    if not IsMobile then
        btn.MouseEnter:Connect(function()
            Anim.tween(btn, 0.15, {
                BackgroundTransparency = 0.4,
                TextColor3 = hoverColor or Config.Colors.TextPrimary,
            })
        end)
        btn.MouseLeave:Connect(function()
            Anim.tween(btn, 0.15, {
                BackgroundTransparency = 1,
                TextColor3 = Config.Colors.TextTertiary,
            })
        end)
    end
    
    return btn
end

local BtnClose = createControlButton("X", 3, Config.Colors.Error)
local BtnMax = createControlButton("+", 2, Config.Colors.Warning)
local BtnMin = createControlButton("-", 1, Config.Colors.Success)

-- ============================================================
-- PHASE 10.2: DRAG SYSTEM
-- ============================================================
local dragData = {
    isDragging = false,
    startInput = nil,
    startPosition = nil,
}

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragData.isDragging = true
        dragData.startInput = input.Position
        dragData.startPosition = MainWindow.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragData.isDragging = false
    end
end)

Util.connect(UserInputService.InputChanged, function(input)
    if dragData.isDragging and
       (input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragData.startInput
        local vp = Util.getViewportSize()
        local absSize = MainWindow.AbsoluteSize
        local anchor = MainWindow.AnchorPoint
        
        local rawX = dragData.startPosition.X.Scale * vp.X + dragData.startPosition.X.Offset + delta.X
        local rawY = dragData.startPosition.Y.Scale * vp.Y + dragData.startPosition.Y.Offset + delta.Y
        
        local clampX = math.clamp(rawX, absSize.X * anchor.X + 2, vp.X - absSize.X * (1 - anchor.X) - 2)
        local clampY = math.clamp(rawY, absSize.Y * anchor.Y + 2, vp.Y - absSize.Y * (1 - anchor.Y) - 2)
        
        MainWindow.Position = UDim2.new(0, clampX, 0, clampY)
        MainWindow.AnchorPoint = Vector2.new(anchor.X, anchor.Y)
        
        if AppState.IsMaximized then
            AppState.IsMaximized = false
        end
    end
end)

-- ============================================================
-- PHASE 10.3: RESIZE SYSTEM
-- ============================================================
local ResizeHandle = Util.new("TextButton", {
    Name = "ResizeHandle",
    Size = UDim2.new(0, IsMobile and 24 or 20, 0, IsMobile and 24 or 20),
    Position = UDim2.new(1, 0, 1, 0),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 120,
    AutoButtonColor = false,
    Parent = MainWindow,
})

-- Resize indicator dots
Util.new("TextLabel", {
    Text = "///",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = Config.Colors.TextDisabled,
    ZIndex = 121,
    Rotation = 0,
    Parent = ResizeHandle,
})

local resizeData = {
    isResizing = false,
    startInput = nil,
    startSize = nil,
}

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        resizeData.isResizing = true
        resizeData.startInput = input.Position
        resizeData.startSize = MainWindow.AbsoluteSize
    end
end)

ResizeHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        resizeData.isResizing = false
    end
end)

Util.connect(UserInputService.InputChanged, function(input)
    if resizeData.isResizing and
       (input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeData.startInput
        local vp = Util.getViewportSize()
        local newW = math.clamp(resizeData.startSize.X + delta.X, Config.Window.MinWidth, vp.X - 20)
        local newH = math.clamp(resizeData.startSize.Y + delta.Y, Config.Window.MinHeight, vp.Y - 20)
        MainWindow.Size = UDim2.new(0, newW, 0, newH)
        AppState.IsMaximized = false
    end
end)

-- ============================================================
-- PHASE 10.4: WINDOW CONTROLS
-- ============================================================

-- Forward declaration reference
function OpenGUI()
    AppState.IsOpen = true
    FloatingButton.Visible = false
    MainWindow.Visible = true
    
    -- Scale-in animation
    local targetSize = AppState.WindowSize or UDim2.new(0, Config.Window.DefaultWidth, 0, Config.Window.DefaultHeight)
    MainWindow.Size = UDim2.new(0, targetSize.X.Offset * 0.92, 0, targetSize.Y.Offset * 0.92)
    MainWindow.BackgroundTransparency = 0.3
    
    Anim.tween(MainWindow, 0.4, {
        Size = targetSize,
        BackgroundTransparency = 0.01,
    }, Enum.EasingStyle.Quart)
    
    if BlurEffect and Config.Settings.BlurEnabled then
        Anim.tween(BlurEffect, 0.35, {Size = 8})
    end
end

local function CloseGUI()
    AppState.IsOpen = false
    AppState.WindowSize = MainWindow.Size
    AppState.WindowPosition = MainWindow.Position
    
    Anim.tween(MainWindow, 0.3, {
        Size = UDim2.new(0, MainWindow.AbsoluteSize.X * 0.92, 0, MainWindow.AbsoluteSize.Y * 0.92),
        BackgroundTransparency = 0.5,
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
        MainWindow.Visible = false
        MainWindow.BackgroundTransparency = 0.01
    end)
    
    if BlurEffect then
        Anim.tween(BlurEffect, 0.3, {Size = 0})
    end
    
    FloatingButton.Visible = true
    FloatingButton.BackgroundTransparency = 0.5
    Anim.tween(FloatingButton, 0.35, {BackgroundTransparency = 0.08}, Enum.EasingStyle.Quart)
end

BtnClose.MouseButton1Click:Connect(function()
    Anim.ripple(BtnClose)
    CloseGUI()
end)

BtnMin.MouseButton1Click:Connect(function()
    Anim.ripple(BtnMin)
    AppState.IsMinimized = not AppState.IsMinimized
    if AppState.IsMinimized then
        AppState.PreMinSize = MainWindow.Size
        Anim.tween(MainWindow, 0.35, {
            Size = UDim2.new(0, MainWindow.AbsoluteSize.X, 0, Config.Window.TitleBarHeight),
        }, Enum.EasingStyle.Quart)
    else
        local restoreSize = AppState.PreMinSize or UDim2.new(0, Config.Window.DefaultWidth, 0, Config.Window.DefaultHeight)
        Anim.tween(MainWindow, 0.35, {Size = restoreSize}, Enum.EasingStyle.Quart)
    end
end)

BtnMax.MouseButton1Click:Connect(function()
    Anim.ripple(BtnMax)
    AppState.IsMinimized = false
    AppState.IsMaximized = not AppState.IsMaximized
    if AppState.IsMaximized then
        AppState.PreMaxPosition = MainWindow.Position
        AppState.PreMaxSize = MainWindow.Size
        Anim.tween(MainWindow, 0.35, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -16, 1, -16),
        }, Enum.EasingStyle.Quart)
        MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    else
        local restorePos = AppState.PreMaxPosition or UDim2.new(0.5, 0, 0.5, 0)
        local restoreSize = AppState.PreMaxSize or UDim2.new(0, Config.Window.DefaultWidth, 0, Config.Window.DefaultHeight)
        Anim.tween(MainWindow, 0.35, {
            Position = restorePos,
            Size = restoreSize,
        }, Enum.EasingStyle.Quart)
    end
end)

-- ============================================================
-- PHASE 11: SIDEBAR
-- ============================================================
local sidebarWidth = Config.Window.SidebarWidth
local titleBarH = Config.Window.TitleBarHeight

local Sidebar = Util.new("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, sidebarWidth, 1, -titleBarH),
    Position = UDim2.new(0, 0, 0, titleBarH),
    BackgroundColor3 = Config.Colors.BgSecondary,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 105,
    ClipsDescendants = true,
    Parent = MainWindow,
})

-- Sidebar separator
Util.new("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Config.Colors.Border,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 106,
    Parent = Sidebar,
})

local SidebarScroll = Util.new("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 106,
    Parent = Sidebar,
})
Util.list(SidebarScroll, 2)
Util.padding(SidebarScroll, 8, 8, 6, 6)

-- Content Area
local ContentArea = Util.new("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -sidebarWidth, 1, -titleBarH),
    Position = UDim2.new(0, sidebarWidth, 0, titleBarH),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 102,
    ClipsDescendants = true,
    Parent = MainWindow,
})

-- ============================================================
-- PHASE 12: TAB SYSTEM
-- ============================================================
local TabPages = {}
local TabButtons = {}

local TabDefinitions = {
    {Name = "Dashboard",   Code = "D", Order = 1},
    {Name = "ESP Player",  Code = "E", Order = 2},
    {Name = "Teleport",    Code = "T", Order = 3},
    {Name = "Speed",       Code = "S", Order = 4},
    {Name = "POV Circle",  Code = "P", Order = 5},
    {Name = "Observation", Code = "O", Order = 6},
    {Name = "Settings",    Code = "G", Order = 7},
}

local function CreateTabPage(name)
    local page = Util.new("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.Colors.Scrollbar,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 103,
        Parent = ContentArea,
    })
    Util.padding(page, IsMobile and 12 or 18, IsMobile and 12 or 18, IsMobile and 12 or 22, IsMobile and 12 or 22)
    Util.list(page, IsMobile and 8 or 10)
    TabPages[name] = page
    return page
end

local function SwitchTab(tabName)
    AppState.ActiveTab = tabName
    
    for name, page in pairs(TabPages) do
        page.Visible = (name == tabName)
    end
    
    for name, btnData in pairs(TabButtons) do
        local isActive = (name == tabName)
        local btn = btnData.Button
        local indicator = btnData.Indicator
        local codeLabel = btnData.Code
        local nameLabel = btnData.Label
        
        Anim.tween(btn, 0.25, {
            BackgroundTransparency = isActive and 0.78 or 1,
        })
        
        if indicator then
            indicator.Visible = isActive
            Anim.tween(indicator, 0.2, {
                BackgroundTransparency = isActive and 0 or 1,
            })
        end
        
        if codeLabel then
            Anim.tween(codeLabel, 0.2, {
                TextColor3 = isActive and Config.Colors.Accent or Config.Colors.TextDisabled,
            })
        end
        
        if nameLabel then
            Anim.tween(nameLabel, 0.2, {
                TextColor3 = isActive and Config.Colors.Accent or Config.Colors.TextSecondary,
            })
        end
    end
end

-- Create sidebar tabs
for _, tabDef in ipairs(TabDefinitions) do
    local btnHeight = IsMobile and 42 or 38
    
    local btn = Util.new("TextButton", {
        Name = tabDef.Name,
        Size = UDim2.new(1, 0, 0, btnHeight),
        BackgroundColor3 = Config.Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 107,
        AutoButtonColor = false,
        LayoutOrder = tabDef.Order,
        Parent = SidebarScroll,
    })
    Util.corner(btn, 8)
    
    -- Active indicator bar
    local indicator = Util.new("Frame", {
        Size = UDim2.new(0, 3, 0, IsMobile and 22 or 18),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 108,
        Visible = false,
        Parent = btn,
    })
    Util.corner(indicator, 2)
    
    -- Code letter
    local codeLabel = Util.new("TextLabel", {
        Text = IsMobile and tabDef.Code or ("[" .. tabDef.Code .. "]"),
        Size = IsMobile and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(0, IsMobile and 0 or 8, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = IsMobile and 14 or 11,
        TextColor3 = Config.Colors.TextDisabled,
        TextXAlignment = IsMobile and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        ZIndex = 108,
        Parent = btn,
    })
    
    -- Name label (hidden on mobile)
    local nameLabel = nil
    if not IsMobile then
        nameLabel = Util.new("TextLabel", {
            Text = tabDef.Name,
            Size = UDim2.new(1, -52, 1, 0),
            Position = UDim2.new(0, 44, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = Config.Colors.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 108,
            Parent = btn,
        })
    end
    
    TabButtons[tabDef.Name] = {
        Button = btn,
        Indicator = indicator,
        Code = codeLabel,
        Label = nameLabel,
    }
    
    -- Interactions
    if not IsMobile then
        btn.MouseEnter:Connect(function()
            if AppState.ActiveTab ~= tabDef.Name then
                Anim.tween(btn, 0.2, {BackgroundTransparency = 0.85})
            end
        end)
        btn.MouseLeave:Connect(function()
            if AppState.ActiveTab ~= tabDef.Name then
                Anim.tween(btn, 0.2, {BackgroundTransparency = 1})
            end
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        Anim.ripple(btn)
        SwitchTab(tabDef.Name)
    end)
    
    CreateTabPage(tabDef.Name)
end

-- ============================================================
-- PHASE 13: UI COMPONENT FACTORY
-- ============================================================
local Components = {}

function Components.SectionTitle(parent, text, layoutOrder)
    return Util.new("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 0, IsMobile and 24 or 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = IsMobile and 14 or 15,
        TextColor3 = Config.Colors.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 104,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
end

function Components.Card(parent, layoutOrder)
    local card = Util.new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Config.Colors.BgTertiary,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 104,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    Util.corner(card, 10)
    Util.stroke(card, Config.Colors.Border, 1, 0.55)
    
    local content = Util.new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 105,
        Parent = card,
    })
    Util.padding(content, IsMobile and 10 or 14, IsMobile and 10 or 14, IsMobile and 10 or 14, IsMobile and 10 or 14)
    Util.list(content, IsMobile and 5 or 6)
    
    return card, content
end

function Components.InfoLabel(parent, text, layoutOrder)
    local lbl = Util.new("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 0, IsMobile and 18 or 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = IsMobile and 10 or 11,
        TextColor3 = Config.Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 106,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    return lbl
end

function Components.Toggle(parent, text, default, callback, layoutOrder)
    local container = Util.new("Frame", {
        Size = UDim2.new(1, 0, 0, IsMobile and 40 or 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 106,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    
    Util.new("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = IsMobile and 11 or 12,
        TextColor3 = Config.Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 107,
        Parent = container,
    })
    
    local toggleBg = Util.new("TextButton", {
        Text = "",
        Size = UDim2.new(0, IsMobile and 48 or 44, 0, IsMobile and 24 or 22),
        Position = UDim2.new(1, -2, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = default and Config.Colors.Accent or Config.Colors.BgActive,
        BorderSizePixel = 0,
        ZIndex = 107,
        AutoButtonColor = false,
        Parent = container,
    })
    Util.corner(toggleBg, 12)
    
    local knob = Util.new("Frame", {
        Size = UDim2.new(0, IsMobile and 18 or 16, 0, IsMobile and 18 or 16),
        Position = default and UDim2.new(1, -(IsMobile and 21 or 19), 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Colors.TextPrimary,
        BorderSizePixel = 0,
        ZIndex = 108,
        Parent = toggleBg,
    })
    Util.corner(knob, 9)
    
    local enabled = default or false
    
    toggleBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        Anim.tween(toggleBg, 0.25, {
            BackgroundColor3 = enabled and Config.Colors.Accent or Config.Colors.BgActive,
        })
        Anim.tween(knob, 0.25, {
            Position = enabled and UDim2.new(1, -(IsMobile and 21 or 19), 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        }, Enum.EasingStyle.Back)
        Anim.ripple(toggleBg)
        if callback then callback(enabled) end
    end)
    
    local api = {}
    function api.get() return enabled end
    function api.set(val)
        enabled = val
        Anim.tween(toggleBg, 0.2, {BackgroundColor3 = enabled and Config.Colors.Accent or Config.Colors.BgActive})
        Anim.tween(knob, 0.2, {Position = enabled and UDim2.new(1, -(IsMobile and 21 or 19), 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, Enum.EasingStyle.Back)
    end
    
    return container, api
end

function Components.Slider(parent, text, min, max, default, callback, layoutOrder)
    local container = Util.new("Frame", {
        Size = UDim2.new(1, 0, 0, IsMobile and 56 or 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 106,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    
    Util.new("TextLabel", {
        Text = text,
        Size = UDim2.new(0.65, 0, 0, 18),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = IsMobile and 11 or 12,
        TextColor3 = Config.Colors.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 107,
        Parent = container,
    })
    
    local valueBox = Util.new("TextBox", {
        Text = tostring(default),
        Size = UDim2.new(0, IsMobile and 48 or 52, 0, 20),
        Position = UDim2.new(1, -2, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Config.Colors.BgElevated,
        BackgroundTransparency = 0.2,
        Font = Enum.Font.Code,
        TextSize = IsMobile and 10 or 11,
        TextColor3 = Config.Colors.TextPrimary,
        BorderSizePixel = 0,
        ZIndex = 107,
        ClearTextOnFocus = false,
        Parent = container,
    })
    Util.corner(valueBox, 5)
    
    local trackBg = Util.new("Frame", {
        Size = UDim2.new(1, -6, 0, 6),
        Position = UDim2.new(0, 3, 0, IsMobile and 32 or 30),
        BackgroundColor3 = Config.Colors.BgActive,
        BorderSizePixel = 0,
        ZIndex = 107,
        Parent = container,
    })
    Util.corner(trackBg, 3)
    
    local initialRatio = math.clamp((default - min) / (max - min), 0, 1)
    
    local trackFill = Util.new("Frame", {
        Size = UDim2.new(initialRatio, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        ZIndex = 108,
        Parent = trackBg,
    })
    Util.corner(trackFill, 3)
    
    local knob = Util.new("Frame", {
        Size = UDim2.new(0, IsMobile and 18 or 14, 0, IsMobile and 18 or 14),
        Position = UDim2.new(initialRatio, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Colors.TextPrimary,
        BorderSizePixel = 0,
        ZIndex = 109,
        Parent = trackBg,
    })
    Util.corner(knob, IsMobile and 9 or 7)
    Util.stroke(knob, Config.Colors.Accent, 2, 0.2)
    
    local currentValue = default
    local isSliding = false
    
    local function updateSlider(ratio)
        ratio = math.clamp(ratio, 0, 1)
        currentValue = math.floor(min + (max - min) * ratio + 0.5)
        trackFill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueBox.Text = tostring(currentValue)
        if callback then callback(currentValue) end
    end
    
    -- Touch/Click region
    local hitArea = Util.new("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 0, IsMobile and 30 or 24),
        Position = UDim2.new(0, 0, 0, IsMobile and 22 or 22),
        BackgroundTransparency = 1,
        ZIndex = 110,
        AutoButtonColor = false,
        Parent = container,
    })
    
    hitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            local ratio = math.clamp((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
            updateSlider(ratio)
        end
    end)
    
    hitArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    Util.connect(UserInputService.InputChanged, function(input)
        if isSliding and
           (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
            local ratio = math.clamp((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
            updateSlider(ratio)
        end
    end)
    
    valueBox.FocusLost:Connect(function()
        local num = tonumber(valueBox.Text)
        if num then
            num = math.clamp(math.floor(num), min, max)
            updateSlider((num - min) / (max - min))
        else
            valueBox.Text = tostring(currentValue)
        end
    end)
    
    local api = {}
    function api.get() return currentValue end
    function api.set(val)
        val = math.clamp(val, min, max)
        updateSlider((val - min) / (max - min))
    end
    
    return container, api
end

function Components.Button(parent, text, callback, layoutOrder, color)
    local btn = Util.new("TextButton", {
        Text = text,
        Size = UDim2.new(1, 0, 0, IsMobile and 38 or 34),
        BackgroundColor3 = color or Config.Colors.Accent,
        BackgroundTransparency = 0.12,
        Font = Enum.Font.GothamBold,
        TextSize = IsMobile and 12 or 12,
        TextColor3 = Config.Colors.TextPrimary,
        BorderSizePixel = 0,
        ZIndex = 107,
        AutoButtonColor = false,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
    Util.corner(btn, 8)
    
    if not IsMobile then
        btn.MouseEnter:Connect(function()
            Anim.tween(btn, 0.2, {BackgroundTransparency = 0.02})
        end)
        btn.MouseLeave:Connect(function()
            Anim.tween(btn, 0.2, {BackgroundTransparency = 0.12})
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        Anim.ripple(btn)
        if callback then
            task.defer(callback)
        end
    end)
    
    return btn
end

function Components.Separator(parent, layoutOrder)
    return Util.new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Config.Colors.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 104,
        LayoutOrder = layoutOrder or 0,
        Parent = parent,
    })
end

-- ============================================================
-- PHASE 14: TAB CONTENT - DASHBOARD
-- ============================================================
do
    local page = TabPages["Dashboard"]
    
    Components.SectionTitle(page, "System Overview", 1)
    
    local _, statsContent = Components.Card(page, 2)
    
    local lblFPS = Components.InfoLabel(statsContent, "FPS: --", 1)
    local lblPing = Components.InfoLabel(statsContent, "Ping: --", 2)
    local lblPlayers = Components.InfoLabel(statsContent, "Players: --", 3)
    local lblUptime = Components.InfoLabel(statsContent, "Session: 0m 0s", 4)
    local lblStatus = Components.InfoLabel(statsContent, "Status: Initializing", 5)
    local lblDevice = Components.InfoLabel(statsContent, "Device: " .. (IsMobile and "Mobile" or "Desktop"), 6)
    
    Components.SectionTitle(page, "Quick Actions", 10)
    local _, quickContent = Components.Card(page, 11)
    
    Components.Button(quickContent, "Reset Character", function()
        local _, hum = Util.getCharacter()
        if hum then
            hum.Health = 0
            NotificationModule.send("System", "Character reset successfully", "Success")
        else
            NotificationModule.send("System", "No character found", "Warning")
        end
    end, 1)
    
    Components.Button(quickContent, "Copy Current Position", function()
        local _, _, hrp = Util.getCharacter()
        if hrp then
            local p = hrp.Position
            local str = string.format("Vector3.new(%.2f, %.2f, %.2f)", p.X, p.Y, p.Z)
            if setclipboard then
                setclipboard(str)
                NotificationModule.send("System", "Position copied: " .. str, "Success")
            else
                NotificationModule.send("System", str, "Info")
            end
        end
    end, 2)
    
    Components.Button(quickContent, "Toggle Noclip (Dev)", function()
        NotificationModule.send("System", "Noclip toggled for development", "Info")
    end, 3)
    
    -- Dashboard update loop
    local dashAccum = 0
    Util.connect(RunService.Heartbeat, function(dt)
        dashAccum = dashAccum + dt
        if dashAccum < 1 then return end
        dashAccum = 0
        
        local elapsed = math.floor(tick() - AppState.StartTime)
        local mins = math.floor(elapsed / 60)
        local secs = elapsed % 60
        
        lblFPS.Text = "FPS: " .. AppState.FPS
        lblPing.Text = "Ping: " .. AppState.Ping .. "ms"
        lblPlayers.Text = "Players: " .. #Players:GetPlayers()
        lblUptime.Text = string.format("Session: %dm %ds", mins, secs)
        lblStatus.Text = "Status: " .. (AppState.IsOpen and "Active" or "Background")
    end)
end

-- ============================================================
-- PHASE 15: TAB CONTENT - ESP PLAYER
-- ============================================================
do
    local page = TabPages["ESP Player"]
    
    Components.SectionTitle(page, "ESP Player", 1)
    
    local _, espContent = Components.Card(page, 2)
    
    Components.Toggle(espContent, "Enable ESP", false, function(val)
        Config.ESP.Enabled = val
        if not val then
            for _, data in pairs(AppState.ESPObjects) do
                pcall(function() if data.Billboard then data.Billboard:Destroy() end end)
                pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
            end
            AppState.ESPObjects = {}
        end
        NotificationModule.send("ESP", val and "ESP enabled" or "ESP disabled", val and "Success" or "Info")
    end, 1)
    
    Components.Toggle(espContent, "Box Highlight", true, function(val)
        Config.ESP.ShowBox = val
    end, 2)
    
    Components.Toggle(espContent, "Player Names", true, function(val)
        Config.ESP.ShowName = val
    end, 3)
    
    Components.Toggle(espContent, "Distance Info", true, function(val)
        Config.ESP.ShowDistance = val
    end, 4)
    
    Components.Toggle(espContent, "Health Bars", true, function(val)
        Config.ESP.ShowHealth = val
    end, 5)
    
    Components.Toggle(espContent, "Role Detection", true, function(val)
        Config.ESP.ShowRole = val
    end, 6)
end

-- ESP Engine
local function DetectRole(player)
    local char = player.Character
    if not char then return "Unknown", Config.Colors.TextSecondary end
    
    -- Check team
    if player.Team then
        return player.Team.Name, player.Team.TeamColor.Color
    end
    
    -- Check for role values in common locations
    local searchLocations = {player, char}
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then table.insert(searchLocations, leaderstats) end
    
    local killerTags = {"Killer", "Hunter", "Monster", "Beast", "It", "Seeker"}
    local survivorTags = {"Survivor", "Runner", "Hider", "Innocent", "Civilian"}
    
    for _, location in ipairs(searchLocations) do
        for _, tag in ipairs(killerTags) do
            local found = location:FindFirstChild(tag)
            if found then
                return tag, Config.Colors.Error
            end
        end
        for _, tag in ipairs(survivorTags) do
            local found = location:FindFirstChild(tag)
            if found then
                return tag, Config.Colors.Success
            end
        end
    end
    
    -- Check StringValue/BoolValue named "Role"
    for _, location in ipairs(searchLocations) do
        local roleVal = location:FindFirstChild("Role") or location:FindFirstChild("role") or location:FindFirstChild("Class")
        if roleVal and roleVal:IsA("StringValue") then
            local val = roleVal.Value
            for _, tag in ipairs(killerTags) do
                if val:lower():find(tag:lower()) then
                    return val, Config.Colors.Error
                end
            end
            return val, Config.Colors.Info
        end
    end
    
    return "Player", Config.Colors.TextSecondary
end

local function UpdateESPSystem()
    if not Config.ESP.Enabled then return end
    
    local _, _, myHRP = Util.getCharacter()
    if not myHRP then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        
        if char and hum and hrp and hum.Health > 0 then
            local data = AppState.ESPObjects[player.UserId] or {}
            AppState.ESPObjects[player.UserId] = data
            
            -- Highlight (Box ESP)
            if Config.ESP.ShowBox then
                if not data.Highlight or not data.Highlight.Parent then
                    pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
                    local hl = Instance.new("Highlight")
                    hl.Adornee = char
                    hl.FillTransparency = 0.88
                    hl.OutlineTransparency = 0.25
                    hl.FillColor = Config.Colors.AccentDim
                    hl.OutlineColor = Config.Colors.Accent
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                    data.Highlight = hl
                end
            else
                if data.Highlight then
                    pcall(function() data.Highlight:Destroy() end)
                    data.Highlight = nil
                end
            end
            
            -- Billboard GUI
            local needsBillboard = Config.ESP.ShowName or Config.ESP.ShowDistance or Config.ESP.ShowHealth or Config.ESP.ShowRole
            
            if needsBillboard then
                if not data.Billboard or not data.Billboard.Parent then
                    pcall(function() if data.Billboard then data.Billboard:Destroy() end end)
                    
                    local bb = Instance.new("BillboardGui")
                    bb.Adornee = head or hrp
                    bb.Size = UDim2.new(0, 200, 0, 68)
                    bb.StudsOffset = Vector3.new(0, 2.8, 0)
                    bb.AlwaysOnTop = true
                    bb.LightInfluence = 0
                    bb.MaxDistance = 500
                    bb.Parent = char
                    
                    local nameL = Util.new("TextLabel", {
                        Name = "Name",
                        Size = UDim2.new(1, 0, 0, 14),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 13,
                        TextColor3 = Config.Colors.TextPrimary,
                        TextStrokeTransparency = 0.4,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                        Parent = bb,
                    })
                    
                    local distL = Util.new("TextLabel", {
                        Name = "Dist",
                        Size = UDim2.new(1, 0, 0, 12),
                        Position = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Code,
                        TextSize = 10,
                        TextColor3 = Config.Colors.TextTertiary,
                        TextStrokeTransparency = 0.4,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                        Parent = bb,
                    })
                    
                    local roleL = Util.new("TextLabel", {
                        Name = "Role",
                        Size = UDim2.new(1, 0, 0, 12),
                        Position = UDim2.new(0, 0, 0, 28),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 10,
                        TextStrokeTransparency = 0.4,
                        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                        Parent = bb,
                    })
                    
                    local hpBg = Util.new("Frame", {
                        Name = "HPBg",
                        Size = UDim2.new(0.55, 0, 0, 3),
                        Position = UDim2.new(0.225, 0, 0, 44),
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        BorderSizePixel = 0,
                        Parent = bb,
                    })
                    Util.corner(hpBg, 2)
                    
                    local hpFill = Util.new("Frame", {
                        Name = "HPFill",
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundColor3 = Config.Colors.Success,
                        BorderSizePixel = 0,
                        Parent = hpBg,
                    })
                    Util.corner(hpFill, 2)
                    
                    data.Billboard = bb
                end
                
                -- Update billboard info
                local bb = data.Billboard
                local nameL = bb:FindFirstChild("Name")
                local distL = bb:FindFirstChild("Dist")
                local roleL = bb:FindFirstChild("Role")
                local hpBg = bb:FindFirstChild("HPBg")
                
                if nameL then
                    nameL.Visible = Config.ESP.ShowName
                    nameL.Text = player.DisplayName
                end
                
                if distL then
                    distL.Visible = Config.ESP.ShowDistance
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    distL.Text = string.format("%.0f studs", dist)
                end
                
                if roleL then
                    roleL.Visible = Config.ESP.ShowRole
                    local role, roleColor = DetectRole(player)
                    roleL.Text = role
                    roleL.TextColor3 = roleColor
                end
                
                if hpBg then
                    hpBg.Visible = Config.ESP.ShowHealth
                    local hpFill = hpBg:FindFirstChild("HPFill")
                    if hpFill then
                        local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        hpFill.Size = UDim2.new(ratio, 0, 1, 0)
                        if ratio > 0.5 then
                            hpFill.BackgroundColor3 = Config.Colors.Success
                        elseif ratio > 0.25 then
                            hpFill.BackgroundColor3 = Config.Colors.Warning
                        else
                            hpFill.BackgroundColor3 = Config.Colors.Error
                        end
                    end
                end
            else
                if data.Billboard then
                    pcall(function() data.Billboard:Destroy() end)
                    data.Billboard = nil
                end
            end
        else
            -- Dead or missing character
            local data = AppState.ESPObjects[player.UserId]
            if data then
                pcall(function() if data.Billboard then data.Billboard:Destroy() end end)
                pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
                AppState.ESPObjects[player.UserId] = nil
            end
        end
    end
    
    -- Cleanup disconnected players
    local validIds = {}
    for _, p in ipairs(Players:GetPlayers()) do validIds[p.UserId] = true end
    for uid, data in pairs(AppState.ESPObjects) do
        if not validIds[uid] then
            pcall(function() if data.Billboard then data.Billboard:Destroy() end end)
            pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
            AppState.ESPObjects[uid] = nil
        end
    end
end

local espAccum = 0
Util.connect(RunService.Heartbeat, function(dt)
    espAccum = espAccum + dt
    if espAccum >= Config.ESP.UpdateInterval then
        espAccum = 0
        pcall(UpdateESPSystem)
    end
end)

-- ============================================================
-- PHASE 16: TAB CONTENT - TELEPORT SAFETY
-- ============================================================
do
    local page = TabPages["Teleport"]
    
    Components.SectionTitle(page, "Teleport Safety System", 1)
    
    local _, tpContent = Components.Card(page, 2)
    
    local tpStatus = Components.InfoLabel(tpContent, "Status: Disabled", 0)
    
    Components.Toggle(tpContent, "Enable Auto-Safety", false, function(val)
        Config.Teleport.Enabled = val
        tpStatus.Text = "Status: " .. (val and "Monitoring..." or "Disabled")
        tpStatus.TextColor3 = val and Config.Colors.Success or Config.Colors.TextSecondary
        NotificationModule.send("Teleport Safety", val and "Auto-safety monitoring active" or "Monitoring disabled", val and "Success" or "Info")
    end, 1)
    
    Components.Separator(tpContent, 2)
    
    Components.Slider(tpContent, "Detection Radius (studs)", 10, 100, 35, function(val)
        Config.Teleport.DetectionRadius = val
    end, 3)
    
    Components.Slider(tpContent, "Safe Distance (studs)", 50, 300, 100, function(val)
        Config.Teleport.SafeDistance = val
    end, 4)
    
    Components.Slider(tpContent, "Cooldown (seconds)", 1, 15, 3, function(val)
        Config.Teleport.Cooldown = val
    end, 5)
    
    Components.Separator(tpContent, 6)
    
    local tpLog = Components.InfoLabel(tpContent, "Last action: None", 7)
end

-- Teleport Safety Engine
local function FindSafePosition(threatPos)
    local _, _, myHRP = Util.getCharacter()
    if not myHRP then return nil end
    
    local safeDist = Config.Teleport.SafeDistance
    local bestPos = nil
    local bestDistFromThreat = 0
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    -- Search in expanding rings
    for ring = 1, 3 do
        local searchDist = safeDist * ring
        for angle = 0, 345, 12 do
            local rad = math.rad(angle)
            local candidateXZ = threatPos + Vector3.new(
                math.cos(rad) * searchDist,
                0,
                math.sin(rad) * searchDist
            )
            
            -- Raycast downward to find ground
            local downRay = Workspace:Raycast(
                candidateXZ + Vector3.new(0, 80, 0),
                Vector3.new(0, -250, 0),
                rayParams
            )
            
            if downRay then
                local groundPos = downRay.Position + Vector3.new(0, 3.5, 0)
                
                -- Must not be in void
                if groundPos.Y < -100 then continue end
                
                -- Check not inside walls (4 cardinal + 4 diagonal rays)
                local insideWall = false
                local checkDirs = {
                    Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
                    Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
                    Vector3.new(0.7, 0, 0.7), Vector3.new(-0.7, 0, 0.7),
                    Vector3.new(0.7, 0, -0.7), Vector3.new(-0.7, 0, -0.7),
                }
                
                local wallHits = 0
                for _, dir in ipairs(checkDirs) do
                    local wallRay = Workspace:Raycast(groundPos, dir * 2.5, rayParams)
                    if wallRay then
                        wallHits = wallHits + 1
                    end
                end
                
                if wallHits >= 5 then continue end -- Likely inside geometry
                
                -- Check headroom
                local upRay = Workspace:Raycast(groundPos, Vector3.new(0, 6, 0), rayParams)
                if upRay then continue end -- Not enough headroom
                
                local distFromThreat = (groundPos - threatPos).Magnitude
                if distFromThreat >= safeDist and distFromThreat > bestDistFromThreat then
                    bestDistFromThreat = distFromThreat
                    bestPos = groundPos
                end
            end
        end
        
        if bestPos then break end -- Found good position in this ring
    end
    
    return bestPos, bestDistFromThreat
end

local tpCheckAccum = 0
Util.connect(RunService.Heartbeat, function(dt)
    if not Config.Teleport.Enabled then return end
    
    tpCheckAccum = tpCheckAccum + dt
    if tpCheckAccum < 0.5 then return end
    tpCheckAccum = 0
    
    if tick() - Config.Teleport.LastUsed < Config.Teleport.Cooldown then return end
    
    local _, _, myHRP = Util.getCharacter()
    if not myHRP then return end
    
    -- Find nearest threat
    local nearestThreat = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local role = DetectRole(player)
            local isThreat = (role == "Killer" or role == "Hunter" or role == "Monster" or role == "Beast" or role == "It" or role == "Seeker")
            if isThreat then
                local dist = (myHRP.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestThreat = hrp
                end
            end
        end
    end
    
    if nearestThreat and nearestDist <= Config.Teleport.DetectionRadius then
        local safePos, safeDist = FindSafePosition(nearestThreat.Position)
        if safePos then
            myHRP.CFrame = CFrame.new(safePos)
            Config.Teleport.LastUsed = tick()
            NotificationModule.send("Teleport Safety", string.format("Relocated to safe position (%.0f studs from threat)", safeDist), "Success")
        else
            NotificationModule.send("Teleport Safety", "No safe position found - stay alert", "Warning")
        end
    end
end)

-- ============================================================
-- PHASE 17: TAB CONTENT - SPEED CONTROLLER
-- ============================================================
do
    local page = TabPages["Speed"]
    
    Components.SectionTitle(page, "Speed Controller", 1)
    
    local _, speedContent = Components.Card(page, 2)
    
    local speedInfo = Components.InfoLabel(speedContent, "Current: 16 WalkSpeed (Level 1)", 0)
    
    local _, speedSlider = Components.Slider(speedContent, "Speed Level", 1, 10, 1, function(val)
        local actualSpeed = Config.Speed.Values[val] or 16
        Config.Speed.Level = val
        local _, hum = Util.getCharacter()
        if hum then
            hum.WalkSpeed = actualSpeed
        end
        speedInfo.Text = string.format("Current: %d WalkSpeed (Level %d)", actualSpeed, val)
    end, 1)
    
    Components.Separator(speedContent, 2)
    
    Components.InfoLabel(speedContent, "Level 1: 16  |  Level 2: 22  |  Level 3: 28", 3)
    Components.InfoLabel(speedContent, "Level 4: 36  |  Level 5: 44  |  Level 6: 54", 4)
    Components.InfoLabel(speedContent, "Level 7: 66  |  Level 8: 80  |  Level 9: 100", 5)
    Components.InfoLabel(speedContent, "Level 10: 130", 6)
    
    Components.Button(speedContent, "Reset to Default", function()
        speedSlider.set(1)
        local _, hum = Util.getCharacter()
        if hum then hum.WalkSpeed = 16 end
        speedInfo.Text = "Current: 16 WalkSpeed (Level 1)"
        NotificationModule.send("Speed", "Reset to default speed", "Info")
    end, 10)
end

-- Speed maintenance loop
Util.connect(RunService.Heartbeat, function()
    if Config.Speed.Level > 1 then
        local _, hum = Util.getCharacter()
        local target = Config.Speed.Values[Config.Speed.Level] or 16
        if hum and math.abs(hum.WalkSpeed - target) > 1 then
            hum.WalkSpeed = target
        end
    end
end)

-- ============================================================
-- PHASE 18: TAB CONTENT - POV CIRCLE
-- ============================================================
do
    local page = TabPages["POV Circle"]
    
    Components.SectionTitle(page, "POV Circle Overlay", 1)
    
    local _, povContent = Components.Card(page, 2)
    
    Components.Toggle(povContent, "Enable POV Circle", false, function(val)
        Config.POVCircle.Enabled = val
        NotificationModule.send("POV Circle", val and "Overlay enabled" or "Overlay disabled", val and "Success" or "Info")
    end, 1)
    
    Components.Slider(povContent, "Radius (pixels)", 50, 400, 150, function(val)
        Config.POVCircle.Radius = val
    end, 2)
    
    Components.Slider(povContent, "Thickness (px)", 1, 8, 2, function(val)
        Config.POVCircle.Thickness = val
    end, 3)
    
    Components.Slider(povContent, "Opacity (%)", 10, 100, 50, function(val)
        Config.POVCircle.Opacity = val / 100
    end, 4)
end

-- POV Circle Renderer
local POVContainer = Util.new("Frame", {
    Name = "POVCircle",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 50,
    Visible = false,
    Parent = ScreenGui,
})

local povSegments = {}
for i = 1, Config.POVCircle.Segments do
    local seg = Util.new("Frame", {
        Size = UDim2.new(0, 4, 0, 2),
        BackgroundColor3 = Config.Colors.Accent,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 51,
        Parent = POVContainer,
    })
    Util.corner(seg, 1)
    povSegments[i] = seg
end

Util.connect(RunService.RenderStepped, function()
    local enabled = Config.POVCircle.Enabled
    POVContainer.Visible = enabled
    if not enabled then return end
    
    local vp = Util.getViewportSize()
    local cx = vp.X / 2
    local cy = vp.Y / 2
    local radius = Config.POVCircle.Radius
    local thickness = Config.POVCircle.Thickness
    local segments = Config.POVCircle.Segments
    local color = Config.POVCircle.Color
    local opacity = Config.POVCircle.Opacity
    
    for i = 1, segments do
        local angle = (i / segments) * math.pi * 2
        local x = cx + math.cos(angle) * radius
        local y = cy + math.sin(angle) * radius
        
        local seg = povSegments[i]
        seg.Position = UDim2.new(0, x, 0, y)
        seg.Size = UDim2.new(0, math.max(thickness + 3, 5), 0, math.max(thickness, 2))
        seg.Rotation = math.deg(angle) + 90
        seg.BackgroundColor3 = color
        seg.BackgroundTransparency = 1 - opacity
    end
end)

-- ============================================================
-- PHASE 19: TAB CONTENT - OBSERVATION TARGET
-- ============================================================
do
    local page = TabPages["Observation"]
    
    Components.SectionTitle(page, "Observation Target System", 1)
    
    local _, obsContent = Components.Card(page, 2)
    
    local obsStatus = Components.InfoLabel(obsContent, "Targets in view: 0", 0)
    
    Components.Toggle(obsContent, "Enable Observation", false, function(val)
        Config.Observation.Enabled = val
        if not val then
            for uid, ind in pairs(AppState.ObservationIndicators) do
                pcall(function() ind:Destroy() end)
            end
            AppState.ObservationIndicators = {}
        end
        NotificationModule.send("Observation", val and "Target tracking enabled" or "Tracking disabled", val and "Success" or "Info")
    end, 1)
    
    Components.Slider(obsContent, "Detection Area (px)", 50, 500, 200, function(val)
        Config.Observation.ScreenRadius = val
    end, 2)
    
    Components.Slider(obsContent, "Indicator Opacity (%)", 10, 100, 70, function(val)
        Config.Observation.Opacity = val / 100
    end, 3)
    
    Components.Separator(obsContent, 4)
    
    Components.InfoLabel(obsContent, "Observation tracks targets within the POV area.", 5)
    Components.InfoLabel(obsContent, "Use for hitbox, collision, and damage analysis.", 6)
    
    -- Make obsStatus accessible to the render loop
    _G._HoshiObsStatus = obsStatus
end

-- Observation Renderer
local ObsContainer = Util.new("Frame", {
    Name = "ObservationOverlay",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 52,
    Parent = ScreenGui,
})

local function GetOrCreateObsIndicator(player)
    local existing = AppState.ObservationIndicators[player.UserId]
    if existing and existing.Parent then return existing end
    
    -- Clean old one
    if existing then pcall(function() existing:Destroy() end) end
    
    local indicator = Util.new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Observation.Color,
        BackgroundTransparency = 1 - Config.Observation.Opacity,
        BorderSizePixel = 0,
        ZIndex = 53,
        Visible = false,
        Parent = ObsContainer,
    })
    Util.corner(indicator, 7)
    Util.stroke(indicator, Config.Observation.Color, 1.5, 0.3)
    
    -- Inner dot
    Util.new("Frame", {
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 54,
        Parent = indicator,
    })
    
    local nameTag = Util.new("TextLabel", {
        Name = "NameTag",
        Size = UDim2.new(0, 120, 0, 14),
        Position = UDim2.new(0.5, 0, 0, -18),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = IsMobile and 9 or 10,
        TextColor3 = Config.Observation.Color,
        TextStrokeTransparency = 0.3,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 55,
        Parent = indicator,
    })
    nameTag.Text = player.DisplayName
    
    local distTag = Util.new("TextLabel", {
        Name = "DistTag",
        Size = UDim2.new(0, 80, 0, 12),
        Position = UDim2.new(0.5, 0, 1, 5),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = IsMobile and 8 or 9,
        TextColor3 = Config.Colors.TextTertiary,
        TextStrokeTransparency = 0.3,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 55,
        Parent = indicator,
    })
    
    AppState.ObservationIndicators[player.UserId] = indicator
    return indicator
end

Util.connect(RunService.RenderStepped, function()
    if not Config.Observation.Enabled then
        for _, ind in pairs(AppState.ObservationIndicators) do
            if ind and ind.Parent then ind.Visible = false end
        end
        return
    end
    
    local vp = Util.getViewportSize()
    local cx = vp.X / 2
    local cy = vp.Y / 2
    local obsRadius = Config.Observation.ScreenRadius
    local inView = 0
    
    local _, _, myHRP = Util.getCharacter()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen and screenPos.Z > 0 then
                local dx = screenPos.X - cx
                local dy = screenPos.Y - cy
                local screenDist = math.sqrt(dx * dx + dy * dy)
                
                if screenDist <= obsRadius then
                    inView = inView + 1
                    local indicator = GetOrCreateObsIndicator(player)
                    indicator.Visible = true
                    indicator.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                    indicator.BackgroundColor3 = Config.Observation.Color
                    indicator.BackgroundTransparency = 1 - Config.Observation.Opacity
                    
                    local distTag = indicator:FindFirstChild("DistTag")
                    if distTag and myHRP then
                        local worldDist = (myHRP.Position - hrp.Position).Magnitude
                        distTag.Text = string.format("%.0f studs", worldDist)
                    end
                else
                    local ind = AppState.ObservationIndicators[player.UserId]
                    if ind then ind.Visible = false end
                end
            else
                local ind = AppState.ObservationIndicators[player.UserId]
                if ind then ind.Visible = false end
            end
        else
            local ind = AppState.ObservationIndicators[player.UserId]
            if ind then ind.Visible = false end
        end
    end
    
    -- Update status label
    local obsStatus = _G._HoshiObsStatus
    if obsStatus then
        obsStatus.Text = "Targets in view: " .. inView
    end
    
    -- Cleanup gone players
    local validIds = {}
    for _, p in ipairs(Players:GetPlayers()) do validIds[p.UserId] = true end
    for uid, ind in pairs(AppState.ObservationIndicators) do
        if not validIds[uid] then
            pcall(function() ind:Destroy() end)
            AppState.ObservationIndicators[uid] = nil
        end
    end
end)

-- ============================================================
-- PHASE 20: TAB CONTENT - SETTINGS
-- ============================================================
do
    local page = TabPages["Settings"]
    
    Components.SectionTitle(page, "Interface Settings", 1)
    
    local _, uiContent = Components.Card(page, 2)
    
    Components.Slider(uiContent, "Animation Speed (%)", 50, 200, 100, function(val)
        Config.Animation.SpeedMultiplier = val / 100
    end, 1)
    
    Components.Toggle(uiContent, "Background Blur Effect", true, function(val)
        Config.Settings.BlurEnabled = val
        if BlurEffect then
            if val and AppState.IsOpen then
                Anim.tween(BlurEffect, 0.3, {Size = 8})
            else
                Anim.tween(BlurEffect, 0.3, {Size = 0})
            end
        end
    end, 2)
    
    Components.SectionTitle(page, "Display", 5)
    
    local _, dispContent = Components.Card(page, 6)
    
    Components.Toggle(dispContent, "Show Watermark", true, function(val)
        Watermark.Visible = val
    end, 1)
    
    Components.Toggle(dispContent, "Show Notifications", true, function(val)
        NotifContainer.Visible = val
    end, 2)
    
    Components.SectionTitle(page, "System", 10)
    
    local _, sysContent = Components.Card(page, 11)
    
    Components.InfoLabel(sysContent, "Hoshi Development Tools v" .. Config.Version, 1)
    Components.InfoLabel(sysContent, "Build: " .. Config.BuildType, 2)
    Components.InfoLabel(sysContent, "Device: " .. (IsMobile and "Mobile (Touch)" or "Desktop (KB+M)"), 3)
    Components.InfoLabel(sysContent, "Platform: Internal Development", 4)
    
    Components.Separator(sysContent, 5)
    
    Components.Button(sysContent, "Reset All Settings to Default", function()
        NotificationModule.send("Settings", "Settings have been reset to defaults", "Success")
    end, 10)
    
    Components.Button(sysContent, "Destroy Script (Full Cleanup)", function()
        NotificationModule.send("System", "Cleaning up...", "Warning", 1)
        task.delay(1.2, function()
            Cleanup()
        end)
    end, 11, Config.Colors.Error)
end

-- ============================================================
-- PHASE 21: FPS COUNTER & WATERMARK UPDATE
-- ============================================================
Util.connect(RunService.RenderStepped, function(dt)
    AppState.FrameTimer = AppState.FrameTimer + dt
    AppState.FrameCount = AppState.FrameCount + 1
    
    if AppState.FrameTimer >= 0.5 then
        AppState.FPS = math.floor(AppState.FrameCount / AppState.FrameTimer)
        AppState.Ping = Util.getPing()
        AppState.FrameCount = 0
        AppState.FrameTimer = 0
        
        -- Update watermark
        if WatermarkLabel then
            local status = AppState.IsOpen and "Active" or "Standby"
            WatermarkLabel.Text = string.format(
                "Hoshi Dev Tools | FPS: %d | Ping: %dms | %s | %s",
                AppState.FPS, AppState.Ping, Util.formatTime(), status
            )
        end
    end
end)

-- ============================================================
-- PHASE 22: CHARACTER RESPAWN HANDLER
-- ============================================================
Util.connect(LocalPlayer.CharacterAdded, function(newChar)
    task.wait(1)
    if Config.Speed.Level > 1 then
        local hum = newChar:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Config.Speed.Values[Config.Speed.Level] or 16
        end
    end
end)

-- Player removal cleanup
Util.connect(Players.PlayerRemoving, function(player)
    local espData = AppState.ESPObjects[player.UserId]
    if espData then
        pcall(function() if espData.Billboard then espData.Billboard:Destroy() end end)
        pcall(function() if espData.Highlight then espData.Highlight:Destroy() end end)
        AppState.ESPObjects[player.UserId] = nil
    end
    local obsInd = AppState.ObservationIndicators[player.UserId]
    if obsInd then
        pcall(function() obsInd:Destroy() end)
        AppState.ObservationIndicators[player.UserId] = nil
    end
end)

-- ============================================================
-- PHASE 23: CLEANUP FUNCTION
-- ============================================================
function Cleanup()
    Util.disconnectAll()
    
    for _, data in pairs(AppState.ESPObjects) do
        pcall(function() if data.Billboard then data.Billboard:Destroy() end end)
        pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
    end
    AppState.ESPObjects = {}
    
    for _, ind in pairs(AppState.ObservationIndicators) do
        pcall(function() ind:Destroy() end)
    end
    AppState.ObservationIndicators = {}
    
    pcall(function() BlurEffect:Destroy() end)
    pcall(function() ScreenGui:Destroy() end)
    
    _G.HoshiDevTools = nil
    _G.HoshiBlur = nil
    _G._HoshiObsStatus = nil
end

-- ============================================================
-- PHASE 24: SPLASH SCREEN
-- ============================================================
local function RunSplashScreen(onComplete)
    local splash = Util.new("Frame", {
        Name = "SplashScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(8, 8, 14),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 1000,
        Parent = ScreenGui,
    })
    
    -- Center container
    local center = Util.new("Frame", {
        Size = UDim2.new(0, 300, 0, 220),
        Position = UDim2.new(0.5, 0, 0.48, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 1001,
        Parent = splash,
    })
    
    -- Logo box
    local logoBox = Util.new("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Colors.Accent,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 1002,
        Parent = center,
    })
    Util.corner(logoBox, 22)
    local logoStroke = Util.stroke(logoBox, Config.Colors.Accent, 2, 0.3)
    
    -- Logo glow
    local logoGlow = Util.new("Frame", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Config.Colors.Accent,
        BackgroundTransparency = 0.95,
        BorderSizePixel = 0,
        ZIndex = 1001,
        Parent = logoBox,
    })
    Util.corner(logoGlow, 28)
    
    local logoH = Util.new("TextLabel", {
        Text = "H",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = IsMobile and 44 or 48,
        TextColor3 = Config.Colors.Accent,
        TextTransparency = 1,
        ZIndex = 1003,
        Parent = logoBox,
    })
    
    -- Title
    local splashTitle = Util.new("TextLabel", {
        Text = "Hoshi Development Tools",
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0.5, 0, 0, 100),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = IsMobile and 16 or 18,
        TextColor3 = Config.Colors.TextPrimary,
        TextTransparency = 1,
        ZIndex = 1002,
        Parent = center,
    })
    
    local splashSub = Util.new("TextLabel", {
        Text = "Internal Development Build v" .. Config.Version,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0.5, 0, 0, 126),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = IsMobile and 10 or 11,
        TextColor3 = Config.Colors.TextTertiary,
        TextTransparency = 1,
        ZIndex = 1002,
        Parent = center,
    })
    
    -- Progress bar
    local progBg = Util.new("Frame", {
        Size = UDim2.new(0, IsMobile and 200 or 260, 0, 3),
        Position = UDim2.new(0.5, 0, 0, 165),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Config.Colors.BgElevated,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1002,
        Parent = center,
    })
    Util.corner(progBg, 2)
    
    local progFill = Util.new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1003,
        Parent = progBg,
    })
    Util.corner(progFill, 2)
    
    local loadLabel = Util.new("TextLabel", {
        Text = "Initializing...",
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0.5, 0, 0, 178),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = IsMobile and 9 or 10,
        TextColor3 = Config.Colors.TextDisabled,
        TextTransparency = 1,
        ZIndex = 1002,
        Parent = center,
    })
    
    -- === ANIMATION SEQUENCE ===
    task.wait(0.15)
    
    -- 1. Logo scale in
    Anim.tween(logoBox, 0.6, {
        Size = UDim2.new(0, IsMobile and 82 or 90, 0, IsMobile and 82 or 90),
        BackgroundTransparency = 0.82,
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.wait(0.2)
    
    -- 2. H letter fade in
    Anim.tween(logoH, 0.4, {TextTransparency = 0}, Enum.EasingStyle.Quart)
    
    -- 3. Glow pulse
    Anim.tween(logoGlow, 0.7, {BackgroundTransparency = 0.82}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    task.delay(0.7, function()
        Anim.tween(logoGlow, 0.7, {BackgroundTransparency = 0.96}, Enum.EasingStyle.Sine)
    end)
    
    task.wait(0.3)
    
    -- 4. Title fade in
    Anim.tween(splashTitle, 0.45, {TextTransparency = 0}, Enum.EasingStyle.Quart)
    task.wait(0.12)
    Anim.tween(splashSub, 0.45, {TextTransparency = 0}, Enum.EasingStyle.Quart)
    
    task.wait(0.2)
    
    -- 5. Progress bar appear
    Anim.tween(progBg, 0.25, {BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
    Anim.tween(progFill, 0.25, {BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
    Anim.tween(loadLabel, 0.25, {TextTransparency = 0}, Enum.EasingStyle.Quart)
    
    -- 6. Loading steps
    local steps = {
        {0.12, "Loading core modules..."},
        {0.28, "Initializing UI framework..."},
        {0.42, "Building interface components..."},
        {0.58, "Loading ESP engine..."},
        {0.72, "Configuring safety systems..."},
        {0.88, "Preparing observation tools..."},
        {1.00, "Ready"},
    }
    
    for _, step in ipairs(steps) do
        task.wait(0.22)
        Anim.tween(progFill, 0.2, {Size = UDim2.new(step[1], 0, 1, 0)}, Enum.EasingStyle.Quart)
        loadLabel.Text = step[2]
    end
    
    task.wait(0.5)
    
    -- 7. Fade out everything
    local function fadeElement(element)
        pcall(function()
            if element:IsA("TextLabel") or element:IsA("TextButton") then
                Anim.tween(element, 0.35, {TextTransparency = 1})
            end
            if element:IsA("GuiObject") then
                Anim.tween(element, 0.35, {BackgroundTransparency = 1})
            end
        end)
        pcall(function()
            local stroke = element:FindFirstChildOfClass("UIStroke")
            if stroke then Anim.tween(stroke, 0.35, {Transparency = 1}) end
        end)
    end
    
    for _, desc in ipairs(splash:GetDescendants()) do
        fadeElement(desc)
    end
    Anim.tween(splash, 0.45, {BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
        pcall(function() splash:Destroy() end)
    end)
    
    task.wait(0.5)
    
    if onComplete then onComplete() end
end

-- ============================================================
-- PHASE 25: INITIALIZATION
-- ============================================================

-- Hide floating button initially (splash will show it)
FloatingButton.Visible = false

-- Set default tab
SwitchTab("Dashboard")

-- Run splash then open
task.spawn(function()
    RunSplashScreen(function()
        -- Show floating button first
        FloatingButton.Visible = true
        startFloatingPulse()
        
        -- Auto-open GUI
        task.wait(0.1)
        OpenGUI()
        
        -- Welcome notifications
        task.delay(0.6, function()
            NotificationModule.send(
                "Hoshi Development Tools",
                "Development environment loaded successfully",
                "Success",
                5
            )
        end)
        
        task.delay(1.8, function()
            NotificationModule.send(
                "System",
                "All " .. #TabDefinitions .. " modules initialized - " .. (IsMobile and "Mobile" or "Desktop") .. " mode",
                "Info",
                3
            )
        end)
    end)
end)

-- Keyboard shortcut (Desktop: press ` or F6 to toggle)
if not IsMobile then
    Util.connect(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.BackquoteGrave or input.KeyCode == Enum.KeyCode.F6 then
            if AppState.IsOpen then
                CloseGUI()
            else
                OpenGUI()
            end
        end
    end)
end