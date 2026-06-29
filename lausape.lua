--[[
    ========================================================
    HOSHI v2.1.0
    Admin Development Tools
    Terminal-Style Interface
    For Private Map Testing & Debugging
    ========================================================
    
    Structure:
    [1]  CONFIG
    [2]  UTILITIES
    [3]  NOTIFICATION SYSTEM
    [4]  UI FRAMEWORK
    [5]  SPLASH SCREEN
    [6]  MAIN GUI BUILDER
    [7]  ESP MODULE
    [8]  TELEPORT SAFETY MODULE
    [9]  SPEED RUN MODULE
    [10] POV CIRCLE MODULE
    [11] ON POINT MODULE
    [12] CLEANUP
    [13] INIT
--]]

-- ========================================================
-- [1] CONFIG
-- ========================================================

local Config = {
    Theme = {
        Background = Color3.fromRGB(8, 8, 12),
        Surface = Color3.fromRGB(12, 12, 18),
        SurfaceLight = Color3.fromRGB(18, 18, 26),
        SurfaceHover = Color3.fromRGB(24, 24, 34),
        SurfaceBright = Color3.fromRGB(30, 30, 42),
        
        Primary = Color3.fromRGB(0, 255, 160),
        PrimaryDim = Color3.fromRGB(0, 180, 110),
        PrimaryDark = Color3.fromRGB(0, 120, 80),
        Secondary = Color3.fromRGB(0, 200, 255),
        Tertiary = Color3.fromRGB(180, 130, 255),
        
        Text = Color3.fromRGB(200, 210, 200),
        TextBright = Color3.fromRGB(230, 240, 230),
        TextDim = Color3.fromRGB(100, 120, 100),
        TextMuted = Color3.fromRGB(50, 65, 50),
        
        Success = Color3.fromRGB(0, 220, 100),
        Warning = Color3.fromRGB(220, 180, 0),
        Danger = Color3.fromRGB(220, 50, 50),
        Info = Color3.fromRGB(0, 180, 220),
        
        Border = Color3.fromRGB(30, 40, 30),
        BorderLight = Color3.fromRGB(40, 55, 40),
        BorderActive = Color3.fromRGB(0, 255, 160),
        
        TerminalGreen = Color3.fromRGB(0, 255, 160),
        TerminalDim = Color3.fromRGB(0, 100, 60),
        TerminalBG = Color3.fromRGB(5, 5, 8),
    },
    
    UI = {
        WindowSize = UDim2.new(0, 820, 0, 560),
        CornerRadius = UDim.new(0, 4),
        CornerRadiusSmall = UDim.new(0, 3),
        CornerRadiusTiny = UDim.new(0, 2),
        AnimationSpeed = 0.3,
        AnimationSpeedFast = 0.15,
        AnimationEasing = Enum.EasingStyle.Quad,
        SidebarWidth = 170,
        HeaderHeight = 40,
        Font = Enum.Font.Code,
        FontBold = Enum.Font.Code,
        FontMono = Enum.Font.Code,
    },
    
    ESP = {
        Enabled = false,
        ShowBox = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowRole = true,
        RoleColors = {
            Killer = Color3.fromRGB(220, 50, 50),
            Survivor = Color3.fromRGB(0, 220, 100),
            Admin = Color3.fromRGB(0, 180, 220),
            Default = Color3.fromRGB(150, 150, 150),
        },
    },
    
    Teleport = {
        Enabled = false,
        Radius = 35,
        Cooldown = 2,
        FleeDistance = 100,
        LastTeleportTime = 0,
        Status = "OFFLINE",
    },
    
    Speed = {
        Value = 1,
        Min = 1,
        Max = 10,
        DefaultWalkSpeed = 16,
    },
    
    POV = {
        Enabled = false,
        Radius = 100,
        Thickness = 2,
        Opacity = 0.8,
        Color = Color3.fromRGB(0, 255, 160),
        TargetPlayer = nil,
        Spectating = false,
    },
    
    OnPoint = {
        Enabled = false,
        DamageRadius = 50,
        SmoothUpdate = true,
        Transparency = 0.4,
        Color = Color3.fromRGB(220, 180, 0),
        TrackNearest = true,
    },
    
    Version = "2.1.0",
    ScriptName = "HOSHI",
}

-- ========================================================
-- [2] UTILITIES
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Utilities = {}
Utilities._connections = {}
Utilities._instances = {}

function Utilities.TweenInfo(duration, style, direction)
    return TweenInfo.new(
        duration or Config.UI.AnimationSpeed,
        style or Config.UI.AnimationEasing,
        direction or Enum.EasingDirection.Out
    )
end

function Utilities.Tween(instance, properties, duration, style, direction, callback)
    if not instance or not instance.Parent then return nil end
    local info = Utilities.TweenInfo(duration, style, direction)
    local tween = TweenService:Create(instance, info, properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function Utilities.Connect(signal, func)
    local connection = signal:Connect(func)
    table.insert(Utilities._connections, connection)
    return connection
end

function Utilities.Track(instance)
    table.insert(Utilities._instances, instance)
    return instance
end

function Utilities.Distance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utilities.GetRootPart(player)
    local char = player and player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

function Utilities.GetHumanoid(player)
    local char = player and player.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function Utilities.GetRole(player)
    local role = player:GetAttribute("Role")
    if role then return role end
    local roleVal = player:FindFirstChild("Role")
    if roleVal and roleVal:IsA("StringValue") then return roleVal.Value end
    if player.Team then return player.Team.Name end
    return "Default"
end

function Utilities.AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Config.UI.CornerRadius
    corner.Parent = parent
    return corner
end

function Utilities.AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Utilities.AddPadding(parent, top, right, bottom, left)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.Parent = parent
    return padding
end

function Utilities.AddListLayout(parent, padding, direction, hAlign, vAlign)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 4)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

-- Find a safe flee position away from a threat
function Utilities.FindFleePosition(fromPos, threatPos, fleeDistance)
    local direction = (fromPos - threatPos).Unit
    
    -- Try primary direction first
    local candidates = {
        direction,
        (direction + Vector3.new(0.5, 0, 0.5)).Unit,
        (direction + Vector3.new(-0.5, 0, 0.5)).Unit,
        (direction + Vector3.new(0.5, 0, -0.5)).Unit,
        (direction + Vector3.new(-0.5, 0, -0.5)).Unit,
        (direction + Vector3.new(1, 0, 0)).Unit,
        (direction + Vector3.new(-1, 0, 0)).Unit,
        (direction + Vector3.new(0, 0, 1)).Unit,
        (direction + Vector3.new(0, 0, -1)).Unit,
    }
    
    for _, dir in ipairs(candidates) do
        local targetPos = fromPos + dir * fleeDistance
        -- Raycast downward to find ground
        local rayOrigin = targetPos + Vector3.new(0, 50, 0)
        local rayDirection = Vector3.new(0, -200, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local result = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
        if result then
            local groundPos = result.Position + Vector3.new(0, 3, 0)
            -- Verify this position is actually far from the threat
            if Utilities.Distance(groundPos, threatPos) >= fleeDistance * 0.8 then
                return groundPos
            end
        end
    end
    
    -- Fallback: just go in the opposite direction at a height
    return fromPos + direction * fleeDistance + Vector3.new(0, 5, 0)
end

-- ========================================================
-- [3] NOTIFICATION SYSTEM
-- ========================================================

local NotificationSystem = {}
NotificationSystem._container = nil

function NotificationSystem.Init(screenGui)
    local container = Instance.new("Frame")
    container.Name = "NotifContainer"
    container.Size = UDim2.new(0, 340, 1, 0)
    container.Position = UDim2.new(1, -350, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    Utilities.AddPadding(container, 60, 0, 10, 0)
    Utilities.AddListLayout(container, 4, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
    
    NotificationSystem._container = container
end

function NotificationSystem.Notify(title, message, notifType, duration)
    notifType = notifType or "info"
    duration = duration or 3
    
    local accentColor = Config.Theme.Primary
    local prefix = "[INFO]"
    if notifType == "success" then 
        accentColor = Config.Theme.Success
        prefix = "[OK]"
    elseif notifType == "warning" then 
        accentColor = Config.Theme.Warning
        prefix = "[WARN]"
    elseif notifType == "error" then 
        accentColor = Config.Theme.Danger
        prefix = "[ERR]"
    end
    
    local frame = Instance.new("Frame")
    frame.Name = "Notif"
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.BackgroundColor3 = Config.Theme.Surface
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = NotificationSystem._container
    
    Utilities.AddCorner(frame, Config.UI.CornerRadiusSmall)
    Utilities.AddStroke(frame, accentColor, 1, 0.3)
    
    -- Left accent line
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 2, 1, 0)
    accent.BackgroundColor3 = accentColor
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    -- Title with prefix
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -14, 0, 18)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = prefix .. " " .. (title or "")
    titleLabel.TextColor3 = accentColor
    titleLabel.TextSize = 11
    titleLabel.Font = Config.UI.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -14, 0, 16)
    msgLabel.Position = UDim2.new(0, 10, 0, 24)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = "> " .. (message or "")
    msgLabel.TextColor3 = Config.Theme.TextDim
    msgLabel.TextSize = 10
    msgLabel.Font = Config.UI.FontMono
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = frame
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 1)
    progressBar.Position = UDim2.new(0, 0, 1, -1)
    progressBar.BackgroundColor3 = accentColor
    progressBar.BackgroundTransparency = 0.3
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame
    
    -- Timestamp
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 60, 0, 14)
    timeLabel.Position = UDim2.new(1, -65, 0, 6)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M:%S")
    timeLabel.TextColor3 = Config.Theme.TextMuted
    timeLabel.TextSize = 9
    timeLabel.Font = Config.UI.FontMono
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = frame
    
    -- Animate in
    frame.Position = UDim2.new(1, 0, 0, 0)
    frame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    msgLabel.TextTransparency = 1
    accent.BackgroundTransparency = 1
    timeLabel.TextTransparency = 1
    
    Utilities.Tween(frame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.25)
    Utilities.Tween(titleLabel, {TextTransparency = 0}, 0.25)
    Utilities.Tween(msgLabel, {TextTransparency = 0}, 0.25)
    Utilities.Tween(accent, {BackgroundTransparency = 0}, 0.25)
    Utilities.Tween(timeLabel, {TextTransparency = 0}, 0.25)
    
    -- Progress countdown
    Utilities.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 1)}, duration, Enum.EasingStyle.Linear)
    
    -- Auto dismiss
    task.delay(duration, function()
        if frame and frame.Parent then
            Utilities.Tween(frame, {BackgroundTransparency = 1, Position = UDim2.new(1, 0, 0, 0)}, 0.2)
            Utilities.Tween(titleLabel, {TextTransparency = 1}, 0.2)
            Utilities.Tween(msgLabel, {TextTransparency = 1}, 0.2)
            Utilities.Tween(accent, {BackgroundTransparency = 1}, 0.2)
            Utilities.Tween(timeLabel, {TextTransparency = 1}, 0.2)
            task.delay(0.25, function()
                if frame and frame.Parent then frame:Destroy() end
            end)
        end
    end)
