-- ============================================================
-- HOSHI ADMIN DEVELOPMENT TOOLS v2.0
-- Loader Script
-- Format: loadstring(game:HttpGet("LINK"))()
-- ============================================================

-- [HOSHI] Loader initialization
local HOSHI_VERSION = "2.0.0"
local HOSHI_BUILD = "TERMINAL"

-- Cleanup previous instances
if _G.HOSHI_CLEANUP then
    pcall(_G.HOSHI_CLEANUP)
end

-- Main script execution
local function InitHoshi()

-- ============================================================
-- MODULE: Config
-- ============================================================
local Config = {
    Version = HOSHI_VERSION,
    Build = HOSHI_BUILD,
    
    -- UI Config
    Colors = {
        Background = Color3.fromRGB(10, 10, 10),
        BackgroundAlt = Color3.fromRGB(15, 15, 15),
        Panel = Color3.fromRGB(12, 12, 12),
        Border = Color3.fromRGB(0, 255, 136),
        BorderDim = Color3.fromRGB(0, 80, 45),
        Text = Color3.fromRGB(0, 255, 136),
        TextDim = Color3.fromRGB(0, 160, 90),
        TextBright = Color3.fromRGB(150, 255, 200),
        Accent = Color3.fromRGB(0, 255, 136),
        AccentDim = Color3.fromRGB(0, 120, 68),
        Error = Color3.fromRGB(255, 60, 60),
        Warning = Color3.fromRGB(255, 200, 0),
        Info = Color3.fromRGB(0, 180, 255),
        White = Color3.fromRGB(200, 200, 200),
        Black = Color3.fromRGB(0, 0, 0),
        Cursor = Color3.fromRGB(0, 255, 136),
        Selection = Color3.fromRGB(0, 255, 136),
        Comment = Color3.fromRGB(0, 100, 60),
        Keyword = Color3.fromRGB(0, 255, 180),
        String = Color3.fromRGB(100, 255, 170),
        Number = Color3.fromRGB(180, 255, 200),
        Separator = Color3.fromRGB(0, 60, 35),
        
        -- Role colors for ESP
        Killer = Color3.fromRGB(255, 50, 50),
        Survivor = Color3.fromRGB(0, 200, 255),
        Unknown = Color3.fromRGB(180, 180, 180),
    },
    
    Font = Enum.Font.Code,
    FontBold = Enum.Font.Code,
    FontSize = 13,
    FontSizeSmall = 11,
    FontSizeLarge = 16,
    FontSizeTitle = 18,
    FontSizeHeader = 22,
    
    -- Feature defaults
    ESP = {
        Enabled = false,
        ShowBox = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowRole = true,
    },
    
    Teleport = {
        Enabled = false,
        Radius = 35,
        Cooldown = 3,
        TeleportDistance = 100,
        LastTeleport = 0,
    },
    
    Speed = {
        Value = 1,
        DefaultWalkSpeed = 16,
    },
    
    POV = {
        Enabled = false,
        Radius = 100,
        Thickness = 2,
        Opacity = 0.8,
        Color = Color3.fromRGB(0, 255, 136),
        TargetPlayer = nil,
        Following = false,
    },
    
    OnPoint = {
        Enabled = false,
        Radius = 50,
        Transparency = 0.5,
        Color = Color3.fromRGB(255, 255, 0),
        SmoothUpdate = true,
    },
    
    UI = {
        MinSize = Vector2.new(700, 450),
        MaxSize = Vector2.new(1200, 800),
        DefaultSize = Vector2.new(850, 550),
        Minimized = false,
        CurrentTab = "ESP",
    },
}

-- ============================================================
-- MODULE: Services
-- ============================================================
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    Camera = workspace.CurrentCamera,
}

local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- MODULE: Utilities
-- ============================================================
local Utilities = {}

-- Connection tracker for cleanup
Utilities.Connections = {}
Utilities.Instances = {}

function Utilities:AddConnection(conn)
    table.insert(self.Connections, conn)
    return conn
end

function Utilities:AddInstance(inst)
    table.insert(self.Instances, inst)
    return inst
end

function Utilities:CleanupAll()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, inst in ipairs(self.Instances) do
        pcall(function() inst:Destroy() end)
    end
    self.Connections = {}
    self.Instances = {}
end

function Utilities:Tween(instance, props, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local tween = Services.TweenService:Create(instance, tweenInfo, props)
    tween:Play()
    return tween
end

function Utilities:GetCharacter(player)
    return player and player.Character
end

function Utilities:GetHumanoid(player)
    local char = self:GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utilities:GetRootPart(player)
    local char = self:GetCharacter(player)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

function Utilities:GetHead(player)
    local char = self:GetCharacter(player)
    return char and char:FindFirstChild("Head")
end

function Utilities:GetDistance(player)
    local myRoot = self:GetRootPart(LocalPlayer)
    local theirRoot = self:GetRootPart(player)
    if myRoot and theirRoot then
        return (myRoot.Position - theirRoot.Position).Magnitude
    end
    return math.huge
end

function Utilities:GetHealth(player)
    local hum = self:GetHumanoid(player)
    if hum then
        return hum.Health, hum.MaxHealth
    end
    return 0, 100
end

-- Detect role based on common game patterns
function Utilities:GetRole(player)
    -- Check common role indicators
    local char = self:GetCharacter(player)
    if not char then return "Unknown" end
    
    -- Check for team
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("monster") or teamName:find("beast") or teamName:find("hunter") then
            return "Killer"
        elseif teamName:find("survivor") or teamName:find("runner") or teamName:find("innocent") or teamName:find("player") then
            return "Survivor"
        end
    end
    
    -- Check for BoolValue or StringValue tags
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BoolValue") or v:IsA("StringValue") then
            local name = v.Name:lower()
            if name:find("killer") or name:find("monster") or name:find("beast") then
                return "Killer"
            elseif name:find("survivor") or name:find("runner") then
                return "Survivor"
            end
        end
    end
    
    -- Check player attributes
    pcall(function()
        for _, attrName in pairs({"Role", "PlayerRole", "GameRole", "Type"}) do
            local attr = player:GetAttribute(attrName)
            if attr then
                local attrLower = tostring(attr):lower()
                if attrLower:find("killer") or attrLower:find("monster") then
                    return "Killer"
                elseif attrLower:find("survivor") or attrLower:find("runner") then
                    return "Survivor"
                end
            end
        end
    end)
    
    return "Unknown"
end

function Utilities:GetRoleColor(role)
    if role == "Killer" then
        return Config.Colors.Killer
    elseif role == "Survivor" then
        return Config.Colors.Survivor
    end
    return Config.Colors.Unknown
end

function Utilities:FormatTime()
    return os.date("%H:%M:%S")
end

function Utilities:WorldToScreen(position)
    local screenPos, onScreen = Services.Camera:WorldToScreenPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- ============================================================
-- MODULE: Notification System
-- ============================================================
local Notification = {}
Notification.Queue = {}
Notification.Container = nil

function Notification:Init(parent)
    self.Container = Instance.new("Frame")
    self.Container.Name = "NotificationContainer"
    self.Container.Size = UDim2.new(0, 350, 1, 0)
    self.Container.Position = UDim2.new(1, -360, 0, 10)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = self.Container
    
    Utilities:AddInstance(self.Container)
end

function Notification:Push(message, notifType, duration)
    if not self.Container then return end
    
    notifType = notifType or "INFO"
    duration = duration or 4
    
    local prefixColor = Config.Colors.Info
    if notifType == "ERROR" then prefixColor = Config.Colors.Error
    elseif notifType == "WARN" then prefixColor = Config.Colors.Warning
    elseif notifType == "OK" then prefixColor = Config.Colors.Accent end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Config.Colors.Background
    frame.BorderSizePixel = 1
    frame.BorderColor3 = prefixColor
    frame.BackgroundTransparency = 1
    frame.Parent = self.Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Config.Font
    label.TextSize = Config.FontSizeSmall
    label.TextColor3 = prefixColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Text = "[" .. Utilities:FormatTime() .. "] [" .. notifType .. "] " .. message
    label.TextTransparency = 1
    label.Parent = frame
    
    -- Animate in
    Utilities:Tween(frame, {BackgroundTransparency = 0.2}, 0.3)
    Utilities:Tween(label, {TextTransparency = 0}, 0.3)
    
    -- Auto remove
    task.delay(duration, function()
        if frame and frame.Parent then
            Utilities:Tween(frame, {BackgroundTransparency = 1}, 0.5)
            Utilities:Tween(label, {TextTransparency = 1}, 0.5)
            task.wait(0.5)
            pcall(function() frame:Destroy() end)
        end
    end)
end

-- ============================================================
-- MODULE: UI Builder
-- ============================================================
local UI = {}
UI.ScreenGui = nil
UI.MainFrame = nil
UI.Sidebar = nil
UI.ContentArea = nil
UI.Tabs = {}
UI.TabButtons = {}
UI.ToggleButton = nil
UI.StatusBar = nil
UI.IsVisible = false
UI.IsDragging = false
UI.IsResizing = false
UI.DragStart = nil
UI.StartPos = nil
UI.ResizeStart = nil
UI.ResizeStartSize = nil

function UI:Create(class, props, children)
    local instance = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() instance[k] = v end)
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    if props and props.Parent then
        instance.Parent = props.Parent
    end
    return instance
