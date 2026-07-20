-- MOD MENU SCRIPT
-- Teleport to Player & ESP
-- iPhone Style UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- KONFIGURASI
-- ============================================
local CONFIG = {
    ESP_ENABLED = false,
    ESP_COLOR = Color3.fromRGB(0, 255, 120),
    ESP_BOX_COLOR = Color3.fromRGB(255, 255, 255),
    ARROW_COLOR = Color3.fromRGB(0, 200, 255),
    MENU_OPEN = false,
}

-- ============================================
-- MEMBUAT SCREEN GUI UTAMA
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn then
    syn.protect_gui(ScreenGui)
end

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- FUNGSI UTILITAS UI
-- ============================================
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 67)
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.Parent = parent
    return padding
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================
-- TOGGLE BUTTON (FLOATING ICON)
-- ============================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
ToggleButton.Text = "M"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.ZIndex = 100
ToggleButton.Parent = ScreenGui
CreateCorner(ToggleButton, 25)

local ToggleShadow = Instance.new("ImageLabel")
ToggleShadow.Name = "Shadow"
ToggleShadow.BackgroundTransparency = 1
ToggleShadow.Size = UDim2.new(1, 30, 1, 30)
ToggleShadow.Position = UDim2.new(0, -15, 0, -10)
ToggleShadow.Image = "rbxassetid://5554236805"
ToggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
ToggleShadow.ImageTransparency = 0.6
ToggleShadow.ScaleType = Enum.ScaleType.Slice
ToggleShadow.SliceCenter = Rect.new(23, 23, 277, 277)
ToggleShadow.ZIndex = 99
ToggleShadow.Parent = ToggleButton

-- Draggable toggle button
MakeDraggable(ToggleButton, ToggleButton)

-- ============================================
-- MAIN MENU FRAME
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(242, 242, 247)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui
CreateCorner(MainFrame, 20)

local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "Shadow"
MainShadow.BackgroundTransparency = 1
MainShadow.Size = UDim2.new(1, 40, 1, 40)
MainShadow.Position = UDim2.new(0, -20, 0, -15)
MainShadow.Image = "rbxassetid://5554236805"
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 0.5
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(23, 23, 277, 277)
MainShadow.ZIndex = 49
MainShadow.Parent = MainFrame

-- ============================================
-- HEADER BAR
-- ============================================
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Header.BorderSizePixel = 0
Header.ZIndex = 52
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = Header

-- Fix bottom corners of header
local HeaderFix = Instance.new("Frame")
HeaderFix.Name = "HeaderFix"
HeaderFix.Size = UDim2.new(1, 0, 0, 20)
HeaderFix.Position = UDim2.new(0, 0, 1, -20)
HeaderFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderFix.BorderSizePixel = 0
HeaderFix.ZIndex = 52
HeaderFix.Parent = Header

local HeaderLine = Instance.new("Frame")
HeaderLine.Name = "HeaderLine"
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, 0)
HeaderLine.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 53
HeaderLine.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Mod Menu"
TitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 54
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -42, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 55
CloseButton.Parent = Header
CreateCorner(CloseButton, 15)

-- Draggable dari header
MakeDraggable(MainFrame, Header)

-- ============================================
-- TAB BAR (Segmented Control)
-- ============================================
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -32, 0, 36)
TabBar.Position = UDim2.new(0, 16, 0, 66)
TabBar.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 52
TabBar.Parent = MainFrame
CreateCorner(TabBar, 8)

local TabTeleport = Instance.new("TextButton")
TabTeleport.Name = "TabTeleport"
TabTeleport.Size = UDim2.new(0.5, -4, 1, -4)
TabTeleport.Position = UDim2.new(0, 2, 0, 2)
TabTeleport.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TabTeleport.Text = "Teleport"
TabTeleport.TextColor3 = Color3.fromRGB(0, 0, 0)
TabTeleport.TextSize = 14
TabTeleport.Font = Enum.Font.GothamSemibold
TabTeleport.BorderSizePixel = 0
TabTeleport.ZIndex = 53
TabTeleport.Parent = TabBar
CreateCorner(TabTeleport, 7)

