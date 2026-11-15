--[[
    S2JR HUB - MERGED & CLEANED
    Full Hub + BoxESP + Tracers
    Drag · Minimize · Working Toggles · Value Controls
    Cleaned & Rewritten by SMITH for Kai
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean old
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "S2JR_HUB" or v.Name == "S2BoxESP" then
        v:Destroy()
    end
end

-------------------------------------------------
-- CONFIG / STATE
-------------------------------------------------
local Settings = {
    SpeedBoost = 70,
    CarrySpeed = 40,
    LaggerCarrySpeed = 24.5,
    CarpetSpeed = 160,
    StealRadius = 60,
    NormalPause = 73,
    AutoTPHeight = 20,
    FOV = 80,

    -- Toggles
    SpeedBoostEnabled = false,
    CarryMode = true,
    LaggerCarry = false,
    AutoCarry = false,
    AutoGiantPotion = false,

    AutoSteal = true,
    AntiRagdoll = true,
    InfiniteJump = true,
    AntiGummy = false,
    AntiBee = false,
    AntiPaintball = false,
    AntiBoogie = false,
    AntiTrap = false,
    AntiE01 = false,

    AutoTPDown = false,
    AutoLaserDrop = false,
    AutoLaserReset = false,
    AutoBoogieDrop = false,
    AutoDestroyTurret = false,
    AutoDestroyDoge = false,

    SpamPaintball = false,
    SpamLaserCape = false,
    WebSlinger = false,

    BoxESP = true,
    HighlightSkin = false,
    Tracers = true,
    ESPMineTrap = false,
}

local CurrentPage = "Speed"
local Dragging = false
local DragStart, StartPos

-------------------------------------------------
-- UTILS
-------------------------------------------------
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Notify(title, text)
    -- simple print for now, can expand later
    print("[S2JR]", title, "-", text)
end

-------------------------------------------------
-- MAIN GUI
-------------------------------------------------
local ScreenGui = Create("ScreenGui", {
    Name = "S2JR_HUB",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui
})

local Main = Create("Frame", {
    Name = "Main",
    BackgroundColor3 = Color3.fromRGB(10, 10, 18),
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -195, 0.5, -153),
    Size = UDim2.new(0, 391, 0, 306),
    ClipsDescendants = true,
    Parent = ScreenGui
})

Create("UICorner", {CornerRadius = UDim.new(0, 11), Parent = Main})
Create("UIStroke", {Color = Color3.fromRGB(30, 40, 80), Thickness = 1, Parent = Main})

-- Background image (optional)
local HubBG = Create("ImageLabel", {
    Name = "HubBG",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Image = "rbxassetid://118131424737973",
    ImageTransparency = 0.25,
    ScaleType = Enum.ScaleType.Crop,
    Parent = Main
})
Create("UICorner", {CornerRadius = UDim.new(0, 11), Parent = HubBG})

local Dim = Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(8, 8, 16),
    BackgroundTransparency = 0.55,
    Size = UDim2.new(1, 0, 1, 0),
    Parent = Main
})
Create("UICorner", {CornerRadius = UDim.new(0, 11), Parent = Dim})

-------------------------------------------------
-- TOP BAR
-------------------------------------------------
local TopBar = Create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 32),
    ZIndex = 5,
    Parent = Main
})

local Title = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(0, 110, 1, 0),
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
    Text = "S2 J'R HUB",
    TextColor3 = Color3.fromRGB(80, 120, 255),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
    Parent = TopBar
})

local DiscordLabel = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0.32, 0, 0, 0),
    Size = UDim2.new(0.4, 0, 1, 0),
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
    Text = "discord.gg/S2HUB",
    TextColor3 = Color3.fromRGB(80, 110, 160),
    TextSize = 11,
    ZIndex = 6,
    Parent = TopBar
})