end

function UI:MakeTerminalLine(text, parent, color, indent)
    color = color or Config.Colors.Text
    indent = indent or 0
    
    local line = self:Create("TextLabel", {
        Size = UDim2.new(1, -(10 + indent), 0, 18),
        Position = UDim2.new(0, 5 + indent, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = parent,
    })
    return line
end

function UI:MakeTerminalButton(text, parent, callback)
    local btn = self:Create("TextButton", {
        Size = UDim2.new(1, -10, 0, 26),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.Text,
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = parent,
    })
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.Parent = btn
    
    btn.MouseEnter:Connect(function()
        Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.AccentDim, TextColor3 = Config.Colors.TextBright}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.Background, TextColor3 = Config.Colors.Text}, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        -- Ripple flash effect
        Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.Accent}, 0.05)
        task.wait(0.05)
        Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.AccentDim}, 0.15)
        if callback then callback() end
    end)
    
    return btn
end

function UI:MakeTerminalToggle(labelText, parent, default, callback)
    local container = self:Create("Frame", {
        Size = UDim2.new(1, -10, 0, 26),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Parent = parent,
    })
    
    local state = default or false
    
    local label = self:Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = labelText,
        Parent = container,
    })
    
    local stateLabel = self:Create("TextLabel", {
        Size = UDim2.new(0, 65, 1, -4),
        Position = UDim2.new(1, -70, 0, 2),
        BackgroundColor3 = state and Config.Colors.AccentDim or Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 1,
        BorderColor3 = state and Config.Colors.Accent or Config.Colors.BorderDim,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = state and Config.Colors.Accent or Config.Colors.TextDim,
        Text = state and "[ON]" or "[OFF]",
        Parent = container,
    })
    
    local clickBtn = self:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container,
    })
    
    clickBtn.MouseEnter:Connect(function()
        Utilities:Tween(container, {BorderColor3 = Config.Colors.Accent}, 0.15)
    end)
    clickBtn.MouseLeave:Connect(function()
        Utilities:Tween(container, {BorderColor3 = Config.Colors.BorderDim}, 0.15)
    end)
    
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        Utilities:Tween(stateLabel, {
            BackgroundColor3 = state and Config.Colors.AccentDim or Color3.fromRGB(40, 40, 40),
            BorderColor3 = state and Config.Colors.Accent or Config.Colors.BorderDim,
            TextColor3 = state and Config.Colors.Accent or Config.Colors.TextDim,
        }, 0.2)
        stateLabel.Text = state and "[ON]" or "[OFF]"
        if callback then callback(state) end
    end)
    
    return container, function() return state end, function(newState)
        state = newState
        stateLabel.Text = state and "[ON]" or "[OFF]"
        Utilities:Tween(stateLabel, {
            BackgroundColor3 = state and Config.Colors.AccentDim or Color3.fromRGB(40, 40, 40),
            BorderColor3 = state and Config.Colors.Accent or Config.Colors.BorderDim,
            TextColor3 = state and Config.Colors.Accent or Config.Colors.TextDim,
        }, 0.2)
    end
end

function UI:MakeTerminalSlider(labelText, parent, min, max, default, callback)
    local container = self:Create("Frame", {
        Size = UDim2.new(1, -10, 0, 44),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Parent = parent,
    })
    
    local currentValue = default or min
    
    local label = self:Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 8, 0, 2),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = labelText,
        Parent = container,
    })
    
    local valueBox = self:Create("TextBox", {
        Size = UDim2.new(0, 55, 0, 18),
        Position = UDim2.new(1, -62, 0, 2),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = Config.Colors.Accent,
        Text = tostring(currentValue),
        ClearTextOnFocus = false,
        Parent = container,
    })
    
    local sliderBg = self:Create("Frame", {
        Size = UDim2.new(1, -16, 0, 8),
        Position = UDim2.new(0, 8, 0, 28),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Parent = container,
    })
    
    local sliderFill = self:Create("Frame", {
        Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Config.Colors.AccentDim,
        BorderSizePixel = 0,
        Parent = sliderBg,
    })
    
    local sliderKnob = self:Create("Frame", {
        Size = UDim2.new(0, 4, 1, 4),
        Position = UDim2.new((currentValue - min) / (max - min), -2, 0, -2),
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        Parent = sliderBg,
    })
    
    local dragging = false
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        -- Check if integer range
        if max - min >= 1 and max <= 1000 then
            value = math.floor(value * 10 + 0.5) / 10
        end
        currentValue = value
        local ratio = (value - min) / (max - min)
        Utilities:Tween(sliderFill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.1)
        Utilities:Tween(sliderKnob, {Position = UDim2.new(ratio, -2, 0, -2)}, 0.1)
        valueBox.Text = tostring(math.floor(value * 10 + 0.5) / 10)
        if callback then callback(value) end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local ratio = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            updateSlider(min + (max - min) * ratio)
        end
    end)
    
    Utilities:AddConnection(Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local ratio = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            updateSlider(min + (max - min) * ratio)
        end
    end))
    
    Utilities:AddConnection(Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    
    valueBox.FocusLost:Connect(function()
        local num = tonumber(valueBox.Text)
        if num then
            updateSlider(num)
        else
            valueBox.Text = tostring(currentValue)
        end
    end)
    
    return container, function() return currentValue end, updateSlider
end

function UI:MakeTerminalDropdown(labelText, parent, options, default, callback)
    local container = self:Create("Frame", {
        Size = UDim2.new(1, -10, 0, 26),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        ClipsDescendants = true,
        Parent = parent,
    })
    
    local selected = default or (options[1] or "None")
    local expanded = false
    
    local label = self:Create("TextLabel", {
        Size = UDim2.new(0.5, -5, 0, 26),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = labelText,
        Parent = container,
    })
    
    local selectBtn = self:Create("TextButton", {
        Size = UDim2.new(0.5, -10, 0, 22),
        Position = UDim2.new(0.5, 0, 0, 2),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = Config.Colors.Accent,
        Text = "[ " .. tostring(selected) .. " ]",
        Parent = container,
    })
    
    local optionContainer = self:Create("Frame", {
        Size = UDim2.new(0.5, -10, 0, #options * 22),
        Position = UDim2.new(0.5, 0, 0, 26),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Visible = false,
        ZIndex = 10,
        Parent = container,
    })
    
    local optLayout = Instance.new("UIListLayout")
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optLayout.Parent = optionContainer
    
    for i, opt in ipairs(options) do
        local optBtn = self:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BorderSizePixel = 0,
            Font = Config.Font,
            TextSize = Config.FontSizeSmall,
            TextColor3 = Config.Colors.TextDim,
            Text = "  " .. tostring(opt),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = optionContainer,
        })
        
        optBtn.MouseEnter:Connect(function()
            Utilities:Tween(optBtn, {BackgroundColor3 = Config.Colors.AccentDim, TextColor3 = Config.Colors.TextBright}, 0.1)
        end)
        optBtn.MouseLeave:Connect(function()
            Utilities:Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(15, 15, 15), TextColor3 = Config.Colors.TextDim}, 0.1)
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            selectBtn.Text = "[ " .. tostring(opt) .. " ]"
            expanded = false
            optionContainer.Visible = false
            Utilities:Tween(container, {Size = UDim2.new(1, -10, 0, 26)}, 0.15)
            if callback then callback(opt) end
        end)
    end
    
    selectBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionContainer.Visible = expanded
        local targetHeight = expanded and (26 + #options * 22 + 4) or 26
        Utilities:Tween(container, {Size = UDim2.new(1, -10, 0, targetHeight)}, 0.15)
    end)
    
    return container, function() return selected end
end

function UI:MakeSeparator(parent)
    local sep = self:Create("Frame", {
        Size = UDim2.new(1, -10, 0, 1),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = Config.Colors.Separator,
        BorderSizePixel = 0,
        Parent = parent,
    })
    return sep
end

function UI:MakeHeader(text, parent)
    local header = self:Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 22),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.Comment,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "// " .. text,
        Parent = parent,
    })
    return header
end

-- ============================================================
-- MODULE: Build Main GUI
-- ============================================================
function UI:BuildGUI()
    -- Cleanup old GUI
    local oldGui = Services.CoreGui:FindFirstChild("HoshiTerminal")
    if oldGui then oldGui:Destroy() end
    
    -- ScreenGui
    self.ScreenGui = self:Create("ScreenGui", {
        Name = "HoshiTerminal",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = Services.CoreGui,
    })
    Utilities:AddInstance(self.ScreenGui)
    
    -- Toggle Button (H icon)
    self:BuildToggleButton()
    
    -- Main Frame
    self:BuildMainFrame()
    
    -- Notification
    Notification:Init(self.ScreenGui)
    
    -- Splash Screen
    self:ShowSplashScreen()
end