local TabESP = Instance.new("TextButton")
TabESP.Name = "TabESP"
TabESP.Size = UDim2.new(0.5, -4, 1, -4)
TabESP.Position = UDim2.new(0.5, 2, 0, 2)
TabESP.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
TabESP.Text = "ESP"
TabESP.TextColor3 = Color3.fromRGB(100, 100, 100)
TabESP.TextSize = 14
TabESP.Font = Enum.Font.GothamSemibold
TabESP.BorderSizePixel = 0
TabESP.ZIndex = 53
TabESP.Parent = TabBar
CreateCorner(TabESP, 7)

-- ============================================
-- CONTENT AREA
-- ============================================
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -32, 1, -120)
ContentArea.Position = UDim2.new(0, 16, 0, 112)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ZIndex = 51
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainFrame

-- ============================================
-- TELEPORT PAGE
-- ============================================
local TeleportPage = Instance.new("ScrollingFrame")
TeleportPage.Name = "TeleportPage"
TeleportPage.Size = UDim2.new(1, 0, 1, 0)
TeleportPage.Position = UDim2.new(0, 0, 0, 0)
TeleportPage.BackgroundTransparency = 1
TeleportPage.BorderSizePixel = 0
TeleportPage.ScrollBarThickness = 3
TeleportPage.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
TeleportPage.CanvasSize = UDim2.new(0, 0, 0, 0)
TeleportPage.ZIndex = 52
TeleportPage.Visible = true
TeleportPage.Parent = ContentArea

local TeleportLayout = Instance.new("UIListLayout")
TeleportLayout.SortOrder = Enum.SortOrder.LayoutOrder
TeleportLayout.Padding = UDim.new(0, 6)
TeleportLayout.Parent = TeleportPage

local TeleportPagePadding = Instance.new("UIPadding")
TeleportPagePadding.PaddingTop = UDim.new(0, 4)
TeleportPagePadding.Parent = TeleportPage

-- ============================================
-- ESP PAGE
-- ============================================
local ESPPage = Instance.new("Frame")
ESPPage.Name = "ESPPage"
ESPPage.Size = UDim2.new(1, 0, 1, 0)
ESPPage.Position = UDim2.new(0, 0, 0, 0)
ESPPage.BackgroundTransparency = 1
ESPPage.BorderSizePixel = 0
ESPPage.ZIndex = 52
ESPPage.Visible = false
ESPPage.Parent = ContentArea

local ESPLayout = Instance.new("UIListLayout")
ESPLayout.SortOrder = Enum.SortOrder.LayoutOrder
ESPLayout.Padding = UDim.new(0, 10)
ESPLayout.Parent = ESPPage

local ESPPagePadding = Instance.new("UIPadding")
ESPPagePadding.PaddingTop = UDim.new(0, 4)
ESPPagePadding.Parent = ESPPage

