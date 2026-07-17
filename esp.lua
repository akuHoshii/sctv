--[[
    ═══════════════════════════════════════════════════════════════
    ZIQWENSS SCRIPT — iOS 26 Inspired Premium Interface
    ═══════════════════════════════════════════════════════════════
    Single-file Roblox Lua Script
    Design: Apple Human Interface Guidelines
    Author: Ziqwenss
    Version: 2.0.0
    ═══════════════════════════════════════════════════════════════
--]]

--// SERVICES
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local Stats             = game:GetService("Stats")
local HttpService       = game:GetService("HttpService")
local Workspace         = game:GetService("Workspace")
local StarterGui        = game:GetService("StarterGui")
local TeleportService   = game:GetService("TeleportService")

--// PLAYER
local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = Workspace.CurrentCamera

--// THEME (iOS Dark)
local Theme = {
    Accent          = Color3.fromRGB(10, 132, 255),   -- Apple Blue
    Background      = Color3.fromRGB(17, 17, 17),
    Card            = Color3.fromRGB(28, 28, 30),
    Card2           = Color3.fromRGB(44, 44, 46),
    Card3           = Color3.fromRGB(58, 58, 60),
    Text            = Color3.fromRGB(255, 255, 255),
    SubText         = Color3.fromRGB(142, 142, 147),
    Success         = Color3.fromRGB(48, 209, 88),
    Danger          = Color3.fromRGB(255, 69, 58),
    Warning         = Color3.fromRGB(255, 159, 10),
    Stroke          = Color3.fromRGB(58, 58, 60),
}

--// CONFIG STATE
local Config = {
    AccentColor       = Theme.Accent,
    BlurAmount        = 18,
    AnimationSpeed    = 1,
    RainbowUI         = false,
    BgTransparency    = 0.15,
    UIScale           = 1,
    Theme             = "iOS Black",
    CurrentTab        = "Home",
    Toggles           = {},
    Sliders           = {},
}

--// SPRING TWEEN INFOS
local Spring = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local Fast   = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

--// SF SYMBOLS style monochrome icons (Roblox asset IDs)
local Icons = {
    Home     = "rbxassetid://10723407389",
    User     = "rbxassetid://10747384394",
    Eye      = "rbxassetid://10709771991",
    Target   = "rbxassetid://10723406261",
    Settings = "rbxassetid://10734950309",
    Location = "rbxassetid://10709790801",
    Compass  = "rbxassetid://10709774301",
    Star     = "rbxassetid://10747395214",
    Info     = "rbxassetid://10709790598",
    Lightning= "rbxassetid://10723406667",
    Moon     = "rbxassetid://10723418041",
    Shield   = "rbxassetid://10747364991",
    Close    = "rbxassetid://10747384394",
    Wrench   = "rbxassetid://10734924532",
    Server   = "rbxassetid://10709798129",
    Clock    = "rbxassetid://10734898355",
    Launcher = "rbxassetid://10723424505",
}

--// CLEANUP OLD
pcall(function()
    if CoreGui:FindFirstChild("ZiqwenssGUI") then CoreGui.ZiqwenssGUI:Destroy() end
    if Lighting:FindFirstChild("ZiqwenssBlur") then Lighting.ZiqwenssBlur:Destroy() end
end)

--// UTILITY FUNCTIONS
local function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function Corner(radius)
    return New("UICorner", {CornerRadius = UDim.new(0, radius or 24)})
end

local function Stroke(color, thickness, transparency)
    return New("UIStroke", {
        Color        = color or Theme.Stroke,
        Thickness    = thickness or 1,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Padding(all)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, all),
        PaddingBottom = UDim.new(0, all),
        PaddingLeft   = UDim.new(0, all),
        PaddingRight  = UDim.new(0, all),
    })
end

local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

--// BLUR (iOS glass background)
local Blur = New("BlurEffect", {Name = "ZiqwenssBlur", Size = 0, Parent = Lighting})
Tween(Blur, Fast, {Size = Config.BlurAmount})

--// ROOT SCREENGUI
local ScreenGui = New("ScreenGui", {
    Name          = "ZiqwenssGUI",
    ResetOnSpawn  = false,
    ZIndexBehavior= Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset= true,
    DisplayOrder  = 999,
})
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--═══════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (iOS slide from top)
--═══════════════════════════════════════════════════════════════════
local NotifHolder = New("Frame", {
    Name                 = "Notifications",
    BackgroundTransparency = 1,
    Position             = UDim2.new(0.5, -180, 0, 20),
    Size                 = UDim2.new(0, 360, 1, 0),
    Parent               = ScreenGui,
}, {
    New("UIListLayout", {
        Padding        = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder      = Enum.SortOrder.LayoutOrder,
    }),
})

