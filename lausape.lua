--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           ADMIN DEVELOPMENT TOOLS v2.0                      ║
    ║           For Private Map Testing & Debugging               ║
    ║           Glassmorphism Dark Theme + Neon Blue               ║
    ╚══════════════════════════════════════════════════════════════╝
    
    Structure:
    [1] CONFIG
    [2] UTILITIES
    [3] NOTIFICATION SYSTEM
    [4] UI FRAMEWORK
    [5] SPLASH SCREEN
    [6] MAIN GUI BUILDER
    [7] ESP MODULE
    [8] TELEPORT SAFETY MODULE
    [9] SPEED RUN MODULE
    [10] POV CIRCLE MODULE
    [11] ON POINT MODULE
    [12] CLEANUP
    [13] INIT
--]]

-- ══════════════════════════════════════════════════════════════
-- [1] CONFIG
-- ══════════════════════════════════════════════════════════════

local Config = {
    -- Theme Colors
    Theme = {
        Background = Color3.fromRGB(12, 12, 20),
        Surface = Color3.fromRGB(18, 18, 30),
        SurfaceLight = Color3.fromRGB(25, 25, 42),
        SurfaceHover = Color3.fromRGB(32, 32, 55),
        NeonBlue = Color3.fromRGB(0, 170, 255),
        NeonBlueLight = Color3.fromRGB(80, 200, 255),
        NeonBlueDark = Color3.fromRGB(0, 120, 200),
        NeonCyan = Color3.fromRGB(0, 255, 230),
        Accent2 = Color3.fromRGB(130, 80, 255),
        Text = Color3.fromRGB(230, 235, 245),
        TextDim = Color3.fromRGB(140, 150, 170),
        TextMuted = Color3.fromRGB(80, 90, 110),
        Success = Color3.fromRGB(0, 220, 130),
        Warning = Color3.fromRGB(255, 180, 0),
        Danger = Color3.fromRGB(255, 60, 80),
        GlassBG = Color3.fromRGB(15, 15, 28),
        GlassStroke = Color3.fromRGB(60, 70, 100),
        SidebarBG = Color3.fromRGB(10, 10, 18),
    },
    
    -- UI Settings
    UI = {
        WindowSize = UDim2.new(0, 780, 0, 520),
        CornerRadius = UDim.new(0, 12),
        CornerRadiusSmall = UDim.new(0, 8),
        CornerRadiusTiny = UDim.new(0, 6),
        AnimationSpeed = 0.35,
        AnimationSpeedFast = 0.2,
        AnimationEasing = Enum.EasingStyle.Quint,
        SidebarWidth = 180,
        HeaderHeight = 50,
        Font = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontRegular = Enum.Font.Gotham,
    },
    
    -- ESP Defaults
    ESP = {
        Enabled = false,
        ShowBox = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowRole = true,
        RoleColors = {
            Killer = Color3.fromRGB(255, 50, 60),
            Survivor = Color3.fromRGB(0, 200, 120),
            Admin = Color3.fromRGB(0, 170, 255),
            Default = Color3.fromRGB(200, 200, 200),
        },
    },
    
    -- Teleport Defaults
    Teleport = {
        Enabled = false,
        Radius = 35,
        Cooldown = 3,
        SafePosition = Vector3.new(0, 100, 0),
        LastTeleportTime = 0,
        Status = "Idle",
    },
    
    -- Speed Defaults
    Speed = {
        Value = 1,
        Min = 1,
        Max = 10,
        DefaultWalkSpeed = 16,
    },
    
    -- POV Circle Defaults
    POV = {
        Enabled = false,
        Radius = 100,
        Thickness = 2,
        Opacity = 0.8,
        Color = Color3.fromRGB(0, 170, 255),
        TargetPlayer = nil,
        Spectating = false,
    },
    
    -- On Point Defaults
    OnPoint = {
        Enabled = false,
        Radius = 50,
        SmoothUpdate = true,
        Transparency = 0.5,
        Color = Color3.fromRGB(255, 180, 0),
    },
    
    -- Version
    Version = "2.0.0",
    ScriptName = "ADT",
}

-- ══════════════════════════════════════════════════════════════
-- [2] UTILITIES
-- ══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Utilities = {}

-- Connections storage for cleanup
Utilities._connections = {}
Utilities._instances = {}

--- Create a TweenInfo shorthand
function Utilities.TweenInfo(duration, style, direction)
    return TweenInfo.new(
        duration or Config.UI.AnimationSpeed,
        style or Config.UI.AnimationEasing,
        direction or Enum.EasingDirection.Out
    )
end

--- Tween an instance property
function Utilities.Tween(instance, properties, duration, style, direction, callback)
    local info = Utilities.TweenInfo(duration, style, direction)
    local tween = TweenService:Create(instance, info, properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

--- Connect and track connections for cleanup
function Utilities.Connect(signal, func)
    local connection = signal:Connect(func)
    table.insert(Utilities._connections, connection)
    return connection
end

--- Track instances for cleanup
function Utilities.Track(instance)
    table.insert(Utilities._instances, instance)
    return instance
end

--- Get distance between two Vector3 positions
function Utilities.Distance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

--- Get character root part
function Utilities.GetRootPart(player)
    local char = player and player.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
end

--- Get humanoid
function Utilities.GetHumanoid(player)
    local char = player and player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

--- Get player role (reads attribute or team name)
function Utilities.GetRole(player)
    -- Try attribute first
    local role = player:GetAttribute("Role")
    if role then return role end
    -- Try a value inside player
    local roleVal = player:FindFirstChild("Role")
    if roleVal and roleVal:IsA("StringValue") then return roleVal.Value end
    -- Fallback to team
    if player.Team then return player.Team.Name end
    return "Default"
end

--- Lerp Color3
function Utilities.LerpColor(c1, c2, alpha)
    return Color3.new(
        c1.R + (c2.R - c1.R) * alpha,
        c1.G + (c2.G - c1.G) * alpha,
        c1.B + (c2.B - c1.B) * alpha
    )
end

--- Create rounded rectangle
function Utilities.AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Config.UI.CornerRadius
    corner.Parent = parent
    return corner
end

--- Create stroke
function Utilities.AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Theme.GlassStroke
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = parent
    return stroke
end

--- Create padding
function Utilities.AddPadding(parent, top, right, bottom, left)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.Parent = parent
    return padding
end

--- Create gradient
function Utilities.AddGradient(parent, c1, c2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1 or Config.Theme.NeonBlue),
        ColorSequenceKeypoint.new(1, c2 or Config.Theme.NeonCyan),
    })
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

--- Create list layout
function Utilities.AddListLayout(parent, padding, direction, horizontalAlign, verticalAlign)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 8)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = horizontalAlign or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = verticalAlign or Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

-- ══════════════════════════════════════════════════════════════
-- [3] NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════

local NotificationSystem = {}
NotificationSystem._gui = nil
NotificationSystem._container = nil