-- ============================================
-- ESP TOGGLE CARD
-- ============================================
local function CreateToggleCard(parent, title, subtitle, defaultState, callback)
    local Card = Instance.new("Frame")
    Card.Name = title .. "Card"
    Card.Size = UDim2.new(1, 0, 0, 60)
    Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Card.BorderSizePixel = 0
    Card.ZIndex = 53
    Card.Parent = parent
    CreateCorner(Card, 12)

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Name = "CardTitle"
    CardTitle.Size = UDim2.new(1, -90, 0, 20)
    CardTitle.Position = UDim2.new(0, 16, 0, 12)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = title
    CardTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    CardTitle.TextSize = 16
    CardTitle.Font = Enum.Font.GothamSemibold
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.ZIndex = 54
    CardTitle.Parent = Card

    local CardSubtitle = Instance.new("TextLabel")
    CardSubtitle.Name = "CardSubtitle"
    CardSubtitle.Size = UDim2.new(1, -90, 0, 16)
    CardSubtitle.Position = UDim2.new(0, 16, 0, 33)
    CardSubtitle.BackgroundTransparency = 1
    CardSubtitle.Text = subtitle
    CardSubtitle.TextColor3 = Color3.fromRGB(142, 142, 147)
    CardSubtitle.TextSize = 12
    CardSubtitle.Font = Enum.Font.Gotham
    CardSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    CardSubtitle.ZIndex = 54
    CardSubtitle.Parent = Card

    -- Toggle Switch (iOS Style)
    local ToggleBG = Instance.new("TextButton")
    ToggleBG.Name = "ToggleBG"
    ToggleBG.Size = UDim2.new(0, 51, 0, 31)
    ToggleBG.Position = UDim2.new(1, -67, 0.5, -15)
    ToggleBG.BackgroundColor3 = defaultState and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(229, 229, 234)
    ToggleBG.Text = ""
    ToggleBG.BorderSizePixel = 0
    ToggleBG.ZIndex = 55
    ToggleBG.Parent = Card
    CreateCorner(ToggleBG, 16)

    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "Knob"
    ToggleKnob.Size = UDim2.new(0, 27, 0, 27)
    ToggleKnob.Position = defaultState and UDim2.new(1, -29, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.ZIndex = 56
    ToggleKnob.Parent = ToggleBG
    CreateCorner(ToggleKnob, 14)

    -- Knob shadow
    local KnobShadow = Instance.new("ImageLabel")
    KnobShadow.BackgroundTransparency = 1
    KnobShadow.Size = UDim2.new(1, 6, 1, 6)
    KnobShadow.Position = UDim2.new(0, -3, 0, -1)
    KnobShadow.Image = "rbxassetid://5554236805"
    KnobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    KnobShadow.ImageTransparency = 0.75
    KnobShadow.ScaleType = Enum.ScaleType.Slice
    KnobShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    KnobShadow.ZIndex = 55
    KnobShadow.Parent = ToggleKnob

    local toggled = defaultState

    ToggleBG.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            ToggleBG.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
            ToggleKnob.Position = UDim2.new(1, -29, 0.5, -13)
        else
            ToggleBG.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
            ToggleKnob.Position = UDim2.new(0, 2, 0.5, -13)
        end
        callback(toggled)
    end)

    return Card
end

-- Buat toggle cards di ESP page
CreateToggleCard(ESPPage, "ESP Aktif", "Tampilkan ESP pada semua pemain", false, function(state)
    CONFIG.ESP_ENABLED = state
    if not state then
        -- Hapus semua ESP
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local espFolder = player:FindFirstChild("ESPFolder")
                if espFolder then
                    espFolder:Destroy()
                end
            end
        end
        -- Hapus arrow folder
        for _, v in pairs(Camera:GetChildren()) do
            if v.Name == "ArrowESP" then
                v:Destroy()
            end
        end
    end
end)

-- ESP Info Card
local InfoCard = Instance.new("Frame")
InfoCard.Name = "InfoCard"
InfoCard.Size = UDim2.new(1, 0, 0, 80)
InfoCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InfoCard.BorderSizePixel = 0
InfoCard.ZIndex = 53
InfoCard.Parent = ESPPage
CreateCorner(InfoCard, 12)

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, -32, 0, 20)
InfoTitle.Position = UDim2.new(0, 16, 0, 12)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "Fitur ESP"
InfoTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
InfoTitle.TextSize = 16
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.ZIndex = 54
InfoTitle.Parent = InfoCard

local InfoDesc = Instance.new("TextLabel")
InfoDesc.Size = UDim2.new(1, -32, 0, 40)
InfoDesc.Position = UDim2.new(0, 16, 0, 34)
InfoDesc.BackgroundTransparency = 1
InfoDesc.Text = "- Hologram karakter\n- Nama bar di atas kepala\n- Panah penunjuk lokasi"
InfoDesc.TextColor3 = Color3.fromRGB(142, 142, 147)
InfoDesc.TextSize = 12
InfoDesc.Font = Enum.Font.Gotham
InfoDesc.TextXAlignment = Enum.TextXAlignment.Left
InfoDesc.TextYAlignment = Enum.TextYAlignment.Top
InfoDesc.ZIndex = 54
InfoDesc.Parent = InfoCard

-- ============================================
-- TAB SWITCHING
-- ============================================
local currentTab = "Teleport"