function UI:BuildToggleButton()
    local toggleBtn = self:Create("TextButton", {
        Name = "HoshiToggle",
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 15, 0.5, -21),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 2,
        BorderColor3 = Config.Colors.Accent,
        Font = Config.FontBold,
        TextSize = 22,
        TextColor3 = Config.Colors.Accent,
        Text = "H",
        AutoButtonColor = false,
        ZIndex = 100,
        Parent = self.ScreenGui,
    })
    
    -- Draggable toggle button
    local toggleDragging = false
    local toggleDragStart, toggleStartPos
    
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleDragging = true
            toggleDragStart = input.Position
            toggleStartPos = toggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    toggleDragging = false
                end
            end)
        end
    end)
    
    toggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and toggleDragging then
            local delta = input.Position - toggleDragStart
            toggleBtn.Position = UDim2.new(
                toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
                toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Pulse animation
    local pulseUp = true
    task.spawn(function()
        while toggleBtn and toggleBtn.Parent do
            local targetColor = pulseUp and Config.Colors.Accent or Config.Colors.AccentDim
            Utilities:Tween(toggleBtn, {BorderColor3 = targetColor}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            pulseUp = not pulseUp
            task.wait(1.5)
        end
    end)
    
    local clickStart = 0
    toggleBtn.MouseButton1Down:Connect(function()
        clickStart = tick()
    end)
    
    toggleBtn.MouseButton1Up:Connect(function()
        local elapsed = tick() - clickStart
        -- Only toggle if it was a click, not a drag
        if elapsed < 0.3 then
            self:ToggleMainFrame()
        end
    end)
    
    toggleBtn.MouseEnter:Connect(function()
        Utilities:Tween(toggleBtn, {BackgroundColor3 = Config.Colors.AccentDim, TextColor3 = Config.Colors.TextBright}, 0.15)
    end)
    toggleBtn.MouseLeave:Connect(function()
        Utilities:Tween(toggleBtn, {BackgroundColor3 = Config.Colors.Background, TextColor3 = Config.Colors.Accent}, 0.15)
    end)
    
    self.ToggleButton = toggleBtn
end

function UI:BuildMainFrame()
    local defaultSize = Config.UI.DefaultSize
    
    -- Main container
    self.MainFrame = self:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, defaultSize.X, 0, defaultSize.Y),
        Position = UDim2.new(0.5, -defaultSize.X/2, 0.5, -defaultSize.Y/2),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.Accent,
        Visible = false,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    
    -- Title bar
    local titleBar = self:Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        BorderSizePixel = 0,
        Parent = self.MainFrame,
    })
    
    local titleBorder = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    
    local titleText = self:Create("TextLabel", {
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "HOSHI v" .. Config.Version .. " // ADMIN DEVELOPMENT TOOLS",
        Parent = titleBar,
    })
    
    -- Window controls
    local controlsFrame = self:Create("Frame", {
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(1, -150, 0, 0),
        BackgroundTransparency = 1,
        Parent = titleBar,
    })
    
    -- Status indicator
    local statusDot = self:Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 5, 0.5, -4),
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
        Parent = controlsFrame,
    })
    
    local statusLabel = self:Create("TextLabel", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = Config.Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "ACTIVE",
        Parent = controlsFrame,
    })
    self.StatusLabel = statusLabel
    self.StatusDot = statusDot
    
    -- Minimize button
    local minimizeBtn = self:Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 22),
        Position = UDim2.new(1, -62, 0, 5),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.TextDim,
        Text = "_",
        Parent = controlsFrame,
    })
    
    minimizeBtn.MouseButton1Click:Connect(function()
        self:MinimizeMainFrame()
    end)
    minimizeBtn.MouseEnter:Connect(function()
        Utilities:Tween(minimizeBtn, {BorderColor3 = Config.Colors.Warning, TextColor3 = Config.Colors.Warning}, 0.15)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        Utilities:Tween(minimizeBtn, {BorderColor3 = Config.Colors.BorderDim, TextColor3 = Config.Colors.TextDim}, 0.15)
    end)
    
    -- Close button
    local closeBtn = self:Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 22),
        Position = UDim2.new(1, -30, 0, 5),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.BorderDim,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.TextDim,
        Text = "X",
        Parent = controlsFrame,
    })
    
    closeBtn.MouseButton1Click:Connect(function()
        self:ToggleMainFrame()
    end)
    closeBtn.MouseEnter:Connect(function()
        Utilities:Tween(closeBtn, {BorderColor3 = Config.Colors.Error, TextColor3 = Config.Colors.Error}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utilities:Tween(closeBtn, {BorderColor3 = Config.Colors.BorderDim, TextColor3 = Config.Colors.TextDim}, 0.15)
    end)
    
    -- Draggable title bar
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Utilities:AddConnection(Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
    
    -- Resize handle
    local resizeHandle = self:Create("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -18, 1, -18),
        BackgroundColor3 = Config.Colors.AccentDim,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 50,
        Parent = self.MainFrame,
    })
    
    local resizeLabel = self:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = 10,
        TextColor3 = Config.Colors.Accent,
        Text = "//",
        ZIndex = 51,
        Parent = resizeHandle,
    })
    
    local resizing = false
    local resizeStart, resizeStartSize
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            resizeStartSize = self.MainFrame.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    Utilities:AddConnection(Services.UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newW = math.clamp(resizeStartSize.X + delta.X, Config.UI.MinSize.X, Config.UI.MaxSize.X)
            local newH = math.clamp(resizeStartSize.Y + delta.Y, Config.UI.MinSize.Y, Config.UI.MaxSize.Y)
            self.MainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end))
    
    -- Body container
    local body = self:Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -56),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = self.MainFrame,
    })
    
    -- Sidebar
    self.Sidebar = self:Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = Color3.fromRGB(8, 8, 8),
        BorderSizePixel = 0,
        Parent = body,
    })
    
    local sidebarBorder = self:Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Config.Colors.Separator,
        BorderSizePixel = 0,
        Parent = self.Sidebar,
    })
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 2)
    sidebarLayout.Parent = self.Sidebar
    
    -- Sidebar header
    self:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = Config.Colors.Comment,
        Text = "// MODULES",
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
        Parent = self.Sidebar,
    })
    local headerPad = Instance.new("UIPadding")
    headerPad.PaddingLeft = UDim.new(0, 8)
    headerPad.Parent = self.Sidebar:FindFirstChildOfClass("TextLabel")
    
    -- Content area
    self.ContentArea = self:Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = body,
    })
    
    -- Status bar at bottom
    local statusBar = self:Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        BorderSizePixel = 0,
        Parent = self.MainFrame,
    })
    
    local statusBarBorder = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Config.Colors.Separator,
        BorderSizePixel = 0,
        Parent = statusBar,
    })
    
    self.StatusBarText = self:Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = Config.Colors.Comment,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "> HOSHI ready // " .. LocalPlayer.Name .. " // " .. tostring(game.PlaceId),
        Parent = statusBar,
    })
    
    local fpsLabel = self:Create("TextLabel", {
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -105, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = Config.Colors.Comment,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = "FPS: --",
        Parent = statusBar,
    })
    self.FPSLabel = fpsLabel
    
    -- FPS counter
    local frameCount = 0
    local lastTime = tick()
    Utilities:AddConnection(Services.RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 1 then
            self.FPSLabel.Text = "FPS: " .. tostring(frameCount)
            frameCount = 0
            lastTime = tick()
        end
    end))
    
    -- Build tabs
    self:BuildTabs()
end

function UI:AddSidebarButton(name, order)
    local btn = self:Create("TextButton", {
        Size = UDim2.new(1, -4, 0, 28),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.TextDim,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        AutoButtonColor = false,
        Parent = self.Sidebar,
    })
    
    local indicator = self:Create("Frame", {
        Size = UDim2.new(0, 3, 1, -6),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = Config.Colors.AccentDim,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = btn,
    })
    
    local label = self:Create("TextLabel", {
        Size = UDim2.new(1, -15, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSize,
        TextColor3 = Config.Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "> " .. name,
        Parent = btn,
    })
    
    btn.MouseEnter:Connect(function()
        if Config.UI.CurrentTab ~= name then
            Utilities:Tween(btn, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, 0.15)
            Utilities:Tween(label, {TextColor3 = Config.Colors.Text}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if Config.UI.CurrentTab ~= name then
            Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.Background}, 0.15)
            Utilities:Tween(label, {TextColor3 = Config.Colors.TextDim}, 0.15)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    self.TabButtons[name] = {Button = btn, Label = label, Indicator = indicator}
    return btn
end

function UI:SwitchTab(name)
    Config.UI.CurrentTab = name
    
    -- Update sidebar buttons
    for tabName, data in pairs(self.TabButtons) do
        if tabName == name then
            Utilities:Tween(data.Button, {BackgroundColor3 = Config.Colors.AccentDim}, 0.2)
            Utilities:Tween(data.Label, {TextColor3 = Config.Colors.TextBright}, 0.2)
            Utilities:Tween(data.Indicator, {BackgroundTransparency = 0, BackgroundColor3 = Config.Colors.Accent}, 0.2)
        else
            Utilities:Tween(data.Button, {BackgroundColor3 = Config.Colors.Background}, 0.2)
            Utilities:Tween(data.Label, {TextColor3 = Config.Colors.TextDim}, 0.2)
            Utilities:Tween(data.Indicator, {BackgroundTransparency = 1}, 0.2)
        end
    end
    
    -- Update content
    for tabName, frame in pairs(self.Tabs) do
        if tabName == name then
            frame.Visible = true
            frame.BackgroundTransparency = 1
            -- Animate scroll children
            for _, child in pairs(frame:GetDescendants()) do
                if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
                    -- Skip
                end
            end
            Utilities:Tween(frame, {BackgroundTransparency = 0}, 0.001)
        else
            frame.Visible = false
        end
    end
    
    self.StatusBarText.Text = "> HOSHI // MODULE: " .. name .. " // " .. Utilities:FormatTime()
end

function UI:CreateTabContent(name)
    local scroll = self:Create("ScrollingFrame", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Background,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Colors.AccentDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.ContentArea,
    })
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = scroll
    
    self.Tabs[name] = scroll
    return scroll
