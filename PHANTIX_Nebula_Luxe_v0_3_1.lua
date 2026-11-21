--[[
    PHANTIX — eigenständige GUI
    Version: 0.3.1 (Nebula Luxe)

    Eigenständige Oberfläche mit Roblox-Standard-UI.
    Keine Gameplay-, Cheat-, Exploit-, Anti-Cheat-Bypass- oder Redeem-Logik.

    Start: Script ausführen.
    Minimieren: kompakte PHANTIX-Leiste mit AN/AUS-Demo-Schalter; + stellt wieder her.
    Mobile: großer, verschiebbarer P-Button; Antippen blendet das Menü ein/aus.
    Beenden: Schließen (×) oder PHANTIX_Stop() in der Laufzeitumgebung.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end
local playerGui = player:WaitForChild("PlayerGui")

-- Optionaler Cleanup-Namespace. getgenv wird nur für den Stop-Handler verwendet.
local env = (typeof(getgenv) == "function" and getgenv()) or _G
if type(env.PHANTIX_Stop) == "function" then
    pcall(env.PHANTIX_Stop)
end

-- ── Konfiguration ────────────────────────────────────────────────────────
local UI_NAME = "PHANTIX_Nebula_Luxe"
local FONT_SCALE = 1.15
local WIN_W, WIN_H = 360, 520
local MIN_H = 56
local GALAXY_ASSET_ID = "rbxassetid://90923178598005"

-- ── Theme: Nebula Luxe ───────────────────────────────────────────────────
local Theme = {
    BgDeep = Color3.fromRGB(10, 5, 32),
    BgDeepEnd = Color3.fromRGB(5, 16, 26),
    BgMid = Color3.fromRGB(16, 8, 40),
    PanelGlass = Color3.fromRGB(26, 18, 53),
    CardGlass = Color3.fromRGB(36, 26, 69),
    InputBg = Color3.fromRGB(15, 12, 28),
    Hover = Color3.fromRGB(52, 40, 92),
    Purple = Color3.fromRGB(139, 92, 246),
    PurpleLight = Color3.fromRGB(167, 139, 250),
    PurpleDim = Color3.fromRGB(91, 60, 170),
    Emerald = Color3.fromRGB(16, 185, 129),
    EmeraldDim = Color3.fromRGB(5, 150, 105),
    Text = Color3.fromRGB(245, 243, 255),
    Dim = Color3.fromRGB(160, 155, 180),
    Red = Color3.fromRGB(239, 68, 68),
    Warn = Color3.fromRGB(250, 204, 90),
    Stroke = Color3.fromRGB(167, 139, 250),
}

-- ── Allgemeine Hilfsfunktionen ───────────────────────────────────────────
local function new(className, props, parent)
    local object = Instance.new(className)
    for property, value in pairs(props or {}) do
        object[property] = value
    end
    if parent then object.Parent = parent end
    return object
end

local function corner(object, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius or 8)
    item.Parent = object
    return item
end

local function stroke(object, color, thickness, transparency)
    local item = Instance.new("UIStroke")
    item.Color = color or Theme.Stroke
    item.Thickness = thickness or 1
    item.Transparency = transparency or 0
    item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    item.Parent = object
    return item
end

local function tween(object, properties, duration)
    local item = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    item:Play()
    return item
end

local function fontSize(size)
    return math.floor((size or 11) * FONT_SCALE + 0.5)
end

local function makeLabel(parent, text, size, color, font, alignment)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextSize = fontSize(size),
        TextColor3 = color or Theme.Text,
        Font = font or Enum.Font.GothamMedium,
        TextXAlignment = alignment or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

-- Activated deckt Maus und Touch ab. Mehrfachbindungen werden vermieden.
local function bindClick(button, callback)
    button.Activated:Connect(callback)
end

local function applyGlass(frame, baseColor, transparency)
    local amount = transparency or 0.3
    frame.BackgroundColor3 = baseColor
    frame.BackgroundTransparency = amount

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.5, amount),
        NumberSequenceKeypoint.new(1, math.min(amount + 0.15, 0.9)),
    })
    gradient.Parent = frame

    local rim = new("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        ZIndex = frame.ZIndex + 1,
    }, frame)

    local rimGradient = Instance.new("UIGradient")
    rimGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })
    rimGradient.Parent = rim
end

local function escapeRichText(value)
    local text = tostring(value or "")
    text = text:gsub("&", "&amp;")
    text = text:gsub("<", "&lt;")
    text = text:gsub(">", "&gt;")
    text = text:gsub('"', "&quot;")
    text = text:gsub("'", "&apos;")
    return text
end