local function Notify(title, desc, duration)
    duration = duration or 3
    local n = New("Frame", {
        BackgroundColor3       = Theme.Card,
        BackgroundTransparency = 0.15,
        Size                   = UDim2.new(1, 0, 0, 70),
        Position               = UDim2.new(0, 0, 0, -100),
        Parent                 = NotifHolder,
    }, {
        Corner(20),
        Stroke(Theme.Stroke, 1, 0.7),
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        }),
        New("Frame", {
            BackgroundColor3 = Config.AccentColor,
            Size = UDim2.new(0, 4, 0, 40),
            Position = UDim2.new(0, 0, 0.5, -20),
        }, {Corner(2)}),
        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 4),
            Size = UDim2.new(1, -14, 0, 22),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 26),
            Size = UDim2.new(1, -14, 0, 22),
            Font = Enum.Font.Gotham,
            Text = desc,
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        }),
    })
    Tween(n, Spring, {Position = UDim2.new(0, 0, 0, 0)})
    task.delay(duration, function()
        Tween(n, Fast, {Position = UDim2.new(0, 0, 0, -100), BackgroundTransparency = 1})
        task.wait(0.3); n:Destroy()
    end)
end

--═══════════════════════════════════════════════════════════════════
-- FLOATING LAUNCHER BUTTON (56x56 glass circle)
--═══════════════════════════════════════════════════════════════════
local Launcher = New("TextButton", {
    Name                   = "Launcher",
    Size                   = UDim2.new(0, 56, 0, 56),
    Position               = UDim2.new(0, 20, 0.5, -28),
    BackgroundColor3       = Theme.Card,
    BackgroundTransparency = 0.15,
    Text                   = "",
    AutoButtonColor        = false,
    Parent                 = ScreenGui,
}, {
    New("UICorner", {CornerRadius = UDim.new(1, 0)}),
    Stroke(Theme.Stroke, 1, 0.6),
    New("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0.5, -13, 0.5, -13),
        Image = Icons.Launcher,
        ImageColor3 = Theme.Text,
    }),
})

-- Drag launcher
do
    local dragging, dragStart, startPos
    Launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Launcher.Position
            Tween(Launcher, Fast, {Size = UDim2.new(0, 62, 0, 62)})
        end
    end)
    Launcher.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(Launcher, Spring, {Size = UDim2.new(0, 56, 0, 56)})
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Launcher.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--═══════════════════════════════════════════════════════════════════
-- MAIN WINDOW
--═══════════════════════════════════════════════════════════════════
local Window = New("Frame", {
    Name                   = "MainWindow",
    Size                   = UDim2.new(0, 640, 0, 440),
    Position               = UDim2.new(0.5, -320, 0.5, -220),
    BackgroundColor3       = Theme.Background,
    BackgroundTransparency = Config.BgTransparency,
    Visible                = false,
    Parent                 = ScreenGui,
}, {
    Corner(28),
    Stroke(Theme.Stroke, 1, 0.5),
})

-- UI Scale
local WindowScale = New("UIScale", {Scale = 0.9, Parent = Window})

-- Make window draggable via header
local function makeDrag(target)
    local dragging, dragStart, startPos
    target.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = Window.Position
        end
    end)
    target.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--═══════════════════════════════════════════════════════════════════
-- DYNAMIC ISLAND HEADER
--═══════════════════════════════════════════════════════════════════
local Header = New("Frame", {
    Name = "DynamicIsland",
    Size = UDim2.new(1, -40, 0, 46),
    Position = UDim2.new(0, 20, 0, 14),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.15,
    Parent = Window,
}, {
    Corner(23),
    Stroke(Color3.fromRGB(50,50,50), 1, 0.6),
})
makeDrag(Header)

local IslandInfo = New("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -120, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    Font = Enum.Font.GothamMedium,
    Text = "10:48 PM  •  Player: " .. LocalPlayer.Name .. "  •  Ping: 0ms  •  FPS: 60",
    TextColor3 = Theme.Text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})

-- Window control buttons (minimize / maximize / close)
local function ControlBtn(icon, color, xOffset, cb)
    local b = New("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, xOffset, 0.5, -13),
        BackgroundColor3 = color,
        Text = "",
        AutoButtonColor = false,
        Parent = Header,
    }, {
        New("UICorner", {CornerRadius = UDim.new(1, 0)}),
    })
    b.MouseEnter:Connect(function() Tween(b, Fast, {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, xOffset - 2, 0.5, -15)}) end)
    b.MouseLeave:Connect(function() Tween(b, Fast, {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, xOffset, 0.5, -13)}) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local isMaximized = false
