--[[
    Hoshi Development Tools
    Admin Development Tools for Private Map Testing
    Single File Implementation
    
    Sections:
    1. Services
    2. Variables & Config
    3. Theme
    4. Utility Functions
    5. UI Builder Core
    6. Splash Screen
    7. Window System
    8. Floating Button
    9. Watermark
    10. Notification System
    11. Component Builders (Toggle, Slider, TextBox, ColorPicker, Button)
    12. Sidebar & Tab System
    13. ESP Player System
    14. Teleport Safety System
    15. Speed Run System
    16. POV Circle System
    17. Observation Target System
    18. Settings Tab
    19. Initialization
    20. Cleanup
]]

--// 1. SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

--// 2. VARIABLES & CONFIG
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ViewportSize = Camera.ViewportSize

local Connections = {}
local Tweens = {}
local ActiveTweens = {}
local ESP_Objects = {}
local NotificationQueue = {}

local State = {
    guiOpen = false,
    minimized = false,
    maximized = false,
    windowPos = UDim2.new(0.5, -400, 0.5, -280),
    windowSize = UDim2.new(0, 800, 0, 560),
    prevWindowPos = nil,
    prevWindowSize = nil,
    activeTab = "ESP",
    floatingPos = UDim2.new(1, -70, 0.5, -25),
    espEnabled = false,
    teleportEnabled = false,
    teleportRadius = 40,
    teleportSafeDistance = 95,
    teleportCooldown = 3,
    lastTeleportTime = 0,
    speedEnabled = false,
    speedValue = 1,
    povEnabled = false,
    povRadius = 120,
    povThickness = 2,
    povTransparency = 0.3,
    povColor = Color3.fromRGB(0, 170, 255),
    obsEnabled = false,
    obsRadius = 150,
    obsTransparency = 0.4,
    obsColor = Color3.fromRGB(0, 255, 170),
    obsTarget = nil,
    uiScale = 1,
    accentColor = Color3.fromRGB(0, 170, 255),
    themeColor = Color3.fromRGB(18, 18, 24),
    animSpeed = 1,
    blurEnabled = true,
    destroyed = false,
}

local Config = {
    font = Enum.Font.GothamBold,
    fontMedium = Enum.Font.GothamMedium,
    fontRegular = Enum.Font.Gotham,
    cornerRadius = UDim.new(0, 8),
    cornerRadiusSmall = UDim.new(0, 6),
    cornerRadiusLarge = UDim.new(0, 12),
    shadowSize = 4,
    sidebarWidth = 180,
    headerHeight = 42,
    animDuration = 0.3,
    espUpdateInterval = 0.1,
    watermarkUpdateInterval = 0.5,
}

local RoleColors = {
    Killer = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(60, 200, 60),
    Unknown = Color3.fromRGB(180, 180, 180),
}

--// 3. THEME
local Theme = {
    bg = Color3.fromRGB(18, 18, 24),
    bgSecondary = Color3.fromRGB(24, 24, 32),
    bgTertiary = Color3.fromRGB(30, 30, 40),
    surface = Color3.fromRGB(35, 35, 48),
    surfaceHover = Color3.fromRGB(42, 42, 56),
    surfaceActive = Color3.fromRGB(50, 50, 65),
    border = Color3.fromRGB(50, 50, 68),
    borderLight = Color3.fromRGB(60, 60, 80),
    accent = Color3.fromRGB(0, 170, 255),
    accentDark = Color3.fromRGB(0, 120, 200),
    accentGlow = Color3.fromRGB(0, 140, 220),
    text = Color3.fromRGB(230, 230, 240),
    textSecondary = Color3.fromRGB(160, 160, 180),
    textMuted = Color3.fromRGB(100, 100, 120),
    success = Color3.fromRGB(60, 200, 120),
    warning = Color3.fromRGB(255, 180, 40),
    error = Color3.fromRGB(255, 70, 70),
    info = Color3.fromRGB(0, 170, 255),
    shadow = Color3.fromRGB(0, 0, 0),
    glass = Color3.fromRGB(25, 25, 35),
}

--// 4. UTILITY FUNCTIONS

local function safeGet(func)
    local ok, result = pcall(func)
    if ok then return result end
    return nil
end

local function getCharacter()
    return safeGet(function() return LocalPlayer.Character end)
end

local function getHumanoid()
    local char = getCharacter()
    if not char then return nil end
    return safeGet(function() return char:FindFirstChildOfClass("Humanoid") end)
end

local function getRootPart()
    local char = getCharacter()
    if not char then return nil end
    return safeGet(function() return char:FindFirstChild("HumanoidRootPart") end)
end

local function getCamera()
    return Workspace.CurrentCamera
end

local function addConnection(conn)
    if conn then
        table.insert(Connections, conn)
    end
    return conn
end

local function tweenObject(obj, props, duration, style, direction, callback)
    if not obj or State.destroyed then return nil end
    duration = (duration or Config.animDuration) * State.animSpeed
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    if callback then
        tween.Completed:Once(callback)
    end
    return tween
end

local function createInstance(className, props, children)
    local inst = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then
                local ok = pcall(function() inst[k] = v end)
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

local function addCorner(parent, radius)
    return createInstance("UICorner", {
        CornerRadius = radius or Config.cornerRadius,
        Parent = parent,
    })
end

local function addStroke(parent, color, thickness, transparency)
    return createInstance("UIStroke", {
        Color = color or Theme.border,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = parent,
    })
end

