--[[
    HOSHI - Admin Development Tools
    Terminal/CMD Style UI
    Version 2.0

    Struktur Module:
    1. Config       - Konfigurasi global
    2. Utilities    - Fungsi utilitas
    3. Notification - Sistem notifikasi
    4. UI           - User Interface utama
    5. ESP          - ESP Player system
    6. Teleport     - Teleport Safety system
    7. Speed        - Speed Run system
    8. POV          - POV Circle system
    9. OnPoint      - On Point targeting system
    10. Cleanup     - Pembersihan memory
    11. Main        - Entry point
]]

-- ============================================================
-- MODULE: CONFIG
-- ============================================================
local Config = {
    ScriptName = "HOSHI",
    Version = "2.0",
    Author = "Developer",

    -- Warna tema terminal
    Colors = {
        Background = Color3.fromRGB(8, 8, 12),
        BackgroundAlt = Color3.fromRGB(12, 12, 18),
        Panel = Color3.fromRGB(14, 14, 22),
        PanelBorder = Color3.fromRGB(30, 30, 50),
        Accent = Color3.fromRGB(0, 180, 255),
        AccentDim = Color3.fromRGB(0, 90, 130),
        AccentGlow = Color3.fromRGB(0, 220, 255),
        Text = Color3.fromRGB(190, 200, 210),
        TextBright = Color3.fromRGB(220, 230, 240),
        TextDim = Color3.fromRGB(80, 90, 110),
        Green = Color3.fromRGB(0, 200, 80),
        Red = Color3.fromRGB(220, 40, 40),
        Yellow = Color3.fromRGB(220, 180, 0),
        Orange = Color3.fromRGB(220, 120, 0),
        Purple = Color3.fromRGB(140, 60, 220),
        Survivor = Color3.fromRGB(0, 180, 255),
        Killer = Color3.fromRGB(220, 40, 40),
        Unknown = Color3.fromRGB(160, 160, 160),
        TerminalGreen = Color3.fromRGB(0, 255, 120),
        TerminalCursor = Color3.fromRGB(0, 200, 255),
    },

    -- Font terminal
    Font = Enum.Font.Code,
    FontBold = Enum.Font.Code,

    -- UI sizing
    MinWindowSize = UDim2.new(0, 520, 0, 380),
    MaxWindowSize = UDim2.new(0, 900, 0, 620),
    DefaultWindowSize = UDim2.new(0, 700, 0, 480),
    DefaultWindowPos = UDim2.new(0.5, -350, 0.5, -240),

    -- Fitur defaults
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
        Color = Color3.fromRGB(0, 180, 255),
        TargetPlayer = nil,
        FollowCamera = false,
    },

    OnPoint = {
        Enabled = false,
        Radius = 50,
        Transparency = 0.5,
        Color = Color3.fromRGB(220, 40, 40),
        SmoothUpdate = true,
    },
}

-- ============================================================
-- MODULE: SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- MODULE: UTILITIES
-- ============================================================
local Utilities = {}

-- Tween helper dengan error handling
function Utilities.Tween(instance, duration, properties, easingStyle, easingDirection)
    if not instance or not instance.Parent then return end
    local style = easingStyle or Enum.EasingStyle.Quint
    local direction = easingDirection or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

-- Mendapatkan role player berdasarkan Team atau atribut
function Utilities.GetPlayerRole(player)
    if not player then return "Unknown" end

    -- Cek team
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("monster") or teamName:find("hunter") or teamName:find("beast") then
            return "Killer"
        elseif teamName:find("survivor") or teamName:find("runner") or teamName:find("human") or teamName:find("innocent") then
            return "Survivor"
        end
    end

    -- Cek atribut
    if player:GetAttribute("Role") then
        return tostring(player:GetAttribute("Role"))
    end

    -- Cek di character untuk tag
    local char = player.Character
    if char then
        if char:FindFirstChild("KillerTag") then return "Killer" end
        if char:FindFirstChild("SurvivorTag") then return "Survivor" end
    end

    return "Unknown"
end

-- Warna berdasarkan role
function Utilities.GetRoleColor(role)
    if role == "Killer" then
        return Config.Colors.Killer
    elseif role == "Survivor" then
        return Config.Colors.Survivor
    end
    return Config.Colors.Unknown
end

-- Jarak antara dua posisi
function Utilities.GetDistance(pos1, pos2)
    if typeof(pos1) == "Vector3" and typeof(pos2) == "Vector3" then
        return (pos1 - pos2).Magnitude
    end
    return math.huge
end

-- Mendapatkan posisi karakter
function Utilities.GetCharacterPosition(player)
    local char = player and player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then return root.Position end
        local head = char:FindFirstChild("Head")
        if head then return head.Position end
    end
    return nil
end

-- Mendapatkan health karakter
function Utilities.GetHealth(player)
    local char = player and player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            return hum.Health, hum.MaxHealth
        end
    end
    return 0, 100
end

-- Cek apakah posisi ada di layar
function Utilities.WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToScreenPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- Mendapatkan bounding box karakter di layar
function Utilities.GetBoundingBox(player)
    local char = player and player.Character
    if not char then return nil end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return nil end

    local rootPos = root.Position
    local topPos = rootPos + Vector3.new(0, 3, 0)
    local bottomPos = rootPos - Vector3.new(0, 3, 0)

    local topScreen, topOnScreen = Utilities.WorldToScreen(topPos)
    local bottomScreen, bottomOnScreen = Utilities.WorldToScreen(bottomPos)

    if not topOnScreen and not bottomOnScreen then return nil end

    local height = math.abs(bottomScreen.Y - topScreen.Y)
    local width = height * 0.6

    local centerX = (topScreen.X + bottomScreen.X) / 2

    return {
        TopLeft = Vector2.new(centerX - width / 2, topScreen.Y),
        BottomRight = Vector2.new(centerX + width / 2, bottomScreen.Y),
        Width = width,
        Height = height,
        Center = Vector2.new(centerX, (topScreen.Y + bottomScreen.Y) / 2),
        TopCenter = topScreen,
    }
end

-- Format angka
function Utilities.FormatNumber(num)
    return string.format("%.0f", num)
end

-- Timestamp terminal style
function Utilities.GetTimestamp()
    local t = os.date("*t")
    return string.format("[%02d:%02d:%02d]", t.hour, t.min, t.sec)
end

-- Cari posisi aman untuk teleport (menjauhi killer)
function Utilities.FindSafePosition(currentPos, killerPos, distance)
    -- Arah menjauhi killer
    local direction = (currentPos - killerPos).Unit
    -- Tambahkan sedikit random offset agar tidak selalu lurus
    local randomAngle = math.rad(math.random(-30, 30))
    local rotatedDir = Vector3.new(
        direction.X * math.cos(randomAngle) - direction.Z * math.sin(randomAngle),
        0,
        direction.X * math.sin(randomAngle) + direction.Z * math.cos(randomAngle)
    ).Unit

    local targetPos = currentPos + rotatedDir * distance
    -- Raycast ke bawah untuk mendapatkan posisi tanah
    local rayOrigin = targetPos + Vector3.new(0, 50, 0)
    local rayDir = Vector3.new(0, -200, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

    local result = Workspace:Raycast(rayOrigin, rayDir, rayParams)
    if result then
        return result.Position + Vector3.new(0, 3, 0)
    end

    -- Fallback: gunakan posisi target dengan Y dari posisi saat ini
    return Vector3.new(targetPos.X, currentPos.Y, targetPos.Z)
end

-- ============================================================
-- MODULE: CLEANUP
-- ============================================================
local Cleanup = {}
Cleanup._connections = {}
Cleanup._instances = {}
Cleanup._drawings = {}

function Cleanup.AddConnection(conn)
    table.insert(Cleanup._connections, conn)
    return conn
end

function Cleanup.AddInstance(inst)
    table.insert(Cleanup._instances, inst)
    return inst
end

function Cleanup.AddDrawing(draw)
    table.insert(Cleanup._drawings, draw)
    return draw
end

function Cleanup.Destroy()
    for _, conn in ipairs(Cleanup._connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, inst in ipairs(Cleanup._instances) do
        pcall(function() inst:Destroy() end)
    end
    for _, draw in ipairs(Cleanup._drawings) do
        pcall(function() draw:Remove() end)
    end
    Cleanup._connections = {}
    Cleanup._instances = {}
    Cleanup._drawings = {}
end

-- ============================================================
-- MODULE: NOTIFICATION
-- ============================================================
local Notification = {}
Notification._container = nil

function Notification.Init(parent)
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 320, 1, 0)
    container.Position = UDim2.new(1, -330, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = container

    Notification._container = container
end

function Notification.Send(title, message, duration, notifType)
    if not Notification._container then return end

    duration = duration or 3
    notifType = notifType or "info"

    local accentColor
    if notifType == "success" then
        accentColor = Config.Colors.Green
    elseif notifType == "error" then
        accentColor = Config.Colors.Red
    elseif notifType == "warning" then
        accentColor = Config.Colors.Yellow
    else
        accentColor = Config.Colors.Accent
    end

    local prefixMap = {
        info = "[INFO]",
        success = "[OK]",
        error = "[ERR]",
        warning = "[WARN]",
    }
    local prefix = prefixMap[notifType] or "[LOG]"

    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 52)
    notif.BackgroundColor3 = Config.Colors.Panel
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 1
    notif.ClipsDescendants = true
    notif.Parent = Notification._container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Color = accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = notif

    -- Accent bar kiri
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.Parent = notif

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = bar

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 0, 18)
    titleLabel.Position = UDim2.new(0, 12, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = Utilities.GetTimestamp() .. " " .. prefix .. " " .. title
    titleLabel.TextColor3 = accentColor
    titleLabel.TextSize = 12
    titleLabel.Font = Config.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = notif

    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -16, 0, 18)
    msgLabel.Position = UDim2.new(0, 12, 0, 26)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = "> " .. message
    msgLabel.TextColor3 = Config.Colors.TextDim
    msgLabel.TextSize = 11
    msgLabel.Font = Config.Font
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextTruncate = Enum.TextTruncate.AtEnd
    msgLabel.Parent = notif

    -- Animasi masuk
    Utilities.Tween(notif, 0.3, {BackgroundTransparency = 0.05})

    -- Auto hilang
    task.delay(duration, function()
        Utilities.Tween(notif, 0.5, {BackgroundTransparency = 1})
        Utilities.Tween(stroke, 0.5, {Transparency = 1})
        Utilities.Tween(titleLabel, 0.5, {TextTransparency = 1})
        Utilities.Tween(msgLabel, 0.5, {TextTransparency = 1})
        Utilities.Tween(bar, 0.5, {BackgroundTransparency = 1})
        task.wait(0.6)
        pcall(function() notif:Destroy() end)
    end)