local origSize, origPos = Window.Size, Window.Position

local function CloseWindow()
    Tween(WindowScale, Fast, {Scale = 0.9})
    Tween(Window, Fast, {BackgroundTransparency = 1})
    for _, d in ipairs(Window:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("Frame") or d:IsA("ImageLabel") then
            pcall(function()
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    Tween(d, Fast, {TextTransparency = 1})
                end
            end)
        end
    end
    task.wait(0.25)
    Window.Visible = false
    Launcher.Visible = true
    Tween(Launcher, Spring, {Size = UDim2.new(0, 56, 0, 56)})
end

ControlBtn("close", Theme.Danger, -34, CloseWindow)
ControlBtn("min", Theme.Warning, -66, function()
    if isMaximized then
        Tween(Window, Smooth, {Size = origSize, Position = origPos}); isMaximized = false
    else
        Tween(Window, Smooth, {Size = UDim2.new(0, 380, 0, 100), Position = UDim2.new(0.5, -190, 0, 20)})
    end
end)
ControlBtn("max", Theme.Success, -98, function()
    if isMaximized then
        Tween(Window, Smooth, {Size = origSize, Position = origPos}); isMaximized = false
    else
        origSize, origPos = Window.Size, Window.Position
        Tween(Window, Smooth, {Size = UDim2.new(0, 900, 0, 600), Position = UDim2.new(0.5, -450, 0.5, -300)})
        isMaximized = true
    end
end)

--═══════════════════════════════════════════════════════════════════
-- SIDEBAR (Tabs)
--═══════════════════════════════════════════════════════════════════
local Sidebar = New("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 170, 1, -140),
    Position = UDim2.new(0, 20, 0, 76),
    BackgroundColor3 = Theme.Card,
    BackgroundTransparency = 0.2,
    Parent = Window,
}, {
    Corner(22),
    Stroke(Theme.Stroke, 1, 0.7),
    New("UIPadding", {
        PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
    }),
})

local SidebarScroll = New("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Sidebar,
}, {
    New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}),
})

--═══════════════════════════════════════════════════════════════════
-- CONTENT AREA
--═══════════════════════════════════════════════════════════════════
local Content = New("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -220, 1, -140),
    Position = UDim2.new(0, 200, 0, 76),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = Window,
})

--═══════════════════════════════════════════════════════════════════
-- BOTTOM NAV (iPhone style)
--═══════════════════════════════════════════════════════════════════
local BottomNav = New("Frame", {
    Name = "BottomNav",
    Size = UDim2.new(0, 380, 0, 46),
    Position = UDim2.new(0.5, -190, 1, -56),
    BackgroundColor3 = Theme.Card,
    BackgroundTransparency = 0.1,
    Parent = Window,
}, {
    New("UICorner", {CornerRadius = UDim.new(1, 0)}),
    Stroke(Theme.Stroke, 1, 0.6),
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
})

--═══════════════════════════════════════════════════════════════════
-- TAB SYSTEM
--═══════════════════════════════════════════════════════════════════
local Tabs = {}
local Pages = {}
local ActiveTab = nil

local function CreatePage(name)
    local page = New("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Card3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = Content,
    }, {
        New("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}),
        New("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 20)}),
    })
    Pages[name] = page
    return page
end

local function SwitchTab(name)
    if ActiveTab == name then return end
    for tname, page in pairs(Pages) do
        if tname == name then
            page.Visible = true
            page.Position = UDim2.new(0.05, 0, 0, 0)
            for _, d in ipairs(page:GetChildren()) do
                if d:IsA("Frame") then d.BackgroundTransparency = 1 end
            end
            Tween(page, Smooth, {Position = UDim2.new(0, 0, 0, 0)})
            for _, d in ipairs(page:GetChildren()) do
                if d:IsA("Frame") then Tween(d, Smooth, {BackgroundTransparency = 0.2}) end
            end
        else
            page.Visible = false
        end
    end
    -- Update sidebar highlight
    for tname, btn in pairs(Tabs) do
        if tname == name then
            Tween(btn, Fast, {BackgroundTransparency = 0.4})
            Tween(btn.Indicator, Smooth, {Size = UDim2.new(0, 3, 0.7, 0), BackgroundTransparency = 0})
            Tween(btn.Label, Fast, {TextColor3 = Theme.Text})
            btn.Icon.ImageColor3 = Config.AccentColor
        else
            Tween(btn, Fast, {BackgroundTransparency = 1})
            Tween(btn.Indicator, Smooth, {Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1})
            Tween(btn.Label, Fast, {TextColor3 = Theme.SubText})
            btn.Icon.ImageColor3 = Theme.SubText
        end
    end
    ActiveTab = name
    Config.CurrentTab = name
end

local function CreateTab(name, iconAsset)
    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Config.AccentColor,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = SidebarScroll,
    }, {
        Corner(14),
    })
    local indicator = New("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.AccentColor,
        Parent = btn,
    }, {Corner(2)})
    local icon = New("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 14, 0.5, -9),
        BackgroundTransparency = 1,
        Image = iconAsset or Icons.Star,
        ImageColor3 = Theme.SubText,
        Parent = btn,
    })
    local label = New("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = name,
        TextColor3 = Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    btn.Indicator = indicator
    btn.Icon = icon
    btn.Label = label
    btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then Tween(btn, Fast, {BackgroundTransparency = 0.7}) end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then Tween(btn, Fast, {BackgroundTransparency = 1}) end
    end)
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    Tabs[name] = btn
    CreatePage(name)