end

function UI:BuildTabs()
    local tabOrder = {"ESP", "TELEPORT", "SPEED", "POV", "ONPOINT", "SYSTEM"}
    
    for i, name in ipairs(tabOrder) do
        self:AddSidebarButton(name, i)
        self:CreateTabContent(name)
    end
    
    -- Build each tab content
    self:BuildESPTab()
    self:BuildTeleportTab()
    self:BuildSpeedTab()
    self:BuildPOVTab()
    self:BuildOnPointTab()
    self:BuildSystemTab()
    
    -- Default tab
    self:SwitchTab("ESP")
end

-- ============================================================
-- TAB: ESP PLAYER
-- ============================================================
function UI:BuildESPTab()
    local tab = self.Tabs["ESP"]
    
    self:MakeHeader("ESP PLAYER MODULE", tab)
    self:MakeTerminalLine("> Displays all players with debug overlays", tab, Config.Colors.Comment)
    self:MakeSeparator(tab)
    
    self:MakeTerminalToggle("ESP Master Toggle", tab, Config.ESP.Enabled, function(state)
        Config.ESP.Enabled = state
        ESP:Toggle(state)
        Notification:Push("ESP " .. (state and "ENABLED" or "DISABLED"), state and "OK" or "WARN")
    end)
    
    self:MakeTerminalToggle("Box ESP", tab, Config.ESP.ShowBox, function(state)
        Config.ESP.ShowBox = state
    end)
    
    self:MakeTerminalToggle("Name ESP", tab, Config.ESP.ShowName, function(state)
        Config.ESP.ShowName = state
    end)
    
    self:MakeTerminalToggle("Distance", tab, Config.ESP.ShowDistance, function(state)
        Config.ESP.ShowDistance = state
    end)
    
    self:MakeTerminalToggle("Health Bar", tab, Config.ESP.ShowHealth, function(state)
        Config.ESP.ShowHealth = state
    end)
    
    self:MakeTerminalToggle("Role Tag", tab, Config.ESP.ShowRole, function(state)
        Config.ESP.ShowRole = state
    end)
    
    self:MakeSeparator(tab)
    self:MakeTerminalLine("> Role colors: KILLER=RED | SURVIVOR=CYAN | UNKNOWN=GRAY", tab, Config.Colors.Comment)
end

-- ============================================================
-- TAB: TELEPORT SAFETY
-- ============================================================
function UI:BuildTeleportTab()
    local tab = self.Tabs["TELEPORT"]
    
    self:MakeHeader("TELEPORT SAFETY MODULE", tab)
    self:MakeTerminalLine("> Auto-teleport when Killer approaches within radius", tab, Config.Colors.Comment)
    self:MakeSeparator(tab)
    
    self:MakeTerminalToggle("Teleport Safety", tab, Config.Teleport.Enabled, function(state)
        Config.Teleport.Enabled = state
        Notification:Push("Teleport Safety " .. (state and "ARMED" or "DISARMED"), state and "OK" or "WARN")
    end)
    
    self:MakeSeparator(tab)
    
    self:MakeTerminalSlider("Detection Radius (studs)", tab, 10, 100, Config.Teleport.Radius, function(val)
        Config.Teleport.Radius = math.floor(val)
    end)
    
    self:MakeTerminalSlider("Teleport Distance (studs)", tab, 50, 200, Config.Teleport.TeleportDistance, function(val)
        Config.Teleport.TeleportDistance = math.floor(val)
    end)
    
    self:MakeTerminalSlider("Cooldown (seconds)", tab, 1, 15, Config.Teleport.Cooldown, function(val)
        Config.Teleport.Cooldown = math.floor(val)
    end)
    
    self:MakeSeparator(tab)
    
    -- Status display
    self.TeleportStatus = self:MakeTerminalLine("> STATUS: STANDBY | COOLDOWN: READY", tab, Config.Colors.TextDim)
end

-- ============================================================
-- TAB: SPEED RUN
-- ============================================================
function UI:BuildSpeedTab()
    local tab = self.Tabs["SPEED"]
    
    self:MakeHeader("SPEED RUN MODULE", tab)
    self:MakeTerminalLine("> Adjust character walk speed multiplier", tab, Config.Colors.Comment)
    self:MakeSeparator(tab)
    
    self:MakeTerminalSlider("Speed Multiplier", tab, 1, 10, Config.Speed.Value, function(val)
        Config.Speed.Value = val
        SpeedModule:Apply(val)
    end)
    
    self:MakeSeparator(tab)
    
    self:MakeTerminalButton("> [RESET SPEED TO DEFAULT]", tab, function()
        Config.Speed.Value = 1
        SpeedModule:Apply(1)
        Notification:Push("Speed reset to default", "OK")
    end)
    
    self:MakeSeparator(tab)
    self.SpeedStatus = self:MakeTerminalLine("> CURRENT: 16 studs/s (1.0x)", tab, Config.Colors.TextDim)
end

-- ============================================================
-- TAB: POV CIRCLE
-- ============================================================
function UI:BuildPOVTab()
    local tab = self.Tabs["POV"]
    
    self:MakeHeader("POV CIRCLE MODULE", tab)
    self:MakeTerminalLine("> Crosshair circle + camera follow for observation", tab, Config.Colors.Comment)
    self:MakeSeparator(tab)
    
    self:MakeTerminalToggle("POV Circle", tab, Config.POV.Enabled, function(state)
        Config.POV.Enabled = state
        POVModule:Toggle(state)
        Notification:Push("POV Circle " .. (state and "ENABLED" or "DISABLED"), state and "OK" or "WARN")
    end)
    
    self:MakeTerminalToggle("Follow Target Camera", tab, Config.POV.Following, function(state)
        Config.POV.Following = state
        Notification:Push("Camera Follow " .. (state and "ON" or "OFF"), "INFO")
    end)
    
    self:MakeSeparator(tab)
    
    self:MakeTerminalSlider("Circle Radius", tab, 20, 300, Config.POV.Radius, function(val)
        Config.POV.Radius = math.floor(val)
        POVModule:UpdateCircle()
    end)
    
    self:MakeTerminalSlider("Thickness", tab, 1, 8, Config.POV.Thickness, function(val)
        Config.POV.Thickness = math.floor(val)
        POVModule:UpdateCircle()
    end)
    
    self:MakeTerminalSlider("Opacity", tab, 0.1, 1, Config.POV.Opacity, function(val)
        Config.POV.Opacity = val
        POVModule:UpdateCircle()
    end)
    
    self:MakeSeparator(tab)
    
    -- Target player selection
    self:MakeTerminalLine("> Select target player for observation:", tab, Config.Colors.Comment)
    
    self.POVTargetContainer = self:Create("Frame", {
        Size = UDim2.new(1, -10, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab,
    })
    local targetLayout = Instance.new("UIListLayout")
    targetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    targetLayout.Padding = UDim.new(0, 2)
    targetLayout.Parent = self.POVTargetContainer
    
    self:MakeTerminalButton("> [REFRESH PLAYER LIST]", tab, function()
        self:RefreshPOVTargets()
    end)
    
    self:RefreshPOVTargets()
end

function UI:RefreshPOVTargets()
    if not self.POVTargetContainer then return end
    for _, child in pairs(self.POVTargetContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = Utilities:GetRole(player)
            local roleColor = Utilities:GetRoleColor(role)
            local btn = self:MakeTerminalButton("    > " .. player.Name .. " [" .. role .. "]", self.POVTargetContainer, function()
                Config.POV.TargetPlayer = player
                Notification:Push("Target set: " .. player.Name, "OK")
            end)
            btn.TextColor3 = roleColor
        end
    end
end

-- ============================================================
-- TAB: ON POINT
-- ============================================================
function UI:BuildOnPointTab()
    local tab = self.Tabs["ONPOINT"]
    
    self:MakeHeader("ON POINT MODULE", tab)
    self:MakeTerminalLine("> Debug indicator when target is in POV circle", tab, Config.Colors.Comment)
    self:MakeTerminalLine("> Shows hitbox/collision/damage area overlay", tab, Config.Colors.Comment)
    self:MakeSeparator(tab)
    
    self:MakeTerminalToggle("On Point Indicator", tab, Config.OnPoint.Enabled, function(state)
        Config.OnPoint.Enabled = state
        OnPointModule:Toggle(state)
        Notification:Push("On Point " .. (state and "ENABLED" or "DISABLED"), state and "OK" or "WARN")
    end)
    
    self:MakeTerminalToggle("Smooth Update", tab, Config.OnPoint.SmoothUpdate, function(state)
        Config.OnPoint.SmoothUpdate = state
    end)
    
    self:MakeSeparator(tab)
    
    self:MakeTerminalSlider("Indicator Radius", tab, 10, 200, Config.OnPoint.Radius, function(val)
        Config.OnPoint.Radius = math.floor(val)
    end)
    
    self:MakeTerminalSlider("Transparency", tab, 0, 1, Config.OnPoint.Transparency, function(val)
        Config.OnPoint.Transparency = val
    end)
    
    self:MakeSeparator(tab)
    self.OnPointStatus = self:MakeTerminalLine("> STATUS: WAITING FOR TARGET", tab, Config.Colors.TextDim)
end

-- ============================================================
-- TAB: SYSTEM
-- ============================================================
function UI:BuildSystemTab()
    local tab = self.Tabs["SYSTEM"]
    
    self:MakeHeader("SYSTEM INFORMATION", tab)
    self:MakeSeparator(tab)
    
    self:MakeTerminalLine("> HOSHI Admin Development Tools v" .. Config.Version, tab, Config.Colors.Accent)
    self:MakeTerminalLine("> Build: " .. Config.Build, tab, Config.Colors.TextDim)
    self:MakeTerminalLine("> Player: " .. LocalPlayer.Name, tab, Config.Colors.TextDim)
    self:MakeTerminalLine("> UserID: " .. tostring(LocalPlayer.UserId), tab, Config.Colors.TextDim)
    self:MakeTerminalLine("> PlaceID: " .. tostring(game.PlaceId), tab, Config.Colors.TextDim)
    self:MakeTerminalLine("> GameID: " .. tostring(game.GameId), tab, Config.Colors.TextDim)
    
    self:MakeSeparator(tab)
    self:MakeHeader("ACTIONS", tab)
    
    self:MakeTerminalButton("> [CLEANUP ALL FEATURES]", tab, function()
        Config.ESP.Enabled = false
        Config.Teleport.Enabled = false
        Config.POV.Enabled = false
        Config.OnPoint.Enabled = false
        Config.Speed.Value = 1
        ESP:Toggle(false)
        POVModule:Toggle(false)
        OnPointModule:Toggle(false)
        SpeedModule:Apply(1)
        Notification:Push("All features disabled and cleaned up", "OK")
    end)
    
    self:MakeTerminalButton("> [DESTROY HOSHI]", tab, function()
        Notification:Push("Shutting down HOSHI...", "WARN")
        task.wait(1)
        Utilities:CleanupAll()
        if UI.ScreenGui then
            UI.ScreenGui:Destroy()
        end
    end)
    
    self:MakeSeparator(tab)
    self:MakeHeader("LOG OUTPUT", tab)
    
    self.LogContainer = self:Create("Frame", {
        Size = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        BorderSizePixel = 1,
        BorderColor3 = Config.Colors.Separator,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab,
    })
    
    local logLayout = Instance.new("UIListLayout")
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.Padding = UDim.new(0, 1)
    logLayout.Parent = self.LogContainer
    
    self:AddLog("HOSHI initialized successfully")
    self:AddLog("All modules loaded")
    self:AddLog("Awaiting commands...")
end

function UI:AddLog(message)
    if not self.LogContainer then return end
    local line = self:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Config.Font,
        TextSize = Config.FontSizeSmall,
        TextColor3 = Config.Colors.Comment,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "  [" .. Utilities:FormatTime() .. "] " .. message,
        Parent = self.LogContainer,
    })
    
    -- Keep log manageable
    local children = self.LogContainer:GetChildren()
    local textLabels = {}
    for _, c in pairs(children) do
        if c:IsA("TextLabel") then table.insert(textLabels, c) end
    end
    if #textLabels > 50 then
        textLabels[1]:Destroy()
    end