end

-- ============================================================
-- MODULE: ESP
-- ============================================================
local ESP = {}
ESP._drawings = {}
ESP._connection = nil

function ESP.CreateESPForPlayer(player)
    if player == LocalPlayer then return end

    local drawings = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Role = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarBG = Drawing.new("Line"),
    }

    -- Box setup
    drawings.BoxOutline.Thickness = 3
    drawings.BoxOutline.Color = Color3.new(0, 0, 0)
    drawings.BoxOutline.Filled = false
    drawings.BoxOutline.Visible = false

    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.Box.Visible = false

    -- Text setup
    for _, key in ipairs({"Name", "Distance", "Health", "Role"}) do
        drawings[key].Size = 13
        drawings[key].Center = true
        drawings[key].Outline = true
        drawings[key].OutlineColor = Color3.new(0, 0, 0)
        drawings[key].Font = Drawing.Fonts.Monospace
        drawings[key].Visible = false
    end

    drawings.Name.Size = 14

    -- Health bar
    drawings.HealthBarBG.Thickness = 3
    drawings.HealthBarBG.Color = Color3.new(0, 0, 0)
    drawings.HealthBarBG.Visible = false

    drawings.HealthBar.Thickness = 1
    drawings.HealthBar.Visible = false

    ESP._drawings[player] = drawings

    for _, d in pairs(drawings) do
        Cleanup.AddDrawing(d)
    end
end

function ESP.UpdateESP()
    for player, drawings in pairs(ESP._drawings) do
        if not player or not player.Parent then
            ESP.RemoveESPForPlayer(player)
            continue
        end

        if not Config.ESP.Enabled then
            for _, d in pairs(drawings) do
                d.Visible = false
            end
            continue
        end

        local bbox = Utilities.GetBoundingBox(player)
        if not bbox then
            for _, d in pairs(drawings) do
                d.Visible = false
            end
            continue
        end

        local role = Utilities.GetPlayerRole(player)
        local roleColor = Utilities.GetRoleColor(role)
        local health, maxHealth = Utilities.GetHealth(player)
        local myPos = Utilities.GetCharacterPosition(LocalPlayer)
        local theirPos = Utilities.GetCharacterPosition(player)
        local dist = 0
        if myPos and theirPos then
            dist = Utilities.GetDistance(myPos, theirPos)
        end

        -- Box
        if Config.ESP.ShowBox then
            drawings.BoxOutline.Size = Vector2.new(bbox.Width, bbox.Height)
            drawings.BoxOutline.Position = bbox.TopLeft
            drawings.BoxOutline.Visible = true

            drawings.Box.Size = Vector2.new(bbox.Width, bbox.Height)
            drawings.Box.Position = bbox.TopLeft
            drawings.Box.Color = roleColor
            drawings.Box.Visible = true
        else
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
        end

        -- Name
        if Config.ESP.ShowName then
            drawings.Name.Text = player.DisplayName
            drawings.Name.Position = Vector2.new(bbox.Center.X, bbox.TopLeft.Y - 20)
            drawings.Name.Color = roleColor
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end

        -- Distance
        if Config.ESP.ShowDistance then
            drawings.Distance.Text = Utilities.FormatNumber(dist) .. " studs"
            drawings.Distance.Position = Vector2.new(bbox.Center.X, bbox.BottomRight.Y + 4)
            drawings.Distance.Color = Config.Colors.TextDim
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end

        -- Health
        if Config.ESP.ShowHealth then
            drawings.Health.Text = Utilities.FormatNumber(health) .. "/" .. Utilities.FormatNumber(maxHealth)
            drawings.Health.Position = Vector2.new(bbox.Center.X, bbox.BottomRight.Y + 18)
            drawings.Health.Color = Color3.fromRGB(
                math.clamp(255 - (health / maxHealth) * 255, 0, 255),
                math.clamp((health / maxHealth) * 255, 0, 255),
                0
            )
            drawings.Health.Visible = true

            -- Health bar
            local barX = bbox.TopLeft.X - 6
            local barTopY = bbox.TopLeft.Y
            local barBottomY = bbox.BottomRight.Y
            local healthRatio = math.clamp(health / maxHealth, 0, 1)
            local barHealthY = barBottomY - (barBottomY - barTopY) * healthRatio

            drawings.HealthBarBG.From = Vector2.new(barX, barTopY)
            drawings.HealthBarBG.To = Vector2.new(barX, barBottomY)
            drawings.HealthBarBG.Visible = true

            drawings.HealthBar.From = Vector2.new(barX, barHealthY)
            drawings.HealthBar.To = Vector2.new(barX, barBottomY)
            drawings.HealthBar.Color = Color3.fromRGB(
                math.clamp(255 - healthRatio * 255, 0, 255),
                math.clamp(healthRatio * 255, 0, 255),
                0
            )
            drawings.HealthBar.Visible = true
        else
            drawings.Health.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBarBG.Visible = false
        end

        -- Role
        if Config.ESP.ShowRole then
            drawings.Role.Text = "[" .. role .. "]"
            drawings.Role.Position = Vector2.new(bbox.Center.X, bbox.TopLeft.Y - 34)
            drawings.Role.Color = roleColor
            drawings.Role.Visible = true
        else
            drawings.Role.Visible = false
        end
    end
end

function ESP.RemoveESPForPlayer(player)
    if ESP._drawings[player] then
        for _, d in pairs(ESP._drawings[player]) do
            pcall(function() d:Remove() end)
        end
        ESP._drawings[player] = nil
    end
end

function ESP.Init()
    -- Buat ESP untuk semua player yang ada
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP.CreateESPForPlayer(player)
        end
    end

    -- Player baru masuk
    Cleanup.AddConnection(Players.PlayerAdded:Connect(function(player)
        ESP.CreateESPForPlayer(player)
    end))

    -- Player keluar
    Cleanup.AddConnection(Players.PlayerRemoving:Connect(function(player)
        ESP.RemoveESPForPlayer(player)
    end))

    -- Update loop
    ESP._connection = RunService.RenderStepped:Connect(function()
        ESP.UpdateESP()
    end)
    Cleanup.AddConnection(ESP._connection)
end

-- ============================================================
-- MODULE: TELEPORT SAFETY
-- ============================================================
local TeleportSafety = {}
TeleportSafety._connection = nil
TeleportSafety._status = "STANDBY"

function TeleportSafety.GetNearestKiller()
    local myPos = Utilities.GetCharacterPosition(LocalPlayer)
    if not myPos then return nil, math.huge end

    local nearestPlayer = nil
    local nearestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = Utilities.GetPlayerRole(player)
            if role == "Killer" then
                local pos = Utilities.GetCharacterPosition(player)
                if pos then
                    local dist = Utilities.GetDistance(myPos, pos)
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPlayer = player
                    end
                end
            end
        end
    end

    return nearestPlayer, nearestDist
end

function TeleportSafety.Execute()
    if not Config.Teleport.Enabled then return end

    local now = tick()
    if now - Config.Teleport.LastTeleport < Config.Teleport.Cooldown then
        return
    end

    local myPos = Utilities.GetCharacterPosition(LocalPlayer)
    if not myPos then return end

    local killer, dist = TeleportSafety.GetNearestKiller()
    if not killer then
        TeleportSafety._status = "NO KILLER DETECTED"
        return
    end

    if dist <= Config.Teleport.Radius then
        local killerPos = Utilities.GetCharacterPosition(killer)
        if not killerPos then return end

        local safePos = Utilities.FindSafePosition(myPos, killerPos, Config.Teleport.TeleportDistance)

        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(safePos)
                Config.Teleport.LastTeleport = now
                TeleportSafety._status = "TELEPORTED"
                Notification.Send("TELEPORT", "Escaped from " .. killer.DisplayName .. " (dist: " .. Utilities.FormatNumber(dist) .. ")", 3, "warning")

                task.delay(2, function()
                    if TeleportSafety._status == "TELEPORTED" then
                        TeleportSafety._status = "MONITORING"
                    end
                end)
            end
        end
    else
        TeleportSafety._status = "MONITORING [" .. Utilities.FormatNumber(dist) .. " studs]"
    end
end

function TeleportSafety.Init()
    TeleportSafety._connection = RunService.Heartbeat:Connect(function()
        TeleportSafety.Execute()
    end)
    Cleanup.AddConnection(TeleportSafety._connection)
end

-- ============================================================
-- MODULE: SPEED
-- ============================================================
local Speed = {}

function Speed.Set(value)
    Config.Speed.Value = math.clamp(value, 1, 10)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Config.Speed.DefaultWalkSpeed * Config.Speed.Value
        end
    end
end

function Speed.Init()
    -- Ketika karakter respawn, terapkan kembali speed
    Cleanup.AddConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if hum and Config.Speed.Value > 1 then
            task.wait(0.5)
            hum.WalkSpeed = Config.Speed.DefaultWalkSpeed * Config.Speed.Value
        end
    end))
end

-- ============================================================
-- MODULE: POV CIRCLE (Drawing-based crosshair yang mengikuti target)
-- ============================================================
local POV = {}
POV._circle = nil
POV._connection = nil
POV._cameraConnection = nil

function POV.CreateCircle()
    if POV._circle then
        pcall(function() POV._circle:Remove() end)
    end

    POV._circle = Drawing.new("Circle")
    POV._circle.Thickness = Config.POV.Thickness
    POV._circle.Color = Config.POV.Color
    POV._circle.Filled = false
    POV._circle.NumSides = 64
    POV._circle.Radius = Config.POV.Radius
    POV._circle.Transparency = Config.POV.Opacity
    POV._circle.Visible = false

    Cleanup.AddDrawing(POV._circle)
end