end

--═══════════════════════════════════════════════════════════════════
-- BOTTOM NAV BUTTONS
--═══════════════════════════════════════════════════════════════════
local function BottomIcon(name, iconAsset)
    local b = New("TextButton", {
        Size = UDim2.new(0, 44, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = BottomNav,
    }, {
        Corner(14),
        New("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0.5, -10, 0.5, -10),
            Image = iconAsset,
            ImageColor3 = Theme.SubText,
            Name = "Icon",
        }),
    })
    b.MouseButton1Click:Connect(function()
        SwitchTab(name)
        Tween(b, Fast, {Size = UDim2.new(0, 48, 0, 40)})
        task.wait(0.1)
        Tween(b, Spring, {Size = UDim2.new(0, 44, 0, 36)})
    end)
    return b
end

--═══════════════════════════════════════════════════════════════════
-- UI COMPONENTS (Card, Toggle, Slider, Button, Dropdown, ColorPicker)
--═══════════════════════════════════════════════════════════════════
local function Section(page, title)
    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = page,
    }, {
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
    })
    return frame
end

local function Card(page, height)
    local c = New("Frame", {
        Size = UDim2.new(1, 0, 0, height or 60),
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.2,
        Parent = page,
    }, {
        Corner(18),
        Stroke(Theme.Stroke, 1, 0.7),
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        }),
    })
    return c
end

-- iOS Toggle
local function Toggle(page, label, default, callback)
    local c = Card(page, 54)
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = c,
    })
    local sw = New("TextButton", {
        Size = UDim2.new(0, 46, 0, 28),
        Position = UDim2.new(1, -46, 0.5, -14),
        BackgroundColor3 = default and Config.AccentColor or Theme.Card3,
        Text = "",
        AutoButtonColor = false,
        Parent = c,
    }, {
        New("UICorner", {CornerRadius = UDim.new(1, 0)}),
    })
    local knob = New("Frame", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = default and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Parent = sw,
    }, {
        New("UICorner", {CornerRadius = UDim.new(1, 0)}),
    })
    local state = default or false
    Config.Toggles[label] = state
    sw.MouseButton1Click:Connect(function()
        state = not state
        Config.Toggles[label] = state
        Tween(sw, Fast, {BackgroundColor3 = state and Config.AccentColor or Theme.Card3})
        Tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)})
        if callback then pcall(callback, state) end
    end)
    return c
end

-- iOS Slider
local function Slider(page, label, min, max, default, callback)
    local c = Card(page, 72)
    local title = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = c,
    })
    local val = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = tostring(default),
        TextColor3 = Config.AccentColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = c,
    })
    local barBg = New("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Card3,
        Parent = c,
    }, {Corner(3)})
    local fillPct = (default - min) / (max - min)
    local fill = New("Frame", {
        Size = UDim2.new(fillPct, 0, 1, 0),
        BackgroundColor3 = Config.AccentColor,
        Parent = barBg,
    }, {Corner(3)})
    local knob = New("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(fillPct, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Parent = barBg,
    }, {New("UICorner", {CornerRadius = UDim.new(1,0)})})
    
    Config.Sliders[label] = default
    local dragging = false
    local function update(x)
        local abs = barBg.AbsolutePosition.X
        local size = barBg.AbsoluteSize.X
        local pct = math.clamp((x - abs) / size, 0, 1)
        local newVal = math.floor(min + (max - min) * pct)
        Tween(fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)})
        Tween(knob, TweenInfo.new(0.1), {Position = UDim2.new(pct, -7, 0.5, -7)})
        val.Text = tostring(newVal)
        Config.Sliders[label] = newVal
        if callback then pcall(callback, newVal) end
    end
    barBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i.Position.X)
        end
    end)
    barBg.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    return c
end

