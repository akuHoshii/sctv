-- ============================================================
-- HOSHI ADMIN DEVELOPMENT TOOLS v3.0
-- Terminal-Style Admin Panel for Roblox Development
-- Loader Script
-- Format: loadstring(game:HttpGet("LINK"))()
-- ============================================================

-- [HOSHI] Loader initialization
local HOSHI_VERSION = "3.0.0"
local HOSHI_BUILD = "TERMINAL-RELEASE"

-- Cleanup previous instances safely
pcall(function()
    if _G.HOSHI_CLEANUP and type(_G.HOSHI_CLEANUP) == "function" then
        _G.HOSHI_CLEANUP()
    end
end)

-- Remove any existing GUI
pcall(function()
    local existing = game:GetService("CoreGui"):FindFirstChild("HoshiTerminal")
    if existing then existing:Destroy() end
end)
pcall(function()
    local existing = game:GetService("CoreGui"):FindFirstChild("HoshiToggleGui")
    if existing then existing:Destroy() end
end)
pcall(function()
    local existing = game:GetService("CoreGui"):FindFirstChild("HoshiSplashGui")
    if existing then existing:Destroy() end
end)
pcall(function()
    local existing = game:GetService("CoreGui"):FindFirstChild("HoshiNotifGui")
    if existing then existing:Destroy() end
end)
pcall(function()
    local existing = game:GetService("CoreGui"):FindFirstChild("HoshiPOVGui")
    if existing then existing:Destroy() end
end)