local function addPadding(parent, top, right, bottom, left)
    return createInstance("UIPadding", {
        PaddingTop = UDim.new(0, top or 8),
        PaddingRight = UDim.new(0, right or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft = UDim.new(0, left or 8),
        Parent = parent,
    })
end

local function addListLayout(parent, direction, padding, hAlign, vAlign, sortOrder)
    return createInstance("UIListLayout", {
        FillDirection = direction or Enum.FillDirection.Vertical,
        Padding = padding or UDim.new(0, 6),
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
        VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

local function addShadow(parent, size)
    local shadow = createInstance("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 30, 1, size or 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = parent,
    })
    return shadow
end

local function clampPosition(pos, size, viewport)
    viewport = viewport or getCamera().ViewportSize
    local x = math.clamp(pos.X.Offset, 0, viewport.X - size.X.Offset)
    local y = math.clamp(pos.Y.Offset, 0, viewport.Y - size.Y.Offset)
    return UDim2.new(0, x, 0, y)
end

local function getPlayerRole(player)
    if not player or not player.Character then return "Unknown" end
    local char = player.Character
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return "Unknown" end
    
    local tools = {}
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(tools, item.Name:lower())
        end
    end
    local backpack = safeGet(function() return player.Backpack end)
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools, item.Name:lower())
            end
        end
    end

    for _, name in ipairs(tools) do
        if name:find("knife") or name:find("weapon") or name:find("sword") or name:find("kill") or name:find("blade") then
            return "Killer"
        end
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local role = leaderstats:FindFirstChild("Role")
        if role and role.Value then
            local val = tostring(role.Value):lower()
            if val:find("killer") or val:find("murder") or val:find("beast") then
                return "Killer"
            elseif val:find("surviv") or val:find("runner") or val:find("innocent") then
                return "Survivor"
            end
        end
    end

    return "Survivor"
end

local function getKillers()
    local killers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getPlayerRole(player) == "Killer" then
            table.insert(killers, player)
        end
    end
    return killers
end

local function formatNumber(n)
    return string.format("%.0f", n)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpColor(a, b, t)
    return Color3.new(
        lerp(a.R, b.R, t),
        lerp(a.G, b.G, t),
        lerp(a.B, b.B, t)
    )
end

--// 5. UI BUILDER CORE

local ScreenGui, BlurEffect

local function buildScreenGui()
    if ScreenGui then
        pcall(function() ScreenGui:Destroy() end)
    end
    
    ScreenGui = createInstance("ScreenGui", {
        Name = "HoshiDevTools",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
    })
    
    local coreGui = safeGet(function() return game:GetService("CoreGui") end)
    if coreGui then
        ScreenGui.Parent = coreGui
    else
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    BlurEffect = createInstance("BlurEffect", {
        Name = "HoshiBlur",
        Size = 0,
        Parent = Lighting,
    })
    
    return ScreenGui
end

--// 6. SPLASH SCREEN

local function showSplashScreen(onComplete)
    local splashFrame = createInstance("Frame", {
        Name = "Splash",
        BackgroundColor3 = Color3.fromRGB(10, 10, 16),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100,
        Parent = ScreenGui,
    })

    local splashCenter = createInstance("Frame", {
        Name = "Center",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 0, 200),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 101,
        Parent = splashFrame,
    })

    local logoGlow = createInstance("Frame", {
        Name = "LogoGlow",
        BackgroundColor3 = Theme.accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 0, 90),
        Position = UDim2.new(0.5, 0, 0.3, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 102,
        Parent = splashCenter,
    })
    addCorner(logoGlow, UDim.new(1, 0))

    local logoBg = createInstance("Frame", {
        Name = "LogoBg",
        BackgroundColor3 = Theme.bgSecondary,
        Size = UDim2.new(0, 70, 0, 70),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 103,
        Parent = logoGlow,
    })
    addCorner(logoBg, UDim.new(0, 16))
    addStroke(logoBg, Theme.accent, 2, 0.3)

    local logoText = createInstance("TextLabel", {
        Name = "Logo",
        Text = "H",
        Font = Config.font,
        TextSize = 36,
        TextColor3 = Theme.accent,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 104,
        Parent = logoBg,
    })

    local titleLabel = createInstance("TextLabel", {
        Name = "Title",
        Text = "Hoshi Development Tools",
        Font = Config.font,
        TextSize = 18,
        TextColor3 = Theme.text,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0.58, 0),
        ZIndex = 102,
        Parent = splashCenter,
    })

    local subtitleLabel = createInstance("TextLabel", {
        Name = "Subtitle",
        Text = "Initializing...",
        Font = Config.fontRegular,
        TextSize = 13,
        TextColor3 = Theme.textSecondary,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0.68, 0),
        ZIndex = 102,
        Parent = splashCenter,
    })

    local progressBg = createInstance("Frame", {
        Name = "ProgressBg",
        BackgroundColor3 = Theme.surface,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 0, 4),
        Position = UDim2.new(0.15, 0, 0.82, 0),
        ZIndex = 102,
        Parent = splashCenter,
    })
    addCorner(progressBg, UDim.new(1, 0))

    local progressFill = createInstance("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 103,
        Parent = progressBg,
    })
    addCorner(progressFill, UDim.new(1, 0))

    -- Animate splash
    tweenObject(splashFrame, {BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Quart)
    
    if State.blurEnabled then
        tweenObject(BlurEffect, {Size = 20}, 0.5, Enum.EasingStyle.Quart)
    end

    task.delay(0.2, function()
        if State.destroyed then return end
        tweenObject(logoBg, {BackgroundTransparency = 0}, 0.4)
        
        local logoBgStroke = logoBg:FindFirstChildOfClass("UIStroke")
        if logoBgStroke then
            tweenObject(logoBgStroke, {Transparency = 0.3}, 0.4)
        end
        
        tweenObject(logoText, {TextTransparency = 0}, 0.4, Enum.EasingStyle.Quart)
        tweenObject(logoGlow, {BackgroundTransparency = 0.85}, 0.5)
    end)

    task.delay(0.5, function()
        if State.destroyed then return end
        tweenObject(titleLabel, {TextTransparency = 0}, 0.4)
        tweenObject(subtitleLabel, {TextTransparency = 0}, 0.4)
        tweenObject(progressBg, {BackgroundTransparency = 0}, 0.3)
        tweenObject(progressFill, {BackgroundTransparency = 0}, 0.3)
    end)

    -- Glow pulse on logo
    task.spawn(function()
        local pulseCount = 0
        while pulseCount < 4 and not State.destroyed do
            tweenObject(logoGlow, {BackgroundTransparency = 0.75}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.5)
            tweenObject(logoGlow, {BackgroundTransparency = 0.9}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.5)
            pulseCount = pulseCount + 1
        end
    end)

    local loadingSteps = {
        {progress = 0.2, text = "Loading services..."},
        {progress = 0.4, text = "Preparing modules..."},
        {progress = 0.6, text = "Building interface..."},
        {progress = 0.8, text = "Connecting systems..."},
        {progress = 1.0, text = "Ready"},
    }

    task.spawn(function()
        task.wait(0.8)
        for i, step in ipairs(loadingSteps) do
            if State.destroyed then return end
            tweenObject(progressFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, 0.35, Enum.EasingStyle.Quart)
            subtitleLabel.Text = step.text
            task.wait(0.4)
        end
        
        task.wait(0.3)
        if State.destroyed then return end
        
        -- Fade out splash
        tweenObject(splashFrame, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quart)
        tweenObject(splashCenter, {}, 0.1)
        
        for _, child in ipairs(splashCenter:GetDescendants()) do
            pcall(function()
                if child:IsA("TextLabel") then
                    tweenObject(child, {TextTransparency = 1}, 0.3)
                elseif child:IsA("Frame") then
                    tweenObject(child, {BackgroundTransparency = 1}, 0.3)
                end
            end)
        end
        tweenObject(logoGlow, {BackgroundTransparency = 1}, 0.3)
        tweenObject(progressBg, {BackgroundTransparency = 1}, 0.3)
        tweenObject(progressFill, {BackgroundTransparency = 1}, 0.3)
        
        if not State.blurEnabled then
            tweenObject(BlurEffect, {Size = 0}, 0.3)
        end
        
        task.wait(0.5)
        if State.destroyed then return end
        pcall(function() splashFrame:Destroy() end)
        
        if onComplete then
            onComplete()
        end
    end)
end

--// 7. WINDOW SYSTEM

local MainWindow, HeaderBar, ContentFrame, SidebarFrame, TabContainer
local WindowDragConnection, WindowResizeConnection

local function buildMainWindow()
    MainWindow = createInstance("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = Theme.bg,
        BackgroundTransparency = 1,
        Size = State.windowSize,
        Position = State.windowPos,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    addCorner(MainWindow, Config.cornerRadiusLarge)
    addStroke(MainWindow, Theme.border, 1, 0.6)
    addShadow(MainWindow, 40)

    -- Header
    HeaderBar = createInstance("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.bgSecondary,
        Size = UDim2.new(1, 0, 0, Config.headerHeight),
        ZIndex = 12,
        Parent = MainWindow,
    })
    addCorner(HeaderBar, Config.cornerRadiusLarge)
    
    -- Bottom corners fix for header
    local headerFix = createInstance("Frame", {
        Name = "Fix",
        BackgroundColor3 = Theme.bgSecondary,
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = HeaderBar,
    })

    local headerDivider = createInstance("Frame", {
        Name = "Divider",
        BackgroundColor3 = Theme.border,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = HeaderBar,
    })

    -- Header title
    local headerIcon = createInstance("TextLabel", {
        Name = "Icon",
        Text = "H",
        Font = Config.font,
        TextSize = 18,
        TextColor3 = Theme.accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        ZIndex = 13,
        Parent = HeaderBar,
    })

    local headerTitle = createInstance("TextLabel", {
        Name = "Title",
        Text = "Hoshi Development Tools",
        Font = Config.fontMedium,
        TextSize = 14,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        ZIndex = 13,
        Parent = HeaderBar,
    })

    -- Window buttons
    local btnSize = 28
    local btnPadding = 6
    local function createWindowButton(name, text, color, order)
        local btn = createInstance("TextButton", {
            Name = name,
            Text = text,
            Font = Config.fontMedium,
            TextSize = 14,
            TextColor3 = Theme.textSecondary,
            BackgroundColor3 = Theme.surface,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(0, btnSize, 0, btnSize),
            Position = UDim2.new(1, -(btnSize + btnPadding) * order - btnPadding, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 14,
            Parent = HeaderBar,
        })
        addCorner(btn, UDim.new(0, 6))
        
        btn.MouseEnter:Connect(function()
            tweenObject(btn, {BackgroundTransparency = 0.2, TextColor3 = color or Theme.text}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            tweenObject(btn, {BackgroundTransparency = 0.5, TextColor3 = Theme.textSecondary}, 0.2)
        end)
        
        return btn
    end

    local closeBtn = createWindowButton("Close", "X", Theme.error, 1)
    local maxBtn = createWindowButton("Maximize", "+", Theme.warning, 2)
    local minBtn = createWindowButton("Minimize", "-", Theme.success, 3)

    closeBtn.MouseButton1Click:Connect(function()
        closeWindow()
    end)

    maxBtn.MouseButton1Click:Connect(function()
        toggleMaximize()
    end)

    minBtn.MouseButton1Click:Connect(function()
        minimizeWindow()
    end)

    -- Drag functionality
    local dragging = false
    local dragStart, startPos

    HeaderBar.InputBegan:Connect(function(input)
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

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            MainWindow.Position = newPos
            State.windowPos = newPos
        end
    end))

    -- Resize handle
    local resizeHandle = createInstance("TextButton", {
        Name = "ResizeHandle",
        Text = "",
        BackgroundColor3 = Theme.accent,
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        ZIndex = 15,
        Parent = MainWindow,
    })
    addCorner(resizeHandle, UDim.new(0, 4))

    local resizing = false
    local resizeStart, startSize

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = MainWindow.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newW = math.clamp(startSize.X.Offset + delta.X, 600, 1200)
            local newH = math.clamp(startSize.Y.Offset + delta.Y, 400, 800)
            MainWindow.Size = UDim2.new(0, newW, 0, newH)
            State.windowSize = MainWindow.Size
        end
    end))

    resizeHandle.MouseEnter:Connect(function()
        tweenObject(resizeHandle, {BackgroundTransparency = 0.4}, 0.2)
    end)
    resizeHandle.MouseLeave:Connect(function()
        tweenObject(resizeHandle, {BackgroundTransparency = 0.8}, 0.2)
    end)

    -- Content area
    ContentFrame = createInstance("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -Config.headerHeight),
        Position = UDim2.new(0, 0, 0, Config.headerHeight),
        ZIndex = 11,
        Parent = MainWindow,
    })

    return MainWindow
end

function closeWindow()
    if State.destroyed then return end
    State.guiOpen = false
    tweenObject(MainWindow, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quart)
    
    for _, desc in ipairs(MainWindow:GetDescendants()) do
        pcall(function()
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                tweenObject(desc, {TextTransparency = 1}, 0.25)
            end
            if desc:IsA("Frame") or desc:IsA("TextButton") or desc:IsA("ScrollingFrame") then
                tweenObject(desc, {BackgroundTransparency = 1}, 0.25)
            end
            if desc:IsA("ImageLabel") then
                tweenObject(desc, {ImageTransparency = 1}, 0.25)
            end
            if desc:IsA("UIStroke") then
                tweenObject(desc, {Transparency = 1}, 0.25)
            end
        end)
    end
    
    if State.blurEnabled and BlurEffect then
        tweenObject(BlurEffect, {Size = 0}, 0.3)
    end
    
    task.delay(0.35, function()
        if MainWindow then
            MainWindow.Visible = false
        end
        showFloatingButton()
    end)
end

function openWindow()
    if State.destroyed or not MainWindow then return end
    State.guiOpen = true
    MainWindow.Visible = true
    hideFloatingButton()

    MainWindow.BackgroundTransparency = 1
    tweenObject(MainWindow, {BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Quart)
    
    if State.blurEnabled and BlurEffect then
        tweenObject(BlurEffect, {Size = 12}, 0.4)
    end
    
    task.delay(0.05, function()
        if State.destroyed then return end
        for _, desc in ipairs(MainWindow:GetDescendants()) do
            pcall(function()
                if desc.Name == "Shadow" then return end
                if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                    local target = 0
                    if desc:GetAttribute("TargetTextTransparency") then
                        target = desc:GetAttribute("TargetTextTransparency")
                    end
                    tweenObject(desc, {TextTransparency = target}, 0.3)
                end
                if desc:IsA("Frame") or desc:IsA("TextButton") or desc:IsA("ScrollingFrame") then
                    local target = 0
                    if desc:GetAttribute("TargetBgTransparency") then
                        target = desc:GetAttribute("TargetBgTransparency")
                    end
                    tweenObject(desc, {BackgroundTransparency = target}, 0.3)
                end
                if desc:IsA("UIStroke") then
                    local target = 0.5
                    if desc:GetAttribute("TargetTransparency") then
                        target = desc:GetAttribute("TargetTransparency")
                    end
                    tweenObject(desc, {Transparency = target}, 0.3)
                end
                if desc:IsA("ImageLabel") then
                    local target = 0
                    if desc:GetAttribute("TargetImageTransparency") then
                        target = desc:GetAttribute("TargetImageTransparency")
                    end
                    tweenObject(desc, {ImageTransparency = target}, 0.3)
                end
            end)
        end
    end)
end

function toggleMaximize()
    if State.maximized then
        State.maximized = false
        if State.prevWindowPos and State.prevWindowSize then
            tweenObject(MainWindow, {
                Position = State.prevWindowPos,
                Size = State.prevWindowSize,
            }, 0.3, Enum.EasingStyle.Quart)
        end
    else
        State.maximized = true
        State.prevWindowPos = MainWindow.Position
        State.prevWindowSize = MainWindow.Size
        tweenObject(MainWindow, {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.95, 0, 0.9, 0),
        }, 0.3, Enum.EasingStyle.Quart)
    end
