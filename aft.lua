--// ============================================================
--//  RELWX HUB × UGC v3  |  Challenge + Farm + Merchant + Auto Leave
--//  - ปรับขนาดตามหน้าจออัตโนมัติ (+ ปรับเพิ่ม/ลดเองได้ในตั้งค่า)
--//  - ทุกอย่างผูกกับ Config และเซฟอัตโนมัติ
--//  - เพิ่มฟังก์ชันใหม่: ดูหัวข้อ "ADD YOUR FUNCTIONS"
--// ============================================================

do
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, n in ipairs({ "RELWX_UI", "RELWX_Stats", "RELWX_Floating" }) do
        local o = pg:FindFirstChild(n)
        if o then
            o:Destroy()
        end
    end
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")

-- ฟอนต์ UI  (เปลี่ยนได้: "Montserrat" | "BuilderSans" | "Gotham")
local UI_FONT = "Montserrat"
local function E(name)
    local ok, v = pcall(function()
        return Enum.Font[name]
    end)
    return ok and v or Enum.Font.Gotham
end
local FontFamilies = {
    Montserrat = { R = E("Montserrat"), M = E("MontserratMedium"), B = E("MontserratBold") },
    BuilderSans = { R = E("BuilderSans"), M = E("BuilderSansMedium"), B = E("BuilderSansBold") },
    Gotham = { R = Enum.Font.Gotham, M = Enum.Font.GothamMedium, B = Enum.Font.GothamBold },
}
local FNT = FontFamilies[UI_FONT] or FontFamilies.Gotham

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- เสียงตอนกดเปิด/ปิด (เปลี่ยน ID ได้ตามชอบ เช่น "rbxassetid://1234567")
local SOUND_ON = "rbxasset://sounds/switch.wav"
local SOUND_OFF = "rbxasset://sounds/button.wav"
local SOUND_FALLBACK = "rbxasset://sounds/electronicpingshort.wav" -- ใช้ถ้าเสียงข้างบนโหลดไม่ได้

--==================================================
-- CONFIG  (Auto Save / Auto Load)
--==================================================

local CONFIG_FILE = "RELWX_UGC_Config.json"

local Defaults = {
    -- สี
    UIAccentColor = "#C9CBD3",
    UIBackgroundColor = "#0A0A0C",
    UIButtonColor = "#232328",
    FloatingButtonColor = "#101012",
    FloatingBorderColor = "#E4E4EA",
    FloatingGlowColor = "#8E8E98",
    -- ฟังก์ชัน
    -- UGC: Challenge
    AutoChallenge = false,
    ChWeekly = true,
    ChDaily = true,
    ChNormal = true,
    -- UGC: ฟาร์ม Story / Frontier / Raid
    AutoFarm = false,
    FarmMode = "Story",
    FarmStage = "",
    FarmAct = 1,
    FarmDiff = "Normal",
    ChallengeFirst = true,
    ChInterrupt = false,
    FarmReplay = true,
    -- UGC: ตั้งค่าห้อง
    ChFriends = true,
    ChStart = true,
    ChTp = false,
    ChStartDelay = 2,
    ChRescan = 20,
    -- UGC: ร้านค้า
    AutoBuy = false,
    BuyDelay = 1,
    BuyRescan = 15,
    Buy_Pirate_Giant_Meat = true,
    Buy_Devil_Fruit_Cake = true,
    Buy_Flame_Hashira_Bento = true,
    Buy_Wisteria_Dango = true,
    Buy_Sweet_Cream_Mochi = true,
    Buy_Cursed_Finger_Parfait = true,
    Buy_Rare_Fragment = true,
    Buy_Epic_Fragment = true,
    Buy_Legendary_Fragment = true,
    Buy_Mythical_Fragment = true,
    Buy_Secret_Fragment = true,
    Buy_Trait_Shard = true,
    Buy_Stats_Reroll = true,
    Buy_Stat_Dice = true,
    Buy_DNA_Fragment = true,
    Buy_Lucky_Potion__1_Hour_ = true,
    -- UGC: ออโต้ในด่าน
    AutoUpgrade = true,
    AutoUltimate = true,
    AutoPlayGame = false,
    -- UGC: ออกจากด่าน
    AutoLeave = true,
    LeaveByTeleport = true,
    LeaveBySetting = true,
    LeaveByButton = false,
    LeaveDelay = 3,
    LeaveRetry = 6,
    AntiAfk = true,
    -- ระบบ
    SoundEnabled = true,
    StatsVisible = true,
    UIScalePercent = 100,
    -- สถานะ UI
    LastTab = "Home",
    WindowVisible = true,
    Maximized = false,
    CollapsedSections = "",
    WindowX = 0.5,
    WindowY = 0.5,
    FloatX = 0.04,
    FloatY = 0.25,
    StatsX = 0.5,
    StatsY = 0.045,
}

local Config = {}
for k, v in pairs(Defaults) do
    Config[k] = v
end

local LoadedFromFile = false

local function LoadConfig()
    if not (isfile and readfile) then
        return
    end
    local ok, exists = pcall(isfile, CONFIG_FILE)
    if not (ok and exists) then
        return
    end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(data) == "table" then
            for k, v in pairs(Defaults) do
                if type(data[k]) == type(v) then
                    Config[k] = data[k]
                end
            end
            LoadedFromFile = true
        end
    end)
end

LoadConfig()
for _, k in ipairs({ "WindowX", "WindowY" }) do
    Config[k] = math.clamp(Config[k], 0.05, 0.95)
end
for _, k in ipairs({ "FloatX", "FloatY", "StatsX", "StatsY" }) do
    Config[k] = math.clamp(Config[k], 0.02, 0.98)
end
Config.UIScalePercent = math.clamp(Config.UIScalePercent, 60, 120)

local SaveHooks = {}
local SaveToken = 0

local function Fire(state)
    for _, h in ipairs(SaveHooks) do
        pcall(h, state)
    end
end

local function WriteNow()
    if not writefile then
        return "unsupported"
    end
    local ok = pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
    return ok and "saved" or "failed"
end

local function SaveConfig(instant)
    SaveToken = SaveToken + 1
    local token = SaveToken
    Fire("saving")
    local function commit()
        if token ~= SaveToken then
            return
        end
        local result = WriteNow()
        Fire(result)
        if result == "saved" then
            task.delay(1.8, function()
                if token == SaveToken then
                    Fire("idle")
                end
            end)
        end
    end
    if instant then
        commit()
    else
        task.delay(0.3, commit)
    end
end

local function SetConfig(key, value)
    if Config[key] == value then
        return
    end
    Config[key] = value
    SaveConfig()
end

--==================================================
-- THEME  (ทุกสีใน UI คำนวณจาก Config และอัปเดตสดทันที)
--==================================================

local function RGB(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local function Lum(c)
    return 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
end

local function Hex(key, fallback)
    local ok, c = pcall(Color3.fromHex, Config[key])
    return ok and c or fallback
end

local Theme = {}

local function ComputeTheme()
    local bg = Hex("UIBackgroundColor", RGB(8, 8, 8))
    local dark = Lum(bg) < 0.5
    local to = dark and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
    Theme.Bg = bg
    Theme.Surface = bg:Lerp(to, 0.05)
    Theme.Surface2 = bg:Lerp(to, 0.095)
    Theme.Stroke = bg:Lerp(to, 0.17)
    Theme.Text = dark and RGB(244, 244, 244) or RGB(20, 20, 20)
    Theme.Sub = Theme.Text:Lerp(bg, 0.32)
    Theme.Muted = Theme.Text:Lerp(bg, 0.58)
    Theme.Accent = Hex("UIAccentColor", RGB(190, 190, 190))
    Theme.OnAccent = Lum(Theme.Accent) > 0.55 and RGB(15, 15, 15) or RGB(255, 255, 255)
    Theme.Button = Hex("UIButtonColor", RGB(36, 36, 36))
    local h, s, v = Theme.Accent:ToHSV()
    if s < 0.12 then
        Theme.Accent2 = Theme.Accent:Lerp(Color3.fromRGB(96, 104, 128), 0.6) -- เทา: ไล่เป็นเหล็กอมฟ้า
    else
        Theme.Accent2 = Color3.fromHSV((h + 0.12) % 1, s, math.max(v, 0.6))
    end
end

ComputeTheme()

local ThemeHooks = {}

local function OnTheme(fn)
    ThemeHooks[#ThemeHooks + 1] = fn
    pcall(fn)
end

local function Bind(obj, prop, key)
    OnTheme(function()
        obj[prop] = Theme[key]
    end)
end

local function ApplyTheme()
    ComputeTheme()
    for _, fn in ipairs(ThemeHooks) do
        pcall(fn)
    end
end

--==================================================
-- HELPERS
--==================================================

local Orders = setmetatable({}, { __mode = "k" })
local function Next(parent)
    Orders[parent] = (Orders[parent] or 0) + 1
    return Orders[parent]
end

local function New(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    return New("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function Pad(parent, l, r, t, b)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, parent)
end

local function List(parent, padding)
    return New("UIListLayout", {
        Padding = UDim.new(0, padding or 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, parent)
end

local function Text(parent, text, size, font, color, align)
    local l = New("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text or "",
        TextSize = size or 13,
        Font = font or FNT.R,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
    if type(color) == "string" then
        Bind(l, "TextColor3", color)
    elseif color then
        l.TextColor3 = color
    end
    return l
end

local function Tween(obj, t, props, style, dir)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function Apply(obj, animate, props)
    if animate then
        Tween(obj, 0.16, props)
    else
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
end

local function Panel(parent, size, class)
    local f = New(class or "Frame", { BorderSizePixel = 0, LayoutOrder = Next(parent) }, parent)
    if class == "TextButton" then
        f.Text = ""
        f.AutoButtonColor = false
    end
    if size then
        f.Size = size
    end
    Bind(f, "BackgroundColor3", "Surface")
    Corner(f, 12)
    Bind(Stroke(f, Theme.Stroke, 1, 0.4), "Color", "Stroke")
    New("UIGradient", {
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.76, 0.76, 0.76)),
        Rotation = 90,
    }, f)
    local hi = New("Frame", {
        Size = UDim2.new(1, -28, 0, 1),
        Position = UDim2.fromOffset(14, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
    }, f)
    New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, hi)
    return f
end

local function HoverRow(btn)
    local st = btn:FindFirstChildOfClass("UIStroke")
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.12, { BackgroundColor3 = Theme.Surface2 })
        if st then
            Tween(st, 0.12, { Transparency = 0.05 })
        end
    end)
    local sc
    if btn:IsA("GuiButton") then
        sc = New("UIScale", { Scale = 1 }, btn)
        btn.MouseButton1Down:Connect(function()
            Tween(sc, 0.08, { Scale = 0.982 })
        end)
        btn.MouseButton1Up:Connect(function()
            Tween(sc, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
        end)
    end
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.12, { BackgroundColor3 = Theme.Surface })
        if st then
            Tween(st, 0.12, { Transparency = 0.4 })
        end
        if sc then
            Tween(sc, 0.12, { Scale = 1 })
        end
    end)
end

-- ชั้นสีไล่เฉดอ่อนๆ ของ accent ใช้ตกแต่งการ์ด
-- ไล่เฉด Accent -> Accent2 (วัตถุที่ใช้ต้องตั้ง BackgroundColor3 เป็นสีขาว)
local function AccentGrad(parent, rotation)
    local g = New("UIGradient", { Rotation = rotation or 0 }, parent)
    OnTheme(function()
        g.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
    end)
    return g
end

local function Tint(parent)
    local t = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, parent)
    Corner(t, 12)
    local g = AccentGrad(t, 25)
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 1),
    })
    return t
end