end

-- ========================================================
-- [4] UI FRAMEWORK
-- ========================================================

local UIFramework = {}

-- Terminal-style section header
function UIFramework.CreateSectionHeader(parent, text, layoutOrder)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 22)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "--- " .. string.upper(text) .. " ---"
    label.TextColor3 = Config.Theme.TextMuted
    label.TextSize = 10
    label.Font = Config.UI.FontMono
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    return container
end

-- Terminal-style toggle
function UIFramework.CreateToggle(parent, label, default, callback, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. label
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.5
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    
    -- Label
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -80, 1, 0)
    textLabel.Position = UDim2.new(0, 8, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "> " .. label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 11
    textLabel.Font = Config.UI.FontMono
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    -- Status text
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 60, 1, 0)
    statusLabel.Position = UDim2.new(1, -68, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = default and "[ON]" or "[OFF]"
    statusLabel.TextColor3 = default and Config.Theme.Success or Config.Theme.Danger
    statusLabel.TextSize = 11
    statusLabel.Font = Config.UI.FontMono
    statusLabel.TextXAlignment = Enum.TextXAlignment.Right
    statusLabel.Parent = container
    
    local isOn = default or false
    
    -- Click button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = container
    
    Utilities.Connect(button.MouseButton1Click, function()
        isOn = not isOn
        statusLabel.Text = isOn and "[ON]" or "[OFF]"
        Utilities.Tween(statusLabel, {
            TextColor3 = isOn and Config.Theme.Success or Config.Theme.Danger
        }, Config.UI.AnimationSpeedFast)
        if callback then callback(isOn) end
    end)
    
    Utilities.Connect(button.MouseEnter, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.2}, 0.1)
        Utilities.Tween(textLabel, {TextColor3 = Config.Theme.Primary}, 0.1)
    end)
    Utilities.Connect(button.MouseLeave, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.5}, 0.1)
        Utilities.Tween(textLabel, {TextColor3 = Config.Theme.Text}, 0.1)
    end)
    
    return {
        Container = container,
        SetState = function(state)
            isOn = state
            statusLabel.Text = isOn and "[ON]" or "[OFF]"
            statusLabel.TextColor3 = isOn and Config.Theme.Success or Config.Theme.Danger
        end,
        GetState = function() return isOn end,
    }
end

-- Terminal-style slider with text input
function UIFramework.CreateSlider(parent, label, min, max, default, callback, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. label
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.5
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    Utilities.AddPadding(container, 4, 8, 4, 8)
    
    -- Label + value
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 16)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = container
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.65, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "> " .. label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 10
    textLabel.Font = Config.UI.FontMono
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = headerFrame
    
    -- Value TextBox
    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0, 45, 0, 16)
    valueBox.Position = UDim2.new(1, -45, 0, 0)
    valueBox.BackgroundColor3 = Config.Theme.TerminalBG
    valueBox.BackgroundTransparency = 0.3
    valueBox.TextColor3 = Config.Theme.Primary
    valueBox.TextSize = 10
    valueBox.Font = Config.UI.FontMono
    valueBox.Text = tostring(default)
    valueBox.ClearTextOnFocus = false
    valueBox.Parent = headerFrame
    Utilities.AddCorner(valueBox, Config.UI.CornerRadiusTiny)
    Utilities.AddStroke(valueBox, Config.Theme.Border, 1, 0.5)
    
    -- Slider track
    local trackFrame = Instance.new("Frame")
    trackFrame.Name = "Track"
    trackFrame.Size = UDim2.new(1, 0, 0, 4)
    trackFrame.Position = UDim2.new(0, 0, 0, 26)
    trackFrame.BackgroundColor3 = Config.Theme.TerminalBG
    trackFrame.BorderSizePixel = 0
    trackFrame.Parent = container
    Utilities.AddCorner(trackFrame, UDim.new(0, 2))
    
    -- Slider fill
    local initAlpha = math.clamp((default - min) / (max - min), 0, 1)
    local fillFrame = Instance.new("Frame")
    fillFrame.Size = UDim2.new(initAlpha, 0, 1, 0)
    fillFrame.BackgroundColor3 = Config.Theme.Primary
    fillFrame.BackgroundTransparency = 0.3
    fillFrame.BorderSizePixel = 0
    fillFrame.Parent = trackFrame
    Utilities.AddCorner(fillFrame, UDim.new(0, 2))
    
    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(initAlpha, -5, 0.5, -5)
    knob.BackgroundColor3 = Config.Theme.Primary
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = trackFrame
    Utilities.AddCorner(knob, UDim.new(0, 2))
    
    local currentValue = default
    local dragging = false
    
    local function updateSlider(alpha)
        alpha = math.clamp(alpha, 0, 1)
        currentValue = math.floor(min + (max - min) * alpha + 0.5)
        currentValue = math.clamp(currentValue, min, max)
        
        local newAlpha = (currentValue - min) / (max - min)
        fillFrame.Size = UDim2.new(newAlpha, 0, 1, 0)
        knob.Position = UDim2.new(newAlpha, -5, 0.5, -5)
        valueBox.Text = tostring(currentValue)
        
        if callback then callback(currentValue) end
    end
    
    -- Click/drag on track
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 0, 0, 16)
    sliderButton.Position = UDim2.new(0, 0, 0, -6)
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
    
    Utilities.Connect(valueBox.FocusLost, function()
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

-- Terminal-style button
function UIFramework.CreateButton(parent, label, callback, layoutOrder, accentColor)
    accentColor = accentColor or Config.Theme.Primary
    
    local container = Instance.new("Frame")
    container.Name = "Btn_" .. label
    container.Size = UDim2.new(1, 0, 0, 26)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.5
    container.LayoutOrder = layoutOrder or 0
    container.ClipsDescendants = true
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    Utilities.AddStroke(container, Config.Theme.Border, 1, 0.5)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "[ " .. label .. " ]"
    textLabel.TextColor3 = accentColor
    textLabel.TextSize = 10
    textLabel.Font = Config.UI.FontMono
    textLabel.Parent = container
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 2
    button.Parent = container
    
    Utilities.Connect(button.MouseButton1Click, function()
        -- Flash effect
        Utilities.Tween(container, {BackgroundTransparency = 0}, 0.05, nil, nil, function()
            Utilities.Tween(container, {BackgroundTransparency = 0.5}, 0.15)
        end)
        if callback then callback() end
    end)
    
    Utilities.Connect(button.MouseEnter, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.3}, 0.1)
        Utilities.Tween(textLabel, {TextColor3 = Config.Theme.TextBright}, 0.1)
    end)
    Utilities.Connect(button.MouseLeave, function()
        Utilities.Tween(container, {BackgroundTransparency = 0.5}, 0.1)
        Utilities.Tween(textLabel, {TextColor3 = accentColor}, 0.1)
    end)
    
    return {
        Container = container,
        SetText = function(text) textLabel.Text = "[ " .. text .. " ]" end,
    }
end