-- ── ScreenGui und Skalierung ─────────────────────────────────────────────
local GUI = new("ScreenGui", {
    Name = UI_NAME,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local Master = new("Frame", {
    Name = "Master",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
}, GUI)

local GlobalScale = new("UIScale", {
    Name = "GlobalScale",
    Scale = 1,
}, Master)

local connections = {}
local viewportConnection

local function track(connection)
    table.insert(connections, connection)
    return connection
end

local function untrack(connection)
    if not connection then return end
    for index = #connections, 1, -1 do
        if connections[index] == connection then
            table.remove(connections, index)
            break
        end
    end
    pcall(function() connection:Disconnect() end)
end

local function recalculateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local height = camera.ViewportSize.Y
    local scale
    if UserInputService.TouchEnabled then
        scale = math.clamp(height / 1000, 0.62, 0.88)
    else
        scale = math.clamp(height / 800, 0.70, 1.05)
    end

    GlobalScale.Scale = scale
    Master.Size = UDim2.new(1 / scale, 0, 1 / scale, 0)
end

local function setupCamera()
    if viewportConnection then
        viewportConnection:Disconnect()
        viewportConnection = nil
    end

    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(recalculateScale)
    end
    recalculateScale()
end

track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(setupCamera))
task.spawn(setupCamera)

-- ── Hauptfenster ─────────────────────────────────────────────────────────
local Window = new("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(WIN_W, WIN_H),
    Position = UDim2.new(1, -(WIN_W + 24), 0, 60),
    BackgroundColor3 = Theme.BgDeep,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
    ZIndex = 2,
}, Master)
corner(Window, 18)

local WindowStroke = stroke(Window, Theme.PurpleLight, 1.5, 0.08)

-- ── Prozeduraler Nebula-Hintergrund ──────────────────────────────────────
local Background = new("Frame", {
    Name = "BgGradient",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Theme.BgDeep,
    BorderSizePixel = 0,
    ZIndex = 2,
}, Window)
corner(Background, 18)

local backgroundGradient = Instance.new("UIGradient")
backgroundGradient.Rotation = 135
backgroundGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.BgMid),
    ColorSequenceKeypoint.new(0.45, Theme.BgDeep),
    ColorSequenceKeypoint.new(1, Theme.BgDeepEnd),
})
backgroundGradient.Parent = Background

local NebulaPurple = new("Frame", {
    Name = "NebulaPurple",
    Size = UDim2.new(0.9, 0, 0.7, 0),
    Position = UDim2.new(-0.25, 0, -0.15, 0),
    BackgroundColor3 = Theme.Purple,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0,
    ZIndex = 4,
}, Window)
corner(NebulaPurple, 200)

local purpleGradient = Instance.new("UIGradient")
purpleGradient.Rotation = 90
purpleGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(0.5, 0.85),
    NumberSequenceKeypoint.new(1, 1),
})
purpleGradient.Parent = NebulaPurple

local NebulaEmerald = new("Frame", {
    Name = "NebulaEmerald",
    Size = UDim2.new(0.8, 0, 0.55, 0),
    Position = UDim2.new(0.45, 0, 0.6, 0),
    BackgroundColor3 = Theme.Emerald,
    BackgroundTransparency = 0.88,
    BorderSizePixel = 0,
    ZIndex = 4,
}, Window)
corner(NebulaEmerald, 200)

local emeraldGradient = Instance.new("UIGradient")
emeraldGradient.Rotation = 90
emeraldGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.88),
    NumberSequenceKeypoint.new(1, 0.65),
})
emeraldGradient.Parent = NebulaEmerald

if GALAXY_ASSET_ID ~= "" then
    local galaxy = new("ImageLabel", {
        Name = "GalaxyImage",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = GALAXY_ASSET_ID,
        ImageTransparency = 0.28,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 3,
    }, Window)
    corner(galaxy, 18)
end

local ReadabilityOverlay = new("Frame", {
    Name = "ReadabilityOverlay",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Theme.BgDeep,
    BackgroundTransparency = 0.70,
    BorderSizePixel = 0,
    ZIndex = 5,
}, Window)
corner(ReadabilityOverlay, 18)

-- ── Header: bleibt beim Minimieren sichtbar ──────────────────────────────
local MIN_HEADER_HEIGHT = MIN_H
local Header = new("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, MIN_HEADER_HEIGHT),
    BackgroundTransparency = 1,
    Active = true,
    ZIndex = 10,
}, Window)

local LiveDot = new("Frame", {
    Size = UDim2.fromOffset(6, 6),
    Position = UDim2.fromOffset(16, 20),
    BackgroundColor3 = Theme.Emerald,
    BorderSizePixel = 0,
    ZIndex = 11,
}, Header)
corner(LiveDot, 3)