local function IsPointer(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

-- ไอคอนวาดด้วย Frame (ไม่พึ่งรูป/asset) คืนค่าฟังก์ชันเปลี่ยนสี
local function Icon(parent, kind, x, y)
    local box = New("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromOffset(x, y),
        BackgroundTransparency = 1,
    }, parent)
    local parts = {}
    local function rect(px, py, w, h, r, rot)
        local f = New("Frame", {
            Size = UDim2.fromOffset(w, h),
            Position = UDim2.fromOffset(px, py),
            BorderSizePixel = 0,
            Rotation = rot or 0,
        }, box)
        Corner(f, r or 1)
        parts[#parts + 1] = { f = f }
        return f
    end
    if kind == "grid" then
        rect(1, 1, 7, 7, 2)
        rect(10, 1, 7, 7, 2)
        rect(1, 10, 7, 7, 2)
        rect(10, 10, 7, 7, 2)
    elseif kind == "sliders" then
        rect(1, 2, 16, 2, 1)
        rect(1, 8, 11, 2, 1)
        rect(1, 14, 14, 2, 1)
    elseif kind == "close" then
        rect(1, 8, 16, 2, 1, 45)
        rect(1, 8, 16, 2, 1, -45)
    elseif kind == "max" then
        local r = New("Frame", {
            Size = UDim2.fromOffset(12, 12),
            Position = UDim2.fromOffset(3, 3),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, box)
        Corner(r, 3)
        parts[#parts + 1] = { stroke = Stroke(r, Color3.new(1, 1, 1), 2, 0) }
    else -- ring (settings)
        local r = New("Frame", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromOffset(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, box)
        Corner(r, 8)
        parts[#parts + 1] = { stroke = Stroke(r, Color3.new(1, 1, 1), 2, 0) }
        rect(7, 7, 4, 4, 2)
    end
    return function(c)
        for _, p in ipairs(parts) do
            if p.stroke then
                p.stroke.Color = c
            else
                p.f.BackgroundColor3 = c
            end
        end
    end
end

--==================================================
-- ROOT GUI
--==================================================

pcall(function()
    for _, v in ipairs(PlayerGui:GetChildren()) do
        if v.Name == "RELWX_UI" or v.Name == "RELWX_Floating" or v.Name == "RELWX_Stats"
            or v.Name == "TwoSki_RideAPet_Floating" then
            v:Destroy()
        end
    end
end)

local Screen = New("ScreenGui", {
    Name = "RELWX_UI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999998,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

-- เก็บ connection ทั้งหมดไว้ ตัดทิ้งตอน UI ถูกทำลาย (รันสคริปต์ซ้ำได้ไม่ค้าง)
local Conns = {}
local function Track(c)
    Conns[#Conns + 1] = c
    return c
end
Screen.Destroying:Connect(function()
    for _, c in ipairs(Conns) do
        pcall(function()
            c:Disconnect()
        end)
    end
end)

local BW, BH = 740, 580 -- ขนาดออกแบบ (ปรับตามจอผ่าน UIScale)
local SW = 172 -- ความกว้าง sidebar

local function ViewSize()
    local s = Screen.AbsoluteSize
    if s.X > 0 and s.Y > 0 then
        return s
    end
    return workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
end

local function TargetScale()
    local v = ViewSize()
    local fit = math.min(v.X * 0.97 / BW, v.Y * 0.95 / BH)
    local base = math.min(fit * (Config.Maximized and 1 or 0.92), Config.Maximized and 1.4 or 1.1)
    local s = base * (Config.UIScalePercent / 100)
    return math.clamp(s, 0.3, math.max(0.3, fit))
end

local Main = New("CanvasGroup", {
    Name = "Main",
    Size = UDim2.fromOffset(BW, BH),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(Config.WindowX, Config.WindowY),
    BorderSizePixel = 0,
    BackgroundTransparency = 0.04,
    GroupTransparency = 1,
    Active = true,
    Visible = false,
}, Screen)
Bind(Main, "BackgroundColor3", "Bg")
Corner(Main, 18)

-- แสงพื้นหลัง (aurora) มุมซ้ายบน / ขวาล่าง
local function Aurora(key, rot)
    local f = New("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, Main)
    Bind(f, "BackgroundColor3", key)
    Corner(f, 18)
    New("UIGradient", {
        Rotation = rot,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.82),
            NumberSequenceKeypoint.new(0.55, 1),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, f)
end
Aurora("Accent", 35)
Aurora("Accent2", 215)

-- ฝุ่นแสงลอยช้าๆ เป็นพื้นหลัง
local Dust = New("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
}, Main)
for i = 1, 16 do
    local sz = math.random(2, 4)
    local x = math.random()
    local p = New("Frame", {
        Size = UDim2.fromOffset(sz, sz),
        Position = UDim2.fromScale(x, 1.05),
        BorderSizePixel = 0,
        BackgroundTransparency = 0.55 + math.random() * 0.3,
    }, Dust)
    Corner(p, 2)
    Bind(p, "BackgroundColor3", (i % 2 == 0) and "Accent" or "Accent2")
    local dur = 9 + math.random() * 9
    TweenService:Create(
        p,
        TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, math.random() * 5),
        { Position = UDim2.fromScale(math.clamp(x + (math.random() - 0.5) * 0.15, 0, 1), -0.05) }
    ):Play()
end

local MainStroke = Stroke(Main, Color3.new(1, 1, 1), 1.5, 0)
local MainGrad = New("UIGradient", { Rotation = 0 }, MainStroke)
OnTheme(function()
    MainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Stroke),
        ColorSequenceKeypoint.new(0.35, Theme.Accent),
        ColorSequenceKeypoint.new(0.65, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Stroke),
    })
end)
TweenService:Create(
    MainGrad,
    TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
    { Rotation = 360 }
):Play()
local MainScale = New("UIScale", { Scale = TargetScale() }, Main)

-- เงา + แสงเรืองใต้หน้าต่าง
local Shadow = New("Frame", {
    Size = UDim2.fromOffset(BW, BH),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    ZIndex = 0,
    Visible = false,
}, Screen)
local ShadowScale = New("UIScale", { Scale = 1 }, Shadow)
local ShadowLayers = {}
for i, g in ipairs({ 8, 20, 36, 56 }) do
    local l = New("Frame", {
        Size = UDim2.new(1, g * 2, 1, g * 2),
        Position = UDim2.fromOffset(-g, -g + 10),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(0, 0, 0),
    }, Shadow)
    Corner(l, 18 + g)
    ShadowLayers[i] = { f = l, base = 0.82 + i * 0.03 }
end
local ShadowGlow = New("Frame", {
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.fromOffset(-20, -20),
    BorderSizePixel = 0,
}, Shadow)
Corner(ShadowGlow, 38)
Bind(ShadowGlow, "BackgroundColor3", "Accent")
ShadowLayers[#ShadowLayers + 1] = { f = ShadowGlow, base = 0.95 }

Track(RunService.RenderStepped:Connect(function()
    local vis = Main.Visible
    Shadow.Visible = vis
    if not vis then
        return
    end
    Shadow.Position = Main.Position
    Shadow.Size = Main.Size
    ShadowScale.Scale = MainScale.Scale
    local a = Main.GroupTransparency
    for _, l in ipairs(ShadowLayers) do
        l.f.BackgroundTransparency = 1 - (1 - l.base) * (1 - a)
    end
end))

-- เส้นแสงด้านบนหน้าต่าง
local TopGlow = New("Frame", {
    Size = UDim2.new(0.8, 0, 0, 1),
    Position = UDim2.fromScale(0.1, 0),
    BorderSizePixel = 0,
}, Main)
Bind(TopGlow, "BackgroundColor3", "Accent")
New("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.15),
        NumberSequenceKeypoint.new(1, 1),
    }),
}, TopGlow)

local Opening = false

local function ApplyScale(animate)
    if Opening then
        return
    end
    if animate and Main.Visible then
        Tween(MainScale, 0.25, { Scale = TargetScale() }, Enum.EasingStyle.Quint)
    else
        MainScale.Scale = TargetScale()
    end
end

Track(Screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    ApplyScale(false)
end))

-- เปิด/ปิดหน้าต่างพร้อมเอฟเฟกต์ (ปิดแบบสโลว์: ค่อยๆ จางและหดลง)
-- เสียงเปิด/ปิด (ถ้าไฟล์เสียงโหลดไม่ขึ้น จะสลับไปใช้เสียงสำรองให้เอง)
local function PlayToggleSound(on, big)
    if not Config.SoundEnabled then
        return
    end
    pcall(function()
        local function play(id, vol, speed)
            local s = Instance.new("Sound")
            s.SoundId = id
            s.Volume = vol
            s.PlaybackSpeed = speed
            s.Parent = SoundService
            s:Play()
            Debris:AddItem(s, 2.5)
            return s
        end
        local speed = (on and 1.18 or 0.86) * (big and 0.85 or 1)
        local s = play(on and SOUND_ON or SOUND_OFF, big and 0.7 or 0.6, speed)
        task.delay(0.35, function()
            if s.Parent and s.TimeLength == 0 then
                play(SOUND_FALLBACK, 0.55, on and 1.35 or 0.85)
            end
        end)
    end)
end

-- ===== FX: วงคลื่น / ประกายไฟ / ลำแสง =====
local function FloatCenter()
    local s = Screen.AbsoluteSize
    return s.X * Config.FloatX, s.Y * Config.FloatY
end

local function FxRing(cx, cy, size, thick, dur, color)
    local r = New("Frame", {
        Size = UDim2.fromOffset(6, 6),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(cx, cy),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 60,
    }, Screen)
    Corner(r, 9999)
    local st = Stroke(r, color or Theme.Accent, thick, 0.05)
    Tween(r, dur, { Size = UDim2.fromOffset(size, size) }, Enum.EasingStyle.Quint)
    Tween(st, dur, { Transparency = 1, Thickness = 0.5 }, Enum.EasingStyle.Quad)
    Debris:AddItem(r, dur + 0.15)
end

local function FxSparks(cx, cy, spread, count, dist)
    for i = 1, count do
        local ang = math.random() * math.pi * 2
        local d = dist * (0.45 + math.random() * 0.8)
        local sz = math.random(3, 6)
        local px = cx + (math.random() - 0.5) * spread
        local col = (i % 3 == 0) and Color3.new(1, 1, 1) or ((i % 2 == 0) and Theme.Accent or Theme.Accent2)
        local p = New("Frame", {
            Size = UDim2.fromOffset(sz, sz),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(px, cy),
            BorderSizePixel = 0,
            BackgroundColor3 = col,
            ZIndex = 61,
        }, Screen)
        Corner(p, 3)
        local dur = 0.45 + math.random() * 0.45
        Tween(p, dur, {
            Position = UDim2.fromOffset(px + math.cos(ang) * d, cy + math.sin(ang) * d * 0.85),
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(1, 1),
        }, Enum.EasingStyle.Quint)
        Debris:AddItem(p, dur + 0.15)
    end
end

local function FxBeam(cx, cy, w)
    local b = New("Frame", {
        Size = UDim2.fromOffset(w, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(cx, cy),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 62,
    }, Screen)
    New("UICorner", { CornerRadius = UDim.new(0.5, 0) }, b)
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent2),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Theme.Accent),
        }),
    }, b)
    Stroke(b, Theme.Accent, 5, 0.65)
    Debris:AddItem(b, 2)
    return b
end

local AnimToken = 0

-- เปิด: บินออกจากปุ่ม RX แล้วขยายเป็นหน้าต่าง + วงคลื่น
local function PlayOpen()
    AnimToken = AnimToken + 1
    local token = AnimToken
    Opening = true
    local t = TargetScale()
    local fx, fy = FloatCenter()

    MainStroke.Thickness = 1.5
    Main.Size = UDim2.fromOffset(BW, BH)
    Main.Position = UDim2.fromOffset(fx, fy)
    Main.GroupTransparency = 1
    MainScale.Scale = t * 0.12
    Main.Visible = true

    PlayToggleSound(true, true)
    FxRing(fx, fy, 120, 3, 0.55)
    FxSparks(fx, fy, 6, 12, 60)

    Tween(Main, 0.3, { GroupTransparency = 0 })
    Tween(Main, 0.6, { Position = UDim2.fromScale(Config.WindowX, Config.WindowY) }, Enum.EasingStyle.Quint)
    Tween(MainScale, 0.65, { Scale = t }, Enum.EasingStyle.Back)

    task.delay(0.5, function()
        if token ~= AnimToken then
            return
        end
        local ap, asz = Main.AbsolutePosition, Main.AbsoluteSize
        FxRing(ap.X + asz.X / 2, ap.Y + asz.Y / 2, math.max(asz.X, asz.Y) * 1.05, 2, 0.7, Theme.Accent2)
    end)
    task.delay(0.68, function()
        if token == AnimToken then
            Opening = false
        end
    end)
end

-- ปิด: ตัวหน้าต่างพองเล็กน้อย -> ยุบเป็นเส้นแสง -> หดเป็นจุด + ประกายไฟ -> บินเข้าปุ่ม RX แล้วปล่อยคลื่น
local function PlayClose()
    AnimToken = AnimToken + 1
    local token = AnimToken
    Opening = true
    PlayToggleSound(false, true)

    local s0 = MainScale.Scale
    local function alive()
        return token == AnimToken
    end

    -- 1) พองเล็กน้อย + ขอบสว่างวาบ
    Tween(MainScale, 0.14, { Scale = s0 * 1.03 }, Enum.EasingStyle.Sine)
    Tween(MainStroke, 0.3, { Thickness = 3.5 }, Enum.EasingStyle.Sine)

    -- 2) ยุบแนวตั้งเป็นเส้นบางๆ
    task.delay(0.14, function()
        if not alive() then
            return
        end
        Tween(Main, 0.36, { Size = UDim2.fromOffset(BW, 5) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Tween(MainScale, 0.36, { Scale = s0 * 0.97 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    end)

    -- 3) เส้นแสงวาบ -> หดเป็นจุด + วงคลื่น + ประกายไฟ
    task.delay(0.5, function()
        if not alive() then
            return
        end
        local ap, asz = Main.AbsolutePosition, Main.AbsoluteSize
        local cx, cy = ap.X + asz.X / 2, ap.Y + asz.Y / 2
        local w = math.max(asz.X, 40)

        Main.Visible = false
        Main.Size = UDim2.fromOffset(BW, BH)
        Main.Position = UDim2.fromScale(Config.WindowX, Config.WindowY)
        MainScale.Scale = s0
        MainStroke.Thickness = 1.5

        local beam = FxBeam(cx, cy, w)
        FxRing(cx, cy, w * 0.75, 3, 0.6)
        FxRing(cx, cy, w * 0.45, 2, 0.5, Theme.Accent2)
        FxSparks(cx, cy, w, 28, 150 * math.max(s0, 0.6))
        Tween(beam, 0.26, { Size = UDim2.fromOffset(18, 18) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

        -- 4) จุดแสงบินเข้าปุ่ม RX
        task.delay(0.28, function()
            local fx, fy = FloatCenter()
            Tween(beam, 0.36, {
                Position = UDim2.fromOffset(fx, fy),
                Size = UDim2.fromOffset(8, 8),
            }, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
            task.delay(0.36, function()
                beam:Destroy()
                FxRing(fx, fy, 100, 3, 0.55)
                FxSparks(fx, fy, 6, 12, 50)
                if alive() then
                    Opening = false
                end
            end)
        end)
    end)
end

local function SetWindow(visible)
    SetConfig("WindowVisible", visible)
    if visible then
        PlayOpen()
    else
        PlayClose()
    end
end

-- ลากหน้าต่าง/ปุ่ม/วิดเจ็ต แล้วเซฟตำแหน่งเป็นสัดส่วนหน้าจอ
local function SavePosition(target, kx, ky)
    local s = Screen.AbsoluteSize
    if s.X <= 0 or s.Y <= 0 then
        return
    end
    local c = target.AbsolutePosition + target.AbsoluteSize / 2
    local fx = math.clamp(c.X / s.X, 0.02, 0.98)
    local fy = math.clamp(c.Y / s.Y, 0.02, 0.98)
    target.Position = UDim2.fromScale(fx, fy)
    SetConfig(kx, math.floor(fx * 10000) / 10000)
    SetConfig(ky, math.floor(fy * 10000) / 10000)
end

local function MakeDraggable(handle, target, kx, ky, onClick)
    local dragging, dragInput, startPos, startCenter, moved = false, nil, nil, nil, false

    handle.InputBegan:Connect(function(input)
        if IsPointer(input) then
            dragging = true
            moved = false
            dragInput = input
            startPos = input.Position
            startCenter = target.AbsolutePosition + target.AbsoluteSize / 2
        end
    end)

    Track(UIS.InputChanged:Connect(function(input)
        if not dragging or not IsMove(input) then
            return
        end
        if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then
            return
        end
        local d = input.Position - startPos
        if d.Magnitude > 8 then
            moved = true
        end
        if moved then
            local s = Screen.AbsoluteSize
            target.Position = UDim2.fromOffset(
                math.clamp(startCenter.X + d.X, 0, s.X),
                math.clamp(startCenter.Y + d.Y, 0, s.Y)
            )
        end
    end))

    Track(UIS.InputEnded:Connect(function(input)
        if dragging and IsPointer(input) then
            if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then
                return
            end
            dragging = false
            if moved then
                SavePosition(target, kx, ky)
            elseif onClick then
                onClick()
            end
        end
    end))
end

-- แจ้งเตือนเล็กๆ ด้านล่างจอ (Toast)
local ActiveToast
local function Toast(text, on)
    if ActiveToast then
        ActiveToast:Destroy()
        ActiveToast = nil
    end
    local t = New("TextLabel", {
        Size = UDim2.fromOffset(0, 38),
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 48),
        BorderSizePixel = 0,
        Text = text,
        TextSize = 12,
        Font = FNT.M,
        BackgroundColor3 = Theme.Surface2,
        TextColor3 = Theme.Text,
        ZIndex = 300,
    }, Screen)
    Corner(t, 19)
    Stroke(t, Theme.Accent, 1, 0.55)
    Pad(t, 38, 18, 0, 0)
    local dot = New("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, -24, 0.5, -4),
        BorderSizePixel = 0,
        BackgroundColor3 = (on == true) and RGB(70, 200, 120) or (on == false and Theme.Muted or Theme.Accent),
    }, t)
    Corner(dot, 4)
    ActiveToast = t
    Tween(t, 0.35, { Position = UDim2.new(0.5, 0, 1, -26) }, Enum.EasingStyle.Back)
    task.delay(1.7, function()
        if ActiveToast == t then
            Tween(t, 0.25, { Position = UDim2.new(0.5, 0, 1, 48) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.3, function()
                t:Destroy()
                if ActiveToast == t then
                    ActiveToast = nil
                end
            end)
        end
    end)
end

--==================================================
-- SAVE STATUS PILL
--==================================================

local SaveStates = {
    idle = { "Auto Save", nil },
    saving = { "กำลังบันทึก...", RGB(240, 190, 60) },
    saved = { "บันทึกแล้ว", RGB(70, 200, 120) },
    failed = { "บันทึกไม่ได้", RGB(235, 75, 90) },
    unsupported = { "ไม่รองรับไฟล์", RGB(235, 75, 90) },
}

local function StatusPill(parent, width)
    local pill = New("Frame", { Size = UDim2.fromOffset(width or 108, 26), BorderSizePixel = 0 }, parent)
    Bind(pill, "BackgroundColor3", "Surface2")
    Corner(pill, 13)
    Bind(Stroke(pill, Theme.Stroke, 1, 0.3), "Color", "Stroke")

    local dot = New("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, 11, 0.5, -4),
        BorderSizePixel = 0,
    }, pill)
    Corner(dot, 4)

    local label = Text(pill, "", 10, FNT.M, "Sub")
    label.Position = UDim2.fromOffset(26, 0)
    label.Size = UDim2.new(1, -30, 1, 0)

    local current = "idle"
    local function render()
        local s = SaveStates[current]
        label.Text = s[1]
        dot.BackgroundColor3 = s[2] or Theme.Accent
    end
    OnTheme(render)

    SaveHooks[#SaveHooks + 1] = function(state)
        current = state
        render()
    end
    return pill
end

--==================================================
-- FPS / MS WIDGET (เล็ก ลากได้ แยกจากหน้าต่างหลัก)
--==================================================

local StatsGui = New("ScreenGui", {
    Name = "RELWX_Stats",
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    IgnoreGuiInset = true,
    Enabled = Config.StatsVisible,
}, PlayerGui)

local StatsBox = New("Frame", {
    Size = UDim2.fromOffset(152, 30),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(Config.StatsX, Config.StatsY),
    BorderSizePixel = 0,
    BackgroundTransparency = 0.1,
    Active = true,
}, StatsGui)
Bind(StatsBox, "BackgroundColor3", "Surface")
Corner(StatsBox, 15)
Bind(Stroke(StatsBox, Theme.Stroke, 1, 0.2), "Color", "Stroke")

local FpsLabel = Text(StatsBox, "", 11, FNT.M, "Sub", Enum.TextXAlignment.Center)
FpsLabel.RichText = true
FpsLabel.Size = UDim2.new(0.5, -1, 1, 0)

local MsLabel = Text(StatsBox, "", 11, FNT.M, "Sub", Enum.TextXAlignment.Center)
MsLabel.RichText = true
MsLabel.Position = UDim2.new(0.5, 1, 0, 0)
MsLabel.Size = UDim2.new(0.5, -1, 1, 0)

local StatsDivider = New("Frame", {
    Size = UDim2.fromOffset(1, 14),
    Position = UDim2.new(0.5, 0, 0.5, -7),
    BorderSizePixel = 0,
}, StatsBox)
Bind(StatsDivider, "BackgroundColor3", "Stroke")

MakeDraggable(StatsBox, StatsBox, "StatsX", "StatsY")

local Metrics = { fps = 60, ping = 0 }

do
    local frames, acc = 0, 0
    Track(RunService.RenderStepped:Connect(function(dt)
        frames = frames + 1
        acc = acc + dt
        if acc >= 0.5 then
            Metrics.fps = math.floor(frames / acc + 0.5)
            frames, acc = 0, 0
        end
    end))
end

local function GetPing()
    local ok, v = pcall(function()
        return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return (ok and type(v) == "number") and math.floor(v + 0.5) or 0
end

local function Level(value, good, mid, higherIsBetter)
    local g, m, b = RGB(70, 200, 120), RGB(240, 190, 60), RGB(235, 75, 90)
    if higherIsBetter then
        return value >= good and g or (value >= mid and m or b)
    end
    return value <= good and g or (value <= mid and m or b)
end

local function RefreshStats()
    Metrics.ping = GetPing()
    local fc = Level(Metrics.fps, 50, 30, true)
    local mc = Level(Metrics.ping, 80, 160, false)
    local muted = "#" .. Theme.Muted:ToHex()
    FpsLabel.Text = string.format(
        '<font color="#%s"><b>%d</b></font> <font color="%s">FPS</font>',
        fc:ToHex(), Metrics.fps, muted
    )
    MsLabel.Text = string.format(
        '<font color="#%s"><b>%d</b></font> <font color="%s">MS</font>',
        mc:ToHex(), Metrics.ping, muted
    )
end

--==================================================
-- TOP BAR
--==================================================

local Top = New("Frame", {
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, Main)

local TopLine = New("Frame", {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 1, -1),
    BorderSizePixel = 0,
    BackgroundColor3 = Color3.new(1, 1, 1),
}, Top)
do
    local g = AccentGrad(TopLine, 0)
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(0.5, 0.15),
        NumberSequenceKeypoint.new(1, 0.95),
    })
end

Top.ClipsDescendants = true
local Shine = New("Frame", {
    Size = UDim2.new(0, 120, 1, 0),
    Position = UDim2.new(-0.3, 0, 0, 0),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, Top)
New("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.93),
        NumberSequenceKeypoint.new(1, 1),
    }),
}, Shine)
TweenService:Create(
    Shine,
    TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 4),
    { Position = UDim2.new(1.1, 0, 0, 0) }
):Play()

