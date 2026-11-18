--[[
    DEMI PING LAGGER — GUI ONLY
    Themes: Purple Dream / Red Fire / Arctic Chaos
    This is a visual interface only. It does not create network lag,
    interfere with servers, or affect other players.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then
    return
end

-- Remove an older copy
local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, core = pcall(function() return CoreGui end)
    if ok and core then return core end
    return player:WaitForChild("PlayerGui")
end

local parent = getGuiParent()
pcall(function()
    local old = parent:FindFirstChild("DemiPingLagger")
    if old then old:Destroy() end
end)

local themes = {
    ["Purple Dream"] = {
        bg = Color3.fromRGB(13, 9, 24),
        panel = Color3.fromRGB(25, 17, 43),
        panel2 = Color3.fromRGB(36, 23, 60),
        accent = Color3.fromRGB(177, 92, 255),
        accent2 = Color3.fromRGB(112, 55, 205),
        text = Color3.fromRGB(246, 238, 255),
        muted = Color3.fromRGB(170, 151, 194),
        stroke = Color3.fromRGB(126, 70, 190),
    },
    ["Red Fire"] = {
        bg = Color3.fromRGB(22, 8, 12),
        panel = Color3.fromRGB(39, 14, 20),
        panel2 = Color3.fromRGB(58, 19, 27),
        accent = Color3.fromRGB(255, 65, 78),
        accent2 = Color3.fromRGB(190, 30, 48),
        text = Color3.fromRGB(255, 240, 241),
        muted = Color3.fromRGB(196, 145, 151),
        stroke = Color3.fromRGB(175, 42, 57),
    },
    ["Arctic Chaos"] = {
        bg = Color3.fromRGB(7, 17, 29),
        panel = Color3.fromRGB(13, 31, 48),
        panel2 = Color3.fromRGB(19, 48, 67),
        accent = Color3.fromRGB(53, 220, 245),
        accent2 = Color3.fromRGB(126, 112, 255),
        text = Color3.fromRGB(235, 250, 255),
        muted = Color3.fromRGB(145, 183, 199),
        stroke = Color3.fromRGB(54, 160, 196),
    }
}

local currentTheme = "Purple Dream"
local objects = {}

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function make(className, props, parentObject)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parentObject
    return obj
end

local gui = make("ScreenGui", {
    Name = "DemiPingLagger",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parent)

local root = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(590, 390),
    BackgroundColor3 = themes[currentTheme].bg,
    BorderSizePixel = 0,
}, gui)
corner(root, 16)
local rootStroke = stroke(root, themes[currentTheme].stroke, 1.5, 0.12)
objects.root = root
objects.rootStroke = rootStroke

local rootGradient = make("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 19, 48)),
        ColorSequenceKeypoint.new(1, themes[currentTheme].bg),
    })
}, root)
objects.rootGradient = rootGradient

-- Soft accent strip
local topLine = make("Frame", {
    Name = "AccentLine",
    Size = UDim2.new(1, -28, 0, 3),
    Position = UDim2.fromOffset(14, 0),
    BackgroundColor3 = themes[currentTheme].accent,
    BorderSizePixel = 0,
}, root)
corner(topLine, 4)
objects.topLine = topLine

-- Sidebar
local sidebar = make("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(12, 15),
    Size = UDim2.new(0, 158, 1, -30),
    BackgroundColor3 = themes[currentTheme].panel,
    BorderSizePixel = 0,
}, root)
corner(sidebar, 12)
objects.sidebar = sidebar

local brand = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 16),
    Size = UDim2.new(1, -28, 0, 30),
    Font = Enum.Font.GothamBlack,
    Text = "DEMI",
    TextColor3 = themes[currentTheme].text,
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)
objects.brand = brand

local brandSub = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 44),
    Size = UDim2.new(1, -28, 0, 18),
    Font = Enum.Font.GothamMedium,
    Text = "PING LAGGER",
    TextColor3 = themes[currentTheme].accent,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 0.05,
}, sidebar)
objects.brandSub = brandSub

local sideDivider = make("Frame", {
    Position = UDim2.fromOffset(14, 76),
    Size = UDim2.new(1, -28, 0, 1),
    BackgroundColor3 = themes[currentTheme].stroke,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
}, sidebar)
objects.sideDivider = sideDivider

local navLabel = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 91),
    Size = UDim2.new(1, -30, 0, 16),
    Font = Enum.Font.GothamBold,
    Text = "MENU",
    TextColor3 = themes[currentTheme].muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)
objects.navLabel = navLabel