-- Terminal-style status display
function UIFramework.CreateStatusLine(parent, label, defaultText, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Status_" .. label
    container.Size = UDim2.new(1, 0, 0, 18)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 8, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.RichText = true
    textLabel.Text = string.format(
        '<font color="#%s">%s:</font> <font color="#%s">%s</font>',
        Config.Theme.TextDim:ToHex(), label,
        Config.Theme.Text:ToHex(), defaultText or "N/A"
    )
    textLabel.TextSize = 10
    textLabel.Font = Config.UI.FontMono
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    return {
        Container = container,
        SetValue = function(text, color)
            local valColor = color or Config.Theme.Text
            textLabel.Text = string.format(
                '<font color="#%s">%s:</font> <font color="#%s">%s</font>',
                Config.Theme.TextDim:ToHex(), label,
                valColor:ToHex(), text
            )
        end,
    }
end

-- Player dropdown
function UIFramework.CreatePlayerDropdown(parent, label, callback, layoutOrder)
    local container = Instance.new("Frame")
    container.Name = "Drop_" .. label
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.5
    container.LayoutOrder = layoutOrder or 0
    container.ClipsDescendants = true
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.5, 0, 0, 28)
    textLabel.Position = UDim2.new(0, 8, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "> " .. label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 10
    textLabel.Font = Config.UI.FontMono
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(0.5, -8, 0, 28)
    selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = "[NONE]"
    selectedLabel.TextColor3 = Config.Theme.Primary
    selectedLabel.TextSize = 10
    selectedLabel.Font = Config.UI.FontMono
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    selectedLabel.Parent = container
    
    local isOpen = false
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 28)
    optionsFrame.BackgroundColor3 = Config.Theme.TerminalBG
    optionsFrame.BackgroundTransparency = 0.1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ScrollBarThickness = 2
    optionsFrame.ScrollBarImageColor3 = Config.Theme.Primary
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsFrame.Visible = false
    optionsFrame.Parent = container
    Utilities.AddCorner(optionsFrame, Config.UI.CornerRadiusTiny)
    
    local optLayout = Utilities.AddListLayout(optionsFrame, 1)
    Utilities.AddPadding(optionsFrame, 2, 2, 2, 2)
    
    local selectedPlayer = nil
    
    local function refreshOptions()
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                count = count + 1
                local role = Utilities.GetRole(player)
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 22)
                optBtn.BackgroundColor3 = Config.Theme.SurfaceLight
                optBtn.BackgroundTransparency = 0.6
                optBtn.Text = "  " .. player.Name .. " [" .. role .. "]"
                optBtn.TextColor3 = Config.Theme.Text
                optBtn.TextSize = 10
                optBtn.Font = Config.UI.FontMono
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.Parent = optionsFrame
                Utilities.AddCorner(optBtn, Config.UI.CornerRadiusTiny)
                
                Utilities.Connect(optBtn.MouseButton1Click, function()
                    selectedPlayer = player
                    selectedLabel.Text = "[" .. player.Name .. "]"
                    isOpen = false
                    Utilities.Tween(container, {Size = UDim2.new(1, 0, 0, 28)}, 0.15)
                    task.delay(0.15, function() optionsFrame.Visible = false end)
                    if callback then callback(player) end
                end)
                
                Utilities.Connect(optBtn.MouseEnter, function()
                    Utilities.Tween(optBtn, {BackgroundTransparency = 0.3}, 0.08)
                end)
                Utilities.Connect(optBtn.MouseLeave, function()
                    Utilities.Tween(optBtn, {BackgroundTransparency = 0.6}, 0.08)
                end)
            end
        end
        
        optionsFrame.CanvasSize = UDim2.new(0, 0, 0, count * 23 + 4)
    end
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 28)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 3
    toggleBtn.Parent = container
    
    Utilities.Connect(toggleBtn.MouseButton1Click, function()
        isOpen = not isOpen
        if isOpen then
            refreshOptions()
            optionsFrame.Visible = true
            local optCount = math.max(#Players:GetPlayers() - 1, 1)
            local height = math.min(optCount * 23 + 4, 100)
            optionsFrame.Size = UDim2.new(1, 0, 0, height)
            Utilities.Tween(container, {Size = UDim2.new(1, 0, 0, 28 + height)}, 0.2)
        else
            Utilities.Tween(container, {Size = UDim2.new(1, 0, 0, 28)}, 0.15, nil, nil, function()
                optionsFrame.Visible = false
            end)
        end
    end)
    
    return {
        Container = container,
        GetSelected = function() return selectedPlayer end,
        SetSelected = function(p)
            selectedPlayer = p
            selectedLabel.Text = p and ("[" .. p.Name .. "]") or "[NONE]"
        end,
    }
end

-- Color picker (preset grid)
function UIFramework.CreateColorPicker(parent, label, default, callback, layoutOrder)
    local presetColors = {
        Config.Theme.Primary,
        Config.Theme.Secondary,
        Config.Theme.Success,
        Config.Theme.Warning,
        Config.Theme.Danger,
        Config.Theme.Tertiary,
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 120, 200),
    }
    
    local container = Instance.new("Frame")
    container.Name = "ColorPick_" .. label
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundColor3 = Config.Theme.SurfaceLight
    container.BackgroundTransparency = 0.5
    container.LayoutOrder = layoutOrder or 0
    container.Parent = parent
    
    Utilities.AddCorner(container, Config.UI.CornerRadiusTiny)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 55, 1, 0)
    textLabel.Position = UDim2.new(0, 8, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "> " .. label
    textLabel.TextColor3 = Config.Theme.Text
    textLabel.TextSize = 10
    textLabel.Font = Config.UI.FontMono
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    local colorsFrame = Instance.new("Frame")
    colorsFrame.Size = UDim2.new(1, -70, 0, 16)
    colorsFrame.Position = UDim2.new(0, 65, 0.5, -8)
    colorsFrame.BackgroundTransparency = 1
    colorsFrame.Parent = container
    
    Utilities.AddListLayout(colorsFrame, 3, Enum.FillDirection.Horizontal)
    
    local selectedColor = default
    
    for _, color in ipairs(presetColors) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 16, 0, 16)
        colorBtn.BackgroundColor3 = color
        colorBtn.Text = ""
        colorBtn.Parent = colorsFrame
        Utilities.AddCorner(colorBtn, Config.UI.CornerRadiusTiny)
        
        if color == default then
            Utilities.AddStroke(colorBtn, Config.Theme.TextBright, 1, 0)
        end
        
        Utilities.Connect(colorBtn.MouseButton1Click, function()
            selectedColor = color
            for _, child in ipairs(colorsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    local s = child:FindFirstChildOfClass("UIStroke")
                    if s then s:Destroy() end
                end
            end
            Utilities.AddStroke(colorBtn, Config.Theme.TextBright, 1, 0)
            if callback then callback(color) end
        end)
    end
    
    return {
        Container = container,
        GetColor = function() return selectedColor end,
    }
end

-- ========================================================
-- [5] SPLASH SCREEN
-- ========================================================

local SplashScreen = {}

function SplashScreen.Show(screenGui, callback)
    local splash = Instance.new("Frame")
    splash.Name = "Splash"
    splash.Size = UDim2.new(1, 0, 1, 0)
    splash.BackgroundColor3 = Config.Theme.TerminalBG
    splash.ZIndex = 100
    splash.Parent = screenGui
    
    local center = Instance.new("Frame")
    center.Size = UDim2.new(0, 400, 0, 220)
    center.Position = UDim2.new(0.5, -200, 0.5, -110)
    center.BackgroundTransparency = 1
    center.ZIndex = 101
    center.Parent = splash
    
    -- Terminal boot text
    local lines = {
        {text = "HOSHI Development Terminal v" .. Config.Version, color = Config.Theme.Primary, delay = 0.1},
        {text = "========================================", color = Config.Theme.TextMuted, delay = 0.05},
        {text = "", color = Config.Theme.Text, delay = 0.1},
        {text = "Initializing core systems...", color = Config.Theme.Text, delay = 0.3},
        {text = "[OK] Config module loaded", color = Config.Theme.Success, delay = 0.2},
        {text = "[OK] UI framework ready", color = Config.Theme.Success, delay = 0.15},
        {text = "[OK] ESP module initialized", color = Config.Theme.Success, delay = 0.2},
        {text = "[OK] Teleport safety module ready", color = Config.Theme.Success, delay = 0.15},
        {text = "[OK] POV system configured", color = Config.Theme.Success, delay = 0.2},
        {text = "[OK] OnPoint targeting loaded", color = Config.Theme.Success, delay = 0.15},
        {text = "[OK] Cleanup handlers registered", color = Config.Theme.Success, delay = 0.1},
        {text = "", color = Config.Theme.Text, delay = 0.1},
        {text = "All systems nominal. Starting GUI...", color = Config.Theme.Primary, delay = 0.3},
        {text = "========================================", color = Config.Theme.TextMuted, delay = 0.1},
    }
    
    local yOffset = 0
    local lineLabels = {}
    
    for i, lineData in ipairs(lines) do
        local lineLabel = Instance.new("TextLabel")
        lineLabel.Size = UDim2.new(1, 0, 0, 14)
        lineLabel.Position = UDim2.new(0, 0, 0, yOffset)
        lineLabel.BackgroundTransparency = 1
        lineLabel.Text = lineData.text
        lineLabel.TextColor3 = lineData.color
        lineLabel.TextSize = 11
        lineLabel.Font = Config.UI.FontMono
        lineLabel.TextXAlignment = Enum.TextXAlignment.Left
        lineLabel.TextTransparency = 1
        lineLabel.ZIndex = 101
        lineLabel.Parent = center
        
        lineLabels[i] = lineLabel
        yOffset = yOffset + 14
    end
    
    -- Animate lines appearing one by one
    task.spawn(function()
        for i, lineData in ipairs(lines) do
            if lineLabels[i] and lineLabels[i].Parent then
                Utilities.Tween(lineLabels[i], {TextTransparency = 0}, 0.1)
                task.wait(lineData.delay)
            end
        end
        
        task.wait(0.4)
        
        -- Fade out
        Utilities.Tween(splash, {BackgroundTransparency = 1}, 0.4)
        for _, lbl in ipairs(lineLabels) do
            if lbl and lbl.Parent then
                Utilities.Tween(lbl, {TextTransparency = 1}, 0.3)
            end
        end
        
        task.wait(0.5)
        if splash and splash.Parent then splash:Destroy() end
        if callback then callback() end
    end)
end

-- ========================================================
-- [6] MAIN GUI BUILDER
-- ========================================================

local MainGUI = {}
MainGUI._screenGui = nil
MainGUI._mainFrame = nil
MainGUI._contentPages = {}
MainGUI._activeTab = nil
MainGUI._minimized = false

function MainGUI.Init()
    local existing = LocalPlayer.PlayerGui:FindFirstChild("HOSHI_DevTools")
    if existing then existing:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HOSHI_DevTools"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.Parent = LocalPlayer.PlayerGui
    
    MainGUI._screenGui = screenGui
    Utilities.Track(screenGui)
    
    NotificationSystem.Init(screenGui)
    
    SplashScreen.Show(screenGui, function()
        MainGUI.BuildMainWindow()
        NotificationSystem.Notify("HOSHI", "Admin Development Tools v" .. Config.Version .. " loaded successfully.", "success", 3)
    end)
end

function MainGUI.BuildMainWindow()
    local screenGui = MainGUI._screenGui
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = Config.UI.WindowSize
    mainFrame.Position = UDim2.new(0.5, -410, 0.5, -280)
    mainFrame.BackgroundColor3 = Config.Theme.Background
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    Utilities.AddCorner(mainFrame, Config.UI.CornerRadius)
    Utilities.AddStroke(mainFrame, Config.Theme.Border, 1, 0)
    
    MainGUI._mainFrame = mainFrame
    
    -- Animate in
    mainFrame.BackgroundTransparency = 1
    local targetSize = Config.UI.WindowSize
    mainFrame.Size = UDim2.new(0, 750, 0, 500)
    
    Utilities.Tween(mainFrame, {
        BackgroundTransparency = 0,
        Size = targetSize,
    }, 0.4, Enum.EasingStyle.Quint)
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, Config.UI.HeaderHeight)
    header.BackgroundColor3 = Config.Theme.TerminalBG
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    Utilities.AddCorner(header, Config.UI.CornerRadius)
    
    -- Bottom cover for header corners
    local headerCover = Instance.new("Frame")
    headerCover.Size = UDim2.new(1, 0, 0, 10)
    headerCover.Position = UDim2.new(0, 0, 1, -10)
    headerCover.BackgroundColor3 = Config.Theme.TerminalBG
    headerCover.BorderSizePixel = 0
    headerCover.Parent = header
    
    -- Header bottom border
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Config.Theme.Primary
    headerLine.BackgroundTransparency = 0.5
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.RichText = true
    title.Text = string.format(
        '<font color="#%s">HOSHI</font> <font color="#%s">// dev-tools v%s</font>',
        Config.Theme.Primary:ToHex(),
        Config.Theme.TextDim:ToHex(),
        Config.Version
    )
    title.TextSize = 13
    title.Font = Config.UI.FontMono
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Terminal cursor blink in title area
    local cursor = Instance.new("TextLabel")
    cursor.Size = UDim2.new(0, 10, 0, 14)
    cursor.Position = UDim2.new(0, 270, 0.5, -7)
    cursor.BackgroundTransparency = 1
    cursor.Text = "_"
    cursor.TextColor3 = Config.Theme.Primary
    cursor.TextSize = 13
    cursor.Font = Config.UI.FontMono
    cursor.Parent = header
    
    -- Blink animation
    task.spawn(function()
        while cursor and cursor.Parent do
            cursor.TextTransparency = 0
            task.wait(0.5)
            if not cursor or not cursor.Parent then break end
            cursor.TextTransparency = 1
            task.wait(0.5)
        end
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundColor3 = Config.Theme.Danger
    closeBtn.BackgroundTransparency = 0.8
    closeBtn.Text = "x"
    closeBtn.TextColor3 = Config.Theme.Danger
    closeBtn.TextSize = 12
    closeBtn.Font = Config.UI.FontMono
    closeBtn.Parent = header
    Utilities.AddCorner(closeBtn, Config.UI.CornerRadiusTiny)
    
    Utilities.Connect(closeBtn.MouseButton1Click, function() MainGUI.Close() end)
    Utilities.Connect(closeBtn.MouseEnter, function()
        Utilities.Tween(closeBtn, {BackgroundTransparency = 0.3}, 0.1)
    end)
    Utilities.Connect(closeBtn.MouseLeave, function()
        Utilities.Tween(closeBtn, {BackgroundTransparency = 0.8}, 0.1)
    end)
    
    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -66, 0.5, -14)
    minBtn.BackgroundColor3 = Config.Theme.Warning
    minBtn.BackgroundTransparency = 0.8
    minBtn.Text = "-"
    minBtn.TextColor3 = Config.Theme.Warning
    minBtn.TextSize = 12
    minBtn.Font = Config.UI.FontMono
    minBtn.Parent = header
    Utilities.AddCorner(minBtn, Config.UI.CornerRadiusTiny)
    
    Utilities.Connect(minBtn.MouseButton1Click, function() MainGUI.ToggleMinimize() end)
    Utilities.Connect(minBtn.MouseEnter, function()
        Utilities.Tween(minBtn, {BackgroundTransparency = 0.3}, 0.1)
    end)
    Utilities.Connect(minBtn.MouseLeave, function()
        Utilities.Tween(minBtn, {BackgroundTransparency = 0.8}, 0.1)
    end)
    
    -- Draggable
    MainGUI.MakeDraggable(header, mainFrame)
    
    -- Body
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -Config.UI.HeaderHeight)
    body.Position = UDim2.new(0, 0, 0, Config.UI.HeaderHeight)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.Parent = mainFrame
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, Config.UI.SidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = Config.Theme.TerminalBG
    sidebar.BorderSizePixel = 0
    sidebar.Parent = body
    
    -- Sidebar right border
    local sbBorder = Instance.new("Frame")
    sbBorder.Size = UDim2.new(0, 1, 1, 0)
    sbBorder.Position = UDim2.new(1, 0, 0, 0)
    sbBorder.BackgroundColor3 = Config.Theme.Border
    sbBorder.BorderSizePixel = 0
    sbBorder.Parent = sidebar
    
    local sbContent = Instance.new("Frame")
    sbContent.Size = UDim2.new(1, 0, 1, 0)
    sbContent.BackgroundTransparency = 1
    sbContent.Parent = sidebar
    Utilities.AddPadding(sbContent, 8, 6, 8, 6)
    Utilities.AddListLayout(sbContent, 2)
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -Config.UI.SidebarWidth, 1, 0)
    contentArea.Position = UDim2.new(0, Config.UI.SidebarWidth, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true
    contentArea.Parent = body
    
    -- Define tabs
    local tabs = {
        {name = "ESP", label = "esp-player"},
        {name = "Teleport", label = "teleport"},
        {name = "Speed", label = "speed-run"},
        {name = "POV", label = "pov-circle"},
        {name = "OnPoint", label = "on-point"},
    }
    
    -- Sidebar header
    local sbHeader = Instance.new("TextLabel")
    sbHeader.Size = UDim2.new(1, 0, 0, 20)
    sbHeader.BackgroundTransparency = 1
    sbHeader.Text = "-- MODULES --"
    sbHeader.TextColor3 = Config.Theme.TextMuted
    sbHeader.TextSize = 9
    sbHeader.Font = Config.UI.FontMono
    sbHeader.TextXAlignment = Enum.TextXAlignment.Left
    sbHeader.LayoutOrder = 0
    sbHeader.Parent = sbContent
    
    local tabButtons = {}
    
    for i, tab in ipairs(tabs) do
        -- Create page
        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. tab.name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Config.Theme.Primary
        page.ScrollBarImageTransparency = 0.5
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = contentArea
        
        Utilities.AddPadding(page, 10, 12, 10, 12)
        local pageLayout = Utilities.AddListLayout(page, 6)
        
        Utilities.Connect(pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 24)
        end)
        
        MainGUI._contentPages[tab.name] = page
        
        -- Sidebar button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tab.name
        tabBtn.Size = UDim2.new(1, 0, 0, 24)
        tabBtn.BackgroundColor3 = Config.Theme.Primary
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = ""
        tabBtn.LayoutOrder = i
        tabBtn.Parent = sbContent
        Utilities.AddCorner(tabBtn, Config.UI.CornerRadiusTiny)
        
        -- Tab indicator
        local tabIndicator = Instance.new("Frame")
        tabIndicator.Size = UDim2.new(0, 2, 0.6, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0.2, 0)
        tabIndicator.BackgroundColor3 = Config.Theme.Primary
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Parent = tabBtn
        Utilities.AddCorner(tabIndicator, UDim.new(0, 1))
        
        -- Tab label
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -10, 1, 0)
        tabLabel.Position = UDim2.new(0, 10, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = "> " .. tab.label
        tabLabel.TextColor3 = Config.Theme.TextDim
        tabLabel.TextSize = 10
        tabLabel.Font = Config.UI.FontMono
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabBtn
        
        tabButtons[tab.name] = {button = tabBtn, label = tabLabel, indicator = tabIndicator}
        
        Utilities.Connect(tabBtn.MouseButton1Click, function()
            MainGUI.SwitchTab(tab.name, tabButtons)
        end)
        
        Utilities.Connect(tabBtn.MouseEnter, function()
            if MainGUI._activeTab ~= tab.name then
                Utilities.Tween(tabBtn, {BackgroundTransparency = 0.85}, 0.1)
            end
        end)
        Utilities.Connect(tabBtn.MouseLeave, function()
            if MainGUI._activeTab ~= tab.name then
                Utilities.Tween(tabBtn, {BackgroundTransparency = 1}, 0.1)
            end
        end)
    end
    
    -- Sidebar footer
    local sbFooter = Instance.new("TextLabel")
    sbFooter.Size = UDim2.new(1, 0, 0, 30)
    sbFooter.BackgroundTransparency = 1
    sbFooter.RichText = true
    sbFooter.Text = string.format(
        '<font color="#%s">SESSION ACTIVE</font>',
        Config.Theme.TerminalDim:ToHex()
    )
    sbFooter.TextSize = 8
    sbFooter.Font = Config.UI.FontMono
    sbFooter.TextXAlignment = Enum.TextXAlignment.Center
    sbFooter.LayoutOrder = 100
    sbFooter.Parent = sbContent
    
    -- Watermark
    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(0, 250, 0, 16)
    watermark.Position = UDim2.new(0, 8, 1, -20)
    watermark.BackgroundTransparency = 1
    watermark.Text = "HOSHI v" .. Config.Version .. " // admin-dev-tools"
    watermark.TextColor3 = Config.Theme.Primary
    watermark.TextTransparency = 0.7
    watermark.TextSize = 9
    watermark.Font = Config.UI.FontMono
    watermark.TextXAlignment = Enum.TextXAlignment.Left
    watermark.Parent = MainGUI._screenGui
    
    -- Build pages
    MainGUI.BuildESPPage()
    MainGUI.BuildTeleportPage()
    MainGUI.BuildSpeedPage()
    MainGUI.BuildPOVPage()
    MainGUI.BuildOnPointPage()
    
    -- Default tab
    MainGUI.SwitchTab("ESP", tabButtons)
end

function MainGUI.SwitchTab(moduleName, tabButtons)
    if MainGUI._activeTab and tabButtons[MainGUI._activeTab] then
        local prev = tabButtons[MainGUI._activeTab]
        Utilities.Tween(prev.button, {BackgroundTransparency = 1}, 0.15)
        Utilities.Tween(prev.label, {TextColor3 = Config.Theme.TextDim}, 0.15)
        Utilities.Tween(prev.indicator, {BackgroundTransparency = 1}, 0.15)
        
        if MainGUI._contentPages[MainGUI._activeTab] then
            local page = MainGUI._contentPages[MainGUI._activeTab]
            page.Visible = false
        end
    end
    
    MainGUI._activeTab = moduleName
    local curr = tabButtons[moduleName]
    Utilities.Tween(curr.button, {BackgroundTransparency = 0.85}, 0.15)
    Utilities.Tween(curr.label, {TextColor3 = Config.Theme.Primary}, 0.15)
    Utilities.Tween(curr.indicator, {BackgroundTransparency = 0}, 0.15)
    
    if MainGUI._contentPages[moduleName] then
        local page = MainGUI._contentPages[moduleName]
        page.Visible = true
        page.Position = UDim2.new(0.03, 0, 0, 0)
        Utilities.Tween(page, {Position = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quint)
    end
end

function MainGUI.MakeDraggable(dragHandle, targetFrame)
    local dragging = false
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
    
    Utilities.Connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function MainGUI.ToggleMinimize()
    MainGUI._minimized = not MainGUI._minimized
    local frame = MainGUI._mainFrame
    
    if MainGUI._minimized then
        Utilities.Tween(frame, {Size = UDim2.new(0, 820, 0, Config.UI.HeaderHeight)}, 0.25)
    else
        Utilities.Tween(frame, {Size = Config.UI.WindowSize}, 0.25)
    end
end

function MainGUI.Close()
    local frame = MainGUI._mainFrame
    Utilities.Tween(frame, {Size = UDim2.new(0, 750, 0, 500), BackgroundTransparency = 1}, 0.25, nil, nil, function()
        Cleanup()
    end)
end

-- ========================================================
-- [7] ESP MODULE
-- ========================================================

local ESPModule = {}
ESPModule._drawings = {}
ESPModule._connection = nil

function MainGUI.BuildESPPage()
    local page = MainGUI._contentPages["ESP"]
    if not page then return end
    
    -- Page header
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 20)
    pageTitle.BackgroundTransparency = 1
    pageTitle.RichText = true
    pageTitle.Text = string.format(
        '<font color="#%s">$</font> <font color="#%s">ESP PLAYER MODULE</font>',
        Config.Theme.Primary:ToHex(), Config.Theme.TextBright:ToHex()
    )
    pageTitle.TextSize = 13
    pageTitle.Font = Config.UI.FontMono
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 14)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "// Visual player overlay for development debugging"
    pageDesc.TextColor3 = Config.Theme.TextMuted
    pageDesc.TextSize = 10
    pageDesc.Font = Config.UI.FontMono
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateToggle(page, "Enable ESP", Config.ESP.Enabled, function(state)
        Config.ESP.Enabled = state
        if state then
            ESPModule.Start()
            NotificationSystem.Notify("ESP", "Player visualization enabled", "success")
        else
            ESPModule.Stop()
            NotificationSystem.Notify("ESP", "Player visualization disabled", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionHeader(page, "DISPLAY OPTIONS", 3)
    
    UIFramework.CreateToggle(page, "Box ESP", Config.ESP.ShowBox, function(s) Config.ESP.ShowBox = s end, 4)
    UIFramework.CreateToggle(page, "Name Tag", Config.ESP.ShowName, function(s) Config.ESP.ShowName = s end, 5)
    UIFramework.CreateToggle(page, "Distance", Config.ESP.ShowDistance, function(s) Config.ESP.ShowDistance = s end, 6)
    UIFramework.CreateToggle(page, "Health Bar", Config.ESP.ShowHealth, function(s) Config.ESP.ShowHealth = s end, 7)
    UIFramework.CreateToggle(page, "Role Tag", Config.ESP.ShowRole, function(s) Config.ESP.ShowRole = s end, 8)
    
    UIFramework.CreateSectionHeader(page, "ROLE COLOR MAP", 9)
    
    local roleInfos = {
        "Killer   = RED    (220,50,50)",
        "Survivor = GREEN  (0,220,100)",
        "Admin    = CYAN   (0,180,220)",
        "Default  = GRAY   (150,150,150)",
    }
    for idx, info in ipairs(roleInfos) do
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 0, 14)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "  " .. info
        infoLabel.TextColor3 = Config.Theme.TextDim
        infoLabel.TextSize = 10
        infoLabel.Font = Config.UI.FontMono
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.LayoutOrder = 9 + idx
        infoLabel.Parent = page
    end
end

function ESPModule.Start()
    ESPModule.Stop()
    
    ESPModule._connection = Utilities.Connect(RunService.RenderStepped, function()
        if not Config.ESP.Enabled then return end
        ESPModule.Update()
    end)
end

function ESPModule.Stop()
    for _, data in pairs(ESPModule._drawings) do
        if data.billboard then data.billboard:Destroy() end
    end
    ESPModule._drawings = {}
    
    if ESPModule._connection then
        ESPModule._connection:Disconnect()
        ESPModule._connection = nil
    end
end

function ESPModule.Update()
    local localRoot = Utilities.GetRootPart(LocalPlayer)
    if not localRoot then return end
    
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
                
                if not ESPModule._drawings[player.UserId] then
                    ESPModule._drawings[player.UserId] = ESPModule.CreateESPBillboard(player)
                end
                
                local data = ESPModule._drawings[player.UserId]
                if data and data.billboard then
                    data.billboard.Adornee = root
                    data.billboard.Enabled = true
                    
                    if data.nameLabel then
                        data.nameLabel.Visible = Config.ESP.ShowName
                        data.nameLabel.Text = player.DisplayName
                        data.nameLabel.TextColor3 = roleColor
                    end
                    
                    if data.distLabel then
                        data.distLabel.Visible = Config.ESP.ShowDistance
                        data.distLabel.Text = string.format("[%.0f studs]", distance)
                    end
                    
                    if data.healthBar then
                        data.healthBar.Visible = Config.ESP.ShowHealth
                        local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        data.healthFill.Size = UDim2.new(hp, 0, 1, 0)
                        data.healthFill.BackgroundColor3 = Color3.fromRGB(
                            255 * (1 - hp), 255 * hp, 0
                        )
                    end
                    
                    if data.roleLabel then
                        data.roleLabel.Visible = Config.ESP.ShowRole
                        data.roleLabel.Text = "[" .. role .. "]"
                        data.roleLabel.TextColor3 = roleColor
                    end
                    
                    if data.boxFrame then
                        data.boxFrame.Visible = Config.ESP.ShowBox
                        local stroke = data.boxFrame:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = roleColor end
                    end
                end
            else
                if ESPModule._drawings[player.UserId] then
                    if ESPModule._drawings[player.UserId].billboard then
                        ESPModule._drawings[player.UserId].billboard.Enabled = false
                    end
                end
            end
        end
    end
    
    for userId, data in pairs(ESPModule._drawings) do
        if not activePlayers[userId] then
            if data.billboard then data.billboard:Destroy() end
            ESPModule._drawings[userId] = nil
        end
    end
end

function ESPModule.CreateESPBillboard(player)
    local root = Utilities.GetRootPart(player)
    if not root then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HOSHI_ESP_" .. player.UserId
    billboard.Size = UDim2.new(0, 100, 0, 120)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    billboard.MaxDistance = 500
    billboard.Parent = root
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard
    
    Utilities.AddListLayout(container, 1, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)
    
    -- Box
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, -10, 0, 65)
    boxFrame.BackgroundTransparency = 0.92
    boxFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    boxFrame.Parent = container
    Utilities.AddCorner(boxFrame, Config.UI.CornerRadiusTiny)
    Utilities.AddStroke(boxFrame, Config.Theme.Primary, 1, 0.3)
    
    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = Config.Theme.Primary
    nameLabel.TextSize = 10
    nameLabel.Font = Config.UI.FontMono
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = container
    
    -- Role
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 10)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "[Default]"
    roleLabel.TextColor3 = Config.Theme.TextDim
    roleLabel.TextSize = 9
    roleLabel.Font = Config.UI.FontMono
    roleLabel.TextStrokeTransparency = 0.3
    roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    roleLabel.Parent = container
    
    -- Distance
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 10)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "[0 studs]"
    distLabel.TextColor3 = Config.Theme.TextDim
    distLabel.TextSize = 9
    distLabel.Font = Config.UI.FontMono
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Parent = container
    
    -- Health bar
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(0.7, 0, 0, 3)
    healthBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = container
    Utilities.AddCorner(healthBar, UDim.new(0, 1))
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Config.Theme.Success
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBar
    Utilities.AddCorner(healthFill, UDim.new(0, 1))
    
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