--- Initialize notification container
function NotificationSystem.Init(screenGui)
    NotificationSystem._gui = screenGui
    
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 320, 1, 0)
    container.Position = UDim2.new(1, -340, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    Utilities.AddPadding(container, 80, 0, 20, 0)
    Utilities.AddListLayout(container, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    
    NotificationSystem._container = container
end

--- Show a notification
function NotificationSystem.Notify(title, message, notifType, duration)
    notifType = notifType or "info"
    duration = duration or 3
    
    local accentColor = Config.Theme.NeonBlue
    if notifType == "success" then accentColor = Config.Theme.Success
    elseif notifType == "warning" then accentColor = Config.Theme.Warning
    elseif notifType == "error" then accentColor = Config.Theme.Danger end
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notification"
    notifFrame.Size = UDim2.new(1, 0, 0, 70)
    notifFrame.BackgroundColor3 = Config.Theme.Surface
    notifFrame.BackgroundTransparency = 0.1
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = NotificationSystem._container
    
    Utilities.AddCorner(notifFrame, Config.UI.CornerRadiusSmall)
    Utilities.AddStroke(notifFrame, accentColor, 1, 0.4)
    
    -- Accent bar on left
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notifFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 24)
    titleLabel.Position = UDim2.new(0, 16, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = Config.Theme.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Config.UI.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifFrame
    
    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 20)
    msgLabel.Position = UDim2.new(0, 16, 0, 34)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message or ""
    msgLabel.TextColor3 = Config.Theme.TextDim
    msgLabel.TextSize = 11
    msgLabel.Font = Config.UI.FontRegular
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = notifFrame
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.BackgroundColor3 = accentColor
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notifFrame
    
    -- Animate in
    notifFrame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    msgLabel.TextTransparency = 1
    accentBar.BackgroundTransparency = 1
    progressBar.BackgroundTransparency = 1
    
    Utilities.Tween(notifFrame, {BackgroundTransparency = 0.1}, 0.3)
    Utilities.Tween(titleLabel, {TextTransparency = 0}, 0.3)
    Utilities.Tween(msgLabel, {TextTransparency = 0}, 0.3)
    Utilities.Tween(accentBar, {BackgroundTransparency = 0}, 0.3)
    Utilities.Tween(progressBar, {BackgroundTransparency = 0}, 0.3)
    
    -- Progress animation
    Utilities.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
    
    -- Auto dismiss
    task.delay(duration, function()
        Utilities.Tween(notifFrame, {BackgroundTransparency = 1}, 0.3)
        Utilities.Tween(titleLabel, {TextTransparency = 1}, 0.3)
        Utilities.Tween(msgLabel, {TextTransparency = 1}, 0.3)
        Utilities.Tween(accentBar, {BackgroundTransparency = 1}, 0.3)
        Utilities.Tween(progressBar, {BackgroundTransparency = 1}, 0.3, nil, nil, function()
            notifFrame:Destroy()
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- [4] UI FRAMEWORK (Component Library)
-- ══════════════════════════════════════════════════════════════

local UIFramework = {}

--- Create a glass-style panel
function UIFramework.CreatePanel(parent, size, position, name)
    local panel = Instance.new("Frame")
    panel.Name = name or "Panel"
    panel.Size = size or UDim2.new(1, 0, 0, 60)
    panel.Position = position or UDim2.new(0, 0, 0, 0)
    panel.BackgroundColor3 = Config.Theme.SurfaceLight
    panel.BackgroundTransparency = 0.2
    panel.BorderSizePixel = 0
    panel.Parent = parent
    
    Utilities.AddCorner(panel, Config.UI.CornerRadiusSmall)
    Utilities.AddStroke(panel, Config.Theme.GlassStroke, 1, 0.6)
    
    return panel
end

--- Create a section title
function UIFramework.CreateSectionTitle(parent, text, layoutOrder)
    local label = Instance.new("TextLabel")
    label.Name = "SectionTitle"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Theme.TextMuted
    label.TextSize = 10
    label.Font = Config.UI.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = layoutOrder or 0
    label.Parent = parent
    return label
end

--- Create a toggle switch
function UIFramework.CreateToggle(parent, label, default, callback, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. label
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.3
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    Utilities.AddPadding(container, 0, 12, 0, 12)
    
    -- Label
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -52, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 12
    textLabel.Font = Config.UI.FontMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    -- Toggle track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, 40, 0, 20)
    track.Position = UDim2.new(1, -40, 0.5, -10)
    track.BackgroundColor3 = default and Config.Theme.NeonBlue or Config.Theme.TextMuted
    track.BorderSizePixel = 0
    track.Parent = container
    Utilities.AddCorner(track, UDim.new(0, 10))
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Utilities.AddCorner(knob, UDim.new(0, 8))
    
    local isOn = default or false
    
    -- Click handler
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = container
    
    Utilities.Connect(button.MouseButton1Click, function()
        isOn = not isOn
        
        -- Animate track color
        Utilities.Tween(track, {
            BackgroundColor3 = isOn and Config.Theme.NeonBlue or Config.Theme.TextMuted
        }, Config.UI.AnimationSpeedFast)
        
        -- Animate knob position
        Utilities.Tween(knob, {
            Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }, Config.UI.AnimationSpeedFast, Enum.EasingStyle.Back)
        
        if callback then callback(isOn) end
    end)
    
    -- Hover effect
    Utilities.Connect(button.MouseEnter, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.15}, 0.15)
    end)
    Utilities.Connect(button.MouseLeave, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.3}, 0.15)
    end)
    
    -- Return toggle API
    return {
        Container = container,
        SetState = function(state)
            isOn = state
            Utilities.Tween(track, {
                BackgroundColor3 = isOn and Config.Theme.NeonBlue or Config.Theme.TextMuted
            }, Config.UI.AnimationSpeedFast)
            Utilities.Tween(knob, {
                Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }, Config.UI.AnimationSpeedFast, Enum.EasingStyle.Back)
        end,
        GetState = function() return isOn end,
    }
end

--- Create a slider with text box
function UIFramework.CreateSlider(parent, label, min, max, default, callback, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. label
    container.Size = UDim2.new(1, 0, 0, 56)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.3
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    Utilities.AddPadding(container, 8, 12, 8, 12)
    
    -- Label + value display
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 16)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = container
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.6, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 12
    textLabel.Font = Config.UI.FontMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = headerFrame
    
    -- Value TextBox
    local valueBox = Instance.new("TextBox")
    valueBox.Name = "ValueBox"
    valueBox.Size = UDim2.new(0, 50, 0, 18)
    valueBox.Position = UDim2.new(1, -50, 0, -1)
    valueBox.BackgroundColor3 = Config.Theme.Background
    valueBox.BackgroundTransparency = 0.3
    valueBox.TextColor3 = Config.Theme.NeonBlue
    valueBox.TextSize = 11
    valueBox.Font = Config.UI.Font
    valueBox.Text = tostring(default)
    valueBox.ClearTextOnFocus = false
    valueBox.Parent = headerFrame
    Utilities.AddCorner(valueBox, Config.UI.CornerRadiusTiny)
    Utilities.AddStroke(valueBox, Config.Theme.NeonBlueDark, 1, 0.6)
    
    -- Slider track
    local trackFrame = Instance.new("Frame")
    trackFrame.Name = "SliderTrack"
    trackFrame.Size = UDim2.new(1, 0, 0, 6)
    trackFrame.Position = UDim2.new(0, 0, 0, 30)
    trackFrame.BackgroundColor3 = Config.Theme.Background
    trackFrame.BorderSizePixel = 0
    trackFrame.Parent = container
    Utilities.AddCorner(trackFrame, UDim.new(0, 3))
    
    -- Slider fill
    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "SliderFill"
    local initAlpha = math.clamp((default - min) / (max - min), 0, 1)
    fillFrame.Size = UDim2.new(initAlpha, 0, 1, 0)
    fillFrame.BackgroundColor3 = Config.Theme.NeonBlue
    fillFrame.BorderSizePixel = 0
    fillFrame.Parent = trackFrame
    Utilities.AddCorner(fillFrame, UDim.new(0, 3))
    Utilities.AddGradient(fillFrame, Config.Theme.NeonBlue, Config.Theme.NeonCyan, 0)
    
    -- Slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "SliderKnob"
    sliderKnob.Size = UDim2.new(0, 14, 0, 14)
    sliderKnob.Position = UDim2.new(initAlpha, -7, 0.5, -7)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 2
    sliderKnob.Parent = trackFrame
    Utilities.AddCorner(sliderKnob, UDim.new(0, 7))
    
    -- Glow around knob
    local knobGlow = Instance.new("Frame")
    knobGlow.Size = UDim2.new(0, 20, 0, 20)
    knobGlow.Position = UDim2.new(0.5, -10, 0.5, -10)
    knobGlow.BackgroundColor3 = Config.Theme.NeonBlue
    knobGlow.BackgroundTransparency = 0.7
    knobGlow.BorderSizePixel = 0
    knobGlow.ZIndex = 1
    knobGlow.Parent = sliderKnob
    Utilities.AddCorner(knobGlow, UDim.new(0, 10))
    
    local currentValue = default
    local dragging = false
    
    local function updateSlider(alpha)
        alpha = math.clamp(alpha, 0, 1)
        currentValue = math.floor(min + (max - min) * alpha + 0.5)
        currentValue = math.clamp(currentValue, min, max)
        
        local newAlpha = (currentValue - min) / (max - min)
        fillFrame.Size = UDim2.new(newAlpha, 0, 1, 0)
        sliderKnob.Position = UDim2.new(newAlpha, -7, 0.5, -7)
        valueBox.Text = tostring(currentValue)
        
        if callback then callback(currentValue) end
    end
    
    -- Invisible button for click detection on track
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 0, 0, 20)
    sliderButton.Position = UDim2.new(0, 0, 0, -7)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.ZIndex = 3
    sliderButton.Parent = trackFrame
    
    Utilities.Connect(sliderButton.MouseButton1Down, function()
        dragging = true
        local relX = Mouse.X - trackFrame.AbsolutePosition.X
        local alpha = relX / trackFrame.AbsoluteSize.X
        updateSlider(alpha)
    end)
    
    Utilities.Connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = Mouse.X - trackFrame.AbsolutePosition.X
            local alpha = relX / trackFrame.AbsoluteSize.X
            updateSlider(alpha)
        end
    end)
    
    Utilities.Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- TextBox input
    Utilities.Connect(valueBox.FocusLost, function(enterPressed)
        local num = tonumber(valueBox.Text)
        if num then
            num = math.clamp(math.floor(num), min, max)
            local alpha = (num - min) / (max - min)
            updateSlider(alpha)
        else
            valueBox.Text = tostring(currentValue)
        end
    end)
    
    return {
        Container = container,
        GetValue = function() return currentValue end,
        SetValue = function(val)
            val = math.clamp(val, min, max)
            local alpha = (val - min) / (max - min)
            updateSlider(alpha)
        end,
    }
end

--- Create a styled button with ripple effect
function UIFramework.CreateButton(parent, label, callback, layoutOrder, accentColor)
    accentColor = accentColor or Config.Theme.NeonBlue
    
    local container = Instance.new("Frame")
    container.Name = "Button_" .. label
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = accentColor
    container.BackgroundTransparency = 0.7
    container.LayoutOrder = layoutOrder or 0
    container.ClipsDescendants = true
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    Utilities.AddStroke(container, accentColor, 1, 0.4)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 12
    textLabel.Font = Config.UI.FontMedium
    textLabel.Parent = container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 3
    button.Parent = container
    
    -- Ripple effect
    Utilities.Connect(button.MouseButton1Click, function()
        -- Create ripple
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 2
        ripple.Parent = container
        Utilities.AddCorner(ripple, UDim.new(0.5, 0))
        
        Utilities.Tween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1,
        }, 0.5, Enum.EasingStyle.Quad, nil, function()
            ripple:Destroy()
        end)
        
        if callback then callback() end
    end)
    
    -- Hover
    Utilities.Connect(button.MouseEnter, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.5}, 0.15)
    end)
    Utilities.Connect(button.MouseLeave, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.7}, 0.15)
    end)
    
    return {
        Container = container,
        SetText = function(text) textLabel.Text = text end,
    }