local navButton = make("TextButton", {
    Name = "AppearanceButton",
    Position = UDim2.fromOffset(10, 116),
    Size = UDim2.new(1, -20, 0, 38),
    BackgroundColor3 = themes[currentTheme].panel2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamSemibold,
    Text = "  ◈   Appearance",
    TextColor3 = themes[currentTheme].text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)
corner(navButton, 8)
local navStroke = stroke(navButton, themes[currentTheme].accent, 1, 0.35)
objects.navButton = navButton
objects.navStroke = navStroke

local sidebarFooter = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 1, -40),
    Size = UDim2.new(1, -28, 0, 26),
    Font = Enum.Font.Gotham,
    Text = "GUI ONLY  •  v1.0",
    TextColor3 = themes[currentTheme].muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)
objects.sidebarFooter = sidebarFooter

-- Main content
local content = make("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(184, 15),
    Size = UDim2.new(1, -199, 1, -30),
    BackgroundTransparency = 1,
}, root)
objects.content = content

local header = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(4, 2),
    Size = UDim2.new(1, -54, 0, 30),
    Font = Enum.Font.GothamBold,
    Text = "Appearance",
    TextColor3 = themes[currentTheme].text,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
}, content)
objects.header = header

local subtitle = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(5, 33),
    Size = UDim2.new(1, -10, 0, 22),
    Font = Enum.Font.Gotham,
    Text = "Choose the visual style of your interface.",
    TextColor3 = themes[currentTheme].muted,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, content)
objects.subtitle = subtitle

local minimize = make("TextButton", {
    Name = "Minimize",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -38, 0, 0),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = themes[currentTheme].panel2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "−",
    TextColor3 = themes[currentTheme].text,
    TextSize = 20,
}, content)
corner(minimize, 8)
objects.minimize = minimize

local close = make("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -2, 0, 0),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = themes[currentTheme].panel2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "×",
    TextColor3 = themes[currentTheme].text,
    TextSize = 20,
}, content)
corner(close, 8)
objects.close = close

local preview = make("Frame", {
    Name = "Preview",
    Position = UDim2.fromOffset(4, 68),
    Size = UDim2.new(1, -8, 0, 94),
    BackgroundColor3 = themes[currentTheme].panel,
    BorderSizePixel = 0,
}, content)
corner(preview, 12)
local previewStroke = stroke(preview, themes[currentTheme].stroke, 1, 0.25)
objects.preview = preview
objects.previewStroke = previewStroke

local previewTitle = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 12),
    Size = UDim2.new(1, -28, 0, 22),
    Font = Enum.Font.GothamBold,
    Text = "THEME PREVIEW",
    TextColor3 = themes[currentTheme].text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, preview)
objects.previewTitle = previewTitle

local previewAccent = make("Frame", {
    Position = UDim2.fromOffset(14, 44),
    Size = UDim2.new(1, -28, 0, 7),
    BackgroundColor3 = themes[currentTheme].accent,
    BorderSizePixel = 0,
}, preview)
corner(previewAccent, 5)
objects.previewAccent = previewAccent

local previewCaption = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 59),
    Size = UDim2.new(1, -28, 0, 18),
    Font = Enum.Font.Gotham,
    Text = "Neon accents • Dark panels • Clean layout",
    TextColor3 = themes[currentTheme].muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, preview)
objects.previewCaption = previewCaption

local chooseLabel = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(5, 178),
    Size = UDim2.new(1, -10, 0, 20),
    Font = Enum.Font.GothamBold,
    Text = "SELECT A THEME",
    TextColor3 = themes[currentTheme].text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, content)
objects.chooseLabel = chooseLabel

local themeButtons = {}
local themeNames = {"Purple Dream", "Red Fire", "Arctic Chaos"}
local buttonY = {207, 253, 299}

for i, name in ipairs(themeNames) do
    local b = make("TextButton", {
        Name = name:gsub("%s", "") .. "Button",
        Position = UDim2.fromOffset(4, buttonY[i]),
        Size = UDim2.new(1, -8, 0, 38),
        BackgroundColor3 = themes[currentTheme].panel,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamSemibold,
        Text = "   " .. name,
        TextColor3 = themes[currentTheme].text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, content)
    corner(b, 9)
    local swatch = make("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -11, 0.5, 0),
        Size = UDim2.fromOffset(46, 8),
        BackgroundColor3 = themes[name].accent,
        BorderSizePixel = 0,
    }, b)
    corner(swatch, 5)
    local bs = stroke(b, themes[currentTheme].stroke, 1, 0.45)
    themeButtons[name] = {button = b, stroke = bs, swatch = swatch}
end
objects.themeButtons = themeButtons

local status = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 4, 1, -22),
    Size = UDim2.new(1, -8, 0, 18),
    Font = Enum.Font.Gotham,
    Text = "Current theme: Purple Dream",
    TextColor3 = themes[currentTheme].muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, content)
objects.status = status

local restore, restoreStroke