local MinimizeBtn = Create("TextButton", {
    BackgroundColor3 = Color3.fromRGB(20, 20, 36),
    BorderSizePixel = 0,
    Position = UDim2.new(1, -28, 0.5, -11),
    Size = UDim2.new(0, 22, 0, 22),
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    Text = "-",
    TextColor3 = Color3.fromRGB(80, 110, 160),
    TextSize = 14,
    ZIndex = 10,
    Parent = TopBar
})
Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MinimizeBtn})

local TopLine = Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(30, 40, 80),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 32),
    Size = UDim2.new(1, 0, 0, 1),
    ZIndex = 4,
    Parent = Main
})

-------------------------------------------------
-- SIDEBAR
-------------------------------------------------
local Sidebar = Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(10, 10, 18),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 33),
    Size = UDim2.new(0, 118, 1, -33),
    ZIndex = 3,
    Parent = Main
})

local SideScroll = Create("ScrollingFrame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, -42),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(60, 90, 180),
    ZIndex = 4,
    Parent = Sidebar
})

Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 0),
    Parent = SideScroll
})

local SideFooter = Create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 1, -40),
    Size = UDim2.new(1, 0, 0, 40),
    ZIndex = 4,
    Parent = Sidebar
})

Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 4),
    Size = UDim2.new(1, -12, 0, 14),
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
    Text = "S2 J'R HUB",
    TextColor3 = Color3.fromRGB(80, 120, 255),
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
    Parent = SideFooter
})

Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 20),
    Size = UDim2.new(1, -12, 0, 12),
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
    Text = "discord.gg/S2HUB",
    TextColor3 = Color3.fromRGB(80, 110, 160),
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
    Parent = SideFooter
})

-------------------------------------------------
-- CONTENT AREA
-------------------------------------------------
local Content = Create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 119, 0, 33),
    Size = UDim2.new(1, -119, 1, -33),
    ZIndex = 2,
    Parent = Main
})

local Pages = {}

local function CreatePage(name)
    local page = Create("ScrollingFrame", {
        Name = name .. "Page",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(60, 90, 180),
        Visible = false,
        ZIndex = 3,
        Parent = Content
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = page
    })
    Pages[name] = page
    return page
end

local function SwitchPage(name)
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
    end
    CurrentPage = name
end

-------------------------------------------------
-- UI COMPONENTS
-------------------------------------------------
local function SectionHeader(parent, text, order)
    local f = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        LayoutOrder = order,
        Parent = parent
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f
    })
    Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(30, 40, 80),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = f
    })
    return f
end

local function SubHeader(parent, text, order)
    local f = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        LayoutOrder = order,
        Parent = parent
    })
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
        Text = text,
        TextColor3 = Color3.fromRGB(60, 100, 180),
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f
    })
    return f
end