function POV.Update()
    if not POV._circle then return end
    if not Config.POV.Enabled then
        POV._circle.Visible = false
        return
    end

    -- Jika ada target player dan follow camera aktif
    if Config.POV.FollowCamera and Config.POV.TargetPlayer then
        local targetPos = Utilities.GetCharacterPosition(Config.POV.TargetPlayer)
        if targetPos then
            local screenPos, onScreen = Utilities.WorldToScreen(targetPos)
            if onScreen then
                POV._circle.Position = screenPos
                POV._circle.Visible = true
            else
                POV._circle.Visible = false
            end
        else
            POV._circle.Visible = false
        end
    else
        -- Default: tengah layar
        local viewport = Camera.ViewportSize
        POV._circle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        POV._circle.Visible = true
    end

    POV._circle.Radius = Config.POV.Radius
    POV._circle.Thickness = Config.POV.Thickness
    POV._circle.Color = Config.POV.Color
    POV._circle.Transparency = Config.POV.Opacity
end

function POV.FollowTarget()
    -- Kamera mengikuti target survivor
    if not Config.POV.FollowCamera then return end
    if not Config.POV.TargetPlayer then return end

    local targetPos = Utilities.GetCharacterPosition(Config.POV.TargetPlayer)
    if targetPos then
        -- Smooth camera follow
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        Camera.CFrame = currentCF:Lerp(targetCF, 0.1)
    end
end

function POV.Init()
    POV.CreateCircle()

    POV._connection = RunService.RenderStepped:Connect(function()
        POV.Update()
        if Config.POV.FollowCamera and Config.POV.TargetPlayer then
            POV.FollowTarget()
        end
    end)
    Cleanup.AddConnection(POV._connection)
end

-- ============================================================
-- MODULE: ON POINT
-- ============================================================
local OnPoint = {}
OnPoint._indicators = {}
OnPoint._connection = nil

function OnPoint.Update()
    if not Config.OnPoint.Enabled then
        -- Sembunyikan semua indicator
        for _, indicator in pairs(OnPoint._indicators) do
            indicator.Circle.Visible = false
            indicator.Line1.Visible = false
            indicator.Line2.Visible = false
            indicator.Text.Visible = false
        end
        return
    end

    local viewport = Camera.ViewportSize
    local circleCenter

    -- Tentukan posisi pusat crosshair
    if Config.POV.Enabled and Config.POV.FollowCamera and Config.POV.TargetPlayer then
        local targetPos = Utilities.GetCharacterPosition(Config.POV.TargetPlayer)
        if targetPos then
            local screenPos, onScreen = Utilities.WorldToScreen(targetPos)
            if onScreen then
                circleCenter = screenPos
            else
                circleCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
            end
        else
            circleCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
        end
    else
        circleCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
    end

    local povRadius = Config.POV.Enabled and Config.POV.Radius or Config.OnPoint.Radius

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local role = Utilities.GetPlayerRole(player)
        if role ~= "Survivor" then continue end

        -- Buat indicator jika belum ada
        if not OnPoint._indicators[player] then
            local indicator = {
                Circle = Drawing.new("Circle"),
                Line1 = Drawing.new("Line"),
                Line2 = Drawing.new("Line"),
                Text = Drawing.new("Text"),
            }

            indicator.Circle.Thickness = 2
            indicator.Circle.Filled = false
            indicator.Circle.NumSides = 32
            indicator.Circle.Radius = 18
            indicator.Circle.Visible = false

            indicator.Line1.Thickness = 1
            indicator.Line1.Visible = false

            indicator.Line2.Thickness = 1
            indicator.Line2.Visible = false

            indicator.Text.Size = 12
            indicator.Text.Center = true
            indicator.Text.Outline = true
            indicator.Text.OutlineColor = Color3.new(0, 0, 0)
            indicator.Text.Font = Drawing.Fonts.Monospace
            indicator.Text.Visible = false

            OnPoint._indicators[player] = indicator

            for _, d in pairs(indicator) do
                Cleanup.AddDrawing(d)
            end
        end

        local indicator = OnPoint._indicators[player]
        local playerPos = Utilities.GetCharacterPosition(player)
        if not playerPos then
            indicator.Circle.Visible = false
            indicator.Line1.Visible = false
            indicator.Line2.Visible = false
            indicator.Text.Visible = false
            continue
        end

        local screenPos, onScreen = Utilities.WorldToScreen(playerPos)

        if not onScreen then
            indicator.Circle.Visible = false
            indicator.Line1.Visible = false
            indicator.Line2.Visible = false
            indicator.Text.Visible = false
            continue
        end

        -- Cek apakah target di dalam lingkaran POV
        local distToCenter = (screenPos - circleCenter).Magnitude

        if distToCenter <= povRadius then
            -- Target di dalam lingkaran - tampilkan indicator
            local col = Config.OnPoint.Color
            local trans = 1 - Config.OnPoint.Transparency

            indicator.Circle.Position = screenPos
            indicator.Circle.Color = col
            indicator.Circle.Transparency = trans
            indicator.Circle.Visible = true

            -- Crosshair lines pada target
            indicator.Line1.From = Vector2.new(screenPos.X - 12, screenPos.Y)
            indicator.Line1.To = Vector2.new(screenPos.X + 12, screenPos.Y)
            indicator.Line1.Color = col
            indicator.Line1.Transparency = trans
            indicator.Line1.Visible = true

            indicator.Line2.From = Vector2.new(screenPos.X, screenPos.Y - 12)
            indicator.Line2.To = Vector2.new(screenPos.X, screenPos.Y + 12)
            indicator.Line2.Color = col
            indicator.Line2.Transparency = trans
            indicator.Line2.Visible = true

            -- Distance text
            local myPos = Utilities.GetCharacterPosition(LocalPlayer)
            local d = myPos and Utilities.GetDistance(myPos, playerPos) or 0
            indicator.Text.Text = "[ON POINT] " .. Utilities.FormatNumber(d) .. "s"
            indicator.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 28)
            indicator.Text.Color = col
            indicator.Text.Transparency = trans
            indicator.Text.Visible = true
        else
            indicator.Circle.Visible = false
            indicator.Line1.Visible = false
            indicator.Line2.Visible = false
            indicator.Text.Visible = false
        end
    end
end

function OnPoint.Init()
    OnPoint._connection = RunService.RenderStepped:Connect(function()
        OnPoint.Update()
    end)
    Cleanup.AddConnection(OnPoint._connection)
end

function OnPoint.CleanupPlayer(player)
    if OnPoint._indicators[player] then
        for _, d in pairs(OnPoint._indicators[player]) do
            pcall(function() d:Remove() end)
        end
        OnPoint._indicators[player] = nil
    end
end

-- ============================================================
-- MODULE: UI (Terminal/CMD Style)
-- ============================================================
local UI = {}
UI._gui = nil
UI._mainFrame = nil
UI._contentFrames = {}
UI._isMinimized = false
UI._isOpen = false
UI._toggleButton = nil
UI._currentTab = nil
UI._statusLabels = {}
UI._splashDone = false

-- Helper: buat frame dasar
function UI.CreateFrame(props)
    local frame = Instance.new("Frame")
    frame.Name = props.Name or "Frame"
    frame.Size = props.Size or UDim2.new(0, 100, 0, 100)
    frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = props.Color or Config.Colors.Panel
    frame.BackgroundTransparency = props.Transparency or 0
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = props.ClipDescendants ~= false

    if props.Corner then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.Corner)
        corner.Parent = frame
    end

    if props.Parent then
        frame.Parent = props.Parent
    end

    return frame
end

-- Helper: buat text label terminal style
function UI.CreateLabel(props)
    local label = Instance.new("TextLabel")
    label.Name = props.Name or "Label"
    label.Size = props.Size or UDim2.new(1, 0, 0, 20)
    label.Position = props.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = props.Text or ""
    label.TextColor3 = props.Color or Config.Colors.Text
    label.TextSize = props.TextSize or 13
    label.Font = props.Font or Config.Font
    label.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    label.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    label.TextTruncate = Enum.TextTruncate.AtEnd

    if props.Parent then
        label.Parent = props.Parent
    end

    return label
end

-- Helper: buat tombol terminal style
function UI.CreateButton(props)
    local btn = Instance.new("TextButton")
    btn.Name = props.Name or "Button"
    btn.Size = props.Size or UDim2.new(0, 120, 0, 30)
    btn.Position = props.Position or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = props.Color or Config.Colors.PanelBorder
    btn.BorderSizePixel = 0
    btn.Text = props.Text or "BUTTON"
    btn.TextColor3 = props.TextColor or Config.Colors.Text
    btn.TextSize = props.TextSize or 12
    btn.Font = Config.Font
    btn.AutoButtonColor = false

    if props.Corner then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.Corner)
        corner.Parent = btn
    end

    local stroke = Instance.new("UIStroke")
    stroke.Color = props.StrokeColor or Config.Colors.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn

    -- Hover effect
    btn.MouseEnter:Connect(function()
        Utilities.Tween(btn, 0.2, {BackgroundColor3 = Config.Colors.AccentDim})
        Utilities.Tween(stroke, 0.2, {Color = Config.Colors.Accent})
    end)

    btn.MouseLeave:Connect(function()
        Utilities.Tween(btn, 0.2, {BackgroundColor3 = props.Color or Config.Colors.PanelBorder})
        Utilities.Tween(stroke, 0.2, {Color = props.StrokeColor or Config.Colors.PanelBorder})
    end)

    if props.Parent then
        btn.Parent = props.Parent
    end

    return btn
end

-- Helper: buat toggle switch
function UI.CreateToggle(props)
    local container = Instance.new("Frame")
    container.Name = props.Name or "Toggle"
    container.Size = props.Size or UDim2.new(1, -20, 0, 32)
    container.Position = props.Position or UDim2.new(0, 10, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = props.Parent

    local label = UI.CreateLabel({
        Name = "Label",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = props.Text or "Toggle",
        Color = Config.Colors.TextDim,
        TextSize = 12,
        Parent = container,
    })

    local toggleBG = Instance.new("Frame")
    toggleBG.Name = "ToggleBG"
    toggleBG.Size = UDim2.new(0, 40, 0, 18)
    toggleBG.Position = UDim2.new(1, -44, 0.5, -9)
    toggleBG.BackgroundColor3 = Config.Colors.PanelBorder
    toggleBG.BorderSizePixel = 0
    toggleBG.Parent = container

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 9)
    bgCorner.Parent = toggleBG

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Config.Colors.TextDim
    knob.BorderSizePixel = 0
    knob.Parent = toggleBG

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 7)
    knobCorner.Parent = knob

    local isOn = props.Default or false

    local function updateVisual()
        if isOn then
            Utilities.Tween(knob, 0.25, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Config.Colors.Accent})
            Utilities.Tween(toggleBG, 0.25, {BackgroundColor3 = Config.Colors.AccentDim})
            label.TextColor3 = Config.Colors.TextBright
        else
            Utilities.Tween(knob, 0.25, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Config.Colors.TextDim})
            Utilities.Tween(toggleBG, 0.25, {BackgroundColor3 = Config.Colors.PanelBorder})
            label.TextColor3 = Config.Colors.TextDim
        end
    end

    updateVisual()

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = container

    clickBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateVisual()
        if props.Callback then
            props.Callback(isOn)
        end
    end)

    return container, function() return isOn end, function(val)
        isOn = val
        updateVisual()
    end