local function SwitchTab(tab)
    currentTab = tab
    if tab == "Teleport" then
        TeleportPage.Visible = true
        ESPPage.Visible = false
        TabTeleport.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabTeleport.TextColor3 = Color3.fromRGB(0, 0, 0)
        TabESP.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
        TabESP.TextColor3 = Color3.fromRGB(100, 100, 100)
    else
        TeleportPage.Visible = false
        ESPPage.Visible = true
        TabESP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabESP.TextColor3 = Color3.fromRGB(0, 0, 0)
        TabTeleport.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
        TabTeleport.TextColor3 = Color3.fromRGB(100, 100, 100)
    end
end

TabTeleport.MouseButton1Click:Connect(function()
    SwitchTab("Teleport")
end)

TabESP.MouseButton1Click:Connect(function()
    SwitchTab("ESP")
end)

-- ============================================
-- TELEPORT PLAYER CARD
-- ============================================
local function CreatePlayerCard(player)
    local Card = Instance.new("TextButton")
    Card.Name = "Player_" .. player.Name
    Card.Size = UDim2.new(1, 0, 0, 56)
    Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Card.Text = ""
    Card.BorderSizePixel = 0
    Card.ZIndex = 53
    Card.AutoButtonColor = false
    Card.Parent = TeleportPage
    CreateCorner(Card, 12)

    -- Player avatar icon placeholder
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.Size = UDim2.new(0, 36, 0, 36)
    AvatarFrame.Position = UDim2.new(0, 12, 0.5, -18)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.ZIndex = 54
    AvatarFrame.Parent = Card
    CreateCorner(AvatarFrame, 18)

    -- Try to load avatar
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Size = UDim2.new(1, 0, 1, 0)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.ZIndex = 55
    AvatarImage.Parent = AvatarFrame
    CreateCorner(AvatarImage, 18)

    pcall(function()
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size48x48
        local content, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
        AvatarImage.Image = content
    end)

    local AvatarInitial = Instance.new("TextLabel")
    AvatarInitial.Name = "Initial"
    AvatarInitial.Size = UDim2.new(1, 0, 1, 0)
    AvatarInitial.BackgroundTransparency = 1
    AvatarInitial.Text = string.sub(player.Name, 1, 1):upper()
    AvatarInitial.TextColor3 = Color3.fromRGB(142, 142, 147)
    AvatarInitial.TextSize = 16
    AvatarInitial.Font = Enum.Font.GothamBold
    AvatarInitial.ZIndex = 54
    AvatarInitial.Parent = AvatarFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, -130, 0, 20)
    NameLabel.Position = UDim2.new(0, 58, 0, 10)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = player.DisplayName
    NameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    NameLabel.TextSize = 15
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.ZIndex = 54
    NameLabel.Parent = Card

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Size = UDim2.new(1, -130, 0, 16)
    UsernameLabel.Position = UDim2.new(0, 58, 0, 30)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = "@" .. player.Name
    UsernameLabel.TextColor3 = Color3.fromRGB(142, 142, 147)
    UsernameLabel.TextSize = 12
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.ZIndex = 54
    UsernameLabel.Parent = Card

    -- Teleport button
    local TPButton = Instance.new("TextButton")
    TPButton.Name = "TPButton"
    TPButton.Size = UDim2.new(0, 56, 0, 28)
    TPButton.Position = UDim2.new(1, -68, 0.5, -14)
    TPButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    TPButton.Text = "TP"
    TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TPButton.TextSize = 13
    TPButton.Font = Enum.Font.GothamBold
    TPButton.BorderSizePixel = 0
    TPButton.ZIndex = 55
    TPButton.Parent = Card
    CreateCorner(TPButton, 8)

    -- Hover effect
    Card.MouseEnter:Connect(function()
        Card.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    end)
    Card.MouseLeave:Connect(function()
        Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end)

    -- Teleport function
    local function DoTeleport()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end

    TPButton.MouseButton1Click:Connect(DoTeleport)
    Card.MouseButton1Click:Connect(DoTeleport)

    return Card
end