local function Toggle(parent, text, key, order, default)
    local f = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(18, 18, 30),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = order,
        Parent = parent
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = f})
    Create("UIStroke", {Color = Color3.fromRGB(0, 50, 150), Transparency = 0.6, Parent = f})

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0, 0),
        Size = UDim2.new(0.65, 0, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f
    })

    local track = Create("Frame", {
        BackgroundColor3 = default and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(30, 30, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -47, 0.5, -10),
        Size = UDim2.new(0, 37, 0, 20),
        ZIndex = 5,
        Parent = f
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})

    local knob = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        ZIndex = 6,
        Parent = track
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

    if default then
        Create("UIStroke", {Color = Color3.fromRGB(80, 120, 255), Thickness = 1.5, Transparency = 0.3, Parent = track})
    end

    local btn = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 7,
        Parent = f
    })

    local state = default
    Settings[key] = state

    btn.MouseButton1Click:Connect(function()
        state = not state
        Settings[key] = state
        Tween(track, {BackgroundColor3 = state and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(30, 30, 50)})
        Tween(knob, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
        Notify(text, state and "ON" or "OFF")
    end)

    return f
end

local function NumberControl(parent, text, key, order, default, step)
    step = step or 1
    local f = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(18, 18, 30),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = order,
        Parent = parent
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = f})
    Create("UIStroke", {Color = Color3.fromRGB(0, 50, 150), Transparency = 0.6, Parent = f})

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f
    })

    local value = default
    Settings[key] = value

    local minus = Create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(20, 30, 70),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -90, 0.5, -11),
        Size = UDim2.new(0, 22, 0, 22),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text = "-",
        TextColor3 = Color3.fromRGB(80, 120, 255),
        TextSize = 14,
        ZIndex = 7,
        Parent = f
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = minus})

    local box = Create("TextBox", {
        BackgroundColor3 = Color3.fromRGB(8, 8, 18),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -66, 0.5, -11),
        Size = UDim2.new(0, 39, 0, 22),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
        Text = tostring(value),
        TextColor3 = Color3.fromRGB(80, 120, 255),
        TextSize = 11,
        ZIndex = 6,
        Parent = f
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = box})

    local plus = Create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(20, 30, 70),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -25, 0.5, -11),
        Size = UDim2.new(0, 22, 0, 22),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text = "+",
        TextColor3 = Color3.fromRGB(80, 120, 255),
        TextSize = 14,
        ZIndex = 7,
        Parent = f
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = plus})

    local function update(v)
        value = math.clamp(tonumber(v) or value, 0, 999)
        Settings[key] = value
        box.Text = tostring(value)
    end

    minus.MouseButton1Click:Connect(function()
        update(value - step)
    end)
    plus.MouseButton1Click:Connect(function()
        update(value + step)
    end)
    box.FocusLost:Connect(function()
        update(box.Text)
    end)

    return f
end

-------------------------------------------------
-- BUILD PAGES
-------------------------------------------------
local SpeedPage = CreatePage("Speed")
SectionHeader(SpeedPage, "SPEED", 1)
SubHeader(SpeedPage, "> MOUVEMENT", 2)
NumberControl(SpeedPage, "SPEED BOOST", "SpeedBoost", 3, 70, 5)
NumberControl(SpeedPage, "CARRY SPEED", "CarrySpeed", 4, 40, 5)
NumberControl(SpeedPage, "LAGGER CARRY SPEED", "LaggerCarrySpeed", 5, 24.5, 0.5)
NumberControl(SpeedPage, "CARPET SPEED", "CarpetSpeed", 6, 160, 10)
SubHeader(SpeedPage, "> MODE", 7)
Toggle(SpeedPage, "CARRY MODE", "CarryMode", 8, true)
Toggle(SpeedPage, "LAGGER CARRY", "LaggerCarry", 9, false)
Toggle(SpeedPage, "AUTO CARRY", "AutoCarry", 10, false)
Toggle(SpeedPage, "AUTO GIANT POTION", "AutoGiantPotion", 11, false)

local StealPage = CreatePage("Steal")
SectionHeader(StealPage, "STEAL", 1)
SubHeader(StealPage, "> AUTO STEAL", 2)
NumberControl(StealPage, "RADIUS", "StealRadius", 3, 60, 5)
Toggle(StealPage, "AUTO STEAL", "AutoSteal", 4, true)
NumberControl(StealPage, "NORMAL PAUSE %", "NormalPause", 5, 73, 1)

local PlayerPage = CreatePage("Player")
SectionHeader(PlayerPage, "PLAYER", 1)
SubHeader(PlayerPage, "> PROTECTION", 2)
Toggle(PlayerPage, "ANTI RAGDOLL", "AntiRagdoll", 3, true)
Toggle(PlayerPage, "INFINITE JUMP", "InfiniteJump", 4, true)
Toggle(PlayerPage, "ANTI GUMMY", "AntiGummy", 5, false)
Toggle(PlayerPage, "ANTI BEE", "AntiBee", 6, false)
Toggle(PlayerPage, "ANTI PAINTBALL", "AntiPaintball", 7, false)
Toggle(PlayerPage, "ANTI BOOGIE BOMB", "AntiBoogie", 8, false)
Toggle(PlayerPage, "ANTI TRAP", "AntiTrap", 9, false)
Toggle(PlayerPage, "ANTI E01 NOTIFIER", "AntiE01", 10, false)