end

--- Create a dropdown to select a player
function UIFramework.CreatePlayerDropdown(parent, label, callback, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. label
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.3
    container.LayoutOrder = layoutOrder or 0
    container.ClipsDescendants = true
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    Utilities.AddPadding(container, 0, 12, 0, 12)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.5, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 12
    textLabel.Font = Config.UI.FontMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(0.5, 0, 1, 0)
    selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = "None"
    selectedLabel.TextColor3 = Config.Theme.NeonBlue
    selectedLabel.TextSize = 11
    selectedLabel.Font = Config.UI.FontMedium
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    selectedLabel.Parent = container
    
    local isOpen = false
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 24, 0, 0)
    optionsFrame.Position = UDim2.new(0, -12, 0, 36)
    optionsFrame.BackgroundColor3 = Config.Theme.Background
    optionsFrame.BackgroundTransparency = 0.1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ScrollBarThickness = 3
    optionsFrame.ScrollBarImageColor3 = Config.Theme.NeonBlue
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsFrame.Visible = false
    optionsFrame.ClipsDescendants = true
    optionsFrame.Parent = container
    Utilities.AddCorner(optionsFrame, Config.UI.CornerRadiusTiny)
    
    local optLayout = Utilities.AddListLayout(optionsFrame, 2)
    Utilities.AddPadding(optionsFrame, 4, 4, 4, 4)
    
    local selectedPlayer = nil
    
    local function refreshOptions()
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                count = count + 1
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = Config.Theme.SurfaceLight
                optBtn.BackgroundTransparency = 0.4
                optBtn.Text = player.Name
                optBtn.TextColor3 = Config.Theme.Text
                optBtn.TextSize = 11
                optBtn.Font = Config.UI.FontMedium
                optBtn.Parent = optionsFrame
                Utilities.AddCorner(optBtn, Config.UI.CornerRadiusTiny)
                
                Utilities.Connect(optBtn.MouseButton1Click, function()
                    selectedPlayer = player
                    selectedLabel.Text = player.Name
                    -- Close
                    isOpen = false
                    Utilities.Tween(container, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                    optionsFrame.Visible = false
                    if callback then callback(player) end
                end)
                
                Utilities.Connect(optBtn.MouseEnter, function()
                    Utilities.Tween(optBtn, {BackgroundTransparency = 0.2}, 0.1)
                end)
                Utilities.Connect(optBtn.MouseLeave, function()
                    Utilities.Tween(optBtn, {BackgroundTransparency = 0.4}, 0.1)
                end)
            end
        end
        
        optionsFrame.CanvasSize = UDim2.new(0, 0, 0, count * 28 + 8)
    end
    
    -- Toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 36)
    toggleBtn.Position = UDim2.new(0, -12, 0, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 3
    toggleBtn.Parent = container
    
    Utilities.Connect(toggleBtn.MouseButton1Click, function()
        isOpen = not isOpen
        if isOpen then
            refreshOptions()
            optionsFrame.Visible = true
            local optCount = #Players:GetPlayers() - 1
            local height = math.min(optCount * 28 + 8, 120)
            Utilities.Tween(container, {Size = UDim2.new(1, 0, 0, 36 + height)}, 0.25)
            optionsFrame.Size = UDim2.new(1, 24, 0, height)
        else
            Utilities.Tween(container, {Size = UDim2.new(1, 0, 0, 36)}, 0.2, nil, nil, function()
                optionsFrame.Visible = false
            end)
        end
    end)
    
    return {
        Container = container,
        GetSelected = function() return selectedPlayer end,
        SetSelected = function(p)
            selectedPlayer = p
            selectedLabel.Text = p and p.Name or "None"
        end,
    }
end

--- Create a color indicator/status label
function UIFramework.CreateStatusLabel(parent, label, defaultText, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Status_" .. label
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.5, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Config.Theme.TextDim
    textLabel.TextSize = 11
    textLabel.Font = Config.UI.FontRegular
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    -- Status dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0.5, 4, 0.5, -4)
    dot.BackgroundColor3 = Config.Theme.TextMuted
    dot.BorderSizePixel = 0
    dot.Parent = container
    Utilities.AddCorner(dot, UDim.new(0, 4))
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.5, -16, 1, 0)
    valueLabel.Position = UDim2.new(0.5, 16, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = defaultText or "N/A"
    valueLabel.TextColor3 = Config.Theme.Text
    valueLabel.TextSize = 11
    valueLabel.Font = Config.UI.FontMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = container
    
    return {
        Container = container,
        SetValue = function(text, color)
            valueLabel.Text = text
            if color then
                dot.BackgroundColor3 = color
                valueLabel.TextColor3 = color
            end
        end,
    }
end

--- Create a color picker (simple - preset colors)
function UIFramework.CreateColorPicker(parent, label, default, callback, layoutOrder)
    local presetColors = {
        Config.Theme.NeonBlue,
        Config.Theme.NeonCyan,
        Config.Theme.Success,
        Config.Theme.Warning,
        Config.Theme.Danger,
        Config.Theme.Accent2,
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 120, 200),
    }
    
    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. label
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.3
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    Utilities.AddPadding(container, 0, 10, 0, 10)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 60, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 11
    textLabel.Font = Config.UI.FontMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    local colorsFrame = Instance.new("Frame")
    colorsFrame.Size = UDim2.new(1, -70, 1, -8)
    colorsFrame.Position = UDim2.new(0, 65, 0, 4)
    colorsFrame.BackgroundTransparency = 1
    colorsFrame.Parent = container
    
    Utilities.AddListLayout(colorsFrame, 4, Enum.FillDirection.Horizontal)
    
    local selectedColor = default
    
    for i, color in ipairs(presetColors) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 22, 0, 22)
        colorBtn.BackgroundColor3 = color
        colorBtn.Text = ""
        colorBtn.Parent = colorsFrame
        Utilities.AddCorner(colorBtn, UDim.new(0, 4))
        
        if color == default then
            Utilities.AddStroke(colorBtn, Color3.fromRGB(255, 255, 255), 2, 0)
        end
        
        Utilities.Connect(colorBtn.MouseButton1Click, function()
            selectedColor = color
            -- Remove all strokes, add to selected
            for _, child in ipairs(colorsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    local existingStroke = child:FindFirstChildOfClass("UIStroke")
                    if existingStroke then existingStroke:Destroy() end
                end
            end
            Utilities.AddStroke(colorBtn, Color3.fromRGB(255, 255, 255), 2, 0)
            if callback then callback(color) end
        end)
    end
    
    return {
        Container = container,
        GetColor = function() return selectedColor end,
    }
end

-- ══════════════════════════════════════════════════════════════
-- [5] SPLASH SCREEN
-- ══════════════════════════════════════════════════════════════

local SplashScreen = {}

function SplashScreen.Show(screenGui, callback)
    local splash = Instance.new("Frame")
    splash.Name = "SplashScreen"
    splash.Size = UDim2.new(1, 0, 1, 0)
    splash.BackgroundColor3 = Config.Theme.Background
    splash.BackgroundTransparency = 0
    splash.ZIndex = 100
    splash.Parent = screenGui
    
    -- Center container
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 300, 0, 200)
    center.Position = UDim2.new(0.5, -150, 0.5, -100)
    center.BackgroundTransparency = 1
    center.ZIndex = 101
    center.Parent = splash
    
    -- Logo text
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 0, 40)
    logoText.Position = UDim2.new(0, 0, 0, 30)
    logoText.BackgroundTransparency = 1
    logoText.Text = "⚡ ADT"
    logoText.TextColor3 = Config.Theme.NeonBlue
    logoText.TextSize = 36
    logoText.Font = Config.UI.Font
    logoText.TextTransparency = 1
    logoText.ZIndex = 101
    logoText.Parent = center
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 75)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Admin Development Tools"
    subtitle.TextColor3 = Config.Theme.TextDim
    subtitle.TextSize = 14
    subtitle.Font = Config.UI.FontMedium
    subtitle.TextTransparency = 1
    subtitle.ZIndex = 101
    subtitle.Parent = center
    
    -- Version
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, 0, 0, 16)
    versionLabel.Position = UDim2.new(0, 0, 0, 98)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v" .. Config.Version
    versionLabel.TextColor3 = Config.Theme.TextMuted
    versionLabel.TextSize = 11
    versionLabel.Font = Config.UI.FontRegular
    versionLabel.TextTransparency = 1
    versionLabel.ZIndex = 101
    versionLabel.Parent = center
    
    -- Loading bar background
    local loadBarBG = Instance.new("Frame")
    loadBarBG.Size = UDim2.new(0.6, 0, 0, 3)
    loadBarBG.Position = UDim2.new(0.2, 0, 0, 140)
    loadBarBG.BackgroundColor3 = Config.Theme.SurfaceLight
    loadBarBG.BorderSizePixel = 0
    loadBarBG.ZIndex = 101
    loadBarBG.Parent = center
    Utilities.AddCorner(loadBarBG, UDim.new(0, 2))
    
    -- Loading bar fill
    local loadBarFill = Instance.new("Frame")
    loadBarFill.Size = UDim2.new(0, 0, 1, 0)
    loadBarFill.BackgroundColor3 = Config.Theme.NeonBlue
    loadBarFill.BorderSizePixel = 0
    loadBarFill.ZIndex = 102
    loadBarFill.Parent = loadBarBG
    Utilities.AddCorner(loadBarFill, UDim.new(0, 2))
    Utilities.AddGradient(loadBarFill, Config.Theme.NeonBlue, Config.Theme.NeonCyan, 0)
    
    -- Loading text
    local loadText = Instance.new("TextLabel")
    loadText.Size = UDim2.new(1, 0, 0, 14)
    loadText.Position = UDim2.new(0, 0, 0, 152)
    loadText.BackgroundTransparency = 1
    loadText.Text = "Initializing..."
    loadText.TextColor3 = Config.Theme.TextMuted
    loadText.TextSize = 10
    loadText.Font = Config.UI.FontRegular
    loadText.TextTransparency = 1
    loadText.ZIndex = 101
    loadText.Parent = center
    
    -- Animate in
    Utilities.Tween(logoText, {TextTransparency = 0}, 0.5)
    task.wait(0.2)
    Utilities.Tween(subtitle, {TextTransparency = 0}, 0.4)
    Utilities.Tween(versionLabel, {TextTransparency = 0}, 0.4)
    task.wait(0.2)
    Utilities.Tween(loadText, {TextTransparency = 0}, 0.3)
    
    -- Loading animation
    local loadSteps = {
        {text = "Loading UI Framework...", progress = 0.2},
        {text = "Initializing Modules...", progress = 0.4},
        {text = "Setting up ESP System...", progress = 0.6},
        {text = "Configuring Tools...", progress = 0.8},
        {text = "Ready!", progress = 1.0},
    }
    
    for _, step in ipairs(loadSteps) do
        loadText.Text = step.text
        Utilities.Tween(loadBarFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, 0.3)
        task.wait(0.35)
    end
    
    task.wait(0.3)
    
    -- Fade out
    Utilities.Tween(splash, {BackgroundTransparency = 1}, 0.5)
    Utilities.Tween(logoText, {TextTransparency = 1}, 0.4)
    Utilities.Tween(subtitle, {TextTransparency = 1}, 0.4)
    Utilities.Tween(versionLabel, {TextTransparency = 1}, 0.4)
    Utilities.Tween(loadText, {TextTransparency = 1}, 0.4)
    Utilities.Tween(loadBarBG, {BackgroundTransparency = 1}, 0.4)
    Utilities.Tween(loadBarFill, {BackgroundTransparency = 1}, 0.4)
    
    task.wait(0.5)
    splash:Destroy()
    
    if callback then callback() end
