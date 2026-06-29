-- ============================================================
-- HOSHI ADMIN DEVELOPMENT TOOLS v4.0
-- Terminal Admin Panel for Roblox Map Development
-- ============================================================

pcall(function()
    if _G.HOSHI_KILL then _G.HOSHI_KILL() end
end)
pcall(function()
    for _, name in ipairs({"HoshiMain","HoshiBtn","HoshiSplash","HoshiNotif","HoshiPOV"}) do
        local g = game:GetService("CoreGui"):FindFirstChild(name)
        if g then g:Destroy() end
    end
end)

local function Boot()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local C = {}
C.ver = "4.0.0"

C.bg = Color3.fromRGB(12,12,12)
C.bg2 = Color3.fromRGB(8,8,8)
C.bg3 = Color3.fromRGB(18,18,18)
C.fg = Color3.fromRGB(0,220,90)
C.fg2 = Color3.fromRGB(0,150,65)
C.fg3 = Color3.fromRGB(0,100,45)
C.dim = Color3.fromRGB(0,70,32)
C.bright = Color3.fromRGB(130,255,180)
C.red = Color3.fromRGB(220,50,50)
C.reddim = Color3.fromRGB(100,25,25)
C.yellow = Color3.fromRGB(220,190,0)
C.cyan = Color3.fromRGB(0,180,240)
C.cyandim = Color3.fromRGB(0,80,110)
C.gray = Color3.fromRGB(140,140,140)
C.graydim = Color3.fromRGB(70,70,70)
C.black = Color3.fromRGB(0,0,0)
C.sep = Color3.fromRGB(0,45,22)
C.white = Color3.fromRGB(190,190,190)

C.font = Enum.Font.Code
C.ts = 13
C.tss = 11
C.tsl = 16

C.esp = {on=false,box=true,name=true,dist=true,hp=true,role=true}
C.tp = {on=false,radius=35,cd=3,dist=100,last=0}
C.spd = {val=1,base=16}
C.pov = {on=false,r=100,thick=2,alpha=0.8,col=Color3.fromRGB(0,220,90),target=nil,follow=false}
C.op = {on=false,r=50,alpha=0.5,col=Color3.fromRGB(220,190,0),smooth=true}
C.ln = 0

-- ============================================================
-- RESPONSIVE: detect device and scale
-- ============================================================
local viewport = Camera.ViewportSize
local isPhone = viewport.X < 700
local isTablet = viewport.X >= 700 and viewport.X < 1100
local scaleFactor = 1
if isPhone then
    scaleFactor = 0.65
    C.ts = 10
    C.tss = 9
    C.tsl = 13
elseif isTablet then
    scaleFactor = 0.82
    C.ts = 11
    C.tss = 10
    C.tsl = 14
end

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local defW = math.floor(860 * scaleFactor)
local defH = math.floor(540 * scaleFactor)
local minW = math.floor(500 * scaleFactor)
local minH = math.floor(350 * scaleFactor)
local maxW = math.floor(1200 * scaleFactor)
local maxH = math.floor(800 * scaleFactor)
local sideW = math.floor(150 * scaleFactor)
local barH = math.floor(28 * scaleFactor)
local statusH = math.floor(20 * scaleFactor)
local btnSize = math.floor(44 * scaleFactor)

-- ============================================================
-- UTILITIES
-- ============================================================
local U = {}
U.conn = {}
U.inst = {}

function U.ac(self,c)
    if c then table.insert(self.conn,c) end
    return c
end

function U.ai(self,i)
    if i then table.insert(self.inst,i) end
    return i
end

function U.clean(self)
    for i=#self.conn,1,-1 do
        pcall(function() self.conn[i]:Disconnect() end)
    end
    for i=#self.inst,1,-1 do
        pcall(function() self.inst[i]:Destroy() end)
    end
    self.conn = {}
    self.inst = {}
end

function U.tw(self,obj,props,dur,es,ed)
    if not obj or not obj.Parent then return end
    local ti = TweenInfo.new(dur or 0.25, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj,ti,props)
    t:Play()
    return t
end

function U.char(self,p)
    return p and p.Character
end

function U.hum(self,p)
    local ch = self:char(p)
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

function U.root(self,p)
    local ch = self:char(p)
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso")
end

function U.head(self,p)
    local ch = self:char(p)
    return ch and ch:FindFirstChild("Head")
end

function U.dist(self,p)
    local a = self:root(LP)
    local b = self:root(p)
    if a and b then return (a.Position-b.Position).Magnitude end
    return math.huge
end

function U.hp(self,p)
    local h = self:hum(p)
    if h then return h.Health, h.MaxHealth end
    return 0,100
end

function U.role(self,p)
    local ch = self:char(p)
    if not ch then return "Unknown" end
    if p.Team then
        local tn = string.lower(p.Team.Name)
        if tn:find("killer") or tn:find("monster") or tn:find("beast") or tn:find("hunter") or tn:find("seeker") then return "Killer" end
        if tn:find("survivor") or tn:find("runner") or tn:find("innocent") or tn:find("hider") or tn:find("player") then return "Survivor" end
    end
    for _,v in pairs(ch:GetChildren()) do
        if v:IsA("BoolValue") or v:IsA("StringValue") then
            local n = string.lower(v.Name)
            if n:find("killer") or n:find("monster") or n:find("beast") then return "Killer" end
            if n:find("survivor") or n:find("runner") then return "Survivor" end
        end
    end
    for _,an in ipairs({"Role","PlayerRole","GameRole","Type"}) do
        local ok,val = pcall(function() return p:GetAttribute(an) end)
        if ok and val then
            local vl = string.lower(tostring(val))
            if vl:find("killer") or vl:find("monster") then return "Killer" end
            if vl:find("survivor") or vl:find("runner") then return "Survivor" end
        end
        local ok2,val2 = pcall(function() return ch:GetAttribute(an) end)
        if ok2 and val2 then
            local vl2 = string.lower(tostring(val2))
            if vl2:find("killer") or vl2:find("monster") then return "Killer" end
            if vl2:find("survivor") or vl2:find("runner") then return "Survivor" end
        end
    end
    return "Unknown"
end

function U.rcol(self,r)
    if r=="Killer" then return C.red end
    if r=="Survivor" then return C.cyan end
    return C.gray
end

function U.rcold(self,r)
    if r=="Killer" then return C.reddim end
    if r=="Survivor" then return C.cyandim end
    return C.graydim
end

function U.time(self)
    return os.date("%H:%M:%S")
end

function U.w2s(self,pos)
    local sp,os2 = Camera:WorldToScreenPoint(pos)
    return Vector2.new(sp.X,sp.Y), os2, sp.Z
end

function U.lnum(self)
    C.ln = C.ln + 1
    local s = tostring(C.ln)
    while #s < 3 do s = "0"..s end
    return s
end

function U.rlnum(self) C.ln = 0 end

-- ============================================================
-- MAKE: instance builder
-- ============================================================
local function mk(cls,props)
    local i = Instance.new(cls)
    local par = nil
    for k,v in pairs(props or {}) do
        if k == "Parent" then
            par = v
        else
            pcall(function() i[k] = v end)
        end
    end
    if par then i.Parent = par end
    return i
end

-- ============================================================
-- NOTIFICATION
-- ============================================================
local Notif = {}
Notif.gui = nil
Notif.box = nil

function Notif.init(self)
    self.gui = mk("ScreenGui",{Name="HoshiNotif",ResetOnSpawn=false,DisplayOrder=1005,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})
    U:ai(self.gui)
    self.box = mk("Frame",{Name="NBox",Size=UDim2.new(0,math.floor(360*scaleFactor),1,-10),Position=UDim2.new(1,-math.floor(370*scaleFactor),0,5),BackgroundTransparency=1,Parent=self.gui})
    local ly = mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3),VerticalAlignment=Enum.VerticalAlignment.Bottom,Parent=self.box})
end