local Brand = makeLabel(Header, "PHANTIX", 16, Theme.Text, Enum.Font.FredokaOne)
local brandEdge = Instance.new("UIStroke")
brandEdge.Color = Theme.Emerald
brandEdge.Thickness = 0.65
brandEdge.Transparency = 0.28
brandEdge.Parent = Brand
local brandGradient = Instance.new("UIGradient")
brandGradient.Rotation = 0
brandGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 255, 250)),
    ColorSequenceKeypoint.new(0.48, Theme.Emerald),
    ColorSequenceKeypoint.new(1, Theme.PurpleLight),
})
brandGradient.Parent = Brand
Brand.Size = UDim2.new(1, -142, 0, 22)
Brand.Position = UDim2.fromOffset(26, 10)
Brand.ZIndex = 11

local Subtitle = makeLabel(Header, "Nebula Luxe  •  Test 1", 9, Theme.Dim)
Subtitle.Size = UDim2.new(1, -142, 0, 14)
Subtitle.Position = UDim2.fromOffset(26, 32)
Subtitle.ZIndex = 11

local function makeHeaderButton(text, xOffset)
    local button = new("TextButton", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, xOffset, 0, 12),
        BackgroundColor3 = Theme.CardGlass,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text,
        TextSize = fontSize(13),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        ZIndex = 11,
    }, Header)
    corner(button, 6)
    stroke(button, Theme.PurpleLight, 1, 0.4)
    return button
end

local MinBtn = makeHeaderButton("–", -78)
local CloseBtn = makeHeaderButton("×", -42)

local CompactPower = new("TextButton", {
    Name = "CompactPower",
    Size = UDim2.fromOffset(54, 30),
    Position = UDim2.new(1, -142, 0, 13),
    BackgroundColor3 = Theme.Emerald,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "AN",
    TextSize = fontSize(11),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBlack,
    Visible = false,
    ZIndex = 12,
}, Header)
corner(CompactPower, 9)
stroke(CompactPower, Theme.Emerald, 1.5, 0.12)
local compactPowerOn = false
local function setCompactPower(state)
    compactPowerOn = state
    CompactPower.Text = state and "AN" or "AUS"
    CompactPower.BackgroundColor3 = state and Theme.Emerald or Theme.CardGlass
    CompactPower.TextColor3 = Theme.Text
end
bindClick(CompactPower, function()
    setCompactPower(not compactPowerOn)
end)

new("Frame", {
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 0, MIN_HEADER_HEIGHT - 1),
    BackgroundColor3 = Theme.PurpleLight,
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
    ZIndex = 10,
}, Window)

-- ── ContentGroup: nur Body + BottomBar werden ausgeblendet ────────────────
local ContentGroup = new("CanvasGroup", {
    Name = "Content",
    Size = UDim2.new(1, 0, 1, -MIN_H),
    Position = UDim2.fromOffset(0, MIN_H),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    GroupTransparency = 0,
    ZIndex = 5,
}, Window)

local Body = new("Frame", {
    Name = "Body",
    Size = UDim2.new(1, -24, 1, -68),
    Position = UDim2.fromOffset(12, 8),
    BackgroundTransparency = 1,
    ZIndex = 5,
}, ContentGroup)

local TabBar = new("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Theme.PanelGlass,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 5,
}, Body)
corner(TabBar, 10)
stroke(TabBar, Theme.PurpleLight, 1, 0.35)

local function makeTabButton(text, xScale)
    local button = new("TextButton", {
        Size = UDim2.new(1 / 3, -4, 1, -4),
        Position = UDim2.new(xScale, 2, 0, 2),
        BackgroundColor3 = Theme.CardGlass,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text,
        TextSize = fontSize(10),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        ZIndex = 6,
    }, TabBar)
    corner(button, 7)
    return button
end

local DashboardTabBtn = makeTabButton("Dashboard", 0)
local SettingsTabBtn = makeTabButton("Settings", 1 / 3)
local ConsoleTabBtn = makeTabButton("Console", 2 / 3)

local TabContentRoot = new("Frame", {
    Name = "TabContentRoot",
    Size = UDim2.new(1, 0, 1, -40),
    Position = UDim2.fromOffset(0, 40),
    BackgroundTransparency = 1,
    ZIndex = 5,
}, Body)

local function makeTabContent(name, visible)
    local frame = new("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = visible,
        ZIndex = 5,
    }, TabContentRoot)

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }, frame)
    return frame
end

local DashboardContent = makeTabContent("Dashboard", true)
local SettingsContent = makeTabContent("Settings", false)
local ConsoleContent = makeTabContent("Console", false)

local function setActiveTab(activeName)
    local tabs = {
        Dashboard = { DashboardContent, DashboardTabBtn },
        Settings = { SettingsContent, SettingsTabBtn },
        Console = { ConsoleContent, ConsoleTabBtn },
    }

    for name, pair in pairs(tabs) do
        local selected = name == activeName
        pair[1].Visible = selected
        tween(pair[2], {
            BackgroundColor3 = selected and Theme.PurpleDim or Theme.CardGlass,
            BackgroundTransparency = selected and 0.08 or 0.35,
        }, 0.12)
    end