-- ========================================================
-- [8] TELEPORT SAFETY MODULE
-- ========================================================

local TeleportModule = {}
TeleportModule._connection = nil
TeleportModule._statusLabel = nil

function MainGUI.BuildTeleportPage()
    local page = MainGUI._contentPages["Teleport"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 20)
    pageTitle.BackgroundTransparency = 1
    pageTitle.RichText = true
    pageTitle.Text = string.format(
        '<font color="#%s">$</font> <font color="#%s">TELEPORT SAFETY MODULE</font>',
        Config.Theme.Primary:ToHex(), Config.Theme.TextBright:ToHex()
    )
    pageTitle.TextSize = 13
    pageTitle.Font = Config.UI.FontMono
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 26)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "// Auto-flee when Killer approaches within detection radius.\n// Teleports admin AWAY from killer by flee distance."
    pageDesc.TextColor3 = Config.Theme.TextMuted
    pageDesc.TextSize = 10
    pageDesc.Font = Config.UI.FontMono
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.TextWrapped = true
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateToggle(page, "Enable Teleport Safety", Config.Teleport.Enabled, function(state)
        Config.Teleport.Enabled = state
        if state then
            TeleportModule.Start()
            NotificationSystem.Notify("TELEPORT", "Safety system ONLINE", "success")
        else
            TeleportModule.Stop()
            NotificationSystem.Notify("TELEPORT", "Safety system OFFLINE", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionHeader(page, "DETECTION", 3)
    
    UIFramework.CreateSlider(page, "Detection Radius (studs)", 10, 100, Config.Teleport.Radius, function(val)
        Config.Teleport.Radius = val
    end, 4)
    
    UIFramework.CreateSlider(page, "Flee Distance (studs)", 50, 200, Config.Teleport.FleeDistance, function(val)
        Config.Teleport.FleeDistance = val
    end, 5)
    
    UIFramework.CreateSlider(page, "Cooldown (sec)", 1, 15, Config.Teleport.Cooldown, function(val)
        Config.Teleport.Cooldown = val
    end, 6)
    
    UIFramework.CreateSectionHeader(page, "MONITORING", 7)
    
    TeleportModule._statusLabel = UIFramework.CreateStatusLine(page, "STATUS", "OFFLINE", 8)
end

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
                TeleportModule._statusLabel.SetValue("COOLDOWN [" .. remaining .. "s]", Config.Theme.Warning)
            end
            return
        end
        
        -- Find nearest Killer to admin
        local nearestKiller = nil
        local nearestKillerDist = math.huge
        local nearestKillerRoot = nil
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local role = Utilities.GetRole(player)
                local root = Utilities.GetRootPart(player)
                
                if role == "Killer" and root then
                    local dist = Utilities.Distance(localRoot.Position, root.Position)
                    if dist < nearestKillerDist then
                        nearestKiller = player
                        nearestKillerDist = dist
                        nearestKillerRoot = root
                    end
                end
            end
        end
        
        if nearestKiller and nearestKillerDist <= Config.Teleport.Radius then
            -- Killer is within detection radius of admin - FLEE
            local fleePos = Utilities.FindFleePosition(
                localRoot.Position, 
                nearestKillerRoot.Position, 
                Config.Teleport.FleeDistance
            )
            
            localRoot.CFrame = CFrame.new(fleePos)
            Config.Teleport.LastTeleportTime = tick()
            
            if TeleportModule._statusLabel then
                TeleportModule._statusLabel.SetValue("FLED! [" .. string.format("%.0f", nearestKillerDist) .. " studs detected]", Config.Theme.Danger)
            end
            
            NotificationSystem.Notify("TELEPORT", 
                string.format("Killer '%s' detected at %.0f studs. Fled %.0f studs away.", 
                nearestKiller.Name, nearestKillerDist, Config.Teleport.FleeDistance), 
                "warning", 4)
            return
        end
        
        -- Display monitoring status
        if TeleportModule._statusLabel then
            if nearestKiller then
                TeleportModule._statusLabel.SetValue(
                    string.format("SCANNING [nearest: %s @ %.0f studs]", nearestKiller.Name, nearestKillerDist),
                    Config.Theme.Success
                )
            else
                TeleportModule._statusLabel.SetValue("SCANNING [no killers detected]", Config.Theme.Success)
            end
        end
    end)
end

function TeleportModule.Stop()
    if TeleportModule._connection then
        TeleportModule._connection:Disconnect()
        TeleportModule._connection = nil
    end
    if TeleportModule._statusLabel then
        TeleportModule._statusLabel.SetValue("OFFLINE", Config.Theme.TextMuted)
    end
end

-- ========================================================
-- [9] SPEED RUN MODULE
-- ========================================================

local SpeedModule = {}

function MainGUI.BuildSpeedPage()
    local page = MainGUI._contentPages["Speed"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 20)
    pageTitle.BackgroundTransparency = 1
    pageTitle.RichText = true
    pageTitle.Text = string.format(
        '<font color="#%s">$</font> <font color="#%s">SPEED CONTROLLER</font>',
        Config.Theme.Primary:ToHex(), Config.Theme.TextBright:ToHex()
    )
    pageTitle.TextSize = 13
    pageTitle.Font = Config.UI.FontMono
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 14)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "// Adjust walk speed multiplier for movement testing"
    pageDesc.TextColor3 = Config.Theme.TextMuted
    pageDesc.TextSize = 10
    pageDesc.Font = Config.UI.FontMono
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateSectionHeader(page, "MULTIPLIER", 2)
    
    local speedSlider = UIFramework.CreateSlider(page, "Speed (1x - 10x)", Config.Speed.Min, Config.Speed.Max, Config.Speed.Value, function(val)
        Config.Speed.Value = val
        SpeedModule.Apply()
    end, 3)
    
    UIFramework.CreateSectionHeader(page, "INFO", 4)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 36)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "  Base WalkSpeed = 16\n  Effective = BaseSpeed * Multiplier\n  Changes apply in realtime."
    infoLabel.TextColor3 = Config.Theme.TextDim
    infoLabel.TextSize = 10
    infoLabel.Font = Config.UI.FontMono
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.LayoutOrder = 5
    infoLabel.Parent = page
    
    UIFramework.CreateButton(page, "RESET TO DEFAULT", function()
        Config.Speed.Value = 1
        speedSlider.SetValue(1)
        SpeedModule.Apply()
        NotificationSystem.Notify("SPEED", "Reset to 1x (WalkSpeed = 16)", "info")
    end, 6)