local function applyTheme(name)
    local t = themes[name]
    if not t then return end
    currentTheme = name

    -- Strong recolor across the complete menu.
    local changes = {
        [root] = {BackgroundColor3 = t.bg},
        [rootStroke] = {Color = t.accent, Transparency = 0.02, Thickness = 2},
        [rootGradient] = {Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.panel2),
            ColorSequenceKeypoint.new(1, t.bg),
        })},
        [topLine] = {BackgroundColor3 = t.accent},
        [sidebar] = {BackgroundColor3 = t.panel},
        [brand] = {TextColor3 = t.text},
        [brandSub] = {TextColor3 = t.accent},
        [sideDivider] = {BackgroundColor3 = t.accent},
        [navLabel] = {TextColor3 = t.accent},
        [navButton] = {BackgroundColor3 = t.accent2, TextColor3 = t.text},
        [sidebarFooter] = {TextColor3 = t.muted},
        [header] = {TextColor3 = t.accent},
        [subtitle] = {TextColor3 = t.text},
        [close] = {BackgroundColor3 = t.accent2, TextColor3 = t.text},
        [minimize] = {BackgroundColor3 = t.accent2, TextColor3 = t.text},
        [preview] = {BackgroundColor3 = t.panel2},
        [previewStroke] = {Color = t.accent, Transparency = 0.05, Thickness = 2},
        [previewTitle] = {TextColor3 = t.accent},
        [previewAccent] = {BackgroundColor3 = t.accent},
        [previewCaption] = {TextColor3 = t.text},
        [chooseLabel] = {TextColor3 = t.accent},
        [status] = {TextColor3 = t.text},
    }
    for obj, props in pairs(changes) do
        if obj and obj.Parent then
            tween(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
        end
    end

    -- Recolor every theme option strongly, while preserving its own color swatch.
    for themeName, data in pairs(themeButtons) do
        local selected = themeName == name
        tween(data.button, TweenInfo.new(0.25), {
            BackgroundColor3 = selected and t.accent2 or t.panel2,
            TextColor3 = t.text,
        })
        tween(data.stroke, TweenInfo.new(0.25), {
            Color = selected and t.accent or t.stroke,
            Transparency = selected and 0 or 0.12,
            Thickness = selected and 2.5 or 1.4,
        })
        if data.swatch then
            data.swatch.BackgroundColor3 = themes[themeName].accent
        end
    end

    -- Remaining UI text and panels inherit the chosen palette instead of staying purple.
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            if descendant ~= brand and descendant ~= brandSub
                and descendant ~= navLabel and descendant ~= sidebarFooter
                and descendant ~= header and descendant ~= subtitle
                and descendant ~= previewTitle and descendant ~= previewCaption
                and descendant ~= chooseLabel and descendant ~= status then
                descendant.TextColor3 = t.text
            end
        elseif descendant:IsA("TextButton") then
            if descendant ~= navButton and descendant ~= close
                and descendant ~= minimize then
                descendant.TextColor3 = t.text
                descendant.BackgroundColor3 = t.panel2
            end
        end
    end

    if restore and restore.Parent then
        tween(restore, TweenInfo.new(0.25), {BackgroundColor3 = t.panel2, TextColor3 = t.accent})
    end
    if restoreStroke and restoreStroke.Parent then
        tween(restoreStroke, TweenInfo.new(0.25), {Color = t.accent})
    end

    status.Text = "Current theme: " .. name
    previewCaption.Text = name .. "  •  Live theme preview"
end

for name, data in pairs(themeButtons) do
    -- Activated supports both mouse clicks and mobile touch.
    data.button.Activated:Connect(function()
        applyTheme(name)
    end)
end

-- Minimize hides the full window and shows a small reopen button.
restore = make("TextButton", {
    Name = "DemiRestoreButton",
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.new(0, 18, 0.5, -24),
    Size = UDim2.fromOffset(48, 48),
    BackgroundColor3 = themes[currentTheme].panel2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBlack,
    Text = "D",
    TextColor3 = themes[currentTheme].accent,
    TextSize = 23,
    Visible = false,
    ZIndex = 20,
}, gui)
corner(restore, 14)
restoreStroke = stroke(restore, themes[currentTheme].accent, 1.5, 0.08)

minimize.Activated:Connect(function()
    root.Visible = false
    restore.Visible = true
end)

restore.Activated:Connect(function()
    restore.Visible = false
    root.Visible = true
end)

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Drag the window using the top portion of the main panel.
local dragging = false
local dragInput
local dragStart
local startPosition

root.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        local p = input.Position
        local inButtonArea = p.X >= root.AbsolutePosition.X + root.AbsoluteSize.X - 78
        if p.Y <= root.AbsolutePosition.Y + 58 and not inButtonArea then
            dragging = true
            dragStart = p
            startPosition = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
end)