-- ============================================================
-- MAIN INITIALIZATION
-- ============================================================
local function InitHoshi()

    -- ============================================================
    -- MODULE: Services (loaded first, no dependencies)
    -- ============================================================
    local Services = {}
    Services.Players = game:GetService("Players")
    Services.RunService = game:GetService("RunService")
    Services.TweenService = game:GetService("TweenService")
    Services.UserInputService = game:GetService("UserInputService")
    Services.Workspace = game:GetService("Workspace")
    Services.CoreGui = game:GetService("CoreGui")
    Services.StarterGui = game:GetService("StarterGui")
    Services.Camera = workspace.CurrentCamera

    local LocalPlayer = Services.Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    -- ============================================================
    -- MODULE: Config (all settings and defaults)
    -- ============================================================
    local Config = {}
    Config.Version = HOSHI_VERSION
    Config.Build = HOSHI_BUILD

    -- Terminal color palette
    Config.Colors = {}
    Config.Colors.Background = Color3.fromRGB(8, 8, 8)
    Config.Colors.BackgroundAlt = Color3.fromRGB(12, 12, 12)
    Config.Colors.BackgroundDark = Color3.fromRGB(3, 3, 3)
    Config.Colors.Panel = Color3.fromRGB(10, 10, 10)
    Config.Colors.Border = Color3.fromRGB(0, 255, 100)
    Config.Colors.BorderDim = Color3.fromRGB(0, 60, 30)
    Config.Colors.BorderBright = Color3.fromRGB(0, 255, 140)
    Config.Colors.Text = Color3.fromRGB(0, 230, 100)
    Config.Colors.TextDim = Color3.fromRGB(0, 140, 65)
    Config.Colors.TextBright = Color3.fromRGB(140, 255, 190)
    Config.Colors.TextWhite = Color3.fromRGB(200, 220, 210)
    Config.Colors.Accent = Color3.fromRGB(0, 255, 100)
    Config.Colors.AccentDim = Color3.fromRGB(0, 90, 40)
    Config.Colors.AccentBright = Color3.fromRGB(100, 255, 170)
    Config.Colors.Error = Color3.fromRGB(255, 55, 55)
    Config.Colors.ErrorDim = Color3.fromRGB(120, 30, 30)
    Config.Colors.Warning = Color3.fromRGB(255, 200, 0)
    Config.Colors.WarningDim = Color3.fromRGB(120, 95, 0)
    Config.Colors.Info = Color3.fromRGB(0, 170, 255)
    Config.Colors.InfoDim = Color3.fromRGB(0, 80, 120)
    Config.Colors.Success = Color3.fromRGB(0, 255, 100)
    Config.Colors.White = Color3.fromRGB(200, 200, 200)
    Config.Colors.Black = Color3.fromRGB(0, 0, 0)
    Config.Colors.Cursor = Color3.fromRGB(0, 255, 100)
    Config.Colors.Selection = Color3.fromRGB(0, 100, 50)
    Config.Colors.Comment = Color3.fromRGB(0, 90, 50)
    Config.Colors.CommentBright = Color3.fromRGB(0, 130, 70)
    Config.Colors.Keyword = Color3.fromRGB(0, 255, 170)
    Config.Colors.String = Color3.fromRGB(100, 255, 160)
    Config.Colors.Number = Color3.fromRGB(170, 255, 200)
    Config.Colors.Separator = Color3.fromRGB(0, 50, 28)
    Config.Colors.SeparatorBright = Color3.fromRGB(0, 80, 45)
    Config.Colors.Scanline = Color3.fromRGB(0, 255, 100)
    Config.Colors.Glow = Color3.fromRGB(0, 180, 80)

    -- Role colors for ESP
    Config.Colors.Killer = Color3.fromRGB(255, 45, 45)
    Config.Colors.KillerDim = Color3.fromRGB(150, 25, 25)
    Config.Colors.Survivor = Color3.fromRGB(0, 190, 255)
    Config.Colors.SurvivorDim = Color3.fromRGB(0, 90, 130)
    Config.Colors.Unknown = Color3.fromRGB(160, 160, 160)
    Config.Colors.UnknownDim = Color3.fromRGB(80, 80, 80)

    -- Font config
    Config.Font = Enum.Font.Code
    Config.FontBold = Enum.Font.Code
    Config.FontSize = 13
    Config.FontSizeSmall = 11
    Config.FontSizeTiny = 10
    Config.FontSizeLarge = 15
    Config.FontSizeTitle = 17
    Config.FontSizeHeader = 20
    Config.FontSizeASCII = 9

    -- Feature: ESP
    Config.ESP = {}
    Config.ESP.Enabled = false
    Config.ESP.ShowBox = true
    Config.ESP.ShowName = true
    Config.ESP.ShowDistance = true
    Config.ESP.ShowHealth = true
    Config.ESP.ShowRole = true

    -- Feature: Teleport Safety
    Config.Teleport = {}
    Config.Teleport.Enabled = false
    Config.Teleport.Radius = 35
    Config.Teleport.Cooldown = 3
    Config.Teleport.TeleportDistance = 100
    Config.Teleport.LastTeleport = 0

    -- Feature: Speed
    Config.Speed = {}
    Config.Speed.Value = 1
    Config.Speed.DefaultWalkSpeed = 16

    -- Feature: POV Circle
    Config.POV = {}
    Config.POV.Enabled = false
    Config.POV.Radius = 100
    Config.POV.Thickness = 2
    Config.POV.Opacity = 0.8
    Config.POV.Color = Color3.fromRGB(0, 255, 100)
    Config.POV.TargetPlayer = nil
    Config.POV.Following = false

    -- Feature: On Point
    Config.OnPoint = {}
    Config.OnPoint.Enabled = false
    Config.OnPoint.Radius = 50
    Config.OnPoint.Transparency = 0.5
    Config.OnPoint.Color = Color3.fromRGB(255, 220, 0)
    Config.OnPoint.SmoothUpdate = true

    -- UI sizing
    Config.UI = {}
    Config.UI.MinSize = Vector2.new(720, 460)
    Config.UI.MaxSize = Vector2.new(1300, 850)
    Config.UI.DefaultSize = Vector2.new(880, 560)
    Config.UI.Minimized = false
    Config.UI.CurrentTab = "ESP"
    Config.UI.LineCounter = 0

    -- ============================================================
    -- MODULE: Utilities (helper functions)
    -- ============================================================
    local Utilities = {}
    Utilities.Connections = {}
    Utilities.Instances = {}

    -- Track connections for cleanup
    function Utilities.AddConnection(self, conn)
        if conn then
            table.insert(self.Connections, conn)
        end
        return conn
    end

    -- Track instances for cleanup
    function Utilities.AddInstance(self, inst)
        if inst then
            table.insert(self.Instances, inst)
        end
        return inst
    end

    -- Destroy everything tracked
    function Utilities.CleanupAll(self)
        for i = #self.Connections, 1, -1 do
            pcall(function()
                self.Connections[i]:Disconnect()
            end)
            self.Connections[i] = nil
        end
        for i = #self.Instances, 1, -1 do
            pcall(function()
                self.Instances[i]:Destroy()
            end)
            self.Instances[i] = nil
        end
        self.Connections = {}
        self.Instances = {}
    end

    -- TweenService wrapper
    function Utilities.Tween(self, instance, props, duration, style, direction)
        if not instance or not instance.Parent then return nil end
        local tweenInfo = TweenInfo.new(
            duration or 0.3,
            style or Enum.EasingStyle.Quart,
            direction or Enum.EasingDirection.Out
        )
        local tween = Services.TweenService:Create(instance, tweenInfo, props)
        tween:Play()
        return tween
    end

    -- Get character safely
    function Utilities.GetCharacter(self, player)
        if not player then return nil end
        return player.Character
    end

    -- Get humanoid safely
    function Utilities.GetHumanoid(self, player)
        local char = self:GetCharacter(player)
        if not char then return nil end
        return char:FindFirstChildOfClass("Humanoid")
    end

    -- Get root part safely
    function Utilities.GetRootPart(self, player)
        local char = self:GetCharacter(player)
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            root = char:FindFirstChild("Torso")
        end
        return root
    end

    -- Get head safely
    function Utilities.GetHead(self, player)
        local char = self:GetCharacter(player)
        if not char then return nil end
        return char:FindFirstChild("Head")
    end

    -- Calculate distance between local player and target
    function Utilities.GetDistance(self, player)
        local myRoot = self:GetRootPart(LocalPlayer)
        local theirRoot = self:GetRootPart(player)
        if myRoot and theirRoot then
            return (myRoot.Position - theirRoot.Position).Magnitude
        end
        return math.huge
    end

    -- Get health info
    function Utilities.GetHealth(self, player)
        local hum = self:GetHumanoid(player)
        if hum then
            return hum.Health, hum.MaxHealth
        end
        return 0, 100
    end

    -- Detect player role from team, attributes, or character values
    function Utilities.GetRole(self, player)
        local char = self:GetCharacter(player)
        if not char then return "Unknown" end

        -- Method 1: Check team name
        if player.Team then
            local teamName = string.lower(player.Team.Name)
            if string.find(teamName, "killer") or string.find(teamName, "monster") or string.find(teamName, "beast") or string.find(teamName, "hunter") or string.find(teamName, "seeker") then
                return "Killer"
            end
            if string.find(teamName, "survivor") or string.find(teamName, "runner") or string.find(teamName, "innocent") or string.find(teamName, "hider") then
                return "Survivor"
            end
        end

        -- Method 2: Check BoolValue / StringValue in character
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("BoolValue") or child:IsA("StringValue") then
                local childName = string.lower(child.Name)
                if string.find(childName, "killer") or string.find(childName, "monster") or string.find(childName, "beast") then
                    return "Killer"
                end
                if string.find(childName, "survivor") or string.find(childName, "runner") or string.find(childName, "innocent") then
                    return "Survivor"
                end
            end
        end

        -- Method 3: Check player attributes
        local roleAttrNames = {"Role", "PlayerRole", "GameRole", "Type", "PlayerType", "CharacterRole"}
        for _, attrName in ipairs(roleAttrNames) do
            local success, attr = pcall(function()
                return player:GetAttribute(attrName)
            end)
            if success and attr then
                local attrLower = string.lower(tostring(attr))
                if string.find(attrLower, "killer") or string.find(attrLower, "monster") then
                    return "Killer"
                end
                if string.find(attrLower, "survivor") or string.find(attrLower, "runner") then
                    return "Survivor"
                end
            end
        end

        -- Method 4: Check character attributes
        for _, attrName in ipairs(roleAttrNames) do
            local success, attr = pcall(function()
                return char:GetAttribute(attrName)
            end)
            if success and attr then
                local attrLower = string.lower(tostring(attr))
                if string.find(attrLower, "killer") or string.find(attrLower, "monster") then
                    return "Killer"
                end
                if string.find(attrLower, "survivor") or string.find(attrLower, "runner") then
                    return "Survivor"
                end
            end
        end

        return "Unknown"
    end

    -- Get color for a role
    function Utilities.GetRoleColor(self, role)
        if role == "Killer" then
            return Config.Colors.Killer
        elseif role == "Survivor" then
            return Config.Colors.Survivor
        end
        return Config.Colors.Unknown
    end

    -- Get dim color for a role
    function Utilities.GetRoleDimColor(self, role)
        if role == "Killer" then
            return Config.Colors.KillerDim
        elseif role == "Survivor" then
            return Config.Colors.SurvivorDim
        end
        return Config.Colors.UnknownDim
    end

    -- Format current time
    function Utilities.FormatTime(self)
        return os.date("%H:%M:%S")
    end

    -- Format current date and time
    function Utilities.FormatDateTime(self)
        return os.date("%Y-%m-%d %H:%M:%S")
    end

    -- World position to screen coordinates
    function Utilities.WorldToScreen(self, position)
        local screenPos, onScreen = Services.Camera:WorldToScreenPoint(position)
        return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
    end

    -- Generate line number for terminal display
    function Utilities.GetLineNumber(self)
        Config.UI.LineCounter = Config.UI.LineCounter + 1
        local num = tostring(Config.UI.LineCounter)
        -- Pad to 4 digits
        while #num < 4 do
            num = "0" .. num
        end
        return num
    end

    -- Reset line counter
    function Utilities.ResetLineCounter(self)
        Config.UI.LineCounter = 0
    end

    -- ============================================================
    -- MODULE: Notification System
    -- ============================================================
    local Notification = {}
    Notification.Queue = {}
    Notification.Container = nil
    Notification.NotifGui = nil

    function Notification.Init(self, screenGui)
        self.NotifGui = Instance.new("ScreenGui")
        self.NotifGui.Name = "HoshiNotifGui"
        self.NotifGui.ResetOnSpawn = false
        self.NotifGui.DisplayOrder = 1001
        self.NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self.NotifGui.Parent = Services.CoreGui
        Utilities:AddInstance(self.NotifGui)

        self.Container = Instance.new("Frame")
        self.Container.Name = "NotificationContainer"
        self.Container.Size = UDim2.new(0, 420, 1, -20)
        self.Container.Position = UDim2.new(1, -430, 0, 10)
        self.Container.BackgroundTransparency = 1
        self.Container.Parent = self.NotifGui

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Parent = self.Container
    end

    function Notification.Push(self, message, notifType, duration)
        if not self.Container then return end

        notifType = notifType or "INFO"
        duration = duration or 5

        -- Determine color based on type
        local prefixColor = Config.Colors.Info
        local borderColor = Config.Colors.InfoDim
        local prefix = "[INFO]"
        if notifType == "ERROR" then
            prefixColor = Config.Colors.Error
            borderColor = Config.Colors.ErrorDim
            prefix = "[ERR!]"
        elseif notifType == "WARN" then
            prefixColor = Config.Colors.Warning
            borderColor = Config.Colors.WarningDim
            prefix = "[WARN]"
        elseif notifType == "OK" then
            prefixColor = Config.Colors.Success
            borderColor = Config.Colors.AccentDim
            prefix = "[ OK ]"
        elseif notifType == "SYS" then
            prefixColor = Config.Colors.Accent
            borderColor = Config.Colors.AccentDim
            prefix = "[SYS.]"
        end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Config.Colors.BackgroundDark
        frame.BorderSizePixel = 1
        frame.BorderColor3 = borderColor
        frame.BackgroundTransparency = 1
        frame.ClipsDescendants = true
        frame.Parent = self.Container

        -- Left accent bar
        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 3, 1, 0)
        accentBar.BackgroundColor3 = prefixColor
        accentBar.BorderSizePixel = 0
        accentBar.BackgroundTransparency = 0.3
        accentBar.Parent = frame

        -- Timestamp
        local timeStr = Utilities:FormatTime()

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Config.Font
        label.TextSize = Config.FontSizeSmall
        label.TextColor3 = prefixColor
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Text = timeStr .. " " .. prefix .. " " .. message
        label.TextTransparency = 1
        label.Parent = frame

        -- Animate in
        Utilities:Tween(frame, {BackgroundTransparency = 0.15}, 0.4)
        Utilities:Tween(label, {TextTransparency = 0}, 0.4)

        -- Auto remove after duration
        task.spawn(function()
            task.wait(duration)
            if frame and frame.Parent then
                Utilities:Tween(frame, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.5)
                Utilities:Tween(label, {TextTransparency = 1}, 0.4)
                task.wait(0.55)
                pcall(function()
                    frame:Destroy()
                end)
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
    UI.ToggleGui = nil
    UI.StatusBar = nil
    UI.StatusBarText = nil
    UI.StatusDot = nil
    UI.StatusLabel = nil
    UI.FPSLabel = nil
    UI.TeleportStatus = nil
    UI.SpeedStatus = nil
    UI.OnPointStatus = nil
    UI.POVTargetContainer = nil
    UI.LogContainer = nil
    UI.IsVisible = false
    UI.SplashDone = false

    -- Create any Roblox instance with properties
    function UI.Create(self, className, properties, children)
        local instance = Instance.new(className)
        if properties then
            for key, value in pairs(properties) do
                if key ~= "Parent" then
                    local ok, err = pcall(function()
                        instance[key] = value
                    end)
                end
            end
        end
        if children then
            for _, child in ipairs(children) do
                child.Parent = instance
            end
        end
        if properties and properties.Parent then
            instance.Parent = properties.Parent
        end
        return instance
    end

    -- ============================================================
    -- Terminal-style UI element builders
    -- ============================================================

    -- Terminal text line with line number
    function UI.MakeTerminalLine(self, text, parent, color, showLineNum)
        color = color or Config.Colors.Text
        if showLineNum == nil then showLineNum = true end

        local lineNum = ""
        if showLineNum then
            lineNum = Utilities:GetLineNumber() .. " | "
        end

        local line = self:Create("TextLabel", {
            Size = UDim2.new(1, -8, 0, 17),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = color,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = lineNum .. text,
            TextTruncate = Enum.TextTruncate.AtEnd,
            RichText = true,
            Parent = parent,
        })
        return line
    end

    -- Terminal comment line
    function UI.MakeComment(self, text, parent)
        return self:MakeTerminalLine("# " .. text, parent, Config.Colors.Comment, true)
    end

    -- Terminal section header with decorative border
    function UI.MakeHeader(self, text, parent)
        local headerText = string.rep("-", 3) .. " " .. string.upper(text) .. " " .. string.rep("-", 40 - #text)
        return self:MakeTerminalLine(headerText, parent, Config.Colors.Accent, true)
    end

    -- Terminal separator line
    function UI.MakeSeparator(self, parent)
        local sep = self:Create("Frame", {
            Size = UDim2.new(1, -8, 0, 1),
            BackgroundColor3 = Config.Colors.Separator,
            BorderSizePixel = 0,
            Parent = parent,
        })
        -- Spacer
        local spacer = self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        return sep
    end

    -- Terminal empty line
    function UI.MakeSpacer(self, parent, height)
        height = height or 6
        local spacer = self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, height),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        return spacer
    end

    -- Terminal-style clickable button
    function UI.MakeTerminalButton(self, text, parent, callback)
        local lineNum = Utilities:GetLineNumber()

        local btn = self:Create("TextButton", {
            Size = UDim2.new(1, -8, 0, 24),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.Text,
            Text = "",
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = parent,
        })

        local label = self:Create("TextLabel", {
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = lineNum .. " | $ " .. text,
            Parent = btn,
        })

        -- Cursor blink at end
        local cursor = self:Create("TextLabel", {
            Size = UDim2.new(0, 8, 1, -4),
            Position = UDim2.new(1, -14, 0, 2),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.Cursor,
            Text = "_",
            Visible = false,
            Parent = btn,
        })

        btn.MouseEnter:Connect(function()
            Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.AccentDim, BorderColor3 = Config.Colors.Accent}, 0.12)
            Utilities:Tween(label, {TextColor3 = Config.Colors.TextBright}, 0.12)
            cursor.Visible = true
        end)

        btn.MouseLeave:Connect(function()
            Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.BackgroundDark, BorderColor3 = Config.Colors.BorderDim}, 0.12)
            Utilities:Tween(label, {TextColor3 = Config.Colors.Text}, 0.12)
            cursor.Visible = false
        end)

        btn.MouseButton1Click:Connect(function()
            -- Flash effect
            Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.Accent}, 0.04)
            Utilities:Tween(label, {TextColor3 = Config.Colors.Black}, 0.04)
            task.wait(0.06)
            Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.AccentDim}, 0.15)
            Utilities:Tween(label, {TextColor3 = Config.Colors.TextBright}, 0.15)
            if callback then
                callback()
            end
        end)

        return btn
    end

    -- Terminal-style toggle switch
    function UI.MakeTerminalToggle(self, labelText, parent, default, callback)
        local lineNum = Utilities:GetLineNumber()

        local container = self:Create("Frame", {
            Size = UDim2.new(1, -8, 0, 24),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            Parent = parent,
        })

        local state = default or false

        local label = self:Create("TextLabel", {
            Size = UDim2.new(1, -100, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = lineNum .. " | " .. labelText,
            Parent = container,
        })

        local stateFrame = self:Create("Frame", {
            Size = UDim2.new(0, 80, 0, 18),
            Position = UDim2.new(1, -86, 0, 3),
            BackgroundColor3 = state and Config.Colors.AccentDim or Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 1,
            BorderColor3 = state and Config.Colors.Accent or Config.Colors.BorderDim,
            Parent = container,
        })

        local stateText = self:Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSizeSmall,
            TextColor3 = state and Config.Colors.Accent or Config.Colors.TextDim,
            Text = state and "[ ENABLED ]" or "[ ---- ]",
            Parent = stateFrame,
        })

        local clickButton = self:Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = container,
        })

        clickButton.MouseEnter:Connect(function()
            Utilities:Tween(container, {BorderColor3 = Config.Colors.Accent}, 0.12)
        end)

        clickButton.MouseLeave:Connect(function()
            Utilities:Tween(container, {BorderColor3 = Config.Colors.BorderDim}, 0.12)
        end)

        clickButton.MouseButton1Click:Connect(function()
            state = not state

            Utilities:Tween(stateFrame, {
                BackgroundColor3 = state and Config.Colors.AccentDim or Color3.fromRGB(25, 25, 25),
                BorderColor3 = state and Config.Colors.Accent or Config.Colors.BorderDim,
            }, 0.2)
            Utilities:Tween(stateText, {
                TextColor3 = state and Config.Colors.Accent or Config.Colors.TextDim,
            }, 0.2)
            stateText.Text = state and "[ ENABLED ]" or "[ ---- ]"

            if callback then
                callback(state)
            end
        end)

        -- Return container, getter, setter
        local getter = function()
            return state
        end

        local setter = function(newState)
            state = newState
            stateText.Text = state and "[ ENABLED ]" or "[ ---- ]"
            Utilities:Tween(stateFrame, {
                BackgroundColor3 = state and Config.Colors.AccentDim or Color3.fromRGB(25, 25, 25),
                BorderColor3 = state and Config.Colors.Accent or Config.Colors.BorderDim,
            }, 0.2)
            Utilities:Tween(stateText, {
                TextColor3 = state and Config.Colors.Accent or Config.Colors.TextDim,
            }, 0.2)
        end

        return container, getter, setter
    end

    -- Terminal-style slider with value input
    function UI.MakeTerminalSlider(self, labelText, parent, min, max, default, callback)
        local lineNum = Utilities:GetLineNumber()

        local container = self:Create("Frame", {
            Size = UDim2.new(1, -8, 0, 42),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            Parent = parent,
        })

        local currentValue = default or min

        -- Top row: label and value
        local label = self:Create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 20),
            Position = UDim2.new(0, 6, 0, 1),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = lineNum .. " | " .. labelText,
            Parent = container,
        })

        local valueBox = self:Create("TextBox", {
            Size = UDim2.new(0, 60, 0, 16),
            Position = UDim2.new(1, -66, 0, 3),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            Font = Config.Font,
            TextSize = Config.FontSizeSmall,
            TextColor3 = Config.Colors.Accent,
            Text = tostring(math.floor(currentValue * 10 + 0.5) / 10),
            ClearTextOnFocus = false,
            Parent = container,
        })

        -- Bottom row: slider bar
        local sliderTrack = self:Create("Frame", {
            Size = UDim2.new(1, -16, 0, 6),
            Position = UDim2.new(0, 8, 0, 28),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            Parent = container,
        })

        local ratio = math.clamp((currentValue - min) / (max - min), 0, 1)

        local sliderFill = self:Create("Frame", {
            Size = UDim2.new(ratio, 0, 1, 0),
            BackgroundColor3 = Config.Colors.AccentDim,
            BorderSizePixel = 0,
            Parent = sliderTrack,
        })

        local sliderKnob = self:Create("Frame", {
            Size = UDim2.new(0, 6, 0, 12),
            Position = UDim2.new(ratio, -3, 0.5, -6),
            BackgroundColor3 = Config.Colors.Accent,
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = sliderTrack,
        })

        -- Slider drag state
        local isDragging = false

        local function updateSlider(value)
            value = math.clamp(value, min, max)
            if max <= 100 then
                value = math.floor(value * 10 + 0.5) / 10
            else
                value = math.floor(value)
            end
            currentValue = value
            local newRatio = math.clamp((value - min) / (max - min), 0, 1)
            Utilities:Tween(sliderFill, {Size = UDim2.new(newRatio, 0, 1, 0)}, 0.08, Enum.EasingStyle.Linear)
            Utilities:Tween(sliderKnob, {Position = UDim2.new(newRatio, -3, 0.5, -6)}, 0.08, Enum.EasingStyle.Linear)
            valueBox.Text = tostring(math.floor(value * 10 + 0.5) / 10)
            if callback then
                callback(value)
            end
        end

        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                local clickRatio = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                updateSlider(min + (max - min) * clickRatio)
            end
        end)

        Utilities:AddConnection(Services.UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local moveRatio = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                updateSlider(min + (max - min) * moveRatio)
            end
        end))

        Utilities:AddConnection(Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end))

        valueBox.FocusLost:Connect(function(enterPressed)
            local num = tonumber(valueBox.Text)
            if num then
                updateSlider(num)
            else
                valueBox.Text = tostring(math.floor(currentValue * 10 + 0.5) / 10)
            end
        end)

        -- Hover effect
        container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                Utilities:Tween(container, {BorderColor3 = Config.Colors.Accent}, 0.12)
            end
        end)
        container.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                Utilities:Tween(container, {BorderColor3 = Config.Colors.BorderDim}, 0.12)
            end
        end)

        local getter = function()
            return currentValue
        end

        return container, getter, updateSlider
    end

    -- ============================================================
    -- BUILD MAIN GUI
    -- ============================================================
    function UI.BuildGUI(self)
        -- Main ScreenGui
        self.ScreenGui = self:Create("ScreenGui", {
            Name = "HoshiTerminal",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999,
            IgnoreGuiInset = false,
            Parent = Services.CoreGui,
        })
        Utilities:AddInstance(self.ScreenGui)

        -- Build the toggle button
        self:BuildToggleButton()

        -- Build the main terminal window
        self:BuildMainFrame()

        -- Initialize notification system
        Notification:Init(self.ScreenGui)

        -- Show splash / boot sequence
        self:ShowBootSequence()
    end

    -- ============================================================
    -- Toggle Button ("H" icon)
    -- ============================================================
    function UI.BuildToggleButton(self)
        self.ToggleGui = self:Create("ScreenGui", {
            Name = "HoshiToggleGui",
            ResetOnSpawn = false,
            DisplayOrder = 1002,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = false,
            Parent = Services.CoreGui,
        })
        Utilities:AddInstance(self.ToggleGui)

        local toggleOuter = self:Create("Frame", {
            Name = "ToggleOuter",
            Size = UDim2.new(0, 46, 0, 46),
            Position = UDim2.new(0, 14, 0.5, -23),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 2,
            BorderColor3 = Config.Colors.Accent,
            ZIndex = 100,
            Parent = self.ToggleGui,
        })

        -- Inner glow frame
        local toggleInner = self:Create("Frame", {
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            ZIndex = 101,
            Parent = toggleOuter,
        })

        local toggleLabel = self:Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Config.FontBold,
            TextSize = 24,
            TextColor3 = Config.Colors.Accent,
            Text = "H",
            ZIndex = 102,
            Parent = toggleInner,
        })

        local toggleBtn = self:Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 103,
            Parent = toggleOuter,
        })

        -- Draggable toggle
        local toggleDragging = false
        local toggleDragStart = nil
        local toggleStartPos = nil
        local toggleMoved = false

        toggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggleDragging = true
                toggleMoved = false
                toggleDragStart = input.Position
                toggleStartPos = toggleOuter.Position
            end
        end)

        Utilities:AddConnection(Services.UserInputService.InputChanged:Connect(function(input)
            if toggleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - toggleDragStart
                if delta.Magnitude > 5 then
                    toggleMoved = true
                end
                toggleOuter.Position = UDim2.new(
                    toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
                    toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
                )
            end
        end))

        Utilities:AddConnection(Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and toggleDragging then
                toggleDragging = false
                if not toggleMoved then
                    -- It was a click, toggle the main frame
                    self:ToggleMainFrame()
                end
            end
        end))

        -- Hover effects
        toggleBtn.MouseEnter:Connect(function()
            Utilities:Tween(toggleInner, {BackgroundColor3 = Config.Colors.AccentDim}, 0.15)
            Utilities:Tween(toggleLabel, {TextColor3 = Config.Colors.TextBright}, 0.15)
        end)

        toggleBtn.MouseLeave:Connect(function()
            Utilities:Tween(toggleInner, {BackgroundColor3 = Config.Colors.BackgroundDark}, 0.15)
            Utilities:Tween(toggleLabel, {TextColor3 = Config.Colors.Accent}, 0.15)
        end)

        -- Pulse animation for border
        task.spawn(function()
            local pulseState = true
            while toggleOuter and toggleOuter.Parent do
                local targetColor = pulseState and Config.Colors.Accent or Config.Colors.AccentDim
                Utilities:Tween(toggleOuter, {BorderColor3 = targetColor}, 1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                pulseState = not pulseState
                task.wait(1.8)
            end
        end)

        self.ToggleButton = toggleOuter
    end

    -- ============================================================
    -- Main Terminal Window
    -- ============================================================
    function UI.BuildMainFrame(self)
        local defaultSize = Config.UI.DefaultSize

        -- Main frame
        self.MainFrame = self:Create("Frame", {
            Name = "MainFrame",
            Size = UDim2.new(0, defaultSize.X, 0, defaultSize.Y),
            Position = UDim2.new(0.5, -defaultSize.X / 2, 0.5, -defaultSize.Y / 2),
            BackgroundColor3 = Config.Colors.Background,
            BorderSizePixel = 2,
            BorderColor3 = Config.Colors.Accent,
            Visible = false,
            ClipsDescendants = true,
            Parent = self.ScreenGui,
        })

        -- Scanline overlay effect (very subtle)
        local scanlineOverlay = self:Create("Frame", {
            Name = "Scanlines",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex = 90,
            Parent = self.MainFrame,
        })

        -- Create subtle scanlines
        for i = 0, 60 do
            local scanline = self:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0, i * 9),
                BackgroundColor3 = Config.Colors.Scanline,
                BackgroundTransparency = 0.97,
                BorderSizePixel = 0,
                ZIndex = 91,
                Parent = scanlineOverlay,
            })
        end

        -- ============================
        -- Title bar
        -- ============================
        local titleBar = self:Create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 0,
            ZIndex = 10,
            Parent = self.MainFrame,
        })

        -- Title bar bottom border (bright green line)
        self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Config.Colors.Accent,
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = titleBar,
        })

        -- Title text
        self:Create("TextLabel", {
            Size = UDim2.new(1, -200, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "HOSHI@" .. string.lower(LocalPlayer.Name) .. ":~$ admin-tools --version " .. Config.Version,
            ZIndex = 11,
            Parent = titleBar,
        })

        -- Window controls container
        local controlsContainer = self:Create("Frame", {
            Size = UDim2.new(0, 190, 1, 0),
            Position = UDim2.new(1, -190, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 11,
            Parent = titleBar,
        })

        -- Active status indicator
        self.StatusDot = self:Create("Frame", {
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0, 5, 0.5, -4),
            BackgroundColor3 = Config.Colors.Accent,
            BorderSizePixel = 0,
            ZIndex = 12,
            Parent = controlsContainer,
        })

        self.StatusLabel = self:Create("TextLabel", {
            Size = UDim2.new(0, 55, 1, 0),
            Position = UDim2.new(0, 17, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSizeTiny,
            TextColor3 = Config.Colors.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "ONLINE",
            ZIndex = 12,
            Parent = controlsContainer,
        })

        -- Minimize button
        local minimizeBtn = self:Create("TextButton", {
            Size = UDim2.new(0, 30, 0, 22),
            Position = UDim2.new(1, -66, 0, 6),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.TextDim,
            Text = "_",
            AutoButtonColor = false,
            ZIndex = 12,
            Parent = controlsContainer,
        })

        minimizeBtn.MouseButton1Click:Connect(function()
            self:MinimizeMainFrame()
        end)
        minimizeBtn.MouseEnter:Connect(function()
            Utilities:Tween(minimizeBtn, {BorderColor3 = Config.Colors.Warning, TextColor3 = Config.Colors.Warning}, 0.12)
        end)
        minimizeBtn.MouseLeave:Connect(function()
            Utilities:Tween(minimizeBtn, {BorderColor3 = Config.Colors.BorderDim, TextColor3 = Config.Colors.TextDim}, 0.12)
        end)

        -- Close button
        local closeBtn = self:Create("TextButton", {
            Size = UDim2.new(0, 30, 0, 22),
            Position = UDim2.new(1, -32, 0, 6),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.BorderDim,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.TextDim,
            Text = "X",
            AutoButtonColor = false,
            ZIndex = 12,
            Parent = controlsContainer,
        })

        closeBtn.MouseButton1Click:Connect(function()
            self:ToggleMainFrame()
        end)
        closeBtn.MouseEnter:Connect(function()
            Utilities:Tween(closeBtn, {BorderColor3 = Config.Colors.Error, TextColor3 = Config.Colors.Error}, 0.12)
        end)
        closeBtn.MouseLeave:Connect(function()
            Utilities:Tween(closeBtn, {BorderColor3 = Config.Colors.BorderDim, TextColor3 = Config.Colors.TextDim}, 0.12)
        end)

        -- ============================
        -- Dragging the title bar
        -- ============================
        local mainDragging = false
        local mainDragStart = nil
        local mainStartPos = nil

        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mainDragging = true
                mainDragStart = input.Position
                mainStartPos = self.MainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        mainDragging = false
                    end
                end)
            end
        end)

        Utilities:AddConnection(Services.UserInputService.InputChanged:Connect(function(input)
            if mainDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - mainDragStart
                self.MainFrame.Position = UDim2.new(
                    mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X,
                    mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y
                )
            end
        end))

        -- ============================
        -- Resize handle (bottom-right corner)
        -- ============================
        local resizeHandle = self:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -16, 1, -16),
            BackgroundColor3 = Config.Colors.AccentDim,
            BorderSizePixel = 0,
            ZIndex = 95,
            Parent = self.MainFrame,
        })

        self:Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = 10,
            TextColor3 = Config.Colors.Accent,
            Text = "//",
            ZIndex = 96,
            Parent = resizeHandle,
        })

        local resizeDragging = false
        local resizeStart = nil
        local resizeStartSize = nil

        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizeDragging = true
                resizeStart = input.Position
                resizeStartSize = self.MainFrame.AbsoluteSize
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        resizeDragging = false
                    end
                end)
            end
        end)

        Utilities:AddConnection(Services.UserInputService.InputChanged:Connect(function(input)
            if resizeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - resizeStart
                local newW = math.clamp(resizeStartSize.X + delta.X, Config.UI.MinSize.X, Config.UI.MaxSize.X)
                local newH = math.clamp(resizeStartSize.Y + delta.Y, Config.UI.MinSize.Y, Config.UI.MaxSize.Y)
                self.MainFrame.Size = UDim2.new(0, newW, 0, newH)
            end
        end))

        -- ============================
        -- Body (sidebar + content)
        -- ============================
        local body = self:Create("Frame", {
            Name = "Body",
            Size = UDim2.new(1, 0, 1, -58),
            Position = UDim2.new(0, 0, 0, 34),
            BackgroundTransparency = 1,
            Parent = self.MainFrame,
        })

        -- Sidebar
        self.Sidebar = self:Create("Frame", {
            Name = "Sidebar",
            Size = UDim2.new(0, 170, 1, 0),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 0,
            Parent = body,
        })

        -- Sidebar right border
        self:Create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0),
            BackgroundColor3 = Config.Colors.Separator,
            BorderSizePixel = 0,
            Parent = self.Sidebar,
        })

        local sidebarLayout = Instance.new("UIListLayout")
        sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sidebarLayout.Padding = UDim.new(0, 1)
        sidebarLayout.Parent = self.Sidebar

        -- Sidebar header
        local sidebarHeader = self:Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Font = Config.Font,
            TextSize = Config.FontSizeTiny,
            TextColor3 = Config.Colors.Comment,
            Text = "  -- MODULES --",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
            Parent = self.Sidebar,
        })

        self:Create("Frame", {
            Size = UDim2.new(1, -8, 0, 1),
            Position = UDim2.new(0, 4, 1, -1),
            BackgroundColor3 = Config.Colors.Separator,
            BorderSizePixel = 0,
            Parent = sidebarHeader,
        })

        -- Content area
        self.ContentArea = self:Create("Frame", {
            Name = "ContentArea",
            Size = UDim2.new(1, -170, 1, 0),
            Position = UDim2.new(0, 170, 0, 0),
            BackgroundColor3 = Config.Colors.Background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = body,
        })

        -- ============================
        -- Status bar (bottom)
        -- ============================
        local statusBar = self:Create("Frame", {
            Name = "StatusBar",
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 1, -24),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 0,
            ZIndex = 10,
            Parent = self.MainFrame,
        })

        -- Status bar top border
        self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Config.Colors.Separator,
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = statusBar,
        })

        self.StatusBarText = self:Create("TextLabel", {
            Size = UDim2.new(1, -120, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSizeTiny,
            TextColor3 = Config.Colors.Comment,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "hoshi@terminal:~$ ready | user:" .. LocalPlayer.Name .. " | place:" .. tostring(game.PlaceId),
            ZIndex = 11,
            Parent = statusBar,
        })

        self.FPSLabel = self:Create("TextLabel", {
            Size = UDim2.new(0, 110, 1, 0),
            Position = UDim2.new(1, -115, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSizeTiny,
            TextColor3 = Config.Colors.Comment,
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = "FPS:-- | MEM:--",
            ZIndex = 11,
            Parent = statusBar,
        })

        -- FPS and memory counter
        local fpsFrameCount = 0
        local fpsLastTime = tick()
        Utilities:AddConnection(Services.RunService.RenderStepped:Connect(function()
            fpsFrameCount = fpsFrameCount + 1
            local now = tick()
            if now - fpsLastTime >= 1 then
                local fps = math.floor(fpsFrameCount / (now - fpsLastTime))
                local mem = math.floor(gcinfo() / 1024 * 10) / 10
                if self.FPSLabel and self.FPSLabel.Parent then
                    self.FPSLabel.Text = "FPS:" .. tostring(fps) .. " | " .. tostring(mem) .. "MB"
                end
                fpsFrameCount = 0
                fpsLastTime = now
            end
        end))

        -- Build all tabs
        self:BuildAllTabs()
    end

    -- ============================================================
    -- Sidebar navigation button
    -- ============================================================
    function UI.AddSidebarButton(self, name, displayName, order)
        local btn = self:Create("TextButton", {
            Size = UDim2.new(1, -2, 0, 26),
            BackgroundColor3 = Config.Colors.BackgroundDark,
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

        -- Active indicator bar (left side)
        local indicator = self:Create("Frame", {
            Size = UDim2.new(0, 3, 1, -4),
            Position = UDim2.new(0, 0, 0, 2),
            BackgroundColor3 = Config.Colors.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = btn,
        })

        -- Label
        local label = self:Create("TextLabel", {
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSize,
            TextColor3 = Config.Colors.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "> " .. displayName,
            Parent = btn,
        })

        btn.MouseEnter:Connect(function()
            if Config.UI.CurrentTab ~= name then
                Utilities:Tween(btn, {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}, 0.12)
                Utilities:Tween(label, {TextColor3 = Config.Colors.Text}, 0.12)
            end
        end)

        btn.MouseLeave:Connect(function()
            if Config.UI.CurrentTab ~= name then
                Utilities:Tween(btn, {BackgroundColor3 = Config.Colors.BackgroundDark}, 0.12)
                Utilities:Tween(label, {TextColor3 = Config.Colors.TextDim}, 0.12)
            end
        end)

        btn.MouseButton1Click:Connect(function()
            self:SwitchTab(name)
        end)

        self.TabButtons[name] = {
            Button = btn,
            Label = label,
            Indicator = indicator,
        }

        return btn
    end

    -- ============================================================
    -- Tab switching logic
    -- ============================================================
    function UI.SwitchTab(self, name)
        Config.UI.CurrentTab = name

        -- Update sidebar appearance
        for tabName, data in pairs(self.TabButtons) do
            if tabName == name then
                Utilities:Tween(data.Button, {BackgroundColor3 = Config.Colors.AccentDim}, 0.2)
                Utilities:Tween(data.Label, {TextColor3 = Config.Colors.TextBright}, 0.2)
                Utilities:Tween(data.Indicator, {BackgroundTransparency = 0}, 0.2)
            else
                Utilities:Tween(data.Button, {BackgroundColor3 = Config.Colors.BackgroundDark}, 0.2)
                Utilities:Tween(data.Label, {TextColor3 = Config.Colors.TextDim}, 0.2)
                Utilities:Tween(data.Indicator, {BackgroundTransparency = 1}, 0.2)
            end
        end

        -- Show/hide tab content
        for tabName, frame in pairs(self.Tabs) do
            if tabName == name then
                frame.Visible = true
            else
                frame.Visible = false
            end
        end

        -- Update status bar
        if self.StatusBarText and self.StatusBarText.Parent then
            self.StatusBarText.Text = "hoshi@terminal:~/" .. string.lower(name) .. "$ module loaded | " .. Utilities:FormatTime()
        end
    end

    -- ============================================================
    -- Create scrolling tab content frame
    -- ============================================================
    function UI.CreateTabContent(self, name)
        local scroll = self:Create("ScrollingFrame", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Config.Colors.Background,
            BorderSizePixel = 0,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Config.Colors.AccentDim,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = self.ContentArea,
        })

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 3)
        layout.Parent = scroll

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.Parent = scroll

        self.Tabs[name] = scroll
        return scroll
    end

    -- ============================================================
    -- Build all tabs
    -- ============================================================
    function UI.BuildAllTabs(self)
        local tabDefinitions = {
            {name = "ESP", display = "ESP_PLAYER", order = 1},
            {name = "TELEPORT", display = "TELEPORT_SAFE", order = 2},
            {name = "SPEED", display = "SPEED_RUN", order = 3},
            {name = "POV", display = "POV_CIRCLE", order = 4},
            {name = "ONPOINT", display = "ON_POINT", order = 5},
            {name = "SYSTEM", display = "SYS_INFO", order = 6},
        }

        for _, def in ipairs(tabDefinitions) do
            self:AddSidebarButton(def.name, def.display, def.order)
            self:CreateTabContent(def.name)
        end

        -- Build each tab's content
        Utilities:ResetLineCounter()
        self:BuildESPTab()
        Utilities:ResetLineCounter()
        self:BuildTeleportTab()
        Utilities:ResetLineCounter()
        self:BuildSpeedTab()
        Utilities:ResetLineCounter()
        self:BuildPOVTab()
        Utilities:ResetLineCounter()
        self:BuildOnPointTab()
        Utilities:ResetLineCounter()
        self:BuildSystemTab()

        -- Activate first tab
        self:SwitchTab("ESP")
    end

    -- ============================================================
    -- TAB: ESP PLAYER
    -- ============================================================
    function UI.BuildESPTab(self)
        local tab = self.Tabs["ESP"]

        self:MakeTerminalLine("#!/hoshi/modules/esp_player.lua", tab, Config.Colors.Comment)
        self:MakeHeader("ESP PLAYER MODULE", tab)
        self:MakeComment("Renders debug overlays on all players", tab)
        self:MakeComment("Color-coded by role: KILLER=RED SURVIVOR=CYAN", tab)
        self:MakeSeparator(tab)

        self:MakeTerminalLine("local ESP = require('hoshi.esp')", tab, Config.Colors.Keyword)
        self:MakeSpacer(tab)

        self:MakeTerminalToggle("ESP.enabled", tab, Config.ESP.Enabled, function(state)
            Config.ESP.Enabled = state
            ESP:Toggle(state)
            Notification:Push("ESP module " .. (state and "activated" or "deactivated"), state and "OK" or "WARN")
        end)

        self:MakeSpacer(tab, 4)
        self:MakeComment("Sub-modules:", tab)

        self:MakeTerminalToggle("ESP.box_highlight", tab, Config.ESP.ShowBox, function(state)
            Config.ESP.ShowBox = state
        end)

        self:MakeTerminalToggle("ESP.name_tag", tab, Config.ESP.ShowName, function(state)
            Config.ESP.ShowName = state
        end)

        self:MakeTerminalToggle("ESP.distance_calc", tab, Config.ESP.ShowDistance, function(state)
            Config.ESP.ShowDistance = state
        end)

        self:MakeTerminalToggle("ESP.health_bar", tab, Config.ESP.ShowHealth, function(state)
            Config.ESP.ShowHealth = state
        end)

        self:MakeTerminalToggle("ESP.role_tag", tab, Config.ESP.ShowRole, function(state)
            Config.ESP.ShowRole = state
        end)

        self:MakeSeparator(tab)
        self:MakeComment("Role detection: Team > CharValue > Attribute", tab)
        self:MakeTerminalLine("-- KILLER  = Color3(255, 45, 45)  -- RED", tab, Config.Colors.Killer)
        self:MakeTerminalLine("-- SURVIVOR = Color3(0, 190, 255) -- CYAN", tab, Config.Colors.Survivor)
        self:MakeTerminalLine("-- UNKNOWN  = Color3(160, 160, 160) -- GRAY", tab, Config.Colors.Unknown)
        self:MakeTerminalLine("return ESP", tab, Config.Colors.Keyword)
    end

    -- ============================================================
    -- TAB: TELEPORT SAFETY
    -- ============================================================
    function UI.BuildTeleportTab(self)
        local tab = self.Tabs["TELEPORT"]

        self:MakeTerminalLine("#!/hoshi/modules/teleport_safety.lua", tab, Config.Colors.Comment)
        self:MakeHeader("TELEPORT SAFETY MODULE", tab)
        self:MakeComment("Auto-teleport away when Killer enters radius", tab)
        self:MakeComment("Calculates safe position opposite to threat vector", tab)
        self:MakeSeparator(tab)

        self:MakeTerminalLine("local Teleport = require('hoshi.teleport')", tab, Config.Colors.Keyword)
        self:MakeSpacer(tab)

        self:MakeTerminalToggle("Teleport.armed", tab, Config.Teleport.Enabled, function(state)
            Config.Teleport.Enabled = state
            Notification:Push("Teleport Safety " .. (state and "ARMED" or "DISARMED"), state and "OK" or "WARN")
        end)

        self:MakeSpacer(tab, 4)
        self:MakeComment("Configuration:", tab)

        self:MakeTerminalSlider("Teleport.detection_radius", tab, 10, 100, Config.Teleport.Radius, function(val)
            Config.Teleport.Radius = math.floor(val)
        end)

        self:MakeTerminalSlider("Teleport.escape_distance", tab, 50, 250, Config.Teleport.TeleportDistance, function(val)
            Config.Teleport.TeleportDistance = math.floor(val)
        end)

        self:MakeTerminalSlider("Teleport.cooldown_sec", tab, 1, 20, Config.Teleport.Cooldown, function(val)
            Config.Teleport.Cooldown = math.floor(val)
        end)

        self:MakeSeparator(tab)
        self:MakeComment("Runtime status:", tab)
        self.TeleportStatus = self:MakeTerminalLine("Teleport.status = 'STANDBY'", tab, Config.Colors.TextDim)
    end

    -- ============================================================
    -- TAB: SPEED RUN
    -- ============================================================
    function UI.BuildSpeedTab(self)
        local tab = self.Tabs["SPEED"]

        self:MakeTerminalLine("#!/hoshi/modules/speed_run.lua", tab, Config.Colors.Comment)
        self:MakeHeader("SPEED RUN MODULE", tab)
        self:MakeComment("Adjusts character WalkSpeed multiplier", tab)
        self:MakeComment("Range: 1x to 10x (base: 16 studs/s)", tab)
        self:MakeSeparator(tab)

        self:MakeTerminalLine("local Speed = require('hoshi.speed')", tab, Config.Colors.Keyword)
        self:MakeSpacer(tab)

        self:MakeTerminalSlider("Speed.multiplier", tab, 1, 10, Config.Speed.Value, function(val)
            Config.Speed.Value = val
            SpeedModule:Apply(val)
        end)

        self:MakeSpacer(tab, 4)

        self:MakeTerminalButton("Speed.reset()", tab, function()
            Config.Speed.Value = 1
            SpeedModule:Apply(1)
            Notification:Push("Speed reset to 1.0x (16 studs/s)", "OK")
        end)

        self:MakeSeparator(tab)
        self:MakeComment("Runtime:", tab)
        self.SpeedStatus = self:MakeTerminalLine("Speed.current = 16 studs/s (1.0x)", tab, Config.Colors.TextDim)
        self:MakeTerminalLine("Speed.base_walkspeed = 16", tab, Config.Colors.Comment)
        self:MakeTerminalLine("return Speed", tab, Config.Colors.Keyword)
    end

    -- ============================================================
    -- TAB: POV CIRCLE
    -- ============================================================
    function UI.BuildPOVTab(self)
        local tab = self.Tabs["POV"]

        self:MakeTerminalLine("#!/hoshi/modules/pov_circle.lua", tab, Config.Colors.Comment)
        self:MakeHeader("POV CIRCLE MODULE", tab)
        self:MakeComment("Crosshair circle overlay for observation", tab)
        self:MakeComment("Camera follows selected Survivor target", tab)
        self:MakeSeparator(tab)

        self:MakeTerminalLine("local POV = require('hoshi.pov')", tab, Config.Colors.Keyword)
        self:MakeSpacer(tab)

        self:MakeTerminalToggle("POV.circle_visible", tab, Config.POV.Enabled, function(state)
            Config.POV.Enabled = state
            POVModule:Toggle(state)
            Notification:Push("POV Circle " .. (state and "rendered" or "hidden"), state and "OK" or "WARN")
        end)

        self:MakeTerminalToggle("POV.camera_follow", tab, Config.POV.Following, function(state)
            Config.POV.Following = state
            Notification:Push("Camera follow " .. (state and "engaged" or "disengaged"), "INFO")
        end)

        self:MakeSpacer(tab, 4)
        self:MakeComment("Circle parameters:", tab)

        self:MakeTerminalSlider("POV.radius", tab, 20, 300, Config.POV.Radius, function(val)
            Config.POV.Radius = math.floor(val)
            POVModule:UpdateCircle()
        end)

        self:MakeTerminalSlider("POV.thickness", tab, 1, 10, Config.POV.Thickness, function(val)
            Config.POV.Thickness = math.floor(val)
            POVModule:UpdateCircle()
        end)

        self:MakeTerminalSlider("POV.opacity", tab, 0.1, 1.0, Config.POV.Opacity, function(val)
            Config.POV.Opacity = val
            POVModule:UpdateCircle()
        end)

        self:MakeSeparator(tab)
        self:MakeComment("Target selection:", tab)

        self.POVTargetContainer = self:Create("Frame", {
            Size = UDim2.new(1, -4, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tab,
        })

        local targetContainerLayout = Instance.new("UIListLayout")
        targetContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        targetContainerLayout.Padding = UDim.new(0, 2)
        targetContainerLayout.Parent = self.POVTargetContainer

        self:MakeSpacer(tab, 4)

        self:MakeTerminalButton("POV.refresh_targets()", tab, function()
            self:RefreshPOVTargets()
            Notification:Push("Target list refreshed", "INFO")
        end)

        -- Initial target list
        self:RefreshPOVTargets()

        self:MakeTerminalLine("return POV", tab, Config.Colors.Keyword)
    end

    -- Refresh player list for POV target selection
    function UI.RefreshPOVTargets(self)
        if not self.POVTargetContainer then return end

        -- Clear existing buttons
        for _, child in pairs(self.POVTargetContainer:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                if child.Name ~= "UIListLayout" and not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
        end

        -- Add player buttons
        for _, player in pairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local role = Utilities:GetRole(player)
                local roleColor = Utilities:GetRoleColor(role)

                local playerBtn = self:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = Config.Colors.BackgroundDark,
                    BorderSizePixel = 1,
                    BorderColor3 = Config.Colors.BorderDim,
                    Font = Config.Font,
                    TextSize = Config.FontSizeSmall,
                    TextColor3 = roleColor,
                    Text = "    >> " .. player.Name .. " [" .. role .. "]",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = self.POVTargetContainer,
                })

                playerBtn.MouseEnter:Connect(function()
                    Utilities:Tween(playerBtn, {BackgroundColor3 = Config.Colors.AccentDim, BorderColor3 = roleColor}, 0.1)
                end)
                playerBtn.MouseLeave:Connect(function()
                    Utilities:Tween(playerBtn, {BackgroundColor3 = Config.Colors.BackgroundDark, BorderColor3 = Config.Colors.BorderDim}, 0.1)
                end)
                playerBtn.MouseButton1Click:Connect(function()
                    Config.POV.TargetPlayer = player
                    Notification:Push("Target locked: " .. player.Name .. " [" .. role .. "]", "OK")
                end)
            end
        end

        if #Services.Players:GetPlayers() <= 1 then
            self:Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Font = Config.Font,
                TextSize = Config.FontSizeSmall,
                TextColor3 = Config.Colors.Comment,
                Text = "    -- no other players in server --",
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = self.POVTargetContainer,
            })
        end
    end

    -- ============================================================
    -- TAB: ON POINT
    -- ============================================================
    function UI.BuildOnPointTab(self)
        local tab = self.Tabs["ONPOINT"]

        self:MakeTerminalLine("#!/hoshi/modules/on_point.lua", tab, Config.Colors.Comment)
        self:MakeHeader("ON POINT MODULE", tab)
        self:MakeComment("Debug indicator when target enters POV circle", tab)
        self:MakeComment("Tracks hitbox, collision area, damage zone", tab)
        self:MakeSeparator(tab)

        self:MakeTerminalLine("local OnPoint = require('hoshi.onpoint')", tab, Config.Colors.Keyword)
        self:MakeSpacer(tab)

        self:MakeTerminalToggle("OnPoint.enabled", tab, Config.OnPoint.Enabled, function(state)
            Config.OnPoint.Enabled = state
            OnPointModule:Toggle(state)
            Notification:Push("OnPoint " .. (state and "tracking" or "stopped"), state and "OK" or "WARN")
        end)

        self:MakeTerminalToggle("OnPoint.smooth_lerp", tab, Config.OnPoint.SmoothUpdate, function(state)
            Config.OnPoint.SmoothUpdate = state
        end)

        self:MakeSpacer(tab, 4)
        self:MakeComment("Indicator parameters:", tab)

        self:MakeTerminalSlider("OnPoint.indicator_size", tab, 10, 200, Config.OnPoint.Radius, function(val)
            Config.OnPoint.Radius = math.floor(val)
        end)

        self:MakeTerminalSlider("OnPoint.transparency", tab, 0, 1, Config.OnPoint.Transparency, function(val)
            Config.OnPoint.Transparency = val
        end)

        self:MakeSeparator(tab)
        self:MakeComment("Runtime:", tab)
        self.OnPointStatus = self:MakeTerminalLine("OnPoint.status = 'AWAITING_TARGET'", tab, Config.Colors.TextDim)
        self:MakeTerminalLine("return OnPoint", tab, Config.Colors.Keyword)
    end

    -- ============================================================
    -- TAB: SYSTEM
    -- ============================================================
    function UI.BuildSystemTab(self)
        local tab = self.Tabs["SYSTEM"]

        self:MakeTerminalLine("#!/hoshi/system/info.lua", tab, Config.Colors.Comment)
        self:MakeHeader("SYSTEM INFORMATION", tab)
        self:MakeSeparator(tab)

        self:MakeTerminalLine("sys.name     = 'HOSHI Admin Development Tools'", tab, Config.Colors.Accent)
        self:MakeTerminalLine("sys.version  = '" .. Config.Version .. "'", tab, Config.Colors.TextDim)
        self:MakeTerminalLine("sys.build    = '" .. Config.Build .. "'", tab, Config.Colors.TextDim)
        self:MakeTerminalLine("sys.user     = '" .. LocalPlayer.Name .. "'", tab, Config.Colors.TextDim)
        self:MakeTerminalLine("sys.user_id  = " .. tostring(LocalPlayer.UserId), tab, Config.Colors.TextDim)
        self:MakeTerminalLine("sys.place_id = " .. tostring(game.PlaceId), tab, Config.Colors.TextDim)
        self:MakeTerminalLine("sys.game_id  = " .. tostring(game.GameId), tab, Config.Colors.TextDim)
        self:MakeTerminalLine("sys.time     = '" .. Utilities:FormatDateTime() .. "'", tab, Config.Colors.TextDim)

        self:MakeSeparator(tab)
        self:MakeHeader("COMMANDS", tab)

        self:MakeTerminalButton("sys.disable_all_modules()", tab, function()
            Config.ESP.Enabled = false
            Config.Teleport.Enabled = false
            Config.POV.Enabled = false
            Config.OnPoint.Enabled = false
            Config.Speed.Value = 1
            ESP:Toggle(false)
            POVModule:Toggle(false)
            OnPointModule:Toggle(false)
            SpeedModule:Apply(1)
            Notification:Push("All modules disabled and reset", "OK")
        end)

        self:MakeTerminalButton("sys.destroy()", tab, function()
            Notification:Push("HOSHI shutting down in 1s...", "WARN")
            task.spawn(function()
                task.wait(1.2)
                pcall(function()
                    _G.HOSHI_CLEANUP()
                end)
            end)
        end)

        self:MakeSeparator(tab)
        self:MakeHeader("LOG OUTPUT", tab)

        self.LogContainer = self:Create("Frame", {
            Size = UDim2.new(1, -4, 0, 10),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 1,
            BorderColor3 = Config.Colors.Separator,
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Parent = tab,
        })

        local logLayout = Instance.new("UIListLayout")
        logLayout.SortOrder = Enum.SortOrder.LayoutOrder
        logLayout.Padding = UDim.new(0, 0)
        logLayout.Parent = self.LogContainer

        local logPadding = Instance.new("UIPadding")
        logPadding.PaddingTop = UDim.new(0, 3)
        logPadding.PaddingBottom = UDim.new(0, 3)
        logPadding.PaddingLeft = UDim.new(0, 4)
        logPadding.Parent = self.LogContainer

        self:AddLog("hoshi.init() -- system started")
        self:AddLog("hoshi.load_modules() -- all modules ready")
        self:AddLog("hoshi.bind_events() -- event listeners active")
        self:AddLog("hoshi.status = 'OPERATIONAL'")
    end

    -- Add a log entry
    function UI.AddLog(self, message)
        if not self.LogContainer then return end

        local logLine = self:Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSizeTiny,
            TextColor3 = Config.Colors.Comment,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "[" .. Utilities:FormatTime() .. "] " .. message,
            Parent = self.LogContainer,
        })

        -- Keep log size manageable (max 80 entries)
        local children = {}
        for _, c in pairs(self.LogContainer:GetChildren()) do
            if c:IsA("TextLabel") then
                table.insert(children, c)
            end
        end
        while #children > 80 do
            children[1]:Destroy()
            table.remove(children, 1)
        end
    end

    -- ============================================================
    -- Toggle main frame visibility
    -- ============================================================
    function UI.ToggleMainFrame(self)
        self.IsVisible = not self.IsVisible

        if self.IsVisible then
            self.MainFrame.Visible = true
            local targetSize = Config.UI.DefaultSize

            -- Start from zero size at center
            self.MainFrame.Size = UDim2.new(0, 2, 0, 2)
            self.MainFrame.Position = UDim2.new(0.5, -1, 0.5, -1)

            -- Animate open
            Utilities:Tween(self.MainFrame, {
                Size = UDim2.new(0, targetSize.X, 0, targetSize.Y),
                Position = UDim2.new(0.5, -targetSize.X / 2, 0.5, -targetSize.Y / 2),
            }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            -- Animate close
            local currentPos = self.MainFrame.Position
            Utilities:Tween(self.MainFrame, {
                Size = UDim2.new(0, 2, 0, 2),
                Position = UDim2.new(
                    currentPos.X.Scale, currentPos.X.Offset + self.MainFrame.AbsoluteSize.X / 2,
                    currentPos.Y.Scale, currentPos.Y.Offset + self.MainFrame.AbsoluteSize.Y / 2
                ),
            }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

            task.spawn(function()
                task.wait(0.35)
                if not self.IsVisible and self.MainFrame then
                    self.MainFrame.Visible = false
                end
            end)
        end
    end

    -- ============================================================
    -- Minimize / restore
    -- ============================================================
    function UI.MinimizeMainFrame(self)
        Config.UI.Minimized = not Config.UI.Minimized

        if Config.UI.Minimized then
            self._restoreHeight = self.MainFrame.AbsoluteSize.Y
            Utilities:Tween(self.MainFrame, {
                Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X, 0, 34),
            }, 0.25)
        else
            local restoreH = self._restoreHeight or Config.UI.DefaultSize.Y
            Utilities:Tween(self.MainFrame, {
                Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X, 0, restoreH),
            }, 0.25)
        end
    end

    -- ============================================================
    -- Boot Sequence (Splash Screen) - Terminal style
    -- ============================================================
    function UI.ShowBootSequence(self)
        local splashGui = self:Create("ScreenGui", {
            Name = "HoshiSplashGui",
            ResetOnSpawn = false,
            DisplayOrder = 1010,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
            Parent = Services.CoreGui,
        })
        Utilities:AddInstance(splashGui)

        -- Full screen dark background
        local bg = self:Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Config.Colors.Black,
            BorderSizePixel = 0,
            ZIndex = 200,
            Parent = splashGui,
        })

        -- Terminal content container
        local termContainer = self:Create("Frame", {
            Size = UDim2.new(0, 600, 0, 420),
            Position = UDim2.new(0.5, -300, 0.5, -210),
            BackgroundColor3 = Config.Colors.BackgroundDark,
            BorderSizePixel = 2,
            BorderColor3 = Config.Colors.Accent,
            ZIndex = 201,
            Parent = bg,
        })

        -- Terminal title bar
        local termTitle = self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Color3.fromRGB(5, 5, 5),
            BorderSizePixel = 0,
            ZIndex = 202,
            Parent = termContainer,
        })

        self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Config.Colors.Accent,
            BorderSizePixel = 0,
            ZIndex = 203,
            Parent = termTitle,
        })

        self:Create("TextLabel", {
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Font = Config.Font,
            TextSize = Config.FontSizeSmall,
            TextColor3 = Config.Colors.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "hoshi@boot:~$ ./initialize.sh",
            ZIndex = 203,
            Parent = termTitle,
        })

        -- Terminal output area
        local outputArea = self:Create("ScrollingFrame", {
            Size = UDim2.new(1, -8, 1, -32),
            Position = UDim2.new(0, 4, 0, 28),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 202,
            Parent = termContainer,
        })

        local outputLayout = Instance.new("UIListLayout")
        outputLayout.SortOrder = Enum.SortOrder.LayoutOrder
        outputLayout.Padding = UDim.new(0, 1)
        outputLayout.Parent = outputArea

        -- Boot sequence lines
        local bootLines = {
            {text = "", color = Config.Colors.Accent, delay = 0.0},
            {text = "  ##  ##   #####    ######  ##  ##  ##", color = Config.Colors.Accent, delay = 0.03},
            {text = "  ##  ##  ##   ##  ##       ##  ##  ##", color = Config.Colors.Accent, delay = 0.06},
            {text = "  ######  ##   ##   #####   ######  ##", color = Config.Colors.Accent, delay = 0.09},
            {text = "  ##  ##  ##   ##       ##  ##  ##  ##", color = Config.Colors.Accent, delay = 0.12},
            {text = "  ##  ##   #####   ######   ##  ##  ##", color = Config.Colors.Accent, delay = 0.15},
            {text = "", color = Config.Colors.Accent, delay = 0.18},
            {text = "  ADMIN DEVELOPMENT TOOLS", color = Config.Colors.TextDim, delay = 0.25},
            {text = "  Version " .. Config.Version .. " | Build: " .. Config.Build, color = Config.Colors.Comment, delay = 0.30},
            {text = "  ============================================", color = Config.Colors.Separator, delay = 0.35},
            {text = "", color = Config.Colors.Accent, delay = 0.40},
            {text = "  [BOOT] Starting HOSHI kernel...", color = Config.Colors.Comment, delay = 0.50},
            {text = "  [BOOT] Loading core services...", color = Config.Colors.Comment, delay = 0.70},
            {text = "  [LOAD] Players service............ READY", color = Config.Colors.Accent, delay = 0.90},
            {text = "  [LOAD] RunService................. READY", color = Config.Colors.Accent, delay = 1.05},
            {text = "  [LOAD] TweenService............... READY", color = Config.Colors.Accent, delay = 1.15},
            {text = "  [LOAD] UserInputService........... READY", color = Config.Colors.Accent, delay = 1.25},
            {text = "  [LOAD] Camera..................... READY", color = Config.Colors.Accent, delay = 1.35},
            {text = "", color = Config.Colors.Accent, delay = 1.40},
            {text = "  [INIT] Compiling ESP module....... OK", color = Config.Colors.Success, delay = 1.55},
            {text = "  [INIT] Compiling Teleport module.. OK", color = Config.Colors.Success, delay = 1.70},
            {text = "  [INIT] Compiling Speed module..... OK", color = Config.Colors.Success, delay = 1.85},
            {text = "  [INIT] Compiling POV module....... OK", color = Config.Colors.Success, delay = 2.00},
            {text = "  [INIT] Compiling OnPoint module... OK", color = Config.Colors.Success, delay = 2.15},
            {text = "  [INIT] Building terminal UI...... OK", color = Config.Colors.Success, delay = 2.30},
            {text = "", color = Config.Colors.Accent, delay = 2.35},
            {text = "  [SYS ] User: " .. LocalPlayer.Name, color = Config.Colors.TextDim, delay = 2.45},
            {text = "  [SYS ] Place: " .. tostring(game.PlaceId), color = Config.Colors.TextDim, delay = 2.55},
            {text = "  [SYS ] Time: " .. Utilities:FormatDateTime(), color = Config.Colors.TextDim, delay = 2.65},
            {text = "", color = Config.Colors.Accent, delay = 2.70},
            {text = "  ============================================", color = Config.Colors.Separator, delay = 2.80},
            {text = "  [DONE] All systems operational.", color = Config.Colors.AccentBright, delay = 2.95},
            {text = "  [DONE] Click [H] to open terminal.", color = Config.Colors.Warning, delay = 3.10},
            {text = "", color = Config.Colors.Accent, delay = 3.15},
        }

        -- Typing animation: each line appears with characters typed out
        for lineIdx, lineData in ipairs(bootLines) do
            task.spawn(function()
                task.wait(lineData.delay)
                if not outputArea or not outputArea.Parent then return end

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 14)
                lbl.BackgroundTransparency = 1
                lbl.Font = Config.Font
                lbl.TextSize = Config.FontSizeSmall
                lbl.TextColor3 = lineData.color
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Text = ""
                lbl.ZIndex = 203
                lbl.LayoutOrder = lineIdx
                lbl.Parent = outputArea

                -- Type out characters one by one for non-empty lines
                local fullText = lineData.text
                if #fullText > 0 and lineData.delay > 0.4 then
                    -- Fast typing effect
                    local charsPerStep = math.max(1, math.floor(#fullText / 8))
                    local pos = 0
                    while pos < #fullText do
                        pos = math.min(pos + charsPerStep, #fullText)
                        lbl.Text = string.sub(fullText, 1, pos) .. "_"
                        task.wait(0.01)
                    end
                    lbl.Text = fullText
                else
                    lbl.Text = fullText
                end
            end)
        end

        -- Cursor blink at bottom
        task.spawn(function()
            task.wait(0.5)
            if not outputArea or not outputArea.Parent then return end

            local cursorLabel = Instance.new("TextLabel")
            cursorLabel.Size = UDim2.new(1, 0, 0, 14)
            cursorLabel.BackgroundTransparency = 1
            cursorLabel.Font = Config.Font
            cursorLabel.TextSize = Config.FontSizeSmall
            cursorLabel.TextColor3 = Config.Colors.Cursor
            cursorLabel.TextXAlignment = Enum.TextXAlignment.Left
            cursorLabel.Text = "  > _"
            cursorLabel.ZIndex = 203
            cursorLabel.LayoutOrder = 999
            cursorLabel.Parent = outputArea

            -- Blink cursor
            local blinkState = true
            for i = 1, 20 do
                task.wait(0.3)
                if cursorLabel and cursorLabel.Parent then
                    blinkState = not blinkState
                    cursorLabel.Text = blinkState and "  > _" or "  >  "
                end
            end
        end)

        -- Fade out and destroy splash
        task.spawn(function()
            task.wait(4.2)
            if bg and bg.Parent then
                -- Fade out
                Utilities:Tween(bg, {BackgroundTransparency = 1}, 1.0)
                for _, desc in pairs(bg:GetDescendants()) do
                    if desc:IsA("TextLabel") then
                        Utilities:Tween(desc, {TextTransparency = 1}, 0.8)
                    elseif desc:IsA("Frame") then
                        Utilities:Tween(desc, {BackgroundTransparency = 1, BorderColor3 = Config.Colors.Black}, 0.8)
                    end
                end
                task.wait(1.1)
                pcall(function()
                    splashGui:Destroy()
                end)
            end
            self.SplashDone = true
        end)
    end

    -- ============================================================
    -- MODULE: ESP (Player highlighting)
    -- ============================================================
    ESP = {}
    ESP.Objects = {}
    ESP.Running = false
    ESP.PlayerAddedConn = nil
    ESP.PlayerRemovingConn = nil

    function ESP.Toggle(self, state)
        if state then
            self:Start()
        else
            self:Stop()
        end
    end

    function ESP.Start(self)
        if self.Running then return end
        self.Running = true

        -- Create ESP for all existing players
        for _, player in pairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer then
                self:CreateESP(player)
            end
        end

        -- Listen for new players joining
        if self.PlayerAddedConn then
            pcall(function() self.PlayerAddedConn:Disconnect() end)
        end
        self.PlayerAddedConn = Services.Players.PlayerAdded:Connect(function(player)
            if Config.ESP.Enabled and player ~= LocalPlayer then
                task.wait(1)
                self:CreateESP(player)
            end
        end)
        Utilities:AddConnection(self.PlayerAddedConn)

        -- Listen for players leaving
        if self.PlayerRemovingConn then
            pcall(function() self.PlayerRemovingConn:Disconnect() end)
        end
        self.PlayerRemovingConn = Services.Players.PlayerRemoving:Connect(function(player)
            self:RemoveESP(player)
        end)
        Utilities:AddConnection(self.PlayerRemovingConn)

        UI:AddLog("ESP.start() -- tracking " .. tostring(#Services.Players:GetPlayers() - 1) .. " players")
    end

    function ESP.Stop(self)
        self.Running = false
        for player, data in pairs(self.Objects) do
            self:DestroyESPData(data)
        end
        self.Objects = {}
        UI:AddLog("ESP.stop() -- all overlays removed")
    end

    function ESP.CreateESP(self, player)
        if self.Objects[player] then return end

        local data = {}

        -- BillboardGui for info overlay
        data.Billboard = Instance.new("BillboardGui")
        data.Billboard.Name = "HoshiESP_" .. player.Name
        data.Billboard.AlwaysOnTop = true
        data.Billboard.Size = UDim2.new(0, 180, 0, 72)
        data.Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        data.Billboard.LightInfluence = 0
        data.Billboard.MaxDistance = 500

        -- Info background
        local infoFrame = Instance.new("Frame")
        infoFrame.Size = UDim2.new(1, 0, 1, 0)
        infoFrame.BackgroundColor3 = Config.Colors.Black
        infoFrame.BackgroundTransparency = 0.45
        infoFrame.BorderSizePixel = 1
        infoFrame.BorderColor3 = Config.Colors.Accent
        infoFrame.Parent = data.Billboard

        local infoLayout = Instance.new("UIListLayout")
        infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
        infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        infoLayout.Padding = UDim.new(0, 1)
        infoLayout.Parent = infoFrame

        local infoPad = Instance.new("UIPadding")
        infoPad.PaddingTop = UDim.new(0, 2)
        infoPad.Parent = infoFrame

        -- Name label
        data.NameLabel = Instance.new("TextLabel")
        data.NameLabel.Size = UDim2.new(1, -4, 0, 15)
        data.NameLabel.BackgroundTransparency = 1
        data.NameLabel.Font = Config.Font
        data.NameLabel.TextSize = 13
        data.NameLabel.TextColor3 = Config.Colors.Text
        data.NameLabel.Text = player.Name
        data.NameLabel.LayoutOrder = 1
        data.NameLabel.Parent = infoFrame

        -- Role label
        data.RoleLabel = Instance.new("TextLabel")
        data.RoleLabel.Size = UDim2.new(1, -4, 0, 13)
        data.RoleLabel.BackgroundTransparency = 1
        data.RoleLabel.Font = Config.Font
        data.RoleLabel.TextSize = 11
        data.RoleLabel.TextColor3 = Config.Colors.TextDim
        data.RoleLabel.Text = "[UNKNOWN]"
        data.RoleLabel.LayoutOrder = 2
        data.RoleLabel.Parent = infoFrame

        -- Distance label
        data.DistLabel = Instance.new("TextLabel")
        data.DistLabel.Size = UDim2.new(1, -4, 0, 13)
        data.DistLabel.BackgroundTransparency = 1
        data.DistLabel.Font = Config.Font
        data.DistLabel.TextSize = 11
        data.DistLabel.TextColor3 = Config.Colors.TextDim
        data.DistLabel.Text = "-- studs"
        data.DistLabel.LayoutOrder = 3
        data.DistLabel.Parent = infoFrame

        -- Health label
        data.HealthLabel = Instance.new("TextLabel")
        data.HealthLabel.Size = UDim2.new(1, -4, 0, 13)
        data.HealthLabel.BackgroundTransparency = 1
        data.HealthLabel.Font = Config.Font
        data.HealthLabel.TextSize = 11
        data.HealthLabel.TextColor3 = Config.Colors.Accent
        data.HealthLabel.Text = "HP:---/---"
        data.HealthLabel.LayoutOrder = 4
        data.HealthLabel.Parent = infoFrame

        -- Highlight for box ESP
        data.Highlight = Instance.new("Highlight")
        data.Highlight.Name = "HoshiHL_" .. player.Name
        data.Highlight.FillTransparency = 0.82
        data.Highlight.OutlineTransparency = 0.25
        data.Highlight.OutlineColor3 = Config.Colors.Accent
        data.Highlight.FillColor3 = Config.Colors.AccentDim
        data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        self.Objects[player] = data

        -- Attach to character
        local function attachToChar(char)
            if not char then return end
            task.spawn(function()
                task.wait(0.3)
                if not data.Billboard then return end
                local adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if adornee then
                    data.Billboard.Adornee = adornee
                    data.Billboard.Parent = Services.CoreGui
                end
                if data.Highlight then
                    data.Highlight.Adornee = char
                    data.Highlight.Parent = Services.CoreGui
                end
            end)
        end

        if player.Character then
            attachToChar(player.Character)
        end

        local charConn = player.CharacterAdded:Connect(function(char)
            attachToChar(char)
        end)
        Utilities:AddConnection(charConn)
        data.CharConn = charConn
    end

    function ESP.RemoveESP(self, player)
        local data = self.Objects[player]
        if data then
            self:DestroyESPData(data)
            self.Objects[player] = nil
        end
    end

    function ESP.DestroyESPData(self, data)
        pcall(function()
            if data.Billboard then data.Billboard:Destroy() end
        end)
        pcall(function()
            if data.Highlight then data.Highlight:Destroy() end
        end)
        pcall(function()
            if data.CharConn then data.CharConn:Disconnect() end
        end)
    end

    function ESP.Update(self)
        if not Config.ESP.Enabled then return end

        for player, data in pairs(self.Objects) do
            -- Check if player still exists
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

            -- Ensure billboard is attached
            if data.Billboard then
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head then
                    if data.Billboard.Adornee ~= head then
                        data.Billboard.Adornee = head
                    end
                    if not data.Billboard.Parent then
                        data.Billboard.Parent = Services.CoreGui
                    end
                end
                data.Billboard.Enabled = true
            end

            -- Ensure highlight is attached
            if data.Highlight then
                if data.Highlight.Adornee ~= char then
                    data.Highlight.Adornee = char
                end
                if not data.Highlight.Parent then
                    data.Highlight.Parent = Services.CoreGui
                end
                data.Highlight.Enabled = Config.ESP.ShowBox
            end

            -- Get role
            local role = Utilities:GetRole(player)
            local roleColor = Utilities:GetRoleColor(role)

            -- Update name
            if data.NameLabel then
                data.NameLabel.Visible = Config.ESP.ShowName
                data.NameLabel.Text = player.Name
                data.NameLabel.TextColor3 = roleColor
            end

            -- Update role
            if data.RoleLabel then
                data.RoleLabel.Visible = Config.ESP.ShowRole
                data.RoleLabel.Text = "[" .. role .. "]"
                data.RoleLabel.TextColor3 = roleColor
            end

            -- Update distance
            if data.DistLabel then
                data.DistLabel.Visible = Config.ESP.ShowDistance
                local dist = Utilities:GetDistance(player)
                if dist < math.huge then
                    data.DistLabel.Text = math.floor(dist) .. " studs"
                else
                    data.DistLabel.Text = "-- studs"
                end
            end

            -- Update health
            if data.HealthLabel then
                data.HealthLabel.Visible = Config.ESP.ShowHealth
                local hp, maxHp = Utilities:GetHealth(player)
                data.HealthLabel.Text = "HP:" .. math.floor(hp) .. "/" .. math.floor(maxHp)
                local pct = hp / math.max(maxHp, 1)
                if pct > 0.6 then
                    data.HealthLabel.TextColor3 = Config.Colors.Accent
                elseif pct > 0.3 then
                    data.HealthLabel.TextColor3 = Config.Colors.Warning
                else
                    data.HealthLabel.TextColor3 = Config.Colors.Error
                end
            end

            -- Update highlight color
            if data.Highlight then
                data.Highlight.OutlineColor3 = roleColor
                data.Highlight.FillColor3 = Utilities:GetRoleDimColor(role)
            end

            -- Update billboard border color
            local infoFrame = data.Billboard:FindFirstChildOfClass("Frame")
            if infoFrame then
                infoFrame.BorderColor3 = roleColor
            end
        end
    end

    -- ============================================================
    -- MODULE: Teleport Safety
    -- ============================================================
    TeleportModule = {}

    function TeleportModule.FindKillers(self)
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

    function TeleportModule.FindSafePosition(self, killerPos, myPos)
        local teleportDist = Config.Teleport.TeleportDistance

        -- Primary direction: directly away from killer
        local awayDir = (myPos - killerPos)
        awayDir = Vector3.new(awayDir.X, 0, awayDir.Z)
        if awayDir.Magnitude < 0.1 then
            awayDir = Vector3.new(1, 0, 0)
        end
        awayDir = awayDir.Unit

        -- Generate multiple candidate directions
        local candidates = {}
        table.insert(candidates, awayDir)

        -- Add angled variations
        for angle = -60, 60, 20 do
            local rad = math.rad(angle)
            local rotatedDir = Vector3.new(
                awayDir.X * math.cos(rad) - awayDir.Z * math.sin(rad),
                0,
                awayDir.X * math.sin(rad) + awayDir.Z * math.cos(rad)
            ).Unit
            table.insert(candidates, rotatedDir)
        end

        -- Add random directions as fallback
        for i = 1, 4 do
            local randAngle = math.random() * math.pi * 2
            table.insert(candidates, Vector3.new(math.cos(randAngle), 0, math.sin(randAngle)))
        end

        -- All known killers
        local allKillers = self:FindKillers()

        -- Test each candidate
        for _, dir in ipairs(candidates) do
            local targetPos = myPos + dir * teleportDist
            targetPos = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)

            -- Raycast down to find ground
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local myChar = Utilities:GetCharacter(LocalPlayer)
            if myChar then
                rayParams.FilterDescendantsInstances = {myChar}
            end

            local groundRay = workspace:Raycast(
                targetPos + Vector3.new(0, 60, 0),
                Vector3.new(0, -250, 0),
                rayParams
            )
            if groundRay then
                targetPos = groundRay.Position + Vector3.new(0, 4, 0)
            end

            -- Verify position is safe from ALL killers
            local positionIsSafe = true
            for _, killer in ipairs(allKillers) do
                local killerRoot = Utilities:GetRootPart(killer)
                if killerRoot then
                    local distFromKiller = (targetPos - killerRoot.Position).Magnitude
                    if distFromKiller < Config.Teleport.Radius * 2 then
                        positionIsSafe = false
                        break
                    end
                end
            end

            if positionIsSafe then
                return targetPos
            end
        end

        -- Absolute fallback: random far position
        local fallbackAngle = math.random() * math.pi * 2
        local fallbackPos = myPos + Vector3.new(
            math.cos(fallbackAngle) * teleportDist,
            0,
            math.sin(fallbackAngle) * teleportDist
        )
        return Vector3.new(fallbackPos.X, myPos.Y + 4, fallbackPos.Z)
    end

    function TeleportModule.Check(self)
        if not Config.Teleport.Enabled then return end

        -- Check cooldown
        local now = tick()
        local elapsed = now - Config.Teleport.LastTeleport
        if elapsed < Config.Teleport.Cooldown then
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
                    -- TELEPORT AWAY
                    local safePos = self:FindSafePosition(killerRoot.Position, myRoot.Position)
                    myRoot.CFrame = CFrame.new(safePos)
                    Config.Teleport.LastTeleport = now

                    local msg = "ESCAPED -- " .. killer.Name .. " was " .. math.floor(distance) .. " studs"
                    Notification:Push(msg, "WARN")
                    UI:AddLog("Teleport.escape(" .. killer.Name .. ", " .. math.floor(distance) .. "st)")

                    if UI.TeleportStatus and UI.TeleportStatus.Parent then
                        UI.TeleportStatus.Text = Utilities:GetLineNumber() .. " | Teleport.last = '" .. Utilities:FormatTime() .. "' -- escaped " .. killer.Name
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

    function SpeedModule.Apply(self, multiplier)
        local humanoid = Utilities:GetHumanoid(LocalPlayer)
        if humanoid then
            local newSpeed = Config.Speed.DefaultWalkSpeed * multiplier
            humanoid.WalkSpeed = newSpeed
            if UI.SpeedStatus and UI.SpeedStatus.Parent then
                UI.SpeedStatus.Text = Utilities:GetLineNumber() .. " | Speed.current = " .. math.floor(newSpeed) .. " studs/s (" .. (math.floor(multiplier * 10) / 10) .. "x)"
            end
        end
    end

    -- ============================================================
    -- MODULE: POV Circle
    -- ============================================================
    POVModule = {}
    POVModule.DrawingCircle = nil
    POVModule.GUICircle = nil
    POVModule.CircleSegments = {}
    POVModule.UsingDrawing = false

    function POVModule.Toggle(self, state)
        if state then
            self:CreateCircle()
        else
            self:DestroyCircle()
        end
    end

    function POVModule.CreateCircle(self)
        self:DestroyCircle()

        -- Try Drawing API first
        local drawingAvailable = pcall(function()
            local test = Drawing.new("Circle")
            test:Remove()
        end)

        if drawingAvailable then
            self.UsingDrawing = true
            self.DrawingCircle = Drawing.new("Circle")
            self.DrawingCircle.Color = Config.POV.Color
            self.DrawingCircle.Thickness = Config.POV.Thickness
            self.DrawingCircle.Radius = Config.POV.Radius
            self.DrawingCircle.Filled = false
            self.DrawingCircle.Transparency = Config.POV.Opacity
            self.DrawingCircle.NumSides = 72
            self.DrawingCircle.Visible = true

            local viewport = Services.Camera.ViewportSize
            self.DrawingCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        else
            self.UsingDrawing = false
            self:CreateGUICircle()
        end
    end

    function POVModule.CreateGUICircle(self)
        self:DestroyCircle()

        -- Create a ScreenGui for the POV circle
        local povGui = Instance.new("ScreenGui")
        povGui.Name = "HoshiPOVGui"
        povGui.ResetOnSpawn = false
        povGui.DisplayOrder = 998
        povGui.IgnoreGuiInset = false
        povGui.Parent = Services.CoreGui
        Utilities:AddInstance(povGui)
        self.POVGui = povGui

        local circleFrame = Instance.new("Frame")
        circleFrame.Name = "POVCircle"
        circleFrame.Size = UDim2.new(0, Config.POV.Radius * 2, 0, Config.POV.Radius * 2)
        circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        circleFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        circleFrame.BackgroundTransparency = 1
        circleFrame.Parent = povGui

        -- Build circle from line segments
        local numSegs = 72
        self.CircleSegments = {}
        for i = 1, numSegs do
            local angle1 = ((i - 1) / numSegs) * math.pi * 2
            local angle2 = (i / numSegs) * math.pi * 2

            local x1 = math.cos(angle1) * Config.POV.Radius
            local y1 = math.sin(angle1) * Config.POV.Radius
            local x2 = math.cos(angle2) * Config.POV.Radius
            local y2 = math.sin(angle2) * Config.POV.Radius

            local dx = x2 - x1
            local dy = y2 - y1
            local segLength = math.sqrt(dx * dx + dy * dy)
            local segAngle = math.atan2(dy, dx)

            local seg = Instance.new("Frame")
            seg.Size = UDim2.new(0, segLength + 1, 0, Config.POV.Thickness)
            seg.Position = UDim2.new(0.5, x1, 0.5, y1)
            seg.Rotation = math.deg(segAngle)
            seg.AnchorPoint = Vector2.new(0, 0.5)
            seg.BackgroundColor3 = Config.POV.Color
            seg.BackgroundTransparency = 1 - Config.POV.Opacity
            seg.BorderSizePixel = 0
            seg.Parent = circleFrame

            table.insert(self.CircleSegments, seg)
        end

        self.GUICircle = circleFrame
    end

    function POVModule.UpdateCircle(self)
        if self.UsingDrawing and self.DrawingCircle then
            self.DrawingCircle.Radius = Config.POV.Radius
            self.DrawingCircle.Thickness = Config.POV.Thickness
            self.DrawingCircle.Transparency = Config.POV.Opacity
            self.DrawingCircle.Color = Config.POV.Color
            local viewport = Services.Camera.ViewportSize
            self.DrawingCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        elseif self.GUICircle then
            -- Rebuild GUI circle with new params
            self:CreateGUICircle()
        end
    end

    function POVModule.DestroyCircle(self)
        if self.DrawingCircle then
            pcall(function() self.DrawingCircle:Remove() end)
            self.DrawingCircle = nil
        end
        if self.GUICircle then
            pcall(function() self.GUICircle:Destroy() end)
            self.GUICircle = nil
        end
        if self.POVGui then
            pcall(function() self.POVGui:Destroy() end)
            self.POVGui = nil
        end
        self.CircleSegments = {}
    end

    function POVModule.UpdatePosition(self)
        -- Keep circle centered on screen every frame
        if self.UsingDrawing and self.DrawingCircle then
            local viewport = Services.Camera.ViewportSize
            self.DrawingCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        end
        -- GUI circle is already positioned with UDim2(0.5, 0, 0.5, 0) so it auto-centers
    end

    function POVModule.UpdateCameraFollow(self)
        if not Config.POV.Following then return end
        if not Config.POV.TargetPlayer then return end

        local target = Config.POV.TargetPlayer
        if not target or not target.Parent then
            Config.POV.TargetPlayer = nil
            return
        end

        local targetRoot = Utilities:GetRootPart(target)
        if not targetRoot then return end

        local camera = Services.Camera
        local camPos = camera.CFrame.Position
        local targetPos = targetRoot.Position

        -- Smooth look-at interpolation
        local lookAtCF = CFrame.lookAt(camPos, targetPos)
        camera.CFrame = camera.CFrame:Lerp(lookAtCF, 0.08)
    end

    function POVModule.IsTargetInCircle(self)
        if not Config.POV.TargetPlayer then return false end

        local target = Config.POV.TargetPlayer
        if not target or not target.Parent then return false end

        local targetRoot = Utilities:GetRootPart(target)
        if not targetRoot then return false end

        local screenPos, onScreen = Utilities:WorldToScreen(targetRoot.Position)
        if not onScreen then return false end

        local viewport = Services.Camera.ViewportSize
        local centerScreen = Vector2.new(viewport.X / 2, viewport.Y / 2)
        local distFromCenter = (screenPos - centerScreen).Magnitude

        return distFromCenter <= Config.POV.Radius
    end

    -- ============================================================
    -- MODULE: On Point (debug indicator)
    -- ============================================================
    OnPointModule = {}
    OnPointModule.ScreenIndicator = nil
    OnPointModule.CrosshairH = nil
    OnPointModule.CrosshairV = nil
    OnPointModule.InfoLabel = nil
    OnPointModule.CornerMarkers = {}

    function OnPointModule.Toggle(self, state)
        if not state then
            self:DestroyIndicator()
        end
    end

    function OnPointModule.DestroyIndicator(self)
        if self.ScreenIndicator then
            pcall(function() self.ScreenIndicator:Destroy() end)
            self.ScreenIndicator = nil
        end
        self.CrosshairH = nil
        self.CrosshairV = nil
        self.InfoLabel = nil
        self.CornerMarkers = {}
    end

    function OnPointModule.CreateScreenIndicator(self)
        if self.ScreenIndicator then return end

        self.ScreenIndicator = Instance.new("Frame")
        self.ScreenIndicator.Name = "HoshiOnPoint"
        self.ScreenIndicator.Size = UDim2.new(0, Config.OnPoint.Radius * 2, 0, Config.OnPoint.Radius * 2)
        self.ScreenIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
        self.ScreenIndicator.Position = UDim2.new(0.5, 0, 0.5, 0)
        self.ScreenIndicator.BackgroundTransparency = 1
        self.ScreenIndicator.ZIndex = 50
        self.ScreenIndicator.Parent = UI.ScreenGui

        -- Horizontal crosshair
        self.CrosshairH = Instance.new("Frame")
        self.CrosshairH.Size = UDim2.new(0, Config.OnPoint.Radius * 2, 0, 2)
        self.CrosshairH.AnchorPoint = Vector2.new(0.5, 0.5)
        self.CrosshairH.Position = UDim2.new(0.5, 0, 0.5, 0)
        self.CrosshairH.BackgroundColor3 = Config.OnPoint.Color
        self.CrosshairH.BackgroundTransparency = Config.OnPoint.Transparency
        self.CrosshairH.BorderSizePixel = 0
        self.CrosshairH.ZIndex = 51
        self.CrosshairH.Parent = self.ScreenIndicator

        -- Vertical crosshair
        self.CrosshairV = Instance.new("Frame")
        self.CrosshairV.Size = UDim2.new(0, 2, 0, Config.OnPoint.Radius * 2)
        self.CrosshairV.AnchorPoint = Vector2.new(0.5, 0.5)
        self.CrosshairV.Position = UDim2.new(0.5, 0, 0.5, 0)
        self.CrosshairV.BackgroundColor3 = Config.OnPoint.Color
        self.CrosshairV.BackgroundTransparency = Config.OnPoint.Transparency
        self.CrosshairV.BorderSizePixel = 0
        self.CrosshairV.ZIndex = 51
        self.CrosshairV.Parent = self.ScreenIndicator

        -- Corner markers (4 corners of target area)
        self.CornerMarkers = {}
        local cornerPositions = {
            {x = -1, y = -1},
            {x = 1, y = -1},
            {x = -1, y = 1},
            {x = 1, y = 1},
        }
        for _, cp in ipairs(cornerPositions) do
            local corner = Instance.new("Frame")
            corner.Size = UDim2.new(0, 10, 0, 10)
            corner.AnchorPoint = Vector2.new(0.5, 0.5)
            corner.Position = UDim2.new(0.5, cp.x * Config.OnPoint.Radius * 0.4, 0.5, cp.y * Config.OnPoint.Radius * 0.4)
            corner.Rotation = 45
            corner.BackgroundColor3 = Config.OnPoint.Color
            corner.BackgroundTransparency = Config.OnPoint.Transparency
            corner.BorderSizePixel = 0
            corner.ZIndex = 51
            corner.Parent = self.ScreenIndicator
            table.insert(self.CornerMarkers, corner)
        end

        -- Info label below indicator
        self.InfoLabel = Instance.new("TextLabel")
        self.InfoLabel.Size = UDim2.new(0, 220, 0, 18)
        self.InfoLabel.AnchorPoint = Vector2.new(0.5, 0)
        self.InfoLabel.Position = UDim2.new(0.5, 0, 1, 8)
        self.InfoLabel.BackgroundColor3 = Config.Colors.Black
        self.InfoLabel.BackgroundTransparency = 0.4
        self.InfoLabel.BorderSizePixel = 1
        self.InfoLabel.BorderColor3 = Config.OnPoint.Color
        self.InfoLabel.Font = Config.Font
        self.InfoLabel.TextSize = Config.FontSizeSmall
        self.InfoLabel.TextColor3 = Config.OnPoint.Color
        self.InfoLabel.Text = "ON_POINT: TRACKING"
        self.InfoLabel.ZIndex = 52
        self.InfoLabel.Parent = self.ScreenIndicator

        Utilities:AddInstance(self.ScreenIndicator)
    end

    function OnPointModule.Update(self)
        if not Config.OnPoint.Enabled then
            if self.ScreenIndicator then
                self.ScreenIndicator.Visible = false
            end
            return
        end

        -- Need a target
        if not Config.POV.TargetPlayer then
            if self.ScreenIndicator then
                self.ScreenIndicator.Visible = false
            end
            if UI.OnPointStatus and UI.OnPointStatus.Parent then
                UI.OnPointStatus.Text = Utilities:GetLineNumber() .. " | OnPoint.status = 'NO_TARGET'"
                UI.OnPointStatus.TextColor3 = Config.Colors.Comment
            end
            return
        end

        local target = Config.POV.TargetPlayer
        if not target or not target.Parent then
            Config.POV.TargetPlayer = nil
            if self.ScreenIndicator then
                self.ScreenIndicator.Visible = false
            end
            return
        end

        local targetRoot = Utilities:GetRootPart(target)
        if not targetRoot then
            if self.ScreenIndicator then
                self.ScreenIndicator.Visible = false
            end
            return
        end

        -- Get screen position of target
        local screenPos, onScreen = Utilities:WorldToScreen(targetRoot.Position)

        if not onScreen then
            if self.ScreenIndicator then
                self.ScreenIndicator.Visible = false
            end
            if UI.OnPointStatus and UI.OnPointStatus.Parent then
                UI.OnPointStatus.Text = Utilities:GetLineNumber() .. " | OnPoint.status = 'TARGET_OFFSCREEN'"
                UI.OnPointStatus.TextColor3 = Config.Colors.Warning
            end
            return
        end

        -- Check if target is inside POV circle
        local viewport = Services.Camera.ViewportSize
        local centerScreen = Vector2.new(viewport.X / 2, viewport.Y / 2)
        local distFromCenter = (screenPos - centerScreen).Magnitude
        local isInsideCircle = distFromCenter <= Config.POV.Radius

        if isInsideCircle then
            -- Create indicator if needed
            if not self.ScreenIndicator then
                self:CreateScreenIndicator()
            end

            self.ScreenIndicator.Visible = true

            -- Move indicator to follow target on screen
            local targetUDim = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            if Config.OnPoint.SmoothUpdate then
                Utilities:Tween(self.ScreenIndicator, {Position = targetUDim}, 0.06, Enum.EasingStyle.Linear)
            else
                self.ScreenIndicator.Position = targetUDim
            end

            -- Update sizing
            local indicatorSize = Config.OnPoint.Radius * 2
            self.ScreenIndicator.Size = UDim2.new(0, indicatorSize, 0, indicatorSize)

            if self.CrosshairH then
                self.CrosshairH.Size = UDim2.new(0, indicatorSize, 0, 2)
                self.CrosshairH.BackgroundTransparency = Config.OnPoint.Transparency
                self.CrosshairH.BackgroundColor3 = Config.OnPoint.Color
            end
            if self.CrosshairV then
                self.CrosshairV.Size = UDim2.new(0, 2, 0, indicatorSize)
                self.CrosshairV.BackgroundTransparency = Config.OnPoint.Transparency
                self.CrosshairV.BackgroundColor3 = Config.OnPoint.Color
            end

            -- Update corner positions
            for idx, corner in ipairs(self.CornerMarkers) do
                local cp = {{x=-1,y=-1},{x=1,y=-1},{x=-1,y=1},{x=1,y=1}}
                if cp[idx] then
                    corner.Position = UDim2.new(0.5, cp[idx].x * Config.OnPoint.Radius * 0.4, 0.5, cp[idx].y * Config.OnPoint.Radius * 0.4)
                end
                corner.BackgroundColor3 = Config.OnPoint.Color
                corner.BackgroundTransparency = Config.OnPoint.Transparency
            end

            -- Update info label
            if self.InfoLabel then
                local dist = Utilities:GetDistance(target)
                local hp, maxHp = Utilities:GetHealth(target)
                self.InfoLabel.Text = target.Name .. " | " .. math.floor(dist) .. "st | HP:" .. math.floor(hp) .. "/" .. math.floor(maxHp)
                self.InfoLabel.BorderColor3 = Config.OnPoint.Color
                self.InfoLabel.TextColor3 = Config.OnPoint.Color
            end

            if UI.OnPointStatus and UI.OnPointStatus.Parent then
                UI.OnPointStatus.Text = Utilities:GetLineNumber() .. " | OnPoint.status = 'LOCKED:" .. target.Name .. "'"
                UI.OnPointStatus.TextColor3 = Config.Colors.Accent
            end
        else
            -- Target outside POV circle
            if self.ScreenIndicator then
                self.ScreenIndicator.Visible = false
            end
            if UI.OnPointStatus and UI.OnPointStatus.Parent then
                UI.OnPointStatus.Text = Utilities:GetLineNumber() .. " | OnPoint.status = 'OUTSIDE_POV_CIRCLE'"
                UI.OnPointStatus.TextColor3 = Config.Colors.TextDim
            end
        end
    end

    -- ============================================================
    -- MODULE: Main Loop (game loop connections)
    -- ============================================================
    local MainLoop = {}

    function MainLoop.Start(self)
        -- RenderStepped: visual updates every frame
        Utilities:AddConnection(Services.RunService.RenderStepped:Connect(function(deltaTime)
            -- ESP visual update
            if Config.ESP.Enabled then
                ESP:Update()
            end

            -- POV circle position (keep centered)
            if Config.POV.Enabled then
                POVModule:UpdatePosition()
            end

            -- POV camera follow
            if Config.POV.Enabled and Config.POV.Following then
                POVModule:UpdateCameraFollow()
            end

            -- On Point update (follows target on screen)
            if Config.OnPoint.Enabled then
                OnPointModule:Update()
            end
        end))

        -- Heartbeat: game logic (physics step)
        Utilities:AddConnection(Services.RunService.Heartbeat:Connect(function(deltaTime)
            -- Teleport safety check
            if Config.Teleport.Enabled then
                TeleportModule:Check()
            end

            -- Speed enforcement (re-apply if game resets it)
            if Config.Speed.Value ~= 1 then
                local hum = Utilities:GetHumanoid(LocalPlayer)
                if hum then
                    local expectedSpeed = Config.Speed.DefaultWalkSpeed * Config.Speed.Value
                    if math.abs(hum.WalkSpeed - expectedSpeed) > 1 then
                        hum.WalkSpeed = expectedSpeed
                    end
                end
            end

            -- Update teleport status display
            if Config.Teleport.Enabled and UI.TeleportStatus and UI.TeleportStatus.Parent then
                local cooldownRemaining = Config.Teleport.Cooldown - (tick() - Config.Teleport.LastTeleport)
                if cooldownRemaining > 0 then
                    UI.TeleportStatus.Text = Utilities:GetLineNumber() .. " | Teleport.status = 'COOLDOWN:" .. string.format("%.1f", cooldownRemaining) .. "s'"
                    UI.TeleportStatus.TextColor3 = Config.Colors.Warning
                else
                    -- Find nearest killer
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
                        local statusStr = "Teleport.status = 'ARMED' -- nearest: " .. nearestName .. " (" .. math.floor(nearestDist) .. "st)"
                        UI.TeleportStatus.Text = Utilities:GetLineNumber() .. " | " .. statusStr

                        if nearestDist < Config.Teleport.Radius * 1.5 then
                            UI.TeleportStatus.TextColor3 = Config.Colors.Error
                        elseif nearestDist < Config.Teleport.Radius * 3 then
                            UI.TeleportStatus.TextColor3 = Config.Colors.Warning
                        else
                            UI.TeleportStatus.TextColor3 = Config.Colors.Accent
                        end
                    else
                        UI.TeleportStatus.Text = Utilities:GetLineNumber() .. " | Teleport.status = 'ARMED' -- no killers detected"
                        UI.TeleportStatus.TextColor3 = Config.Colors.TextDim
                    end
                end
            end
        end))

        -- Character respawn handler
        Utilities:AddConnection(LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(1.5)

            -- Reapply speed multiplier
            if Config.Speed.Value ~= 1 then
                SpeedModule:Apply(Config.Speed.Value)
            end

            -- Re-attach ESP
            if Config.ESP.Enabled then
                for _, player in pairs(Services.Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local data = ESP.Objects[player]
                        if data then
                            local pChar = Utilities:GetCharacter(player)
                            if pChar then
                                if data.Billboard then
                                    local adornee = pChar:FindFirstChild("Head") or pChar:FindFirstChild("HumanoidRootPart")
                                    if adornee then
                                        data.Billboard.Adornee = adornee
                                    end
                                end
                                if data.Highlight then
                                    data.Highlight.Adornee = pChar
                                end
                            end
                        end
                    end
                end
            end

            UI:AddLog("CharacterAdded -- modules reattached")
            Notification:Push("Character respawned, modules reloaded", "SYS")
        end))

        UI:AddLog("MainLoop.start() -- all loops active")
    end

    -- ============================================================
    -- MODULE: Global Cleanup Function
    -- ============================================================
    _G.HOSHI_CLEANUP = function()
        -- Disable all features
        Config.ESP.Enabled = false
        Config.Teleport.Enabled = false
        Config.POV.Enabled = false
        Config.OnPoint.Enabled = false
        Config.Speed.Value = 1

        -- Reset walk speed
        pcall(function()
            local hum = Utilities:GetHumanoid(LocalPlayer)
            if hum then
                hum.WalkSpeed = Config.Speed.DefaultWalkSpeed
            end
        end)

        -- Stop ESP
        pcall(function() ESP:Stop() end)

        -- Destroy POV circle
        pcall(function() POVModule:DestroyCircle() end)

        -- Destroy OnPoint indicator
        pcall(function() OnPointModule:DestroyIndicator() end)

        -- Cleanup all tracked connections and instances
        Utilities:CleanupAll()

        -- Destroy all GUIs
        pcall(function()
            local gui = Services.CoreGui:FindFirstChild("HoshiTerminal")
            if gui then gui:Destroy() end
        end)
        pcall(function()
            local gui = Services.CoreGui:FindFirstChild("HoshiToggleGui")
            if gui then gui:Destroy() end
        end)
        pcall(function()
            local gui = Services.CoreGui:FindFirstChild("HoshiSplashGui")
            if gui then gui:Destroy() end
        end)
        pcall(function()
            local gui = Services.CoreGui:FindFirstChild("HoshiNotifGui")
            if gui then gui:Destroy() end
        end)
        pcall(function()
            local gui = Services.CoreGui:FindFirstChild("HoshiPOVGui")
            if gui then gui:Destroy() end
        end)
    end

    -- ============================================================
    -- EXECUTE: Build everything and start
    -- ============================================================

    -- Step 1: Build the GUI
    UI:BuildGUI()

    -- Step 2: Start the main loop
    MainLoop:Start()

    -- Step 3: Post-boot notifications (after splash finishes)
    task.spawn(function()
        task.wait(5)
        Notification:Push("HOSHI v" .. Config.Version .. " operational", "OK")
        Notification:Push("Click [H] to open terminal", "SYS")
        UI:AddLog("All systems nominal -- ready for input")
    end)

end -- End of InitHoshi function

-- ============================================================
-- EXECUTE INITIALIZATION
-- ============================================================
local initSuccess, initError = pcall(InitHoshi)
if not initSuccess then
    warn("[HOSHI] Initialization failed: " .. tostring(initError))
end