end

bindClick(DashboardTabBtn, function() setActiveTab("Dashboard") end)
bindClick(SettingsTabBtn, function() setActiveTab("Settings") end)
bindClick(ConsoleTabBtn, function() setActiveTab("Console") end)
setActiveTab("Dashboard") -- Startzustand: Dashboard-Tab ist als aktiv markiert

-- ── Console und Log-System ───────────────────────────────────────────────
local logLines = {}
local MAX_LOG = 120
local ConsoleText
local Console

-- CanvasPosition wird von Roblox auf den gültigen Bereich begrenzt. Ein großer Wert
-- scrollt daher ans Ende, ohne AbsoluteSize (enthält UIScale) mit lokalen Einheiten zu mischen.
local function scrollConsoleToBottom()
    task.defer(function()
        RunService.Heartbeat:Wait()
        if Console and Console.Parent then
            Console.CanvasPosition = Vector2.new(0, 1000000)
        end
    end)
end

local function logLine(message, color)
    local safeMessage = escapeRichText(message)
    local chosenColor = color or Theme.Text
    local colorTag = string.format(
        "rgb(%d,%d,%d)",
        math.floor(chosenColor.R * 255),
        math.floor(chosenColor.G * 255),
        math.floor(chosenColor.B * 255)
    )

    table.insert(logLines, '<font color="' .. colorTag .. '">' .. safeMessage .. "</font>")
    if #logLines > MAX_LOG then
        table.remove(logLines, 1)
    end

    if ConsoleText then
        ConsoleText.Text = table.concat(logLines, "\n")
        scrollConsoleToBottom()
    end
end

-- ── Dashboard: Status-Cards ──────────────────────────────────────────────
local StatusRow = new("Frame", {
    Name = "StatusRow",
    Size = UDim2.new(1, 0, 0, 70),
    BackgroundTransparency = 1,
    LayoutOrder = 1,
    ZIndex = 5,
}, DashboardContent)

new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
}, StatusRow)