end

function SpeedModule.Apply()
    local humanoid = Utilities.GetHumanoid(LocalPlayer)
    if humanoid then
        humanoid.WalkSpeed = Config.Speed.DefaultWalkSpeed * Config.Speed.Value
    end
end

Utilities.Connect(LocalPlayer.CharacterAdded, function()
    task.wait(0.5)
    if Config.Speed.Value > 1 then
        SpeedModule.Apply()
    end
end)

-- ========================================================
-- [10] POV CIRCLE MODULE
-- ========================================================

local POVModule = {}
POVModule._circle = nil
POVModule._crosshairParts = {}
POVModule._spectateConnection = nil
POVModule._followConnection = nil

function MainGUI.BuildPOVPage()
    local page = MainGUI._contentPages["POV"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 20)
    pageTitle.BackgroundTransparency = 1
    pageTitle.RichText = true
    pageTitle.Text = string.format(
        '<font color="#%s">$</font> <font color="#%s">POV CIRCLE MODULE</font>',
        Config.Theme.Primary:ToHex(), Config.Theme.TextBright:ToHex()
    )
    pageTitle.TextSize = 13
    pageTitle.Font = Config.UI.FontMono
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 26)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "// Center screen crosshair overlay.\n// Spectate follows selected player camera."
    pageDesc.TextColor3 = Config.Theme.TextMuted
    pageDesc.TextSize = 10
    pageDesc.Font = Config.UI.FontMono
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.TextWrapped = true
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateToggle(page, "Enable POV Circle", Config.POV.Enabled, function(state)
        Config.POV.Enabled = state
        if state then
            POVModule.CreateCircle()
            NotificationSystem.Notify("POV", "Circle overlay active", "success")
        else
            POVModule.DestroyCircle()
            NotificationSystem.Notify("POV", "Circle overlay disabled", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionHeader(page, "CIRCLE SETTINGS", 3)
    
    UIFramework.CreateSlider(page, "Radius (px)", 30, 300, Config.POV.Radius, function(val)
        Config.POV.Radius = val
        POVModule.UpdateCircle()
    end, 4)
    
    UIFramework.CreateSlider(page, "Thickness", 1, 10, Config.POV.Thickness, function(val)
        Config.POV.Thickness = val
        POVModule.UpdateCircle()
    end, 5)
    
    UIFramework.CreateSlider(page, "Opacity (%)", 10, 100, math.floor(Config.POV.Opacity * 100), function(val)
        Config.POV.Opacity = val / 100
        POVModule.UpdateCircle()
    end, 6)
    
    UIFramework.CreateColorPicker(page, "Color", Config.POV.Color, function(color)
        Config.POV.Color = color
        POVModule.UpdateCircle()
    end, 7)
    
    UIFramework.CreateSectionHeader(page, "SPECTATE CAMERA", 8)
    
    local playerDropdown = UIFramework.CreatePlayerDropdown(page, "Target Player", function(player)
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

function POVModule.CreateCircle()
    POVModule.DestroyCircle()
    
    local screenGui = MainGUI._screenGui
    if not screenGui then return end
    
    -- Circle frame
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
    
    -- Crosshair lines
    local crossSize = 12
    local crossLines = {
        {pos = UDim2.new(0.5, -1, 0.5, -crossSize - 4), size = UDim2.new(0, 1, 0, crossSize)},
        {pos = UDim2.new(0.5, -1, 0.5, 4), size = UDim2.new(0, 1, 0, crossSize)},
        {pos = UDim2.new(0.5, -crossSize - 4, 0.5, -1), size = UDim2.new(0, crossSize, 0, 1)},
        {pos = UDim2.new(0.5, 4, 0.5, -1), size = UDim2.new(0, crossSize, 0, 1)},
    }
    
    POVModule._crosshairParts = {}
    
    for _, lineData in ipairs(crossLines) do
        local line = Instance.new("Frame")
        line.Position = lineData.pos
        line.Size = lineData.size
        line.BackgroundColor3 = Config.POV.Color
        line.BackgroundTransparency = 1 - Config.POV.Opacity
        line.BorderSizePixel = 0
        line.Parent = circleFrame
        table.insert(POVModule._crosshairParts, line)
    end
    
    -- Center dot
    local centerDot = Instance.new("Frame")
    centerDot.Size = UDim2.new(0, 3, 0, 3)
    centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerDot.BackgroundColor3 = Config.POV.Color
    centerDot.BackgroundTransparency = 1 - Config.POV.Opacity
    centerDot.BorderSizePixel = 0
    centerDot.Parent = circleFrame
    Utilities.AddCorner(centerDot, UDim.new(0.5, 0))
    table.insert(POVModule._crosshairParts, centerDot)
    
    POVModule._circle = circleFrame
    
    -- Animate in
    circleFrame.Size = UDim2.new(0, 0, 0, 0)
    Utilities.Tween(circleFrame, {
        Size = UDim2.new(0, Config.POV.Radius * 2, 0, Config.POV.Radius * 2)
    }, 0.3, Enum.EasingStyle.Back)
end

function POVModule.UpdateCircle()
    if not POVModule._circle then return end
    
    local circle = POVModule._circle
    Utilities.Tween(circle, {
        Size = UDim2.new(0, Config.POV.Radius * 2, 0, Config.POV.Radius * 2)
    }, 0.15)
    
    local stroke = circle:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = Config.POV.Color
        stroke.Thickness = Config.POV.Thickness
        stroke.Transparency = 1 - Config.POV.Opacity
    end
    
    for _, part in ipairs(POVModule._crosshairParts) do
        if part and part.Parent then
            part.BackgroundColor3 = Config.POV.Color
            part.BackgroundTransparency = 1 - Config.POV.Opacity
        end
    end
end

function POVModule.DestroyCircle()
    if POVModule._circle then
        POVModule._circle:Destroy()
        POVModule._circle = nil
    end
    POVModule._crosshairParts = {}
end

function POVModule.StartSpectate()
    POVModule.StopSpectate()
    
    if not Config.POV.TargetPlayer then
        NotificationSystem.Notify("POV", "No target selected. Choose a player first.", "warning")
        return
    end
    
    -- Set camera to follow target
    POVModule._spectateConnection = Utilities.Connect(RunService.RenderStepped, function()
        if not Config.POV.Spectating or not Config.POV.TargetPlayer then return end
        
        local targetChar = Config.POV.TargetPlayer.Character
        if targetChar then
            local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if targetHumanoid then
                Camera.CameraSubject = targetHumanoid
            end
        end
    end)
    
    NotificationSystem.Notify("POV", "Spectating: " .. Config.POV.TargetPlayer.Name, "info")
end

function POVModule.StopSpectate()
    if POVModule._spectateConnection then
        POVModule._spectateConnection:Disconnect()
        POVModule._spectateConnection = nil
    end
    
    -- Reset camera
    local humanoid = Utilities.GetHumanoid(LocalPlayer)
    if humanoid then
        Camera.CameraSubject = humanoid
    end
end

-- ========================================================
-- [11] ON POINT MODULE
-- ========================================================

local OnPointModule = {}
OnPointModule._connection = nil
OnPointModule._indicators = {}
OnPointModule._screenIndicator = nil

function MainGUI.BuildOnPointPage()
    local page = MainGUI._contentPages["OnPoint"]
    if not page then return end
    
    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size = UDim2.new(1, 0, 0, 20)
    pageTitle.BackgroundTransparency = 1
    pageTitle.RichText = true
    pageTitle.Text = string.format(
        '<font color="#%s">$</font> <font color="#%s">ON POINT MODULE</font>',
        Config.Theme.Primary:ToHex(), Config.Theme.TextBright:ToHex()
    )
    pageTitle.TextSize = 13
    pageTitle.Font = Config.UI.FontMono
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.LayoutOrder = 0
    pageTitle.Parent = page
    
    local pageDesc = Instance.new("TextLabel")
    pageDesc.Size = UDim2.new(1, 0, 0, 36)
    pageDesc.BackgroundTransparency = 1
    pageDesc.Text = "// Debug indicator system for hitbox and collision.\n// Tracks ALL players inside POV circle area.\n// Shows position data and distance in realtime."
    pageDesc.TextColor3 = Config.Theme.TextMuted
    pageDesc.TextSize = 10
    pageDesc.Font = Config.UI.FontMono
    pageDesc.TextXAlignment = Enum.TextXAlignment.Left
    pageDesc.TextWrapped = true
    pageDesc.LayoutOrder = 1
    pageDesc.Parent = page
    
    UIFramework.CreateToggle(page, "Enable On Point", Config.OnPoint.Enabled, function(state)
        Config.OnPoint.Enabled = state
        if state then
            OnPointModule.Start()
            NotificationSystem.Notify("ON POINT", "Debug tracking ACTIVE", "success")
        else
            OnPointModule.Stop()
            NotificationSystem.Notify("ON POINT", "Debug tracking OFFLINE", "info")
        end
    end, 2)
    
    UIFramework.CreateSectionHeader(page, "DETECTION", 3)
    
    UIFramework.CreateSlider(page, "Damage Radius (studs)", 10, 200, Config.OnPoint.DamageRadius, function(val)
        Config.OnPoint.DamageRadius = val
    end, 4)
    
    UIFramework.CreateToggle(page, "Track Nearest Auto", Config.OnPoint.TrackNearest, function(s)
        Config.OnPoint.TrackNearest = s
    end, 5)
    
    UIFramework.CreateSectionHeader(page, "DISPLAY", 6)
    
    UIFramework.CreateToggle(page, "Smooth Pulse", Config.OnPoint.SmoothUpdate, function(s) Config.OnPoint.SmoothUpdate = s end, 7)
    
    UIFramework.CreateSlider(page, "Transparency (%)", 10, 90, math.floor(Config.OnPoint.Transparency * 100), function(val)
        Config.OnPoint.Transparency = val / 100
    end, 8)
    
    UIFramework.CreateColorPicker(page, "Color", Config.OnPoint.Color, function(color)
        Config.OnPoint.Color = color
    end, 9)
end

function OnPointModule.Start()
    OnPointModule.Stop()
    
    -- Create screen indicator label
    local screenGui = MainGUI._screenGui
    if screenGui then
        local indicator = Instance.new("TextLabel")
        indicator.Name = "OnPointScreenIndicator"
        indicator.Size = UDim2.new(0, 300, 0, 40)
        indicator.AnchorPoint = Vector2.new(0.5, 0)
        indicator.Position = UDim2.new(0.5, 0, 0, 60)
        indicator.BackgroundColor3 = Config.Theme.TerminalBG
        indicator.BackgroundTransparency = 0.3
        indicator.TextColor3 = Config.OnPoint.Color
        indicator.TextSize = 10
        indicator.Font = Config.UI.FontMono
        indicator.Text = ""
        indicator.TextWrapped = true
        indicator.Visible = false
        indicator.Parent = screenGui
        Utilities.AddCorner(indicator, Config.UI.CornerRadiusSmall)
        Utilities.AddStroke(indicator, Config.OnPoint.Color, 1, 0.5)
        Utilities.AddPadding(indicator, 4, 8, 4, 8)
        
        OnPointModule._screenIndicator = indicator
    end
    
    OnPointModule._connection = Utilities.Connect(RunService.RenderStepped, function()
        if not Config.OnPoint.Enabled then return end
        
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local povRadius = Config.POV.Enabled and Config.POV.Radius or 150
        
        local localRoot = Utilities.GetRootPart(LocalPlayer)
        local anyOnPoint = false
        local onPointInfo = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local root = Utilities.GetRootPart(player)
                local humanoid = Utilities.GetHumanoid(player)
                
                if root and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                    local isInsidePOV = false
                    
                    if onScreen then
                        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                        local distFromCenter = (screenVec - screenCenter).Magnitude
                        isInsidePOV = distFromCenter <= povRadius
                    end
                    
                    -- Also check 3D distance for damage radius
                    local dist3D = localRoot and Utilities.Distance(localRoot.Position, root.Position) or 9999
                    local isInDamageRange = dist3D <= Config.OnPoint.DamageRadius
                    
                    if isInsidePOV or isInDamageRange then
                        anyOnPoint = true
                        local role = Utilities.GetRole(player)
                        
                        table.insert(onPointInfo, {
                            name = player.DisplayName,
                            role = role,
                            dist = dist3D,
                            pos = root.Position,
                            inPOV = isInsidePOV,
                            inRange = isInDamageRange,
                        })
                        
                        -- Show or update billboard indicator on target
                        OnPointModule.ShowIndicator(player, root, dist3D)
                    else
                        OnPointModule.HideIndicator(player)
                    end
                else
                    OnPointModule.HideIndicator(player)
                end
            end
        end
        
        -- Update screen indicator
        if OnPointModule._screenIndicator then
            if anyOnPoint and #onPointInfo > 0 then
                OnPointModule._screenIndicator.Visible = true
                local infoLines = {"[ON POINT] Targets Detected:"}
                for _, info in ipairs(onPointInfo) do
                    local flags = ""
                    if info.inPOV then flags = flags .. "POV " end
                    if info.inRange then flags = flags .. "DMG " end
                    table.insert(infoLines, string.format(
                        "  %s [%s] dist:%.0f %s",
                        info.name, info.role, info.dist, flags
                    ))
                end
                OnPointModule._screenIndicator.Text = table.concat(infoLines, "\n")
                OnPointModule._screenIndicator.TextColor3 = Config.OnPoint.Color
                OnPointModule._screenIndicator.Size = UDim2.new(0, 340, 0, 16 + #onPointInfo * 14)
                
                local sStroke = OnPointModule._screenIndicator:FindFirstChildOfClass("UIStroke")
                if sStroke then sStroke.Color = Config.OnPoint.Color end
            else
                OnPointModule._screenIndicator.Visible = false
            end
        end
        
        -- Cleanup indicators for removed players
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

function OnPointModule.ShowIndicator(player, root, distance)
    if not OnPointModule._indicators[player.UserId] then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HOSHI_OnPoint_" .. player.UserId
        billboard.Size = UDim2.new(0, 80, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 0, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = root
        billboard.Adornee = root
        billboard.MaxDistance = 300
        
        -- Ring indicator
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
        
        -- Center marker (cross shape for terminal look)
        local hLine = Instance.new("Frame")
        hLine.Size = UDim2.new(0, 10, 0, 1)
        hLine.AnchorPoint = Vector2.new(0.5, 0.5)
        hLine.Position = UDim2.new(0.5, 0, 0.5, 0)
        hLine.BackgroundColor3 = Config.OnPoint.Color
        hLine.BackgroundTransparency = Config.OnPoint.Transparency
        hLine.BorderSizePixel = 0
        hLine.Parent = billboard
        
        local vLine = Instance.new("Frame")
        vLine.Size = UDim2.new(0, 1, 0, 10)
        vLine.AnchorPoint = Vector2.new(0.5, 0.5)
        vLine.Position = UDim2.new(0.5, 0, 0.5, 0)
        vLine.BackgroundColor3 = Config.OnPoint.Color
        vLine.BackgroundTransparency = Config.OnPoint.Transparency
        vLine.BorderSizePixel = 0
        vLine.Parent = billboard
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 120, 0, 12)
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.Position = UDim2.new(0.5, 0, 1, 4)
        label.BackgroundTransparency = 1
        label.Text = "TRACKING"
        label.TextColor3 = Config.OnPoint.Color
        label.TextSize = 9
        label.Font = Enum.Font.Code
        label.TextStrokeTransparency = 0.3
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = billboard
        
        -- Distance / Position info
        local distInfo = Instance.new("TextLabel")
        distInfo.Size = UDim2.new(0, 160, 0, 12)
        distInfo.AnchorPoint = Vector2.new(0.5, 0)
        distInfo.Position = UDim2.new(0.5, 0, 1, 16)
        distInfo.BackgroundTransparency = 1
        distInfo.Text = ""
        distInfo.TextColor3 = Config.Theme.TextDim
        distInfo.TextSize = 8
        distInfo.Font = Enum.Font.Code
        distInfo.TextStrokeTransparency = 0.3
        distInfo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distInfo.Parent = billboard
        
        OnPointModule._indicators[player.UserId] = {
            billboard = billboard,
            ring = ring,
            ringStroke = ringStroke,
            hLine = hLine,
            vLine = vLine,
            label = label,
            distInfo = distInfo,
        }
        
        -- Animate in
        ring.Size = UDim2.new(0, 0, 0, 0)
        Utilities.Tween(ring, {Size = UDim2.new(1, 0, 1, 0)}, 0.25, Enum.EasingStyle.Back)
    end
    
    -- Update existing indicator
    local indicator = OnPointModule._indicators[player.UserId]
    if indicator then
        indicator.billboard.Adornee = root
        indicator.billboard.Enabled = true
        
        -- Update colors
        indicator.ringStroke.Color = Config.OnPoint.Color
        indicator.ringStroke.Transparency = Config.OnPoint.Transparency
        indicator.hLine.BackgroundColor3 = Config.OnPoint.Color
        indicator.hLine.BackgroundTransparency = Config.OnPoint.Transparency
        indicator.vLine.BackgroundColor3 = Config.OnPoint.Color
        indicator.vLine.BackgroundTransparency = Config.OnPoint.Transparency
        indicator.label.TextColor3 = Config.OnPoint.Color
        
        -- Update text
        indicator.label.Text = string.format("[LOCK] %s", player.DisplayName)
        indicator.distInfo.Text = string.format(
            "D:%.1f | X:%.0f Y:%.0f Z:%.0f",
            distance, root.Position.X, root.Position.Y, root.Position.Z
        )
        
        -- Pulse animation
        if Config.OnPoint.SmoothUpdate then
            local pulse = 1 + math.sin(tick() * 4) * 0.08
            indicator.ring.Size = UDim2.new(pulse, 0, pulse, 0)
        else
            indicator.ring.Size = UDim2.new(1, 0, 1, 0)
        end
    end
end

function OnPointModule.HideIndicator(player)
    local indicator = OnPointModule._indicators[player.UserId]
    if indicator and indicator.billboard then
        indicator.billboard.Enabled = false
    end
end

function OnPointModule.Stop()
    if OnPointModule._connection then
        OnPointModule._connection:Disconnect()
        OnPointModule._connection = nil
    end
    
    for _, indicator in pairs(OnPointModule._indicators) do
        if indicator.billboard then indicator.billboard:Destroy() end
    end
    OnPointModule._indicators = {}
    
    if OnPointModule._screenIndicator then
        OnPointModule._screenIndicator:Destroy()
        OnPointModule._screenIndicator = nil
    end
end

-- ========================================================
-- [12] CLEANUP
-- ========================================================

function Cleanup()
    ESPModule.Stop()
    TeleportModule.Stop()
    POVModule.DestroyCircle()
    POVModule.StopSpectate()
    OnPointModule.Stop()
    
    Config.Speed.Value = 1
    local humanoid = Utilities.GetHumanoid(LocalPlayer)
    if humanoid then
        humanoid.WalkSpeed = Config.Speed.DefaultWalkSpeed
    end
    
    for _, connection in ipairs(Utilities._connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    Utilities._connections = {}
    
    for _, instance in ipairs(Utilities._instances) do
        if instance and instance.Parent then
            instance:Destroy()
        end
    end
    Utilities._instances = {}
    
    _G.HOSHI_Running = false
    
    print("[HOSHI] Cleanup complete. All modules stopped.")
end

-- ========================================================
-- [13] INIT
-- ========================================================

if _G.HOSHI_Running then
    if _G.HOSHI_Cleanup then
        _G.HOSHI_Cleanup()
    end
end

_G.HOSHI_Running = true
_G.HOSHI_Cleanup = Cleanup

MainGUI.Init()

print("========================================")
print("  HOSHI v" .. Config.Version)
print("  Admin Development Tools")
print("  Private Map Testing & Debugging")
print("  Session started: " .. os.date("%Y-%m-%d %H:%M:%S"))
print("========================================")