local Badge = New("Frame", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.fromOffset(16, 13),
    BorderSizePixel = 0,
}, Top)
Badge.BackgroundColor3 = Color3.new(1, 1, 1)
AccentGrad(Badge, 45)
Corner(Badge, 10)
Bind(Stroke(Badge, Theme.Accent, 1.5, 0.65), "Color", "Accent")
local BadgeText = Text(Badge, "RX", 13, FNT.B, nil, Enum.TextXAlignment.Center)
BadgeText.Size = UDim2.fromScale(1, 1)
Bind(BadgeText, "TextColor3", "OnAccent")

local Brand = Text(Top, "", 15, FNT.B, "Text")
Brand.RichText = true
OnTheme(function()
    Brand.Text = 'RELWX <font color="#' .. Theme.Accent:ToHex() .. '">HUB</font>'
end)
Brand.Position = UDim2.fromOffset(60, 10)
Brand.Size = UDim2.new(1, -270, 0, 22)

local BrandSub = Text(Top, tostring(game.Name or ""), 10, FNT.R, "Muted")
BrandSub.Position = UDim2.fromOffset(60, 31)
BrandSub.Size = UDim2.new(1, -270, 0, 16)

local function WindowButton(kind, xOffset, danger)
    local b = New("TextButton", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, xOffset, 0.5, -16),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, Top)
    Corner(b, 10)
    Bind(b, "BackgroundColor3", "Surface2")
    local paint = Icon(b, kind, 7, 7)
    OnTheme(function()
        paint(Theme.Sub)
    end)
    b.MouseEnter:Connect(function()
        Tween(b, 0.12, { BackgroundColor3 = danger and RGB(200, 70, 80) or Theme.Button })
        paint(danger and RGB(255, 255, 255) or Theme.Text)
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.12, { BackgroundColor3 = Theme.Surface2 })
        paint(Theme.Sub)
    end)
    return b
end

local MaxBtn = WindowButton("max", -86, false)
local CloseBtn = WindowButton("close", -48, true)
CloseBtn.MouseButton1Click:Connect(function()
    SetWindow(false)
end)

MakeDraggable(Top, Main, "WindowX", "WindowY")

MaxBtn.MouseButton1Click:Connect(function()
    SetConfig("Maximized", not Config.Maximized)
    SetConfig("WindowX", 0.5)
    SetConfig("WindowY", 0.5)
    Tween(Main, 0.3, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Quint)
    ApplyScale(true)
end)

--==================================================
-- SIDEBAR (หมวดหมู่)
--==================================================

local Rail = New("Frame", {
    Size = UDim2.new(0, SW, 1, -80),
    Position = UDim2.fromOffset(12, 68),
    BorderSizePixel = 0,
}, Main)
Bind(Rail, "BackgroundColor3", "Surface")
Corner(Rail, 14)
Bind(Stroke(Rail, Theme.Stroke, 1, 0.4), "Color", "Stroke")

local CatList = New("ScrollingFrame", {
    Size = UDim2.new(1, -16, 1, -80),
    Position = UDim2.fromOffset(8, 10),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageTransparency = 0.3,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ElasticBehavior = Enum.ElasticBehavior.Never,
}, Rail)
Bind(CatList, "ScrollBarImageColor3", "Accent")
List(CatList, 4)
Pad(CatList, 0, 4, 1, 1)

local UserBox = New("Frame", {
    Size = UDim2.new(1, -16, 0, 52),
    Position = UDim2.new(0, 8, 1, -60),
    BorderSizePixel = 0,
}, Rail)
Bind(UserBox, "BackgroundColor3", "Surface2")
Corner(UserBox, 12)

local Avatar = New("ImageLabel", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(0, 9, 0.5, -17),
    BorderSizePixel = 0,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=60&h=60",
}, UserBox)
Corner(Avatar, 17)
Bind(Avatar, "BackgroundColor3", "Button")
Bind(Stroke(Avatar, Theme.Accent, 1.5, 0.2), "Color", "Accent")
Bind(Stroke(UserBox, Theme.Stroke, 1, 0.5), "Color", "Stroke")
local Online = New("Frame", {
    Size = UDim2.fromOffset(10, 10),
    Position = UDim2.new(0, 36, 0.5, 7),
    BorderSizePixel = 0,
    BackgroundColor3 = RGB(70, 200, 120),
    ZIndex = 3,
}, UserBox)
Corner(Online, 5)
Bind(Stroke(Online, Theme.Surface2, 2, 0), "Color", "Surface2")

local UName = Text(UserBox, LocalPlayer.DisplayName, 12, FNT.B, "Text")
UName.Position = UDim2.fromOffset(52, 9)
UName.Size = UDim2.new(1, -58, 0, 18)
local UTag = Text(UserBox, "@" .. LocalPlayer.Name, 10, FNT.R, "Muted")
UTag.Position = UDim2.fromOffset(52, 27)
UTag.Size = UDim2.new(1, -58, 0, 14)

local Pages = {}
local TabList = {}

local function CatGroup(name)
    local l = Text(CatList, name, 10, FNT.B, "Muted")
    l.Size = UDim2.new(1, 0, 0, 26)
    l.LayoutOrder = Next(CatList)
    Pad(l, 10, 0, 6, 0)
    return l
end

local CurrentTab = nil
local function SelectTab(id)
    if not Pages[id] then
        id = "Home"
    end
    SetConfig("LastTab", id)
    local changed = id ~= CurrentTab
    CurrentTab = id
    for pid, page in pairs(Pages) do
        page.Visible = (pid == id)
    end
    if changed then
        local p = Pages[id]
        p.Position = UDim2.fromOffset(0, 16)
        Tween(p, 0.32, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
    end
    for _, t in ipairs(TabList) do
        t.active = (t.id == id)
        t.paint()
    end
end

local function Category(name, id, iconKind)
    local b = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = Next(CatList),
    }, CatList)
    Corner(b, 11)
    local bst = Stroke(b, Theme.Accent, 1, 1)

    local ind = New("Frame", {
        Size = UDim2.fromOffset(3, 8),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 4, 0.5, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, b)
    Corner(ind, 2)

    local setIcon = Icon(b, iconKind, 16, 12)

    local lbl = Text(b, name, 13, FNT.M)
    lbl.Position = UDim2.fromOffset(44, 0)
    lbl.Size = UDim2.new(1, -48, 1, 0)
    lbl.TextColor3 = Theme.Sub

    local tab = { id = id, active = false, hover = false }
    function tab.paint()
        Tween(b, 0.15, {
            BackgroundColor3 = tab.active and Theme.Accent or Theme.Button,
            BackgroundTransparency = tab.active and 0.84 or (tab.hover and 0.5 or 1),
        })
        Tween(bst, 0.15, { Color = Theme.Accent, Transparency = tab.active and 0.55 or 1 })
        Tween(lbl, 0.15, { TextColor3 = tab.active and Theme.Text or Theme.Sub })
        Tween(ind, 0.15, {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = tab.active and 0 or 1,
            Size = tab.active and UDim2.fromOffset(3, 22) or UDim2.fromOffset(3, 8),
        })
        setIcon(tab.active and Theme.Accent or Theme.Sub)
    end
    TabList[#TabList + 1] = tab
    OnTheme(tab.paint)

    b.MouseEnter:Connect(function()
        tab.hover = true
        tab.paint()
    end)
    b.MouseLeave:Connect(function()
        tab.hover = false
        tab.paint()
    end)
    b.MouseButton1Click:Connect(function()
        SelectTab(id)
    end)
    return b
end

--==================================================
-- PAGES
--==================================================

local Body = New("Frame", {
    Size = UDim2.new(1, -(SW + 36), 1, -80),
    Position = UDim2.fromOffset(SW + 24, 68),
    BackgroundTransparency = 1,
}, Main)

local function MakePage(id, title, subtitle)
    local page = New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
    }, Body)
    Bind(page, "ScrollBarImageColor3", "Stroke")
    List(page, 8)
    Pad(page, 0, 8, 0, 14)

    local head = New("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = Next(page),
    }, page)
    local t = Text(head, title, 22, FNT.B, "Text")
    t.Size = UDim2.new(1, 0, 0, 28)
    local s = Text(head, subtitle or "", 11, FNT.R, "Muted")
    s.Position = UDim2.fromOffset(0, 29)
    s.Size = UDim2.new(1, 0, 0, 18)
    local hb = New("Frame", {
        Size = UDim2.fromOffset(36, 3),
        Position = UDim2.fromOffset(0, 53),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, head)
    Corner(hb, 2)
    AccentGrad(hb, 0)

    Pages[id] = page
    return page
end

-- Section แบบพับ/ขยายได้ (จำสถานะไว้ใน Config)
local Collapsed = {}
for id in string.gmatch(Config.CollapsedSections, "[^|]+") do
    Collapsed[id] = true
end
local function SaveCollapsed()
    local t = {}
    for id, v in pairs(Collapsed) do
        if v then
            t[#t + 1] = id
        end
    end
    table.sort(t)
    SetConfig("CollapsedSections", table.concat(t, "|"))
end

local SectionsByPage = {}
local CurrentSection = nil

local function Section(page, title)
    local hdr = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = Next(page),
    }, page)

    local bar = New("Frame", {
        Size = UDim2.fromOffset(3, 14),
        Position = UDim2.new(0, 2, 0.5, -7),
        BorderSizePixel = 0,
    }, hdr)
    Corner(bar, 2)
    bar.BackgroundColor3 = Color3.new(1, 1, 1)
    AccentGrad(bar, 90)

    local hl = New("Frame", {
        Size = UDim2.new(1, -4, 0, 1),
        Position = UDim2.new(0, 2, 1, -1),
        BorderSizePixel = 0,
    }, hdr)
    Bind(hl, "BackgroundColor3", "Stroke")
    New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, hl)

    local label = Text(hdr, title, 13, FNT.B, "Text")
    label.Position = UDim2.fromOffset(14, 0)
    label.Size = UDim2.new(1, -44, 1, 0)

    -- ลูกศร (วาดด้วยเส้น 2 เส้น)
    local chev = New("Frame", {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -18, 0.5, 0),
        BackgroundTransparency = 1,
    }, hdr)
    local c1 = New("Frame", {
        Size = UDim2.fromOffset(8, 2), Position = UDim2.fromOffset(1, 6), Rotation = 45, BorderSizePixel = 0,
    }, chev)
    local c2 = New("Frame", {
        Size = UDim2.fromOffset(8, 2), Position = UDim2.fromOffset(6, 6), Rotation = -45, BorderSizePixel = 0,
    }, chev)
    Corner(c1, 1)
    Corner(c2, 1)
    OnTheme(function()
        c1.BackgroundColor3 = Theme.Muted
        c2.BackgroundColor3 = Theme.Muted
    end)

    local sec = { label = hdr, items = {}, collapsed = Collapsed[title] == true }
    function sec.refresh(animate)
        for _, it in ipairs(sec.items) do
            it.frame.Visible = it.matched and not sec.collapsed
        end
        local rot = sec.collapsed and -90 or 0
        if animate then
            Tween(chev, 0.18, { Rotation = rot })
        else
            chev.Rotation = rot
        end
    end
    sec.refresh(false)

    hdr.MouseButton1Click:Connect(function()
        sec.collapsed = not sec.collapsed
        Collapsed[title] = sec.collapsed
        SaveCollapsed()
        sec.refresh(true)
    end)

    CurrentSection = sec
    SectionsByPage[page] = SectionsByPage[page] or {}
    table.insert(SectionsByPage[page], sec)
    return sec
end

local function Register(row, search)
    local sec = CurrentSection
    if sec then
        table.insert(sec.items, { frame = row, search = string.lower(search or ""), matched = true })
        sec.refresh(false)
    end
end

local Refreshers = {}

--==================================================
-- COMPONENTS: Toggle / Slider / ColorRow
--==================================================

local FuncToggles = {}
local UpdateSummary = function() end

