-- ============================================================================
-- AFG INTRO (richer atmosphere + smooth Afghan X opening, approx. 4 seconds)
-- Recreates the supplied video style with Roblox GUI effects.
-- ============================================================================
local function playAFGIntro()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local player = Players.LocalPlayer
    while not player do task.wait(); player = Players.LocalPlayer end

    local parent
    pcall(function() if type(gethui) == "function" then parent = gethui() end end)
    parent = parent or player:WaitForChild("PlayerGui")
    local old = parent:FindFirstChild("AFG_Intro")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "AFG_Intro"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = parent

    local root = Instance.new("Frame")
    root.Size = UDim2.fromScale(1, 1)
    root.BackgroundColor3 = Color3.fromRGB(3, 4, 6)
    root.BorderSizePixel = 0
    root.Parent = gui
    local bg = Instance.new("UIGradient")
    bg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(42, 5, 13)),
        ColorSequenceKeypoint.new(0.34, Color3.fromRGB(12, 8, 13)),
        ColorSequenceKeypoint.new(0.68, Color3.fromRGB(7, 15, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 35, 20))
    })
    bg.Rotation = 18
    bg.Parent = root

    local function tween(obj, duration, props, style, direction)
        local t = TweenService:Create(obj, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
        t:Play()
        return t
    end

    -- Soft colored light pools create depth behind the logo.
    local function glowBlob(color, pos, size, transparency)
        local blob = Instance.new("Frame")
        blob.AnchorPoint = Vector2.new(0.5, 0.5)
        blob.Position = pos
        blob.Size = size
        blob.BackgroundColor3 = color
        blob.BackgroundTransparency = transparency
        blob.BorderSizePixel = 0
        blob.Parent = root
        Instance.new("UICorner", blob).CornerRadius = UDim.new(1, 0)
        local g = Instance.new("UIGradient")
        g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(1, 1)})
        g.Rotation = 90
        g.Parent = blob
        return blob
    end
    local redGlow = glowBlob(Color3.fromRGB(190, 22, 45), UDim2.fromScale(0.22, 0.48), UDim2.fromScale(0.48, 0.72), 0.48)
    local greenGlow = glowBlob(Color3.fromRGB(20, 145, 75), UDim2.fromScale(0.78, 0.52), UDim2.fromScale(0.48, 0.72), 0.5)
    local centerGlow = glowBlob(Color3.fromRGB(120, 120, 120), UDim2.fromScale(0.5, 0.48), UDim2.fromScale(0.32, 0.42), 0.82)
    tween(redGlow, 3.8, {Position = UDim2.fromScale(0.34, 0.45), Size = UDim2.fromScale(0.58, 0.8), BackgroundTransparency = 0.62})
    tween(greenGlow, 3.8, {Position = UDim2.fromScale(0.66, 0.53), Size = UDim2.fromScale(0.58, 0.8), BackgroundTransparency = 0.64})
    tween(centerGlow, 2.4, {Size = UDim2.fromScale(0.46, 0.56), BackgroundTransparency = 0.9})

    -- Framed cinematic edges.
    local frame = Instance.new("Frame")
    frame.Position = UDim2.fromScale(0.025, 0.055)
    frame.Size = UDim2.fromScale(0.95, 0.89)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = root
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(210, 205, 195)
    frameStroke.Thickness = 1.4
    frameStroke.Transparency = 0.48
    frameStroke.Parent = frame

    -- Radial beams, alternating Afghan red and green.
    local rays = Instance.new("Frame")
    rays.Size = UDim2.fromScale(1, 1)
    rays.BackgroundTransparency = 1
    rays.Parent = root
    for i = 1, 40 do
        local ray = Instance.new("Frame")
        ray.AnchorPoint = Vector2.new(0.5, 0.5)
        ray.Position = UDim2.fromScale(0.5, 0.49)
        ray.Size = UDim2.new(0, (i % 4 == 0) and 3 or 1, 0, 0)
        ray.Rotation = (i - 1) * 9
        ray.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(220, 35, 55) or Color3.fromRGB(35, 190, 105)
        ray.BackgroundTransparency = 0.7
        ray.BorderSizePixel = 0
        ray.Parent = rays
        tween(ray, 0.9, {Size = UDim2.new(0, (i % 4 == 0) and 3 or 1, 0, 620), BackgroundTransparency = 0.84})
    end

    -- Floating smoke-like wisps drift behind the title.
    for i = 1, 9 do
        local smoke = Instance.new("Frame")
        smoke.AnchorPoint = Vector2.new(0.5, 0.5)
        smoke.Position = UDim2.fromScale(0.08 + (i * 0.095), 0.3 + ((i % 3) * 0.2))
        smoke.Size = UDim2.fromScale(0.17 + (i % 3) * 0.035, 0.07 + (i % 2) * 0.035)
        smoke.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(115, 35, 43) or Color3.fromRGB(35, 105, 70)
        smoke.BackgroundTransparency = 0.68
        smoke.BorderSizePixel = 0
        smoke.Parent = root
        Instance.new("UICorner", smoke).CornerRadius = UDim.new(1, 0)
        local sg = Instance.new("UIGradient")
        sg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.28), NumberSequenceKeypoint.new(1, 1)})
        sg.Parent = smoke
        tween(smoke, 2.2 + (i % 3) * 0.35, {
            Position = UDim2.fromScale(math.clamp(smoke.Position.X.Scale + (i % 2 == 0 and 0.12 or -0.1), 0, 1), math.clamp(smoke.Position.Y.Scale - 0.12, 0.08, 0.9)),
            BackgroundTransparency = 0.88,
            Size = smoke.Size + UDim2.fromScale(0.08, 0.04)
        }, Enum.EasingStyle.Sine)
    end

    -- Sparks / embers.
    local random = Random.new()
    for i = 1, 52 do
        local dot = Instance.new("Frame")
        local s = random:NextInteger(2, 5)
        dot.Size = UDim2.fromOffset(s, s)
        dot.Position = UDim2.fromScale(random:NextNumber(0.04, 0.96), random:NextNumber(0.08, 0.92))
        dot.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 75, 65) or Color3.fromRGB(80, 235, 145)
        dot.BackgroundTransparency = random:NextNumber(0.12, 0.38)
        dot.BorderSizePixel = 0
        dot.Parent = root
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        tween(dot, random:NextNumber(1.0, 2.0), {
            Position = UDim2.fromScale(math.clamp(dot.Position.X.Scale + random:NextNumber(-0.09, 0.09), 0, 1), math.clamp(dot.Position.Y.Scale - random:NextNumber(0.08, 0.2), 0, 1)),
            BackgroundTransparency = 0.88
        }, Enum.EasingStyle.Sine)
    end

    -- Logo glow layers and main AFG lettering.
    local logoGlow = Instance.new("TextLabel")
    logoGlow.BackgroundTransparency = 1
    logoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    logoGlow.Position = UDim2.fromScale(0.5, 0.465)
    logoGlow.Size = UDim2.fromScale(0.58, 0.28)
    logoGlow.Font = Enum.Font.GothamBlack
    logoGlow.Text = "AFG"
    logoGlow.TextScaled = true
    logoGlow.TextColor3 = Color3.fromRGB(190, 45, 58)
    logoGlow.TextTransparency = 1
    logoGlow.Parent = root
    local logo = Instance.new("TextLabel")
    logo.BackgroundTransparency = 1
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.45)
    logo.Size = UDim2.fromScale(0.52, 0.24)
    logo.Font = Enum.Font.GothamBlack
    logo.Text = "AFG"
    logo.TextScaled = true
    logo.TextColor3 = Color3.fromRGB(250, 248, 242)
    logo.TextTransparency = 1
    logo.Parent = root
    local logoStroke = Instance.new("UIStroke")
    logoStroke.Color = Color3.fromRGB(12, 12, 12)
    logoStroke.Thickness = 2.5
    logoStroke.Transparency = 0.12
    logoStroke.Parent = logo

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.Position = UDim2.fromScale(0.5, 0.59)
    subtitle.Size = UDim2.fromScale(0.5, 0.055)
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.Text = "AFGHAN GAMING"
    subtitle.TextScaled = true
    subtitle.TextColor3 = Color3.fromRGB(225, 225, 225)
    subtitle.TextTransparency = 1
    subtitle.Parent = root

    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.fromScale(0.5, 0.635)
    line.Size = UDim2.fromScale(0, 0.004)
    line.BackgroundColor3 = Color3.fromRGB(235, 235, 225)
    line.BorderSizePixel = 0
    line.Parent = root
    local lineGlow = Instance.new("UIStroke")
    lineGlow.Color = Color3.fromRGB(170, 40, 55)
    lineGlow.Thickness = 3
    lineGlow.Transparency = 0.25
    lineGlow.Parent = line

    tween(logoGlow, 0.55, {TextTransparency = 0.66, Size = UDim2.fromScale(0.61, 0.3)}, Enum.EasingStyle.Back)
    tween(logo, 0.62, {TextTransparency = 0, Position = UDim2.fromScale(0.5, 0.455), Size = UDim2.fromScale(0.54, 0.25)}, Enum.EasingStyle.Back)
    tween(subtitle, 0.55, {TextTransparency = 0, Position = UDim2.fromScale(0.5, 0.575)})
    tween(line, 0.55, {Size = UDim2.fromScale(0.3, 0.004)})
    task.wait(1.35)

    -- Pull the title into light, then form the red/green Afghan X from the center.
    tween(logo, 0.22, {TextTransparency = 1, Size = UDim2.fromScale(0.42, 0.19)})
    tween(logoGlow, 0.22, {TextTransparency = 1})
    tween(subtitle, 0.18, {TextTransparency = 1})
    tween(line, 0.18, {BackgroundTransparency = 1, Size = UDim2.fromScale(0.05, 0.004)})
    task.wait(0.16)

    local xParts = {}
    local function makeX(color, rotation, side)
        local bar = Instance.new("Frame")
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.fromScale(0.5, 0.49)
        bar.Size = UDim2.new(0, 0, 0, 17)
        bar.Rotation = rotation
        bar.BackgroundColor3 = color
        bar.BorderSizePixel = 0
        bar.Parent = root
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(245, 240, 225)
        stroke.Thickness = 2
        stroke.Transparency = 0.08
        stroke.Parent = bar
        xParts[#xParts + 1] = {bar = bar, side = side}
    end
    makeX(Color3.fromRGB(190, 25, 48), 45, -1)
    makeX(Color3.fromRGB(30, 155, 83), -45, 1)
    for _, item in ipairs(xParts) do
        tween(item.bar, 0.58, {
            Size = UDim2.new(0.39, 0, 0, 17),
            Position = UDim2.fromScale(0.5 + item.side * 0.012, 0.49)
        }, Enum.EasingStyle.Back)
    end

    local emblem = Instance.new("Frame")
    emblem.AnchorPoint = Vector2.new(0.5, 0.5)
    emblem.Position = UDim2.fromScale(0.5, 0.49)
    emblem.Size = UDim2.fromOffset(0, 0)
    emblem.BackgroundColor3 = Color3.fromRGB(5, 8, 8)
    emblem.BackgroundTransparency = 0.08
    emblem.BorderSizePixel = 0
    emblem.Parent = root
    Instance.new("UICorner", emblem).CornerRadius = UDim.new(1, 0)
    local emblemStroke = Instance.new("UIStroke")
    emblemStroke.Color = Color3.fromRGB(245, 240, 225)
    emblemStroke.Thickness = 2.4
    emblemStroke.Parent = emblem
    local mark = Instance.new("TextLabel")
    mark.BackgroundTransparency = 1
    mark.Size = UDim2.fromScale(1, 1)
    mark.Font = Enum.Font.GothamBlack
    mark.Text = "AFG"
    mark.TextColor3 = Color3.fromRGB(250, 248, 242)
    mark.TextScaled = true
    mark.TextTransparency = 1
    mark.Parent = emblem
    tween(emblem, 0.42, {Size = UDim2.fromOffset(82, 82)}, Enum.EasingStyle.Back)
    tween(mark, 0.3, {TextTransparency = 0})
    task.wait(1.0)

    -- X opens outward and the whole intro dissolves smoothly into the AFG GUI.
    for _, item in ipairs(xParts) do
        tween(item.bar, 0.32, {
            Position = UDim2.fromScale(0.5 + item.side * 0.12, 0.49),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.31, 0, 0, 12)
        }, Enum.EasingStyle.Quad)
    end
    tween(emblem, 0.28, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1})
    tween(mark, 0.2, {TextTransparency = 1})
    task.wait(0.22)

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("GuiObject") then
            local props = {}
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then props.TextTransparency = 1 end
            if obj:IsA("Frame") then props.BackgroundTransparency = 1 end
            if next(props) then tween(obj, 0.24, props) end
        end
    end
    tween(root, 0.28, {BackgroundTransparency = 1})
    task.wait(0.34)
    gui:Destroy()