end

-- Helper: buat slider
function UI.CreateSlider(props)
    local container = Instance.new("Frame")
    container.Name = props.Name or "Slider"
    container.Size = props.Size or UDim2.new(1, -20, 0, 50)
    container.Position = props.Position or UDim2.new(0, 10, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = props.Parent

    local min = props.Min or 0
    local max = props.Max or 100
    local default = props.Default or min
    local currentValue = default

    -- Label dan value
    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 18)
    topRow.BackgroundTransparency = 1
    topRow.Parent = container

    local label = UI.CreateLabel({
        Size = UDim2.new(0.7, 0, 1, 0),
        Text = props.Text or "Slider",
        Color = Config.Colors.TextDim,
        TextSize = 12,
        Parent = topRow,
    })

    local valueLabel = UI.CreateLabel({
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        Text = tostring(currentValue),
        Color = Config.Colors.Accent,
        TextSize = 12,
        XAlign = Enum.TextXAlignment.Right,
        Parent = topRow,
    })

    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Config.Colors.PanelBorder
    track.BorderSizePixel = 0
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track

    -- Fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Config.Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    -- Knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Config.Colors.AccentGlow
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 7)
    knobCorner.Parent = knob

    -- Input handling
    local dragging = false

    local inputBtn = Instance.new("TextButton")
    inputBtn.Size = UDim2.new(1, 0, 0, 20)
    inputBtn.Position = UDim2.new(0, 0, 0, 22)
    inputBtn.BackgroundTransparency = 1
    inputBtn.Text = ""
    inputBtn.Parent = container

    local function updateSlider(inputX)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local relative = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)

        if props.Step then
            local steps = (max - min) / props.Step
            relative = math.round(relative * steps) / steps
        end

        currentValue = math.floor(min + (max - min) * relative + 0.5)
        currentValue = math.clamp(currentValue, min, max)

        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, -7, 0.5, -7)
        valueLabel.Text = tostring(currentValue)

        if props.Callback then
            props.Callback(currentValue)
        end
    end

    inputBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)

    Cleanup.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end))

    Cleanup.AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    inputBtn.MouseButton1Click:Connect(function()
        -- Single click juga update
        local mouse = LocalPlayer:GetMouse()
        updateSlider(mouse.X)
    end)

    return container, function() return currentValue end
end