end

function UI:ToggleMainFrame()
    self.IsVisible = not self.IsVisible
    
    if self.IsVisible then
        self.MainFrame.Visible = true
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        local defaultSize = Config.UI.DefaultSize
        self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Utilities:Tween(self.MainFrame, {
            Size = UDim2.new(0, defaultSize.X, 0, defaultSize.Y),
            Position = UDim2.new(0.5, -defaultSize.X/2, 0.5, -defaultSize.Y/2),
        }, 0.35, Enum.EasingStyle.Back)
    else
        Utilities:Tween(self.MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.25, function()
            if not self.IsVisible then
                self.MainFrame.Visible = false
            end
        end)
    end
end

function UI:MinimizeMainFrame()
    Config.UI.Minimized = not Config.UI.Minimized
    
    if Config.UI.Minimized then
        Utilities:Tween(self.MainFrame, {
            Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X, 0, 32),
        }, 0.25)
    else
        local defaultSize = Config.UI.DefaultSize
        Utilities:Tween(self.MainFrame, {
            Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X, 0, defaultSize.Y),
        }, 0.25)
    end
end

function UI:ShowSplashScreen()
    local splash = self:Create("Frame", {
        Name = "Splash",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Config.Colors.Black,
        BackgroundTransparency = 0,
        ZIndex = 200,
        Parent = self.ScreenGui,
    })
    
    local splashLines = {
        {text = "", color = Config.Colors.Accent, delay = 0},
        {text = "  ##   ##   #####    ######  ##   ##  ##", color = Config.Colors.Accent, delay = 0.05},
        {text = "  ##   ##  ##   ##  ##       ##   ##  ##", color = Config.Colors.Accent, delay = 0.1},
        {text = "  #######  ##   ##   #####   #######  ##", color = Config.Colors.Accent, delay = 0.15},
        {text = "  ##   ##  ##   ##       ##  ##   ##  ##", color = Config.Colors.Accent, delay = 0.2},
        {text = "  ##   ##   #####   ######   ##   ##  ##", color = Config.Colors.Accent, delay = 0.25},
        {text = "", color = Config.Colors.Accent, delay = 0.3},
        {text = "  ADMIN DEVELOPMENT TOOLS v" .. Config.Version, color = Config.Colors.TextDim, delay = 0.4},
        {text = "  ==========================================", color = Config.Colors.Separator, delay = 0.45},
        {text = "", color = Config.Colors.Accent, delay = 0.5},
        {text = "  > Initializing core modules...", color = Config.Colors.Comment, delay = 0.6},
        {text = "  > Loading ESP module............... [OK]", color = Config.Colors.Accent, delay = 0.8},
        {text = "  > Loading Teleport module.......... [OK]", color = Config.Colors.Accent, delay = 1.0},
        {text = "  > Loading Speed module............. [OK]", color = Config.Colors.Accent, delay = 1.2},
        {text = "  > Loading POV module............... [OK]", color = Config.Colors.Accent, delay = 1.4},
        {text = "  > Loading OnPoint module........... [OK]", color = Config.Colors.Accent, delay = 1.6},
        {text = "  > System check complete.", color = Config.Colors.TextBright, delay = 1.8},
        {text = "", color = Config.Colors.Accent, delay = 1.9},
        {text = "  > Press [H] button to open terminal.", color = Config.Colors.Warning, delay = 2.1},
    }
    
    local container = self:Create("Frame", {
        Size = UDim2.new(0, 500, 0, #splashLines * 18 + 20),
        Position = UDim2.new(0.5, -250, 0.5, -(#splashLines * 18 + 20)/2),
        BackgroundTransparency = 1,
        ZIndex = 201,
        Parent = splash,
    })
    
    for i, lineData in ipairs(splashLines) do
        task.delay(lineData.delay, function()
            if not splash or not splash.Parent then return end
            local lbl = self:Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 0, 0, (i-1) * 18),
                BackgroundTransparency = 1,
                Font = Config.Font,
                TextSize = Config.FontSize,
                TextColor3 = lineData.color,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = lineData.text,
                TextTransparency = 1,
                ZIndex = 202,
                Parent = container,
            })
            Utilities:Tween(lbl, {TextTransparency = 0}, 0.3)
        end)
    end
    
    -- Fade out splash
    task.delay(3.5, function()
        if splash and splash.Parent then
            Utilities:Tween(splash, {BackgroundTransparency = 1}, 0.8)
            for _, desc in pairs(splash:GetDescendants()) do
                if desc:IsA("TextLabel") then
                    Utilities:Tween(desc, {TextTransparency = 1}, 0.6)
                end
            end
            task.wait(1)
            pcall(function() splash:Destroy() end)
        end
    end)
end

-- ============================================================
-- MODULE: ESP
-- ============================================================
ESP = {}
ESP.Objects = {}
ESP.Running = false

function ESP:Toggle(state)
    if state then
        self:Start()
    else
        self:Stop()
    end
end

function ESP:Start()
    if self.Running then return end
    self.Running = true
    
    -- Create ESP for existing players
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateESP(player)
        end
    end
    
    -- Listen for new players
    Utilities:AddConnection(Services.Players.PlayerAdded:Connect(function(player)
        if Config.ESP.Enabled and player ~= LocalPlayer then
            self:CreateESP(player)
        end
    end))
    
    Utilities:AddConnection(Services.Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end))
end

function ESP:Stop()
    self.Running = false
    for player, data in pairs(self.Objects) do
        self:DestroyESPData(data)
    end
    self.Objects = {}
end