-- ============================================
-- REFRESH PLAYER LIST
-- ============================================
local function RefreshPlayerList()
    -- Clear existing
    for _, child in pairs(TeleportPage:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Add players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreatePlayerCard(player)
        end
    end

    -- Update canvas size
    task.wait()
    TeleportLayout:ApplyLayout()
    TeleportPage.CanvasSize = UDim2.new(0, 0, 0, TeleportLayout.AbsoluteContentSize.Y + 10)
end

-- Listen for player changes
Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    RefreshPlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    task.wait(0.5)
    RefreshPlayerList()
end)

-- Initial refresh
RefreshPlayerList()

-- ============================================
-- TOGGLE MENU OPEN/CLOSE
-- ============================================
local menuOpen = false
local lastClickTime = 0

ToggleButton.MouseButton1Click:Connect(function()
    local now = tick()
    -- Prevent drag from triggering click
    if now - lastClickTime < 0.3 then return end
    lastClickTime = now

    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen

    if menuOpen then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
        ToggleButton.Text = "X"
        RefreshPlayerList()
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        ToggleButton.Text = "M"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    menuOpen = false
    MainFrame.Visible = false
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    ToggleButton.Text = "M"
end)

-- ============================================
-- ESP SYSTEM
-- ============================================

local ESPObjects = {}

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end

    -- Remove existing ESP
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        ESPObjects[player] = nil
    end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")

    if not humanoid or not rootPart or not head then return end

    ESPObjects[player] = {}

    -- ============================================
    -- 1. HOLOGRAM CHARACTER (Highlight)
    -- ============================================
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = CONFIG.ESP_COLOR
    highlight.FillTransparency = 0.65
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    table.insert(ESPObjects[player], highlight)

    -- ============================================
    -- 2. NAMA BAR (BillboardGui)
    -- ============================================
    local nameBillboard = Instance.new("BillboardGui")
    nameBillboard.Name = "ESP_NameBar"
    nameBillboard.Adornee = head
    nameBillboard.Size = UDim2.new(0, 180, 0, 50)
    nameBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
    nameBillboard.AlwaysOnTop = true
    nameBillboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    nameBillboard.Parent = character

    local nameBarBG = Instance.new("Frame")
    nameBarBG.Name = "BG"
    nameBarBG.Size = UDim2.new(1, 0, 0, 24)
    nameBarBG.Position = UDim2.new(0, 0, 0, 0)
    nameBarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    nameBarBG.BackgroundTransparency = 0.3
    nameBarBG.BorderSizePixel = 0
    nameBarBG.Parent = nameBillboard
    CreateCorner(nameBarBG, 6)

    local nameText = Instance.new("TextLabel")
    nameText.Name = "NameText"
    nameText.Size = UDim2.new(1, -10, 1, 0)
    nameText.Position = UDim2.new(0, 5, 0, 0)
    nameText.BackgroundTransparency = 1
    nameText.Text = player.DisplayName .. " [@" .. player.Name .. "]"
    nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameText.TextSize = 12
    nameText.Font = Enum.Font.GothamSemibold
    nameText.TextScaled = true
    nameText.Parent = nameBarBG

    -- Health bar background
    local healthBarBG = Instance.new("Frame")
    healthBarBG.Name = "HealthBarBG"
    healthBarBG.Size = UDim2.new(1, 0, 0, 6)
    healthBarBG.Position = UDim2.new(0, 0, 0, 26)
    healthBarBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    healthBarBG.BackgroundTransparency = 0.4
    healthBarBG.BorderSizePixel = 0
    healthBarBG.Parent = nameBillboard
    CreateCorner(healthBarBG, 3)

    local healthBarFill = Instance.new("Frame")
    healthBarFill.Name = "Fill"
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
    healthBarFill.BorderSizePixel = 0
    healthBarFill.Parent = healthBarBG
    CreateCorner(healthBarFill, 3)

    -- Distance label
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 34)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = nameBillboard

    table.insert(ESPObjects[player], nameBillboard)

    -- Update health bar dan distance
    local updateConn
    updateConn = RunService.RenderStepped:Connect(function()
        if not CONFIG.ESP_ENABLED then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    if obj and obj.Parent then
                        obj:Destroy()
                    end
                end
                ESPObjects[player] = nil
            end
            updateConn:Disconnect()
            return
        end

        if not player.Parent or not character.Parent or not humanoid.Parent or not rootPart.Parent then
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    if obj and obj.Parent then
                        obj:Destroy()
                    end
                end
                ESPObjects[player] = nil
            end
            updateConn:Disconnect()
            return
        end

        -- Update health
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        healthBarFill.Size = UDim2.new(math.clamp(healthPercent, 0, 1), 0, 1, 0)

        if healthPercent > 0.5 then
            healthBarFill.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        elseif healthPercent > 0.25 then
            healthBarFill.BackgroundColor3 = Color3.fromRGB(255, 204, 0)
        else
            healthBarFill.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
        end

        -- Update distance
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            distLabel.Text = math.floor(dist) .. "m"
        end
    end)