end

task.spawn(function()
    pcall(playAFGIntro)
end)

--[[
    Afg Joiner - STEAL A BRAINROT - Roblox Script
    Features: Auto Join, Blacklist, Firebase Integration, GUI
    Theme: Red Neon
    DISPLAY: Name | Value | JOIN Button
    NO LAG - OPTIMIZED
]]

-- ============================================================================
-- SAFE LOAD WRAPPER (iterative retry - no stack growth)
-- ============================================================================
local function safeLoad()
    local attempt = 0
    while true do
        attempt = attempt + 1
        local success, err = pcall(function()
            print("[Afg Joiner] Initializing (attempt " .. attempt .. ")...")

            local Players          = game:GetService("Players")
            local HttpService      = game:GetService("HttpService")
            local TeleportService  = game:GetService("TeleportService")
            local CoreGui          = game:GetService("CoreGui")
            local UserInputService = game:GetService("UserInputService")
            local RunService       = game:GetService("RunService")
            local PlayerGui        = Players.LocalPlayer:WaitForChild("PlayerGui")

            local Player = Players.LocalPlayer

            -- ===================== CONFIGURATION =====================
            local FIREBASE_URL  = "https://nigger-default-rtdb.firebaseio.com/.json"
            local POLL_INTERVAL = 1.5
            local MIN_VAL       = 10000000

            local AJ_DELAY      = 5
            local JOIN_COOLDOWN = 1.5
            local MAX_ROWS      = 100
            local PROCESSED_TTL = 600

            local isProcessing  = false
            local joinQueue     = {}

            local processedIds = {}

            -- ============================================================================
            -- MOBILE / PC DETECTION & SCALING
            -- ============================================================================
            local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
            local SCALE    = isMobile and 0.65 or 1.0
            local GUI_WIDTH  = isMobile and 320 or 450
            local GUI_HEIGHT = isMobile and 380 or 420
            local FONT_SIZE_MULTIPLIER = isMobile and 0.8 or 1.0
            local ROW_HEIGHT       = isMobile and 40 or 48
            local HEADER_HEIGHT    = isMobile and 85 or 105
            local CONTROLS_HEIGHT  = isMobile and 28 or 32
            local DISCORD_HEIGHT   = isMobile and 28 or 32
            local TOGGLE_SIZE      = isMobile and 40 or 45

            -- ============================================================================
            -- UI THEME
            -- ============================================================================
            -- Upload your supplied Afghan smoke/emblem image to Roblox and put its asset ID here.
            -- Example: "rbxassetid://1234567890". Leave as rbxassetid://0 until you have the ID.
            local AFG_BACKGROUND_IMAGE = "rbxassetid://74992268612037"

            local THEME = {
                Background    = Color3.fromRGB(7, 8, 10),
                SidebarBG     = Color3.fromRGB(13, 15, 18),
                ItemBG        = Color3.fromRGB(18, 20, 23),
                Stroke        = Color3.fromRGB(184, 145, 72),
                Accent        = Color3.fromRGB(224, 48, 48),
                DiscordAccent = Color3.fromRGB(224, 48, 48),
                TextWhite     = Color3.fromRGB(250, 247, 239),
                TextGray      = Color3.fromRGB(190, 185, 175),
                GreenActive   = Color3.fromRGB(40, 190, 100),
                RedSoft       = Color3.fromRGB(255, 105, 105),
                Gold          = Color3.fromRGB(218, 177, 94),
            }

            local State = {
                AutoJoin     = false,
                MinGenFilter = MIN_VAL,
                BlackList    = {},
                ActiveTab    = "MONITOR",
            }

            -- ============================================================================
            -- HTTP REQUEST
            -- ============================================================================
            local function httpRequest(url)
                local reqFunc = (syn and syn.request) or http_request or request
                local body

                if reqFunc then
                    local ok, res = pcall(function()
                        return reqFunc({ Url = url, Method = "GET" })
                    end)
                    if ok and res and res.Body then
                        body = res.Body
                    end
                end

                if not body then
                    local ok, res = pcall(function()
                        return game:HttpGet(url, true)
                    end)
                    if ok and res then
                        body = res
                    end
                end

                return body
            end

            -- ============================================================================
            -- UTILITIES
            -- ============================================================================
            local function formatNumber(n)
                n = tonumber(n) or 0
                if n >= 1e12 then return string.format("%.2fT", n / 1e12)
                elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
                elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
                elseif n >= 1e3 then return string.format("%.2fK", n / 1e3) end
                return tostring(math.floor(n))
            end

            local function parseMoneyValue(value)
                if value == nil then return nil end
                if type(value) == "number" then return value end

                local s = tostring(value):gsub("[%s$,]", "")
                local numStr = s:match("[%d%.]+")
                if not numStr then return nil end

                local num = tonumber(numStr)
                if not num then return nil end

                local u = s:upper()
                if u:find("T") then return num * 1e12
                elseif u:find("B") then return num * 1e9
                elseif u:find("M") then return num * 1e6
                elseif u:find("K") then return num * 1e3 end
                return num
            end

            local function getField(tbl, keys)
                if type(tbl) ~= "table" then return nil end
                for _, k in ipairs(keys) do
                    local v = tbl[k]
                    if v ~= nil and v ~= "" then return v end
                end
                return nil
            end

            local function extractJobId(s)
                if type(s) ~= "string" then return nil end
                local id = s:match("[Gg]ameInstanceId=([%w%-]+)")
                        or s:match("[Jj]ob[Ii][Dd]=([%w%-]+)")
                if id and #id >= 32 then return id end
                return s:match("(%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x)")
            end

            -- ============================================================================
            -- FIREBASE DATA NORMALIZATION
            -- ============================================================================
            local function normalizeEntry(fbKey, rawData)
                if type(rawData) ~= "table" then return nil end

                local name = getField(rawData, {
                    "name","Name","nome","Nome","player","Player",
                    "username","Username","user","User","displayName","DisplayName",
                    "petName","PetName","display","Display","title","Title",
                    "nick","Nick","pet","Pet","Item","item"
                }) or "Unknown"

                local moneyRaw = getField(rawData, {
                    "money","Money","value","Value","gen","Gen",
                    "generations","Generations","amount","Amount",
                    "cash","Cash","total","Total","price","Price"
                })

                local jobId = getField(rawData, {
                    "jobId","JobId","jobID","JobID","serverId","serverID",
                    "job_id","id","Id","ID","server","Server",
                    "joinId","JoinId","job","Job","server_id"
                })

                local placeId = tonumber(getField(rawData, {
                    "placeId","PlaceId","placeID","PlaceID",
                    "place_id","gameId","GameId","game_id"
                })) or game.PlaceId

                if not jobId then
                    local linkBlob = rawData.join_game
                                  or rawData.join_script
                                  or rawData.link
                                  or rawData.url
                    jobId = extractJobId(linkBlob)
                end

                if type(jobId) ~= "string" or #jobId < 32 then
                    return nil
                end

                local numVal = parseMoneyValue(moneyRaw) or 0
                local uniqueId = tostring(fbKey) .. "_" .. tostring(jobId)

                return {
                    fbKey    = tostring(fbKey),
                    uniqueId = uniqueId,
                    nome     = tostring(name),
                    money    = (type(moneyRaw) == "string" and moneyRaw ~= "")
                               and moneyRaw or ("$" .. formatNumber(numVal)),
                    valor    = numVal,
                    jobId    = tostring(jobId),
                    placeId  = placeId,
                }
            end

            local function collectAll(snapshot)
                local out = {}
                if type(snapshot) ~= "table" then return out end

                for fbKey, rawData in pairs(snapshot) do
                    if type(rawData) == "table" then
                        local item = normalizeEntry(fbKey, rawData)
                        if item then
                            out[item.uniqueId] = item
                        else
                            for subKey, subData in pairs(rawData) do
                                if type(subData) == "table" then
                                    local subItem = normalizeEntry(subKey, subData)
                                    if subItem then
                                        out[subItem.uniqueId] = subItem
                                    end
                                end
                            end
                        end
                    end
                end
                return out
            end

            -- ============================================================================
            -- BLACKLIST HELPERS (exact-token match)
            -- ============================================================================
            local function isBlacklisted(name)
                if not name then return false end
                local lower = tostring(name):lower():match("^%s*(.-)%s*$")
                return State.BlackList[lower] ~= nil
            end

            local function addToBlacklist(name)
                local trimmed = name:match("^%s*(.-)%s*$")
                if trimmed == "" then return false, "Empty name" end
                local key = trimmed:lower()
                if State.BlackList[key] then return false, "Already in blacklist" end
                State.BlackList[key] = trimmed
                return true, trimmed
            end

            local function removeFromBlacklist(key)
                State.BlackList[key] = nil
            end

            -- ============================================================================
            -- UI CONSTRUCTION
            -- ============================================================================
            pcall(function()
                for _, c in pairs(CoreGui:GetChildren()) do
                    if c.Name == "AfgJoinerUI" then c:Destroy() end
                end
            end)

            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "AfgJoinerUI"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            local ok = pcall(function() ScreenGui.Parent = CoreGui end)
            if not ok then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

            local OPEN_POS = UDim2.new(0.5, -(GUI_WIDTH/2), 0.5, -(GUI_HEIGHT/2))

            local MainFrame = Instance.new("Frame")
            MainFrame.Name = "MainFrame"
            MainFrame.Parent = ScreenGui
            MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
            MainFrame.Position = OPEN_POS
            MainFrame.BackgroundColor3 = THEME.Background
            MainFrame.BackgroundTransparency = 1 -- let the Afghan artwork show through
            MainFrame.ClipsDescendants = true
            MainFrame.BorderSizePixel = 0
            Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

            -- Full-window Afghan smoke artwork: this is the MAIN GUI background, not a small decoration.
            local BackgroundArt = Instance.new("ImageLabel")
            BackgroundArt.Name = "AFGMainBackground"
            BackgroundArt.Parent = MainFrame
            BackgroundArt.BackgroundTransparency = 1
            BackgroundArt.BorderSizePixel = 0
            BackgroundArt.Size = UDim2.new(1, 0, 1, 0)
            BackgroundArt.Position = UDim2.new(0, 0, 0, 0)
            BackgroundArt.Image = AFG_BACKGROUND_IMAGE
            BackgroundArt.ScaleType = Enum.ScaleType.Crop
            BackgroundArt.ImageTransparency = 0
            BackgroundArt.ZIndex = 1
            Instance.new("UICorner", BackgroundArt).CornerRadius = UDim.new(0, 14)
            BackgroundArt.Image = AFG_BACKGROUND_IMAGE
            BackgroundArt.Visible = true
            BackgroundArt.Active = false
            -- Ask Roblox to load the uploaded asset before building the rest of the interface.
            task.spawn(function()
                local ContentProvider = game:GetService("ContentProvider")
                pcall(function() ContentProvider:PreloadAsync({BackgroundArt}) end)
                if not BackgroundArt.IsLoaded then
                    warn("[AFG] Background image has not loaded. Check asset permissions / moderation.")
                end
            end)

            -- Darken the artwork slightly so the controls remain readable.
            local BackgroundShade = Instance.new("Frame")
            BackgroundShade.Name = "BackgroundShade"
            BackgroundShade.Parent = MainFrame
            BackgroundShade.Size = UDim2.new(1, 0, 1, 0)
            BackgroundShade.BackgroundColor3 = Color3.fromRGB(3, 4, 5)
            BackgroundShade.BackgroundTransparency = 0.88
            BackgroundShade.BorderSizePixel = 0
            BackgroundShade.ZIndex = 2
            Instance.new("UICorner", BackgroundShade).CornerRadius = UDim.new(0, 14)

            local MainStroke = Instance.new("UIStroke", MainFrame)
            MainStroke.Color = THEME.Gold
            MainStroke.Thickness = 1.6
            MainStroke.Transparency = 0.12

            -- ============================================================================
            -- HEADER
            -- ============================================================================
            local Header = Instance.new("Frame")
            Header.Name = "Header"
            Header.Parent = MainFrame
            Header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
            Header.BackgroundTransparency = 1

            local DragHandle = Instance.new("Frame")
            DragHandle.Name = "DragHandle"
            DragHandle.Parent = Header
            DragHandle.Size = UDim2.new(1, 0, 0, 34)
            DragHandle.BackgroundTransparency = 1
            DragHandle.Active = true

            local HeaderAccent = Instance.new("Frame")
            HeaderAccent.Name = "HeaderAccent"
            HeaderAccent.Parent = Header
            HeaderAccent.Position = UDim2.new(0, 14, 0, 32)
            HeaderAccent.Size = UDim2.new(1, -28, 0, 2)
            HeaderAccent.BackgroundColor3 = THEME.Gold
            HeaderAccent.BorderSizePixel = 0
            HeaderAccent.ZIndex = 2

            local HeaderAccentGradient = Instance.new("UIGradient")
            HeaderAccentGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, THEME.Accent),
                ColorSequenceKeypoint.new(0.5, THEME.Gold),
                ColorSequenceKeypoint.new(1, THEME.GreenActive),
            })
            HeaderAccentGradient.Parent = HeaderAccent

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Parent = Header
            TitleLabel.Text = "Afg Joiner"
            TitleLabel.Font = Enum.Font.GothamBlack
            TitleLabel.TextSize = 14 * FONT_SIZE_MULTIPLIER
            TitleLabel.TextColor3 = THEME.TextWhite
            TitleLabel.Size = UDim2.new(1, -40, 0, 25)
            TitleLabel.Position = UDim2.new(0, 20, 0, 10)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd

            local TabBar = Instance.new("Frame")
            TabBar.Name = "TabBar"
            TabBar.Parent = Header
            TabBar.Size = UDim2.new(0, 200, 0, 26 * FONT_SIZE_MULTIPLIER)
            TabBar.Position = UDim2.new(0, 20, 0, 38)
            TabBar.BackgroundTransparency = 1

            local TabMonitor = Instance.new("TextButton")
            TabMonitor.Name = "TabMonitor"
            TabMonitor.Parent = TabBar
            TabMonitor.Text = "MONITOR"
            TabMonitor.Size = UDim2.new(0, 95, 1, 0)
            TabMonitor.BackgroundColor3 = THEME.Accent
            TabMonitor.TextColor3 = THEME.Background
            TabMonitor.Font = Enum.Font.GothamBold
            TabMonitor.TextSize = 10 * FONT_SIZE_MULTIPLIER
            Instance.new("UICorner", TabMonitor).CornerRadius = UDim.new(0, 6)

            local TabConfig = Instance.new("TextButton")
            TabConfig.Name = "TabConfig"
            TabConfig.Parent = TabBar
            TabConfig.Text = "CONFIG"
            TabConfig.Size = UDim2.new(0, 95, 1, 0)
            TabConfig.Position = UDim2.new(0, 100, 0, 0)
            TabConfig.BackgroundColor3 = THEME.ItemBG
            TabConfig.TextColor3 = THEME.TextGray
            TabConfig.Font = Enum.Font.GothamBold
            TabConfig.TextSize = 10 * FONT_SIZE_MULTIPLIER
            Instance.new("UICorner", TabConfig).CornerRadius = UDim.new(0, 6)

            local StatusLabel = Instance.new("TextLabel")
            StatusLabel.Name = "StatusLabel"
            StatusLabel.Parent = Header
            StatusLabel.Size = UDim2.new(1, -40, 0, 20)
            StatusLabel.Position = UDim2.new(0, 20, 0, HEADER_HEIGHT - 23)
            StatusLabel.BackgroundTransparency = 1
            StatusLabel.Text = "Connecting..."
            StatusLabel.TextColor3 = THEME.Accent
            StatusLabel.TextSize = 11 * FONT_SIZE_MULTIPLIER
            StatusLabel.Font = Enum.Font.Gotham
            StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
            StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd

            -- ============================================================================
            -- MONITOR PANEL
            -- ============================================================================
            local MonitorPanel = Instance.new("Frame")
            MonitorPanel.Name = "MonitorPanel"
            MonitorPanel.Parent = MainFrame
            MonitorPanel.Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + 2))
            MonitorPanel.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
            MonitorPanel.BackgroundTransparency = 1
            MonitorPanel.Visible = true

            local Controls = Instance.new("Frame")
            Controls.Name = "Controls"
            Controls.Parent = MonitorPanel
            Controls.Size = UDim2.new(1, -40, 0, CONTROLS_HEIGHT)
            Controls.Position = UDim2.new(0, 20, 0, 0)
            Controls.BackgroundTransparency = 1

            local AJButton = Instance.new("TextButton")
            AJButton.Name = "AJButton"
            AJButton.Parent = Controls
            AJButton.Text = "AUTO JOIN: OFF"
            AJButton.Size = UDim2.new(0, 130 * SCALE, 1, 0)
            AJButton.BackgroundColor3 = THEME.ItemBG
            AJButton.TextColor3 = THEME.TextWhite
            AJButton.Font = Enum.Font.GothamBold
            AJButton.TextSize = 10 * FONT_SIZE_MULTIPLIER
            Instance.new("UICorner", AJButton).CornerRadius = UDim.new(0, 8)

            local ValueInput = Instance.new("TextBox")
            ValueInput.Name = "ValueInput"
            ValueInput.Parent = Controls
            ValueInput.Text = "10M"
            ValueInput.Size = UDim2.new(1, -(130 * SCALE + 10), 1, 0)
            ValueInput.Position = UDim2.new(0, 130 * SCALE + 10, 0, 0)
            ValueInput.BackgroundColor3 = THEME.ItemBG
            ValueInput.TextColor3 = THEME.TextWhite
            ValueInput.Font = Enum.Font.GothamBold
            ValueInput.TextSize = 11 * FONT_SIZE_MULTIPLIER
            ValueInput.ClearTextOnFocus = false
            Instance.new("UICorner", ValueInput).CornerRadius = UDim.new(0, 8)

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Name = "Scroll"
            Scroll.Parent = MonitorPanel
            Scroll.Size = UDim2.new(1, -40, 1, -(CONTROLS_HEIGHT + 10))
            Scroll.Position = UDim2.new(0, 20, 0, CONTROLS_HEIGHT + 10)
            Scroll.BackgroundTransparency = 1
            Scroll.ScrollBarThickness = 3
            Scroll.ScrollBarImageColor3 = THEME.Accent
            Scroll.ClipsDescendants = true

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = Scroll
            ListLayout.Padding = UDim.new(0, 4)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
            end)

            -- ============================================================================
            -- CONFIG PANEL
            -- ============================================================================
            local ConfigPanel = Instance.new("Frame")
            ConfigPanel.Name = "ConfigPanel"
            ConfigPanel.Parent = MainFrame
            ConfigPanel.Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + 2))
            ConfigPanel.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
            ConfigPanel.BackgroundTransparency = 1
            ConfigPanel.Visible = false

            local MinSection = Instance.new("Frame")
            MinSection.Name = "MinSection"
            MinSection.Parent = ConfigPanel
            MinSection.Size = UDim2.new(1, -40, 0, 62 * SCALE)
            MinSection.Position = UDim2.new(0, 20, 0, 4)
            MinSection.BackgroundColor3 = THEME.ItemBG
            Instance.new("UICorner", MinSection).CornerRadius = UDim.new(0, 8)

            local MinTitle = Instance.new("TextLabel")
            MinTitle.Parent = MinSection
            MinTitle.Text = "⚙ Minimum (10M+)"
            MinTitle.Size = UDim2.new(1, -12, 0, 22 * FONT_SIZE_MULTIPLIER)
            MinTitle.Position = UDim2.new(0, 12, 0, 6)
            MinTitle.Font = Enum.Font.GothamBold
            MinTitle.TextSize = 11 * FONT_SIZE_MULTIPLIER
            MinTitle.TextColor3 = THEME.TextWhite
            MinTitle.BackgroundTransparency = 1
            MinTitle.TextXAlignment = Enum.TextXAlignment.Left

            local MinInputConfig = Instance.new("TextBox")
            MinInputConfig.Name = "MinInputConfig"
            MinInputConfig.Parent = MinSection
            MinInputConfig.Text = "10M"
            MinInputConfig.Size = UDim2.new(0, 100 * SCALE, 0, 22 * FONT_SIZE_MULTIPLIER)
            MinInputConfig.Position = UDim2.new(1, -(100 * SCALE + 12), 0, 20)
            MinInputConfig.BackgroundColor3 = THEME.Background
            MinInputConfig.TextColor3 = THEME.Accent
            MinInputConfig.Font = Enum.Font.GothamBold
            MinInputConfig.TextSize = 11 * FONT_SIZE_MULTIPLIER
            MinInputConfig.ClearTextOnFocus = false
            Instance.new("UICorner", MinInputConfig).CornerRadius = UDim.new(0, 6)

            local BLSection = Instance.new("Frame")
            BLSection.Name = "BLSection"
            BLSection.Parent = ConfigPanel
            BLSection.Size = UDim2.new(1, -40, 1, -(62 * SCALE + 12))
            BLSection.Position = UDim2.new(0, 20, 0, 62 * SCALE + 8)
            BLSection.BackgroundColor3 = THEME.ItemBG
            Instance.new("UICorner", BLSection).CornerRadius = UDim.new(0, 8)

            local BLTitle = Instance.new("TextLabel")
            BLTitle.Parent = BLSection
            BLTitle.Text = "🚫 Blacklist"
            BLTitle.Size = UDim2.new(1, -12, 0, 22 * FONT_SIZE_MULTIPLIER)
            BLTitle.Position = UDim2.new(0, 12, 0, 6)
            BLTitle.Font = Enum.Font.GothamBold
            BLTitle.TextSize = 11 * FONT_SIZE_MULTIPLIER
            BLTitle.TextColor3 = THEME.TextWhite
            BLTitle.BackgroundTransparency = 1
            BLTitle.TextXAlignment = Enum.TextXAlignment.Left

            local BLInputRow = Instance.new("Frame")
            BLInputRow.Name = "BLInputRow"
            BLInputRow.Parent = BLSection
            BLInputRow.Size = UDim2.new(1, -20, 0, 30 * SCALE)
            BLInputRow.Position = UDim2.new(0, 10, 0, 30 * SCALE)
            BLInputRow.BackgroundTransparency = 1

            local BLInput = Instance.new("TextBox")
            BLInput.Name = "BLInput"
            BLInput.Parent = BLInputRow
            BLInput.PlaceholderText = "Pet name"
            BLInput.Text = ""
            BLInput.Size = UDim2.new(1, -(34 * SCALE + 8), 1, 0)
            BLInput.BackgroundColor3 = THEME.Background
            BLInput.TextColor3 = THEME.TextWhite
            BLInput.PlaceholderColor3 = THEME.TextGray
            BLInput.Font = Enum.Font.Gotham
            BLInput.TextSize = 10 * FONT_SIZE_MULTIPLIER
            BLInput.ClearTextOnFocus = false
            Instance.new("UICorner", BLInput).CornerRadius = UDim.new(0, 6)

            local BLAddBtn = Instance.new("TextButton")
            BLAddBtn.Name = "BLAddBtn"
            BLAddBtn.Parent = BLInputRow
            BLAddBtn.Text = "+"
            BLAddBtn.Size = UDim2.new(0, 34 * SCALE, 1, 0)
            BLAddBtn.Position = UDim2.new(1, -(34 * SCALE), 0, 0)
            BLAddBtn.BackgroundColor3 = THEME.Accent
            BLAddBtn.TextColor3 = THEME.Background
            BLAddBtn.Font = Enum.Font.GothamBlack
            BLAddBtn.TextSize = 18 * FONT_SIZE_MULTIPLIER
            Instance.new("UICorner", BLAddBtn).CornerRadius = UDim.new(0, 6)

            local BLFeedback = Instance.new("TextLabel")
            BLFeedback.Name = "BLFeedback"
            BLFeedback.Parent = BLSection
            BLFeedback.Text = ""
            BLFeedback.Size = UDim2.new(1, -20, 0, 14 * FONT_SIZE_MULTIPLIER)
            BLFeedback.Position = UDim2.new(0, 10, 0, 64 * SCALE)
            BLFeedback.Font = Enum.Font.Gotham
            BLFeedback.TextSize = 9 * FONT_SIZE_MULTIPLIER
            BLFeedback.TextColor3 = THEME.GreenActive
            BLFeedback.BackgroundTransparency = 1
            BLFeedback.TextXAlignment = Enum.TextXAlignment.Left

            local BLScroll = Instance.new("ScrollingFrame")
            BLScroll.Name = "BLScroll"
            BLScroll.Parent = BLSection
            BLScroll.Size = UDim2.new(1, -20, 1, -(80 * SCALE + 20))
            BLScroll.Position = UDim2.new(0, 10, 0, 80 * SCALE + 16)
            BLScroll.BackgroundTransparency = 1
            BLScroll.ScrollBarThickness = 3
            BLScroll.ScrollBarImageColor3 = THEME.Accent
            BLScroll.ClipsDescendants = true

            local BLListLayout = Instance.new("UIListLayout")
            BLListLayout.Parent = BLScroll
            BLListLayout.Padding = UDim.new(0, 4)
            BLListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            BLListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                BLScroll.CanvasSize = UDim2.new(0, 0, 0, BLListLayout.AbsoluteContentSize.Y + 6)
            end)

            -- ============================================================================
            -- BLACKLIST UI FUNCTIONS
            -- ============================================================================
            local function refreshBLFeedback(msg, color)
                BLFeedback.Text = msg
                BLFeedback.TextColor3 = color or THEME.GreenActive
                task.delay(2, function()
                    pcall(function()
                        if BLFeedback.Text == msg then
                            BLFeedback.Text = ""
                        end
                    end)
                end)
            end

            local rowOrder = 0
            local function nextOrder()
                rowOrder = rowOrder + 1
                return rowOrder
            end

            local function createBLRow(displayName, key)
                local Row = Instance.new("Frame")
                Row.Name = "BL_" .. key
                Row.Parent = BLScroll
                Row.LayoutOrder = nextOrder()
                Row.Size = UDim2.new(1, 0, 0, 28 * SCALE)
                Row.BackgroundColor3 = THEME.Background
                Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

                local NameL = Instance.new("TextLabel")
                NameL.Parent = Row
                NameL.Text = "🚫 " .. displayName
                NameL.Size = UDim2.new(1, -(32 * SCALE + 4), 1, 0)
                NameL.Position = UDim2.new(0, 8, 0, 0)
                NameL.Font = Enum.Font.Gotham
                NameL.TextSize = 10 * FONT_SIZE_MULTIPLIER
                NameL.TextColor3 = THEME.TextWhite
                NameL.BackgroundTransparency = 1
                NameL.TextXAlignment = Enum.TextXAlignment.Left
                NameL.TextTruncate = Enum.TextTruncate.AtEnd

                local DelBtn = Instance.new("TextButton")
                DelBtn.Parent = Row
                DelBtn.Text = "✕"
                DelBtn.Size = UDim2.new(0, 28 * SCALE, 0, 20 * SCALE)
                DelBtn.Position = UDim2.new(1, -(28 * SCALE + 4), 0.5, -(10 * SCALE))
                DelBtn.BackgroundColor3 = THEME.RedSoft
                DelBtn.TextColor3 = THEME.TextWhite
                DelBtn.Font = Enum.Font.GothamBold
                DelBtn.TextSize = 10 * FONT_SIZE_MULTIPLIER
                Instance.new("UICorner", DelBtn).CornerRadius = UDim.new(0, 4)
                DelBtn.MouseButton1Click:Connect(function()
                    removeFromBlacklist(key)
                    Row:Destroy()
                    refreshBLFeedback("Removed: " .. displayName, THEME.RedSoft)
                end)
            end

            local function tryAddFromBLInput()
                local text = BLInput.Text
                local added, result = addToBlacklist(text)
                if added then
                    createBLRow(result, result:lower())
                    BLInput.Text = ""
                    refreshBLFeedback("Added: " .. result, THEME.GreenActive)
                else
                    refreshBLFeedback("⚠ " .. result, THEME.RedSoft)
                end
            end

            BLAddBtn.MouseButton1Click:Connect(tryAddFromBLInput)
            BLInput.FocusLost:Connect(function(enterPressed)
                if enterPressed then tryAddFromBLInput() end
            end)

            -- ============================================================================
            -- DISCORD BUTTON
            -- ============================================================================
            local DiscordButton = Instance.new("Frame")
            DiscordButton.Name = "DiscordButton"
            DiscordButton.Parent = ScreenGui
            DiscordButton.Size = UDim2.new(0, GUI_WIDTH, 0, DISCORD_HEIGHT)
            DiscordButton.Position = UDim2.new(OPEN_POS.X.Scale, OPEN_POS.X.Offset,
                                                OPEN_POS.Y.Scale, OPEN_POS.Y.Offset + GUI_HEIGHT)
            DiscordButton.BackgroundColor3 = THEME.SidebarBG
            Instance.new("UICorner", DiscordButton).CornerRadius = UDim.new(0, 8)

            local DiscordLabel = Instance.new("TextLabel")
            DiscordLabel.Parent = DiscordButton
            DiscordLabel.Size = UDim2.new(1, 0, 1, 0)
            DiscordLabel.BackgroundTransparency = 1
            DiscordLabel.Text = "Discord: discord.gg/zeUKa7ksD9"
            DiscordLabel.TextColor3 = THEME.DiscordAccent
            DiscordLabel.TextSize = 11 * FONT_SIZE_MULTIPLIER
            DiscordLabel.Font = Enum.Font.GothamBold

            local DiscordClick = Instance.new("TextButton")
            DiscordClick.Parent = DiscordButton
            DiscordClick.Size = UDim2.new(1, 0, 1, 0)
            DiscordClick.BackgroundTransparency = 1
            DiscordClick.Text = ""
            DiscordClick.MouseButton1Click:Connect(function()
                pcall(function() setclipboard("discord.gg/zeUKa7ksD9") end)
            end)

            -- ============================================================================
            -- TOGGLE BUTTON
            -- ============================================================================
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = ScreenGui
            ToggleFrame.Size = UDim2.new(0, TOGGLE_SIZE, 0, TOGGLE_SIZE)
            ToggleFrame.Position = UDim2.new(0, 10, 0.5, -(TOGGLE_SIZE/2))
            ToggleFrame.BackgroundColor3 = THEME.Background
            ToggleFrame.BorderSizePixel = 0
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 12)
            local ToggleStroke = Instance.new("UIStroke", ToggleFrame)
            ToggleStroke.Color = THEME.Gold
            ToggleStroke.Thickness = 1.5
            ToggleStroke.Transparency = 0.08

            local ToggleGradient = Instance.new("UIGradient", ToggleFrame)
            ToggleGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 10, 12)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 10, 12)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 22, 13)),
            })
            ToggleGradient.Rotation = 25

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Parent = ToggleFrame
            ToggleBtn.Text = "AFG"
            ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.TextColor3 = THEME.Gold
            ToggleBtn.Font = Enum.Font.GothamBlack
            ToggleBtn.TextSize = 14 * FONT_SIZE_MULTIPLIER
            ToggleBtn.ZIndex = 1
            ToggleBtn.MouseButton1Click:Connect(function()
                local vis = not MainFrame.Visible
                MainFrame.Visible = vis
                DiscordButton.Visible = vis
            end)

            -- ============================================================================
            -- TAB LOGIC
            -- ============================================================================
            local function switchTab(tab)
                State.ActiveTab = tab
                if tab == "MONITOR" then
                    MonitorPanel.Visible = true
                    ConfigPanel.Visible  = false
                    TabMonitor.BackgroundColor3 = THEME.Accent
                    TabMonitor.TextColor3       = THEME.Background
                    TabConfig.BackgroundColor3  = THEME.ItemBG
                    TabConfig.TextColor3        = THEME.TextGray
                else
                    MonitorPanel.Visible = false
                    ConfigPanel.Visible  = true
                    TabConfig.BackgroundColor3  = THEME.Accent
                    TabConfig.TextColor3        = THEME.Background
                    TabMonitor.BackgroundColor3 = THEME.ItemBG
                    TabMonitor.TextColor3       = THEME.TextGray
                end
            end

            TabMonitor.MouseButton1Click:Connect(function() switchTab("MONITOR") end)
            TabConfig.MouseButton1Click:Connect(function() switchTab("CONFIG") end)

            -- ============================================================================
            -- STATUS
            -- ============================================================================
            local function setStatus(txt, color)
                pcall(function()
                    StatusLabel.Text = txt
                    StatusLabel.TextColor3 = color or THEME.TextGray
                end)
            end

            -- ============================================================================
            -- MIN FILTER SYNC
            -- ============================================================================
            local function applyMinFilterFrom(textBox, mirrorBox)
                local v = parseMoneyValue(textBox.Text)
                if v and v >= 0 then
                    State.MinGenFilter = v
                    local formatted = (v == 0) and "0" or formatNumber(v)
                    textBox.Text = formatted
                    if mirrorBox then mirrorBox.Text = formatted end
                    setStatus("Filter: " .. formatted, THEME.Accent)
                else
                    textBox.Text = formatNumber(State.MinGenFilter)
                    setStatus("Invalid filter input", THEME.RedSoft)
                end
            end

            MinInputConfig.FocusLost:Connect(function()
                applyMinFilterFrom(MinInputConfig, ValueInput)
            end)

            ValueInput.FocusLost:Connect(function()
                applyMinFilterFrom(ValueInput, MinInputConfig)
            end)

            State.MinGenFilter = parseMoneyValue(ValueInput.Text) or MIN_VAL

            -- ============================================================================
            -- AUTO-JOIN BUTTON
            -- ============================================================================
            AJButton.MouseButton1Click:Connect(function()
                State.AutoJoin = not State.AutoJoin
                AJButton.Text = "AUTO JOIN: " .. (State.AutoJoin and "ON" or "OFF")
                AJButton.BackgroundColor3 = State.AutoJoin and THEME.Accent or THEME.ItemBG
                AJButton.TextColor3 = State.AutoJoin and THEME.Background or THEME.TextWhite
            end)

            --============================================================================
            -- MONITOR ROW FACTORY (continued)
            -- ============================================================================
            local function capRows()
                local frames = {}
                for _, c in ipairs(Scroll:GetChildren()) do
                    if c:IsA("Frame") then
                        frames[#frames + 1] = c
                    end
                end
                -- UIListLayout sorts by LayoutOrder, so first inserted = oldest
                table.sort(frames, function(a, b)
                    return a.LayoutOrder < b.LayoutOrder
                end)
                while #frames > MAX_ROWS do
                    frames[1]:Destroy()
                    table.remove(frames, 1)
                end
            end

            local function createRow(data)
                local Row = Instance.new("Frame")
                Row.Name = "Row_" .. data.uniqueId
                Row.Parent = Scroll
                Row.LayoutOrder = nextOrder()
                Row.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
                Row.BackgroundColor3 = THEME.ItemBG
                Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
                local rs = Instance.new("UIStroke", Row)
                rs.Color = THEME.Stroke
                rs.Thickness = 1

                local NameL = Instance.new("TextLabel")
                NameL.Parent = Row
                NameL.Text = data.nome
                NameL.Size = UDim2.new(0.5, -20, 1, 0)
                NameL.Position = UDim2.new(0, 12, 0, 0)
                NameL.Font = Enum.Font.GothamBold
                NameL.TextSize = 12 * FONT_SIZE_MULTIPLIER
                NameL.TextColor3 = THEME.TextWhite
                NameL.BackgroundTransparency = 1
                NameL.TextXAlignment = Enum.TextXAlignment.Left
                NameL.TextYAlignment = Enum.TextYAlignment.Center
                NameL.TextTruncate = Enum.TextTruncate.AtEnd

                local ValueL = Instance.new("TextLabel")
                ValueL.Parent = Row
                ValueL.Text = data.money
                ValueL.Size = UDim2.new(0.3, -10, 1, 0)
                ValueL.Position = UDim2.new(0.5, 0, 0, 0)
                ValueL.Font = Enum.Font.GothamBold
                ValueL.TextColor3 = THEME.Accent
                ValueL.TextSize = 13 * FONT_SIZE_MULTIPLIER
                ValueL.BackgroundTransparency = 1
                ValueL.TextXAlignment = Enum.TextXAlignment.Center
                ValueL.TextYAlignment = Enum.TextYAlignment.Center
                ValueL.TextTruncate = Enum.TextTruncate.AtEnd

                local Join = Instance.new("TextButton")
                Join.Parent = Row
                Join.Text = "JOIN"
                Join.Size = UDim2.new(0, 65 * SCALE, 0, 32 * SCALE)
                Join.Position = UDim2.new(1, -(65 * SCALE + 10), 0.5, -(16 * SCALE))
                Join.BackgroundColor3 = THEME.Accent
                Join.TextColor3 = THEME.TextWhite
                Join.Font = Enum.Font.GothamBold
                Join.TextSize = 11 * FONT_SIZE_MULTIPLIER
                Instance.new("UICorner", Join).CornerRadius = UDim.new(0, 6)

                Join.MouseButton1Click:Connect(function()
                    local now = tick()
                    if now < joinLockUntil then return end   -- debounce
                    joinLockUntil = now + JOIN_COOLDOWN

                    setStatus("Joining: " .. data.nome, THEME.Accent)
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(
                            data.placeId or game.PlaceId,
                            data.jobId,
                            Player
                        )
                    end)
                end)

                capRows()
            end

            -- ============================================================================
            -- FETCH FROM FIREBASE
            -- ============================================================================
            local function fetchFromFirebase()
                local cacheBuster = tostring(math.random(100000, 999999)) .. "_" .. tostring(tick())
                local url = FIREBASE_URL .. "?t=" .. cacheBuster
                local body = httpRequest(url)

                if not body or body == "" or body:lower() == "null" then
                    return nil
                end

                local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body)
                if ok and type(decoded) == "table" then
                    return decoded
                end
                return nil
            end

            -- ============================================================================
            -- AUTO-JOIN QUEUE (non-blocking)
            -- ============================================================================
            local function processQueue()
                if isProcessing then return end
                isProcessing = true

                task.spawn(function()
                    while #joinQueue > 0 and State.AutoJoin do
                        local item = table.remove(joinQueue, 1)
                        if item and item.jobId then
                            setStatus("⚡ Joining: " .. item.nome, THEME.Accent)

                            local ok = pcall(function()
                                TeleportService:TeleportToPlaceInstance(
                                    item.placeId or game.PlaceId,
                                    item.jobId,
                                    Player
                                )
                            end)

                            -- If teleport failed, drop and continue quickly.
                            -- If it succeeded the client usually leaves the game anyway.
                            task.wait(ok and AJ_DELAY or 1)
                        end
                    end
                    isProcessing = false
                end)
            end

            local function addToQueue(item)
                if not item or not item.jobId then return end
                table.insert(joinQueue, item)
                if State.AutoJoin then
                    processQueue()
                end
            end


            -- ============================================================================
            -- DEX LIVE FEED BRIDGE (uses the AFG GUI; no Dex GUI is created)
            -- Receives log events and feeds them into AFG's existing rows/filter/auto-join.
            -- This listener does not POST player data or send webhooks.
            -- ============================================================================
            local DEX_WS_URL = "wss://dexapi2.up.railway.app/ws"

            local function getDexWebSocket()
                return (syn and syn.websocket and syn.websocket.connect)
                    or (WebSocket and WebSocket.connect)
                    or (fluxus and fluxus.websocket and fluxus.websocket.connect)
                    or (krnl and krnl.websocket and krnl.websocket.connect)
            end

            local function parseDexValue(raw)
                if type(raw) == "number" then return raw end
                local s = tostring(raw or ""):upper():gsub("%$", ""):gsub("/S", ""):gsub(",", ""):gsub("%s+", "")
                local number, suffix = s:match("([%d%.]+)([KMBT]?)")
                number = tonumber(number)
                if not number then return 0 end
                local mult = ({K=1e3, M=1e6, B=1e9, T=1e12})[suffix or ""] or 1
                return number * mult
            end

            local function handleDexMessage(message)
                if type(message) ~= "string" then return end
                local fields = {}
                for value in message:gmatch("[^|]+") do
                    fields[#fields + 1] = value:gsub("^%s+", ""):gsub("%s+$", "")
                end
                local name = fields[1]
                local rawValue = fields[2]
                local players = tonumber(fields[3]) or 0
                local jobId = fields[4]
                if not name or name == "" or not rawValue or not jobId or #jobId < 20 then return end

                local amount = parseDexValue(rawValue)
                if amount < State.MinGenFilter or isBlacklisted(name) then return end

                local uniqueId = "DEX_" .. jobId .. "_" .. name
                if processedIds[uniqueId] then return end
                processedIds[uniqueId] = tick()

                local item = {
                    nome = name,
                    money = tostring(rawValue),
                    valor = amount,
                    jobId = jobId,
                    placeId = game.PlaceId,
                    source = "DEX"
                }
                pcall(function() createRow(item) end)
                setStatus("DEX LIVE: " .. name .. " (" .. tostring(rawValue) .. ")", THEME.GreenActive)
                if State.AutoJoin then addToQueue(item) end
            end

            task.spawn(function()
                local connector = getDexWebSocket()
                if not connector then
                    warn("[AFG] This executor has no WebSocket API; Dex live feed disabled.")
                    return
                end
                while true do
                    local socket
                    local connected = pcall(function()
                        socket = connector(DEX_WS_URL)
                    end)
                    if connected and socket then
                        setStatus("AFG + DEX LIVE CONNECTED", THEME.GreenActive)
                        local messageConnection
                        local closeConnection
                        local closed = false
                        pcall(function()
                            messageConnection = socket.OnMessage:Connect(handleDexMessage)
                        end)
                        pcall(function()
                            closeConnection = socket.OnClose:Connect(function()
                                closed = true
                            end)
                        end)
                        if not messageConnection then
                            closed = true
                        end
                        while not closed do
                            task.wait(1)
                            local readOk, isClosed = pcall(function() return socket.Closed end)
                            if readOk and isClosed == true then closed = true end
                        end
                        pcall(function() if messageConnection then messageConnection:Disconnect() end end)
                        pcall(function() if closeConnection then closeConnection:Disconnect() end end)
                        pcall(function() socket:Close() end)
                    else
                        setStatus("DEX LIVE RECONNECTING", THEME.RedSoft)
                    end
                    task.wait(5)
                end
            end)

            -- ============================================================================
            -- PROCESSED-ID PRUNING
            -- ============================================================================
            task.spawn(function()
                while true do
                    task.wait(60)
                    local now = tick()
                    for id, ts in pairs(processedIds) do
                        if now - ts > PROCESSED_TTL then
                            processedIds[id] = nil
                        end
                    end
                end
            end)

            -- ============================================================================
            -- MAIN POLLING LOOP
            -- ============================================================================
            task.spawn(function()
                local failCount = 0
                local connected = false
                local IsFirstFetch = true

                while true do
                    task.wait(POLL_INTERVAL)

                    local currentData = fetchFromFirebase()

                    if currentData then
                        if not connected then
                            connected = true
                            setStatus("Connected", THEME.GreenActive)
                        end

                        failCount = 0
                        local current = collectAll(currentData)
                        local newItems = {}

                        for uniqueId, item in pairs(current) do
                            if not processedIds[uniqueId] then
                                processedIds[uniqueId] = tick()

                                if not IsFirstFetch then
                                    if not isBlacklisted(item.nome)
                                       and item.valor >= State.MinGenFilter then
                                        table.insert(newItems, item)
                                    end
                                end
                            end
                        end

                        for _, item in ipairs(newItems) do
                            pcall(function()
                                createRow(item)
                            end)
                            task.defer(function()
                                pcall(function()
                                    Scroll.CanvasPosition =
                                        Vector2.new(0, Scroll.CanvasSize.Y.Offset)
                                end)
                            end)

                            setStatus("🚀 " .. item.nome .. " (" .. item.money .. ")",
                                      THEME.GreenActive)

                            if State.AutoJoin then
                                addToQueue(item)
                            end
                        end

                        IsFirstFetch = false

                        if not StatusLabel.Text:find("🚀")
                           and not StatusLabel.Text:find("⚡") then
                            setStatus("Monitoring... " .. os.date("%H:%M:%S"),
                                      THEME.TextGray)
                        end
                    else
                        failCount = failCount + 1
                        connected = false
                        setStatus("Reconnecting (" .. failCount .. ")", THEME.RedSoft)
                        if failCount >= 5 then
                            task.wait(2)
                        end
                    end
                end
            end)

            -- ============================================================================
            -- DRAGGABLE (leak-free)
            -- ============================================================================
            local function makeDraggable(obj, handle, others)
                local dragging, inputStart, startPos = false, nil, nil

                handle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        inputStart = input.Position
                        startPos = obj.Position
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        return
                    end
                    if not dragging then return end
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end

                    local delta = input.Position - inputStart
                    local newPos = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                    obj.Position = newPos
                    if others then
                        for _, o in ipairs(others) do
                            o.obj.Position = UDim2.new(
                                newPos.X.Scale, newPos.X.Offset + o.offX,
                                newPos.Y.Scale, newPos.Y.Offset + o.offY
                            )
                        end
                    end
                end)
            end

            -- Explicitly layer the completed interface above the artwork and shade.
            -- BackgroundArt = ZIndex 1, BackgroundShade = ZIndex 2, all controls = ZIndex 3+.
            for _, uiObject in ipairs(MainFrame:GetDescendants()) do
                if uiObject:IsA("GuiObject") and uiObject ~= BackgroundArt and uiObject ~= BackgroundShade then
                    uiObject.ZIndex = math.max(uiObject.ZIndex, 3)
                end
            end

            makeDraggable(MainFrame, DragHandle, {
                {obj = DiscordButton, offX = 0, offY = GUI_HEIGHT},
            })
            -- Toggle is tap-only. It must never follow ordinary screen taps or drag gestures.

            print("[Afg Joiner] Loaded! (NO LAG - OPTIMIZED)")
            print("[Afg Joiner] Mode: " .. (isMobile and "MOBILE" or "PC"))
            print("[Afg Joiner] Polling: " .. POLL_INTERVAL .. "s | Min: " .. formatNumber(MIN_VAL))
            print("[Afg Joiner] Auto-Join Delay: " .. AJ_DELAY .. "s")
        end)

        if success then
            break
        end

        warn("[Afg Joiner] Load failed (attempt " .. attempt .. "):", err)
        if attempt >= 5 then
            warn("[Afg Joiner] Giving up after 5 attempts.")
            break
        end
        task.wait(2)
    end
end

safeLoad()