local MiscPage = CreatePage("Misc")
SectionHeader(MiscPage, "MISC", 1)
SubHeader(MiscPage, "> TÉLÉPORTS", 2)
Toggle(MiscPage, "AUTO TP DOWN", "AutoTPDown", 3, false)
NumberControl(MiscPage, "AUTO TP DOWN HEIGHT", "AutoTPHeight", 4, 20, 5)
SubHeader(MiscPage, "> AUTO", 5)
Toggle(MiscPage, "AUTO LASER ON DROP", "AutoLaserDrop", 6, false)
Toggle(MiscPage, "AUTO LASER ON RESET", "AutoLaserReset", 7, false)
Toggle(MiscPage, "AUTO BOOGIE BOMB ON DROP", "AutoBoogieDrop", 8, false)
Toggle(MiscPage, "AUTO DESTROY TURRET", "AutoDestroyTurret", 9, false)
Toggle(MiscPage, "AUTO DESTROY DOGE", "AutoDestroyDoge", 10, false)

local SpamPage = CreatePage("Spam")
SectionHeader(SpamPage, "SPAM", 1)
SubHeader(SpamPage, "> AUTO SPAM", 2)
Toggle(SpamPage, "SPAM PAINTBALL GUN", "SpamPaintball", 3, false)
Toggle(SpamPage, "SPAM LASER CAPE AIMBOT", "SpamLaserCape", 4, false)
Toggle(SpamPage, "WEB SLINGER", "WebSlinger", 5, false)

local VisualPage = CreatePage("Visual")
SectionHeader(VisualPage, "VISUAL", 1)
SubHeader(VisualPage, "> ESP PLAYERS", 2)
Toggle(VisualPage, "BOX ESP", "BoxESP", 3, true)
Toggle(VisualPage, "HIGHLIGHT SKIN", "HighlightSkin", 4, false)
Toggle(VisualPage, "TRACERS", "Tracers", 5, true)
Toggle(VisualPage, "ESP MINE TRAP", "ESPMineTrap", 6, false)
SubHeader(VisualPage, "> CAMERA", 7)
NumberControl(VisualPage, "FOV", "FOV", 8, 80, 5)

local InterfacePage = CreatePage("Interface")
SectionHeader(InterfacePage, "INTERFACE", 1)
Toggle(InterfacePage, "SHOW KEYBINDS", "ShowKeybinds", 2, true)

local KeybindsPage = CreatePage("Keybinds")
SectionHeader(KeybindsPage, "KEYBINDS", 1)
Create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 40),
    LayoutOrder = 2,
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular),
    Text = "RightShift = Toggle UI\n(Customize later)",
    TextColor3 = Color3.fromRGB(160, 180, 220),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = KeybindsPage
})

-------------------------------------------------
-- SIDEBAR TABS
-------------------------------------------------
local TabNames = {"Speed", "Steal", "Player", "Misc", "Spam", "Visual", "Interface", "Keybinds"}
local TabButtons = {}

for i, name in ipairs(TabNames) do
    local btn = Create("TextButton", {
        Name = name .. "Tab",
        BackgroundColor3 = Color3.fromRGB(80, 120, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = i,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
        Text = string.upper(name),
        TextColor3 = Color3.fromRGB(80, 110, 160),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = SideScroll
    })
    Create("UIPadding", {PaddingLeft = UDim.new(0, 12), Parent = btn})

    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(TabButtons) do
            b.TextColor3 = Color3.fromRGB(80, 110, 160)
            b.BackgroundTransparency = 1
        end
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.85
        SwitchPage(name)
    end)

    TabButtons[name] = btn