local function makeStatCard(order, title, value, accent)
    local card = new("Frame", {
        Size = UDim2.new(1 / 3, -4, 1, 0),
        BackgroundColor3 = Theme.CardGlass,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 6,
    }, StatusRow)
    corner(card, 10)
    stroke(card, accent or Theme.PurpleLight, 1, 0.4)
    applyGlass(card, Theme.CardGlass, 0.35)

    local titleLabel = makeLabel(card, title, 9, Theme.Dim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.Position = UDim2.fromOffset(0, 10)
    titleLabel.ZIndex = 7

    local valueLabel = makeLabel(card, value, 18, accent or Theme.Text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    valueLabel.Size = UDim2.new(1, 0, 0, 26)
    valueLabel.Position = UDim2.fromOffset(0, 30)
    valueLabel.ZIndex = 7
    return card, valueLabel
end

local _, SniperStatVal = makeStatCard(1, "SNIPER", "OFF", Theme.Dim)
local _, SolvedStatVal = makeStatCard(2, "SOLVED", "0", Theme.Emerald)
local _, AskedStatVal = makeStatCard(3, "ASKED", "0", Theme.PurpleLight)

-- ── Dashboard: Last Code ─────────────────────────────────────────────────
local LastCodeCard = new("Frame", {
    Name = "LastCodeCard",
    Size = UDim2.new(1, 0, 0, 90),
    BackgroundColor3 = Theme.CardGlass,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    LayoutOrder = 2,
    ZIndex = 6,
}, DashboardContent)
corner(LastCodeCard, 10)
stroke(LastCodeCard, Theme.Emerald, 1.25, 0.2)
applyGlass(LastCodeCard, Theme.CardGlass, 0.35)

local LastCodeTitle = makeLabel(LastCodeCard, "LAST CODE", 9, Theme.Emerald, Enum.Font.GothamBlack)
LastCodeTitle.Size = UDim2.new(1, -80, 0, 14)
LastCodeTitle.Position = UDim2.fromOffset(12, 8)
LastCodeTitle.ZIndex = 7

local CopyBtn = new("TextButton", {
    Name = "CopyBtn",
    Size = UDim2.fromOffset(56, 20),
    Position = UDim2.new(1, -68, 0, 6),
    BackgroundColor3 = Theme.Emerald,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "COPY",
    TextSize = fontSize(9),
    TextColor3 = Color3.fromRGB(10, 10, 15),
    Font = Enum.Font.GothamBlack,
    ZIndex = 7,
}, LastCodeCard)
corner(CopyBtn, 6)

local LastOutputBox = new("TextBox", {
    Name = "LastOutput",
    Size = UDim2.new(1, -24, 0, 44),
    Position = UDim2.fromOffset(12, 34),
    BackgroundColor3 = Theme.InputBg,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    Text = "",
    PlaceholderText = "— no code yet —",
    PlaceholderColor3 = Theme.Dim,
    TextSize = fontSize(11),
    Font = Enum.Font.Code,
    TextColor3 = Theme.Emerald,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextEditable = false,
    TextWrapped = true,
    ZIndex = 7,
}, LastCodeCard)
corner(LastOutputBox, 6)
stroke(LastOutputBox, Theme.Emerald, 1, 0.35)
new("UIPadding", {
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 6),
}, LastOutputBox)

local function copyToClipboard(text)
    if type(setclipboard) ~= "function" then return false end
    local ok = pcall(setclipboard, tostring(text or ""))
    return ok
end

bindClick(CopyBtn, function()
    local text = LastOutputBox.Text
    if not text or text == "" then
        logLine("Nothing to copy.", Theme.Warn)
        return
    end

    if copyToClipboard(text) then
        logLine("Copied to clipboard.", Theme.Emerald)
    else
        logLine("Clipboard unavailable — copy manually.", Theme.Red)
    end
end)

-- ── Dashboard: Riddle-Eingabe (nur UI-Demo) ──────────────────────────────
local RiddleCard = new("Frame", {
    Name = "RiddleCard",
    Size = UDim2.new(1, 0, 0, 74),
    BackgroundColor3 = Theme.CardGlass,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    LayoutOrder = 3,
    ZIndex = 6,
}, DashboardContent)
corner(RiddleCard, 10)
stroke(RiddleCard, Theme.PurpleLight, 1, 0.4)
applyGlass(RiddleCard, Theme.CardGlass, 0.35)

local RiddleTitle = makeLabel(RiddleCard, "RIDDLE INPUT", 9, Theme.PurpleLight, Enum.Font.GothamBlack)
RiddleTitle.Size = UDim2.new(1, -24, 0, 14)
RiddleTitle.Position = UDim2.fromOffset(12, 8)
RiddleTitle.ZIndex = 7

local RiddleBox = new("TextBox", {
    Name = "RiddleInput",
    Size = UDim2.new(1, -70, 0, 30),
    Position = UDim2.fromOffset(12, 32),
    BackgroundColor3 = Theme.InputBg,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    Text = "",
    PlaceholderText = "Type your riddle here…",
    PlaceholderColor3 = Theme.Dim,
    TextSize = fontSize(10),
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
}, RiddleCard)
corner(RiddleBox, 6)
stroke(RiddleBox, Theme.PurpleLight, 1, 0.4)
new("UIPadding", {
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 6),
}, RiddleBox)

local SolveBtn = new("TextButton", {
    Name = "SolveBtn",
    Size = UDim2.fromOffset(50, 30),
    Position = UDim2.new(1, -62, 0, 32),
    BackgroundColor3 = Theme.Purple,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "SOLVE",
    TextSize = fontSize(10),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBlack,
    ZIndex = 7,
}, RiddleCard)
corner(SolveBtn, 6)
stroke(SolveBtn, Theme.PurpleLight, 1, 0.2)

bindClick(SolveBtn, function()
    local query = RiddleBox.Text
    if not query or query == "" then
        logLine("Type a riddle first.", Theme.Warn)
        return
    end

    logLine("Demo input received: " .. query:sub(1, 60), Theme.PurpleLight)
    logLine("No service connected in this UI test.", Theme.Dim)
    LastOutputBox.Text = "— demo only —"
end)

-- ── Settings ─────────────────────────────────────────────────────────────
local minimised = false
local compactMode = false
local windowTween
local contentTween
local setGlowEnabled -- Vorwärtsdeklaration: Callback greift erst nach Setup darauf zu.

local function makeSettingToggle(order, title, initial, onChange)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.CardGlass,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 6,
    }, SettingsContent)
    corner(row, 10)
    stroke(row, Theme.PurpleLight, 1, 0.4)

    local titleLabel = makeLabel(row, title, 11, Theme.Text, Enum.Font.GothamSemibold)
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.fromOffset(14, 0)
    titleLabel.ZIndex = 7

    local button = new("TextButton", {
        Size = UDim2.fromOffset(44, 24),
        Position = UDim2.new(1, -54, 0.5, -12),
        BackgroundColor3 = initial and Theme.Emerald or Theme.BgMid,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = initial and "ON" or "OFF",
        TextSize = fontSize(10),
        TextColor3 = initial and Color3.fromRGB(10, 10, 15) or Theme.Dim,
        Font = Enum.Font.GothamBlack,
        ZIndex = 7,
    }, row)
    corner(button, 12)

    local state = initial
    bindClick(button, function()
        state = not state
        tween(button, {
            BackgroundColor3 = state and Theme.Emerald or Theme.BgMid,
        }, 0.14)
        button.Text = state and "ON" or "OFF"
        button.TextColor3 = state and Color3.fromRGB(10, 10, 15) or Theme.Dim
        if onChange then onChange(state) end
    end)

    return button