local function Toggle(page, opts)
    local row = Panel(page, UDim2.new(1, 0, 0, 64), "TextButton")
    HoverRow(row)
    Register(row, opts.title .. " " .. (opts.desc or ""))
    local rowStroke = row:FindFirstChildOfClass("UIStroke")

    local title = Text(row, opts.title, 13, FNT.M, "Text")
    title.Position = UDim2.fromOffset(18, 11)
    title.Size = UDim2.new(1, -96, 0, 20)

    local desc = Text(row, opts.desc or "", 11, FNT.R, "Muted")
    desc.Position = UDim2.fromOffset(18, 33)
    desc.Size = UDim2.new(1, -96, 0, 18)

    local strip = New("Frame", {
        Size = UDim2.fromOffset(3, 26),
        Position = UDim2.new(0, 4, 0.5, -13),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
    }, row)
    Corner(strip, 2)
    AccentGrad(strip, 90)

    local glow = New("Frame", {
        Size = UDim2.fromOffset(62, 40),
        Position = UDim2.new(1, -71, 0.5, -20),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
    }, row)
    Corner(glow, 20)
    AccentGrad(glow, 0)

    local track = New("Frame", {
        Size = UDim2.fromOffset(48, 26),
        Position = UDim2.new(1, -64, 0.5, -13),
        BorderSizePixel = 0,
    }, row)
    Corner(track, 13)
    local tStroke = Stroke(track, Theme.Stroke, 1, 0.2)
    Bind(tStroke, "Color", "Stroke")

    local fill = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
    }, track)
    Corner(fill, 13)
    AccentGrad(fill, 0)

    local knob = New("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.fromOffset(3, 3),
        BorderSizePixel = 0,
    }, track)
    Corner(knob, 10)

    local state = Config[opts.key] == true

    if page == Pages["Functions"] then
        FuncToggles[#FuncToggles + 1] = function()
            return state
        end
    end

    local function render(animate)
        Apply(track, animate, { BackgroundColor3 = Theme.Button })
        Apply(fill, animate, { BackgroundTransparency = state and 0 or 1 })
        Apply(glow, animate, { BackgroundTransparency = state and 0.82 or 1 })
        Apply(knob, animate, {
            Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = state and Theme.OnAccent or Theme.Sub,
        })
        Apply(strip, animate, { BackgroundTransparency = state and 0 or 1 })
        Apply(tStroke, animate, { Color = state and Theme.Accent or Theme.Stroke })
        if rowStroke then
            Apply(rowStroke, animate, {
                Color = state and Theme.Accent or Theme.Stroke,
                Transparency = state and 0.55 or 0.4,
            })
        end
        UpdateSummary()
    end
    OnTheme(function()
        render(false)
    end)

    local function set(v, fire)
        state = v
        SetConfig(opts.key, v)
        render(true)
        if fire then
            PlayToggleSound(v)
            if opts.callback then
                task.spawn(opts.callback, v)
            end
        end
    end

    row.MouseButton1Click:Connect(function()
        set(not state, true)
    end)

    Refreshers[#Refreshers + 1] = function()
        state = Config[opts.key] == true
        render(false)
        if opts.callback then
            task.spawn(opts.callback, state)
        end
    end

    if opts.callback then
        task.defer(opts.callback, state)
    end

    return {
        Get = function()
            return state
        end,
        Set = function(v)
            set(v, true)
        end,
    }
end

local function Slider(page, opts)
    local min, max, step = opts.min, opts.max, opts.step or 1
    local row = Panel(page, UDim2.new(1, 0, 0, 78))
    Register(row, opts.title .. " " .. (opts.desc or ""))

    local title = Text(row, opts.title, 13, FNT.M, "Text")
    title.Position = UDim2.fromOffset(16, 10)
    title.Size = UDim2.new(1, -110, 0, 20)

    local desc = Text(row, opts.desc or "", 11, FNT.R, "Muted")
    desc.Position = UDim2.fromOffset(16, 31)
    desc.Size = UDim2.new(1, -110, 0, 16)

    local pill = New("Frame", {
        Size = UDim2.fromOffset(82, 22),
        Position = UDim2.new(1, -98, 0, 9),
        BorderSizePixel = 0,
    }, row)
    Corner(pill, 11)
    Bind(pill, "BackgroundColor3", "Surface2")
    Bind(Stroke(pill, Theme.Accent, 1, 0.6), "Color", "Accent")
    local val = Text(row, "", 12, FNT.B, "Accent", Enum.TextXAlignment.Center)
    val.Position = UDim2.new(1, -98, 0, 9)
    val.Size = UDim2.fromOffset(82, 22)

    local bar = New("Frame", {
        Size = UDim2.new(1, -32, 0, 6),
        Position = UDim2.fromOffset(16, 60),
        BorderSizePixel = 0,
    }, row)
    Corner(bar, 3)
    Bind(bar, "BackgroundColor3", "Button")

    local fill = New("Frame", {
        Size = UDim2.fromScale(0, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, bar)
    Corner(fill, 3)
    AccentGrad(fill, 0)

    local knob = New("Frame", {
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        BorderSizePixel = 0,
    }, bar)
    Corner(knob, 8)
    Bind(knob, "BackgroundColor3", "Text")
    Bind(Stroke(knob, Theme.Accent, 3, 0), "Color", "Accent")

    local hit = New("TextButton", {
        Size = UDim2.new(1, -32, 0, 30),
        Position = UDim2.fromOffset(16, 48),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, row)

    local value = Config[opts.key]

    local function show()
        local a = (value - min) / (max - min)
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, 0.5)
        val.Text = string.format("%g", value) .. (opts.suffix or "")
    end

    local function setValue(v, fire)
        v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
        if v == value and fire then
            return
        end
        value = v
        show()
        if fire then
            SetConfig(opts.key, v)
            if opts.callback then
                task.spawn(opts.callback, v)
            end
        end
    end

    local dragging = false
    local function fromX(x)
        local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
        setValue(min + (max - min) * a, true)
    end

    hit.InputBegan:Connect(function(input)
        if IsPointer(input) then
            dragging = true
            page.ScrollingEnabled = false
            Tween(knob, 0.12, { Size = UDim2.fromOffset(21, 21) })
            fromX(input.Position.X)
        end
    end)
    Track(UIS.InputChanged:Connect(function(input)
        if dragging and IsMove(input) then
            fromX(input.Position.X)
        end
    end))
    Track(UIS.InputEnded:Connect(function(input)
        if dragging and IsPointer(input) then
            dragging = false
            page.ScrollingEnabled = true
            Tween(knob, 0.12, { Size = UDim2.fromOffset(16, 16) })
        end
    end))

    value = math.clamp(value, min, max)
    show()

    Refreshers[#Refreshers + 1] = function()
        value = math.clamp(Config[opts.key], min, max)
        show()
        if opts.callback then
            task.spawn(opts.callback, value)
        end
    end

    if opts.callback then
        task.defer(opts.callback, value)
    end
end

-- ============================================================
--  COLOR PICKER v2  (สี่เหลี่ยมเฉด + แถบ Hue + HEX + พรีเซ็ต)
--  เปลี่ยนสีแล้วเซฟอัตโนมัติผ่าน SetConfig เหมือนเดิม
-- ============================================================
local PaletteColors = {
    "FFFFFF", "BEBEBE", "6B6B76", "2A2A33", "0E0E14", "000000", "8B5CF6", "6366F1",
    "3B82F6", "22D3EE", "10B981", "84CC16", "FACC15", "FB923C", "EF4444", "EC4899",
}

local ActiveOverlay, ActivePopup
local PaletteConns = {}

local function ClosePalette()
    for _, c in ipairs(PaletteConns) do
        pcall(function()
            c:Disconnect()
        end)
    end
    PaletteConns = {}
    if ActiveOverlay then
        ActiveOverlay:Destroy()
        ActiveOverlay = nil
    end
    if ActivePopup then
        ActivePopup:Destroy()
        ActivePopup = nil
    end
end

-- รวมการอัปเดตธีมให้เหลือครั้งเดียวต่อเฟรม (ลากสีแล้วไม่หน่วง)
local themePending = false
local function QueueTheme()
    if themePending then
        return
    end
    themePending = true
    task.defer(function()
        themePending = false
        ApplyTheme()
    end)
end

local function OpenPalette(title, key, onPick)
    ClosePalette()

    ActiveOverlay = New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 150,
    }, Screen)
    Tween(ActiveOverlay, 0.2, { BackgroundTransparency = 0.45 })
    ActiveOverlay.MouseButton1Click:Connect(ClosePalette)

    local PW, PH = 240, 304
    local pop = New("CanvasGroup", {
        Size = UDim2.fromOffset(PW, PH),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ZIndex = 160,
        Active = true,
    }, Screen)
    Corner(pop, 16)
    Stroke(pop, Theme.Accent, 1.5, 0.35)
    local vs = ViewSize()
    New("UIScale", { Scale = math.clamp((vs.Y - 24) / PH, 0.5, 1) }, pop)
    ActivePopup = pop
    Tween(pop, 0.2, { GroupTransparency = 0 })

    -- สีเริ่มต้นจาก Config
    local okc, c0 = pcall(Color3.fromHex, Config[key])
    if not okc then
        c0 = Color3.new(1, 1, 1)
    end
    local H, S, V = c0:ToHSV()

    -- หัวข้อ + พรีวิว + ปุ่มปิด
    local ttl = Text(pop, title or "เลือกสี", 13, FNT.B, Theme.Text)
    ttl.Position = UDim2.fromOffset(14, 10)
    ttl.Size = UDim2.new(1, -130, 0, 20)

    local prev = New("Frame", {
        Size = UDim2.fromOffset(36, 18),
        Position = UDim2.fromOffset(PW - 82, 11),
        BorderSizePixel = 0,
    }, pop)
    Corner(prev, 6)
    Stroke(prev, Color3.new(1, 1, 1), 1, 0.75)

    local closeB = New("TextButton", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromOffset(PW - 38, 8),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Text = "×",
        TextSize = 18,
        Font = FNT.B,
        TextColor3 = Theme.Sub,
        AutoButtonColor = false,
    }, pop)
    Corner(closeB, 8)
    closeB.MouseButton1Click:Connect(ClosePalette)

    -- สี่เหลี่ยมเลือก Saturation / Value
    local sv = New("Frame", {
        Size = UDim2.fromOffset(PW - 28, 124),
        Position = UDim2.fromOffset(14, 40),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromHSV(H, 1, 1),
    }, pop)
    Corner(sv, 10)
    local wf = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, sv)
    Corner(wf, 10)
    New("UIGradient", { Transparency = NumberSequence.new(0, 1) }, wf)
    local bf = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(0, 0, 0),
    }, sv)
    Corner(bf, 10)
    New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, bf)
    local svCur = New("Frame", {
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, sv)
    Corner(svCur, 8)
    Stroke(svCur, Color3.new(1, 1, 1), 2.5, 0)
    local svHit = New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, sv)

    -- แถบ Hue
    local hue = New("Frame", {
        Size = UDim2.fromOffset(PW - 28, 14),
        Position = UDim2.fromOffset(14, 176),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, pop)
    Corner(hue, 7)
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
    }, hue)
    local hueCur = New("Frame", {
        Size = UDim2.fromOffset(18, 18),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
    }, hue)
    Corner(hueCur, 9)
    Stroke(hueCur, Color3.new(1, 1, 1), 2.5, 0)
    local hueHit = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 12),
        Position = UDim2.fromOffset(0, -6),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, hue)

    -- ช่อง HEX
    local box = New("TextBox", {
        Size = UDim2.fromOffset(PW - 28, 30),
        Position = UDim2.fromOffset(14, 202),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "#RRGGBB",
        ClearTextOnFocus = false,
        TextSize = 12,
        Font = FNT.M,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Muted,
    }, pop)
    Corner(box, 9)
    Stroke(box, Theme.Stroke, 1, 0.3)

    local function render(fromBox)
        local c = Color3.fromHSV(H, S, V)
        sv.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        svCur.Position = UDim2.fromScale(S, 1 - V)
        hueCur.Position = UDim2.fromScale(H, 0.5)
        hueCur.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        prev.BackgroundColor3 = c
        if not fromBox then
            box.Text = "#" .. string.upper(c:ToHex())
        end
        return c
    end
    local function commit(fromBox)
        onPick(render(fromBox))
    end
    render(false)

    -- ลาก (รองรับเมาส์/ทัช, ชดเชย GuiInset อัตโนมัติ)
    local function bindDrag(hit, onMove)
        local dragging, dInput = false, nil
        local off = Vector2.zero
        hit.InputBegan:Connect(function(input)
            if not IsPointer(input) then
                return
            end
            local p = Vector2.new(input.Position.X, input.Position.Y)
            local a, sz = hit.AbsolutePosition, hit.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local q = p + inset
            local inside = q.X >= a.X and q.X <= a.X + sz.X and q.Y >= a.Y and q.Y <= a.Y + sz.Y
            off = inside and inset or Vector2.zero
            dragging = true
            dInput = input
            onMove(p + off)
        end)
        PaletteConns[#PaletteConns + 1] = UIS.InputChanged:Connect(function(input)
            if dragging and IsMove(input) then
                if input.UserInputType == Enum.UserInputType.Touch and input ~= dInput then
                    return
                end
                onMove(Vector2.new(input.Position.X, input.Position.Y) + off)
            end
        end)
        PaletteConns[#PaletteConns + 1] = UIS.InputEnded:Connect(function(input)
            if dragging and IsPointer(input) then
                if input.UserInputType == Enum.UserInputType.Touch and input ~= dInput then
                    return
                end
                dragging = false
            end
        end)
    end

    bindDrag(svHit, function(pos)
        S = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(1, sv.AbsoluteSize.X), 0, 1)
        V = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(1, sv.AbsoluteSize.Y), 0, 1)
        commit(false)
    end)
    bindDrag(hueHit, function(pos)
        H = math.clamp((pos.X - hue.AbsolutePosition.X) / math.max(1, hue.AbsoluteSize.X), 0, 1)
        commit(false)
    end)

    box.FocusLost:Connect(function()
        local h = string.match(box.Text, "^%s*#?(%x%x%x%x%x%x)%s*$")
        if h then
            H, S, V = Color3.fromHex(h):ToHSV()
            commit(false)
        else
            box.TextColor3 = RGB(235, 75, 90)
            task.delay(0.8, function()
                if box.Parent then
                    box.TextColor3 = Theme.Text
                    render(false)
                end
            end)
        end
    end)

    -- สีสำเร็จรูป
    for i, hexv in ipairs(PaletteColors) do
        local c = Color3.fromHex(hexv)
        local sw = New("TextButton", {
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.fromOffset(14 + ((i - 1) % 8) * 27, 244 + math.floor((i - 1) / 8) * 28),
            BackgroundColor3 = c,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, pop)
        Corner(sw, 11)
        Stroke(sw, Color3.new(1, 1, 1), 1, 0.8)
        sw.MouseButton1Click:Connect(function()
            H, S, V = c:ToHSV()
            commit(false)
        end)
    end
end

local ColorRefreshers = {}

local function ColorRow(page, title, key)
    local row = Panel(page, UDim2.new(1, 0, 0, 50), "TextButton")
    HoverRow(row)
    Register(row, title)

    local t = Text(row, title, 12, FNT.M, "Text")
    t.Position = UDim2.fromOffset(18, 0)
    t.Size = UDim2.new(1, -176, 1, 0)

    local hexLabel = Text(row, "", 10, FNT.M, "Muted", Enum.TextXAlignment.Right)
    hexLabel.Position = UDim2.new(1, -152, 0, 0)
    hexLabel.Size = UDim2.fromOffset(84, 50)

    local swatch = New("Frame", {
        Size = UDim2.fromOffset(44, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BorderSizePixel = 0,
    }, row)
    Corner(swatch, 8)
    Stroke(swatch, Color3.new(1, 1, 1), 1, 0.7)

    local function refresh()
        swatch.BackgroundColor3 = Hex(key, RGB(100, 100, 100))
        hexLabel.Text = string.upper(tostring(Config[key]))
    end
    refresh()
    Refreshers[#Refreshers + 1] = refresh
    ColorRefreshers[#ColorRefreshers + 1] = refresh

    row.MouseButton1Click:Connect(function()
        OpenPalette(title, key, function(c)
            SetConfig(key, "#" .. string.upper(c:ToHex()))
            refresh()
            QueueTheme()
        end)
    end)
end

-- ธีมสำเร็จรูป: แตะครั้งเดียวเปลี่ยนทั้ง UI + ปุ่ม RX (เซฟอัตโนมัติ)
local ThemePresets = {
    { "Graphite", "#C9CBD3", "#0A0A0C", "#232328" },
    { "Violet", "#8B5CF6", "#09090D", "#1C1C26" },
    { "Crimson", "#F43F5E", "#0B0708", "#26151A" },
    { "Cyber", "#22D3EE", "#06090C", "#122029" },
    { "Toxic", "#4ADE80", "#060A07", "#13211A" },
    { "Sunset", "#FB923C", "#0C0805", "#271A10" },
}

local function ThemeGrid(page)
    local holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = Next(page),
    }, page)
    New("UIGridLayout", {
        CellSize = UDim2.new(1 / 3, -7, 0, 56),
        CellPadding = UDim2.fromOffset(10, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, holder)
    Register(holder, "ธีม theme preset สำเร็จรูป")

    for _, p in ipairs(ThemePresets) do
        local card = Panel(holder, nil, "TextButton")
        HoverRow(card)

        local function dot(hex, x)
            local d = New("Frame", {
                Size = UDim2.fromOffset(22, 22),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, x, 0.5, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromHex(hex),
            }, card)
            Corner(d, 11)
            Stroke(d, Color3.new(1, 1, 1), 1, 0.8)
        end
        dot(p[3], 12)
        dot(p[4], 24)
        dot(p[2], 36)

        local n = Text(card, p[1], 12, FNT.M, "Text")
        n.Position = UDim2.fromOffset(68, 0)
        n.Size = UDim2.new(1, -74, 1, 0)

        card.MouseButton1Click:Connect(function()
            SetConfig("UIAccentColor", p[2])
            SetConfig("UIBackgroundColor", p[3])
            SetConfig("UIButtonColor", p[4])
            SetConfig("FloatingButtonColor", p[3])
            SetConfig("FloatingBorderColor", p[2])
            SetConfig("FloatingGlowColor", p[2])
            for _, fn in ipairs(ColorRefreshers) do
                pcall(fn)
            end
            QueueTheme()
            Toast("ใช้ธีม " .. p[1])
        end)
    end
end

--==================================================
-- HOME
--==================================================

local Home = MakePage("Home", "หน้าหลัก", "ภาพรวมและข้อมูลเซิร์ฟเวอร์")

-- การ์ดต้อนรับ
local Hero = Panel(Home, UDim2.new(1, 0, 0, 84))
Tint(Hero)
local HeroSub = Text(Hero, "", 11, FNT.M, "Muted")
HeroSub.Position = UDim2.fromOffset(20, 14)
HeroSub.Size = UDim2.new(0.6, 0, 0, 16)
local HeroName = Text(Hero, LocalPlayer.DisplayName, 24, FNT.B, Color3.new(1, 1, 1))
HeroName.Position = UDim2.fromOffset(20, 32)
HeroName.Size = UDim2.new(0.6, 0, 0, 38)
AccentGrad(HeroName, 0)
local HeroClock = Text(Hero, "", 26, FNT.B, "Text", Enum.TextXAlignment.Right)
HeroClock.Position = UDim2.new(0.5, 0, 0, 16)
HeroClock.Size = UDim2.new(0.5, -20, 0, 34)
local HeroDate = Text(Hero, "", 10, FNT.M, "Muted", Enum.TextXAlignment.Right)
HeroDate.Position = UDim2.new(0.5, 0, 0, 52)
HeroDate.Size = UDim2.new(0.5, -20, 0, 16)

-- การ์ดแมพ (รูปไอคอนแมพจริงจาก Roblox)
local MapImage = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150"

local MapCard = Panel(Home, UDim2.new(1, 0, 0, 116))
MapCard.ClipsDescendants = true

local MapBG = New("ImageLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = MapImage,
    ScaleType = Enum.ScaleType.Crop,
    ImageTransparency = 0.86,
}, MapCard)
Corner(MapBG, 12)

local MapFade = New("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, MapCard)
Bind(MapFade, "BackgroundColor3", "Surface")
New("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.7),
    }),
}, MapFade)
Corner(MapFade, 12)
Tint(MapCard)

local MapIcon = New("ImageLabel", {
    Size = UDim2.fromOffset(84, 84),
    Position = UDim2.fromOffset(16, 16),
    BorderSizePixel = 0,
    Image = MapImage,
    ScaleType = Enum.ScaleType.Crop,
}, MapCard)
Corner(MapIcon, 16)
Bind(MapIcon, "BackgroundColor3", "Button")
Bind(Stroke(MapIcon, Theme.Stroke, 1.5, 0.1), "Color", "Stroke")

local MapName = Text(MapCard, tostring(game.Name or "Unknown"), 17, FNT.B, "Text")
MapName.Position = UDim2.fromOffset(112, 16)
MapName.Size = UDim2.new(1, -128, 0, 26)

local MapBy = Text(MapCard, "กำลังโหลดข้อมูลแมพ...", 11, FNT.R, "Muted")
MapBy.Position = UDim2.fromOffset(112, 43)
MapBy.Size = UDim2.new(1, -128, 0, 16)

local Chips = New("Frame", {
    Size = UDim2.new(1, -128, 0, 24),
    Position = UDim2.fromOffset(112, 72),
    BackgroundTransparency = 1,
}, MapCard)
New("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Chips)

local function Chip(text)
    local c = New("TextLabel", {
        Size = UDim2.fromOffset(0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        Text = text,
        TextSize = 10,
        Font = FNT.M,
        LayoutOrder = Next(Chips),
    }, Chips)
    Bind(c, "BackgroundColor3", "Surface2")
    Bind(c, "TextColor3", "Sub")
    Corner(c, 12)
    Pad(c, 10, 10, 0, 0)
    return c
end

local ChipPlace = Chip("ID " .. tostring(game.PlaceId))
local ChipPlayers = Chip("ผู้เล่น -/-")

task.spawn(function()
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info then
            if info.Name and info.Name ~= "" then
                MapName.Text = tostring(info.Name)
                BrandSub.Text = tostring(info.Name)
            end
            if info.Creator and info.Creator.Name then
                MapBy.Text = "โดย " .. tostring(info.Creator.Name)
            else
                MapBy.Text = ""
            end
        end
    end)
end)

local function Stat(parent, label, size)
    local c = Panel(parent, size)
    local bar = New("Frame", {
        Size = UDim2.fromOffset(3, 18),
        Position = UDim2.fromOffset(0, 12),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, c)
    Corner(bar, 2)
    AccentGrad(bar, 90)
    local l = Text(c, label, 10, FNT.M, "Muted")
    l.Position = UDim2.fromOffset(16, 11)
    l.Size = UDim2.new(1, -30, 0, 14)
    local v = Text(c, "-", 14, FNT.B, "Text")
    v.Position = UDim2.fromOffset(16, 30)
    v.Size = UDim2.new(1, -30, 0, 22)
    return v
end

local Grid = New("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    LayoutOrder = Next(Home),
}, Home)
New("UIGridLayout", {
    CellSize = UDim2.new(0.5, -5, 0, 64),
    CellPadding = UDim2.fromOffset(10, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Grid)

local StatPlayer = Stat(Grid, "ผู้เล่น")
local StatTime = Stat(Grid, "เวลาในเซิร์ฟ")
local StatFps = Stat(Grid, "FPS")
local StatPing = Stat(Grid, "Ping")

-- กราฟ FPS ย้อนหลัง
local PerfCard = Panel(Home, UDim2.new(1, 0, 0, 120))
Tint(PerfCard)
local PerfTitle = Text(PerfCard, "ประสิทธิภาพ (FPS)", 12, FNT.B, "Text")
PerfTitle.Position = UDim2.fromOffset(18, 12)
PerfTitle.Size = UDim2.new(0.5, 0, 0, 18)
local PerfAvg = Text(PerfCard, "", 11, FNT.M, "Sub", Enum.TextXAlignment.Right)
PerfAvg.Position = UDim2.new(0.5, 0, 0, 12)
PerfAvg.Size = UDim2.new(0.5, -18, 0, 18)
local PerfBars = New("Frame", {
    Size = UDim2.new(1, -36, 0, 68),
    Position = UDim2.fromOffset(18, 40),
    BackgroundTransparency = 1,
}, PerfCard)

local PERF_N = 36
local PerfBar, PerfHist = {}, {}
for i = 1, PERF_N do
    local b = New("Frame", {
        Size = UDim2.new(1 / PERF_N, -2, 0, 2),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new((i - 1) / PERF_N, 1, 1, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
    }, PerfBars)
    Corner(b, 2)
    PerfBar[i] = b
    PerfHist[i] = 0
end

local function PerfUpdate()
    table.remove(PerfHist, 1)
    PerfHist[#PerfHist + 1] = Metrics.fps
    local peak, sum, cnt = 60, 0, 0
    for _, v in ipairs(PerfHist) do
        if v > peak then
            peak = v
        end
        if v > 0 then
            sum = sum + v
            cnt = cnt + 1
        end
    end
    for i, v in ipairs(PerfHist) do
        local b = PerfBar[i]
        b.Size = UDim2.new(1 / PERF_N, -2, math.clamp(v / peak, 0.04, 1), 0)
        b.BackgroundColor3 = Level(v, 50, 30, true)
        b.BackgroundTransparency = v == 0 and 1 or 0.08
    end
    PerfAvg.Text = "เฉลี่ย " .. tostring(cnt > 0 and math.floor(sum / cnt + 0.5) or 0) .. " FPS"
end

local sessionStart = os.time()

local function RefreshHome()
    local hr = tonumber(os.date("%H")) or 12
    HeroSub.Text = (hr >= 5 and hr < 12 and "อรุณสวัสดิ์")
        or (hr >= 12 and hr < 17 and "สวัสดีตอนบ่าย")
        or (hr >= 17 and hr < 21 and "สวัสดีตอนเย็น")
        or "ราตรีสวัสดิ์"
    HeroClock.Text = os.date("%H:%M")
    HeroDate.Text = os.date("%d / %m / %Y")
    local sec = math.max(0, os.time() - sessionStart)
    StatPlayer.Text = LocalPlayer.DisplayName
    StatTime.Text = string.format("%02d:%02d:%02d", math.floor(sec / 3600), math.floor((sec % 3600) / 60), sec % 60)
    StatFps.Text = tostring(Metrics.fps)
    StatFps.TextColor3 = Level(Metrics.fps, 50, 30, true)
    StatPing.Text = tostring(Metrics.ping) .. " ms"
    StatPing.TextColor3 = Level(Metrics.ping, 80, 160, false)
    ChipPlayers.Text = string.format("ผู้เล่น %d/%d", #Players:GetPlayers(), Players.MaxPlayers)
    PerfUpdate()
end

task.spawn(function()
    while Screen.Parent do
        RefreshStats()
        RefreshHome()
        task.wait(0.5)
    end
end)

--==================================================
-- FUNCTIONS
--==================================================

local Functions = MakePage("Functions", "ฟังก์ชัน", "เปิด / ปิดการใช้งานได้ทันที  •  เซฟอัตโนมัติ")

--==================================================
-- >>> ADD YOUR FUNCTIONS <<<
-- เพิ่มฟังก์ชันใหม่ (ค่าจะเซฟ/โหลดอัตโนมัติ):
--   1) เพิ่มคีย์ใน Defaults ด้านบน เช่น  AutoFarm = false
--   2) Toggle(Functions, { key="AutoFarm", title="...", desc="...", callback=function(v) ... end })
--   3) Slider(Functions, { key="Speed", title="...", desc="...", min=0, max=100, step=1, callback=function(v) end })
--   4) จัดกลุ่มด้วย Section(Functions, "ชื่อหมวด") ก่อนเพิ่มแถวของหมวดนั้น
-- callback จะถูกเรียกอัตโนมัติตอนโหลด Config (ฟังก์ชันที่เปิดไว้จะทำงานต่อทันที)
--==================================================

--==================================================
-- UGC v3
--  ลอบบี้ (PlaceId 118467039345115): Challenge / ฟาร์ม Story-Frontier-Raid / ร้านค้า
--  ในด่าน: ออโต้อัพเกรด + อัลติเมตทุกตัว + เล่นซ้ำ/ออก (ตรวจซ้ำจนกว่าจะออกได้)
--==================================================
;(function()
    local RS = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    local VirtualUser = game:GetService("VirtualUser")

    local LOBBY_ID = 118467039345115
    local inLobby = game.PlaceId == LOBBY_ID

    local function alive()
        return Screen.Parent ~= nil
    end

    --------------------------------------------------
    -- helpers UI (สไตล์เดียวกับ RELWX)
    --------------------------------------------------
    local function Button(page, title, cb)
        local row = Panel(page, UDim2.new(1, 0, 0, 50), "TextButton")
        HoverRow(row)
        Register(row, title)
        local t = Text(row, title, 13, FNT.M, "Text")
        t.Position = UDim2.fromOffset(18, 0)
        t.Size = UDim2.new(1, -36, 1, 0)
        row.MouseButton1Click:Connect(function()
            task.spawn(cb)
        end)
        return row
    end

    local function StatusCard(page, height)
        local card = Panel(page, UDim2.new(1, 0, 0, height))
        Register(card, "status สถานะ")
        local lbl = Text(card, "", 12, FNT.R, "Text")
        lbl.Position = UDim2.fromOffset(16, 10)
        lbl.Size = UDim2.new(1, -32, 1, -20)
        lbl.TextWrapped = true
        lbl.TextTruncate = Enum.TextTruncate.None
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        return lbl, card
    end

    -- แถวเลือกค่า: กดเพื่อวนไปค่าถัดไป (เซฟอัตโนมัติ)
    local function Choice(page, opts)
        local row = Panel(page, UDim2.new(1, 0, 0, 56), "TextButton")
        HoverRow(row)
        Register(row, opts.title)
        local title = Text(row, opts.title, 13, FNT.M, "Text")
        title.Position = UDim2.fromOffset(18, 11)
        title.Size = UDim2.new(1, -200, 0, 20)
        local desc = Text(row, opts.desc or "", 11, FNT.R, "Muted")
        desc.Position = UDim2.fromOffset(18, 33)
        desc.Size = UDim2.new(1, -200, 0, 18)
        local val = Text(row, "", 13, FNT.B, "Accent", Enum.TextXAlignment.Right)
        val.Position = UDim2.new(1, -184, 0, 0)
        val.Size = UDim2.new(0, 166, 1, 0)

        local obj = {}
        function obj.Refresh()
            local v = Config[opts.key]
            val.Text = (opts.format and opts.format(v) or tostring(v)) .. "  ›"
        end
        row.MouseButton1Click:Connect(function()
            local list = opts.getValues() or {}
            if #list == 0 then
                return
            end
            local idx = 0
            for i, v in ipairs(list) do
                if v == Config[opts.key] then
                    idx = i
                    break
                end
            end
            local nv = list[idx % #list + 1]
            SetConfig(opts.key, nv)
            obj.Refresh()
            if opts.onChange then
                task.spawn(opts.onChange, nv)
            end
        end)
        obj.Refresh()
        return obj
    end

    local function hms(sec)
        sec = math.max(0, math.floor(tonumber(sec) or 0))
        return string.format("%02d:%02d:%02d", sec // 3600, sec % 3600 // 60, sec % 60)
    end

    local function fmt(n)
        local s = tostring(math.floor(tonumber(n) or 0))
        local k
        repeat
            s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        until k == 0
        return s
    end

    local function jitter(t)
        return t + math.random() * 0.25
    end

    local function goTo(inst)
        local char = LocalPlayer.Character
        if not (char and inst) then
            return
        end
        local cf = inst:IsA("Model") and inst:GetPivot() or inst.CFrame
        char:PivotTo(cf * CFrame.new(0, 3, 5))
    end

    local function waypoint(name)
        local m = workspace:FindFirstChild("Main")
        local a = m and m:FindFirstChild("AreasWaypoints")
        return a and a:FindFirstChild(name)
    end

    local function merchantNpc()
        local m = workspace:FindFirstChild("Main")
        local n = m and m:FindFirstChild("NpcFolder")
        return n and n:FindFirstChild("Merchant")
    end

    --------------------------------------------------
    -- state + โมดูล
    --------------------------------------------------
    local Mods = { ok = false, err = "กำลังโหลดโมดูลของเกม...", merchantOk = false, merchantErr = "กำลังโหลด..." }
    local Lobby, Data, StageDB, MerchantDB, Packets

    local S = {
        -- ห้อง/ลงด่าน
        roomPending = false, roomOk = false, roomMsg = "-", myRoomId = 0, teleporting = false,
        entered = 0, log = "-",
        -- ร้านค้า
        buyPending = false, buyOk = false, buyMsg = "-", buyCount = 0, buySpent = 0,
        -- ในด่าน
        ended = nil, action = "-", leaving = false, leaveAttempts = 0, restarting = false, restartAttempts = 0,
        tpState = nil, tpAt = 0, ultSent = 0, autoSent = 0,
    }

    local function loadMod(path)
        local cur = RS
        for _, name in ipairs(path) do
            cur = cur:WaitForChild(name, 15)
            if not cur then
                return nil, "ไม่พบ " .. table.concat(path, ".")
            end
        end
        local ok, res = pcall(require, cur)
        if not ok then
            return nil, table.concat(path, ".") .. " : " .. tostring(res)
        end
        return res
    end

    local function waitFlag(getter, timeout)
        local t = 0
        repeat
            task.wait(0.1)
            t = t + 0.1
        until not getter() or t >= timeout or not alive()
        return t < timeout
    end

    -- ส่ง packet ของเกม (ลองทั้ง .send และ :send)
    local function psend(pk, payload)
        if not pk then
            return false
        end
        local ok, err = pcall(function()
            pk.send(payload)
        end)
        if not ok then
            ok, err = pcall(function()
                pk:send(payload)
            end)
        end
        if not ok then
            warn("[UGC] ส่ง packet ไม่สำเร็จ:", err)
        end
        return ok
    end

    local function lsend(name, payload)
        return psend(Lobby and Lobby[name], payload)
    end

    --------------------------------------------------
    -- Challenge (ใช้ได้ทั้งลอบบี้/ในด่านเพื่อเช็คว่าพร้อมลงไหม)
    --------------------------------------------------
    local MODE_ORDER = { "WeeklyChallenge", "DailyChallenge", "Challenges" }
    local MODE_KEY = { WeeklyChallenge = "ChWeekly", DailyChallenge = "ChDaily", Challenges = "ChNormal" }
    local MODE_LABEL = { WeeklyChallenge = "Weekly", DailyChallenge = "Daily", Challenges = "Challenge 30 นาที" }

    local function readClears()
        local out = {}
        local p = Data and Data.Get({ "StageClearProfile" }, nil)
        if type(p) == "table" then
            for k, v in pairs(p) do
                out[k] = tonumber(v) or 0
            end
        end
        return out
    end

    -- คืน (ด่าน, เหตุผลที่ลงไม่ได้ | nil)
    local function challengeStatus(mode)
        local ok, ch = pcall(StageDB.CurrentChallenge, mode)
        if not ok or not ch then
            return nil, "ไม่มีด่านในตอนนี้"
        end
        local clearedAt = tonumber(Data.Get({ "ChallengeClearProfile", mode }, -1)) or -1
        local okP, period = pcall(StageDB.Period, mode)
        if okP and clearedAt == period then
            return ch, "ลงไปแล้วในรอบนี้"
        end
        local ok2, can, why = pcall(StageDB.CanAccessChallenge, mode, ch.stageName, readClears())
        if ok2 and not can then
            return ch, why or "ยังไม่ปลดล็อกแมพ"
        end
        return ch, nil
    end

    local function challengeReady()
        if not (StageDB and Data) then
            return false
        end
        for _, mode in ipairs(MODE_ORDER) do
            if Config[MODE_KEY[mode]] then
                local ch, why = challengeStatus(mode)
                if ch and not why then
                    return true, mode
                end
            end
        end
        return false
    end

    --------------------------------------------------
    -- ลอบบี้: สร้างห้อง + เริ่ม (ใช้ร่วมกัน Challenge/ฟาร์ม)
    --------------------------------------------------
    local function createAndStart(payload, label, tpName)
        if S.myRoomId ~= 0 then
            lsend("RequestLeaveRoom", {})
            task.wait(1)
        end
        if tpName and Config.ChTp then
            goTo(waypoint(tpName))
            task.wait(0.6)
        end

        payload.friendsOnly = Config.ChFriends == true
        S.roomPending, S.roomOk = true, false
        if not lsend("RequestCreateRoom", payload) then
            S.log = "ส่งคำสั่งสร้างห้องไม่สำเร็จ"
            return false
        end

        waitFlag(function() return S.roomPending end, 6)
        if S.roomPending then
            S.roomPending = false
            S.log = "เซิร์ฟเวอร์ไม่ตอบตอนสร้างห้อง"
            return false
        end
        if not S.roomOk then
            S.log = label .. ": " .. S.roomMsg
            return false
        end

        if Config.ChStart then
            task.wait(jitter(tonumber(Config.ChStartDelay) or 2))
            lsend("RequestStartRoom", {})
            waitFlag(function() return not S.teleporting end, 10)
        end
        S.entered = S.entered + 1
        S.log = "สร้างห้อง " .. label
        return true
    end

    local function enterChallenge(mode, ch)
        return createAndStart({
            stageName = ch.stageName, chapter = ch.chapter, difficulty = ch.difficulty, mode = ch.mode,
        }, string.format("%s - %s Ch.%d (%s)", MODE_LABEL[mode], ch.stageName, ch.chapter, ch.difficulty), "Challenges")
    end

    local function tryEnterChallenge()
        for _, mode in ipairs(MODE_ORDER) do
            if Config[MODE_KEY[mode]] then
                local ch, why = challengeStatus(mode)
                if ch and not why and enterChallenge(mode, ch) then
                    return true
                end
            end
        end
        return false
    end

    --------------------------------------------------
    -- ลอบบี้: ฟาร์ม Story / Frontier / Raid
    --------------------------------------------------
    local FARM_MODES = { "Story", "FrontierStage", "Raids" }
    local FARM_LABEL = { Story = "Story", FrontierStage = "Frontier", Raids = "Raid" }
    local DIFFS = { "Normal", "Hard", "Nightmare" }

    local function stageNames(mode)
        local names = {}
        if StageDB then
            local ok, list = pcall(StageDB.List, mode)
            if ok and type(list) == "table" then
                for _, e in ipairs(list) do
                    names[#names + 1] = e.name
                end
            end
        end
        return names
    end

    local function currentFarmStage()
        local names = stageNames(Config.FarmMode)
        for _, n in ipairs(names) do
            if n == Config.FarmStage then
                return n
            end
        end
        return names[1]
    end

    local function actList(mode, stage)
        local n = 1
        if StageDB and stage then
            local ok, c = pcall(StageDB.ChapterCount, mode, stage)
            if ok and tonumber(c) then
                n = math.max(1, math.floor(c))
            end
        end
        local t = {}
        for i = 1, n do
            t[i] = i
        end
        return t
    end

    -- คืน (ความยาก, ถูกบังคับไหม)
    local function farmDifficulty()
        if StageDB then
            local ok, forced = pcall(StageDB.ForcedDifficulty, Config.FarmMode)
            if ok and forced then
                return forced, true
            end
        end
        return Config.FarmDiff, false
    end

    local function farmSummary()
        local stage = currentFarmStage() or "?"
        local acts = actList(Config.FarmMode, stage)
        local act = math.clamp(tonumber(Config.FarmAct) or 1, 1, #acts)
        local diff = farmDifficulty()
        return string.format("%s - %s Act %d (%s)", FARM_LABEL[Config.FarmMode] or Config.FarmMode, stage, act, diff), stage, act, diff
    end

    local function enterFarm()
        local label, stage, act, diff = farmSummary()
        if stage == "?" then
            S.log = "ไม่พบรายชื่อด่านของโหมดนี้"
            return false
        end
        if Config.FarmMode == "FrontierStage" then
            local ok, can, why = pcall(StageDB.CanAccessFrontier, "FrontierStage", stage, act, readClears())
            if ok and not can then
                S.log = "Frontier: " .. tostring(why)
                return false
            end
        end
        return createAndStart({
            stageName = stage, chapter = act, difficulty = diff, mode = Config.FarmMode,
        }, label, nil)
    end

    --------------------------------------------------
    -- ลอบบี้: ตัวควบคุมหลัก (Challenge / ฟาร์ม ตามลำดับความสำคัญ)
    --------------------------------------------------
    local autoRunning = false
    local function autoLoop()
        if autoRunning or not inLobby then
            return -- ลงด่านทำงานเฉพาะในลอบบี้
        end
        autoRunning = true
        while alive() and (Config.AutoChallenge or Config.AutoFarm) do
            if not (inLobby and Mods.ok) then
                task.wait(1)
            else
                local entered = false
                local order = Config.ChallengeFirst and { "c", "f" } or { "f", "c" }
                for _, k in ipairs(order) do
                    if k == "c" and Config.AutoChallenge then
                        entered = tryEnterChallenge()
                    elseif k == "f" and Config.AutoFarm then
                        entered = enterFarm()
                    end
                    if entered then
                        break
                    end
                end
                if entered then
                    Toast(S.log)
                    if not Config.ChStart then
                        break -- ไม่ได้ตั้งให้เริ่มเอง: หยุดรอให้กดเริ่มห้องเอง
                    end
                    task.wait(20) -- เกมจะเทเลพอร์ตไปด่าน สคริปต์จะถูกโหลดใหม่ฝั่งด่าน
                end
                local t, waitT = 0, tonumber(Config.ChRescan) or 20
                while alive() and (Config.AutoChallenge or Config.AutoFarm) and t < waitT do
                    task.wait(0.5)
                    t = t + 0.5
                end
            end
        end
        autoRunning = false
    end

    --------------------------------------------------
    -- ลอบบี้: ร้านค้า Merchant
    --------------------------------------------------
    local ITEMS = {
        "Pirate Giant Meat", "Devil Fruit Cake", "Flame Hashira Bento", "Wisteria Dango",
        "Sweet Cream Mochi", "Cursed Finger Parfait", "Rare Fragment", "Epic Fragment",
        "Legendary Fragment", "Mythical Fragment", "Secret Fragment", "Trait Shard",
        "Stats Reroll", "Stat Dice", "DNA Fragment", "Lucky Potion (1 Hour)",
    }
    local function itemKey(name)
        return "Buy_" .. (name:gsub("[^%w]", "_"))
    end

    local function getYen()
        return tonumber(Data.Get({ "MainProfile", "Yen" }, 0)) or 0
    end

    local function readStock()
        local period = MerchantDB.GetPeriod()
        local stock = MerchantDB.GetStock(period, LocalPlayer.UserId)
        local bought = {}
        local prof = Data.Get({ "MerchantProfile" }, nil)
        if type(prof) == "table" and prof.Period == period and type(prof.Bought) == "table" then
            for k, v in pairs(prof.Bought) do
                bought[k] = tonumber(v) or 0
            end
        end
        return stock, bought
    end

    local buyRunning = false
    local function buyLoop()
        if buyRunning then
            return
        end
        buyRunning = true
        while alive() and Config.AutoBuy do
            if not (inLobby and Mods.merchantOk) then
                task.wait(1)
            else
                local didBuy = false
                local okS, stock, bought = pcall(readStock)
                if okS then
                    local list = {}
                    for _, e in ipairs(stock) do
                        if e.Kind ~= "emote" and Config[itemKey(e.Item)] then
                            local remain = e.Quantity - (bought[e.Item] or 0)
                            if remain > 0 then
                                list[#list + 1] = { item = e.Item, price = e.Price, remain = remain }
                            end
                        end
                    end
                    table.sort(list, function(a, b)
                        return a.price > b.price -- แพงก่อน
                    end)

                    for _, e in ipairs(list) do
                        if not (alive() and Config.AutoBuy) then
                            break
                        end
                        local afford = e.price > 0 and math.floor(getYen() / e.price) or e.remain
                        local amt = math.min(e.remain, afford)
                        if amt > 0 then
                            S.buyPending = true
                            lsend("BuyMerchantItem", { itemName = e.item, amount = amt })
                            waitFlag(function() return S.buyPending end, 5)
                            if S.buyPending then
                                S.buyPending = false
                            elseif S.buyOk then
                                didBuy = true
                                S.buyCount = S.buyCount + amt
                                S.buySpent = S.buySpent + amt * e.price
                            end
                            task.wait(jitter(tonumber(Config.BuyDelay) or 1))
                        end
                    end
                end
                if not didBuy then
                    local t, waitT = 0, tonumber(Config.BuyRescan) or 15
                    while alive() and Config.AutoBuy and t < waitT do
                        task.wait(0.5)
                        t = t + 0.5
                    end
                end
            end
        end
        buyRunning = false
    end

    --------------------------------------------------
    -- ในด่าน: ข้อมูลด่านปัจจุบัน
    --------------------------------------------------
    local function gv(name)
        local g = workspace:FindFirstChild("Game")
        local v = g and g:FindFirstChild(name)
        return v and v.Value
    end

    local function isChallengeMode(mode)
        if not (mode and StageDB) then
            return false
        end
        local ok, r = pcall(StageDB.OncePerPeriod, mode)
        return ok and r == true
    end

    --------------------------------------------------
    -- ในด่าน: ระบบออก (ตรวจซ้ำจนกว่าจะออกได้ / หลายวิธีพร้อมกัน)
    --------------------------------------------------
    local TP_ACTIVE = { Started = true, RequestedFromServer = true, WaitingForServer = true, InProgress = true }

    LocalPlayer.OnTeleport:Connect(function(state)
        S.tpState, S.tpAt = state, os.clock()
    end)
    TeleportService.TeleportInitFailed:Connect(function(player, result, msg)
        if player == LocalPlayer then
            S.tpState = nil
            warn("[UGC] เทเลพอร์ตล้มเหลว:", result, msg)
        end
    end)

    -- วิธีที่ 3: กดปุ่ม "Teleport to Main Lobby" ใน Settings ของเกมจริง (กดยืนยัน 2 ครั้ง)
    local function clickSettingsLeave()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return false
        end
        for _, d in ipairs(pg:GetDescendants()) do
            if d.Name == "Teleport to Main Lobby" then
                local dis = d:FindFirstChild("Dis")
                local btn = dis and dis:FindFirstChild("Action")
                if btn and btn:IsA("GuiButton") then
                    for _ = 1, 2 do
                        pcall(function()
                            if firesignal then
                                firesignal(btn.Activated)
                            elseif getconnections then
                                for _, c in ipairs(getconnections(btn.Activated)) do
                                    c:Fire()
                                end
                            end
                        end)
                        task.wait(0.4)
                    end
                    return true
                end
            end
        end
        return false
    end

    local function beginLeave(reason)
        if S.leaving or inLobby then
            return
        end
        S.leaving, S.leaveAttempts = true, 0
        task.spawn(function()
            task.wait(tonumber(Config.LeaveDelay) or 3)
            while alive() and S.leaving and game.PlaceId ~= LOBBY_ID do
                local tpBusy = S.tpState and TP_ACTIVE[S.tpState.Name] and (os.clock() - S.tpAt) < 25
                if not tpBusy then
                    S.leaveAttempts = S.leaveAttempts + 1
                    local a, b, c = Config.LeaveByTeleport, Config.LeaveBySetting, Config.LeaveByButton
                    if a or not (b or c) then
                        pcall(function()
                            TeleportService:Teleport(LOBBY_ID, LocalPlayer)
                        end)
                    end
                    if b and Packets then
                        psend(Packets.GameplaySettingAction, { action = "lobby" })
                    end
                    if c then
                        task.spawn(clickSettingsLeave)
                    end
                end
                local t, waitT = 0, tonumber(Config.LeaveRetry) or 6
                while alive() and S.leaving and t < waitT do
                    task.wait(0.5)
                    t = t + 0.5
                end
            end
            S.leaving = false
        end)
    end

    -- เล่นซ้ำด่านเดิม (ฟาร์ม) ถ้าไม่สำเร็จจะกลับลอบบี้แทน
    local function beginRestart()
        if S.restarting or S.leaving or inLobby then
            return
        end
        S.restarting, S.restartAttempts = true, 0
        task.spawn(function()
            task.wait(tonumber(Config.LeaveDelay) or 3)
            local ok = false
            for attempt = 1, 3 do
                if not (alive() and S.ended) then
                    ok = true
                    break
                end
                S.restartAttempts = attempt
                psend(Packets and Packets.RequestRestart, {})
                local t = 0
                while alive() and S.ended and t < 12 do
                    task.wait(0.5)
                    t = t + 0.5
                end
                if not S.ended then
                    ok = true
                    break
                end
            end
            S.restarting = false
            if not ok and alive() and S.ended then
                Toast("เล่นซ้ำไม่ได้ กลับลอบบี้แทน")
                S.action = "เล่นซ้ำไม่ได้ → ออก"
                beginLeave("restart-failed")
            end
        end)
    end

    -- ตัดสินใจเมื่อจบด่าน
    local function onGameEnd(result)
        if S.ended then
            return
        end
        S.ended = tostring(result or "done")
        task.spawn(function()
            task.wait(0.5)
            local mode = gv("StageMode")
            local isChal = isChallengeMode(mode)
            local ready = challengeReady()
            if isChal then
                if Config.AutoLeave then
                    S.action = "จบ Challenge → ออก"
                    beginLeave("challenge-done")
                else
                    S.action = "จบ Challenge (Auto Leave ปิดอยู่)"
                end
            elseif Config.AutoChallenge and Config.ChallengeFirst and ready then
                S.action = "Challenge พร้อมลง → ออก"
                Toast("Challenge พร้อมลง กำลังกลับลอบบี้...")
                beginLeave("challenge-ready")
            elseif Config.AutoFarm and Config.FarmReplay then
                S.action = "ฟาร์ม → เล่นซ้ำ"
                beginRestart()
            elseif Config.AutoLeave then
                S.action = "จบด่าน → ออก"
                Toast("จบด่านแล้ว กำลังกลับลอบบี้...")
                beginLeave("stage-done")
            else
                S.action = "ไม่ทำอะไร (Auto Leave ปิดอยู่)"
            end
        end)
    end

    --------------------------------------------------
    -- ในด่าน: ออโต้อัพเกรด / ออโต้อัลติเมตทุกตัว / ออโต้เพลย์
    --------------------------------------------------
    local ultTries = {}

    local function applyAutoFeatures()
        if not Packets then
            return
        end
        if Config.AutoUpgrade and psend(Packets.AutoUpgradeAll, { enabled = true }) then
            S.autoSent = S.autoSent + 1
        end
        if Config.AutoPlayGame then
            psend(Packets.AutoPlay, { enabled = true })
        end
    end

    local function ultimatePass()
        if not (Config.AutoUltimate and Packets and Packets.SetAutoUltimate) then
            return
        end
        local folder = workspace:FindFirstChild("Unit")
        if not folder then
            return
        end
        for _, m in ipairs(folder:GetChildren()) do
            local id = m:GetAttribute("UnitId")
            if id and m:GetAttribute("OwnerId") == LocalPlayer.UserId and m:GetAttribute("AutoUltimate") ~= true then
                local n = ultTries[id] or 0
                if n < 6 then
                    ultTries[id] = n + 1
                    if psend(Packets.SetAutoUltimate, { unitId = id, enabled = true }) then
                        S.ultSent = S.ultSent + 1
                    end
                end
            end
        end
    end

    --------------------------------------------------
    -- โหลดโมดูล + ผูก listener (พื้นหลัง)
    --------------------------------------------------
    task.spawn(function()
        local errs = {}
        local function need(path)
            local m, e = loadMod(path)
            if not m then
                errs[#errs + 1] = e
            end
            return m
        end

        if inLobby then
            Lobby = need({ "Module", "Shared", "LobbyPacket" })
            Data = need({ "Module", "Shared", "PlayerDataClient" })
            StageDB = need({ "Module", "Database", "StageDatabase" })

            local function listen(name, fn)
                local pk = Lobby and Lobby[name]
                if not pk then
                    warn("[UGC] ไม่พบ packet " .. name)
                    return false
                end
                pk.listen(function(...)
                    if alive() then
                        fn(...)
                    end
                end)
                return true
            end

            if #errs == 0 then
                listen("RoomResult", function(res)
                    S.roomMsg = tostring(res.message or "")
                    S.roomOk = res.success == true
                    S.roomPending = false
                end)
                listen("RoomListSync", function(p)
                    S.myRoomId = tonumber(p.myRoomId) or 0
                end)
                listen("RoomTeleportState", function(p)
                    S.teleporting = p.active == true
                end)
                Mods.ok = true
                Mods.err = ""
            else
                Mods.err = table.concat(errs, " | ")
                warn("[UGC] โหลดโมดูลลอบบี้ไม่สำเร็จ: " .. Mods.err)
            end

            -- ร้านค้า (แยกจากส่วนอื่น: ถ้าพังก็ไม่กระทบ)
            local mdb, merr = loadMod({ "Module", "Database", "Merchant_DataBase" })
            if mdb and Lobby and Data then
                MerchantDB = mdb
                local a = listen("MerchantResult", function(res)
                    S.buyMsg = tostring(res.message or "")
                    S.buyOk = res.success == true
                    S.buyPending = false
                end)
                if a and Lobby.BuyMerchantItem then
                    Mods.merchantOk = true
                    Mods.merchantErr = ""
                else
                    Mods.merchantErr = "ไม่พบ packet ร้านค้า"
                end
            else
                Mods.merchantErr = merr or "โหลดไม่สำเร็จ"
                warn("[UGC] โหลดโมดูลร้านค้าไม่สำเร็จ: " .. tostring(Mods.merchantErr))
            end
        else
            -- ในด่าน: ไม่โหลดโมดูลร้านค้า/ลอบบี้ (ไม่ใช่บัค)
            Mods.merchantErr = "ร้านค้าใช้ได้เฉพาะในลอบบี้"
            Packets = need({ "Module", "Shared", "Packets" })
            Data = need({ "Module", "Shared", "PlayerDataClient" })
            StageDB = need({ "Module", "Database", "StageDatabase" })

            if Packets and Packets.GameEnd and Packets.GameStart then
                Packets.GameEnd.listen(function(p)
                    if alive() then
                        onGameEnd(p and p.result)
                    end
                end)
                Packets.GameStart.listen(function()
                    if alive() then
                        S.ended, S.leaving, S.action = nil, false, "-"
                        ultTries = {}
                        task.delay(2, applyAutoFeatures)
                    end
                end)
                Mods.ok = true
                Mods.err = (#errs > 0) and ("พร้อมบางส่วน: " .. table.concat(errs, " | ")) or ""
            else
                Mods.err = table.concat(errs, " | ")
                if Mods.err == "" then
                    Mods.err = "ไม่พบ packet GameEnd/GameStart"
                end
                warn("[UGC] " .. Mods.err)
            end

            -- ตัวเฝ้า (ทุก 1 วินาที): ตรวจสถานะจบด่านจาก workspace.Game.GameEnd + ใช้ฟีเจอร์ออโต้
            task.spawn(function()
                local tick = 0
                applyAutoFeatures()
                while alive() do
                    tick = tick + 1
                    local g = workspace:FindFirstChild("Game")
                    local ge = g and g:FindFirstChild("GameEnd")
                    if ge and ge:IsA("BoolValue") then
                        if ge.Value and not S.ended then
                            onGameEnd("done")
                        elseif not ge.Value and S.ended then
                            S.ended, S.leaving, S.action = nil, false, "-"
                            ultTries = {}
                        end
                    end
                    if not S.ended then
                        pcall(ultimatePass)
                        if tick % 15 == 0 then
                            applyAutoFeatures()
                        end
                        -- ออกทันทีเมื่อ Challenge พร้อม (ไม่รอจบด่านฟาร์ม)
                        if tick % 5 == 0 and Config.ChInterrupt and Config.AutoChallenge and Config.ChallengeFirst
                            and not S.leaving and not isChallengeMode(gv("StageMode")) and challengeReady() then
                            S.action = "Challenge พร้อมลง → ออกทันที"
                            Toast("Challenge พร้อมลง กำลังกลับลอบบี้...")
                            beginLeave("challenge-interrupt")
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end)

    --------------------------------------------------
    -- UI
    --------------------------------------------------
    Section(Functions, "สถานะ")
    local statusLbl = StatusCard(Functions, 270)

    Section(Functions, "ลง Challenge (ใช้ในลอบบี้)")
    Toggle(Functions, {
        key = "AutoChallenge",
        title = "Auto Challenge",
        desc = "สร้างห้องและเริ่ม Challenge ให้เอง  •  เปิดค้างไว้ได้",
        callback = function(v)
            if v then
                task.spawn(autoLoop)
            end
        end,
    })
    Toggle(Functions, { key = "ChWeekly", title = "ลง Weekly", desc = "ด่านประจำสัปดาห์" })
    Toggle(Functions, { key = "ChDaily", title = "ลง Daily", desc = "ด่านประจำวัน" })
    Toggle(Functions, { key = "ChNormal", title = "ลง Challenge 30 นาที", desc = "ด่านที่รีเซ็ตทุก 30 นาที" })
    Button(Functions, "ลง Challenge ที่พร้อมตอนนี้ (ครั้งเดียว)", function()
        if not (inLobby and Mods.ok) then
            Toast("ใช้ได้เฉพาะในลอบบี้หลังโหลดโมดูลเสร็จ")
            return
        end
        if tryEnterChallenge() then
            Toast(S.log)
        else
            Toast("ลงไม่ได้ตอนนี้: " .. S.log)
        end
    end)

    Section(Functions, "ฟาร์มด่าน Story / Frontier / Raid (ใช้ในลอบบี้)")
    Toggle(Functions, {
        key = "AutoFarm",
        title = "Auto ฟาร์มด่านที่เลือก",
        desc = "สร้างห้องด่านที่เลือกด้านล่างให้เอง",
        callback = function(v)
            if v then
                task.spawn(autoLoop)
            end
        end,
    })
    local chStage, chAct, chDiff
    local chMode = Choice(Functions, {
        key = "FarmMode", title = "โหมด", desc = "กดเพื่อสลับ Story / Frontier / Raid",
        getValues = function() return FARM_MODES end,
        format = function(v) return FARM_LABEL[v] or tostring(v) end,
        onChange = function()
            SetConfig("FarmStage", "")
            SetConfig("FarmAct", 1)
            chStage.Refresh()
            chAct.Refresh()
            chDiff.Refresh()
        end,
    })
    chStage = Choice(Functions, {
        key = "FarmStage", title = "แมพ", desc = "กดเพื่อสลับแมพของโหมดที่เลือก",
        getValues = function() return stageNames(Config.FarmMode) end,
        format = function(v)
            if v ~= "" then
                return tostring(v)
            end
            return currentFarmStage() or "(กำลังโหลด...)"
        end,
        onChange = function()
            SetConfig("FarmAct", 1)
            chAct.Refresh()
        end,
    })
    chAct = Choice(Functions, {
        key = "FarmAct", title = "Act (Chapter)", desc = "กดเพื่อสลับ Act",
        getValues = function() return actList(Config.FarmMode, currentFarmStage()) end,
        format = function(v) return "Act " .. tostring(v) end,
    })
    chDiff = Choice(Functions, {
        key = "FarmDiff", title = "ความยาก", desc = "Normal / Hard / Nightmare (บางโหมดถูกบังคับ)",
        getValues = function()
            local _, forced = farmDifficulty()
            return forced and {} or DIFFS
        end,
        format = function(v)
            local d, forced = farmDifficulty()
            return forced and (d .. " (บังคับ)") or tostring(v)
        end,
    })
    Toggle(Functions, {
        key = "ChallengeFirst",
        title = "Challenge ก่อนฟาร์ม",
        desc = "เปิด = ถ้า Challenge พร้อมลง ไปลงก่อน เสร็จแล้วค่อยกลับมาฟาร์ม  •  ปิด = ฟาร์มก่อน",
    })
    Toggle(Functions, {
        key = "ChInterrupt",
        title = "ออกทันทีเมื่อ Challenge พร้อม",
        desc = "ไม่รอจบด่านฟาร์ม (ปิดไว้ = รอจบด่านก่อนค่อยไป)",
    })
    Toggle(Functions, {
        key = "FarmReplay",
        title = "เล่นด่านเดิมซ้ำอัตโนมัติเมื่อจบ",
        desc = "ตอนฟาร์มจะไม่ออกจากด่านจนกว่า Challenge จะมา",
    })
    Button(Functions, "ลงด่านฟาร์มที่เลือกตอนนี้ (ครั้งเดียว)", function()
        if not (inLobby and Mods.ok) then
            Toast("ใช้ได้เฉพาะในลอบบี้หลังโหลดโมดูลเสร็จ")
            return
        end
        if enterFarm() then
            Toast(S.log)
        else
            Toast("ลงไม่ได้: " .. S.log)
        end
    end)

    Section(Functions, "ตั้งค่าห้อง (Challenge + ฟาร์ม)")
    Toggle(Functions, { key = "ChFriends", title = "ห้องเฉพาะเพื่อน", desc = "friendsOnly" })
    Toggle(Functions, { key = "ChStart", title = "กดเริ่มห้องอัตโนมัติ", desc = "ปิดไว้ถ้าอยากกดเริ่มเอง" })
    Toggle(Functions, { key = "ChTp", title = "วาร์ปไปโซน Challenges ก่อนสร้างห้อง Challenge", desc = "เปิดถ้าสร้างห้องไม่ผ่าน" })
    Slider(Functions, {
        key = "ChStartDelay", title = "รอก่อนกดเริ่ม", desc = "วินาที",
        min = 1, max = 10, step = 1, suffix = " วิ",
    })
    Slider(Functions, {
        key = "ChRescan", title = "ตรวจด่านใหม่ทุก", desc = "วินาที",
        min = 5, max = 120, step = 5, suffix = " วิ",
    })
    Button(Functions, "ออกจากห้อง", function()
        lsend("RequestLeaveRoom", {})
    end)
    Button(Functions, "วาร์ปไปโซน Challenges", function()
        goTo(waypoint("Challenges"))
    end)

    Section(Functions, "ร้านค้า Merchant (ใช้ในลอบบี้)")
    Toggle(Functions, {
        key = "AutoBuy",
        title = "Auto Buy",
        desc = "ซื้อของแพงก่อนเท่าที่ Yen พอ และตรวจสต็อกใหม่ทุกรอบที่ร้านรีเซ็ต",
        callback = function(v)
            if v then
                task.spawn(buyLoop)
            end
        end,
    })
    Slider(Functions, {
        key = "BuyDelay", title = "หน่วงเวลาระหว่างการซื้อ", desc = "วินาที",
        min = 0.5, max = 4, step = 0.5, suffix = " วิ",
    })
    Slider(Functions, {
        key = "BuyRescan", title = "ตรวจสต็อกใหม่ทุก", desc = "วินาที",
        min = 5, max = 120, step = 5, suffix = " วิ",
    })
    Button(Functions, "วาร์ปไปหา Merchant", function()
        goTo(merchantNpc())
    end)

    Section(Functions, "สต็อกร้านค้าตอนนี้")
    local stockLbl, stockCard = StatusCard(Functions, 60)

    Section(Functions, "ไอเทมที่จะซื้อ")
    for _, name in ipairs(ITEMS) do
        Toggle(Functions, { key = itemKey(name), title = name, desc = "เปิด = ซื้อไอเทมนี้" })
    end

    Section(Functions, "ออโต้ในด่าน (ใช้ในด่าน)")
    Toggle(Functions, {
        key = "AutoUpgrade", title = "Auto Upgrade (อัพเกรดทุกตัว)",
        desc = "เปิดปุ่ม Auto Upgrade All ของเกมให้เอง ทุกครั้งที่เริ่มด่าน",
        callback = function(v)
            if v and not inLobby then
                task.spawn(applyAutoFeatures)
            end
        end,
    })
    Toggle(Functions, {
        key = "AutoUltimate", title = "Auto Ultimate (ทุกตัวละคร)",
        desc = "เปิดออโต้อัลติเมตให้ทุกยูนิตของเรา รวมตัวที่วางใหม่",
    })
    Toggle(Functions, {
        key = "AutoPlayGame", title = "Auto Play",
        desc = "เปิด Auto Play ของเกม (ปิดไว้เป็นค่าเริ่มต้น)",
        callback = function(v)
            if v and not inLobby then
                task.spawn(applyAutoFeatures)
            end
        end,
    })

    Section(Functions, "ออกจากด่าน (ใช้ในด่าน)")
    Toggle(Functions, {
        key = "AutoLeave",
        title = "Auto Leave",
        desc = "จบ Challenge แล้วกลับลอบบี้ให้เอง  •  ตอนฟาร์มจะไม่ออกจนกว่า Challenge จะมา",
    })
    Toggle(Functions, {
        key = "LeaveByTeleport", title = "วิธีออก 1: Teleport กลับลอบบี้",
        desc = "ใช้ TeleportService เหมือนปุ่ม Back to Lobby ตอนจบด่าน",
    })
    Toggle(Functions, {
        key = "LeaveBySetting", title = "วิธีออก 2: Settings → Leave to Main Lobby",
        desc = "ส่งคำสั่งเดียวกับปุ่ม Teleport to Main Lobby ใน Settings ของเกม",
    })
    Toggle(Functions, {
        key = "LeaveByButton", title = "วิธีออก 3: กดปุ่ม Leave ใน Settings จริงๆ",
        desc = "กดปุ่มบน UI ให้ (ยืนยัน 2 ครั้ง)  •  เปิดเสริมถ้า 2 วิธีแรกไม่ติด",
    })
    Slider(Functions, {
        key = "LeaveDelay", title = "รอก่อนออก/เล่นซ้ำหลังจบด่าน", desc = "ให้รางวัลเข้าก่อน",
        min = 0, max = 15, step = 1, suffix = " วิ",
    })
    Slider(Functions, {
        key = "LeaveRetry", title = "ถ้ายังไม่ออก ลองใหม่ทุก", desc = "ตรวจซ้ำเรื่อยๆ จนกว่าจะออกได้",
        min = 3, max = 20, step = 1, suffix = " วิ",
    })
    Button(Functions, "ออกไปลอบบี้ตอนนี้", function()
        if inLobby then
            Toast("อยู่ลอบบี้อยู่แล้ว")
            return
        end
        if S.leaving then
            Toast("กำลังพยายามออกอยู่แล้ว")
            return
        end
        S.action = "กดออกเอง"
        beginLeave("manual")
    end)

    Section(Functions, "อื่นๆ")
    Toggle(Functions, { key = "AntiAfk", title = "Anti-AFK", desc = "กันโดนเตะเมื่อไม่ได้ขยับ" })
    LocalPlayer.Idled:Connect(function()
        if alive() and Config.AntiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)

    -- รีเฟรชแถวเลือกค่าหลังโหลดโมดูลเสร็จ (ชื่อแมพ/จำนวน Act เพิ่งรู้ตอนนี้)
    task.spawn(function()
        local t = 0
        while alive() and not Mods.ok and t < 60 do
            task.wait(1)
            t = t + 1
        end
        chMode.Refresh()
        chStage.Refresh()
        chAct.Refresh()
        chDiff.Refresh()
    end)

    --------------------------------------------------
    -- อัปเดตสถานะ
    --------------------------------------------------
    task.spawn(function()
        while alive() do
            local ok, txt = pcall(function()
                local L = {}
                if inLobby then
                    L[#L + 1] = "ตำแหน่ง: ลอบบี้  |  ระบบ: " .. (Mods.ok and "พร้อม" or Mods.err)
                    if Mods.ok then
                        for _, mode in ipairs(MODE_ORDER) do
                            local ch, why = challengeStatus(mode)
                            if ch then
                                local okR, reset = pcall(StageDB.SecondsUntilReset, mode)
                                L[#L + 1] = string.format("%s: %s Ch.%d (%s)  |  %s  |  รีเซ็ตใน %s",
                                    MODE_LABEL[mode], ch.stageName, ch.chapter, ch.difficulty,
                                    why and ("ลงไม่ได้: " .. why) or "พร้อมลง", hms(okR and reset or 0))
                            else
                                L[#L + 1] = MODE_LABEL[mode] .. ": " .. (why or "-")
                            end
                        end
                        L[#L + 1] = "ฟาร์มที่เลือก: " .. (farmSummary()) .. "  |  "
                            .. (Config.ChallengeFirst and "Challenge ก่อน" or "ฟาร์มก่อน")
                    end
                    L[#L + 1] = string.format("ห้องที่สร้างแล้ว: %d  |  ล่าสุด: %s", S.entered, S.log)
                    if Mods.merchantOk then
                        local okR, secs = pcall(MerchantDB.SecondsUntilReset)
                        L[#L + 1] = string.format("ร้านค้า: Yen %s  |  รีเซ็ตใน %s", fmt(getYen()), hms(okR and secs or 0))
                        L[#L + 1] = string.format("ซื้อไปแล้ว %d ชิ้น (ใช้ %s Yen)  |  ล่าสุด: %s",
                            S.buyCount, fmt(S.buySpent), S.buyMsg)
                    else
                        L[#L + 1] = "ร้านค้า: " .. tostring(Mods.merchantErr)
                    end
                else
                    L[#L + 1] = "ตำแหน่ง: ในด่าน  |  ระบบ: " .. (Mods.ok and "พร้อม" or Mods.err)
                    local mode = gv("StageMode")
                    L[#L + 1] = string.format("ด่าน: %s / %s Act %s (%s)  |  ประเภท: %s",
                        tostring(mode or "?"), tostring(gv("StageName") or "?"), tostring(gv("Act") or "?"),
                        tostring(gv("Difficult") or "?"), isChallengeMode(mode) and "Challenge" or "ฟาร์ม/ทั่วไป")
                    if S.ended then
                        local st = "จบด่านแล้ว (" .. S.ended .. ")  |  " .. S.action
                        if S.leaving then
                            local tp = S.tpState and S.tpState.Name or "-"
                            st = st .. string.format("\nกำลังออก... พยายามแล้ว %d ครั้ง (teleport: %s) จะลองซ้ำจนกว่าจะออกได้",
                                S.leaveAttempts, tp)
                        elseif S.restarting then
                            st = st .. string.format("\nกำลังเริ่มด่านใหม่... ครั้งที่ %d", S.restartAttempts)
                        end
                        L[#L + 1] = st
                    else
                        L[#L + 1] = "ด่านกำลังเล่นอยู่"
                    end
                    L[#L + 1] = string.format("ออโต้: Upgrade %s (ส่ง %d ครั้ง)  |  Ultimate %s (ส่ง %d ครั้ง)  |  Auto Play %s",
                        Config.AutoUpgrade and "เปิด" or "ปิด", S.autoSent,
                        Config.AutoUltimate and "เปิด" or "ปิด", S.ultSent,
                        Config.AutoPlayGame and "เปิด" or "ปิด")
                    L[#L + 1] = string.format("ออก: วิธี 1 %s | วิธี 2 %s | วิธี 3 %s  |  Auto Leave %s",
                        Config.LeaveByTeleport and "✔" or "✘", Config.LeaveBySetting and "✔" or "✘",
                        Config.LeaveByButton and "✔" or "✘", Config.AutoLeave and "เปิด" or "ปิด")
                end
                return table.concat(L, "\n")
            end)
            statusLbl.Text = ok and txt or ("อ่านสถานะไม่สำเร็จ: " .. tostring(txt))

            -- การ์ดสต็อกร้านค้า
            local okK, stxt, nlines = pcall(function()
                if not inLobby then
                    return "ดูสต็อกได้เฉพาะในลอบบี้", 1
                end
                if not Mods.merchantOk then
                    return "ร้านค้า: " .. tostring(Mods.merchantErr), 1
                end
                local stock, bought = readStock()
                local R = {}
                R[#R + 1] = string.format("Yen: %s  |  สต็อกรีเซ็ตใน %s", fmt(getYen()), hms(MerchantDB.SecondsUntilReset()))
                for _, e in ipairs(stock) do
                    local remain = e.Quantity - (bought[e.Item] or 0)
                    local mark = (e.Kind ~= "emote" and Config[itemKey(e.Item)]) and "✔ " or "• "
                    R[#R + 1] = string.format("%s%s  —  %s  —  %s", mark, e.Item, fmt(e.Price),
                        remain > 0 and string.format("เหลือ %d/%d", remain, e.Quantity) or "ครบ")
                end
                R[#R + 1] = "✔ = ไอเทมที่เลือกซื้อ"
                return table.concat(R, "\n"), #R
            end)
            if okK then
                stockLbl.Text = stxt
                stockCard.Size = UDim2.new(1, 0, 0, 24 + 16 * (nlines or 1))
            else
                stockLbl.Text = "อ่านสต็อกไม่สำเร็จ"
            end
            task.wait(1)
        end
    end)
end)()

--==================================================
-- SETTINGS
--==================================================

local Settings = MakePage("Settings", "ตั้งค่า", "ปรับแต่งหน้าตา RELWX  •  เปลี่ยนแล้วเซฟทันที")

Section(Settings, "ระบบ")

Toggle(Settings, {
    key = "SoundEnabled",
    title = "เสียงตอนเปิด/ปิดฟังก์ชัน",
    desc = "เล่นเสียงสั้นๆ เมื่อกดสวิตช์",
})

Toggle(Settings, {
    key = "StatsVisible",
    title = "แสดง FPS / MS",
    desc = "กล่องเล็กลากย้ายตำแหน่งได้",
    callback = function(v)
        StatsGui.Enabled = v
    end,
})

Slider(Settings, {
    key = "UIScalePercent",
    title = "ขนาดหน้าต่าง",
    desc = "ปรับเพิ่มจากขนาดอัตโนมัติตามหน้าจอ",
    min = 60,
    max = 120,
    step = 5,
    suffix = "%",
    callback = function()
        ApplyScale(true)
    end,
})

Section(Settings, "ธีมสำเร็จรูป")
ThemeGrid(Settings)

Section(Settings, "ธีม UI")
ColorRow(Settings, "สีหลัก UI", "UIAccentColor")
ColorRow(Settings, "สีพื้นหลัง UI", "UIBackgroundColor")
ColorRow(Settings, "สีปุ่ม UI", "UIButtonColor")

Section(Settings, "ปุ่มลอย RX")
ColorRow(Settings, "สีปุ่ม RX", "FloatingButtonColor")
ColorRow(Settings, "สีขอบ RX", "FloatingBorderColor")
ColorRow(Settings, "สี Glow RX", "FloatingGlowColor")

Section(Settings, "Config")

local CfgCard = Panel(Settings, UDim2.new(1, 0, 0, 64))
local CfgTitle = Text(CfgCard, "บันทึกอัตโนมัติ", 13, FNT.M, "Text")
CfgTitle.Position = UDim2.fromOffset(16, 11)
CfgTitle.Size = UDim2.new(1, -140, 0, 20)
local CfgDesc = Text(
    CfgCard,
    writefile and CONFIG_FILE or "executor นี้ไม่รองรับการเขียนไฟล์",
    10,
    FNT.R,
    "Muted"
)
CfgDesc.Position = UDim2.fromOffset(16, 33)
CfgDesc.Size = UDim2.new(1, -140, 0, 18)
local CfgPill = StatusPill(CfgCard, 108)
CfgPill.AnchorPoint = Vector2.new(1, 0.5)
CfgPill.Position = UDim2.new(1, -14, 0.5, 0)

local ResetRow = Panel(Settings, UDim2.new(1, 0, 0, 50), "TextButton")
HoverRow(ResetRow)
local ResetLabel = Text(ResetRow, "รีเซ็ตการตั้งค่าทั้งหมด", 12, FNT.M, RGB(235, 90, 100))
ResetLabel.Position = UDim2.fromOffset(16, 0)
ResetLabel.Size = UDim2.new(1, -32, 1, 0)

local FloatApplyPosition

local resetArmed = false
ResetRow.MouseButton1Click:Connect(function()
    if not resetArmed then
        resetArmed = true
        ResetLabel.Text = "กดอีกครั้งเพื่อยืนยันการรีเซ็ต"
        task.delay(3, function()
            resetArmed = false
            ResetLabel.Text = "รีเซ็ตการตั้งค่าทั้งหมด"
        end)
        return
    end
    resetArmed = false
    ResetLabel.Text = "รีเซ็ตการตั้งค่าทั้งหมด"

    for k, v in pairs(Defaults) do
        Config[k] = v
    end
    Collapsed = {}
    for _, secs in pairs(SectionsByPage) do
        for _, sec in ipairs(secs) do
            sec.collapsed = false
            sec.refresh(true)
        end
    end
    ApplyTheme()
    for _, fn in ipairs(Refreshers) do
        pcall(fn)
    end
    Tween(Main, 0.3, { Position = UDim2.fromScale(Config.WindowX, Config.WindowY) }, Enum.EasingStyle.Quint)
    ApplyScale(true)
    if FloatApplyPosition then
        FloatApplyPosition()
    end
    StatsBox.Position = UDim2.fromScale(Config.StatsX, Config.StatsY)
    StatsGui.Enabled = Config.StatsVisible
    SelectTab(Config.LastTab)
    SaveConfig(true)
    Toast("รีเซ็ตการตั้งค่าแล้ว")
end)

--==================================================
-- SIDEBAR CATEGORIES
--==================================================

CatGroup("เมนูหลัก")
Category("หน้าหลัก", "Home", "grid")
Category("ฟังก์ชัน", "Functions", "sliders")
CatGroup("ระบบ")
Category("ตั้งค่า", "Settings", "ring")

--==================================================
-- FLOATING RX BUTTON
--==================================================

local ToggleGui = New("ScreenGui", {
    Name = "RELWX_Floating",
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    IgnoreGuiInset = true,
}, PlayerGui)

local Float = New("Frame", {
    Size = UDim2.fromOffset(48, 48),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(Config.FloatX, Config.FloatY),
    BackgroundTransparency = 1,
    Active = true,
}, ToggleGui)

local Glow = New("Frame", {
    Size = UDim2.new(1, 8, 1, 8),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
}, Float)
Corner(Glow, 15)
local GlowStroke = Stroke(Glow, RGB(145, 145, 145), 3, 0.2)

local RX = New("TextButton", {
    Size = UDim2.fromScale(1, 1),
    Text = "RX",
    TextSize = 15,
    Font = FNT.B,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Active = true,
}, Float)
Corner(RX, 13)
local RXStroke = Stroke(RX, RGB(255, 255, 255), 2, 0.05)
local RXGrad = New("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.85),
        NumberSequenceKeypoint.new(1, 0),
    }),
}, RXStroke)
TweenService:Create(
    RXGrad,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
    { Rotation = 360 }
):Play()

OnTheme(function()
    local bg = Hex("FloatingButtonColor", RGB(18, 18, 18))
    RX.BackgroundColor3 = bg
    RX.TextColor3 = Lum(bg) > 0.55 and RGB(15, 15, 15) or RGB(255, 255, 255)
    RXStroke.Color = Hex("FloatingBorderColor", RGB(255, 255, 255))
    GlowStroke.Color = Hex("FloatingGlowColor", RGB(145, 145, 145))
end)

TweenService:Create(
    GlowStroke,
    TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Transparency = 0.65 }
):Play()

FloatApplyPosition = function()
    Float.Position = UDim2.fromScale(Config.FloatX, Config.FloatY)
end

MakeDraggable(RX, Float, "FloatX", "FloatY", function()
    SetWindow(not Config.WindowVisible)
end)

--==================================================
-- START
--==================================================

SelectTab(Config.LastTab)
RefreshStats()
RefreshHome()

if Config.WindowVisible then
    PlayOpen()
end

if not LoadedFromFile then
    SaveConfig(true) -- สร้างไฟล์ Config ครั้งแรก
end

print("[RELWX] UI v7 Loaded" .. (LoadedFromFile and " (Config loaded)" or " (new Config)"))