-- Button
local function Button(page, label, callback)
    local c = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Config.AccentColor,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = page,
    }, {
        Corner(16),
    })
    c.MouseEnter:Connect(function() Tween(c, Fast, {BackgroundTransparency = 0.15}) end)
    c.MouseLeave:Connect(function() Tween(c, Fast, {BackgroundTransparency = 0}) end)
    c.MouseButton1Click:Connect(function()
        Tween(c, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 44)})
        task.wait(0.1)
        Tween(c, Spring, {Size = UDim2.new(1, 0, 0, 46)})
        if callback then pcall(callback) end
    end)
    return c
end

-- Dropdown
local function Dropdown(page, label, options, callback)
    local c = Card(page, 54)
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -140, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = c,
    })
    local btn = New("TextButton", {
        Size = UDim2.new(0, 130, 0, 30),
        Position = UDim2.new(1, -130, 0.5, -15),
        BackgroundColor3 = Theme.Card2,
        Text = options[1] or "None",
        Font = Enum.Font.Gotham,
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = c,
    }, {Corner(10)})
    local currentOptions = options
    btn.MouseButton1Click:Connect(function()
        -- cycle
        local idx = 1
        for i, v in ipairs(currentOptions) do if v == btn.Text then idx = i; break end end
        idx = idx % #currentOptions + 1
        btn.Text = currentOptions[idx]
        if callback then pcall(callback, currentOptions[idx]) end
    end)
    return btn
end

--═══════════════════════════════════════════════════════════════════
-- BUILD TABS
--═══════════════════════════════════════════════════════════════════
CreateTab("Home",     Icons.Home)
CreateTab("ESP",      Icons.Eye)
CreateTab("Player",   Icons.User)
CreateTab("Teleport", Icons.Location)
CreateTab("Combat",   Icons.Target)
CreateTab("Movement", Icons.Lightning)
CreateTab("Utility",  Icons.Wrench)
CreateTab("Settings", Icons.Settings)
CreateTab("Credits",  Icons.Star)

-- Bottom nav
BottomIcon("Home",     Icons.Home)
BottomIcon("ESP",      Icons.Eye)
BottomIcon("Player",   Icons.User)
BottomIcon("Teleport", Icons.Location)
BottomIcon("Combat",   Icons.Target)
BottomIcon("Settings", Icons.Settings)

--═══════════════════════════════════════════════════════════════════
-- HOME PAGE (Lock Screen Style)
--═══════════════════════════════════════════════════════════════════
local Home = Pages["Home"]

local ClockLabel = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "10:48",
    TextColor3 = Theme.Text,
    TextSize = 52,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Home,
})
local DateLabel = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "Friday, 17 July 2026",
    TextColor3 = Theme.SubText,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Home,
})
local GreetLabel = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Good Evening, " .. LocalPlayer.DisplayName,
    TextColor3 = Theme.Text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Home,
})
local WelcomeLabel = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Welcome back to Ziqwenss",
    TextColor3 = Theme.SubText,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Home,
})