function Notif.push(self,msg,typ,dur)
    if not self.box then return end
    typ = typ or "info"
    dur = dur or 4
    local col = C.fg
    local pre = "[---]"
    if typ=="err" then col=C.red pre="[ERR]"
    elseif typ=="wrn" then col=C.yellow pre="[WRN]"
    elseif typ=="ok" then col=C.fg pre="[=OK]"
    elseif typ=="sys" then col=C.cyan pre="[SYS]" end

    local f = mk("Frame",{Size=UDim2.new(1,0,0,math.floor(26*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=1,BorderColor3=col,BackgroundTransparency=1,ClipsDescendants=true,Parent=self.box})
    mk("Frame",{Size=UDim2.new(0,2,1,0),BackgroundColor3=col,BorderSizePixel=0,BackgroundTransparency=0.2,Parent=f})
    local lb = mk("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=col,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Text=U:time().." "..pre.." "..msg,TextTransparency=1,Parent=f})
    U:tw(f,{BackgroundTransparency=0.1},0.3)
    U:tw(lb,{TextTransparency=0},0.3)
    task.delay(dur,function()
        if f and f.Parent then
            U:tw(f,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)},0.4)
            U:tw(lb,{TextTransparency=1},0.3)
            task.wait(0.45)
            pcall(function() f:Destroy() end)
        end
    end)
end

-- ============================================================
-- GUI BUILDER
-- ============================================================
local GUI = {}
GUI.main = nil
GUI.mainG = nil
GUI.side = nil
GUI.content = nil
GUI.tabs = {}
GUI.tbtns = {}
GUI.visible = false
GUI.mini = false
GUI.curTab = "ESP"
GUI.tpStat = nil
GUI.spdStat = nil
GUI.opStat = nil
GUI.povList = nil
GUI.logBox = nil
GUI.statusTxt = nil
GUI.fpsTxt = nil
GUI.restoreH = defH

-- terminal line
function GUI.line(self,txt,par,col)
    col = col or C.fg
    local ln = U:lnum()
    return mk("TextLabel",{Size=UDim2.new(1,-6,0,math.floor(16*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=C.ts,TextColor3=col,TextXAlignment=Enum.TextXAlignment.Left,Text=" "..ln.." "..txt,RichText=false,TextTruncate=Enum.TextTruncate.AtEnd,Parent=par})
end

-- comment
function GUI.cmt(self,txt,par)
    return self:line("# "..txt,par,C.dim)
end

-- separator
function GUI.sep(self,par)
    mk("Frame",{Size=UDim2.new(1,-6,0,1),BackgroundColor3=C.sep,BorderSizePixel=0,Parent=par})
    mk("Frame",{Size=UDim2.new(1,0,0,3),BackgroundTransparency=1,Parent=par})
end

-- header
function GUI.hdr(self,txt,par)
    local bar = string.rep("-",math.max(1,35-#txt))
    return self:line("--- "..string.upper(txt).." "..bar,par,C.fg)
end

-- spacer
function GUI.spc(self,par,h)
    mk("Frame",{Size=UDim2.new(1,0,0,h or 4),BackgroundTransparency=1,Parent=par})
end

-- button
function GUI.btn(self,txt,par,cb)
    local ln = U:lnum()
    local b = mk("TextButton",{Size=UDim2.new(1,-6,0,math.floor(22*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=1,BorderColor3=C.dim,Font=C.font,TextSize=C.ts,TextColor3=C.fg,Text=" "..ln.." $ "..txt,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Parent=par})

    b.MouseEnter:Connect(function()
        U:tw(b,{BackgroundColor3=C.fg3,BorderColor3=C.fg,TextColor3=C.bright},0.1)
    end)
    b.MouseLeave:Connect(function()
        U:tw(b,{BackgroundColor3=C.bg2,BorderColor3=C.dim,TextColor3=C.fg},0.1)
    end)

    if isMobile then
        b.TouchTap:Connect(function()
            U:tw(b,{BackgroundColor3=C.fg},0.03)
            task.wait(0.05)
            U:tw(b,{BackgroundColor3=C.fg3},0.1)
            if cb then cb() end
        end)
    end

    b.MouseButton1Click:Connect(function()
        U:tw(b,{BackgroundColor3=C.fg},0.03)
        task.wait(0.05)
        U:tw(b,{BackgroundColor3=C.fg3},0.1)
        if cb then cb() end
    end)
    return b
end

-- toggle
function GUI.tog(self,txt,par,def,cb)
    local ln = U:lnum()
    local st = def or false
    local fr = mk("Frame",{Size=UDim2.new(1,-6,0,math.floor(22*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=1,BorderColor3=C.dim,Parent=par})
    local lb = mk("TextLabel",{Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Font=C.font,TextSize=C.ts,TextColor3=C.fg,TextXAlignment=Enum.TextXAlignment.Left,Text=" "..ln.." "..txt,Parent=fr})
    local sf = mk("Frame",{Size=UDim2.new(0,math.floor(72*scaleFactor),0,math.floor(16*scaleFactor)),Position=UDim2.new(1,-math.floor(78*scaleFactor),0,3),BackgroundColor3=st and C.fg3 or Color3.fromRGB(22,22,22),BorderSizePixel=1,BorderColor3=st and C.fg or C.dim,Parent=fr})
    local sl = mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=st and C.fg or C.fg3,Text=st and "ENABLED" or "------",Parent=sf})

    local click = mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5,Parent=fr})

    local function doToggle()
        st = not st
        sl.Text = st and "ENABLED" or "------"
        U:tw(sf,{BackgroundColor3=st and C.fg3 or Color3.fromRGB(22,22,22),BorderColor3=st and C.fg or C.dim},0.15)
        U:tw(sl,{TextColor3=st and C.fg or C.fg3},0.15)
        if cb then cb(st) end
    end

    click.MouseButton1Click:Connect(doToggle)
    if isMobile then
        click.TouchTap:Connect(doToggle)
    end

    click.MouseEnter:Connect(function()
        U:tw(fr,{BorderColor3=C.fg},0.1)
    end)
    click.MouseLeave:Connect(function()
        U:tw(fr,{BorderColor3=C.dim},0.1)
    end)

    local getter = function() return st end
    local setter = function(v)
        st = v
        sl.Text = st and "ENABLED" or "------"
        sf.BackgroundColor3 = st and C.fg3 or Color3.fromRGB(22,22,22)
        sf.BorderColor3 = st and C.fg or C.dim
        sl.TextColor3 = st and C.fg or C.fg3
    end
    return fr, getter, setter
end

-- slider
function GUI.sld(self,txt,par,mn,mx,def,cb)
    local ln = U:lnum()
    local cur = def or mn
    local fr = mk("Frame",{Size=UDim2.new(1,-6,0,math.floor(38*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=1,BorderColor3=C.dim,Parent=par})
    local lb = mk("TextLabel",{Size=UDim2.new(1,-70,0,math.floor(18*scaleFactor)),Position=UDim2.new(0,4,0,1),BackgroundTransparency=1,Font=C.font,TextSize=C.ts,TextColor3=C.fg,TextXAlignment=Enum.TextXAlignment.Left,Text=" "..ln.." "..txt,Parent=fr})
    local vb = mk("TextBox",{Size=UDim2.new(0,math.floor(55*scaleFactor),0,math.floor(15*scaleFactor)),Position=UDim2.new(1,-math.floor(60*scaleFactor),0,2),BackgroundColor3=Color3.fromRGB(15,15,15),BorderSizePixel=1,BorderColor3=C.dim,Font=C.font,TextSize=C.tss,TextColor3=C.fg,Text=tostring(math.floor(cur*10+0.5)/10),ClearTextOnFocus=false,Parent=fr})
    local track = mk("Frame",{Size=UDim2.new(1,-12,0,math.floor(5*scaleFactor)),Position=UDim2.new(0,6,0,math.floor(24*scaleFactor)),BackgroundColor3=Color3.fromRGB(22,22,22),BorderSizePixel=1,BorderColor3=C.dim,Parent=fr})
    local ratio = math.clamp((cur-mn)/(mx-mn),0,1)
    local fill = mk("Frame",{Size=UDim2.new(ratio,0,1,0),BackgroundColor3=C.fg3,BorderSizePixel=0,Parent=track})
    local knob = mk("Frame",{Size=UDim2.new(0,math.floor(5*scaleFactor),0,math.floor(10*scaleFactor)),Position=UDim2.new(ratio,-2,0.5,-math.floor(5*scaleFactor)),BackgroundColor3=C.fg,BorderSizePixel=0,ZIndex=3,Parent=track})

    local dragging = false

    local function upd(v)
        v = math.clamp(v,mn,mx)
        if mx <= 100 then v = math.floor(v*10+0.5)/10
        else v = math.floor(v) end
        cur = v
        local r = math.clamp((v-mn)/(mx-mn),0,1)
        fill.Size = UDim2.new(r,0,1,0)
        knob.Position = UDim2.new(r,-2,0.5,-math.floor(5*scaleFactor))
        vb.Text = tostring(math.floor(v*10+0.5)/10)
        if cb then cb(v) end
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local r = math.clamp((inp.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            upd(mn+(mx-mn)*r)
        end
    end)

    U:ac(UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local r = math.clamp((inp.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            upd(mn+(mx-mn)*r)
        end
    end))

    U:ac(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    vb.FocusLost:Connect(function()
        local n = tonumber(vb.Text)
        if n then upd(n) else vb.Text = tostring(math.floor(cur*10+0.5)/10) end
    end)

    fr.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            U:tw(fr,{BorderColor3=C.fg},0.1)
        end
    end)
    fr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            U:tw(fr,{BorderColor3=C.dim},0.1)
        end
    end)

    return fr, function() return cur end, upd
end

-- ============================================================
-- DRAG HELPER (works on both desktop and mobile)
-- ============================================================
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
-- BUILD TOGGLE BUTTON "H"
-- ============================================================
function GUI.buildBtn(self)
    local bg = mk("ScreenGui",{Name="HoshiBtn",ResetOnSpawn=false,DisplayOrder=1010,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})
    U:ai(bg)

    local outer = mk("Frame",{Name="HBtn",Size=UDim2.new(0,btnSize,0,btnSize),Position=UDim2.new(0,10,0.5,-btnSize/2),BackgroundColor3=C.bg2,BorderSizePixel=2,BorderColor3=C.fg,Active=true,Parent=bg})
    local inner = mk("Frame",{Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=outer})
    local label = mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Font=C.font,TextSize=math.floor(22*scaleFactor),TextColor3=C.fg,Text="H",Parent=inner})

    -- Drag handling with click detection
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    local mouseDownTime = 0
    local mouseDownPos = nil
    local CLICK_TIME = 0.3
    local CLICK_DIST = 8

    outer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            dragStart = input.Position
            startPos = outer.Position
            mouseDownTime = tick()
            mouseDownPos = input.Position
        end
    end)

    outer.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragStart then
            local delta = input.Position - dragStart
            if delta.Magnitude > CLICK_DIST then
                isDragging = true
                outer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    outer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local elapsed = tick() - mouseDownTime
            local moved = mouseDownPos and (input.Position - mouseDownPos).Magnitude or 0

            if elapsed < CLICK_TIME and moved < CLICK_DIST then
                -- This was a click, not a drag
                self:toggle()
            end

            isDragging = false
            dragStart = nil
        end
    end)

    -- Hover (desktop)
    outer.MouseEnter:Connect(function()
        U:tw(inner,{BackgroundColor3=C.fg3},0.12)
        U:tw(label,{TextColor3=C.bright},0.12)
    end)
    outer.MouseLeave:Connect(function()
        U:tw(inner,{BackgroundColor3=C.bg},0.12)
        U:tw(label,{TextColor3=C.fg},0.12)
    end)

    -- Pulse border
    task.spawn(function()
        local up = true
        while outer and outer.Parent do
            U:tw(outer,{BorderColor3=up and C.fg or C.fg3},1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            up = not up
            task.wait(1.5)
        end
    end)

    self.hBtn = outer
end

-- ============================================================
-- BUILD MAIN WINDOW
-- ============================================================
function GUI.buildMain(self)
    self.mainG = mk("ScreenGui",{Name="HoshiMain",ResetOnSpawn=false,DisplayOrder=1000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})
    U:ai(self.mainG)

    self.main = mk("Frame",{Name="Main",Size=UDim2.new(0,defW,0,defH),Position=UDim2.new(0.5,-defW/2,0.5,-defH/2),BackgroundColor3=C.bg,BorderSizePixel=1,BorderColor3=C.fg,Visible=false,ClipsDescendants=true,Active=true,Parent=self.mainG})

    -- TITLE BAR
    local tb = mk("Frame",{Name="TB",Size=UDim2.new(1,0,0,barH),BackgroundColor3=C.bg2,BorderSizePixel=0,Active=true,Parent=self.main})
    mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.fg,BorderSizePixel=0,Parent=tb})

    local titleStr = "hoshi@"..string.lower(LP.Name)..":~$ v"..C.ver
    mk("TextLabel",{Size=UDim2.new(1,-math.floor(140*scaleFactor),1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Font=C.font,TextSize=C.ts,TextColor3=C.fg,TextXAlignment=Enum.TextXAlignment.Left,Text=titleStr,Parent=tb})

    -- Minimize
    local mnBtn = mk("TextButton",{Size=UDim2.new(0,math.floor(26*scaleFactor),0,math.floor(18*scaleFactor)),Position=UDim2.new(1,-math.floor(58*scaleFactor),0,math.floor(5*scaleFactor)),BackgroundColor3=C.bg,BorderSizePixel=1,BorderColor3=C.dim,Font=C.font,TextSize=C.ts,TextColor3=C.fg2,Text="_",AutoButtonColor=false,Parent=tb})
    mnBtn.MouseButton1Click:Connect(function() self:minimize() end)
    if isMobile then mnBtn.TouchTap:Connect(function() self:minimize() end) end
    mnBtn.MouseEnter:Connect(function() U:tw(mnBtn,{BorderColor3=C.yellow,TextColor3=C.yellow},0.1) end)
    mnBtn.MouseLeave:Connect(function() U:tw(mnBtn,{BorderColor3=C.dim,TextColor3=C.fg2},0.1) end)

    -- Close
    local clBtn = mk("TextButton",{Size=UDim2.new(0,math.floor(26*scaleFactor),0,math.floor(18*scaleFactor)),Position=UDim2.new(1,-math.floor(28*scaleFactor),0,math.floor(5*scaleFactor)),BackgroundColor3=C.bg,BorderSizePixel=1,BorderColor3=C.dim,Font=C.font,TextSize=C.ts,TextColor3=C.fg2,Text="X",AutoButtonColor=false,Parent=tb})
    clBtn.MouseButton1Click:Connect(function() self:toggle() end)
    if isMobile then clBtn.TouchTap:Connect(function() self:toggle() end) end
    clBtn.MouseEnter:Connect(function() U:tw(clBtn,{BorderColor3=C.red,TextColor3=C.red},0.1) end)
    clBtn.MouseLeave:Connect(function() U:tw(clBtn,{BorderColor3=C.dim,TextColor3=C.fg2},0.1) end)

    -- Drag title bar
    makeDraggable(self.main, tb)

    -- RESIZE HANDLE
    local rh = mk("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(1,-14,1,-14),BackgroundColor3=C.fg3,BorderSizePixel=0,ZIndex=90,Active=true,Parent=self.main})
    mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Font=C.font,TextSize=8,TextColor3=C.fg,Text="//",ZIndex=91,Parent=rh})

    local resizing = false
    local resStart, resSizeStart

    rh.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resStart = inp.Position
            resSizeStart = self.main.AbsoluteSize
        end
    end)

    U:ac(UIS.InputChanged:Connect(function(inp)
        if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - resStart
            local nw = math.clamp(resSizeStart.X+d.X,minW,maxW)
            local nh = math.clamp(resSizeStart.Y+d.Y,minH,maxH)
            self.main.Size = UDim2.new(0,nw,0,nh)
        end
    end))

    U:ac(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end))

    -- BODY
    local body = mk("Frame",{Size=UDim2.new(1,0,1,-(barH+statusH)),Position=UDim2.new(0,0,0,barH),BackgroundTransparency=1,Parent=self.main})

    -- SIDEBAR
    self.side = mk("Frame",{Size=UDim2.new(0,sideW,1,0),BackgroundColor3=C.bg2,BorderSizePixel=0,Parent=body})
    mk("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=C.sep,BorderSizePixel=0,Parent=self.side})
    local slay = mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0),Parent=self.side})

    mk("TextLabel",{Size=UDim2.new(1,0,0,math.floor(22*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=C.dim,Text="  -- MODULES",TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=0,Parent=self.side})

    -- CONTENT
    self.content = mk("Frame",{Size=UDim2.new(1,-sideW,1,0),Position=UDim2.new(0,sideW,0,0),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,Parent=body})

    -- STATUS BAR
    local sb = mk("Frame",{Size=UDim2.new(1,0,0,statusH),Position=UDim2.new(0,0,1,-statusH),BackgroundColor3=C.bg2,BorderSizePixel=0,ZIndex=10,Parent=self.main})
    mk("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.sep,BorderSizePixel=0,ZIndex=11,Parent=sb})

    self.statusTxt = mk("TextLabel",{Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,Text="ready",ZIndex=11,Parent=sb})
    self.fpsTxt = mk("TextLabel",{Size=UDim2.new(0,90,1,0),Position=UDim2.new(1,-95,0,0),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right,Text="fps:--",ZIndex=11,Parent=sb})

    -- FPS counter
    local fc,lt = 0,tick()
    U:ac(RunService.RenderStepped:Connect(function()
        fc=fc+1
        local n=tick()
        if n-lt>=1 then
            local fps=math.floor(fc/(n-lt))
            if self.fpsTxt and self.fpsTxt.Parent then
                self.fpsTxt.Text="fps:"..fps
            end
            fc=0 lt=n
        end
    end))

    -- Build tabs
    self:buildTabs()
end

-- Sidebar button
function GUI.sideBtn(self,name,disp,ord)
    local b = mk("TextButton",{Size=UDim2.new(1,0,0,math.floor(24*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=0,Font=C.font,TextSize=C.ts,TextColor3=C.fg2,Text="  > "..disp,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=ord,AutoButtonColor=false,Parent=self.side})

    local ind = mk("Frame",{Size=UDim2.new(0,2,1,-4),Position=UDim2.new(0,0,0,2),BackgroundColor3=C.fg,BackgroundTransparency=1,BorderSizePixel=0,Parent=b})

    b.MouseButton1Click:Connect(function() self:switchTab(name) end)
    if isMobile then b.TouchTap:Connect(function() self:switchTab(name) end) end
    b.MouseEnter:Connect(function()
        if self.curTab~=name then U:tw(b,{BackgroundColor3=C.bg3,TextColor3=C.fg},0.1) end
    end)
    b.MouseLeave:Connect(function()
        if self.curTab~=name then U:tw(b,{BackgroundColor3=C.bg2,TextColor3=C.fg2},0.1) end
    end)

    self.tbtns[name] = {btn=b,ind=ind}
end

-- Switch tab
function GUI.switchTab(self,name)
    self.curTab = name
    for tn,d in pairs(self.tbtns) do
        if tn==name then
            U:tw(d.btn,{BackgroundColor3=C.fg3,TextColor3=C.bright},0.15)
            U:tw(d.ind,{BackgroundTransparency=0},0.15)
        else
            U:tw(d.btn,{BackgroundColor3=C.bg2,TextColor3=C.fg2},0.15)
            U:tw(d.ind,{BackgroundTransparency=1},0.15)
        end
    end
    for tn,fr in pairs(self.tabs) do
        fr.Visible = (tn==name)
    end
    if self.statusTxt and self.statusTxt.Parent then
        self.statusTxt.Text = "~/"..string.lower(name).."$ loaded | "..U:time()
    end
end

-- Create tab scroll frame
function GUI.mkTab(self,name)
    local sc = mk("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.bg,BorderSizePixel=0,ScrollBarThickness=math.floor(4*scaleFactor),ScrollBarImageColor3=C.fg3,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=self.content})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2),Parent=sc})
    mk("UIPadding",{PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4),Parent=sc})
    self.tabs[name] = sc
    return sc
end

-- ============================================================
-- BUILD ALL TABS
-- ============================================================
function GUI.buildTabs(self)
    local defs = {
        {n="ESP",d="esp",o=1},
        {n="TELEPORT",d="teleport",o=2},
        {n="SPEED",d="speed",o=3},
        {n="POV",d="pov",o=4},
        {n="ONPOINT",d="onpoint",o=5},
        {n="SYSTEM",d="system",o=6},
    }
    for _,d in ipairs(defs) do
        self:sideBtn(d.n,d.d,d.o)
        self:mkTab(d.n)
    end

    U:rlnum() self:buildESP()
    U:rlnum() self:buildTP()
    U:rlnum() self:buildSPD()
    U:rlnum() self:buildPOV()
    U:rlnum() self:buildOP()
    U:rlnum() self:buildSYS()

    self:switchTab("ESP")
end

-- TAB: ESP
function GUI.buildESP(self)
    local t = self.tabs["ESP"]
    self:hdr("esp player",t)
    self:cmt("render debug overlays on all players",t)
    self:cmt("color by role: killer=red survivor=cyan",t)
    self:sep(t)
    self:tog("esp.enabled",t,C.esp.on,function(s) C.esp.on=s ESP_M:toggle(s) Notif:push("esp "..(s and "on" or "off"),s and "ok" or "wrn") end)
    self:spc(t)
    self:tog("esp.box",t,C.esp.box,function(s) C.esp.box=s end)
    self:tog("esp.name",t,C.esp.name,function(s) C.esp.name=s end)
    self:tog("esp.distance",t,C.esp.dist,function(s) C.esp.dist=s end)
    self:tog("esp.health",t,C.esp.hp,function(s) C.esp.hp=s end)
    self:tog("esp.role",t,C.esp.role,function(s) C.esp.role=s end)
    self:sep(t)
    self:line("-- killer  = red",t,C.red)
    self:line("-- survivor = cyan",t,C.cyan)
    self:line("-- unknown  = gray",t,C.gray)
end

-- TAB: TELEPORT
function GUI.buildTP(self)
    local t = self.tabs["TELEPORT"]
    self:hdr("teleport safety",t)
    self:cmt("auto-escape when killer enters radius",t)
    self:cmt("teleports opposite direction from threat",t)
    self:sep(t)
    self:tog("teleport.armed",t,C.tp.on,function(s) C.tp.on=s Notif:push("teleport "..(s and "armed" or "disarmed"),s and "ok" or "wrn") end)
    self:spc(t)
    self:sld("teleport.radius",t,10,100,C.tp.radius,function(v) C.tp.radius=math.floor(v) end)
    self:sld("teleport.escape_dist",t,50,250,C.tp.dist,function(v) C.tp.dist=math.floor(v) end)
    self:sld("teleport.cooldown",t,1,20,C.tp.cd,function(v) C.tp.cd=math.floor(v) end)
    self:sep(t)
    self.tpStat = self:line("status = standby",t,C.fg2)
end

-- TAB: SPEED
function GUI.buildSPD(self)
    local t = self.tabs["SPEED"]
    self:hdr("speed run",t)
    self:cmt("walkspeed multiplier (base=16)",t)
    self:sep(t)
    self:sld("speed.multiplier",t,1,10,C.spd.val,function(v) C.spd.val=v SPD_M:apply(v) end)
    self:spc(t)
    self:btn("speed.reset()",t,function() C.spd.val=1 SPD_M:apply(1) Notif:push("speed reset","ok") end)
    self:sep(t)
    self.spdStat = self:line("current = 16 studs/s (1.0x)",t,C.fg2)
end

-- TAB: POV
function GUI.buildPOV(self)
    local t = self.tabs["POV"]
    self:hdr("pov circle",t)
    self:cmt("crosshair + camera follow for observation",t)
    self:sep(t)
    self:tog("pov.circle",t,C.pov.on,function(s) C.pov.on=s POV_M:toggle(s) Notif:push("pov "..(s and "on" or "off"),s and "ok" or "wrn") end)
    self:tog("pov.follow_cam",t,C.pov.follow,function(s) C.pov.follow=s Notif:push("cam follow "..(s and "on" or "off"),"info") end)
    self:spc(t)
    self:sld("pov.radius",t,20,300,C.pov.r,function(v) C.pov.r=math.floor(v) POV_M:rebuild() end)
    self:sld("pov.thickness",t,1,10,C.pov.thick,function(v) C.pov.thick=math.floor(v) POV_M:rebuild() end)
    self:sld("pov.opacity",t,0.1,1,C.pov.alpha,function(v) C.pov.alpha=v POV_M:rebuild() end)
    self:sep(t)
    self:cmt("select target:",t)

    self.povList = mk("Frame",{Size=UDim2.new(1,-4,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Parent=t})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2),Parent=self.povList})

    self:spc(t)
    self:btn("pov.refresh()",t,function() self:refreshTargets() Notif:push("list refreshed","info") end)
    self:refreshTargets()
end

function GUI.refreshTargets(self)
    if not self.povList then return end
    for _,ch in pairs(self.povList:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local r = U:role(p)
            local rc = U:rcol(r)
            local pb = mk("TextButton",{Size=UDim2.new(1,0,0,math.floor(20*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=1,BorderColor3=C.dim,Font=C.font,TextSize=C.tss,TextColor3=rc,Text="   >> "..p.Name.." ["..r.."]",TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Parent=self.povList})
            pb.MouseButton1Click:Connect(function()
                C.pov.target = p
                Notif:push("target: "..p.Name,"ok")
            end)
            if isMobile then
                pb.TouchTap:Connect(function()
                    C.pov.target = p
                    Notif:push("target: "..p.Name,"ok")
                end)
            end
            pb.MouseEnter:Connect(function() U:tw(pb,{BackgroundColor3=C.fg3,BorderColor3=rc},0.08) end)
            pb.MouseLeave:Connect(function() U:tw(pb,{BackgroundColor3=C.bg2,BorderColor3=C.dim},0.08) end)
        end
    end
    if #Players:GetPlayers() <= 1 then
        mk("TextLabel",{Size=UDim2.new(1,0,0,math.floor(18*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=C.dim,Text="   -- no other players --",TextXAlignment=Enum.TextXAlignment.Left,Parent=self.povList})
    end
end

-- TAB: ON POINT
function GUI.buildOP(self)
    local t = self.tabs["ONPOINT"]
    self:hdr("on point",t)
    self:cmt("debug indicator when target in pov circle",t)
    self:cmt("tracks hitbox, collision, damage area",t)
    self:sep(t)
    self:tog("onpoint.enabled",t,C.op.on,function(s) C.op.on=s OP_M:toggle(s) Notif:push("onpoint "..(s and "on" or "off"),s and "ok" or "wrn") end)
    self:tog("onpoint.smooth",t,C.op.smooth,function(s) C.op.smooth=s end)
    self:spc(t)
    self:sld("onpoint.size",t,10,200,C.op.r,function(v) C.op.r=math.floor(v) end)
    self:sld("onpoint.transparency",t,0,1,C.op.alpha,function(v) C.op.alpha=v end)
    self:sep(t)
    self.opStat = self:line("status = waiting",t,C.fg2)
end

-- TAB: SYSTEM
function GUI.buildSYS(self)
    local t = self.tabs["SYSTEM"]
    self:hdr("system",t)
    self:sep(t)
    self:line("name    = 'hoshi'",t,C.fg)
    self:line("version = '"..C.ver.."'",t,C.fg2)
    self:line("user    = '"..LP.Name.."'",t,C.fg2)
    self:line("uid     = "..tostring(LP.UserId),t,C.fg2)
    self:line("place   = "..tostring(game.PlaceId),t,C.fg2)
    self:line("game    = "..tostring(game.GameId),t,C.fg2)
    self:sep(t)
    self:btn("disable_all()",t,function()
        C.esp.on=false C.tp.on=false C.pov.on=false C.op.on=false C.spd.val=1
        ESP_M:toggle(false) POV_M:toggle(false) OP_M:toggle(false) SPD_M:apply(1)
        Notif:push("all modules off","ok")
    end)
    self:btn("destroy()",t,function()
        Notif:push("shutting down...","wrn")
        task.delay(1,function() pcall(_G.HOSHI_KILL) end)
    end)
    self:sep(t)
    self:hdr("log",t)
    self.logBox = mk("Frame",{Size=UDim2.new(1,-4,0,8),BackgroundColor3=C.bg2,BorderSizePixel=1,BorderColor3=C.sep,AutomaticSize=Enum.AutomaticSize.Y,ClipsDescendants=true,Parent=t})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0),Parent=self.logBox})
    mk("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2),PaddingLeft=UDim.new(0,3),Parent=self.logBox})
    self:addLog("init complete")
    self:addLog("modules loaded")
    self:addLog("ready")
end

function GUI.addLog(self,msg)
    if not self.logBox then return end
    mk("TextLabel",{Size=UDim2.new(1,0,0,math.floor(13*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,Text="["..U:time().."] "..msg,Parent=self.logBox})
    local ch = {}
    for _,c in pairs(self.logBox:GetChildren()) do
        if c:IsA("TextLabel") then table.insert(ch,c) end
    end
    while #ch > 60 do ch[1]:Destroy() table.remove(ch,1) end
end

-- Toggle window
function GUI.toggle(self)
    self.visible = not self.visible
    if self.visible then
        self.main.Visible = true
        self.main.Size = UDim2.new(0,4,0,4)
        self.main.Position = UDim2.new(0.5,-2,0.5,-2)
        U:tw(self.main,{Size=UDim2.new(0,defW,0,defH),Position=UDim2.new(0.5,-defW/2,0.5,-defH/2)},0.35,Enum.EasingStyle.Back)
    else
        local p = self.main.Position
        local s = self.main.AbsoluteSize
        U:tw(self.main,{Size=UDim2.new(0,4,0,4),Position=UDim2.new(p.X.Scale,p.X.Offset+s.X/2,p.Y.Scale,p.Y.Offset+s.Y/2)},0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        task.delay(0.28,function()
            if not self.visible then self.main.Visible = false end
        end)
    end
end

-- Minimize
function GUI.minimize(self)
    self.mini = not self.mini
    if self.mini then
        self.restoreH = self.main.AbsoluteSize.Y
        U:tw(self.main,{Size=UDim2.new(0,self.main.AbsoluteSize.X,0,barH)},0.2)
    else
        U:tw(self.main,{Size=UDim2.new(0,self.main.AbsoluteSize.X,0,self.restoreH)},0.2)
    end
end

-- ============================================================
-- SPLASH / BOOT SEQUENCE
-- ============================================================
function GUI.splash(self)
    local sg = mk("ScreenGui",{Name="HoshiSplash",ResetOnSpawn=false,DisplayOrder=1020,IgnoreGuiInset=true,Parent=CoreGui})
    U:ai(sg)

    local bg = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.black,BorderSizePixel=0,Parent=sg})

    local box = mk("Frame",{Size=UDim2.new(0,math.floor(520*scaleFactor),0,math.floor(360*scaleFactor)),Position=UDim2.new(0.5,-math.floor(260*scaleFactor),0.5,-math.floor(180*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=1,BorderColor3=C.fg,Parent=bg})

    local boxTitle = mk("Frame",{Size=UDim2.new(1,0,0,math.floor(20*scaleFactor)),BackgroundColor3=C.bg2,BorderSizePixel=0,Parent=box})
    mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.fg,BorderSizePixel=0,Parent=boxTitle})
    mk("TextLabel",{Size=UDim2.new(1,-4,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=C.fg,TextXAlignment=Enum.TextXAlignment.Left,Text="hoshi@boot:~$ ./init.sh",Parent=boxTitle})

    local out = mk("ScrollingFrame",{Size=UDim2.new(1,-6,1,-math.floor(24*scaleFactor)),Position=UDim2.new(0,3,0,math.floor(22*scaleFactor)),BackgroundTransparency=1,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=box})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0),Parent=out})

    local lines = {
        {t="",c=C.fg,d=0},
        {t=" ##  ##  #####  ######  ##  ##  ##",c=C.fg,d=0.02},
        {t=" ##  ## ##   ## ##      ##  ##  ##",c=C.fg,d=0.04},
        {t=" ###### ##   ##  ##### ######  ##",c=C.fg,d=0.06},
        {t=" ##  ## ##   ##      ## ##  ##  ##",c=C.fg,d=0.08},
        {t=" ##  ##  #####  ###### ##  ##  ##",c=C.fg,d=0.10},
        {t="",c=C.fg,d=0.12},
        {t=" admin development tools v"..C.ver,c=C.fg2,d=0.18},
        {t=" ========================================",c=C.sep,d=0.22},
        {t="",c=C.fg,d=0.25},
        {t=" [boot] starting kernel...",c=C.dim,d=0.35},
        {t=" [load] Players ................. ok",c=C.fg,d=0.50},
        {t=" [load] RunService .............. ok",c=C.fg,d=0.62},
        {t=" [load] TweenService ............ ok",c=C.fg,d=0.72},
        {t=" [load] UserInputService ........ ok",c=C.fg,d=0.82},
        {t=" [load] Camera .................. ok",c=C.fg,d=0.90},
        {t="",c=C.fg,d=0.95},
        {t=" [init] esp module .............. ok",c=C.fg,d=1.05},
        {t=" [init] teleport module ......... ok",c=C.fg,d=1.18},
        {t=" [init] speed module ............ ok",c=C.fg,d=1.30},
        {t=" [init] pov module .............. ok",c=C.fg,d=1.42},
        {t=" [init] onpoint module .......... ok",c=C.fg,d=1.54},
        {t=" [init] terminal ui ............. ok",c=C.fg,d=1.66},
        {t="",c=C.fg,d=1.70},
        {t=" [sys] user: "..LP.Name,c=C.fg2,d=1.80},
        {t=" [sys] place: "..tostring(game.PlaceId),c=C.fg2,d=1.88},
        {t="",c=C.fg,d=1.92},
        {t=" ========================================",c=C.sep,d=2.00},
        {t=" [done] all systems operational",c=C.bright,d=2.10},
        {t=" [done] click [H] to open terminal",c=C.yellow,d=2.20},
        {t="",c=C.fg,d=2.25},
    }

    for idx,ld in ipairs(lines) do
        task.spawn(function()
            task.wait(ld.d)
            if not out or not out.Parent then return end
            local lb = mk("TextLabel",{Size=UDim2.new(1,0,0,math.floor(13*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=C.FontSizeASCII or C.tss,TextColor3=ld.c,TextXAlignment=Enum.TextXAlignment.Left,Text="",LayoutOrder=idx,Parent=out})

            -- Typing effect for content lines
            local full = ld.t
            if #full > 0 and ld.d >= 0.35 then
                local step = math.max(1,math.floor(#full/6))
                local pos = 0
                while pos < #full do
                    pos = math.min(pos+step,#full)
                    if lb and lb.Parent then
                        lb.Text = string.sub(full,1,pos).."_"
                    end
                    task.wait(0.008)
                end
                if lb and lb.Parent then lb.Text = full end
            else
                lb.Text = full
            end
        end)
    end

    -- Blinking cursor
    task.spawn(function()
        task.wait(0.4)
        if not out or not out.Parent then return end
        local cur = mk("TextLabel",{Size=UDim2.new(1,0,0,math.floor(13*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=C.tss,TextColor3=C.fg,TextXAlignment=Enum.TextXAlignment.Left,Text=" > _",LayoutOrder=999,Parent=out})
        local blink = true
        for i=1,16 do
            task.wait(0.25)
            if cur and cur.Parent then
                blink = not blink
                cur.Text = blink and " > _" or " >  "
            end
        end
    end)

    -- Fade out
    task.spawn(function()
        task.wait(3.8)
        if bg and bg.Parent then
            U:tw(bg,{BackgroundTransparency=1},0.8)
            for _,d in pairs(bg:GetDescendants()) do
                if d:IsA("TextLabel") then U:tw(d,{TextTransparency=1},0.6) end
                if d:IsA("Frame") then U:tw(d,{BackgroundTransparency=1},0.6) pcall(function() U:tw(d,{BorderColor3=C.black},0.6) end) end
                if d:IsA("ScrollingFrame") then U:tw(d,{ScrollBarImageTransparency=1},0.6) end
            end
            task.wait(0.9)
            pcall(function() sg:Destroy() end)
        end
    end)
end

-- ============================================================
-- MODULE: ESP
-- ============================================================
ESP_M = {}
ESP_M.objs = {}
ESP_M.running = false

function ESP_M.toggle(self,s)
    if s then self:start() else self:stop() end
end

function ESP_M.start(self)
    if self.running then return end
    self.running = true
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP then self:create(p) end
    end
    U:ac(Players.PlayerAdded:Connect(function(p)
        if C.esp.on and p~=LP then task.wait(1) self:create(p) end
    end))
    U:ac(Players.PlayerRemoving:Connect(function(p) self:remove(p) end))
    GUI:addLog("esp started")
end

function ESP_M.stop(self)
    self.running = false
    for p,d in pairs(self.objs) do self:kill(d) end
    self.objs = {}
    GUI:addLog("esp stopped")
end

function ESP_M.create(self,p)
    if self.objs[p] then return end
    local d = {}

    d.bb = Instance.new("BillboardGui")
    d.bb.Name = "HESP"
    d.bb.AlwaysOnTop = true
    d.bb.Size = UDim2.new(0,math.floor(160*scaleFactor),0,math.floor(65*scaleFactor))
    d.bb.StudsOffset = Vector3.new(0,3.5,0)
    d.bb.LightInfluence = 0
    d.bb.MaxDistance = 500

    local inf = mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.black,BackgroundTransparency=0.45,BorderSizePixel=1,BorderColor3=C.fg,Parent=d.bb})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center,Padding=UDim.new(0,0),Parent=inf})
    mk("UIPadding",{PaddingTop=UDim.new(0,2),Parent=inf})

    d.nm = mk("TextLabel",{Size=UDim2.new(1,-4,0,math.floor(14*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=math.floor(12*scaleFactor),TextColor3=C.fg,Text=p.Name,LayoutOrder=1,Parent=inf})
    d.rl = mk("TextLabel",{Size=UDim2.new(1,-4,0,math.floor(12*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=math.floor(10*scaleFactor),TextColor3=C.fg2,Text="[?]",LayoutOrder=2,Parent=inf})
    d.dt = mk("TextLabel",{Size=UDim2.new(1,-4,0,math.floor(12*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=math.floor(10*scaleFactor),TextColor3=C.fg2,Text="--st",LayoutOrder=3,Parent=inf})
    d.hl = mk("TextLabel",{Size=UDim2.new(1,-4,0,math.floor(12*scaleFactor)),BackgroundTransparency=1,Font=C.font,TextSize=math.floor(10*scaleFactor),TextColor3=C.fg,Text="hp:--",LayoutOrder=4,Parent=inf})

    d.hi = Instance.new("Highlight")
    d.hi.FillTransparency = 0.82
    d.hi.OutlineTransparency = 0.25
    d.hi.OutlineColor3 = C.fg
    d.hi.FillColor3 = C.fg3
    d.hi.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    d.inf = inf
    self.objs[p] = d

    local function attach(ch)
        if not ch then return end
        task.spawn(function()
            task.wait(0.3)
            if not d.bb then return end
            local ad = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
            if ad then d.bb.Adornee=ad d.bb.Parent=CoreGui end
            if d.hi then d.hi.Adornee=ch d.hi.Parent=CoreGui end
        end)
    end

    if p.Character then attach(p.Character) end
    d.cc = p.CharacterAdded:Connect(function(ch) attach(ch) end)
    U:ac(d.cc)
end

function ESP_M.remove(self,p)
    local d = self.objs[p]
    if d then self:kill(d) self.objs[p]=nil end
end

function ESP_M.kill(self,d)
    pcall(function() if d.bb then d.bb:Destroy() end end)
    pcall(function() if d.hi then d.hi:Destroy() end end)
    pcall(function() if d.cc then d.cc:Disconnect() end end)
end

function ESP_M.update(self)
    if not C.esp.on then return end
    for p,d in pairs(self.objs) do
        if not p or not p.Parent then self:kill(d) self.objs[p]=nil continue end
        local ch = U:char(p)
        if not ch then
            if d.bb then d.bb.Enabled=false end
            if d.hi then d.hi.Enabled=false end
            continue
        end

        if d.bb then
            local hd = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
            if hd then
                if d.bb.Adornee~=hd then d.bb.Adornee=hd end
                if not d.bb.Parent then d.bb.Parent=CoreGui end
            end
            d.bb.Enabled=true
        end
        if d.hi then
            if d.hi.Adornee~=ch then d.hi.Adornee=ch end
            if not d.hi.Parent then d.hi.Parent=CoreGui end
            d.hi.Enabled=C.esp.box
        end

        local r = U:role(p)
        local rc = U:rcol(r)

        if d.nm then d.nm.Visible=C.esp.name d.nm.Text=p.Name d.nm.TextColor3=rc end
        if d.rl then d.rl.Visible=C.esp.role d.rl.Text="["..r.."]" d.rl.TextColor3=rc end
        if d.dt then
            d.dt.Visible=C.esp.dist
            local ds = U:dist(p)
            d.dt.Text = ds<math.huge and (math.floor(ds).."st") or "--st"
        end
        if d.hl then
            d.hl.Visible=C.esp.hp
            local hp,mhp = U:hp(p)
            d.hl.Text="hp:"..math.floor(hp).."/"..math.floor(mhp)
            local pct=hp/math.max(mhp,1)
            d.hl.TextColor3 = pct>0.6 and C.fg or (pct>0.3 and C.yellow or C.red)
        end
        if d.hi then d.hi.OutlineColor3=rc d.hi.FillColor3=U:rcold(r) end
        if d.inf then d.inf.BorderColor3=rc end
    end
end

-- ============================================================
-- MODULE: TELEPORT SAFETY
-- ============================================================
TP_M = {}

function TP_M.findKillers(self)
    local k = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and U:role(p)=="Killer" then table.insert(k,p) end
    end
    return k
end

function TP_M.findSafe(self,kpos,mpos)
    local dist = C.tp.dist
    local away = (mpos-kpos)
    away = Vector3.new(away.X,0,away.Z)
    if away.Magnitude<0.1 then away=Vector3.new(1,0,0) end
    away = away.Unit

    local cands = {away}
    for a=-60,60,15 do
        local r=math.rad(a)
        table.insert(cands,Vector3.new(away.X*math.cos(r)-away.Z*math.sin(r),0,away.X*math.sin(r)+away.Z*math.cos(r)).Unit)
    end
    for i=1,5 do
        local ra=math.random()*math.pi*2
        table.insert(cands,Vector3.new(math.cos(ra),0,math.sin(ra)))
    end

    local killers = self:findKillers()
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local mc = U:char(LP)
    if mc then rp.FilterDescendantsInstances={mc} end

    for _,dir in ipairs(cands) do
        local tp = mpos + dir*dist
        tp = Vector3.new(tp.X,mpos.Y,tp.Z)
        local ray = workspace:Raycast(tp+Vector3.new(0,60,0),Vector3.new(0,-250,0),rp)
        if ray then tp = ray.Position+Vector3.new(0,4,0) end

        local safe = true
        for _,kp in ipairs(killers) do
            local kr = U:root(kp)
            if kr and (tp-kr.Position).Magnitude < C.tp.radius*2 then safe=false break end
        end
        if safe then return tp end
    end

    local fa = math.random()*math.pi*2
    return mpos+Vector3.new(math.cos(fa)*dist,4,math.sin(fa)*dist)
end

function TP_M.check(self)
    if not C.tp.on then return end
    local now = tick()
    if now-C.tp.last < C.tp.cd then return end
    local mr = U:root(LP)
    if not mr then return end

    for _,k in ipairs(self:findKillers()) do
        local kr = U:root(k)
        if kr then
            local d = (mr.Position-kr.Position).Magnitude
            if d <= C.tp.radius then
                local sp = self:findSafe(kr.Position,mr.Position)
                mr.CFrame = CFrame.new(sp)
                C.tp.last = now
                Notif:push("escaped "..k.Name.." ("..math.floor(d).."st)","wrn")
                GUI:addLog("tp.escape("..k.Name..","..math.floor(d).."st)")
                if GUI.tpStat and GUI.tpStat.Parent then
                    GUI.tpStat.Text = " --- status = escaped "..k.Name.." @ "..U:time()
                    GUI.tpStat.TextColor3 = C.yellow
                end
                break
            end
        end
    end
end

-- ============================================================
-- MODULE: SPEED
-- ============================================================
SPD_M = {}

function SPD_M.apply(self,m)
    local h = U:hum(LP)
    if h then
        local ns = C.spd.base*m
        h.WalkSpeed = ns
        if GUI.spdStat and GUI.spdStat.Parent then
            GUI.spdStat.Text = " --- current = "..math.floor(ns).." studs/s ("..(math.floor(m*10)/10).."x)"
        end
    end
end

-- ============================================================
-- MODULE: POV CIRCLE
-- ============================================================
POV_M = {}
POV_M.circle = nil
POV_M.gui = nil
POV_M.useDrawing = false

function POV_M.toggle(self,s)
    if s then self:create() else self:destroy() end
end

function POV_M.create(self)
    self:destroy()
    local ok = pcall(function() local t=Drawing.new("Circle") t:Remove() end)
    if ok then
        self.useDrawing = true
        self.circle = Drawing.new("Circle")
        self.circle.Color = C.pov.col
        self.circle.Thickness = C.pov.thick
        self.circle.Radius = C.pov.r
        self.circle.Filled = false
        self.circle.Transparency = C.pov.alpha
        self.circle.NumSides = 72
        self.circle.Visible = true
        local vp = Camera.ViewportSize
        self.circle.Position = Vector2.new(vp.X/2,vp.Y/2)
    else
        self.useDrawing = false
        self:createGUI()
    end
end

function POV_M.createGUI(self)
    self:destroy()
    self.gui = mk("ScreenGui",{Name="HoshiPOV",ResetOnSpawn=false,DisplayOrder=997,Parent=CoreGui})
    U:ai(self.gui)

    local cf = mk("Frame",{Size=UDim2.new(0,C.pov.r*2,0,C.pov.r*2),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1,Parent=self.gui})

    local segs = 72
    for i=1,segs do
        local a1 = ((i-1)/segs)*math.pi*2
        local a2 = (i/segs)*math.pi*2
        local x1,y1 = math.cos(a1)*C.pov.r, math.sin(a1)*C.pov.r
        local x2,y2 = math.cos(a2)*C.pov.r, math.sin(a2)*C.pov.r
        local dx,dy = x2-x1, y2-y1
        local len = math.sqrt(dx*dx+dy*dy)
        local ang = math.atan2(dy,dx)
        mk("Frame",{Size=UDim2.new(0,len+1,0,C.pov.thick),Position=UDim2.new(0.5,x1,0.5,y1),Rotation=math.deg(ang),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=C.pov.col,BackgroundTransparency=1-C.pov.alpha,BorderSizePixel=0,Parent=cf})
    end

    self.circleFrame = cf
end

function POV_M.rebuild(self)
    if C.pov.on then self:create() end
end

function POV_M.destroy(self)
    if self.circle then pcall(function() self.circle:Remove() end) self.circle=nil end
    if self.gui then pcall(function() self.gui:Destroy() end) self.gui=nil end
    self.circleFrame = nil
end

function POV_M.tick(self)
    if not C.pov.on then return end
    if self.useDrawing and self.circle then
        local vp = Camera.ViewportSize
        self.circle.Position = Vector2.new(vp.X/2,vp.Y/2)
    end
end

function POV_M.followCam(self)
    if not C.pov.follow or not C.pov.target then return end
    local t = C.pov.target
    if not t or not t.Parent then C.pov.target=nil return end
    local tr = U:root(t)
    if not tr then return end
    local cf = CFrame.lookAt(Camera.CFrame.Position,tr.Position)
    Camera.CFrame = Camera.CFrame:Lerp(cf,0.08)
end

function POV_M.isInCircle(self)
    if not C.pov.target then return false end
    local t = C.pov.target
    if not t or not t.Parent then return false end
    local tr = U:root(t)
    if not tr then return false end
    local sp,on = U:w2s(tr.Position)
    if not on then return false end
    local vp = Camera.ViewportSize
    local ct = Vector2.new(vp.X/2,vp.Y/2)
    return (sp-ct).Magnitude <= C.pov.r
end

-- ============================================================
-- MODULE: ON POINT
-- ============================================================
OP_M = {}
OP_M.ind = nil
OP_M.hLine = nil
OP_M.vLine = nil
OP_M.lbl = nil
OP_M.corners = {}

function OP_M.toggle(self,s)
    if not s then self:kill() end
end

function OP_M.kill(self)
    if self.ind then pcall(function() self.ind:Destroy() end) self.ind=nil end
    self.hLine=nil self.vLine=nil self.lbl=nil self.corners={}
end

function OP_M.build(self)
    if self.ind then return end
    self.ind = mk("Frame",{Name="HOP",Size=UDim2.new(0,C.op.r*2,0,C.op.r*2),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1,ZIndex=50,Parent=GUI.mainG})

    self.hLine = mk("Frame",{Size=UDim2.new(0,C.op.r*2,0,2),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=C.op.col,BackgroundTransparency=C.op.alpha,BorderSizePixel=0,ZIndex=51,Parent=self.ind})
    self.vLine = mk("Frame",{Size=UDim2.new(0,2,0,C.op.r*2),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=C.op.col,BackgroundTransparency=C.op.alpha,BorderSizePixel=0,ZIndex=51,Parent=self.ind})

    self.corners = {}
    local cps = {{-1,-1},{1,-1},{-1,1},{1,1}}
    for _,cp in ipairs(cps) do
        local c = mk("Frame",{Size=UDim2.new(0,8,0,8),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,cp[1]*C.op.r*0.4,0.5,cp[2]*C.op.r*0.4),Rotation=45,BackgroundColor3=C.op.col,BackgroundTransparency=C.op.alpha,BorderSizePixel=0,ZIndex=51,Parent=self.ind})
        table.insert(self.corners,c)
    end

    self.lbl = mk("TextLabel",{Size=UDim2.new(0,200,0,16),AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,1,6),BackgroundColor3=C.black,BackgroundTransparency=0.4,BorderSizePixel=1,BorderColor3=C.op.col,Font=C.font,TextSize=C.tss,TextColor3=C.op.col,Text="on_point",ZIndex=52,Parent=self.ind})

    U:ai(self.ind)
end

function OP_M.update(self)
    if not C.op.on then
        if self.ind then self.ind.Visible=false end
        return
    end

    if not C.pov.target then
        if self.ind then self.ind.Visible=false end
        if GUI.opStat and GUI.opStat.Parent then
            GUI.opStat.Text=" --- status = no_target" GUI.opStat.TextColor3=C.dim
        end
        return
    end

    local t = C.pov.target
    if not t or not t.Parent then C.pov.target=nil if self.ind then self.ind.Visible=false end return end
    local tr = U:root(t)
    if not tr then if self.ind then self.ind.Visible=false end return end

    local sp,on = U:w2s(tr.Position)

    if not on then
        if self.ind then self.ind.Visible=false end
        if GUI.opStat and GUI.opStat.Parent then
            GUI.opStat.Text=" --- status = offscreen" GUI.opStat.TextColor3=C.yellow
        end
        return
    end

    local vp = Camera.ViewportSize
    local ct = Vector2.new(vp.X/2,vp.Y/2)
    local dfc = (sp-ct).Magnitude

    if dfc <= C.pov.r then
        if not self.ind then self:build() end
        self.ind.Visible = true

        local tgt = UDim2.new(0,sp.X,0,sp.Y)
        if C.op.smooth then
            U:tw(self.ind,{Position=tgt},0.05,Enum.EasingStyle.Linear)
        else
            self.ind.Position = tgt
        end

        local sz = C.op.r*2
        self.ind.Size = UDim2.new(0,sz,0,sz)
        if self.hLine then self.hLine.Size=UDim2.new(0,sz,0,2) self.hLine.BackgroundTransparency=C.op.alpha self.hLine.BackgroundColor3=C.op.col end
        if self.vLine then self.vLine.Size=UDim2.new(0,2,0,sz) self.vLine.BackgroundTransparency=C.op.alpha self.vLine.BackgroundColor3=C.op.col end

        local cps={{-1,-1},{1,-1},{-1,1},{1,1}}
        for i,corner in ipairs(self.corners) do
            if cps[i] then
                corner.Position=UDim2.new(0.5,cps[i][1]*C.op.r*0.4,0.5,cps[i][2]*C.op.r*0.4)
                corner.BackgroundColor3=C.op.col corner.BackgroundTransparency=C.op.alpha
            end
        end

        if self.lbl then
            local d = U:dist(t)
            local hp,mhp = U:hp(t)
            self.lbl.Text=t.Name.." | "..math.floor(d).."st | hp:"..math.floor(hp).."/"..math.floor(mhp)
            self.lbl.BorderColor3=C.op.col self.lbl.TextColor3=C.op.col
        end

        if GUI.opStat and GUI.opStat.Parent then
            GUI.opStat.Text=" --- status = locked:"..t.Name GUI.opStat.TextColor3=C.fg
        end
    else
        if self.ind then self.ind.Visible=false end
        if GUI.opStat and GUI.opStat.Parent then
            GUI.opStat.Text=" --- status = outside_circle" GUI.opStat.TextColor3=C.fg2
        end
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
local function startLoop()
    U:ac(RunService.RenderStepped:Connect(function()
        if C.esp.on then ESP_M:update() end
        if C.pov.on then POV_M:tick() end
        if C.pov.on and C.pov.follow then POV_M:followCam() end
        if C.op.on then OP_M:update() end
    end))

    U:ac(RunService.Heartbeat:Connect(function()
        if C.tp.on then TP_M:check() end

        if C.spd.val~=1 then
            local h=U:hum(LP)
            if h then
                local ex=C.spd.base*C.spd.val
                if math.abs(h.WalkSpeed-ex)>1 then h.WalkSpeed=ex end
            end
        end

        if C.tp.on and GUI.tpStat and GUI.tpStat.Parent then
            local rem = C.tp.cd-(tick()-C.tp.last)
            if rem > 0 then
                GUI.tpStat.Text=" --- status = cooldown:"..string.format("%.1f",rem).."s"
                GUI.tpStat.TextColor3=C.yellow
            else
                local nd,nn = math.huge,"none"
                for _,p in pairs(Players:GetPlayers()) do
                    if p~=LP and U:role(p)=="Killer" then
                        local d=U:dist(p)
                        if d<nd then nd=d nn=p.Name end
                    end
                end
                if nd<math.huge then
                    GUI.tpStat.Text=" --- status = armed | nearest:"..nn.." ("..math.floor(nd).."st)"
                    GUI.tpStat.TextColor3 = nd<C.tp.radius*1.5 and C.red or (nd<C.tp.radius*3 and C.yellow or C.fg)
                else
                    GUI.tpStat.Text=" --- status = armed | no killers"
                    GUI.tpStat.TextColor3=C.fg2
                end
            end
        end
    end))

    U:ac(LP.CharacterAdded:Connect(function()
        task.wait(1.5)
        if C.spd.val~=1 then SPD_M:apply(C.spd.val) end
        GUI:addLog("respawned, reattached")
        Notif:push("respawned, modules reloaded","sys")
    end))
end

-- ============================================================
-- CLEANUP
-- ============================================================
_G.HOSHI_KILL = function()
    C.esp.on=false C.tp.on=false C.pov.on=false C.op.on=false C.spd.val=1
    pcall(function() local h=U:hum(LP) if h then h.WalkSpeed=C.spd.base end end)
    pcall(function() ESP_M:stop() end)
    pcall(function() POV_M:destroy() end)
    pcall(function() OP_M:kill() end)
    U:clean()
    for _,n in ipairs({"HoshiMain","HoshiBtn","HoshiSplash","HoshiNotif","HoshiPOV"}) do
        pcall(function() local g=CoreGui:FindFirstChild(n) if g then g:Destroy() end end)
    end
end

-- ============================================================
-- RUN
-- ============================================================
Notif:init()
GUI:buildBtn()
GUI:buildMain()
GUI:splash()
startLoop()

task.delay(4.5,function()
    Notif:push("hoshi v"..C.ver.." loaded","ok")
    Notif:push("click [H] to open","sys")
    GUI:addLog("operational")
end)

end -- Boot()

local ok,err = pcall(Boot)
if not ok then warn("[HOSHI] "..tostring(err)) end