end

local glowEnabled = true
local glowTween
local function setGlow(on)
    glowEnabled = on
    if not on then
        if glowTween then
            glowTween:Cancel()
            glowTween = nil
        end
        if WindowStroke and WindowStroke.Parent then
            WindowStroke.Thickness = 1.5
            WindowStroke.Transparency = 0.08
        end
    end
end
setGlowEnabled = setGlow

makeSettingToggle(1, "Breathing Glow", true, function(enabled)
    logLine("Breathing glow " .. (enabled and "on." or "off."), enabled and Theme.Emerald or Theme.Dim)
    setGlowEnabled(enabled)
end)

makeSettingToggle(2, "Nebula Clouds", true, function(enabled)
    logLine("Nebula clouds " .. (enabled and "on." or "off."), enabled and Theme.Emerald or Theme.Dim)
    tween(NebulaPurple, { BackgroundTransparency = enabled and 0.82 or 1 }, 0.3)
    tween(NebulaEmerald, { BackgroundTransparency = enabled and 0.88 or 1 }, 0.3)
end)

makeSettingToggle(3, "Compact Mode", false, function(enabled)
    compactMode = enabled
    logLine("Compact Mode " .. (enabled and "on." or "off."), enabled and Theme.Emerald or Theme.Dim)
    if not minimised then
        if windowTween then windowTween:Cancel() end
        windowTween = TweenService:Create(
            Window,
            TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(WIN_W, compactMode and 460 or WIN_H) }
        )
        windowTween:Play()
    end
end)

-- ── Console ──────────────────────────────────────────────────────────────
local ConsoleBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    LayoutOrder = 1,
    ZIndex = 6,
}, ConsoleContent)

local ConsoleTitle = makeLabel(ConsoleBar, "CONSOLE", 9, Theme.PurpleLight, Enum.Font.GothamBlack)
ConsoleTitle.Size = UDim2.fromOffset(80, 24)
ConsoleTitle.Position = UDim2.fromOffset(4, 0)
ConsoleTitle.ZIndex = 7

local ClearBtn = new("TextButton", {
    Size = UDim2.fromOffset(56, 22),
    Position = UDim2.new(1, -56, 0, 1),
    BackgroundColor3 = Theme.CardGlass,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "CLEAR",
    TextSize = fontSize(9),
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    ZIndex = 7,
}, ConsoleBar)
corner(ClearBtn, 6)
stroke(ClearBtn, Theme.PurpleLight, 1, 0.4)

Console = new("ScrollingFrame", {
    Name = "Console",
    Size = UDim2.new(1, 0, 1, -32),
    Position = UDim2.fromOffset(0, 32),
    BackgroundColor3 = Theme.InputBg,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollingEnabled = true,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.PurpleLight,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    LayoutOrder = 2,
    ZIndex = 6,
}, ConsoleContent)
corner(Console, 8)
stroke(Console, Theme.PurpleLight, 1, 0.4)