-- Helper: buat dropdown player selector
function UI.CreatePlayerDropdown(props)
    local container = Instance.new("Frame")
    container.Name = props.Name or "Dropdown"
    container.Size = props.Size or UDim2.new(1, -20, 0, 32)
    container.Position = props.Position or UDim2.new(0, 10, 0, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.Parent = props.Parent

    local label = UI.CreateLabel({
        Size = UDim2.new(0.4, 0, 1, 0),
        Text = props.Text or "Target",
        Color = Config.Colors.TextDim,
        TextSize = 12,
        Parent = container,
    })

    local dropBtn = Instance.new("TextButton")
    dropBtn.Name = "DropButton"
    dropBtn.Size = UDim2.new(0.55, 0, 0, 26)
    dropBtn.Position = UDim2.new(0.42, 0, 0.5, -13)
    dropBtn.BackgroundColor3 = Config.Colors.PanelBorder
    dropBtn.BorderSizePixel = 0
    dropBtn.Text = "  > SELECT TARGET"
    dropBtn.TextColor3 = Config.Colors.TextDim
    dropBtn.TextSize = 11
    dropBtn.Font = Config.Font
    dropBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropBtn.AutoButtonColor = false
    dropBtn.Parent = container

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 3)
    dropCorner.Parent = dropBtn

    local dropStroke = Instance.new("UIStroke")
    dropStroke.Color = Config.Colors.PanelBorder
    dropStroke.Thickness = 1
    dropStroke.Parent = dropBtn

    -- Dropdown list
    local dropList = Instance.new("ScrollingFrame")
    dropList.Name = "DropList"
    dropList.Size = UDim2.new(1, 0, 0, 0)
    dropList.Position = UDim2.new(0, 0, 1, 2)
    dropList.BackgroundColor3 = Config.Colors.Background
    dropList.BorderSizePixel = 0
    dropList.Visible = false
    dropList.ZIndex = 10
    dropList.ScrollBarThickness = 3
    dropList.ScrollBarImageColor3 = Config.Colors.Accent
    dropList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropList.ClipsDescendants = true
    dropList.Parent = dropBtn

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 3)
    listCorner.Parent = dropList

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Config.Colors.AccentDim
    listStroke.Thickness = 1
    listStroke.Parent = dropList

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 1)
    listLayout.Parent = dropList

    local isOpen = false
    local selectedPlayer = nil

    local function refreshList()
        for _, child in ipairs(dropList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local playerCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if props.RoleFilter then
                local role = Utilities.GetPlayerRole(player)
                if role ~= props.RoleFilter then continue end
            end

            playerCount = playerCount + 1
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 24)
            itemBtn.BackgroundColor3 = Config.Colors.Panel
            itemBtn.BorderSizePixel = 0
            itemBtn.Text = "  " .. player.DisplayName
            itemBtn.TextColor3 = Utilities.GetRoleColor(Utilities.GetPlayerRole(player))
            itemBtn.TextSize = 11
            itemBtn.Font = Config.Font
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.AutoButtonColor = false
            itemBtn.ZIndex = 11
            itemBtn.Parent = dropList

            itemBtn.MouseEnter:Connect(function()
                Utilities.Tween(itemBtn, 0.15, {BackgroundColor3 = Config.Colors.AccentDim})
            end)
            itemBtn.MouseLeave:Connect(function()
                Utilities.Tween(itemBtn, 0.15, {BackgroundColor3 = Config.Colors.Panel})
            end)

            itemBtn.MouseButton1Click:Connect(function()
                selectedPlayer = player
                dropBtn.Text = "  > " .. player.DisplayName
                dropBtn.TextColor3 = Utilities.GetRoleColor(Utilities.GetPlayerRole(player))
                isOpen = false
                Utilities.Tween(dropList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                task.delay(0.2, function()
                    dropList.Visible = false
                end)
                if props.Callback then
                    props.Callback(player)
                end
            end)
        end

        dropList.CanvasSize = UDim2.new(0, 0, 0, playerCount * 25)
    end

    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            refreshList()
            dropList.Visible = true
            local count = #dropList:GetChildren() - 2
            local height = math.min(count * 25, 150)
            Utilities.Tween(dropList, 0.2, {Size = UDim2.new(1, 0, 0, height)})
        else
            Utilities.Tween(dropList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
            task.delay(0.2, function()
                dropList.Visible = false
            end)
        end
    end)

    return container, function() return selectedPlayer end
end

-- ============================================
-- Membangun UI utama
-- ============================================
function UI.Build()
    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "HoshiDev"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999

    -- Coba parent ke CoreGui, fallback ke PlayerGui
    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    UI._gui = gui
    Cleanup.AddInstance(gui)

    -- Notification init
    Notification.Init(gui)

    -- ============================================
    -- TOGGLE BUTTON (Icon "H")
    -- ============================================
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "HoshiToggle"
    toggleBtn.Size = UDim2.new(0, 42, 0, 42)
    toggleBtn.Position = UDim2.new(0, 14, 0.5, -21)
    toggleBtn.BackgroundColor3 = Config.Colors.Background
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "H"
    toggleBtn.TextColor3 = Config.Colors.Accent
    toggleBtn.TextSize = 22
    toggleBtn.Font = Config.FontBold
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 100
    toggleBtn.Parent = gui

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Config.Colors.Accent
    toggleStroke.Thickness = 1.5
    toggleStroke.Transparency = 0.3
    toggleStroke.Parent = toggleBtn

    -- Toggle glow animation loop
    task.spawn(function()
        while gui.Parent do
            Utilities.Tween(toggleStroke, 1.5, {Transparency = 0.7})
            task.wait(1.5)
            Utilities.Tween(toggleStroke, 1.5, {Transparency = 0.2})
            task.wait(1.5)
        end
    end)

    -- Toggle draggable
    local toggleDragging = false
    local toggleDragStart = nil
    local toggleStartPos = nil

    toggleBtn.MouseButton1Down:Connect(function()
        toggleDragging = true
        toggleDragStart = UserInputService:GetMouseLocation()
        toggleStartPos = toggleBtn.Position
    end)

    Cleanup.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if toggleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = mousePos - toggleDragStart
            toggleBtn.Position = UDim2.new(
                toggleStartPos.X.Scale,
                toggleStartPos.X.Offset + delta.X,
                toggleStartPos.Y.Scale,
                toggleStartPos.Y.Offset + delta.Y
            )
        end
    end))

    Cleanup.AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if toggleDragging then
                local mousePos = UserInputService:GetMouseLocation()
                local delta = mousePos - (toggleDragStart or mousePos)
                if delta.Magnitude < 5 then
                    -- Ini adalah click, bukan drag
                    UI.ToggleWindow()
                end
                toggleDragging = false
            end
        end
    end))

    UI._toggleButton = toggleBtn

    -- ============================================
    -- MAIN WINDOW
    -- ============================================
    local mainFrame = UI.CreateFrame({
        Name = "MainWindow",
        Size = Config.DefaultWindowSize,
        Position = Config.DefaultWindowPos,
        Color = Config.Colors.Background,
        Corner = 6,
        Parent = gui,
    })
    mainFrame.Visible = false
    mainFrame.BackgroundTransparency = 1

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Config.Colors.PanelBorder
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainFrame

    UI._mainFrame = mainFrame

    -- ============================================
    -- TITLE BAR
    -- ============================================
    local titleBar = UI.CreateFrame({
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 34),
        Color = Config.Colors.Panel,
        Parent = mainFrame,
    })

    -- Draggable title bar
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    Cleanup.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end))

    Cleanup.AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    -- Title text
    local titleText = UI.CreateLabel({
        Name = "Title",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = "HOSHI v" .. Config.Version .. " // ADMIN DEVELOPMENT TOOLS",
        Color = Config.Colors.Accent,
        TextSize = 12,
        Parent = titleBar,
    })

    -- Status indicator (blinking dot)
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 340, 0.5, -4)
    statusDot.BackgroundColor3 = Config.Colors.Green
    statusDot.BorderSizePixel = 0
    statusDot.Parent = titleBar

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot

    -- Blinking animation
    task.spawn(function()
        while gui.Parent do
            Utilities.Tween(statusDot, 0.8, {BackgroundTransparency = 0.6})
            task.wait(0.8)
            Utilities.Tween(statusDot, 0.8, {BackgroundTransparency = 0})
            task.wait(0.8)
        end
    end)

    local statusText = UI.CreateLabel({
        Name = "StatusText",
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, 354, 0, 0),
        Text = "ACTIVE",
        Color = Config.Colors.Green,
        TextSize = 10,
        Parent = titleBar,
    })

    -- Window controls (minimize, resize, close)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 90, 1, 0)
    controlsFrame.Position = UDim2.new(1, -94, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 26, 0, 22)
    minBtn.Position = UDim2.new(0, 0, 0.5, -11)
    minBtn.BackgroundColor3 = Config.Colors.PanelBorder
    minBtn.BorderSizePixel = 0
    minBtn.Text = "_"
    minBtn.TextColor3 = Config.Colors.TextDim
    minBtn.TextSize = 14
    minBtn.Font = Config.Font
    minBtn.AutoButtonColor = false
    minBtn.Parent = controlsFrame

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 3)
    minCorner.Parent = minBtn

    minBtn.MouseEnter:Connect(function()
        Utilities.Tween(minBtn, 0.15, {BackgroundColor3 = Config.Colors.Yellow, TextColor3 = Config.Colors.Background})
    end)
    minBtn.MouseLeave:Connect(function()
        Utilities.Tween(minBtn, 0.15, {BackgroundColor3 = Config.Colors.PanelBorder, TextColor3 = Config.Colors.TextDim})
    end)
    minBtn.MouseButton1Click:Connect(function()
        UI.MinimizeWindow()
    end)

    -- Resize button
    local resizeBtn = Instance.new("TextButton")
    resizeBtn.Size = UDim2.new(0, 26, 0, 22)
    resizeBtn.Position = UDim2.new(0, 30, 0.5, -11)
    resizeBtn.BackgroundColor3 = Config.Colors.PanelBorder
    resizeBtn.BorderSizePixel = 0
    resizeBtn.Text = "[]"
    resizeBtn.TextColor3 = Config.Colors.TextDim
    resizeBtn.TextSize = 11
    resizeBtn.Font = Config.Font
    resizeBtn.AutoButtonColor = false
    resizeBtn.Parent = controlsFrame

    local resCorner = Instance.new("UICorner")
    resCorner.CornerRadius = UDim.new(0, 3)
    resCorner.Parent = resizeBtn

    local isMaximized = false
    local storedSize = Config.DefaultWindowSize
    local storedPos = Config.DefaultWindowPos

    resizeBtn.MouseEnter:Connect(function()
        Utilities.Tween(resizeBtn, 0.15, {BackgroundColor3 = Config.Colors.Green, TextColor3 = Config.Colors.Background})
    end)
    resizeBtn.MouseLeave:Connect(function()
        Utilities.Tween(resizeBtn, 0.15, {BackgroundColor3 = Config.Colors.PanelBorder, TextColor3 = Config.Colors.TextDim})
    end)
    resizeBtn.MouseButton1Click:Connect(function()
        if isMaximized then
            Utilities.Tween(mainFrame, 0.3, {Size = storedSize, Position = storedPos})
            isMaximized = false
        else
            storedSize = mainFrame.Size
            storedPos = mainFrame.Position
            Utilities.Tween(mainFrame, 0.3, {Size = Config.MaxWindowSize, Position = UDim2.new(0.5, -450, 0.5, -310)})
            isMaximized = true
        end
    end)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 22)
    closeBtn.Position = UDim2.new(0, 60, 0.5, -11)
    closeBtn.BackgroundColor3 = Config.Colors.PanelBorder
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Config.Colors.TextDim
    closeBtn.TextSize = 12
    closeBtn.Font = Config.Font
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = controlsFrame

    local clsCorner = Instance.new("UICorner")
    clsCorner.CornerRadius = UDim.new(0, 3)
    clsCorner.Parent = closeBtn

    closeBtn.MouseEnter:Connect(function()
        Utilities.Tween(closeBtn, 0.15, {BackgroundColor3 = Config.Colors.Red, TextColor3 = Color3.new(1,1,1)})
    end)
    closeBtn.MouseLeave:Connect(function()
        Utilities.Tween(closeBtn, 0.15, {BackgroundColor3 = Config.Colors.PanelBorder, TextColor3 = Config.Colors.TextDim})
    end)
    closeBtn.MouseButton1Click:Connect(function()
        UI.CloseWindow()
    end)

    -- ============================================
    -- SIDEBAR
    -- ============================================
    local sidebar = UI.CreateFrame({
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, -34),
        Position = UDim2.new(0, 0, 0, 34),
        Color = Config.Colors.Panel,
        Parent = mainFrame,
    })

    -- Sidebar separator line
    local sidebarLine = Instance.new("Frame")
    sidebarLine.Size = UDim2.new(0, 1, 1, 0)
    sidebarLine.Position = UDim2.new(1, 0, 0, 0)
    sidebarLine.BackgroundColor3 = Config.Colors.PanelBorder
    sidebarLine.BorderSizePixel = 0
    sidebarLine.Parent = sidebar

    -- Terminal prompt di sidebar
    local sidebarHeader = UI.CreateLabel({
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 8, 0, 8),
        Text = "root@hoshi:~$",
        Color = Config.Colors.TerminalGreen,
        TextSize = 10,
        Parent = sidebar,
    })

    -- Sidebar nav buttons
    local tabs = {
        {Name = "ESP", Label = "> ESP"},
        {Name = "Teleport", Label = "> TELEPORT"},
        {Name = "Speed", Label = "> SPEED"},
        {Name = "POV", Label = "> POV"},
        {Name = "OnPoint", Label = "> ON_POINT"},
        {Name = "System", Label = "> SYSTEM"},
    }

    local tabButtons = {}

    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tab.Name
        tabBtn.Size = UDim2.new(1, -12, 0, 28)
        tabBtn.Position = UDim2.new(0, 6, 0, 40 + (i - 1) * 32)
        tabBtn.BackgroundColor3 = Config.Colors.Panel
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tab.Label
        tabBtn.TextColor3 = Config.Colors.TextDim
        tabBtn.TextSize = 12
        tabBtn.Font = Config.Font
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = sidebar

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 3)
        tabCorner.Parent = tabBtn

        -- Active indicator
        local activeBar = Instance.new("Frame")
        activeBar.Name = "ActiveBar"
        activeBar.Size = UDim2.new(0, 2, 0.6, 0)
        activeBar.Position = UDim2.new(0, -1, 0.2, 0)
        activeBar.BackgroundColor3 = Config.Colors.Accent
        activeBar.BackgroundTransparency = 1
        activeBar.BorderSizePixel = 0
        activeBar.Parent = tabBtn

        local barCorner2 = Instance.new("UICorner")
        barCorner2.CornerRadius = UDim.new(0, 1)
        barCorner2.Parent = activeBar

        tabButtons[tab.Name] = {Button = tabBtn, Bar = activeBar}

        tabBtn.MouseEnter:Connect(function()
            if UI._currentTab ~= tab.Name then
                Utilities.Tween(tabBtn, 0.15, {BackgroundTransparency = 0.5, TextColor3 = Config.Colors.TextBright})
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if UI._currentTab ~= tab.Name then
                Utilities.Tween(tabBtn, 0.15, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDim})
            end
        end)

        tabBtn.MouseButton1Click:Connect(function()
            UI.SwitchTab(tab.Name)
        end)
    end

    UI._tabButtons = tabButtons

    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local contentArea = UI.CreateFrame({
        Name = "ContentArea",
        Size = UDim2.new(1, -142, 1, -36),
        Position = UDim2.new(0, 142, 0, 36),
        Color = Config.Colors.Background,
        Transparency = 0,
        Parent = mainFrame,
    })

    -- ============================================
    -- TAB: ESP
    -- ============================================
    local espTab = UI.CreateFrame({
        Name = "ESPTab",
        Size = UDim2.new(1, 0, 1, 0),
        Color = Config.Colors.Background,
        Transparency = 1,
        Parent = contentArea,
    })
    espTab.Visible = false

    local espScroll = Instance.new("ScrollingFrame")
    espScroll.Size = UDim2.new(1, 0, 1, 0)
    espScroll.BackgroundTransparency = 1
    espScroll.BorderSizePixel = 0
    espScroll.ScrollBarThickness = 3
    espScroll.ScrollBarImageColor3 = Config.Colors.Accent
    espScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
    espScroll.Parent = espTab

    local espLayout = Instance.new("UIListLayout")
    espLayout.SortOrder = Enum.SortOrder.LayoutOrder
    espLayout.Padding = UDim.new(0, 4)
    espLayout.Parent = espScroll

    local espPadding = Instance.new("UIPadding")
    espPadding.PaddingTop = UDim.new(0, 8)
    espPadding.PaddingLeft = UDim.new(0, 8)
    espPadding.PaddingRight = UDim.new(0, 8)
    espPadding.Parent = espScroll

    -- Header
    UI.CreateLabel({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        Text = "-- ESP PLAYER MODULE --",
        Color = Config.Colors.AccentDim,
        TextSize = 11,
        Parent = espScroll,
    })

    UI.CreateToggle({
        Name = "ESPToggle",
        Text = "ESP Enabled",
        Default = Config.ESP.Enabled,
        Parent = espScroll,
        Callback = function(val)
            Config.ESP.Enabled = val
            Notification.Send("ESP", val and "ESP enabled" or "ESP disabled", 2, val and "success" or "info")
        end,
    })

    UI.CreateToggle({
        Name = "BoxToggle",
        Text = "Box ESP",
        Default = Config.ESP.ShowBox,
        Parent = espScroll,
        Callback = function(val) Config.ESP.ShowBox = val end,
    })

    UI.CreateToggle({
        Name = "NameToggle",
        Text = "Name ESP",
        Default = Config.ESP.ShowName,
        Parent = espScroll,
        Callback = function(val) Config.ESP.ShowName = val end,
    })

    UI.CreateToggle({
        Name = "DistToggle",
        Text = "Distance",
        Default = Config.ESP.ShowDistance,
        Parent = espScroll,
        Callback = function(val) Config.ESP.ShowDistance = val end,
    })

    UI.CreateToggle({
        Name = "HealthToggle",
        Text = "Health",
        Default = Config.ESP.ShowHealth,
        Parent = espScroll,
        Callback = function(val) Config.ESP.ShowHealth = val end,
    })

    UI.CreateToggle({
        Name = "RoleToggle",
        Text = "Role",
        Default = Config.ESP.ShowRole,
        Parent = espScroll,
        Callback = function(val) Config.ESP.ShowRole = val end,
    })

    UI._contentFrames["ESP"] = espTab

    -- ============================================
    -- TAB: TELEPORT
    -- ============================================
    local teleportTab = UI.CreateFrame({
        Name = "TeleportTab",
        Size = UDim2.new(1, 0, 1, 0),
        Color = Config.Colors.Background,
        Transparency = 1,
        Parent = contentArea,
    })
    teleportTab.Visible = false

    local tpScroll = Instance.new("ScrollingFrame")
    tpScroll.Size = UDim2.new(1, 0, 1, 0)
    tpScroll.BackgroundTransparency = 1
    tpScroll.BorderSizePixel = 0
    tpScroll.ScrollBarThickness = 3
    tpScroll.ScrollBarImageColor3 = Config.Colors.Accent
    tpScroll.CanvasSize = UDim2.new(0, 0, 0, 320)
    tpScroll.Parent = teleportTab

    local tpLayout = Instance.new("UIListLayout")
    tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tpLayout.Padding = UDim.new(0, 4)
    tpLayout.Parent = tpScroll

    local tpPadding = Instance.new("UIPadding")
    tpPadding.PaddingTop = UDim.new(0, 8)
    tpPadding.PaddingLeft = UDim.new(0, 8)
    tpPadding.PaddingRight = UDim.new(0, 8)
    tpPadding.Parent = tpScroll

    UI.CreateLabel({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        Text = "-- TELEPORT SAFETY MODULE --",
        Color = Config.Colors.AccentDim,
        TextSize = 11,
        Parent = tpScroll,
    })

    UI.CreateToggle({
        Name = "TPToggle",
        Text = "Teleport Safety Enabled",
        Default = Config.Teleport.Enabled,
        Parent = tpScroll,
        Callback = function(val)
            Config.Teleport.Enabled = val
            TeleportSafety._status = val and "MONITORING" or "STANDBY"
            Notification.Send("TELEPORT", val and "Safety enabled" or "Safety disabled", 2, val and "success" or "info")
        end,
    })

    UI.CreateSlider({
        Name = "RadiusSlider",
        Text = "Detection Radius",
        Min = 10,
        Max = 100,
        Default = Config.Teleport.Radius,
        Step = 5,
        Parent = tpScroll,
        Callback = function(val) Config.Teleport.Radius = val end,
    })

    UI.CreateSlider({
        Name = "TPDistSlider",
        Text = "Teleport Distance",
        Min = 50,
        Max = 200,
        Default = Config.Teleport.TeleportDistance,
        Step = 10,
        Parent = tpScroll,
        Callback = function(val) Config.Teleport.TeleportDistance = val end,
    })

    UI.CreateSlider({
        Name = "CooldownSlider",
        Text = "Cooldown (sec)",
        Min = 1,
        Max = 15,
        Default = Config.Teleport.Cooldown,
        Step = 1,
        Parent = tpScroll,
        Callback = function(val) Config.Teleport.Cooldown = val end,
    })

    -- Status display
    local tpStatusFrame = UI.CreateFrame({
        Name = "StatusFrame",
        Size = UDim2.new(1, -20, 0, 36),
        Color = Config.Colors.Panel,
        Corner = 4,
        Parent = tpScroll,
    })

    local tpStatusStroke = Instance.new("UIStroke")
    tpStatusStroke.Color = Config.Colors.PanelBorder
    tpStatusStroke.Thickness = 1
    tpStatusStroke.Parent = tpStatusFrame

    local tpStatusLabel = UI.CreateLabel({
        Name = "Status",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = "STATUS: STANDBY",
        Color = Config.Colors.TextDim,
        TextSize = 11,
        Parent = tpStatusFrame,
    })
    UI._statusLabels["teleport"] = tpStatusLabel

    UI._contentFrames["Teleport"] = teleportTab

    -- ============================================
    -- TAB: SPEED
    -- ============================================
    local speedTab = UI.CreateFrame({
        Name = "SpeedTab",
        Size = UDim2.new(1, 0, 1, 0),
        Color = Config.Colors.Background,
        Transparency = 1,
        Parent = contentArea,
    })
    speedTab.Visible = false

    local speedScroll = Instance.new("ScrollingFrame")
    speedScroll.Size = UDim2.new(1, 0, 1, 0)
    speedScroll.BackgroundTransparency = 1
    speedScroll.BorderSizePixel = 0
    speedScroll.ScrollBarThickness = 3
    speedScroll.ScrollBarImageColor3 = Config.Colors.Accent
    speedScroll.CanvasSize = UDim2.new(0, 0, 0, 220)
    speedScroll.Parent = speedTab

    local speedLayout = Instance.new("UIListLayout")
    speedLayout.SortOrder = Enum.SortOrder.LayoutOrder
    speedLayout.Padding = UDim.new(0, 4)
    speedLayout.Parent = speedScroll

    local speedPadding = Instance.new("UIPadding")
    speedPadding.PaddingTop = UDim.new(0, 8)
    speedPadding.PaddingLeft = UDim.new(0, 8)
    speedPadding.PaddingRight = UDim.new(0, 8)
    speedPadding.Parent = speedScroll

    UI.CreateLabel({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        Text = "-- SPEED RUN MODULE --",
        Color = Config.Colors.AccentDim,
        TextSize = 11,
        Parent = speedScroll,
    })

    UI.CreateSlider({
        Name = "SpeedSlider",
        Text = "Speed Multiplier",
        Min = 1,
        Max = 10,
        Default = Config.Speed.Value,
        Step = 1,
        Parent = speedScroll,
        Callback = function(val)
            Speed.Set(val)
        end,
    })

    -- Speed input box
    local speedInputFrame = Instance.new("Frame")
    speedInputFrame.Size = UDim2.new(1, -20, 0, 36)
    speedInputFrame.BackgroundTransparency = 1
    speedInputFrame.Parent = speedScroll

    UI.CreateLabel({
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = "Manual Input (1-10)",
        Color = Config.Colors.TextDim,
        TextSize = 12,
        Parent = speedInputFrame,
    })

    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0, 80, 0, 28)
    speedInput.Position = UDim2.new(1, -84, 0.5, -14)
    speedInput.BackgroundColor3 = Config.Colors.PanelBorder
    speedInput.BorderSizePixel = 0
    speedInput.Text = tostring(Config.Speed.Value)
    speedInput.TextColor3 = Config.Colors.Accent
    speedInput.PlaceholderText = "1-10"
    speedInput.PlaceholderColor3 = Config.Colors.TextDim
    speedInput.TextSize = 13
    speedInput.Font = Config.Font
    speedInput.ClearTextOnFocus = true
    speedInput.Parent = speedInputFrame

    local speedInputCorner = Instance.new("UICorner")
    speedInputCorner.CornerRadius = UDim.new(0, 3)
    speedInputCorner.Parent = speedInput

    local speedInputStroke = Instance.new("UIStroke")
    speedInputStroke.Color = Config.Colors.PanelBorder
    speedInputStroke.Thickness = 1
    speedInputStroke.Parent = speedInput

    speedInput.FocusLost:Connect(function()
        local val = tonumber(speedInput.Text)
        if val then
            val = math.clamp(math.floor(val), 1, 10)
            Speed.Set(val)
            speedInput.Text = tostring(val)
            Notification.Send("SPEED", "Speed set to x" .. val, 2, "success")
        else
            speedInput.Text = tostring(Config.Speed.Value)
        end
    end)

    -- Speed status
    local speedStatusFrame = UI.CreateFrame({
        Name = "SpeedStatus",
        Size = UDim2.new(1, -20, 0, 36),
        Color = Config.Colors.Panel,
        Corner = 4,
        Parent = speedScroll,
    })

    local speedStatusStroke = Instance.new("UIStroke")
    speedStatusStroke.Color = Config.Colors.PanelBorder
    speedStatusStroke.Thickness = 1
    speedStatusStroke.Parent = speedStatusFrame

    local speedStatusLabel = UI.CreateLabel({
        Name = "SpeedStatus",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = "CURRENT SPEED: " .. Config.Speed.DefaultWalkSpeed .. " (x1)",
        Color = Config.Colors.TextDim,
        TextSize = 11,
        Parent = speedStatusFrame,
    })
    UI._statusLabels["speed"] = speedStatusLabel

    UI._contentFrames["Speed"] = speedTab

    -- ============================================
    -- TAB: POV
    -- ============================================
    local povTab = UI.CreateFrame({
        Name = "POVTab",
        Size = UDim2.new(1, 0, 1, 0),
        Color = Config.Colors.Background,
        Transparency = 1,
        Parent = contentArea,
    })
    povTab.Visible = false

    local povScroll = Instance.new("ScrollingFrame")
    povScroll.Size = UDim2.new(1, 0, 1, 0)
    povScroll.BackgroundTransparency = 1
    povScroll.BorderSizePixel = 0
    povScroll.ScrollBarThickness = 3
    povScroll.ScrollBarImageColor3 = Config.Colors.Accent
    povScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    povScroll.Parent = povTab

    local povLayout = Instance.new("UIListLayout")
    povLayout.SortOrder = Enum.SortOrder.LayoutOrder
    povLayout.Padding = UDim.new(0, 4)
    povLayout.Parent = povScroll

    local povPadding = Instance.new("UIPadding")
    povPadding.PaddingTop = UDim.new(0, 8)
    povPadding.PaddingLeft = UDim.new(0, 8)
    povPadding.PaddingRight = UDim.new(0, 8)
    povPadding.Parent = povScroll

    UI.CreateLabel({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        Text = "-- POV CIRCLE MODULE --",
        Color = Config.Colors.AccentDim,
        TextSize = 11,
        Parent = povScroll,
    })

    UI.CreateToggle({
        Name = "POVToggle",
        Text = "POV Circle Enabled",
        Default = Config.POV.Enabled,
        Parent = povScroll,
        Callback = function(val)
            Config.POV.Enabled = val
            Notification.Send("POV", val and "Circle enabled" or "Circle disabled", 2, val and "success" or "info")
        end,
    })

    UI.CreateToggle({
        Name = "FollowToggle",
        Text = "Camera Follow Target",
        Default = Config.POV.FollowCamera,
        Parent = povScroll,
        Callback = function(val)
            Config.POV.FollowCamera = val
        end,
    })

    UI.CreatePlayerDropdown({
        Name = "POVTarget",
        Text = "Target Player",
        RoleFilter = "Survivor",
        Parent = povScroll,
        Callback = function(player)
            Config.POV.TargetPlayer = player
            Notification.Send("POV", "Target: " .. player.DisplayName, 2, "info")
        end,
    })

    UI.CreateSlider({
        Name = "POVRadius",
        Text = "Circle Radius",
        Min = 20,
        Max = 300,
        Default = Config.POV.Radius,
        Step = 5,
        Parent = povScroll,
        Callback = function(val) Config.POV.Radius = val end,
    })

    UI.CreateSlider({
        Name = "POVThickness",
        Text = "Thickness",
        Min = 1,
        Max = 8,
        Default = Config.POV.Thickness,
        Step = 1,
        Parent = povScroll,
        Callback = function(val) Config.POV.Thickness = val end,
    })

    UI.CreateSlider({
        Name = "POVOpacity",
        Text = "Opacity (%)",
        Min = 10,
        Max = 100,
        Default = Config.POV.Opacity * 100,
        Step = 5,
        Parent = povScroll,
        Callback = function(val) Config.POV.Opacity = val / 100 end,
    })

    UI._contentFrames["POV"] = povTab

    -- ============================================
    -- TAB: ON POINT
    -- ============================================
    local onPointTab = UI.CreateFrame({
        Name = "OnPointTab",
        Size = UDim2.new(1, 0, 1, 0),
        Color = Config.Colors.Background,
        Transparency = 1,
        Parent = contentArea,
    })
    onPointTab.Visible = false

    local opScroll = Instance.new("ScrollingFrame")
    opScroll.Size = UDim2.new(1, 0, 1, 0)
    opScroll.BackgroundTransparency = 1
    opScroll.BorderSizePixel = 0
    opScroll.ScrollBarThickness = 3
    opScroll.ScrollBarImageColor3 = Config.Colors.Accent
    opScroll.CanvasSize = UDim2.new(0, 0, 0, 320)
    opScroll.Parent = onPointTab

    local opLayout = Instance.new("UIListLayout")
    opLayout.SortOrder = Enum.SortOrder.LayoutOrder
    opLayout.Padding = UDim.new(0, 4)
    opLayout.Parent = opScroll

    local opPadding = Instance.new("UIPadding")
    opPadding.PaddingTop = UDim.new(0, 8)
    opPadding.PaddingLeft = UDim.new(0, 8)
    opPadding.PaddingRight = UDim.new(0, 8)
    opPadding.Parent = opScroll

    UI.CreateLabel({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        Text = "-- ON POINT MODULE --",
        Color = Config.Colors.AccentDim,
        TextSize = 11,
        Parent = opScroll,
    })

    UI.CreateToggle({
        Name = "OPToggle",
        Text = "On Point Enabled",
        Default = Config.OnPoint.Enabled,
        Parent = opScroll,
        Callback = function(val)
            Config.OnPoint.Enabled = val
            Notification.Send("ON POINT", val and "Indicator enabled" or "Indicator disabled", 2, val and "success" or "info")
        end,
    })

    UI.CreateSlider({
        Name = "OPRadius",
        Text = "Indicator Radius",
        Min = 20,
        Max = 200,
        Default = Config.OnPoint.Radius,
        Step = 5,
        Parent = opScroll,
        Callback = function(val) Config.OnPoint.Radius = val end,
    })

    UI.CreateSlider({
        Name = "OPTransparency",
        Text = "Transparency (%)",
        Min = 10,
        Max = 100,
        Default = Config.OnPoint.Transparency * 100,
        Step = 5,
        Parent = opScroll,
        Callback = function(val) Config.OnPoint.Transparency = val / 100 end,
    })

    UI.CreateToggle({
        Name = "OPSmooth",
        Text = "Smooth Update",
        Default = Config.OnPoint.SmoothUpdate,
        Parent = opScroll,
        Callback = function(val) Config.OnPoint.SmoothUpdate = val end,
    })

    UI._contentFrames["OnPoint"] = onPointTab

    -- ============================================
    -- TAB: SYSTEM
    -- ============================================
    local systemTab = UI.CreateFrame({
        Name = "SystemTab",
        Size = UDim2.new(1, 0, 1, 0),
        Color = Config.Colors.Background,
        Transparency = 1,
        Parent = contentArea,
    })
    systemTab.Visible = false

    local sysScroll = Instance.new("ScrollingFrame")
    sysScroll.Size = UDim2.new(1, 0, 1, 0)
    sysScroll.BackgroundTransparency = 1
    sysScroll.BorderSizePixel = 0
    sysScroll.ScrollBarThickness = 3
    sysScroll.ScrollBarImageColor3 = Config.Colors.Accent
    sysScroll.CanvasSize = UDim2.new(0, 0, 0, 280)
    sysScroll.Parent = systemTab

    local sysLayout = Instance.new("UIListLayout")
    sysLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sysLayout.Padding = UDim.new(0, 4)
    sysLayout.Parent = sysScroll

    local sysPadding = Instance.new("UIPadding")
    sysPadding.PaddingTop = UDim.new(0, 8)
    sysPadding.PaddingLeft = UDim.new(0, 8)
    sysPadding.PaddingRight = UDim.new(0, 8)
    sysPadding.Parent = sysScroll

    UI.CreateLabel({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        Text = "-- SYSTEM INFO --",
        Color = Config.Colors.AccentDim,
        TextSize = 11,
        Parent = sysScroll,
    })

    -- System info labels
    local sysInfoFrame = UI.CreateFrame({
        Name = "SysInfo",
        Size = UDim2.new(1, -20, 0, 140),
        Color = Config.Colors.Panel,
        Corner = 4,
        Parent = sysScroll,
    })

    local sysInfoStroke = Instance.new("UIStroke")
    sysInfoStroke.Color = Config.Colors.PanelBorder
    sysInfoStroke.Thickness = 1
    sysInfoStroke.Parent = sysInfoFrame

    local sysLabels = {}
    local sysTexts = {
        "SCRIPT    : HOSHI v" .. Config.Version,
        "USER      : " .. LocalPlayer.Name,
        "DISPLAY   : " .. LocalPlayer.DisplayName,
        "PLAYER_ID : " .. LocalPlayer.UserId,
        "GAME_ID   : " .. game.PlaceId,
        "SERVER    : " .. game.JobId:sub(1, 16) .. "...",
    }

    for i, text in ipairs(sysTexts) do
        local lbl = UI.CreateLabel({
            Size = UDim2.new(1, -16, 0, 18),
            Position = UDim2.new(0, 8, 0, 6 + (i - 1) * 20),
            Text = text,
            Color = Config.Colors.TextDim,
            TextSize = 11,
            Parent = sysInfoFrame,
        })
        table.insert(sysLabels, lbl)
    end

    -- FPS counter
    local fpsFrame = UI.CreateFrame({
        Name = "FPSFrame",
        Size = UDim2.new(1, -20, 0, 36),
        Color = Config.Colors.Panel,
        Corner = 4,
        Parent = sysScroll,
    })

    local fpsStroke = Instance.new("UIStroke")
    fpsStroke.Color = Config.Colors.PanelBorder
    fpsStroke.Thickness = 1
    fpsStroke.Parent = fpsFrame

    local fpsLabel = UI.CreateLabel({
        Name = "FPS",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = "FPS: ---",
        Color = Config.Colors.Green,
        TextSize = 12,
        Parent = fpsFrame,
    })
    UI._statusLabels["fps"] = fpsLabel

    -- Destroy button
    local destroyBtn = UI.CreateButton({
        Name = "DestroyBtn",
        Size = UDim2.new(1, -20, 0, 32),
        Text = "> DESTROY SCRIPT",
        TextColor = Config.Colors.Red,
        Color = Config.Colors.Panel,
        Corner = 4,
        StrokeColor = Config.Colors.Red,
        Parent = sysScroll,
    })

    destroyBtn.MouseButton1Click:Connect(function()
        Notification.Send("SYSTEM", "Destroying HOSHI...", 2, "error")
        task.wait(1)
        Cleanup.Destroy()
    end)

    UI._contentFrames["System"] = systemTab

    -- ============================================
    -- BOTTOM STATUS BAR
    -- ============================================
    local bottomBar = UI.CreateFrame({
        Name = "BottomBar",
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        Color = Config.Colors.Panel,
        Parent = mainFrame,
    })

    local bottomText = UI.CreateLabel({
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = "HOSHI // READY // " .. os.date("%Y-%m-%d"),
        Color = Config.Colors.TextDim,
        TextSize = 10,
        Parent = bottomBar,
    })
    UI._statusLabels["bottom"] = bottomText

    -- ============================================
    -- WATERMARK (top-right corner of screen)
    -- ============================================
    local watermark = UI.CreateLabel({
        Name = "Watermark",
        Size = UDim2.new(0, 220, 0, 18),
        Position = UDim2.new(1, -225, 0, 5),
        Text = "HOSHI v" .. Config.Version .. " | DEV TOOLS",
        Color = Config.Colors.AccentDim,
        TextSize = 11,
        XAlign = Enum.TextXAlignment.Right,
        Parent = gui,
    })

    -- Watermark pulse
    task.spawn(function()
        while gui.Parent do
            Utilities.Tween(watermark, 2, {TextTransparency = 0.5})
            task.wait(2)
            Utilities.Tween(watermark, 2, {TextTransparency = 0})
            task.wait(2)
        end
    end)

    -- Set default tab
    UI.SwitchTab("ESP")

    -- Return references
    return gui