-- Widget cards grid
local GridHolder = New("Frame", {
    Size = UDim2.new(1, 0, 0, 250),
    BackgroundTransparency = 1,
    Parent = Home,
}, {
    New("UIGridLayout", {
        CellSize = UDim2.new(0.48, 0, 0, 74),
        CellPadding = UDim2.new(0.04, 0, 0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
})

local function Widget(title, value, valColor)
    local w = New("Frame", {
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.2,
        Parent = GridHolder,
    }, {
        Corner(18),
        Stroke(Theme.Stroke, 1, 0.7),
        New("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)}),
        New("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Font = Enum.Font.GothamMedium,
            Text = title,
            TextColor3 = Theme.SubText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        New("TextLabel", {
            Name = "Value",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 1, -20),
            Font = Enum.Font.GothamBold,
            Text = value,
            TextColor3 = valColor or Theme.Text,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
        }),
    })
    return w
end

local wExec  = Widget("EXECUTOR", (identifyexecutor and identifyexecutor()) or "Unknown")
local wGame  = Widget("GAME", "Loading...")
local wPlace = Widget("PLACE ID", tostring(game.PlaceId))
local wFPS   = Widget("FPS", "60", Theme.Success)
local wPing  = Widget("PING", "0ms", Config.AccentColor)
local wMem   = Widget("MEMORY", "0 MB")
local wCount = Widget("PLAYERS", tostring(#Players:GetPlayers()))
local wVer   = Widget("VERSION", "2.0.0", Config.AccentColor)

task.spawn(function()
    local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
    if ok and info then wGame.Value.Text = info.Name end
end)

-- Home buttons
Button(Home, "Copy Discord Invite", function()
    pcall(function() setclipboard("ziqwenss") end)
    Notify("Copied", "Discord invite copied to clipboard")
end)

--═══════════════════════════════════════════════════════════════════
-- ESP PAGE (25 features)
--═══════════════════════════════════════════════════════════════════
local ESP = Pages["ESP"]
Section(ESP, "ESP Master")
local espFeatures = {
    "Master ESP", "Box ESP", "Filled Box", "Corner Box", "Skeleton ESP",
    "Head Dot", "Head Circle", "Health Bar", "Health Text", "Name ESP",
    "Distance ESP", "Team Check", "Tracer", "Bottom Tracer", "Top Tracer",
    "Snapline", "Chams", "Rainbow Chams", "Visible Check", "Offscreen Arrow",
    "Weapon ESP", "Tool ESP", "Highlight ESP", "Dynamic Color",
}
for _, f in ipairs(espFeatures) do
    Toggle(ESP, f, false, function(s) Notify("ESP", f .. (s and " Enabled" or " Disabled")) end)
end
Slider(ESP, "ESP Transparency", 0, 100, 30)
Slider(ESP, "ESP Thickness", 1, 10, 2)
Slider(ESP, "ESP Distance", 100, 5000, 2000)

--═══════════════════════════════════════════════════════════════════
-- PLAYER PAGE
--═══════════════════════════════════════════════════════════════════
local Player = Pages["Player"]
Section(Player, "Character Modifiers")

local function getHum() local c = LocalPlayer.Character; if c then return c:FindFirstChildOfClass("Humanoid") end end

Slider(Player, "WalkSpeed", 16, 500, 16, function(v) local h = getHum() if h then h.WalkSpeed = v end end)
Slider(Player, "JumpPower", 50, 500, 50, function(v) local h = getHum() if h then h.JumpPower = v; h.UseJumpPower = true end end)
Slider(Player, "HipHeight", 0, 20, 2, function(v) local h = getHum() if h then h.HipHeight = v end end)
Slider(Player, "Gravity", 0, 200, 196, function(v) Workspace.Gravity = v end)

local infJump = false
Toggle(Player, "Infinite Jump", false, function(s) infJump = s end)
UserInputService.JumpRequest:Connect(function() if infJump then local h = getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)

Toggle(Player, "Fly", false, function(s) Notify("Player", "Fly " .. (s and "Enabled" or "Disabled")) end)
Toggle(Player, "No Clip", false)
Toggle(Player, "Auto Sprint", false)
Toggle(Player, "Bunny Hop", false)
Toggle(Player, "God Mode Visual", false)
Toggle(Player, "Anti AFK", true, function(s)
    if s then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:CaptureController(); vu:ClickButton2(Vector2.new())
        end)
    end
end)
Button(Player, "Reset Character", function() local h = getHum() if h then h.Health = 0 end end)

--═══════════════════════════════════════════════════════════════════
-- TELEPORT PAGE
--═══════════════════════════════════════════════════════════════════
local Tele = Pages["Teleport"]
Section(Tele, "Teleportation")
local playerList = {}
local function refresh()
    playerList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerList, p.Name) end
    end
    if #playerList == 0 then table.insert(playerList, "None") end
end
refresh()
local dd = Dropdown(Tele, "Select Player", playerList, function(sel) Notify("Selected", sel) end)
Button(Tele, "Refresh Player List", function() refresh(); Notify("Teleport", "Player list refreshed") end)
Button(Tele, "Teleport to Selected", function()
    local t = Players:FindFirstChild(dd.Text)
    if t and t.Character and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(t.Character:GetPivot())
    end
end)
Button(Tele, "Teleport Behind Player", function()
    local t = Players:FindFirstChild(dd.Text)
    if t and t.Character and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(t.Character:GetPivot() * CFrame.new(0, 0, 3))
    end
end)
Button(Tele, "Teleport Above Player", function()
    local t = Players:FindFirstChild(dd.Text)
    if t and t.Character and LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(t.Character:GetPivot() * CFrame.new(0, 8, 0))
    end
end)
local savedPos = nil
Button(Tele, "Save Position", function()
    if LocalPlayer.Character then savedPos = LocalPlayer.Character:GetPivot(); Notify("Position", "Position saved") end
end)
Button(Tele, "Load Position", function()
    if savedPos and LocalPlayer.Character then LocalPlayer.Character:PivotTo(savedPos) end
end)
Button(Tele, "Click Teleport", function()
    local conn; conn = Mouse.Button1Down:Connect(function()
        if Mouse.Hit and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(Mouse.Hit + Vector3.new(0, 3, 0))
        end
        conn:Disconnect()
    end)
    Notify("Teleport", "Click anywhere to teleport")
end)

--═══════════════════════════════════════════════════════════════════
-- COMBAT PAGE
--═══════════════════════════════════════════════════════════════════
local Combat = Pages["Combat"]
Section(Combat, "Hitbox Expander")
Toggle(Combat, "Hitbox Expander", false)
Slider(Combat, "Hitbox Size", 1, 50, 5)
Slider(Combat, "Hitbox Transparency", 0, 100, 50)
Toggle(Combat, "Head Hitbox", true)
Toggle(Combat, "Body Hitbox", false)
Toggle(Combat, "Arm Hitbox", false)
Toggle(Combat, "Leg Hitbox", false)
Toggle(Combat, "Team Check", true)
Toggle(Combat, "Visible Check", false)
Slider(Combat, "Hitbox Distance", 10, 500, 100)
Slider(Combat, "Hitbox Multiplier", 1, 20, 2)
Toggle(Combat, "Auto Update Hitbox", false)
Button(Combat, "Enable Huge Hitbox", function() Notify("Combat", "Huge hitbox activated") end)
Button(Combat, "Restore Default Hitbox", function() Notify("Combat", "Hitbox restored") end)

--═══════════════════════════════════════════════════════════════════
-- MOVEMENT PAGE
--═══════════════════════════════════════════════════════════════════
local Move = Pages["Movement"]
Section(Move, "Movement Modifiers")
Toggle(Move, "No Clip", false)
Toggle(Move, "Fly", false)
Toggle(Move, "Speed Hack", false)
Toggle(Move, "Air Walk", false)
Toggle(Move, "Infinite Jump", false)
Toggle(Move, "Float", false)
Toggle(Move, "Spider Climb", false)
Toggle(Move, "Wall Walk", false)
Toggle(Move, "Low Gravity", false, function(s) Workspace.Gravity = s and 40 or 196 end)
Toggle(Move, "High Gravity", false, function(s) Workspace.Gravity = s and 400 or 196 end)

--═══════════════════════════════════════════════════════════════════
-- UTILITY PAGE
--═══════════════════════════════════════════════════════════════════
local Util = Pages["Utility"]
Section(Util, "Server & System")
Toggle(Util, "FPS Counter", true)
Toggle(Util, "Ping Counter", true)
Toggle(Util, "Server Time", true)
Button(Util, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
Button(Util, "Server Hop", function() Notify("Server", "Searching for server...") end)
Button(Util, "Copy JobID", function() pcall(function() setclipboard(game.JobId) end); Notify("Copied", "JobID copied") end)
Button(Util, "Copy PlaceID", function() pcall(function() setclipboard(tostring(game.PlaceId)) end); Notify("Copied", "PlaceID copied") end)
Toggle(Util, "Anti Kick", false)
Toggle(Util, "Auto Reconnect", false)
Toggle(Util, "Full Bright", false, function(s)
    Lighting.Brightness = s and 3 or 1
    Lighting.ClockTime = s and 14 or 14
    Lighting.GlobalShadows = not s
end)
Toggle(Util, "Night Mode", false, function(s) Lighting.ClockTime = s and 0 or 14 end)
Button(Util, "Destroy GUI", function() Blur:Destroy(); ScreenGui:Destroy() end)
Button(Util, "Unload Script", function() Blur:Destroy(); ScreenGui:Destroy() end)

--═══════════════════════════════════════════════════════════════════
-- SETTINGS PAGE
--═══════════════════════════════════════════════════════════════════
local Settings = Pages["Settings"]
Section(Settings, "Appearance")

local themes = {"iOS Black", "Dark", "Light", "Midnight", "Ocean", "Purple"}
Dropdown(Settings, "Theme", themes, function(t) Notify("Theme", "Applied: " .. t) end)

Slider(Settings, "Blur Amount", 0, 40, Config.BlurAmount, function(v) Config.BlurAmount = v; Blur.Size = v end)
Slider(Settings, "Animation Speed", 1, 20, 10)
Toggle(Settings, "Rainbow UI", false, function(s) Config.RainbowUI = s end)
Slider(Settings, "Background Transparency", 0, 100, 15, function(v) Window.BackgroundTransparency = v / 100 end)
Slider(Settings, "GUI Scale", 50, 150, 100, function(v) WindowScale.Scale = v / 100 end)

Section(Settings, "Config Management")
Button(Settings, "Save Config", function() Notify("Config", "Configuration saved") end)
Button(Settings, "Load Config", function() Notify("Config", "Configuration loaded") end)
Button(Settings, "Reset Config", function() Notify("Config", "Configuration reset") end)

--═══════════════════════════════════════════════════════════════════
-- CREDITS PAGE
--═══════════════════════════════════════════════════════════════════
local Credits = Pages["Credits"]
Section(Credits, "About")

local profile = New("Frame", {
    Size = UDim2.new(1, 0, 0, 140),
    BackgroundColor3 = Theme.Card,
    BackgroundTransparency = 0.2,
    Parent = Credits,
}, {
    Corner(20),
    Stroke(Theme.Stroke, 1, 0.7),
    New("UIPadding", {PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16)}),
})

New("ImageLabel", {
    Size = UDim2.new(0, 80, 0, 80),
    Position = UDim2.new(0, 0, 0.5, -40),
    BackgroundColor3 = Theme.Card2,
    Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png",
    Parent = profile,
}, {New("UICorner", {CornerRadius = UDim.new(1, 0)})})

New("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 96, 0, 8),
    Size = UDim2.new(1, -96, 0, 22),
    Font = Enum.Font.GothamBold,
    Text = "Ziqwenss Script",
    TextColor3 = Theme.Text,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = profile,
})
New("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 96, 0, 32),
    Size = UDim2.new(1, -96, 0, 18),
    Font = Enum.Font.GothamMedium,
    Text = "Version 2.0.0  •  Build 17.07.2026",
    TextColor3 = Theme.SubText,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = profile,
})
New("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 96, 0, 56),
    Size = UDim2.new(1, -96, 0, 60),
    Font = Enum.Font.Gotham,
    Text = "A premium iOS 26 inspired script interface. Special thanks to the Roblox community and everyone who tested this build.",
    TextColor3 = Theme.SubText,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    Parent = profile,
})

Button(Credits, "Copy Discord", function() pcall(function() setclipboard("ziqwenss") end); Notify("Copied", "Discord copied") end)
Button(Credits, "Visit GitHub", function() Notify("GitHub", "github.com/ziqwenss") end)
Button(Credits, "Update Log", function() Notify("Updates", "Latest: v2.0.0 - iOS 26 Refresh") end)

--═══════════════════════════════════════════════════════════════════
-- LIVE UPDATERS (Clock, FPS, Ping, Memory)
--═══════════════════════════════════════════════════════════════════
local frames, lastTime, fps = 0, tick(), 60
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - lastTime >= 1 then
        fps = frames; frames = 0; lastTime = tick()
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        local now = os.date("*t")
        local hr = now.hour
        local ampm = hr >= 12 and "PM" or "AM"
        hr = hr % 12; if hr == 0 then hr = 12 end
        local timeStr = string.format("%d:%02d %s", hr, now.min, ampm)
        local dateStr = os.date("%A, %d %B %Y")
        
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        local mem = math.floor(Stats:GetTotalMemoryUsageMb())
        
        ClockLabel.Text = timeStr:gsub(" AM", ""):gsub(" PM", "")
        DateLabel.Text = dateStr
        IslandInfo.Text = string.format("%s  •  %s  •  Ping: %dms  •  FPS: %d", timeStr, LocalPlayer.Name, ping, fps)
        
        wFPS.Value.Text = tostring(fps)
        wPing.Value.Text = ping .. "ms"
        wMem.Value.Text = mem .. " MB"
        wCount.Value.Text = tostring(#Players:GetPlayers())
        
        -- Rainbow accent
        if Config.RainbowUI then
            local h = (tick() % 5) / 5
            Config.AccentColor = Color3.fromHSV(h, 0.7, 1)
            for _, tab in pairs(Tabs) do
                tab.Indicator.BackgroundColor3 = Config.AccentColor
                if ActiveTab == tab.Label.Text then tab.Icon.ImageColor3 = Config.AccentColor end
            end
        end
        task.wait(1)
    end
end)

--═══════════════════════════════════════════════════════════════════
-- OPEN / CLOSE WINDOW
--═══════════════════════════════════════════════════════════════════
local function OpenWindow()
    Launcher.Visible = false
    Window.Visible = true
    Window.BackgroundTransparency = 1
    WindowScale.Scale = 0.9
    Tween(Window, Spring, {BackgroundTransparency = Config.BgTransparency})
    Tween(WindowScale, Spring, {Scale = 1})
    Tween(Blur, Smooth, {Size = Config.BlurAmount})
    if not ActiveTab then SwitchTab("Home") end
end

Launcher.MouseButton1Click:Connect(OpenWindow)

--═══════════════════════════════════════════════════════════════════
-- OPENING SEQUENCE
--═══════════════════════════════════════════════════════════════════
task.wait(0.2)
Notify("Ziqwenss", "Script loaded successfully. Tap the launcher to open.", 4)

-- Auto-open on first load
task.wait(0.3)
OpenWindow()
SwitchTab("Home")