end

-- ══════════════════════════════════════════════════════════════
-- [6] MAIN GUI BUILDER
-- ══════════════════════════════════════════════════════════════

local MainGUI = {}
MainGUI._screenGui = nil
MainGUI._mainFrame = nil
MainGUI._contentPages = {}
MainGUI._activeTab = nil
MainGUI._minimized = false

function MainGUI.Init()
    -- Destroy existing
    local existing = LocalPlayer.PlayerGui:FindFirstChild("ADT_DevTools")
    if existing then existing:Destroy() end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ADT_DevTools"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.Parent = LocalPlayer.PlayerGui
    
    MainGUI._screenGui = screenGui
    Utilities.Track(screenGui)
    
    -- Init notifications
    NotificationSystem.Init(screenGui)
    
    -- Show splash screen, then build main UI
    SplashScreen.Show(screenGui, function()
        MainGUI.BuildMainWindow()
        NotificationSystem.Notify("ADT Loaded", "Admin Development Tools v" .. Config.Version .. " ready.", "success", 3)
    end)
end

function MainGUI.BuildMainWindow()
    local screenGui = MainGUI._screenGui
    
    -- ── Main Frame ──
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = Config.UI.WindowSize
    mainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
    mainFrame.BackgroundColor3 = Config.Theme.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    Utilities.AddCorner(mainFrame, Config.UI.CornerRadius)
    Utilities.AddStroke(mainFrame, Config.Theme.GlassStroke, 1, 0.3)
    
    -- Drop shadow (simulated with larger frame behind)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    MainGUI._mainFrame = mainFrame
    
    -- Fade in animation
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 700, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -230)
    
    Utilities.Tween(mainFrame, {
        BackgroundTransparency = 0.05,
        Size = Config.UI.WindowSize,
        Position = UDim2.new(0.5, -390, 0.5, -260),
    }, 0.5, Enum.EasingStyle.Back)
    
    -- ── Header Bar ──
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, Config.UI.HeaderHeight)
    header.BackgroundColor3 = Config.Theme.SidebarBG
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    -- Header bottom line
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Config.Theme.NeonBlue
    headerLine.BackgroundTransparency = 0.6
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header
    
    -- Header gradient line
    Utilities.AddGradient(headerLine, Config.Theme.NeonBlue, Config.Theme.Accent2, 0)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ ADT Dev Tools"
    title.TextColor3 = Config.Theme.NeonBlue
    title.TextSize = 16
    title.Font = Config.UI.Font
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Version badge
    local vBadge = Instance.new("TextLabel")
    vBadge.Size = UDim2.new(0, 40, 0, 16)
    vBadge.Position = UDim2.new(0, 180, 0.5, -8)
    vBadge.BackgroundColor3 = Config.Theme.NeonBlueDark
    vBadge.BackgroundTransparency = 0.5
    vBadge.Text = "v" .. Config.Version
    vBadge.TextColor3 = Config.Theme.NeonBlueLight
    vBadge.TextSize = 9
    vBadge.Font = Config.UI.Font
    vBadge.Parent = header
    Utilities.AddCorner(vBadge, UDim.new(0, 4))
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundColor3 = Config.Theme.Danger
    closeBtn.BackgroundTransparency = 0.8
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Config.Theme.Danger
    closeBtn.TextSize = 14
    closeBtn.Font = Config.UI.Font
    closeBtn.Parent = header
    Utilities.AddCorner(closeBtn, Config.UI.CornerRadiusTiny)
    
    Utilities.Connect(closeBtn.MouseButton1Click, function()
        MainGUI.Close()
    end)
    Utilities.Connect(closeBtn.MouseEnter, function()
        Utilities.Tween(closeBtn, {BackgroundTransparency = 0.4}, 0.15)
    end)
    Utilities.Connect(closeBtn.MouseLeave, function()
        Utilities.Tween(closeBtn, {BackgroundTransparency = 0.8}, 0.15)
    end)
    
    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -76, 0.5, -15)
    minBtn.BackgroundColor3 = Config.Theme.Warning
    minBtn.BackgroundTransparency = 0.8
    minBtn.Text = "─"
    minBtn.TextColor3 = Config.Theme.Warning
    minBtn.TextSize = 14
    minBtn.Font = Config.UI.Font
    minBtn.Parent = header
    Utilities.AddCorner(minBtn, Config.UI.CornerRadiusTiny)
    
    Utilities.Connect(minBtn.MouseButton1Click, function()
        MainGUI.ToggleMinimize()
    end)
    Utilities.Connect(minBtn.MouseEnter, function()
        Utilities.Tween(minBtn, {BackgroundTransparency = 0.4}, 0.15)
    end)
    Utilities.Connect(minBtn.MouseLeave, function()
        Utilities.Tween(minBtn, {BackgroundTransparency = 0.8}, 0.15)
    end)
    
    -- ── Draggable ──
    MainGUI.MakeDraggable(header, mainFrame)
    
    -- ── Body Frame ──
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -Config.UI.HeaderHeight)
    body.Position = UDim2.new(0, 0, 0, Config.UI.HeaderHeight)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.Parent = mainFrame
    
    -- ── Sidebar ──
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, Config.UI.SidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = Config.Theme.SidebarBG
    sidebar.BackgroundTransparency = 0.2
    sidebar.BorderSizePixel = 0
    sidebar.Parent = body
    
    -- Sidebar right border
    local sidebarBorder = Instance.new("Frame")
    sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    sidebarBorder.Position = UDim2.new(1, 0, 0, 0)
    sidebarBorder.BackgroundColor3 = Config.Theme.GlassStroke
    sidebarBorder.BackgroundTransparency = 0.5
    sidebarBorder.BorderSizePixel = 0
    sidebarBorder.Parent = sidebar
    
    local sidebarContent = Instance.new("Frame")
    sidebarContent.Size = UDim2.new(1, 0, 1, 0)
    sidebarContent.BackgroundTransparency = 1
    sidebarContent.Parent = sidebar
    Utilities.AddPadding(sidebarContent, 12, 10, 12, 10)
    Utilities.AddListLayout(sidebarContent, 4)
    
    -- ── Content Area ──
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -Config.UI.SidebarWidth, 1, 0)
    contentArea.Position = UDim2.new(0, Config.UI.SidebarWidth, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true
    contentArea.Parent = body
    
    -- ── Create Tab Pages ──
    local tabs = {
        {name = "ESP Player", icon = "👁", module = "ESP"},
        {name = "Teleport", icon = "⚡", module = "Teleport"},
        {name = "Speed Run", icon = "🏃", module = "Speed"},
        {name = "POV Circle", icon = "◎", module = "POV"},
        {name = "On Point", icon = "🎯", module = "OnPoint"},
    }
    
    -- Sidebar label
    local sideLabel = Instance.new("TextLabel")
    sideLabel.Size = UDim2.new(1, 0, 0, 20)
    sideLabel.BackgroundTransparency = 1
    sideLabel.Text = "NAVIGATION"
    sideLabel.TextColor3 = Config.Theme.TextMuted
    sideLabel.TextSize = 9
    sideLabel.Font = Config.UI.Font
    sideLabel.TextXAlignment = Enum.TextXAlignment.Left
    sideLabel.LayoutOrder = 0
    sideLabel.Parent = sidebarContent
    
    local tabButtons = {}
    
    for i, tab in ipairs(tabs) do
        -- Create content page
        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. tab.module
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Config.Theme.NeonBlue
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = contentArea
        
        Utilities.AddPadding(page, 16, 16, 16, 16)
        local pageLayout = Utilities.AddListLayout(page, 10)
        
        -- Auto resize canvas
        Utilities.Connect(pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 32)
        end)
        
        MainGUI._contentPages[tab.module] = page
        
        -- Create sidebar button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tab.module
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.BackgroundColor3 = Config.Theme.NeonBlue
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = ""
        tabBtn.LayoutOrder = i
        tabBtn.Parent = sidebarContent
        Utilities.AddCorner(tabBtn, Config.UI.CornerRadiusTiny)
        
        -- Tab indicator (left accent)
        local tabIndicator = Instance.new("Frame")
        tabIndicator.Name = "Indicator"
        tabIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0.2, 0)
        tabIndicator.BackgroundColor3 = Config.Theme.NeonBlue
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Parent = tabBtn
        Utilities.AddCorner(tabIndicator, UDim.new(0, 2))
        
        -- Tab icon + text
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -12, 1, 0)
        tabLabel.Position = UDim2.new(0, 12, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tab.icon .. "  " .. tab.name
        tabLabel.TextColor3 = Config.Theme.TextDim
        tabLabel.TextSize = 12
        tabLabel.Font = Config.UI.FontMedium
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabBtn
        
        tabButtons[tab.module] = {button = tabBtn, label = tabLabel, indicator = tabIndicator}
        
        Utilities.Connect(tabBtn.MouseButton1Click, function()
            MainGUI.SwitchTab(tab.module, tabButtons)
        end)
        
        Utilities.Connect(tabBtn.MouseEnter, function()
            if MainGUI._activeTab ~= tab.module then
                Utilities.Tween(tabBtn, {BackgroundTransparency = 0.85}, 0.15)
            end
        end)
        
        Utilities.Connect(tabBtn.MouseLeave, function()
            if MainGUI._activeTab ~= tab.module then
                Utilities.Tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
            end
        end)
    end
    
    -- ── Sidebar footer (watermark) ──
    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(1, 0, 0, 30)
    watermark.BackgroundTransparency = 1
    watermark.Text = "DEV MODE"
    watermark.TextColor3 = Config.Theme.TextMuted
    watermark.TextSize = 9
    watermark.Font = Config.UI.Font
    watermark.TextXAlignment = Enum.TextXAlignment.Center
    watermark.LayoutOrder = 100
    watermark.Parent = sidebarContent
    
    -- ── Watermark on screen ──
    local screenWatermark = Instance.new("TextLabel")
    screenWatermark.Size = UDim2.new(0, 200, 0, 20)
    screenWatermark.Position = UDim2.new(0, 10, 1, -25)
    screenWatermark.BackgroundTransparency = 1
    screenWatermark.Text = "ADT v" .. Config.Version .. " | Dev Build"
    screenWatermark.TextColor3 = Config.Theme.NeonBlue
    screenWatermark.TextTransparency = 0.6
    screenWatermark.TextSize = 10
    screenWatermark.Font = Config.UI.Font
    screenWatermark.TextXAlignment = Enum.TextXAlignment.Left
    screenWatermark.Parent = MainGUI._screenGui
    
    -- ── Build module content ──
    MainGUI.BuildESPPage()
    MainGUI.BuildTeleportPage()
    MainGUI.BuildSpeedPage()
    MainGUI.BuildPOVPage()
    MainGUI.BuildOnPointPage()
    
    -- Default tab
    MainGUI.SwitchTab("ESP", tabButtons)
end

--- Switch active tab
function MainGUI.SwitchTab(moduleName, tabButtons)
    -- Deactivate previous
    if MainGUI._activeTab and tabButtons[MainGUI._activeTab] then
        local prev = tabButtons[MainGUI._activeTab]
        Utilities.Tween(prev.button, {BackgroundTransparency = 1}, 0.2)
        Utilities.Tween(prev.label, {TextColor3 = Config.Theme.TextDim}, 0.2)
        Utilities.Tween(prev.indicator, {BackgroundTransparency = 1}, 0.2)
        
        if MainGUI._contentPages[MainGUI._activeTab] then
            local page = MainGUI._contentPages[MainGUI._activeTab]
            Utilities.Tween(page, {Position = UDim2.new(-0.05, 0, 0, 0)}, 0.15, nil, nil, function()
                page.Visible = false
            end)
        end
    end
    
    -- Activate new
    MainGUI._activeTab = moduleName
    local curr = tabButtons[moduleName]
    Utilities.Tween(curr.button, {BackgroundTransparency = 0.8}, 0.2)
    Utilities.Tween(curr.label, {TextColor3 = Config.Theme.Text}, 0.2)
    Utilities.Tween(curr.indicator, {BackgroundTransparency = 0}, 0.2)
    
    if MainGUI._contentPages[moduleName] then
        local page = MainGUI._contentPages[moduleName]
        page.Visible = true
        page.Position = UDim2.new(0.05, 0, 0, 0)
        Utilities.Tween(page, {Position = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quint)
    end
end

--- Make a frame draggable
function MainGUI.MakeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    Utilities.Connect(dragHandle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Utilities.Connect(dragHandle.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    Utilities.Connect(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--- Toggle minimize
function MainGUI.ToggleMinimize()
    MainGUI._minimized = not MainGUI._minimized
    local frame = MainGUI._mainFrame
    
    if MainGUI._minimized then
        Utilities.Tween(frame, {
            Size = UDim2.new(0, 780, 0, Config.UI.HeaderHeight),
        }, 0.3, Enum.EasingStyle.Quint)
    else
        Utilities.Tween(frame, {
            Size = Config.UI.WindowSize,
        }, 0.3, Enum.EasingStyle.Quint)
    end
end

--- Close the GUI
function MainGUI.Close()
    local frame = MainGUI._mainFrame
    
    Utilities.Tween(frame, {
        Size = UDim2.new(0, 700, 0, 460),
        BackgroundTransparency = 1,
    }, 0.3, Enum.EasingStyle.Quint, nil, function()
        -- Cleanup everything
        Cleanup()
    end)
end

-- ══════════════════════════════════════════════════════════════
-- [7] ESP MODULE
-- ══════════════════════════════════════════════════════════════

local ESPModule = {}
ESPModule._drawings = {}
ESPModule._connection = nil

function MainGUI.BuildESPPage()
    local page = MainGUI._contentPages["ESP"]
    if not page then return end
    
    -- Page title
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 30)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "👁  ESP Player"
    pageTitle.TextColor3 = Config.Theme.Text
    pageTitle.TextSize = 18
    pageTitle.Font = Config.UI.Font
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 16)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "Visual player information overlay for debugging"
    pageDesc.TextColor3 = Config.Theme.TextDim
    pageDesc.TextSize = 11
    pageDesc.Font = Config.UI.FontRegular
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    -- Main toggle
    UIFramework.CreateToggle(page, "Enable ESP", Config.ESP.Enabled, function(state)
        Config.ESP.Enabled = state
        if state then
            ESPModule.Start()
            NotificationSystem.Notify("ESP", "ESP enabled", "success")
        else
            ESPModule.Stop()
            NotificationSystem.Notify("ESP", "ESP disabled", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionTitle(page, "DISPLAY OPTIONS", 3)
    
    UIFramework.CreateToggle(page, "Box ESP", Config.ESP.ShowBox, function(state)
        Config.ESP.ShowBox = state
    end, 4)
    
    UIFramework.CreateToggle(page, "Name ESP", Config.ESP.ShowName, function(state)
        Config.ESP.ShowName = state
    end, 5)
    
    UIFramework.CreateToggle(page, "Distance", Config.ESP.ShowDistance, function(state)
        Config.ESP.ShowDistance = state
    end, 6)
    
    UIFramework.CreateToggle(page, "Health Bar", Config.ESP.ShowHealth, function(state)
        Config.ESP.ShowHealth = state
    end, 7)
    
    UIFramework.CreateToggle(page, "Role Tag", Config.ESP.ShowRole, function(state)
        Config.ESP.ShowRole = state
    end, 8)
    
    UIFramework.CreateSectionTitle(page, "ROLE COLORS", 9)
    
    -- Role color info
    local roleInfo = {"Killer → Red", "Survivor → Green", "Admin → Blue", "Default → Gray"}
    for idx, info in ipairs(roleInfo) do
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 0, 18)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "  • " .. info
        infoLabel.TextColor3 = Config.Theme.TextDim
        infoLabel.TextSize = 11
        infoLabel.Font = Config.UI.FontRegular
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.LayoutOrder = 9 + idx
        infoLabel.Parent = page
    end
end

--- Start ESP rendering
function ESPModule.Start()
    ESPModule.Stop() -- Clear existing
    
    ESPModule._connection = Utilities.Connect(RunService.RenderStepped, function()
        if not Config.ESP.Enabled then return end
        ESPModule.Update()
    end)
end

--- Stop ESP rendering
function ESPModule.Stop()
    -- Clean up drawings
    for _, data in pairs(ESPModule._drawings) do
        if data.billboard then data.billboard:Destroy() end
    end
    ESPModule._drawings = {}
    
    if ESPModule._connection then
        ESPModule._connection:Disconnect()
        ESPModule._connection = nil
    end
end

--- Update ESP each frame
function ESPModule.Update()
    local localRoot = Utilities.GetRootPart(LocalPlayer)
    if not localRoot then return end
    
    -- Track which players are still valid
    local activePlayers = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            activePlayers[player.UserId] = true
            local root = Utilities.GetRootPart(player)
            local humanoid = Utilities.GetHumanoid(player)
            
            if root and humanoid and humanoid.Health > 0 then
                local distance = Utilities.Distance(localRoot.Position, root.Position)
                local role = Utilities.GetRole(player)
                local roleColor = Config.ESP.RoleColors[role] or Config.ESP.RoleColors.Default
                
                -- Get or create ESP billboard
                if not ESPModule._drawings[player.UserId] then
                    ESPModule._drawings[player.UserId] = ESPModule.CreateESPBillboard(player)
                end
                
                local data = ESPModule._drawings[player.UserId]
                if data and data.billboard then
                    local char = player.Character
                    data.billboard.Adornee = root
                    data.billboard.Enabled = true
                    
                    -- Update name
                    if data.nameLabel then
                        data.nameLabel.Visible = Config.ESP.ShowName
                        data.nameLabel.Text = player.DisplayName
                        data.nameLabel.TextColor3 = roleColor
                    end
                    
                    -- Update distance
                    if data.distLabel then
                        data.distLabel.Visible = Config.ESP.ShowDistance
                        data.distLabel.Text = string.format("%.0f studs", distance)
                    end
                    
                    -- Update health
                    if data.healthBar then
                        data.healthBar.Visible = Config.ESP.ShowHealth
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        data.healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                        data.healthFill.BackgroundColor3 = Color3.fromRGB(
                            255 * (1 - healthPercent),
                            255 * healthPercent,
                            0
                        )
                    end
                    
                    -- Update role
                    if data.roleLabel then
                        data.roleLabel.Visible = Config.ESP.ShowRole
                        data.roleLabel.Text = "[" .. role .. "]"
                        data.roleLabel.TextColor3 = roleColor
                    end
                    
                    -- Update box
                    if data.boxFrame then
                        data.boxFrame.Visible = Config.ESP.ShowBox
                        local stroke = data.boxFrame:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = roleColor end
                    end
                end
            else
                -- Player dead or no character
                if ESPModule._drawings[player.UserId] then
                    if ESPModule._drawings[player.UserId].billboard then
                        ESPModule._drawings[player.UserId].billboard.Enabled = false
                    end
                end
            end
        end
    end
    
    -- Cleanup removed players
    for userId, data in pairs(ESPModule._drawings) do
        if not activePlayers[userId] then
            if data.billboard then data.billboard:Destroy() end
            ESPModule._drawings[userId] = nil
        end
    end
end

--- Create ESP billboard for a player
function ESPModule.CreateESPBillboard(player)
    local root = Utilities.GetRootPart(player)
    if not root then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ADT_ESP_" .. player.UserId
    billboard.Size = UDim2.new(0, 120, 0, 140)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    billboard.Parent = root
    billboard.MaxDistance = 500
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard
    
    Utilities.AddListLayout(container, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)
    
    -- Box frame
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "Box"
    boxFrame.Size = UDim2.new(1, -20, 0, 80)
    boxFrame.BackgroundTransparency = 0.9
    boxFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    boxFrame.Parent = container
    Utilities.AddCorner(boxFrame, UDim.new(0, 4))
    Utilities.AddStroke(boxFrame, Config.Theme.NeonBlue, 1.5, 0.2)
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 14)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = Config.Theme.NeonBlue
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = container
    
    -- Role label
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 12)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "[Default]"
    roleLabel.TextColor3 = Config.Theme.TextDim
    roleLabel.TextSize = 10
    roleLabel.Font = Enum.Font.GothamMedium
    roleLabel.TextStrokeTransparency = 0.5
    roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    roleLabel.Parent = container
    
    -- Distance label
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 12)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0 studs"
    distLabel.TextColor3 = Config.Theme.TextDim
    distLabel.TextSize = 10
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Parent = container
    
    -- Health bar
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(0.8, 0, 0, 4)
    healthBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = container
    Utilities.AddCorner(healthBar, UDim.new(0, 2))
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Config.Theme.Success
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBar
    Utilities.AddCorner(healthFill, UDim.new(0, 2))
    
    return {
        billboard = billboard,
        nameLabel = nameLabel,
        distLabel = distLabel,
        roleLabel = roleLabel,
        healthBar = healthBar,
        healthFill = healthFill,
        boxFrame = boxFrame,
    }
end

-- ══════════════════════════════════════════════════════════════
-- [8] TELEPORT SAFETY MODULE
-- ══════════════════════════════════════════════════════════════

local TeleportModule = {}
TeleportModule._connection = nil
TeleportModule._statusLabel = nil

function MainGUI.BuildTeleportPage()
    local page = MainGUI._contentPages["Teleport"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 30)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "⚡  Teleport Safety"
    pageTitle.TextColor3 = Config.Theme.Text
    pageTitle.TextSize = 18
    pageTitle.Font = Config.UI.Font
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 16)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "Auto-teleport when Killer is within danger radius of Survivor"
    pageDesc.TextColor3 = Config.Theme.TextDim
    pageDesc.TextSize = 11
    pageDesc.Font = Config.UI.FontRegular
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateToggle(page, "Enable Teleport Safety", Config.Teleport.Enabled, function(state)
        Config.Teleport.Enabled = state
        if state then
            TeleportModule.Start()
            NotificationSystem.Notify("Teleport", "Safety teleport enabled", "success")
        else
            TeleportModule.Stop()
            NotificationSystem.Notify("Teleport", "Safety teleport disabled", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionTitle(page, "SETTINGS", 3)
    
    UIFramework.CreateSlider(page, "Detection Radius", 10, 100, Config.Teleport.Radius, function(val)
        Config.Teleport.Radius = val
    end, 4)
    
    UIFramework.CreateSlider(page, "Cooldown (sec)", 1, 15, Config.Teleport.Cooldown, function(val)
        Config.Teleport.Cooldown = val
    end, 5)
    
    UIFramework.CreateSectionTitle(page, "SAFE POSITION", 6)
    
    UIFramework.CreateButton(page, "Set Safe Position to Current", function()
        local root = Utilities.GetRootPart(LocalPlayer)
        if root then
            Config.Teleport.SafePosition = root.Position + Vector3.new(0, 5, 0)
            NotificationSystem.Notify("Teleport", string.format("Safe position set: %.0f, %.0f, %.0f", 
                Config.Teleport.SafePosition.X, Config.Teleport.SafePosition.Y, Config.Teleport.SafePosition.Z), "success")
        end
    end, 7)
    
    UIFramework.CreateSectionTitle(page, "STATUS", 8)
    
    TeleportModule._statusLabel = UIFramework.CreateStatusLabel(page, "Status", "Idle", 9)
end

--- Start teleport safety monitoring
function TeleportModule.Start()
    TeleportModule.Stop()
    
    TeleportModule._connection = Utilities.Connect(RunService.Heartbeat, function()
        if not Config.Teleport.Enabled then return end
        
        local localRoot = Utilities.GetRootPart(LocalPlayer)
        if not localRoot then return end
        
        local now = tick()
        if now - Config.Teleport.LastTeleportTime < Config.Teleport.Cooldown then
            if TeleportModule._statusLabel then
                local remaining = math.ceil(Config.Teleport.Cooldown - (now - Config.Teleport.LastTeleportTime))
                TeleportModule._statusLabel.SetValue("Cooldown: " .. remaining .. "s", Config.Theme.Warning)
            end
            return
        end
        
        -- Find Killers and Survivors
        local dangerDetected = false
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local role = Utilities.GetRole(player)
                local root = Utilities.GetRootPart(player)
                
                if role == "Killer" and root then
                    -- Check against all survivors
                    for _, survivor in ipairs(Players:GetPlayers()) do
                        local sRole = Utilities.GetRole(survivor)
                        local sRoot = Utilities.GetRootPart(survivor)
                        
                        if sRole == "Survivor" and sRoot then
                            local dist = Utilities.Distance(root.Position, sRoot.Position)
                            
                            if dist <= Config.Teleport.Radius then
                                dangerDetected = true
                                -- Teleport admin
                                localRoot.CFrame = CFrame.new(Config.Teleport.SafePosition)
                                Config.Teleport.LastTeleportTime = tick()
                                
                                if TeleportModule._statusLabel then
                                    TeleportModule._statusLabel.SetValue("TELEPORTED!", Config.Theme.Danger)
                                end
                                
                                NotificationSystem.Notify("Teleport Safety", 
                                    string.format("Killer near Survivor! (%.0f studs) - Teleported to safety", dist), "warning", 3)
                                return
                            end
                        end
                    end
                end
            end
        end
        
        if TeleportModule._statusLabel then
            if not dangerDetected then
                TeleportModule._statusLabel.SetValue("Monitoring...", Config.Theme.Success)
            end
        end
    end)
end

--- Stop teleport safety
function TeleportModule.Stop()
    if TeleportModule._connection then
        TeleportModule._connection:Disconnect()
        TeleportModule._connection = nil
    end
    if TeleportModule._statusLabel then
        TeleportModule._statusLabel.SetValue("Disabled", Config.Theme.TextMuted)
    end
end

-- ══════════════════════════════════════════════════════════════
-- [9] SPEED RUN MODULE
-- ══════════════════════════════════════════════════════════════

local SpeedModule = {}

function MainGUI.BuildSpeedPage()
    local page = MainGUI._contentPages["Speed"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 30)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "🏃  Speed Run"
    pageTitle.TextColor3 = Config.Theme.Text
    pageTitle.TextSize = 18
    pageTitle.Font = Config.UI.Font
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 16)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "Adjust walk speed multiplier for movement testing"
    pageDesc.TextColor3 = Config.Theme.TextDim
    pageDesc.TextSize = 11
    pageDesc.Font = Config.UI.FontRegular
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateSectionTitle(page, "SPEED MULTIPLIER", 2)
    
    UIFramework.CreateSlider(page, "Speed (1x - 10x)", Config.Speed.Min, Config.Speed.Max, Config.Speed.Value, function(val)
        Config.Speed.Value = val
        SpeedModule.Apply()
    end, 3)
    
    -- Speed info panel
    local infoPanel = UIFramework.CreatePanel(page, UDim2.new(1, 0, 0, 50), nil, "SpeedInfo")
    infoPanel.LayoutOrder = 4
    Utilities.AddPadding(infoPanel, 10, 12, 10, 12)
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, 0, 1, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "💡 Speed is applied in realtime. Default WalkSpeed = 16. Multiplier affects WalkSpeed directly."
    infoText.TextColor3 = Config.Theme.TextDim
    infoText.TextSize = 10
    infoText.Font = Config.UI.FontRegular
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextWrapped = true
    infoText.Parent = infoPanel
    
    UIFramework.CreateButton(page, "Reset to Default", function()
        Config.Speed.Value = 1
        SpeedModule.Apply()
        NotificationSystem.Notify("Speed", "Speed reset to 1x", "info")
    end, 5)
end

--- Apply speed multiplier
function SpeedModule.Apply()
    local humanoid = Utilities.GetHumanoid(LocalPlayer)
    if humanoid then
        humanoid.WalkSpeed = Config.Speed.DefaultWalkSpeed * Config.Speed.Value
    end
end

-- Keep speed synced with character respawn
Utilities.Connect(LocalPlayer.CharacterAdded, function(char)
    task.wait(0.5)
    SpeedModule.Apply()
end)

-- ══════════════════════════════════════════════════════════════
-- [10] POV CIRCLE MODULE
-- ══════════════════════════════════════════════════════════════

local POVModule = {}
POVModule._circle = nil
POVModule._connection = nil
POVModule._spectateConnection = nil

function MainGUI.BuildPOVPage()
    local page = MainGUI._contentPages["POV"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 30)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "◎  POV Circle"
    pageTitle.TextColor3 = Config.Theme.Text
    pageTitle.TextSize = 18
    pageTitle.Font = Config.UI.Font
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 16)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "Center screen circle overlay + Spectate survivor for debugging"
    pageDesc.TextColor3 = Config.Theme.TextDim
    pageDesc.TextSize = 11
    pageDesc.Font = Config.UI.FontRegular
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateToggle(page, "Enable POV Circle", Config.POV.Enabled, function(state)
        Config.POV.Enabled = state
        if state then
            POVModule.CreateCircle()
            NotificationSystem.Notify("POV", "Circle overlay enabled", "success")
        else
            POVModule.DestroyCircle()
            NotificationSystem.Notify("POV", "Circle overlay disabled", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionTitle(page, "CIRCLE SETTINGS", 3)
    
    UIFramework.CreateSlider(page, "Radius (px)", 30, 300, Config.POV.Radius, function(val)
        Config.POV.Radius = val
        POVModule.UpdateCircle()
    end, 4)
    
    UIFramework.CreateSlider(page, "Thickness", 1, 10, Config.POV.Thickness, function(val)
        Config.POV.Thickness = val
        POVModule.UpdateCircle()
    end, 5)
    
    -- Opacity slider (1-100 mapped to 0-1)
    UIFramework.CreateSlider(page, "Opacity (%)", 10, 100, math.floor(Config.POV.Opacity * 100), function(val)
        Config.POV.Opacity = val / 100
        POVModule.UpdateCircle()
    end, 6)
    
    UIFramework.CreateColorPicker(page, "Color", Config.POV.Color, function(color)
        Config.POV.Color = color
        POVModule.UpdateCircle()
    end, 7)
    
    UIFramework.CreateSectionTitle(page, "SPECTATE", 8)
    
    local playerDropdown = UIFramework.CreatePlayerDropdown(page, "Target Survivor", function(player)
        Config.POV.TargetPlayer = player
    end, 9)
    
    UIFramework.CreateToggle(page, "Spectate Target", false, function(state)
        Config.POV.Spectating = state
        if state then
            POVModule.StartSpectate()
        else
            POVModule.StopSpectate()
        end
    end, 10)
end

--- Create the POV circle on screen
function POVModule.CreateCircle()
    POVModule.DestroyCircle()
    
    local screenGui = MainGUI._screenGui
    if not screenGui then return end
    
    -- Create circle using a Frame with UIStroke (ring effect)
    local circleFrame = Instance.new("Frame")
    circleFrame.Name = "POVCircle"
    circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    circleFrame.Size = UDim2.new(0, Config.POV.Radius * 2, 0, Config.POV.Radius * 2)
    circleFrame.BackgroundTransparency = 1
    circleFrame.Parent = screenGui
    
    Utilities.AddCorner(circleFrame, UDim.new(0.5, 0))
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.POV.Color
    stroke.Thickness = Config.POV.Thickness
    stroke.Transparency = 1 - Config.POV.Opacity
    stroke.Parent = circleFrame
    
    -- Crosshair lines (small)
    local crossSize = 8
    for _, data in ipairs({
        {UDim2.new(0.5, -1, 0.5, -crossSize), UDim2.new(0, 2, 0, crossSize - 2)}, -- top
        {UDim2.new(0.5, -1, 0.5, 2), UDim2.new(0, 2, 0, crossSize - 2)}, -- bottom
        {UDim2.new(0.5, -crossSize, 0.5, -1), UDim2.new(0, crossSize - 2, 0, 2)}, -- left
        {UDim2.new(0.5, 2, 0.5, -1), UDim2.new(0, crossSize - 2, 0, 2)}, -- right
    }) do
        local line = Instance.new("Frame")
        line.Position = data[1]
        line.Size = data[2]
        line.BackgroundColor3 = Config.POV.Color
        line.BackgroundTransparency = 1 - Config.POV.Opacity
        line.BorderSizePixel = 0
        line.Parent = circleFrame
    end
    
    POVModule._circle = circleFrame
    
    -- Fade in
    circleFrame.Size = UDim2.new(0, 0, 0, 0)
    Utilities.Tween(circleFrame, {
        Size = UDim2.new(0, Config.POV.Radius * 2, 0, Config.POV.Radius * 2)
    }, 0.4, Enum.EasingStyle.Back)
end

--- Update circle appearance
function POVModule.UpdateCircle()
    if not POVModule._circle then return end
    
    local circle = POVModule._circle
    Utilities.Tween(circle, {
        Size = UDim2.new(0, Config.POV.Radius * 2, 0, Config.POV.Radius * 2)
    }, 0.2)
    
    local stroke = circle:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = Config.POV.Color
        stroke.Thickness = Config.POV.Thickness
        stroke.Transparency = 1 - Config.POV.Opacity
    end
    
    -- Update crosshair lines
    for _, child in ipairs(circle:GetChildren()) do
        if child:IsA("Frame") then
            child.BackgroundColor3 = Config.POV.Color
            child.BackgroundTransparency = 1 - Config.POV.Opacity
        end
    end
end

--- Destroy circle
function POVModule.DestroyCircle()
    if POVModule._circle then
        POVModule._circle:Destroy()
        POVModule._circle = nil
    end
end

--- Start spectating a target
function POVModule.StartSpectate()
    POVModule.StopSpectate()
    
    if not Config.POV.TargetPlayer then
        NotificationSystem.Notify("POV", "No target selected!", "warning")
        return
    end
    
    POVModule._spectateConnection = Utilities.Connect(RunService.RenderStepped, function()
        if not Config.POV.Spectating or not Config.POV.TargetPlayer then return end
        
        local targetRoot = Utilities.GetRootPart(Config.POV.TargetPlayer)
        if targetRoot then
            Camera.CameraSubject = Config.POV.TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end)
    
    NotificationSystem.Notify("POV", "Spectating: " .. Config.POV.TargetPlayer.Name, "info")
end

--- Stop spectating
function POVModule.StopSpectate()
    if POVModule._spectateConnection then
        POVModule._spectateConnection:Disconnect()
        POVModule._spectateConnection = nil
    end
    
    -- Reset camera to local player
    local humanoid = Utilities.GetHumanoid(LocalPlayer)
    if humanoid then
        Camera.CameraSubject = humanoid
    end
end

-- ══════════════════════════════════════════════════════════════
-- [11] ON POINT MODULE
-- ══════════════════════════════════════════════════════════════

local OnPointModule = {}
OnPointModule._connection = nil
OnPointModule._indicators = {}

function MainGUI.BuildOnPointPage()
    local page = MainGUI._contentPages["OnPoint"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 30)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text = "🎯  On Point"
    pageTitle.TextColor3 = Config.Theme.Text
    pageTitle.TextSize = 18
    pageTitle.Font = Config.UI.Font
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 28)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "Debug indicator when target Survivor is within POV circle area.\nHelps observe hitbox, collision, and damage areas."
    pageDesc.TextColor3 = Config.Theme.TextDim
    pageDesc.TextSize = 11
    pageDesc.Font = Config.UI.FontRegular
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.TextWrapped = true
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateToggle(page, "Enable On Point", Config.OnPoint.Enabled, function(state)
        Config.OnPoint.Enabled = state
        if state then
            OnPointModule.Start()
            NotificationSystem.Notify("On Point", "Debug indicators enabled", "success")
        else
            OnPointModule.Stop()
            NotificationSystem.Notify("On Point", "Debug indicators disabled", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionTitle(page, "SETTINGS", 3)
    
    UIFramework.CreateSlider(page, "Detection Radius", 20, 200, Config.OnPoint.Radius, function(val)
        Config.OnPoint.Radius = val
    end, 4)
    
    UIFramework.CreateToggle(page, "Smooth Update", Config.OnPoint.SmoothUpdate, function(state)
        Config.OnPoint.SmoothUpdate = state
    end, 5)
    
    UIFramework.CreateSlider(page, "Transparency (%)", 10, 90, math.floor(Config.OnPoint.Transparency * 100), function(val)
        Config.OnPoint.Transparency = val / 100
    end, 6)
    
    UIFramework.CreateColorPicker(page, "Color", Config.OnPoint.Color, function(color)
        Config.OnPoint.Color = color
    end, 7)
end

--- Start On Point detection
function OnPointModule.Start()
    OnPointModule.Stop()
    
    OnPointModule._connection = Utilities.Connect(RunService.RenderStepped, function()
        if not Config.OnPoint.Enabled then return end
        
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local povRadius = Config.POV.Radius -- Use POV circle radius as reference
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local role = Utilities.GetRole(player)
                
                if role == "Survivor" then
                    local root = Utilities.GetRootPart(player)
                    if root then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                        
                        if onScreen then
                            local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                            local distFromCenter = (screenVec - screenCenter).Magnitude
                            
                            if distFromCenter <= povRadius then
                                -- Target is inside POV circle - show indicator
                                OnPointModule.ShowIndicator(player, root)
                            else
                                OnPointModule.HideIndicator(player)
                            end
                        else
                            OnPointModule.HideIndicator(player)
                        end
                    else
                        OnPointModule.HideIndicator(player)
                    end
                end
            end
        end
        
        -- Cleanup disconnected players
        for userId, indicator in pairs(OnPointModule._indicators) do
            local found = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.UserId == userId then found = true break end
            end
            if not found then
                if indicator.billboard then indicator.billboard:Destroy() end
                OnPointModule._indicators[userId] = nil
            end
        end
    end)
end

--- Show debug indicator on a player
function OnPointModule.ShowIndicator(player, root)
    if not OnPointModule._indicators[player.UserId] then
        -- Create indicator billboard
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ADT_OnPoint_" .. player.UserId
        billboard.Size = UDim2.new(0, 100, 0, 100)
        billboard.StudsOffset = Vector3.new(0, 0, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = root
        billboard.Adornee = root
        billboard.MaxDistance = 300
        
        -- Debug ring (hitbox visualization)
        local ring = Instance.new("Frame")
        ring.Size = UDim2.new(1, 0, 1, 0)
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.new(0.5, 0, 0.5, 0)
        ring.BackgroundTransparency = 1
        ring.Parent = billboard
        Utilities.AddCorner(ring, UDim.new(0.5, 0))
        
        local ringStroke = Instance.new("UIStroke")
        ringStroke.Color = Config.OnPoint.Color
        ringStroke.Thickness = 2
        ringStroke.Transparency = Config.OnPoint.Transparency
        ringStroke.Parent = ring
        
        -- Center dot
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BackgroundColor3 = Config.OnPoint.Color
        dot.BackgroundTransparency = Config.OnPoint.Transparency
        dot.Parent = billboard
        Utilities.AddCorner(dot, UDim.new(0.5, 0))
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 14)
        label.Position = UDim2.new(0, 0, 1, 5)
        label.BackgroundTransparency = 1
        label.Text = "● ON POINT"
        label.TextColor3 = Config.OnPoint.Color
        label.TextSize = 10
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0.3
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = billboard
        
        -- Distance debug info
        local distInfo = Instance.new("TextLabel")
        distInfo.Size = UDim2.new(1, 0, 0, 12)
        distInfo.Position = UDim2.new(0, 0, 1, 20)
        distInfo.BackgroundTransparency = 1
        distInfo.Text = ""
        distInfo.TextColor3 = Config.Theme.TextDim
        distInfo.TextSize = 9
        distInfo.Font = Enum.Font.Gotham
        distInfo.TextStrokeTransparency = 0.3
        distInfo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distInfo.Parent = billboard
        
        OnPointModule._indicators[player.UserId] = {
            billboard = billboard,
            ring = ring,
            ringStroke = ringStroke,
            dot = dot,
            label = label,
            distInfo = distInfo,
        }
        
        -- Animate in
        ring.Size = UDim2.new(0, 0, 0, 0)
        Utilities.Tween(ring, {Size = UDim2.new(1, 0, 1, 0)}, 0.3, Enum.EasingStyle.Back)
    end
    
    -- Update indicator
    local indicator = OnPointModule._indicators[player.UserId]
    if indicator then
        indicator.billboard.Adornee = root
        indicator.billboard.Enabled = true
        
        -- Update color/transparency
        indicator.ringStroke.Color = Config.OnPoint.Color
        indicator.ringStroke.Transparency = Config.OnPoint.Transparency
        indicator.dot.BackgroundColor3 = Config.OnPoint.Color
        indicator.dot.BackgroundTransparency = Config.OnPoint.Transparency
        indicator.label.TextColor3 = Config.OnPoint.Color
        
        -- Distance info
        local localRoot = Utilities.GetRootPart(LocalPlayer)
        if localRoot then
            local dist = Utilities.Distance(localRoot.Position, root.Position)
            indicator.distInfo.Text = string.format("Dist: %.1f | Pos: %.0f, %.0f, %.0f",
                dist, root.Position.X, root.Position.Y, root.Position.Z)
        end
        
        -- Pulse animation on ring
        if Config.OnPoint.SmoothUpdate then
            local pulseSize = 1 + math.sin(tick() * 3) * 0.05
            indicator.ring.Size = UDim2.new(pulseSize, 0, pulseSize, 0)
        end
    end
end

--- Hide indicator for a player
function OnPointModule.HideIndicator(player)
    local indicator = OnPointModule._indicators[player.UserId]
    if indicator and indicator.billboard.Enabled then
        indicator.billboard.Enabled = false
    end
end

--- Stop On Point module
function OnPointModule.Stop()
    if OnPointModule._connection then
        OnPointModule._connection:Disconnect()
        OnPointModule._connection = nil
    end
    
    for _, indicator in pairs(OnPointModule._indicators) do
        if indicator.billboard then indicator.billboard:Destroy() end
    end
    OnPointModule._indicators = {}
end

-- ══════════════════════════════════════════════════════════════
-- [12] CLEANUP
-- ══════════════════════════════════════════════════════════════

function Cleanup()
    -- Stop all modules
    ESPModule.Stop()
    TeleportModule.Stop()
    POVModule.DestroyCircle()
    POVModule.StopSpectate()
    OnPointModule.Stop()
    
    -- Reset speed
    Config.Speed.Value = 1
    local humanoid = Utilities.GetHumanoid(LocalPlayer)
    if humanoid then
        humanoid.WalkSpeed = Config.Speed.DefaultWalkSpeed
    end
    
    -- Disconnect all tracked connections
    for _, connection in ipairs(Utilities._connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    Utilities._connections = {}
    
    -- Destroy all tracked instances
    for _, instance in ipairs(Utilities._instances) do
        if instance and instance.Parent then
            instance:Destroy()
        end
    end
    Utilities._instances = {}
    
    print("[ADT] Cleanup complete. All modules stopped and resources freed.")
end

-- ══════════════════════════════════════════════════════════════
-- [13] INIT
-- ══════════════════════════════════════════════════════════════

-- Prevent duplicate execution
if _G.ADT_Running then
    -- Cleanup previous instance
    if _G.ADT_Cleanup then
        _G.ADT_Cleanup()
    end
end

_G.ADT_Running = true
_G.ADT_Cleanup = Cleanup

-- Initialize the GUI
MainGUI.Init()

print("═══════════════════════════════════════")
print("  ⚡ ADT Dev Tools v" .. Config.Version .. " Loaded")
print("  Admin Development Tools")
print("  For Private Map Testing & Debugging")
print("═══════════════════════════════════════")