function ESP:CreateESP(player)
    if self.Objects[player] then return end
    
    local data = {}
    
    -- Billboard for name/distance/role/health
    data.Billboard = Instance.new("BillboardGui")
    data.Billboard.Name = "HoshiESP_" .. player.Name
    data.Billboard.AlwaysOnTop = true
    data.Billboard.Size = UDim2.new(0, 200, 0, 80)
    data.Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    data.Billboard.LightInfluence = 0
    
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, 0, 1, 0)
    infoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoFrame.BackgroundTransparency = 0.6
    infoFrame.BorderSizePixel = 1
    infoFrame.BorderColor3 = Config.Colors.Accent
    infoFrame.Parent = data.Billboard
    
    local infoLayout = Instance.new("UIListLayout")
    infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    infoLayout.Parent = infoFrame
    
    data.NameLabel = Instance.new("TextLabel")
    data.NameLabel.Size = UDim2.new(1, 0, 0, 16)
    data.NameLabel.BackgroundTransparency = 1
    data.NameLabel.Font = Config.Font
    data.NameLabel.TextSize = 14
    data.NameLabel.TextColor3 = Config.Colors.Text
    data.NameLabel.Text = player.Name
    data.NameLabel.LayoutOrder = 1
    data.NameLabel.Parent = infoFrame
    
    data.RoleLabel = Instance.new("TextLabel")
    data.RoleLabel.Size = UDim2.new(1, 0, 0, 14)
    data.RoleLabel.BackgroundTransparency = 1
    data.RoleLabel.Font = Config.Font
    data.RoleLabel.TextSize = 12
    data.RoleLabel.TextColor3 = Config.Colors.TextDim
    data.RoleLabel.Text = "[UNKNOWN]"
    data.RoleLabel.LayoutOrder = 2
    data.RoleLabel.Parent = infoFrame
    
    data.DistLabel = Instance.new("TextLabel")
    data.DistLabel.Size = UDim2.new(1, 0, 0, 14)
    data.DistLabel.BackgroundTransparency = 1
    data.DistLabel.Font = Config.Font
    data.DistLabel.TextSize = 12
    data.DistLabel.TextColor3 = Config.Colors.TextDim
    data.DistLabel.Text = "0 studs"
    data.DistLabel.LayoutOrder = 3
    data.DistLabel.Parent = infoFrame
    
    data.HealthLabel = Instance.new("TextLabel")
    data.HealthLabel.Size = UDim2.new(1, 0, 0, 14)
    data.HealthLabel.BackgroundTransparency = 1
    data.HealthLabel.Font = Config.Font
    data.HealthLabel.TextSize = 12
    data.HealthLabel.TextColor3 = Config.Colors.Accent
    data.HealthLabel.Text = "HP: 100/100"
    data.HealthLabel.LayoutOrder = 4
    data.HealthLabel.Parent = infoFrame
    
    -- Box ESP using Highlight
    data.Highlight = Instance.new("Highlight")
    data.Highlight.Name = "HoshiHL_" .. player.Name
    data.Highlight.FillTransparency = 0.8
    data.Highlight.OutlineTransparency = 0.3
    data.Highlight.OutlineColor3 = Config.Colors.Accent
    data.Highlight.FillColor3 = Config.Colors.AccentDim
    
    -- Store and connect
    self.Objects[player] = data
    
    -- Attach when character exists
    local function attachToCharacter(char)
        if not char then return end
        task.wait(0.5) -- Wait for character to load
        if data.Billboard then
            data.Billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            data.Billboard.Parent = Services.CoreGui
        end
        if data.Highlight and Config.ESP.ShowBox then
            data.Highlight.Adornee = char
            data.Highlight.Parent = Services.CoreGui
        end
    end
    
    if player.Character then
        attachToCharacter(player.Character)
    end
    
    Utilities:AddConnection(player.CharacterAdded:Connect(function(char)
        attachToCharacter(char)
    end))
end

function ESP:RemoveESP(player)
    local data = self.Objects[player]
    if data then
        self:DestroyESPData(data)
        self.Objects[player] = nil
    end
end

function ESP:DestroyESPData(data)
    pcall(function()
        if data.Billboard then data.Billboard:Destroy() end
        if data.Highlight then data.Highlight:Destroy() end
    end)
end

function ESP:Update()
    if not Config.ESP.Enabled then return end
    
    for player, data in pairs(self.Objects) do
        if not player or not player.Parent then
            self:DestroyESPData(data)
            self.Objects[player] = nil
            continue
        end
        
        local char = Utilities:GetCharacter(player)
        if not char then
            if data.Billboard then data.Billboard.Enabled = false end
            if data.Highlight then data.Highlight.Enabled = false end
            continue
        end
        
        -- Update billboard adornee
        if data.Billboard then
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head then
                data.Billboard.Adornee = head
                if not data.Billboard.Parent then
                    data.Billboard.Parent = Services.CoreGui
                end
            end
            data.Billboard.Enabled = true
        end
        
        -- Update highlight
        if data.Highlight then
            data.Highlight.Adornee = char
            if not data.Highlight.Parent then
                data.Highlight.Parent = Services.CoreGui
            end
            data.Highlight.Enabled = Config.ESP.ShowBox
        end
        
        -- Role
        local role = Utilities:GetRole(player)
        local roleColor = Utilities:GetRoleColor(role)
        
        -- Update labels
        if data.NameLabel then
            data.NameLabel.Visible = Config.ESP.ShowName
            data.NameLabel.Text = player.Name
            data.NameLabel.TextColor3 = roleColor
        end
        
        if data.RoleLabel then
            data.RoleLabel.Visible = Config.ESP.ShowRole
            data.RoleLabel.Text = "[" .. role .. "]"
            data.RoleLabel.TextColor3 = roleColor
        end
        
        if data.DistLabel then
            data.DistLabel.Visible = Config.ESP.ShowDistance
            local dist = Utilities:GetDistance(player)
            data.DistLabel.Text = math.floor(dist) .. " studs"
        end
        
        if data.HealthLabel then
            data.HealthLabel.Visible = Config.ESP.ShowHealth
            local hp, maxHp = Utilities:GetHealth(player)
            data.HealthLabel.Text = "HP: " .. math.floor(hp) .. "/" .. math.floor(maxHp)
            -- Color health based on percentage
            local pct = hp / maxHp
            if pct > 0.6 then
                data.HealthLabel.TextColor3 = Config.Colors.Accent
            elseif pct > 0.3 then
                data.HealthLabel.TextColor3 = Config.Colors.Warning
            else
                data.HealthLabel.TextColor3 = Config.Colors.Error
            end
        end
        
        -- Update highlight color based on role
        if data.Highlight then
            data.Highlight.OutlineColor3 = roleColor
            data.Highlight.FillColor3 = roleColor
        end
    end
end

-- ============================================================
-- MODULE: Teleport Safety
-- ============================================================
TeleportModule = {}

function TeleportModule:FindKillers()
    local killers = {}
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = Utilities:GetRole(player)
            if role == "Killer" then
                table.insert(killers, player)
            end
        end
    end
    return killers
end

function TeleportModule:FindSafePosition(killerPos, myPos)
    -- Calculate direction away from killer
    local direction = (myPos - killerPos).Unit
    local teleportDist = Config.Teleport.TeleportDistance
    
    -- Try multiple directions if direct path is blocked
    local attempts = {
        direction,
        (direction + Vector3.new(1, 0, 0)).Unit,
        (direction + Vector3.new(-1, 0, 0)).Unit,
        (direction + Vector3.new(0, 0, 1)).Unit,
        (direction + Vector3.new(0, 0, -1)).Unit,
        Vector3.new(math.random() * 2 - 1, 0, math.random() * 2 - 1).Unit,
    }
    
    for _, dir in ipairs(attempts) do
        local targetPos = myPos + dir * teleportDist
        targetPos = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
        
        -- Raycast down to find ground
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local char = Utilities:GetCharacter(LocalPlayer)
        if char then
            rayParams.FilterDescendantsInstances = {char}
        end
        
        local ray = workspace:Raycast(targetPos + Vector3.new(0, 50, 0), Vector3.new(0, -200, 0), rayParams)
        if ray then
            targetPos = ray.Position + Vector3.new(0, 3, 0)
        end
        
        -- Verify this position is far from ALL killers
        local isSafe = true
        for _, killer in ipairs(self:FindKillers()) do
            local killerRoot = Utilities:GetRootPart(killer)
            if killerRoot then
                if (targetPos - killerRoot.Position).Magnitude < Config.Teleport.Radius * 1.5 then
                    isSafe = false
                    break
                end
            end
        end
        
        if isSafe then
            return targetPos
        end
    end
    
    -- Fallback: random far position
    local angle = math.random() * math.pi * 2
    local fallback = myPos + Vector3.new(math.cos(angle), 0, math.sin(angle)) * teleportDist
    return Vector3.new(fallback.X, myPos.Y + 3, fallback.Z)
end