end

-- Tab switching
function UI.SwitchTab(tabName)
    -- Sembunyikan semua tab
    for name, frame in pairs(UI._contentFrames) do
        frame.Visible = false
    end

    -- Deactivate semua tab button
    for name, data in pairs(UI._tabButtons) do
        Utilities.Tween(data.Button, 0.15, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextDim})
        Utilities.Tween(data.Bar, 0.15, {BackgroundTransparency = 1})
    end

    -- Activate selected tab
    if UI._contentFrames[tabName] then
        UI._contentFrames[tabName].Visible = true
    end

    if UI._tabButtons[tabName] then
        local data = UI._tabButtons[tabName]
        Utilities.Tween(data.Button, 0.2, {BackgroundTransparency = 0.85, TextColor3 = Config.Colors.Accent})
        Utilities.Tween(data.Bar, 0.2, {BackgroundTransparency = 0})
    end

    UI._currentTab = tabName
end

-- Toggle window visibility
function UI.ToggleWindow()
    if not UI._mainFrame then return end

    UI._isOpen = not UI._isOpen

    if UI._isOpen then
        UI._mainFrame.Visible = true
        UI._mainFrame.BackgroundTransparency = 1
        Utilities.Tween(UI._mainFrame, 0.35, {BackgroundTransparency = 0})

        -- Fade in semua children
        for _, child in ipairs(UI._mainFrame:GetDescendants()) do
            if child:IsA("Frame") and child.Name ~= "MainWindow" then
                if child.BackgroundTransparency < 0.5 then
                    child.BackgroundTransparency = 1
                    Utilities.Tween(child, 0.35, {BackgroundTransparency = 0})
                end
            elseif child:IsA("TextLabel") then
                child.TextTransparency = 1
                Utilities.Tween(child, 0.35, {TextTransparency = 0})
            elseif child:IsA("TextButton") then
                child.TextTransparency = 1
                Utilities.Tween(child, 0.35, {TextTransparency = 0})
            end
        end
    else
        Utilities.Tween(UI._mainFrame, 0.25, {BackgroundTransparency = 1})
        task.delay(0.25, function()
            if not UI._isOpen then
                UI._mainFrame.Visible = false
            end
        end)
    end