end

-- ============================================
-- 3. ARROW INDICATOR (Screen Space)
-- ============================================
local ArrowFolder = Instance.new("Folder")
ArrowFolder.Name = "ArrowESPFolder"
ArrowFolder.Parent = ScreenGui

local function CreateArrowForPlayer(player)
    if player == LocalPlayer then return nil end

    local arrowFrame = Instance.new("Frame")
    arrowFrame.Name = "Arrow_" .. player.Name
    arrowFrame.Size = UDim2.new(0, 40, 0, 40)
    arrowFrame.BackgroundTransparency = 1
    arrowFrame.Visible = false
    arrowFrame.ZIndex = 40
    arrowFrame.Parent = ArrowFolder

    -- Arrow shape using triangle
    local arrowImage = Instance.new("ImageLabel")
    arrowImage.Name = "ArrowImage"
    arrowImage.Size = UDim2.new(1, 0, 1, 0)
    arrowImage.BackgroundTransparency = 1
    arrowImage.Image = "rbxassetid://3926305904"
    arrowImage.ImageRectOffset = Vector2.new(764, 244)
    arrowImage.ImageRectSize = Vector2.new(36, 36)
    arrowImage.ImageColor3 = CONFIG.ARROW_COLOR
    arrowImage.ZIndex = 41
    arrowImage.Parent = arrowFrame

    -- Arrow player name
    local arrowName = Instance.new("TextLabel")
    arrowName.Name = "ArrowName"
    arrowName.Size = UDim2.new(0, 100, 0, 16)
    arrowName.Position = UDim2.new(0.5, -50, 1, 2)
    arrowName.BackgroundTransparency = 1
    arrowName.Text = player.DisplayName
    arrowName.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrowName.TextSize = 10
    arrowName.Font = Enum.Font.GothamBold
    arrowName.ZIndex = 41
    arrowName.Parent = arrowFrame

    return arrowFrame
end

-- ============================================
-- ESP RENDER LOOP (Arrows)
-- ============================================
RunService.RenderStepped:Connect(function()
    if not CONFIG.ESP_ENABLED then
        for _, child in pairs(ArrowFolder:GetChildren()) do
            child.Visible = false
        end
        return
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position

    local viewportSize = Camera.ViewportSize

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local worldPos = rootPart.Position

            -- Check if on screen
            local screenPos, onScreen = Camera:WorldToScreenPoint(worldPos)

            local arrowFrame = ArrowFolder:FindFirstChild("Arrow_" .. player.Name)
            if not arrowFrame then
                arrowFrame = CreateArrowForPlayer(player)
            end

            if arrowFrame then
                if onScreen and screenPos.Z > 0 then
                    -- Player is on screen, hide arrow
                    arrowFrame.Visible = false
                else
                    -- Player is off screen, show arrow pointing toward them
                    arrowFrame.Visible = true

                    local centerX = viewportSize.X / 2
                    local centerY = viewportSize.Y / 2

                    local direction = Vector2.new(screenPos.X - centerX, screenPos.Y - centerY)
                    if screenPos.Z < 0 then
                        direction = -direction
                    end

                    local angle = math.atan2(direction.Y, direction.X)
                    local radius = math.min(centerX, centerY) - 50

                    local arrowX = centerX + math.cos(angle) * radius
                    local arrowY = centerY + math.sin(angle) * radius

                    arrowFrame.Position = UDim2.new(0, arrowX - 20, 0, arrowY - 20)
                    arrowFrame.Rotation = math.deg(angle) + 90

                    -- Update name rotation to stay readable
                    local arrowName = arrowFrame:FindFirstChild("ArrowName")
                    if arrowName then
                        arrowName.Rotation = -arrowFrame.Rotation
                    end
                end
            end
        else
            local arrowFrame = ArrowFolder:FindFirstChild("Arrow_" .. player.Name)
            if arrowFrame then
                arrowFrame.Visible = false
            end
        end
    end
end)