function TeleportModule:Check()
    if not Config.Teleport.Enabled then return end
    
    local now = tick()
    if now - Config.Teleport.LastTeleport < Config.Teleport.Cooldown then
        return
    end
    
    local myRoot = Utilities:GetRootPart(LocalPlayer)
    if not myRoot then return end
    
    local killers = self:FindKillers()
    
    for _, killer in ipairs(killers) do
        local killerRoot = Utilities:GetRootPart(killer)
        if killerRoot then
            local distance = (myRoot.Position - killerRoot.Position).Magnitude
            
            if distance <= Config.Teleport.Radius then
                -- Teleport away
                local safePos = self:FindSafePosition(killerRoot.Position, myRoot.Position)
                myRoot.CFrame = CFrame.new(safePos)
                Config.Teleport.LastTeleport = now
                
                Notification:Push("TELEPORTED -- Killer [" .. killer.Name .. "] was " .. math.floor(distance) .. " studs away", "WARN")
                UI:AddLog("Teleport triggered: " .. killer.Name .. " at " .. math.floor(distance) .. " studs")
                
                -- Update status
                if UI.TeleportStatus then
                    UI.TeleportStatus.Text = "> STATUS: TELEPORTED | LAST: " .. Utilities:FormatTime() .. " | COOLDOWN: " .. Config.Teleport.Cooldown .. "s"
                    UI.TeleportStatus.TextColor3 = Config.Colors.Warning
                end
                
                break
            end
        end
    end
end

-- ============================================================
-- MODULE: Speed
-- ============================================================
SpeedModule = {}

function SpeedModule:Apply(multiplier)
    local humanoid = Utilities:GetHumanoid(LocalPlayer)
    if humanoid then
        local newSpeed = Config.Speed.DefaultWalkSpeed * multiplier
        humanoid.WalkSpeed = newSpeed
        if UI.SpeedStatus then
            UI.SpeedStatus.Text = "> CURRENT: " .. math.floor(newSpeed) .. " studs/s (" .. multiplier .. "x)"
        end
    end
end

-- ============================================================
-- MODULE: POV Circle
-- ============================================================
POVModule = {}
POVModule.Circle = nil
POVModule.Segments = {}

function POVModule:Toggle(state)
    if state then
        self:CreateCircle()
    else
        self:DestroyCircle()
    end
end

function POVModule:CreateCircle()
    self:DestroyCircle()
    
    -- Create circle using Drawing API if available, otherwise use Frame
    if Drawing then
        self.Circle = Drawing.new("Circle")
        self.Circle.Color = Config.POV.Color
        self.Circle.Thickness = Config.POV.Thickness
        self.Circle.Radius = Config.POV.Radius
        self.Circle.Filled = false
        self.Circle.Transparency = Config.POV.Opacity
        self.Circle.Visible = true
        self.Circle.NumSides = 64
        
        -- Position at center of screen
        local viewport = Services.Camera.ViewportSize
        self.Circle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
    else
        -- Fallback: create circle using GUI frames
        self:CreateGUICircle()
    end
end

function POVModule:CreateGUICircle()
    self:DestroyCircle()
    
    local circleFrame = Instance.new("Frame")
    circleFrame.Name = "HoshiPOVCircle"
    circleFrame.Size = UDim2.new(0, Config.POV.Radius * 2, 0, Config.POV.Radius * 2)
    circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    circleFrame.BackgroundTransparency = 1
    circleFrame.Parent = UI.ScreenGui
    
    -- Create circle segments
    local numSegments = 64
    for i = 1, numSegments do
        local angle = (i / numSegments) * math.pi * 2
        local nextAngle = ((i + 1) / numSegments) * math.pi * 2
        
        local x1 = math.cos(angle) * Config.POV.Radius
        local y1 = math.sin(angle) * Config.POV.Radius
        local x2 = math.cos(nextAngle) * Config.POV.Radius
        local y2 = math.sin(nextAngle) * Config.POV.Radius
        
        local dx = x2 - x1
        local dy = y2 - y1
        local length = math.sqrt(dx*dx + dy*dy)
        local rot = math.atan2(dy, dx)
        
        local seg = Instance.new("Frame")
        seg.Size = UDim2.new(0, length + 1, 0, Config.POV.Thickness)
        seg.Position = UDim2.new(0.5, x1, 0.5, y1)
        seg.Rotation = math.deg(rot)
        seg.AnchorPoint = Vector2.new(0, 0.5)
        seg.BackgroundColor3 = Config.POV.Color
        seg.BackgroundTransparency = 1 - Config.POV.Opacity
        seg.BorderSizePixel = 0
        seg.Parent = circleFrame
        
        table.insert(self.Segments, seg)
    end
    
    self.CircleFrame = circleFrame
    Utilities:AddInstance(circleFrame)
end

function POVModule:UpdateCircle()
    if Drawing and self.Circle then
        self.Circle.Radius = Config.POV.Radius
        self.Circle.Thickness = Config.POV.Thickness
        self.Circle.Transparency = Config.POV.Opacity
        self.Circle.Color = Config.POV.Color
        local viewport = Services.Camera.ViewportSize
        self.Circle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
    elseif self.CircleFrame then
        -- Rebuild GUI circle
        self:CreateGUICircle()
    end
end

function POVModule:DestroyCircle()
    if self.Circle then
        pcall(function() self.Circle:Remove() end)
        self.Circle = nil
    end
    if self.CircleFrame then
        pcall(function() self.CircleFrame:Destroy() end)
        self.CircleFrame = nil
    end
    self.Segments = {}
end

function POVModule:UpdateCameraFollow()
    if not Config.POV.Following or not Config.POV.TargetPlayer then return end
    
    local target = Config.POV.TargetPlayer
    if not target or not target.Parent then
        Config.POV.TargetPlayer = nil
        return
    end
    
    local targetRoot = Utilities:GetRootPart(target)
    if not targetRoot then return end
    
    -- Make camera look at target smoothly
    local camera = Services.Camera
    local myRoot = Utilities:GetRootPart(LocalPlayer)
    if not myRoot then return end
    
    local targetPos = targetRoot.Position
    local camPos = camera.CFrame.Position
    local lookAt = CFrame.lookAt(camPos, targetPos)
    
    -- Smooth interpolation
    camera.CFrame = camera.CFrame:Lerp(lookAt, 0.1)
end

function POVModule:IsTargetInCircle()
    if not Config.POV.TargetPlayer then return false end
    
    local target = Config.POV.TargetPlayer
    local targetRoot = Utilities:GetRootPart(target)
    if not targetRoot then return false end
    
    local screenPos, onScreen = Utilities:WorldToScreen(targetRoot.Position)
    if not onScreen then return false end
    
    local viewport = Services.Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local distFromCenter = (screenPos - center).Magnitude
    
    return distFromCenter <= Config.POV.Radius
end

-- ============================================================
-- MODULE: On Point
-- ============================================================
OnPointModule = {}
OnPointModule.Indicator = nil
OnPointModule.BillboardIndicator = nil

function OnPointModule:Toggle(state)
    if not state then
        self:DestroyIndicator()
    end
end

function OnPointModule:DestroyIndicator()
    if self.Indicator then
        pcall(function() self.Indicator:Remove() end)
        self.Indicator = nil
    end
    if self.BillboardIndicator then
        pcall(function() self.BillboardIndicator:Destroy() end)
        self.BillboardIndicator = nil
    end
    if self.ScreenIndicator then
        pcall(function() self.ScreenIndicator:Destroy() end)
        self.ScreenIndicator = nil
    end
end

function OnPointModule:CreateScreenIndicator()
    if self.ScreenIndicator then return end
    
    self.ScreenIndicator = Instance.new("Frame")
    self.ScreenIndicator.Name = "OnPointIndicator"
    self.ScreenIndicator.Size = UDim2.new(0, 0, 0, 0)
    self.ScreenIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ScreenIndicator.BackgroundTransparency = 1
    self.ScreenIndicator.Parent = UI.ScreenGui
    
    -- Crosshair lines
    local function makeLine(size, pos, color)
        local line = Instance.new("Frame")
        line.Size = size
        line.Position = pos
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = color or Config.OnPoint.Color
        line.BackgroundTransparency = Config.OnPoint.Transparency
        line.BorderSizePixel = 0
        line.Parent = self.ScreenIndicator
        return line
    end
    
    -- Horizontal line
    self.OnPointH = makeLine(
        UDim2.new(0, Config.OnPoint.Radius, 0, 2),
        UDim2.new(0.5, 0, 0.5, 0),
        Config.OnPoint.Color
    )
    
    -- Vertical line
    self.OnPointV = makeLine(
        UDim2.new(0, 2, 0, Config.OnPoint.Radius),
        UDim2.new(0.5, 0, 0.5, 0),
        Config.OnPoint.Color
    )
    
    -- Diamond corners
    for i = 1, 4 do
        local angle = (i - 1) * 90
        local rad = math.rad(angle)
        local dist = Config.OnPoint.Radius * 0.3
        local corner = Instance.new("Frame")
        corner.Size = UDim2.new(0, 8, 0, 8)
        corner.AnchorPoint = Vector2.new(0.5, 0.5)
        corner.Position = UDim2.new(0.5, math.cos(rad) * dist, 0.5, math.sin(rad) * dist)
        corner.Rotation = 45
        corner.BackgroundColor3 = Config.OnPoint.Color
        corner.BackgroundTransparency = Config.OnPoint.Transparency
        corner.BorderSizePixel = 0
        corner.Parent = self.ScreenIndicator
    end
    
    -- Info label
    self.OnPointLabel = Instance.new("TextLabel")
    self.OnPointLabel.Size = UDim2.new(0, 200, 0, 20)
    self.OnPointLabel.Position = UDim2.new(0.5, 0, 1, 10)
    self.OnPointLabel.AnchorPoint = Vector2.new(0.5, 0)
    self.OnPointLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.OnPointLabel.BackgroundTransparency = 0.5
    self.OnPointLabel.BorderSizePixel = 1
    self.OnPointLabel.BorderColor3 = Config.OnPoint.Color
    self.OnPointLabel.Font = Config.Font
    self.OnPointLabel.TextSize = Config.FontSizeSmall
    self.OnPointLabel.TextColor3 = Config.OnPoint.Color
    self.OnPointLabel.Text = "ON POINT"
    self.OnPointLabel.Parent = self.ScreenIndicator
    
    Utilities:AddInstance(self.ScreenIndicator)