end

-- Minimize window
function UI.MinimizeWindow()
    UI._isMinimized = not UI._isMinimized

    if UI._isMinimized then
        Utilities.Tween(UI._mainFrame, 0.3, {Size = UDim2.new(0, UI._mainFrame.Size.X.Offset, 0, 34)})
    else
        Utilities.Tween(UI._mainFrame, 0.3, {Size = Config.DefaultWindowSize})
    end
end

-- Close window (hide, not destroy)
function UI.CloseWindow()
    UI._isOpen = false
    Utilities.Tween(UI._mainFrame, 0.25, {BackgroundTransparency = 1})
    task.delay(0.25, function()
        UI._mainFrame.Visible = false
    end)
end

-- ============================================
-- Splash Screen
-- ============================================
function UI.ShowSplash()
    if not UI._gui then return end

    local splash = UI.CreateFrame({
        Name = "Splash",
        Size = UDim2.new(1, 0, 1, 0),
        Color = Config.Colors.Background,
        Parent = UI._gui,
    })
    splash.ZIndex = 200

    -- H logo besar
    local logoH = Instance.new("TextLabel")
    logoH.Size = UDim2.new(0, 200, 0, 120)
    logoH.Position = UDim2.new(0.5, -100, 0.35, -60)
    logoH.BackgroundTransparency = 1
    logoH.Text = "H"
    logoH.TextColor3 = Config.Colors.Accent
    logoH.TextSize = 100
    logoH.Font = Config.FontBold
    logoH.TextTransparency = 1
    logoH.ZIndex = 201
    logoH.Parent = splash

    local subText = Instance.new("TextLabel")
    subText.Size = UDim2.new(0, 400, 0, 20)
    subText.Position = UDim2.new(0.5, -200, 0.55, 0)
    subText.BackgroundTransparency = 1
    subText.Text = "HOSHI ADMIN DEVELOPMENT TOOLS"
    subText.TextColor3 = Config.Colors.TextDim
    subText.TextSize = 14
    subText.Font = Config.Font
    subText.TextTransparency = 1
    subText.ZIndex = 201
    subText.Parent = splash

    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(0, 400, 0, 16)
    loadingText.Position = UDim2.new(0.5, -200, 0.62, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "INITIALIZING..."
    loadingText.TextColor3 = Config.Colors.AccentDim
    loadingText.TextSize = 11
    loadingText.Font = Config.Font
    loadingText.TextTransparency = 1
    loadingText.ZIndex = 201
    loadingText.Parent = splash

    -- Loading bar
    local loadBarBG = UI.CreateFrame({
        Name = "LoadBarBG",
        Size = UDim2.new(0, 300, 0, 3),
        Position = UDim2.new(0.5, -150, 0.68, 0),
        Color = Config.Colors.PanelBorder,
        Corner = 2,
        Parent = splash,
    })
    loadBarBG.ZIndex = 201

    local loadBarFill = UI.CreateFrame({
        Name = "LoadBarFill",
        Size = UDim2.new(0, 0, 1, 0),
        Color = Config.Colors.Accent,
        Corner = 2,
        Parent = loadBarBG,
    })
    loadBarFill.ZIndex = 202

    -- Animasi splash
    Utilities.Tween(logoH, 0.6, {TextTransparency = 0})
    task.wait(0.3)
    Utilities.Tween(subText, 0.5, {TextTransparency = 0})
    task.wait(0.2)
    Utilities.Tween(loadingText, 0.4, {TextTransparency = 0})
    task.wait(0.2)

    -- Loading progress
    local loadSteps = {
        {Progress = 0.2, Text = "Loading modules..."},
        {Progress = 0.4, Text = "Initializing ESP system..."},
        {Progress = 0.6, Text = "Setting up teleport safety..."},
        {Progress = 0.8, Text = "Configuring POV circle..."},
        {Progress = 1.0, Text = "HOSHI ready."},
    }

    for _, step in ipairs(loadSteps) do
        loadingText.Text = step.Text
        Utilities.Tween(loadBarFill, 0.4, {Size = UDim2.new(step.Progress, 0, 1, 0)})
        task.wait(0.5)
    end

    task.wait(0.5)

    -- Fade out splash
    Utilities.Tween(splash, 0.5, {BackgroundTransparency = 1})
    Utilities.Tween(logoH, 0.5, {TextTransparency = 1})
    Utilities.Tween(subText, 0.5, {TextTransparency = 1})
    Utilities.Tween(loadingText, 0.5, {TextTransparency = 1})
    Utilities.Tween(loadBarBG, 0.5, {BackgroundTransparency = 1})
    Utilities.Tween(loadBarFill, 0.5, {BackgroundTransparency = 1})

    task.wait(0.6)
    splash:Destroy()

    UI._splashDone = true
end

-- ============================================
-- Status update loop
-- ============================================
function UI.StartStatusLoop()
    local fpsCount = 0
    local lastFPSUpdate = tick()

    Cleanup.AddConnection(RunService.RenderStepped:Connect(function()
        fpsCount = fpsCount + 1
        local now = tick()

        if now - lastFPSUpdate >= 1 then
            if UI._statusLabels["fps"] then
                UI._statusLabels["fps"].Text = "FPS: " .. fpsCount
                UI._statusLabels["fps"].TextColor3 = fpsCount >= 50 and Config.Colors.Green or (fpsCount >= 30 and Config.Colors.Yellow or Config.Colors.Red)
            end
            fpsCount = 0
            lastFPSUpdate = now
        end

        -- Update teleport status
        if UI._statusLabels["teleport"] then
            UI._statusLabels["teleport"].Text = "STATUS: " .. TeleportSafety._status
            if TeleportSafety._status:find("TELEPORTED") then
                UI._statusLabels["teleport"].TextColor3 = Config.Colors.Yellow
            elseif TeleportSafety._status:find("MONITORING") then
                UI._statusLabels["teleport"].TextColor3 = Config.Colors.Green
            else
                UI._statusLabels["teleport"].TextColor3 = Config.Colors.TextDim
            end
        end

        -- Update speed status
        if UI._statusLabels["speed"] then
            local char = LocalPlayer.Character
            local currentSpeed = Config.Speed.DefaultWalkSpeed
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then currentSpeed = hum.WalkSpeed end
            end
            UI._statusLabels["speed"].Text = "CURRENT SPEED: " .. Utilities.FormatNumber(currentSpeed) .. " (x" .. Config.Speed.Value .. ")"
        end

        -- Update bottom bar
        if UI._statusLabels["bottom"] then
            local playerCount = #Players:GetPlayers()
            UI._statusLabels["bottom"].Text = "HOSHI // ACTIVE // PLAYERS: " .. playerCount .. " // " .. os.date("%H:%M:%S")
        end
    end))
end

-- ============================================================
-- MODULE: MAIN (Entry Point)
-- ============================================================
local Main = {}

function Main.Init()
    -- Hapus instance lama jika ada
    local oldGui = game:GetService("CoreGui"):FindFirstChild("HoshiDev")
    if oldGui then oldGui:Destroy() end
    local oldGui2 = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HoshiDev")
    if oldGui2 then oldGui2:Destroy() end

    -- Build UI
    UI.Build()

    -- Show splash screen
    UI.ShowSplash()

    -- Init modules
    ESP.Init()
    TeleportSafety.Init()
    Speed.Init()
    POV.Init()
    OnPoint.Init()

    -- Start status loop
    UI.StartStatusLoop()

    -- Player removing cleanup for OnPoint
    Cleanup.AddConnection(Players.PlayerRemoving:Connect(function(player)
        OnPoint.CleanupPlayer(player)
    end))

    -- Send welcome notification
    task.delay(0.5, function()
        Notification.Send("HOSHI", "System initialized. Click [H] to open.", 4, "success")
    end)

    print("[HOSHI] Admin Development Tools loaded successfully.")
    print("[HOSHI] Version: " .. Config.Version)
    print("[HOSHI] Click the [H] button to open the menu.")
end

-- Run
Main.Init()