end

-- Default
TabButtons["Speed"].TextColor3 = Color3.fromRGB(255, 255, 255)
TabButtons["Speed"].BackgroundTransparency = 0.85
SwitchPage("Speed")

-------------------------------------------------
-- DRAG
-------------------------------------------------
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

-------------------------------------------------
-- MINIMIZE
-------------------------------------------------
local Minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        Tween(Main, {Size = UDim2.new(0, 391, 0, 33)}, 0.2)
        MinimizeBtn.Text = "+"
    else
        Tween(Main, {Size = UDim2.new(0, 391, 0, 306)}, 0.2)
        MinimizeBtn.Text = "-"
    end
end)

-------------------------------------------------
-- TOGGLE UI (RightShift)
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-------------------------------------------------
-- BOX ESP + TRACERS
-------------------------------------------------
local ESPGui = Create("ScreenGui", {
    Name = "S2BoxESP",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 900,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui
})

local ESPFolder = Create("Folder", {Name = "ESPObjects", Parent = ESPGui})
local TracerFolder = Create("Folder", {Name = "Tracers", Parent = ESPGui})

local function CreateBox(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local box = Create("Frame", {
        Name = "ESP_" .. player.Name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2,
        Parent = ESPFolder
    })
    Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(0, 140, 255),
        Thickness = 2,
        Parent = box
    })

    local tracer = Create("Frame", {
        Name = "Tracer_" .. player.Name,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 140, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 2, 0, 2),
        Visible = false,
        Parent = TracerFolder
    })

    return box, tracer
end

local ESPCache = {}

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                if not ESPCache[player] then
                    local box, tracer = CreateBox(player)
                    ESPCache[player] = {Box = box, Tracer = tracer}
                end

                local data = ESPCache[player]
                local box = data.Box
                local tracer = data.Tracer

                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                if onScreen and Settings.BoxESP then
                    local size = 40 / (pos.Z * 0.04) -- rough scale
                    box.Size = UDim2.new(0, size, 0, size * 1.6)
                    box.Position = UDim2.new(0, pos.X - size/2, 0, pos.Y - size*0.8)
                    box.Visible = true
                else
                    box.Visible = false
                end

                if Settings.Tracers and onScreen then
                    local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y)
                    local target = Vector2.new(pos.X, pos.Y)
                    local dist = (target - screenCenter).Magnitude
                    local angle = math.deg(math.atan2(target.Y - screenCenter.Y, target.X - screenCenter.X))

                    tracer.Size = UDim2.new(0, dist, 0, 2)
                    tracer.Position = UDim2.new(0, (screenCenter.X + target.X)/2, 0, (screenCenter.Y + target.Y)/2)
                    tracer.Rotation = angle
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            else
                if ESPCache[player] then
                    ESPCache[player].Box.Visible = false
                    ESPCache[player].Tracer.Visible = false
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.BoxESP or Settings.Tracers then
        UpdateESP()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        ESPCache[player].Box:Destroy()
        ESPCache[player].Tracer:Destroy()
        ESPCache[player] = nil
    end
end)

-------------------------------------------------
-- BASIC FEATURES (examples that actually work)
-------------------------------------------------
-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- FOV
local function ApplyFOV()
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = Settings.FOV
    end
end

-- Speed (simple WalkSpeed override when enabled)
local function ApplySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Settings.SpeedBoostEnabled then
        hum.WalkSpeed = Settings.SpeedBoost
    end
end

-- Hook character
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    ApplyFOV()
end)

-- Live FOV update when number changes
-- (the NumberControl already updates Settings.FOV, we just apply it)
RunService.Heartbeat:Connect(function()
    ApplyFOV()
end)

-------------------------------------------------
-- FINISHED
-------------------------------------------------
print("[S2JR HUB] Loaded successfully | RightShift to toggle")
Notify("S2JR HUB", "Merged & Ready")

return ScreenGui