-- ============================================
-- ESP MANAGEMENT
-- ============================================
local function SetupESP(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if CONFIG.ESP_ENABLED then
            CreateESPForPlayer(player)
        end
    end)

    if CONFIG.ESP_ENABLED and player.Character then
        CreateESPForPlayer(player)
    end
end

-- Monitor ESP toggle
local lastESPState = false
RunService.Heartbeat:Connect(function()
    if CONFIG.ESP_ENABLED ~= lastESPState then
        lastESPState = CONFIG.ESP_ENABLED
        if CONFIG.ESP_ENABLED then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESPForPlayer(player)
                end
            end
        else
            -- Clean up
            for player, objects in pairs(ESPObjects) do
                for _, obj in pairs(objects) do
                    if obj and obj.Parent then
                        obj:Destroy()
                    end
                end
            end
            ESPObjects = {}

            for _, child in pairs(ArrowFolder:GetChildren()) do
                child:Destroy()
            end
        end
    end
end)

-- Setup for existing players
for _, player in pairs(Players:GetPlayers()) do
    SetupESP(player)
end

Players.PlayerAdded:Connect(function(player)
    SetupESP(player)
    task.wait(1)
    RefreshPlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        ESPObjects[player] = nil
    end

    local arrowFrame = ArrowFolder:FindFirstChild("Arrow_" .. player.Name)
    if arrowFrame then
        arrowFrame:Destroy()
    end

    task.wait(0.5)
    RefreshPlayerList()
end)

-- ============================================
-- STATUS BAR (Bottom)
-- ============================================
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, 0, 0, 30)
StatusBar.Position = UDim2.new(0, 0, 1, -30)
StatusBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 52
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 20)
StatusCorner.Parent = StatusBar

local StatusFix = Instance.new("Frame")
StatusFix.Size = UDim2.new(1, 0, 0, 15)
StatusFix.Position = UDim2.new(0, 0, 0, 0)
StatusFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StatusFix.BorderSizePixel = 0
StatusFix.ZIndex = 52
StatusFix.Parent = StatusBar

local StatusLine = Instance.new("Frame")
StatusLine.Size = UDim2.new(1, 0, 0, 1)
StatusLine.Position = UDim2.new(0, 0, 0, 0)
StatusLine.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
StatusLine.BorderSizePixel = 0
StatusLine.ZIndex = 53
StatusLine.Parent = StatusBar

local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Players: " .. #Players:GetPlayers() - 1 .. " | Mod Menu v1.0"
StatusText.TextColor3 = Color3.fromRGB(142, 142, 147)
StatusText.TextSize = 11
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Center
StatusText.ZIndex = 54
StatusText.Parent = StatusBar

-- Update status bar
RunService.Heartbeat:Connect(function()
    local playerCount = #Players:GetPlayers() - 1
    local espStatus = CONFIG.ESP_ENABLED and "ON" or "OFF"
    StatusText.Text = "Players: " .. playerCount .. " | ESP: " .. espStatus .. " | v1.0"
end)

-- ============================================
-- HOME INDICATOR (iOS Style)
-- ============================================
local HomeIndicator = Instance.new("Frame")
HomeIndicator.Name = "HomeIndicator"
HomeIndicator.Size = UDim2.new(0, 40, 0, 4)
HomeIndicator.Position = UDim2.new(0.5, -20, 1, -10)
HomeIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
HomeIndicator.BorderSizePixel = 0
HomeIndicator.ZIndex = 55
HomeIndicator.Parent = MainFrame
CreateCorner(HomeIndicator, 2)

print("[Mod Menu] Loaded successfully!")
print("[Mod Menu] Klik tombol M untuk membuka menu")
print("[Mod Menu] Fitur: Teleport to Player, ESP (Hologram + Name Bar + Arrow)")