ConsoleText = new("TextLabel", {
    Name = "Output",
    Size = UDim2.new(1, -16, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.fromOffset(8, 6),
    BackgroundTransparency = 1,
    RichText = true,
    Text = "",
    TextSize = fontSize(10),
    Font = Enum.Font.Code,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    ZIndex = 7,
}, Console)

-- Beim Öffnen des Console-Tabs ans Ende scrollen (Tab war vorher unsichtbar).
bindClick(ConsoleTabBtn, scrollConsoleToBottom)

bindClick(ClearBtn, function()
    table.clear(logLines)
    ConsoleText.Text = ""
    logLine("Console cleared.", Theme.Dim)
end)

-- ── BottomBar ────────────────────────────────────────────────────────────
local BottomBar = new("Frame", {
    Name = "BottomBar",
    Size = UDim2.new(1, -24, 0, 40),
    Position = UDim2.new(0, 12, 1, -52),
    BackgroundColor3 = Theme.PanelGlass,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 6,
}, ContentGroup)
corner(BottomBar, 10)
stroke(BottomBar, Theme.PurpleLight, 1, 0.4)
applyGlass(BottomBar, Theme.PanelGlass, 0.2)

local LogoTile = new("Frame", {
    Size = UDim2.fromOffset(26, 26),
    Position = UDim2.new(0, 8, 0.5, -13),
    BackgroundColor3 = Theme.Purple,
    BorderSizePixel = 0,
    ZIndex = 7,
}, BottomBar)
corner(LogoTile, 8)
stroke(LogoTile, Theme.Text, 1, 0.7)

local LogoLetter = makeLabel(LogoTile, "P", 16, Theme.Text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
LogoLetter.Size = UDim2.new(1, 0, 1, 0)
LogoLetter.ZIndex = 8

local WordMark = makeLabel(BottomBar, "PHANTIX", 15, Theme.PurpleLight, Enum.Font.FredokaOne)
WordMark.Size = UDim2.fromOffset(100, 22)
WordMark.Position = UDim2.fromOffset(42, 4)
WordMark.ZIndex = 7

local VersionLabel = makeLabel(BottomBar, "0.3.1", 9, Theme.Dim, Enum.Font.GothamSemibold, Enum.TextXAlignment.Right)
VersionLabel.Size = UDim2.fromOffset(60, 22)
VersionLabel.Position = UDim2.new(1, -68, 0, 4)
VersionLabel.ZIndex = 7

-- ── Mobile-Schwebeschaltfläche ───────────────────────────────────────────
local MobileToggle = new("TextButton", {
    Name = "MobileToggle",
    Size = UDim2.fromOffset(60, 60),
    Position = UDim2.new(1, -22, 1, -112),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundColor3 = Theme.Purple,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "P",
    TextSize = fontSize(25),
    TextColor3 = Theme.Text,
    Font = Enum.Font.FredokaOne,
    Visible = UserInputService.TouchEnabled,
    ZIndex = 50,
}, Master)
corner(MobileToggle, 30)
stroke(MobileToggle, Theme.Emerald, 2.5, 0.08)
applyGlass(MobileToggle, Theme.Purple, 0.08)
local pGradient = Instance.new("UIGradient")
pGradient.Rotation = 45
pGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Emerald),
    ColorSequenceKeypoint.new(0.48, Theme.Purple),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 95, 190)),
})
pGradient.Parent = MobileToggle

-- ── P-Schaltfläche bewegen: Touch und Maus ────────────────────────────────
local mobileButtonWasDragged = false
do
    local moving = false
    local moveInput
    local startPoint
    local startAbsolute

    track(MobileToggle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
            and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        moving = true
        moveInput = input
        mobileButtonWasDragged = false
        startPoint = Vector2.new(input.Position.X, input.Position.Y)
        startAbsolute = MobileToggle.AbsolutePosition
    end))

    track(UserInputService.InputChanged:Connect(function(input)
        if not moving or not moveInput then return end
        local isTouch = moveInput.UserInputType == Enum.UserInputType.Touch and input == moveInput
        local isMouse = moveInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        if not isTouch and not isMouse then return end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - startPoint
        if delta.Magnitude > 5 then mobileButtonWasDragged = true end
        local scale = GlobalScale.Scale
        if scale <= 0 then scale = 1 end
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local size = MobileToggle.AbsoluteSize
        local absoluteX = math.clamp(
            startAbsolute.X + delta.X,
            8,
            math.max(8, viewport.X - size.X - 8)
        )
        local absoluteY = math.clamp(
            startAbsolute.Y + delta.Y,
            8,
            math.max(8, viewport.Y - size.Y - 8)
        )
        MobileToggle.Position = UDim2.new(
            0, absoluteX / scale + size.X / scale,
            0, absoluteY / scale + size.Y / scale
        )
    end))

    track(UserInputService.InputEnded:Connect(function(input)
        if moveInput and input == moveInput then
            moving = false
            moveInput = nil
        end
    end))
end

-- ── Fenster ziehen: Maus und Touch ───────────────────────────────────────
do
    local dragging = false
    local dragInput
    local dragStart
    local dragStartAbsolute
    local startPosition
    local moved = false
    local threshold = UserInputService.TouchEnabled and 8 or 2

    local function overControl(position)
        for _, control in ipairs({ MinBtn, CloseBtn }) do
            local p = control.AbsolutePosition
            local s = control.AbsoluteSize
            if position.X >= p.X - 6 and position.X <= p.X + s.X + 6
                and position.Y >= p.Y - 6 and position.Y <= p.Y + s.Y + 6 then
                return true
            end
        end
        return false
    end

    track(Header.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if dragging or overControl(input.Position) then return end

        dragging = true
        dragInput = input
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        dragStartAbsolute = Window.AbsolutePosition
        startPosition = Window.Position
        moved = false

        local endConnection
        endConnection = track(input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End
                or input.UserInputState == Enum.UserInputState.Cancel then
                if dragInput == input then
                    dragging = false
                    dragInput = nil
                end
                if endConnection then
                    untrack(endConnection)
                    endConnection = nil
                end
            end
        end))
    end))

    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then return end

        local isTouchMove = dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput
        local isMouseMove = dragInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        if not isTouchMove and not isMouseMove then return end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        if not moved then
            if delta.Magnitude < threshold then return end
            moved = true
        end

        local scale = GlobalScale.Scale
        if scale <= 0 then scale = 1 end

        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        local absoluteSize = Window.AbsoluteSize
        local clampedX = math.clamp(
            dragStartAbsolute.X + delta.X,
            8,
            math.max(8, viewport.X - absoluteSize.X - 8)
        )
        local clampedY = math.clamp(
            dragStartAbsolute.Y + delta.Y,
            8,
            math.max(8, viewport.Y - absoluteSize.Y - 8)
        )

        Window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + (clampedX - dragStartAbsolute.X) / scale,
            startPosition.Y.Scale,
            startPosition.Y.Offset + (clampedY - dragStartAbsolute.Y) / scale
        )
    end))