end

function minimizeWindow()
    if State.minimized then
        State.minimized = false
        tweenObject(MainWindow, {
            Size = State.windowSize,
            BackgroundTransparency = 0,
        }, 0.3, Enum.EasingStyle.Quart)
        for _, desc in ipairs(MainWindow:GetDescendants()) do
            pcall(function()
                if desc.Name ~= "Shadow" and desc ~= HeaderBar and not desc:IsDescendantOf(HeaderBar) then
                    if desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
                        tweenObject(desc, {BackgroundTransparency = desc:GetAttribute("TargetBgTransparency") or 0}, 0.25)
                    end
                end
            end)
        end
    else
        State.minimized = true
        tweenObject(MainWindow, {
            Size = UDim2.new(0, MainWindow.Size.X.Offset, 0, Config.headerHeight),
        }, 0.3, Enum.EasingStyle.Quart)
    end
end

--// 8. FLOATING BUTTON

local FloatingButton, FloatingPulseLoop

function buildFloatingButton()
    FloatingButton = createInstance("TextButton", {
        Name = "FloatingBtn",
        Text = "",
        BackgroundColor3 = Theme.bgSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 0, 50),
        Position = State.floatingPos,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 200,
        Visible = false,
        Parent = ScreenGui,
    })
    addCorner(FloatingButton, UDim.new(1, 0))
    addStroke(FloatingButton, Theme.accent, 2, 0.4)
    addShadow(FloatingButton, 20)

    local glowRing = createInstance("Frame", {
        Name = "Glow",
        BackgroundColor3 = Theme.accent,
        BackgroundTransparency = 0.85,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 199,
        Parent = FloatingButton,
    })
    addCorner(glowRing, UDim.new(1, 0))

    local floatIcon = createInstance("TextLabel", {
        Name = "Icon",
        Text = "H",
        Font = Config.font,
        TextSize = 24,
        TextColor3 = Theme.accent,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 201,
        Parent = FloatingButton,
    })

    -- Drag
    local fdrag = false
    local fstart, fpos
    local wasClick = true

    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fdrag = true
            wasClick = true
            fstart = input.Position
            fpos = FloatingButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fdrag = false
                    if wasClick then
                        openWindow()
                    end
                    -- Clamp to screen
                    local vp = getCamera().ViewportSize
                    local curPos = FloatingButton.Position
                    local cx = math.clamp(curPos.X.Offset + curPos.X.Scale * vp.X, 25, vp.X - 25)
                    local cy = math.clamp(curPos.Y.Offset + curPos.Y.Scale * vp.Y, 25, vp.Y - 25)
                    FloatingButton.Position = UDim2.new(0, cx, 0, cy)
                    State.floatingPos = FloatingButton.Position
                end
            end)
        end
    end)

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if fdrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - fstart
            if delta.Magnitude > 5 then
                wasClick = false
            end
            FloatingButton.Position = UDim2.new(
                fpos.X.Scale, fpos.X.Offset + delta.X,
                fpos.Y.Scale, fpos.Y.Offset + delta.Y
            )
        end
    end))

    -- Hover
    FloatingButton.MouseEnter:Connect(function()
        tweenObject(FloatingButton, {Size = UDim2.new(0, 56, 0, 56)}, 0.2, Enum.EasingStyle.Quart)
        local stroke = FloatingButton:FindFirstChildOfClass("UIStroke")
        if stroke then
            tweenObject(stroke, {Transparency = 0.1}, 0.2)
        end
    end)
    FloatingButton.MouseLeave:Connect(function()
        tweenObject(FloatingButton, {Size = UDim2.new(0, 50, 0, 50)}, 0.2, Enum.EasingStyle.Quart)
        local stroke = FloatingButton:FindFirstChildOfClass("UIStroke")
        if stroke then
            tweenObject(stroke, {Transparency = 0.4}, 0.2)
        end
    end)

    return FloatingButton
end

function showFloatingButton()
    if not FloatingButton or State.destroyed then return end
    FloatingButton.Visible = true
    FloatingButton.BackgroundTransparency = 1
    local icon = FloatingButton:FindFirstChild("Icon")
    if icon then icon.TextTransparency = 1 end
    
    tweenObject(FloatingButton, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Quart)
    if icon then
        tweenObject(icon, {TextTransparency = 0}, 0.3)
    end
    
    local stroke = FloatingButton:FindFirstChildOfClass("UIStroke")
    if stroke then tweenObject(stroke, {Transparency = 0.4}, 0.3) end
    
    local glow = FloatingButton:FindFirstChild("Glow")
    if glow then tweenObject(glow, {BackgroundTransparency = 0.85}, 0.3) end

    -- Pulse animation
    if FloatingPulseLoop then return end
    FloatingPulseLoop = true
    task.spawn(function()
        while FloatingPulseLoop and FloatingButton and FloatingButton.Visible and not State.destroyed do
            if FloatingButton and FloatingButton.Parent then
                local glow2 = FloatingButton:FindFirstChild("Glow")
                if glow2 then
                    tweenObject(glow2, {BackgroundTransparency = 0.75, Size = UDim2.new(1, 14, 1, 14)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1)
                    if not FloatingPulseLoop or State.destroyed then break end
                    tweenObject(glow2, {BackgroundTransparency = 0.9, Size = UDim2.new(1, 8, 1, 8)}, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                    task.wait(1)
                end
            else
                break
            end
        end
    end)
end

function hideFloatingButton()
    if not FloatingButton or State.destroyed then return end
    FloatingPulseLoop = false
    tweenObject(FloatingButton, {BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Quart)
    local icon = FloatingButton:FindFirstChild("Icon")
    if icon then tweenObject(icon, {TextTransparency = 1}, 0.25) end
    local stroke = FloatingButton:FindFirstChildOfClass("UIStroke")
    if stroke then tweenObject(stroke, {Transparency = 1}, 0.25) end
    local glow = FloatingButton:FindFirstChild("Glow")
    if glow then tweenObject(glow, {BackgroundTransparency = 1}, 0.25) end
    
    task.delay(0.3, function()
        if FloatingButton then
            FloatingButton.Visible = false
        end
    end)
end

--// 9. WATERMARK

local WatermarkFrame

local function buildWatermark()
    WatermarkFrame = createInstance("Frame", {
        Name = "Watermark",
        BackgroundColor3 = Theme.bgSecondary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 340, 0, 28),
        Position = UDim2.new(1, -10, 0, 10),
        AnchorPoint = Vector2.new(1, 0),
        ZIndex = 50,
        Parent = ScreenGui,
    })
    addCorner(WatermarkFrame, UDim.new(0, 6))
    addStroke(WatermarkFrame, Theme.accent, 1, 0.7)

    local wmText = createInstance("TextLabel", {
        Name = "Text",
        Text = "Hoshi Development Tools | FPS: -- | Ping: -- | --:--:--",
        Font = Config.fontRegular,
        TextSize = 12,
        TextColor3 = Theme.textSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 51,
        Parent = WatermarkFrame,
    })

    -- Fade in
    WatermarkFrame.BackgroundTransparency = 1
    wmText.TextTransparency = 1
    local wmStroke = WatermarkFrame:FindFirstChildOfClass("UIStroke")
    if wmStroke then wmStroke.Transparency = 1 end

    task.delay(0.5, function()
        tweenObject(WatermarkFrame, {BackgroundTransparency = 0.3}, 0.5)
        tweenObject(wmText, {TextTransparency = 0}, 0.5)
        if wmStroke then tweenObject(wmStroke, {Transparency = 0.7}, 0.5) end
    end)

    -- Update loop
    task.spawn(function()
        while not State.destroyed do
            if WatermarkFrame and WatermarkFrame.Parent then
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                local ping = math.floor(safeGet(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end) or 0)
                local timeStr = os.date("%H:%M:%S")
                local status = State.guiOpen and "Active" or "Idle"
                local txt = WatermarkFrame:FindFirstChild("Text")
                if txt then
                    txt.Text = string.format("Hoshi Development Tools | FPS: %d | Ping: %dms | %s | %s", fps, ping, timeStr, status)
                end
            end
            task.wait(Config.watermarkUpdateInterval)
        end
    end)

    return WatermarkFrame
end

--// 10. NOTIFICATION SYSTEM

local NotificationContainer

local function buildNotificationContainer()
    NotificationContainer = createInstance("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 1, -50),
        Position = UDim2.new(1, -10, 0, 45),
        AnchorPoint = Vector2.new(1, 0),
        ZIndex = 90,
        Parent = ScreenGui,
    })
    addListLayout(NotificationContainer, Enum.FillDirection.Vertical, UDim.new(0, 6), Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top)
    addPadding(NotificationContainer, 4, 0, 4, 0)
end

local function notify(title, message, duration, ntype)
    if State.destroyed or not NotificationContainer then return end
    duration = duration or 3
    ntype = ntype or "INFO"
    
    local colors = {
        INFO = Theme.accent,
        SUCCESS = Theme.success,
        WARNING = Theme.warning,
        ERROR = Theme.error,
    }
    local accentColor = colors[ntype] or Theme.accent

    local notif = createInstance("Frame", {
        Name = "Notif",
        BackgroundColor3 = Theme.bgSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 56),
        ClipsDescendants = true,
        ZIndex = 91,
        Parent = NotificationContainer,
    })
    addCorner(notif, UDim.new(0, 8))
    addStroke(notif, accentColor, 1, 0.6)

    local accentLine = createInstance("Frame", {
        Name = "Accent",
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        ZIndex = 92,
        Parent = notif,
    })
    addCorner(accentLine, UDim.new(1, 0))

    local ntitle = createInstance("TextLabel", {
        Name = "Title",
        Text = "[" .. ntype .. "] " .. (title or ""),
        Font = Config.fontMedium,
        TextSize = 12,
        TextColor3 = accentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 14, 0, 6),
        ZIndex = 93,
        Parent = notif,
    })

    local nmsg = createInstance("TextLabel", {
        Name = "Message",
        Text = message or "",
        Font = Config.fontRegular,
        TextSize = 11,
        TextColor3 = Theme.textSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 14, 0, 24),
        ZIndex = 93,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = notif,
    })

    local progressBar = createInstance("Frame", {
        Name = "Progress",
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        ZIndex = 93,
        Parent = notif,
    })

    -- Animate in
    tweenObject(notif, {BackgroundTransparency = 0.1}, 0.3, Enum.EasingStyle.Quart)
    tweenObject(ntitle, {TextTransparency = 0}, 0.3)
    tweenObject(nmsg, {TextTransparency = 0}, 0.3)
    tweenObject(accentLine, {BackgroundTransparency = 0}, 0.3)
    tweenObject(progressBar, {BackgroundTransparency = 0.3}, 0.3)

    local notifStroke = notif:FindFirstChildOfClass("UIStroke")
    if notifStroke then tweenObject(notifStroke, {Transparency = 0.6}, 0.3) end

    -- Progress countdown
    task.delay(0.3, function()
        tweenObject(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
    end)

    -- Auto close
    task.delay(duration + 0.3, function()
        if notif and notif.Parent then
            tweenObject(notif, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quart)
            tweenObject(ntitle, {TextTransparency = 1}, 0.25)
            tweenObject(nmsg, {TextTransparency = 1}, 0.25)
            tweenObject(accentLine, {BackgroundTransparency = 1}, 0.25)
            tweenObject(progressBar, {BackgroundTransparency = 1}, 0.25)
            if notifStroke then tweenObject(notifStroke, {Transparency = 1}, 0.25) end
            task.delay(0.35, function()
                pcall(function() notif:Destroy() end)
            end)
        end
    end)
end

--// 11. COMPONENT BUILDERS

local function createRipple(button)
    if not button then return end
    local ripple = createInstance("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 1,
        Parent = button,
    })
    addCorner(ripple, UDim.new(1, 0))
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    tweenObject(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    }, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
        pcall(function() ripple:Destroy() end)
    end)