root.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

-- Visible cinematic hand-to-GUI intro. The game remains visible behind it.
applyTheme(currentTheme)

-- Keep the actual menu underneath the intro artwork until the reveal finishes.
root.ZIndex = 5
for _, ui in ipairs(root:GetDescendants()) do
    if ui:IsA("GuiObject") then
        ui.ZIndex = 5
    end
end

local intro = make("Frame", {
    Name = "DemiIntroOverlay",
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 50,
}, gui)

local introGlow = make("Frame", {
    Name = "IntroGlow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.51, 0),
    Size = UDim2.fromOffset(150, 150),
    BackgroundColor3 = themes[currentTheme].accent,
    BackgroundTransparency = 0.58,
    BorderSizePixel = 0,
    ZIndex = 51,
}, intro)
corner(introGlow, 100)
local introGlowStroke = stroke(introGlow, themes[currentTheme].accent, 3, 0.02)

local hand = make("TextLabel", {
    Name = "IntroHand",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.49, 0),
    Size = UDim2.fromOffset(150, 135),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "✋",
    TextSize = 94,
    TextColor3 = themes[currentTheme].accent,
    TextTransparency = 0,
    ZIndex = 53,
}, intro)

local introCaption = make("TextLabel", {
    Name = "IntroCaption",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0.51, 82),
    Size = UDim2.fromOffset(320, 30),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "DEMI PING LAGGER",
    TextSize = 20,
    TextColor3 = themes[currentTheme].text,
    TextTransparency = 0,
    ZIndex = 53,
}, intro)

local introSub = make("TextLabel", {
    Name = "IntroSub",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0.51, 111),
    Size = UDim2.fromOffset(320, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "INITIALIZING INTERFACE",
    TextSize = 10,
    TextColor3 = themes[currentTheme].muted,
    TextTransparency = 0.08,
    ZIndex = 53,
}, intro)

local skip = make("TextButton", {
    Name = "SkipIntro",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, 18),
    Size = UDim2.fromOffset(82, 36),
    BackgroundColor3 = themes[currentTheme].panel2,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Font = Enum.Font.GothamBold,
    Text = "SKIP  ›",
    TextColor3 = themes[currentTheme].text,
    TextSize = 11,
    ZIndex = 60,
}, intro)
corner(skip, 9)
local skipStroke = stroke(skip, themes[currentTheme].accent, 1.5, 0.05)

root.Visible = false
root.Position = UDim2.new(0.5, 0, 0.51, 0)
root.Size = UDim2.fromOffset(24, 20)
root.BackgroundTransparency = 0.1

local introDone = false
local function finishIntro()
    if introDone or not gui.Parent then return end
    introDone = true

    -- The REAL menu appears from the hand's center and expands to full size.
    root.Visible = true
    root.Position = UDim2.new(0.5, 0, 0.51, 0)
    root.Size = UDim2.fromOffset(24, 20)
    root.BackgroundTransparency = 0.08

    tween(root, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(590, 390),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0,
    })
    tween(hand, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
        TextTransparency = 1,
        TextSize = 35,
        Position = UDim2.new(0.5, 0, 0.46, -15),
    })
    tween(introCaption, TweenInfo.new(0.35), {TextTransparency = 1})
    tween(introSub, TweenInfo.new(0.3), {TextTransparency = 1})
    tween(introGlow, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(520, 520),
        BackgroundTransparency = 1,
    })
    tween(introGlowStroke, TweenInfo.new(0.65), {Transparency = 1, Thickness = 5})
    tween(skip, TweenInfo.new(0.2), {TextTransparency = 1, BackgroundTransparency = 1})
    tween(skipStroke, TweenInfo.new(0.2), {Transparency = 1})
    task.delay(0.95, function()
        if intro and intro.Parent then
            intro:Destroy()
        end
    end)
end

skip.Activated:Connect(finishIntro)

-- A deliberate 3-second intro so it is actually visible, not over in a blink.
task.spawn(function()
    tween(introGlow, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(210, 210),
        BackgroundTransparency = 0.48,
    })
    tween(hand, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextSize = 104,
        Position = UDim2.new(0.5, 0, 0.47, 0),
    })
    task.wait(0.85)
    if introDone then return end
    tween(introGlow, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {
        Size = UDim2.fromOffset(245, 245),
        BackgroundTransparency = 0.62,
    })
    tween(hand, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        TextSize = 96,
        Position = UDim2.new(0.5, 0, 0.49, 0),
    })
    task.wait(1.75)
    if not introDone then
        finishIntro()
    end
end)

print("Demi Ping Lagger GUI loaded. Visible hand-to-menu intro and full theme recoloring enabled.")