end

-- ── Minimize / Restore ───────────────────────────────────────────────────
local function setMinimised(state)
    minimised = state

    if windowTween then windowTween:Cancel() end
    if contentTween then contentTween:Cancel() end

    if not minimised then
        ContentGroup.GroupTransparency = 1
        CompactPower.Visible = false
        Subtitle.Visible = true
        Brand.Position = UDim2.fromOffset(26, 10)
        Brand.Size = UDim2.new(1, -142, 0, 22)
    else
        CompactPower.Visible = true
        Subtitle.Visible = false
        Brand.Size = UDim2.new(0, 94, 0, 32)
        Brand.Position = UDim2.fromOffset(26, 12)
    end

    local targetWidth = minimised and 270 or WIN_W
    windowTween = TweenService:Create(
        Window,
        TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(targetWidth, minimised and MIN_H or (compactMode and 460 or WIN_H)) }
    )

    contentTween = TweenService:Create(
        ContentGroup,
        TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { GroupTransparency = minimised and 1 or 0 }
    )

    windowTween:Play()
    contentTween:Play()
    MinBtn.Text = minimised and "+" or "–"
end

bindClick(MinBtn, function()
    setMinimised(not minimised)
end)

bindClick(MobileToggle, function()
    if mobileButtonWasDragged then
        mobileButtonWasDragged = false
        return
    end
    -- Ein Tap stellt ein minimiertes Fenster direkt wieder her.
    -- Nur ein vollständig geöffnetes Fenster wird ausgeblendet.
    if not Window.Visible then
        Window.Visible = true
        if minimised then setMinimised(false) end
        return
    end

    if minimised then
        setMinimised(false)
    else
        Window.Visible = false
    end
end)

-- ── Breathing Glow ───────────────────────────────────────────────────────
task.spawn(function()
    while GUI.Parent and Window.Parent do
        if glowEnabled then
            local first = TweenService:Create(
                WindowStroke,
                TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Thickness = 2.2, Transparency = 0.02 }
            )
            glowTween = first
            first:Play()
            first.Completed:Wait()
            if not GUI.Parent then break end
            if not glowEnabled then
                task.wait(0.1)
            else
                local second = TweenService:Create(
                    WindowStroke,
                    TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { Thickness = 1.5, Transparency = 0.08 }
                )
                glowTween = second
                second:Play()
                second.Completed:Wait()
            end
        else
            task.wait(0.25)
        end
    end
end)

-- ── Cleanup / Close ──────────────────────────────────────────────────────
local stopped = false

local function stopEverything()
    if stopped then return end
    stopped = true

    if viewportConnection then
        pcall(function() viewportConnection:Disconnect() end)
        viewportConnection = nil
    end
    if glowTween then
        pcall(function() glowTween:Cancel() end)
        glowTween = nil
    end

    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(connections)

    if GUI and GUI.Parent then
        GUI:Destroy()
    end

    if env.PHANTIX_Stop == stopEverything then
        env.PHANTIX_Stop = nil
    end
end

env.PHANTIX_Stop = stopEverything
bindClick(CloseBtn, stopEverything)

-- ── Öffnungsanimation ────────────────────────────────────────────────────
do
    local targetPosition = Window.Position
    local openScale = new("UIScale", {
        Name = "OpenScale",
        Scale = 0.92,
    }, Window)

    Window.Position = UDim2.new(
        targetPosition.X.Scale,
        targetPosition.X.Offset,
        targetPosition.Y.Scale,
        targetPosition.Y.Offset + 18
    )

    tween(openScale, { Scale = 1 }, 0.22)
    tween(Window, { Position = targetPosition }, 0.22)
end

-- ── Initiale Logs ────────────────────────────────────────────────────────
logLine("PHANTIX 0.3.1 loaded — Nebula Luxe.", Theme.PurpleLight)
logLine("Header stays visible while minimized.", Theme.Emerald)
logLine("Mobile P-toggle is available on touch devices.", Theme.Dim)
logLine("UI demo only — no service connected.", Theme.Warn)

print("[PHANTIX] 0.3.1 Nebula Luxe loaded.")