end

local function buildToggle(parent, label, default, callback, zBase)
    zBase = zBase or (parent and parent.ZIndex or 11) + 1
    
    local container = createInstance("Frame", {
        Name = "Toggle_" .. label,
        BackgroundColor3 = Theme.surface,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = zBase,
        Parent = parent,
    })
    addCorner(container, Config.cornerRadiusSmall)
    container:SetAttribute("TargetBgTransparency", 0)

    local lbl = createInstance("TextLabel", {
        Name = "Label",
        Text = label,
        Font = Config.fontMedium,
        TextSize = 13,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        ZIndex = zBase + 1,
        Parent = container,
    })

    local toggleBg = createInstance("Frame", {
        Name = "ToggleBg",
        BackgroundColor3 = default and Theme.accent or Theme.bgTertiary,
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -54, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = zBase + 1,
        Parent = container,
    })
    addCorner(toggleBg, UDim.new(1, 0))
    addStroke(toggleBg, Theme.border, 1, 0.6)
    toggleBg:SetAttribute("TargetBgTransparency", 0)

    local toggleKnob = createInstance("Frame", {
        Name = "Knob",
        BackgroundColor3 = Theme.text,
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = zBase + 2,
        Parent = toggleBg,
    })
    addCorner(toggleKnob, UDim.new(1, 0))
    toggleKnob:SetAttribute("TargetBgTransparency", 0)

    local enabled = default or false

    local toggleBtn = createInstance("TextButton", {
        Name = "ToggleBtn",
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = zBase + 3,
        Parent = container,
    })

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        createRipple(container)
        tweenObject(toggleBg, {BackgroundColor3 = enabled and Theme.accent or Theme.bgTertiary}, 0.25, Enum.EasingStyle.Quart)
        tweenObject(toggleKnob, {Position = enabled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.25, Enum.EasingStyle.Quart)
        if callback then
            callback(enabled)
        end
    end)

    container.MouseEnter:Connect(function()
        tweenObject(container, {BackgroundColor3 = Theme.surfaceHover}, 0.2)
    end)
    container.MouseLeave:Connect(function()
        tweenObject(container, {BackgroundColor3 = Theme.surface}, 0.2)
    end)

    local api = {}
    function api:Set(val)
        enabled = val
        tweenObject(toggleBg, {BackgroundColor3 = enabled and Theme.accent or Theme.bgTertiary}, 0.2)
        tweenObject(toggleKnob, {Position = enabled and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.2)
    end
    function api:Get()
        return enabled
    end
    
    return container, api
end

local function buildSlider(parent, label, min, max, default, callback, zBase)
    zBase = zBase or (parent and parent.ZIndex or 11) + 1

    local container = createInstance("Frame", {
        Name = "Slider_" .. label,
        BackgroundColor3 = Theme.surface,
        Size = UDim2.new(1, 0, 0, 52),
        ZIndex = zBase,
        Parent = parent,
    })
    addCorner(container, Config.cornerRadiusSmall)
    container:SetAttribute("TargetBgTransparency", 0)

    local lbl = createInstance("TextLabel", {
        Name = "Label",
        Text = label,
        Font = Config.fontMedium,
        TextSize = 12,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 0, 18),
        Position = UDim2.new(0, 12, 0, 4),
        ZIndex = zBase + 1,
        Parent = container,
    })

    local valLabel = createInstance("TextLabel", {
        Name = "Value",
        Text = tostring(default),
        Font = Config.fontMedium,
        TextSize = 12,
        TextColor3 = Theme.accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35, 0, 0, 18),
        Position = UDim2.new(0.6, 0, 0, 4),
        ZIndex = zBase + 1,
        Parent = container,
    })

    local trackBg = createInstance("Frame", {
        Name = "Track",
        BackgroundColor3 = Theme.bgTertiary,
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 34),
        ZIndex = zBase + 1,
        Parent = container,
    })
    addCorner(trackBg, UDim.new(1, 0))
    trackBg:SetAttribute("TargetBgTransparency", 0)

    local fillFrac = math.clamp((default - min) / (max - min), 0, 1)

    local trackFill = createInstance("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.accent,
        Size = UDim2.new(fillFrac, 0, 1, 0),
        ZIndex = zBase + 2,
        Parent = trackBg,
    })
    addCorner(trackFill, UDim.new(1, 0))
    trackFill:SetAttribute("TargetBgTransparency", 0)

    local knob = createInstance("Frame", {
        Name = "Knob",
        BackgroundColor3 = Theme.accent,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(fillFrac, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = zBase + 3,
        Parent = trackBg,
    })
    addCorner(knob, UDim.new(1, 0))
    addStroke(knob, Theme.text, 2, 0.5)
    knob:SetAttribute("TargetBgTransparency", 0)

    local sliderBtn = createInstance("TextButton", {
        Name = "SliderBtn",
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 24),
        ZIndex = zBase + 4,
        Parent = container,
    })

    local sliding = false
    local currentValue = default

    local function updateSlider(inputX)
        local trackAbsPos = trackBg.AbsolutePosition.X
        local trackAbsSize = trackBg.AbsoluteSize.X
        if trackAbsSize <= 0 then return end
        local frac = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
        currentValue = math.floor(min + frac * (max - min) + 0.5)
        frac = (currentValue - min) / (max - min)
        
        trackFill.Size = UDim2.new(frac, 0, 1, 0)
        knob.Position = UDim2.new(frac, 0, 0.5, 0)
        valLabel.Text = tostring(currentValue)
        
        if callback then
            callback(currentValue)
        end
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input.Position.X)
        end
    end)

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end))

    addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end))

    container.MouseEnter:Connect(function()
        tweenObject(container, {BackgroundColor3 = Theme.surfaceHover}, 0.2)
    end)
    container.MouseLeave:Connect(function()
        tweenObject(container, {BackgroundColor3 = Theme.surface}, 0.2)
    end)

    local api = {}
    function api:Set(val)
        currentValue = math.clamp(val, min, max)
        local frac = (currentValue - min) / (max - min)
        trackFill.Size = UDim2.new(frac, 0, 1, 0)
        knob.Position = UDim2.new(frac, 0, 0.5, 0)
        valLabel.Text = tostring(currentValue)
    end
    function api:Get()
        return currentValue
    end
    
    return container, api
end