end

function OnPointModule:Update()
    if not Config.OnPoint.Enabled then
        if self.ScreenIndicator then
            self.ScreenIndicator.Visible = false
        end
        return
    end
    
    if not Config.POV.TargetPlayer then
        if self.ScreenIndicator then
            self.ScreenIndicator.Visible = false
        end
        if UI.OnPointStatus then
            UI.OnPointStatus.Text = "> STATUS: NO TARGET SELECTED"
            UI.OnPointStatus.TextColor3 = Config.Colors.Comment
        end
        return
    end
    
    local target = Config.POV.TargetPlayer
    if not target or not target.Parent then
        Config.POV.TargetPlayer = nil
        return
    end
    
    local targetRoot = Utilities:GetRootPart(target)
    if not targetRoot then return end
    
    local screenPos, onScreen = Utilities:WorldToScreen(targetRoot.Position)
    
    if not onScreen then
        if self.ScreenIndicator then
            self.ScreenIndicator.Visible = false
        end
        if UI.OnPointStatus then
            UI.OnPointStatus.Text = "> STATUS: TARGET OFF SCREEN"
            UI.OnPointStatus.TextColor3 = Config.Colors.Warning
        end
        return
    end
    
    -- Check if target is in POV circle
    local viewport = Services.Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local distFromCenter = (screenPos - center).Magnitude
    local isInCircle = distFromCenter <= Config.POV.Radius
    
    if isInCircle then
        -- Create indicator if not exists
        if not self.ScreenIndicator then
            self:CreateScreenIndicator()
        end
        
        self.ScreenIndicator.Visible = true
        
        -- Move indicator to follow target on screen
        if Config.OnPoint.SmoothUpdate then
            Utilities:Tween(self.ScreenIndicator, {
                Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            }, 0.08, Enum.EasingStyle.Linear)
        else
            self.ScreenIndicator.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
        end
        
        -- Update label
        if self.OnPointLabel then
            local dist = Utilities:GetDistance(target)
            local hp, maxHp = Utilities:GetHealth(target)
            self.OnPointLabel.Text = target.Name .. " | " .. math.floor(dist) .. "st | HP:" .. math.floor(hp)
        end
        
        -- Update lines size
        if self.OnPointH then
            self.OnPointH.Size = UDim2.new(0, Config.OnPoint.Radius, 0, 2)
            self.OnPointH.BackgroundTransparency = Config.OnPoint.Transparency
            self.OnPointH.BackgroundColor3 = Config.OnPoint.Color
        end
        if self.OnPointV then
            self.OnPointV.Size = UDim2.new(0, 2, 0, Config.OnPoint.Radius)
            self.OnPointV.BackgroundTransparency = Config.OnPoint.Transparency
            self.OnPointV.BackgroundColor3 = Config.OnPoint.Color
        end
        
        if UI.OnPointStatus then
            UI.OnPointStatus.Text = "> STATUS: LOCKED -- " .. target.Name .. " IN RANGE"
            UI.OnPointStatus.TextColor3 = Config.Colors.Accent
        end
    else
        if self.ScreenIndicator then
            self.ScreenIndicator.Visible = false
        end
        if UI.OnPointStatus then
            UI.OnPointStatus.Text = "> STATUS: TARGET OUTSIDE POV CIRCLE"
            UI.OnPointStatus.TextColor3 = Config.Colors.TextDim
        end
    end
end

-- ============================================================
-- MODULE: Main Loop
-- ============================================================
local MainLoop = {}

function MainLoop:Start()
    -- Main update loop (RenderStepped for visual updates)
    Utilities:AddConnection(Services.RunService.RenderStepped:Connect(function(dt)
        -- ESP Update
        if Config.ESP.Enabled then
            ESP:Update()
        end
        
        -- POV Camera follow
        if Config.POV.Following and Config.POV.Enabled then
            POVModule:UpdateCameraFollow()
        end
        
        -- POV Circle position update (keep centered)
        if Config.POV.Enabled and POVModule.Circle and Drawing then
            local viewport = Services.Camera.ViewportSize
            POVModule.Circle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        end
        
        -- On Point update
        if Config.OnPoint.Enabled then
            OnPointModule:Update()
        end
    end))
    
    -- Heartbeat for game logic (less frequent)
    Utilities:AddConnection(Services.RunService.Heartbeat:Connect(function(dt)
        -- Teleport safety check
        if Config.Teleport.Enabled then
            TeleportModule:Check()
        end
        
        -- Speed enforcement
        if Config.Speed.Value ~= 1 then
            local hum = Utilities:GetHumanoid(LocalPlayer)
            if hum then
                local expectedSpeed = Config.Speed.DefaultWalkSpeed * Config.Speed.Value
                if math.abs(hum.WalkSpeed - expectedSpeed) > 0.1 then
                    hum.WalkSpeed = expectedSpeed
                end
            end
        end
        
        -- Update teleport status
        if Config.Teleport.Enabled and UI.TeleportStatus then
            local remaining = Config.Teleport.Cooldown - (tick() - Config.Teleport.LastTeleport)
            if remaining > 0 then
                UI.TeleportStatus.Text = "> STATUS: COOLDOWN " .. string.format("%.1f", remaining) .. "s | RADIUS: " .. Config.Teleport.Radius .. " studs"
                UI.TeleportStatus.TextColor3 = Config.Colors.Warning
            else
                -- Check nearest killer distance
                local nearestDist = math.huge
                local nearestName = "NONE"
                for _, p in pairs(Services.Players:GetPlayers()) do
                    if p ~= LocalPlayer and Utilities:GetRole(p) == "Killer" then
                        local d = Utilities:GetDistance(p)
                        if d < nearestDist then
                            nearestDist = d
                            nearestName = p.Name
                        end
                    end
                end
                if nearestDist < math.huge then
                    UI.TeleportStatus.Text = "> STATUS: ARMED | NEAREST KILLER: " .. nearestName .. " (" .. math.floor(nearestDist) .. " studs)"
                    if nearestDist < Config.Teleport.Radius * 1.5 then
                        UI.TeleportStatus.TextColor3 = Config.Colors.Error
                    else
                        UI.TeleportStatus.TextColor3 = Config.Colors.Accent
                    end
                else
                    UI.TeleportStatus.Text = "> STATUS: ARMED | NO KILLERS DETECTED | RADIUS: " .. Config.Teleport.Radius
                    UI.TeleportStatus.TextColor3 = Config.Colors.TextDim
                end
            end
        end
    end))
    
    -- Character respawn handler
    Utilities:AddConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        -- Reapply speed
        if Config.Speed.Value ~= 1 then
            SpeedModule:Apply(Config.Speed.Value)
        end
        
        -- Re-setup ESP
        if Config.ESP.Enabled then
            for _, player in pairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local data = ESP.Objects[player]
                    if data then
                        local pChar = Utilities:GetCharacter(player)
                        if pChar then
                            if data.Billboard then
                                data.Billboard.Adornee = pChar:FindFirstChild("Head") or pChar:FindFirstChild("HumanoidRootPart")
                            end
                            if data.Highlight then
                                data.Highlight.Adornee = pChar
                            end
                        end
                    end
                end
            end
        end
        
        UI:AddLog("Character respawned -- modules reattached")
    end))
end

-- ============================================================
-- MODULE: Cleanup
-- ============================================================
_G.HOSHI_CLEANUP = function()
    Config.ESP.Enabled = false
    Config.Teleport.Enabled = false
    Config.POV.Enabled = false
    Config.OnPoint.Enabled = false
    Config.Speed.Value = 1
    
    -- Reset speed
    pcall(function()
        local hum = Utilities:GetHumanoid(LocalPlayer)
        if hum then
            hum.WalkSpeed = Config.Speed.DefaultWalkSpeed
        end
    end)
    
    ESP:Stop()
    POVModule:DestroyCircle()
    OnPointModule:DestroyIndicator()
    Utilities:CleanupAll()
    
    -- Destroy GUI
    pcall(function()
        local gui = Services.CoreGui:FindFirstChild("HoshiTerminal")
        if gui then gui:Destroy() end
    end)
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

-- Build GUI
UI:BuildGUI()

-- Start main loop
MainLoop:Start()

-- Initial notification after splash
task.delay(4, function()
    Notification:Push("HOSHI v" .. Config.Version .. " loaded successfully", "OK")
    Notification:Push("Click [H] button to open terminal", "INFO")
    UI:AddLog("System fully initialized")
end)

end -- End InitHoshi

-- Execute
InitHoshi()