local function buildTextInput(parent, label, default, placeholder, callback, zBase)
    zBase = zBase or (parent and parent.ZIndex or 11) + 1

    local container = createInstance("Frame", {
        Name = "Input_" .. label,
        BackgroundColor3 = Theme.surface,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = zBase,
        Parent = parent,
    })
    addCorner(container, Config.cornerRadiusSmall)
    container:SetAttribute("TargetBgTransparency", 0)

    local lbl = createInstance("TextLabel", {
        Name = "Label",
        Text = label,
        Font = Config.fontMedium,
        TextSize = 12,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        ZIndex = zBase + 1,
        Parent = container,
    })

    local inputBox = createInstance("TextBox", {
        Name = "Input",
        Text = tostring(default or ""),
        PlaceholderText = placeholder or "",
        Font = Config.fontRegular,
        TextSize = 13,
        TextColor3 = Theme.accent,
        PlaceholderColor3 = Theme.textMuted,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundColor3 = Theme.bgTertiary,
        Size = UDim2.new(0.4, 0, 0, 26),
        Position = UDim2.new(0.55, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = zBase + 2,
        ClearTextOnFocus = false,
        Parent = container,
    })
    addCorner(inputBox, UDim.new(0, 5))
    addStroke(inputBox, Theme.border, 1, 0.7)
    inputBox:SetAttribute("TargetBgTransparency", 0)

    inputBox.FocusLost:Connect(function()
        if callback then
            callback(inputBox.Text)
        end
    end)

    inputBox.Focused:Connect(function()
        local stroke = inputBox:FindFirstChildOfClass("UIStroke")
        if stroke then tweenObject(stroke, {Color = Theme.accent, Transparency = 0.3}, 0.2) end
    end)

    inputBox.FocusLost:Connect(function()
        local stroke = inputBox:FindFirstChildOfClass("UIStroke")
        if stroke then tweenObject(stroke, {Color = Theme.border, Transparency = 0.7}, 0.2) end
    end)

    container.MouseEnter:Connect(function()
        tweenObject(container, {BackgroundColor3 = Theme.surfaceHover}, 0.2)
    end)
    container.MouseLeave:Connect(function()
        tweenObject(container, {BackgroundColor3 = Theme.surface}, 0.2)
    end)

    local api = {}
    function api:Set(val)
        inputBox.Text = tostring(val)
    end
    function api:Get()
        return inputBox.Text
    end

    return container, api
end

local function buildButton(parent, label, callback, zBase, accentOverride)
    zBase = zBase or (parent and parent.ZIndex or 11) + 1
    local accent = accentOverride or Theme.accent

    local btn = createInstance("TextButton", {
        Name = "Btn_" .. label,
        Text = label,
        Font = Config.fontMedium,
        TextSize = 13,
        TextColor3 = Theme.text,
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(1, 0, 0, 34),
        ZIndex = zBase,
        ClipsDescendants = true,
        Parent = parent,
    })
    addCorner(btn, Config.cornerRadiusSmall)
    addStroke(btn, accent, 1, 0.5)
    btn:SetAttribute("TargetBgTransparency", 0.7)

    btn.MouseEnter:Connect(function()
        tweenObject(btn, {BackgroundTransparency = 0.4, Size = UDim2.new(1, 0, 0, 36)}, 0.15, Enum.EasingStyle.Quart)
    end)
    btn.MouseLeave:Connect(function()
        tweenObject(btn, {BackgroundTransparency = 0.7, Size = UDim2.new(1, 0, 0, 34)}, 0.15, Enum.EasingStyle.Quart)
    end)
    btn.MouseButton1Click:Connect(function()
        createRipple(btn)
        tweenObject(btn, {Size = UDim2.new(1, 0, 0, 32)}, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
            tweenObject(btn, {Size = UDim2.new(1, 0, 0, 34)}, 0.15, Enum.EasingStyle.Quart)
        end)
        if callback then
            callback()
        end
    end)

    return btn
end

local function buildSectionLabel(parent, text, zBase)
    zBase = zBase or (parent and parent.ZIndex or 11) + 1
    
    local lbl = createInstance("TextLabel", {
        Name = "Section_" .. text,
        Text = text,
        Font = Config.font,
        TextSize = 14,
        TextColor3 = Theme.accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = zBase,
        Parent = parent,
    })
    return lbl
end

local function buildStatusLabel(parent, name, text, zBase)
    zBase = zBase or (parent and parent.ZIndex or 11) + 1
    
    local lbl = createInstance("TextLabel", {
        Name = name,
        Text = text or "",
        Font = Config.fontRegular,
        TextSize = 12,
        TextColor3 = Theme.textSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        ZIndex = zBase,
        Parent = parent,
    })
    return lbl
end

--// 12. SIDEBAR & TAB SYSTEM

local Tabs = {}
local TabButtons = {}
local ActiveIndicator

local function buildSidebar()
    SidebarFrame = createInstance("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.bgSecondary,
        Size = UDim2.new(0, Config.sidebarWidth, 1, 0),
        ZIndex = 15,
        ClipsDescendants = true,
        Parent = ContentFrame,
    })
    addStroke(SidebarFrame, Theme.border, 1, 0.7)
    SidebarFrame:SetAttribute("TargetBgTransparency", 0)

    local sidebarContent = createInstance("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        ZIndex = 16,
        Parent = SidebarFrame,
    })
    addListLayout(sidebarContent, Enum.FillDirection.Vertical, UDim.new(0, 2))
    addPadding(sidebarContent, 8, 8, 8, 8)

    -- Sidebar brand
    local brandLabel = createInstance("TextLabel", {
        Name = "Brand",
        Text = "MENU",
        Font = Config.font,
        TextSize = 11,
        TextColor3 = Theme.textMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        ZIndex = 17,
        LayoutOrder = 0,
        Parent = sidebarContent,
    })

    local menuItems = {
        {name = "ESP", icon = "[E]", order = 1},
        {name = "Teleport", icon = "[T]", order = 2},
        {name = "Speed", icon = "[S]", order = 3},
        {name = "POV", icon = "[P]", order = 4},
        {name = "Observe", icon = "[O]", order = 5},
        {name = "Settings", icon = "[*]", order = 6},
    }

    for _, item in ipairs(menuItems) do
        local menuBtn = createInstance("TextButton", {
            Name = "Menu_" .. item.name,
            Text = "",
            BackgroundColor3 = (State.activeTab == item.name) and Theme.surfaceActive or Theme.bgSecondary,
            BackgroundTransparency = (State.activeTab == item.name) and 0 or 1,
            Size = UDim2.new(1, 0, 0, 34),
            ZIndex = 17,
            LayoutOrder = item.order,
            ClipsDescendants = true,
            Parent = sidebarContent,
        })
        addCorner(menuBtn, Config.cornerRadiusSmall)
        menuBtn:SetAttribute("TargetBgTransparency", (State.activeTab == item.name) and 0 or 1)

        local iconLbl = createInstance("TextLabel", {
            Name = "Icon",
            Text = item.icon,
            Font = Config.fontMedium,
            TextSize = 12,
            TextColor3 = (State.activeTab == item.name) and Theme.accent or Theme.textMuted,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 18,
            Parent = menuBtn,
        })

        local nameLbl = createInstance("TextLabel", {
            Name = "Name",
            Text = item.name,
            Font = Config.fontMedium,
            TextSize = 13,
            TextColor3 = (State.activeTab == item.name) and Theme.text or Theme.textSecondary,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -44, 1, 0),
            Position = UDim2.new(0, 38, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 18,
            Parent = menuBtn,
        })

        local activeLine = createInstance("Frame", {
            Name = "ActiveLine",
            BackgroundColor3 = Theme.accent,
            BackgroundTransparency = (State.activeTab == item.name) and 0 or 1,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            ZIndex = 19,
            Parent = menuBtn,
        })
        addCorner(activeLine, UDim.new(1, 0))

        TabButtons[item.name] = {button = menuBtn, icon = iconLbl, label = nameLbl, line = activeLine}

        menuBtn.MouseEnter:Connect(function()
            if State.activeTab ~= item.name then
                tweenObject(menuBtn, {BackgroundTransparency = 0.5}, 0.15)
                tweenObject(nameLbl, {TextColor3 = Theme.text}, 0.15)
            end
        end)
        menuBtn.MouseLeave:Connect(function()
            if State.activeTab ~= item.name then
                tweenObject(menuBtn, {BackgroundTransparency = 1}, 0.15)
                tweenObject(nameLbl, {TextColor3 = Theme.textSecondary}, 0.15)
            end
        end)

        menuBtn.MouseButton1Click:Connect(function()
            createRipple(menuBtn)
            switchTab(item.name)
        end)
    end

    -- Tab container
    TabContainer = createInstance("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -Config.sidebarWidth, 1, 0),
        Position = UDim2.new(0, Config.sidebarWidth, 0, 0),
        ClipsDescendants = true,
        ZIndex = 15,
        Parent = ContentFrame,
    })
end

function switchTab(tabName)
    if State.activeTab == tabName then return end
    local oldTab = State.activeTab
    State.activeTab = tabName

    -- Update sidebar buttons
    for name, data in pairs(TabButtons) do
        if name == tabName then
            tweenObject(data.button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.surfaceActive}, 0.2)
            data.button:SetAttribute("TargetBgTransparency", 0)
            tweenObject(data.icon, {TextColor3 = Theme.accent}, 0.2)
            tweenObject(data.label, {TextColor3 = Theme.text}, 0.2)
            tweenObject(data.line, {BackgroundTransparency = 0}, 0.2)
        else
            tweenObject(data.button, {BackgroundTransparency = 1, BackgroundColor3 = Theme.bgSecondary}, 0.2)
            data.button:SetAttribute("TargetBgTransparency", 1)
            tweenObject(data.icon, {TextColor3 = Theme.textMuted}, 0.2)
            tweenObject(data.label, {TextColor3 = Theme.textSecondary}, 0.2)
            tweenObject(data.line, {BackgroundTransparency = 1}, 0.2)
        end
    end

    -- Switch tab content
    for name, frame in pairs(Tabs) do
        if name == tabName then
            frame.Visible = true
            frame.Position = UDim2.new(0.05, 0, 0, 0)
            tweenObject(frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quart)
            for _, desc in ipairs(frame:GetDescendants()) do
                pcall(function()
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                        tweenObject(desc, {TextTransparency = desc:GetAttribute("TargetTextTransparency") or 0}, 0.2)
                    end
                    if desc:IsA("Frame") or desc:IsA("TextButton") or desc:IsA("ScrollingFrame") then
                        tweenObject(desc, {BackgroundTransparency = desc:GetAttribute("TargetBgTransparency") or 0}, 0.2)
                    end
                    if desc:IsA("UIStroke") then
                        tweenObject(desc, {Transparency = desc:GetAttribute("TargetTransparency") or 0.5}, 0.2)
                    end
                end)
            end
        else
            if frame.Visible then
                for _, desc in ipairs(frame:GetDescendants()) do
                    pcall(function()
                        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                            tweenObject(desc, {TextTransparency = 1}, 0.15)
                        end
                        if desc:IsA("Frame") or desc:IsA("TextButton") or desc:IsA("ScrollingFrame") then
                            tweenObject(desc, {BackgroundTransparency = 1}, 0.15)
                        end
                        if desc:IsA("UIStroke") then
                            tweenObject(desc, {Transparency = 1}, 0.15)
                        end
                    end)
                end
                task.delay(0.2, function()
                    if State.activeTab ~= name then
                        frame.Visible = false
                    end
                end)
            end
        end
    end
end

local function buildTabContent(name, order)
    local scroll = createInstance("ScrollingFrame", {
        Name = "Tab_" .. name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.accent,
        ScrollBarImageTransparency = 0.5,
        Visible = (State.activeTab == name),
        ZIndex = 16,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = TabContainer,
    })
    addListLayout(scroll, Enum.FillDirection.Vertical, UDim.new(0, 6))
    addPadding(scroll, 12, 14, 12, 14)

    Tabs[name] = scroll
    return scroll
end

--// 13. ESP PLAYER SYSTEM

local ESPContainer
local ESPUpdateConnection

local function clearESP()
    for _, obj in pairs(ESP_Objects) do
        pcall(function()
            if obj.billboard then obj.billboard:Destroy() end
            if obj.box then obj.box:Destroy() end
        end)
    end
    ESP_Objects = {}
end

local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local role = getPlayerRole(player)
    local color = RoleColors[role] or RoleColors.Unknown

    -- Billboard for name/health/distance/role
    local billboard = createInstance("BillboardGui", {
        Name = "HoshiESP_" .. player.Name,
        Adornee = rootPart,
        Size = UDim2.new(0, 160, 0, 60),
        StudsOffset = Vector3.new(0, 3.5, 0),
        AlwaysOnTop = true,
        LightInfluence = 0,
        MaxDistance = 500,
    })

    local espFrame = createInstance("Frame", {
        BackgroundColor3 = Color3.fromRGB(10, 10, 16),
        BackgroundTransparency = 0.35,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = billboard,
    })
    addCorner(espFrame, UDim.new(0, 6))
    addStroke(espFrame, color, 1, 0.5)

    local nameLabel = createInstance("TextLabel", {
        Name = "Name",
        Text = player.DisplayName,
        Font = Config.fontMedium,
        TextSize = 12,
        TextColor3 = color,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 16),
        Position = UDim2.new(0, 4, 0, 2),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = espFrame,
    })

    local roleLabel = createInstance("TextLabel", {
        Name = "Role",
        Text = "[" .. role .. "]",
        Font = Config.fontRegular,
        TextSize = 10,
        TextColor3 = color,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 14),
        Position = UDim2.new(0, 4, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = espFrame,
    })

    local healthBar = createInstance("Frame", {
        Name = "HealthBg",
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Size = UDim2.new(0.8, 0, 0, 4),
        Position = UDim2.new(0.1, 0, 0, 34),
        Parent = espFrame,
    })
    addCorner(healthBar, UDim.new(1, 0))

    local healthFill = createInstance("Frame", {
        Name = "HealthFill",
        BackgroundColor3 = Theme.success,
        Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0),
        Parent = healthBar,
    })
    addCorner(healthFill, UDim.new(1, 0))

    local distLabel = createInstance("TextLabel", {
        Name = "Distance",
        Text = "0m",
        Font = Config.fontRegular,
        TextSize = 10,
        TextColor3 = Theme.textSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 14),
        Position = UDim2.new(0, 4, 0, 40),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = espFrame,
    })

    -- Highlight box
    local highlight = createInstance("Highlight", {
        Name = "HoshiHighlight_" .. player.Name,
        FillColor = color,
        FillTransparency = 0.8,
        OutlineColor = color,
        OutlineTransparency = 0.3,
        Adornee = player.Character,
    })

    billboard.Parent = player.Character
    highlight.Parent = player.Character

    ESP_Objects[player.UserId] = {
        player = player,
        billboard = billboard,
        highlight = highlight,
        nameLabel = nameLabel,
        roleLabel = roleLabel,
        healthFill = healthFill,
        distLabel = distLabel,
        espFrame = espFrame,
        color = color,
    }
end

local function updateESP()
    local myRoot = getRootPart()
    
    for userId, data in pairs(ESP_Objects) do
        local player = data.player
        if not player or not player.Parent then
            pcall(function()
                if data.billboard then data.billboard:Destroy() end
                if data.highlight then data.highlight:Destroy() end
            end)
            ESP_Objects[userId] = nil
        else
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root and data.healthFill then
                    data.healthFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
                    
                    local hpColor = lerpColor(Theme.error, Theme.success, math.clamp(hum.Health / hum.MaxHealth, 0, 1))
                    data.healthFill.BackgroundColor3 = hpColor
                    
                    if myRoot then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        data.distLabel.Text = formatNumber(dist) .. "m"
                    end
                    
                    local role = getPlayerRole(player)
                    local newColor = RoleColors[role] or RoleColors.Unknown
                    if data.color ~= newColor then
                        data.color = newColor
                        data.nameLabel.TextColor3 = newColor
                        data.roleLabel.TextColor3 = newColor
                        data.roleLabel.Text = "[" .. role .. "]"
                        if data.highlight then
                            data.highlight.FillColor = newColor
                            data.highlight.OutlineColor = newColor
                        end
                        local stroke = data.espFrame:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = newColor end
                    end
                end
            end
        end
    end
end

local function startESP()
    if ESPUpdateConnection then return end
    clearESP()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function() createESPForPlayer(player) end)
        end
    end

    addConnection(Players.PlayerAdded:Connect(function(player)
        if State.espEnabled then
            player.CharacterAdded:Connect(function()
                task.wait(1)
                if State.espEnabled then
                    pcall(function() createESPForPlayer(player) end)
                end
            end)
        end
    end))

    addConnection(Players.PlayerRemoving:Connect(function(player)
        local data = ESP_Objects[player.UserId]
        if data then
            pcall(function()
                if data.billboard then data.billboard:Destroy() end
                if data.highlight then data.highlight:Destroy() end
            end)
            ESP_Objects[player.UserId] = nil
        end
    end))

    -- Refresh loop
    task.spawn(function()
        while State.espEnabled and not State.destroyed do
            -- Re-create for players that respawned
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not ESP_Objects[player.UserId] then
                    pcall(function() createESPForPlayer(player) end)
                end
            end
            updateESP()
            task.wait(Config.espUpdateInterval)
        end
    end)
end

local function stopESP()
    State.espEnabled = false
    clearESP()
end

local function buildESPTab()
    local tab = buildTabContent("ESP", 1)
    
    buildSectionLabel(tab, "ESP Player", 17)
    
    buildToggle(tab, "Enable ESP", false, function(val)
        State.espEnabled = val
        if val then
            startESP()
            notify("ESP", "ESP Player enabled", 2, "SUCCESS")
        else
            stopESP()
            notify("ESP", "ESP Player disabled", 2, "INFO")
        end
    end, 17)
    
    buildStatusLabel(tab, "ESPStatus", "Status: Disabled", 17)

    -- Auto-update status
    task.spawn(function()
        while not State.destroyed do
            if Tabs["ESP"] and Tabs["ESP"]:FindFirstChild("ESPStatus") then
                local count = 0
                for _ in pairs(ESP_Objects) do count = count + 1 end
                Tabs["ESP"].ESPStatus.Text = State.espEnabled 
                    and ("Status: Active | Tracking: " .. count .. " players") 
                    or "Status: Disabled"
            end
            task.wait(1)
        end
    end)
end

--// 14. TELEPORT SAFETY SYSTEM

local TeleportCooldownActive = false

local function isPositionSafe(pos)
    -- Check if position is above void
    local downRay = Workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -100, 0))
    if not downRay then return false end
    
    -- Check ground distance
    local groundY = downRay.Position.Y
    if pos.Y - groundY > 20 then return false end
    
    -- Check not inside wall (cast in 4 directions)
    local directions = {
        Vector3.new(2, 0, 0),
        Vector3.new(-2, 0, 0),
        Vector3.new(0, 0, 2),
        Vector3.new(0, 0, -2),
    }
    local insideCount = 0
    for _, dir in ipairs(directions) do
        local ray = Workspace:Raycast(pos, dir)
        if ray and (ray.Position - pos).Magnitude < 1.5 then
            insideCount = insideCount + 1
        end
    end
    if insideCount >= 3 then return false end
    
    -- Check head clearance
    local upRay = Workspace:Raycast(pos, Vector3.new(0, 6, 0))
    if upRay and (upRay.Position - pos).Magnitude < 4 then return false end
    
    return true
end

local function findSafePosition()
    local myRoot = getRootPart()
    if not myRoot then return nil end
    
    local killers = getKillers()
    local killerPositions = {}
    for _, killer in ipairs(killers) do
        if killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(killerPositions, killer.Character.HumanoidRootPart.Position)
        end
    end

    local bestPos = nil
    local bestScore = -math.huge
    
    local myPos = myRoot.Position
    local attempts = 60
    
    for i = 1, attempts do
        -- Generate candidate positions in a ring pattern
        local angle = (i / attempts) * math.pi * 2
        local radius = State.teleportSafeDistance + math.random(0, 30)
        local candidatePos = myPos + Vector3.new(
            math.cos(angle) * radius,
            0,
            math.sin(angle) * radius
        )
        
        -- Snap to ground
        local groundRay = Workspace:Raycast(candidatePos + Vector3.new(0, 50, 0), Vector3.new(0, -200, 0))
        if groundRay then
            candidatePos = groundRay.Position + Vector3.new(0, 3, 0)
            
            if isPositionSafe(candidatePos) then
                -- Score: distance from all killers (higher = better)
                local minKillerDist = math.huge
                for _, kpos in ipairs(killerPositions) do
                    local d = (candidatePos - kpos).Magnitude
                    minKillerDist = math.min(minKillerDist, d)
                end
                
                if #killerPositions == 0 then
                    minKillerDist = radius
                end
                
                if minKillerDist > bestScore then
                    bestScore = minKillerDist
                    bestPos = candidatePos
                end
            end
        end
    end
    
    -- Fallback: try grid-based search
    if not bestPos then
        for x = -150, 150, 20 do
            for z = -150, 150, 20 do
                local candidatePos = myPos + Vector3.new(x, 0, z)
                local groundRay = Workspace:Raycast(candidatePos + Vector3.new(0, 50, 0), Vector3.new(0, -200, 0))
                if groundRay then
                    candidatePos = groundRay.Position + Vector3.new(0, 3, 0)
                    if isPositionSafe(candidatePos) then
                        local minKillerDist = math.huge
                        for _, kpos in ipairs(killerPositions) do
                            minKillerDist = math.min(minKillerDist, (candidatePos - kpos).Magnitude)
                        end
                        if #killerPositions == 0 then minKillerDist = 100 end
                        if minKillerDist > bestScore then
                            bestScore = minKillerDist
                            bestPos = candidatePos
                        end
                    end
                end
            end
        end
    end
    
    return bestPos, bestScore
end

local function executeTeleportSafety()
    if TeleportCooldownActive then
        notify("Teleport", "Cooldown active, please wait", 2, "WARNING")
        return
    end
    
    local myRoot = getRootPart()
    if not myRoot then
        notify("Teleport", "Character not found", 2, "ERROR")
        return
    end
    
    -- Check if any killer is nearby
    local killers = getKillers()
    local nearbyKiller = false
    
    for _, killer in ipairs(killers) do
        if killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (killer.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist <= State.teleportRadius then
                nearbyKiller = true
                break
            end
        end
    end
    
    if not nearbyKiller and #killers > 0 then
        notify("Teleport", "No killer nearby (radius: " .. State.teleportRadius .. ")", 2, "INFO")
        return
    end
    
    local safePos, score = findSafePosition()
    if safePos then
        myRoot.CFrame = CFrame.new(safePos)
        TeleportCooldownActive = true
        notify("Teleport", "Teleported safely (distance: " .. formatNumber(score) .. " studs)", 2, "SUCCESS")
        
        task.delay(State.teleportCooldown, function()
            TeleportCooldownActive = false
        end)
    else
        notify("Teleport", "No safe position found", 2, "ERROR")
    end
end

local TeleportAutoConnection

local function buildTeleportTab()
    local tab = buildTabContent("Teleport", 2)
    
    buildSectionLabel(tab, "Teleport Safety", 17)
    
    local _, toggleApi = buildToggle(tab, "Auto Teleport", false, function(val)
        State.teleportEnabled = val
        if val then
            notify("Teleport", "Auto Teleport Safety enabled", 2, "SUCCESS")
        else
            notify("Teleport", "Auto Teleport Safety disabled", 2, "INFO")
        end
    end, 17)
    
    buildSlider(tab, "Detection Radius", 20, 80, State.teleportRadius, function(val)
        State.teleportRadius = val
    end, 17)
    
    buildSlider(tab, "Safe Distance", 50, 200, State.teleportSafeDistance, function(val)
        State.teleportSafeDistance = val
    end, 17)
    
    buildSlider(tab, "Cooldown (s)", 1, 10, State.teleportCooldown, function(val)
        State.teleportCooldown = val
    end, 17)
    
    buildButton(tab, "Teleport Now", function()
        executeTeleportSafety()
    end, 17)
    
    local statusLabel = buildStatusLabel(tab, "TeleportStatus", "Status: Disabled", 17)

    -- Auto teleport loop
    task.spawn(function()
        while not State.destroyed do
            if State.teleportEnabled and not TeleportCooldownActive then
                local myRoot = getRootPart()
                if myRoot then
                    local killers = getKillers()
                    for _, killer in ipairs(killers) do
                        if killer.Character and killer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (killer.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                            if dist <= State.teleportRadius then
                                executeTeleportSafety()
                                break
                            end
                        end
                    end
                end
            end
            
            -- Update status
            if Tabs["Teleport"] and Tabs["Teleport"]:FindFirstChild("TeleportStatus") then
                local cooldownText = TeleportCooldownActive and " | Cooldown Active" or ""
                Tabs["Teleport"].TeleportStatus.Text = State.teleportEnabled 
                    and ("Status: Active | Radius: " .. State.teleportRadius .. " | Safe: " .. State.teleportSafeDistance .. cooldownText)
                    or "Status: Disabled"
            end
            
            task.wait(0.5)
        end
    end)
end

--// 15. SPEED RUN SYSTEM

local OriginalWalkSpeed = 16

local function applySpeed()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = OriginalWalkSpeed * State.speedValue
    end
end

local function buildSpeedTab()
    local tab = buildTabContent("Speed", 3)
    
    buildSectionLabel(tab, "Speed Run", 17)
    
    buildToggle(tab, "Enable Speed", false, function(val)
        State.speedEnabled = val
        if val then
            local hum = getHumanoid()
            if hum then
                OriginalWalkSpeed = 16
            end
            applySpeed()
            notify("Speed", "Speed Run enabled (x" .. State.speedValue .. ")", 2, "SUCCESS")
        else
            local hum = getHumanoid()
            if hum then
                hum.WalkSpeed = 16
            end
            notify("Speed", "Speed Run disabled", 2, "INFO")
        end
    end, 17)
    
    buildSlider(tab, "Speed Multiplier", 1, 10, State.speedValue, function(val)
        State.speedValue = val
        if State.speedEnabled then
            applySpeed()
        end
    end, 17)
    
    buildTextInput(tab, "Speed Value", tostring(State.speedValue), "1-10", function(text)
        local num = tonumber(text)
        if num then
            num = math.clamp(math.floor(num), 1, 10)
            State.speedValue = num
            if State.speedEnabled then
                applySpeed()
            end
        end
    end, 17)
    
    buildStatusLabel(tab, "SpeedStatus", "Status: Disabled", 17)

    -- Speed maintain loop
    task.spawn(function()
        while not State.destroyed do
            if State.speedEnabled then
                applySpeed()
            end
            if Tabs["Speed"] and Tabs["Speed"]:FindFirstChild("SpeedStatus") then
                Tabs["Speed"].SpeedStatus.Text = State.speedEnabled 
                    and ("Status: Active | Speed: x" .. State.speedValue .. " (" .. formatNumber(OriginalWalkSpeed * State.speedValue) .. " studs/s)")
                    or "Status: Disabled"
            end
            task.wait(0.5)
        end
    end)
end

--// 16. POV CIRCLE SYSTEM

local POVCircle

local function buildPOVCircle()
    if POVCircle then
        pcall(function() POVCircle:Destroy() end)
    end
    
    POVCircle = createInstance("Frame", {
        Name = "POVCircle",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, State.povRadius * 2, 0, State.povRadius * 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = State.povEnabled,
        ZIndex = 40,
        Parent = ScreenGui,
    })
    
    -- Draw circle using UIStroke on a round frame
    local circleFrame = createInstance("Frame", {
        Name = "Circle",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 41,
        Parent = POVCircle,
    })
    addCorner(circleFrame, UDim.new(0.5, 0))
    local circleStroke = addStroke(circleFrame, State.povColor, State.povThickness, State.povTransparency)
    circleStroke:SetAttribute("TargetTransparency", State.povTransparency)
    
    -- Center dot
    local centerDot = createInstance("Frame", {
        Name = "Dot",
        BackgroundColor3 = State.povColor,
        BackgroundTransparency = State.povTransparency,
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 42,
        Parent = POVCircle,
    })
    addCorner(centerDot, UDim.new(1, 0))
    
    -- Crosshair lines
    local lineSize = 10
    local lines = {
        {pos = UDim2.new(0.5, 0, 0.5, -lineSize - 4), size = UDim2.new(0, 2, 0, lineSize)},
        {pos = UDim2.new(0.5, 0, 0.5, 4), size = UDim2.new(0, 2, 0, lineSize)},
        {pos = UDim2.new(0.5, -lineSize - 4, 0.5, 0), size = UDim2.new(0, lineSize, 0, 2)},
        {pos = UDim2.new(0.5, 4, 0.5, 0), size = UDim2.new(0, lineSize, 0, 2)},
    }
    for _, l in ipairs(lines) do
        createInstance("Frame", {
            BackgroundColor3 = State.povColor,
            BackgroundTransparency = State.povTransparency + 0.2,
            Size = l.size,
            Position = l.pos,
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 42,
            Parent = POVCircle,
        })
    end
end

local function updatePOVCirclePosition()
    if not POVCircle or not State.povEnabled then return end
    local cam = getCamera()
    if not cam then return end
    local vpSize = cam.ViewportSize
    POVCircle.Position = UDim2.new(0, vpSize.X / 2, 0, vpSize.Y / 2)
end

local function updatePOVCircleAppearance()
    if not POVCircle then return end
    tweenObject(POVCircle, {Size = UDim2.new(0, State.povRadius * 2, 0, State.povRadius * 2)}, 0.2)
    
    local circle = POVCircle:FindFirstChild("Circle")
    if circle then
        local stroke = circle:FindFirstChildOfClass("UIStroke")
        if stroke then
            tweenObject(stroke, {Color = State.povColor, Thickness = State.povThickness, Transparency = State.povTransparency}, 0.2)
        end
    end
    
    local dot = POVCircle:FindFirstChild("Dot")
    if dot then
        tweenObject(dot, {BackgroundColor3 = State.povColor, BackgroundTransparency = State.povTransparency}, 0.2)
    end
end

local function buildPOVTab()
    local tab = buildTabContent("POV", 4)
    
    buildSectionLabel(tab, "POV Circle / Crosshair", 17)
    
    buildToggle(tab, "Enable POV Circle", false, function(val)
        State.povEnabled = val
        if POVCircle then
            if val then
                POVCircle.Visible = true
                tweenObject(POVCircle, {}, 0.1) -- ensure visible
                for _, desc in ipairs(POVCircle:GetDescendants()) do
                    pcall(function()
                        if desc:IsA("Frame") then
                            tweenObject(desc, {BackgroundTransparency = desc:GetAttribute("TargetBgTransparency") or State.povTransparency}, 0.3)
                        end
                        if desc:IsA("UIStroke") then
                            tweenObject(desc, {Transparency = desc:GetAttribute("TargetTransparency") or State.povTransparency}, 0.3)
                        end
                    end)
                end
                notify("POV", "POV Circle enabled", 2, "SUCCESS")
            else
                for _, desc in ipairs(POVCircle:GetDescendants()) do
                    pcall(function()
                        if desc:IsA("Frame") then
                            tweenObject(desc, {BackgroundTransparency = 1}, 0.2)
                        end
                        if desc:IsA("UIStroke") then
                            tweenObject(desc, {Transparency = 1}, 0.2)
                        end
                    end)
                end
                task.delay(0.25, function()
                    if POVCircle then POVCircle.Visible = false end
                end)
                notify("POV", "POV Circle disabled", 2, "INFO")
            end
        end
    end, 17)
    
    buildSlider(tab, "Radius", 30, 300, State.povRadius, function(val)
        State.povRadius = val
        updatePOVCircleAppearance()
    end, 17)
    
    buildSlider(tab, "Thickness", 1, 6, State.povThickness, function(val)
        State.povThickness = val
        updatePOVCircleAppearance()
    end, 17)
    
    buildSlider(tab, "Transparency (%)", 0, 90, math.floor(State.povTransparency * 100), function(val)
        State.povTransparency = val / 100
        updatePOVCircleAppearance()
    end, 17)
    
    buildStatusLabel(tab, "POVStatus", "Status: Disabled", 17)
    
    task.spawn(function()
        while not State.destroyed do
            if Tabs["POV"] and Tabs["POV"]:FindFirstChild("POVStatus") then
                Tabs["POV"].POVStatus.Text = State.povEnabled 
                    and ("Status: Active | Radius: " .. State.povRadius .. " | Thickness: " .. State.povThickness)
                    or "Status: Disabled"
            end
            task.wait(1)
        end
    end)
end

--// 17. OBSERVATION TARGET SYSTEM

local ObsIndicators = {}
local ObsHighlights = {}

local function clearObservation()
    for _, ind in pairs(ObsIndicators) do
        pcall(function() ind:Destroy() end)
    end
    for _, hl in pairs(ObsHighlights) do
        pcall(function() hl:Destroy() end)
    end
    ObsIndicators = {}
    ObsHighlights = {}
end

local function createObsIndicator(player)
    if player == LocalPlayer then return end
    
    local indicator = createInstance("Frame", {
        Name = "ObsInd_" .. player.Name,
        BackgroundColor3 = State.obsColor,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = false,
        ZIndex = 45,
        Parent = ScreenGui,
    })
    addCorner(indicator, UDim.new(1, 0))
    addStroke(indicator, State.obsColor, 1, 0.3)
    
    local nameTag = createInstance("TextLabel", {
        Name = "Name",
        Text = player.DisplayName,
        Font = Config.fontMedium,
        TextSize = 10,
        TextColor3 = State.obsColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 14),
        Position = UDim2.new(0.5, 0, 0, -16),
        AnchorPoint = Vector2.new(0.5, 1),
        ZIndex = 46,
        Parent = indicator,
    })
    
    ObsIndicators[player.UserId] = indicator
    
    return indicator
end

local function updateObservation()
    if not State.obsEnabled then return end
    
    local cam = getCamera()
    if not cam then return end
    local vpSize = cam.ViewportSize
    local screenCenter = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = getPlayerRole(player)
            if role == "Survivor" then
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                local indicator = ObsIndicators[player.UserId]
                if not indicator then
                    indicator = createObsIndicator(player)
                end
                
                if root and hum and hum.Health > 0 and indicator then
                    local worldPos = root.Position + Vector3.new(0, 2, 0)
                    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
                    
                    if onScreen then
                        local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                        local distFromCenter = (screenPoint - screenCenter).Magnitude
                        
                        if distFromCenter <= State.obsRadius then
                            indicator.Visible = true
                            indicator.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                            indicator.BackgroundTransparency = State.obsTransparency
                            indicator.BackgroundColor3 = State.obsColor
                            
                            local nameTag = indicator:FindFirstChild("Name")
                            if nameTag then
                                nameTag.TextColor3 = State.obsColor
                            end
                            
                            -- Add highlight if not exists
                            if not ObsHighlights[player.UserId] and char then
                                local hl = createInstance("Highlight", {
                                    Name = "ObsHL_" .. player.Name,
                                    FillColor = State.obsColor,
                                    FillTransparency = 0.85,
                                    OutlineColor = State.obsColor,
                                    OutlineTransparency = 0.4,
                                    Adornee = char,
                                    Parent = char,
                                })
                                ObsHighlights[player.UserId] = hl
                            end
                        else
                            indicator.Visible = false
                            if ObsHighlights[player.UserId] then
                                pcall(function() ObsHighlights[player.UserId]:Destroy() end)
                                ObsHighlights[player.UserId] = nil
                            end
                        end
                    else
                        indicator.Visible = false
                        if ObsHighlights[player.UserId] then
                            pcall(function() ObsHighlights[player.UserId]:Destroy() end)
                            ObsHighlights[player.UserId] = nil
                        end
                    end
                else
                    if indicator then indicator.Visible = false end
                    if ObsHighlights[player.UserId] then
                        pcall(function() ObsHighlights[player.UserId]:Destroy() end)
                        ObsHighlights[player.UserId] = nil
                    end
                end
            end
        end
    end
    
    -- Clean up indicators for players who left
    for userId, indicator in pairs(ObsIndicators) do
        local player = Players:GetPlayerByUserId(userId)
        if not player or not player.Parent then
            pcall(function() indicator:Destroy() end)
            ObsIndicators[userId] = nil
            if ObsHighlights[userId] then
                pcall(function() ObsHighlights[userId]:Destroy() end)
                ObsHighlights[userId] = nil
            end
        end
    end
end

local function buildObserveTab()
    local tab = buildTabContent("Observe", 5)
    
    buildSectionLabel(tab, "Observation Target", 17)
    
    buildToggle(tab, "Enable Observation", false, function(val)
        State.obsEnabled = val
        if val then
            notify("Observe", "Observation enabled", 2, "SUCCESS")
        else
            clearObservation()
            notify("Observe", "Observation disabled", 2, "INFO")
        end
    end, 17)
    
    buildSlider(tab, "Detection Radius (px)", 50, 400, State.obsRadius, function(val)
        State.obsRadius = val
    end, 17)
    
    buildSlider(tab, "Transparency (%)", 0, 90, math.floor(State.obsTransparency * 100), function(val)
        State.obsTransparency = val / 100
    end, 17)
    
    buildStatusLabel(tab, "ObsStatus", "Status: Disabled", 17)
    
    buildSectionLabel(tab, "Information", 17)
    
    buildStatusLabel(tab, "ObsInfo", "Observation tracks Survivor positions within the POV area for hitbox, collision, and tracking analysis.", 17)
    
    task.spawn(function()
        while not State.destroyed do
            if Tabs["Observe"] and Tabs["Observe"]:FindFirstChild("ObsStatus") then
                local count = 0
                for _, ind in pairs(ObsIndicators) do
                    if ind.Visible then count = count + 1 end
                end
                Tabs["Observe"].ObsStatus.Text = State.obsEnabled 
                    and ("Status: Active | Targets in view: " .. count .. " | Radius: " .. State.obsRadius .. "px")
                    or "Status: Disabled"
            end
            task.wait(0.5)
        end
    end)
end

--// 18. SETTINGS TAB

local function buildSettingsTab()
    local tab = buildTabContent("Settings", 6)
    
    buildSectionLabel(tab, "Interface", 17)
    
    buildSlider(tab, "Animation Speed", 50, 200, math.floor(State.animSpeed * 100), function(val)
        State.animSpeed = val / 100
    end, 17)
    
    buildToggle(tab, "Background Blur", State.blurEnabled, function(val)
        State.blurEnabled = val
        if not val and BlurEffect then
            tweenObject(BlurEffect, {Size = 0}, 0.3)
        elseif val and State.guiOpen and BlurEffect then
            tweenObject(BlurEffect, {Size = 12}, 0.3)
        end
    end, 17)
    
    buildSectionLabel(tab, "Colors", 17)
    
    buildSlider(tab, "Accent Red", 0, 255, State.accentColor.R * 255, function(val)
        State.accentColor = Color3.fromRGB(val, State.accentColor.G * 255, State.accentColor.B * 255)
        Theme.accent = State.accentColor
    end, 17)
    
    buildSlider(tab, "Accent Green", 0, 255, State.accentColor.G * 255, function(val)
        State.accentColor = Color3.fromRGB(State.accentColor.R * 255, val, State.accentColor.B * 255)
        Theme.accent = State.accentColor
    end, 17)
    
    buildSlider(tab, "Accent Blue", 0, 255, State.accentColor.B * 255, function(val)
        State.accentColor = Color3.fromRGB(State.accentColor.R * 255, State.accentColor.G * 255, val)
        Theme.accent = State.accentColor
    end, 17)
    
    buildSectionLabel(tab, "System", 17)
    
    buildButton(tab, "Reset All Settings", function()
        State.animSpeed = 1
        State.blurEnabled = true
        State.accentColor = Color3.fromRGB(0, 170, 255)
        Theme.accent = State.accentColor
        notify("Settings", "All settings have been reset", 2, "SUCCESS")
    end, 17, Theme.warning)
    
    buildButton(tab, "Destroy Script", function()
        cleanup()
    end, 17, Theme.error)
end

--// 19. INITIALIZATION

local function init()
    -- Cleanup old instances
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        local old = coreGui:FindFirstChild("HoshiDevTools")
        if old then old:Destroy() end
    end)
    pcall(function()
        local old = LocalPlayer.PlayerGui:FindFirstChild("HoshiDevTools")
        if old then old:Destroy() end
    end)
    pcall(function()
        local oldBlur = Lighting:FindFirstChild("HoshiBlur")
        if oldBlur then oldBlur:Destroy() end
    end)
    
    buildScreenGui()
    
    showSplashScreen(function()
        if State.destroyed then return end
        
        buildMainWindow()
        buildFloatingButton()
        buildWatermark()
        buildNotificationContainer()
        buildSidebar()
        
        -- Build all tabs
        buildESPTab()
        buildTeleportTab()
        buildSpeedTab()
        buildPOVTab()
        buildObserveTab()
        buildSettingsTab()
        
        -- Build POV Circle
        buildPOVCircle()
        
        -- RenderStepped for realtime updates
        addConnection(RunService.RenderStepped:Connect(function()
            if State.destroyed then return end
            updatePOVCirclePosition()
            if State.obsEnabled then
                updateObservation()
            end
        end))
        
        -- Character respawn handling
        addConnection(LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(1)
            if State.speedEnabled then
                applySpeed()
            end
        end))
        
        -- Show window
        State.guiOpen = true
        openWindow()
        
        task.delay(0.5, function()
            notify("Hoshi", "Development Tools loaded successfully", 3, "SUCCESS")
        end)
    end)
end

--// 20. CLEANUP

function cleanup()
    State.destroyed = true
    
    -- Disconnect all events
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
    
    -- Clear ESP
    clearESP()
    
    -- Clear observation
    clearObservation()
    
    -- Reset speed
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = 16
    end
    
    -- Remove blur
    if BlurEffect then
        pcall(function() BlurEffect:Destroy() end)
    end
    
    -- Remove GUI
    if ScreenGui then
        pcall(function() ScreenGui:Destroy() end)
    end
    
    FloatingPulseLoop = false
end

-- Start
init()