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
    gui.Name = "AFG_Intro"; gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false; gui.DisplayOrder = 999999; gui.Parent = parent
    local root = Instance.new("Frame")
    root.Size = UDim2.fromScale(1, 1); root.BackgroundColor3 = Color3.fromRGB(3, 4, 6); root.BorderSizePixel = 0; root.Parent = gui
    local bg = Instance.new("UIGradient")
    bg.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(42, 5, 13)), ColorSequenceKeypoint.new(0.34, Color3.fromRGB(12, 8, 13)), ColorSequenceKeypoint.new(0.68, Color3.fromRGB(7, 15, 12)), ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 35, 20)) })
    bg.Rotation = 18; bg.Parent = root
    local function tween(obj, duration, props, style, direction)
        local t = TweenService:Create(obj, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
        t:Play(); return t
    end
    local logo = Instance.new("TextLabel"); logo.BackgroundTransparency = 1; logo.AnchorPoint = Vector2.new(0.5, 0.5); logo.Position = UDim2.fromScale(0.5, 0.45); logo.Size = UDim2.fromScale(0.52, 0.24); logo.Font = Enum.Font.GothamBlack; logo.Text = "AFG"; logo.TextScaled = true; logo.TextColor3 = Color3.fromRGB(250, 248, 242); logo.TextTransparency = 1; logo.Parent = root
    local logoStroke = Instance.new("UIStroke"); logoStroke.Color = Color3.fromRGB(12, 12, 12); logoStroke.Thickness = 2.5; logoStroke.Transparency = 0.12; logoStroke.Parent = logo
    tween(logo, 0.62, {TextTransparency = 0, Position = UDim2.fromScale(0.5, 0.455), Size = UDim2.fromScale(0.54, 0.25)}, Enum.EasingStyle.Back)
    task.wait(1.35)
    tween(logo, 0.22, {TextTransparency = 1, Size = UDim2.fromScale(0.42, 0.19)})
    task.wait(0.22)
    for _, obj in ipairs(root:GetDescendants()) do if obj:IsA("GuiObject") then local props = {}; if obj:IsA("TextLabel") or obj:IsA("TextButton") then props.TextTransparency = 1 end; if obj:IsA("Frame") then props.BackgroundTransparency = 1 end; if next(props) then tween(obj, 0.24, props) end end end
    tween(root, 0.28, {BackgroundTransparency = 1}); task.wait(0.34); gui:Destroy()
end
task.spawn(function() pcall(playAFGIntro) end)

local function safeLoad()
    local attempt = 0
    while true do
        attempt = attempt + 1
        local success, err = pcall(function()
            local Players = game:GetService("Players")
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local CoreGui = game:GetService("CoreGui")
            local UserInputService = game:GetService("UserInputService")
            local Player = Players.LocalPlayer
            local PlayerGui = Player:WaitForChild("PlayerGui")

            local FIREBASE_URL  = "https://lower-5cb21-default-rtdb.firebaseio.com/.json"
            local POLL_INTERVAL = 1.5
            local MIN_VAL       = 0
            local TELEPORT_TIMEOUT = 30
            local MAX_ROWS = 100
            local MAX_LOGS = 50

            local isRunning = true
            local isProcessing = false
            local joinQueue = {}
            local joinLockUntil = 0
            local isJoining = false
            local currentJoinJob = nil
            local joinAttemptId = 0
            local fullJobs = {}
            local processedIds = {}
            local foundItems = {}
            local rowFrames = {}
            local renderOrder = {}

            local connections = {}
            local safeTeleport
            local processQueue
            local renderRow
            local cleanup
            local setStatus
            local AddLog

            local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
            local SCALE = isMobile and 0.65 or 1.0
            local GUI_WIDTH = isMobile and 320 or 450
            local GUI_HEIGHT = isMobile and 380 or 420
            local FONT_SIZE_MULTIPLIER = isMobile and 0.8 or 1.0
            local ROW_HEIGHT = isMobile and 40 or 48
            local HEADER_HEIGHT = isMobile and 85 or 105
            local CONTROLS_HEIGHT = isMobile and 28 or 32
            local TOGGLE_SIZE = isMobile and 40 or 45
            local AFG_BACKGROUND_IMAGE = "rbxassetid://100165046666841"

            local THEME = {
                Background = Color3.fromRGB(7, 8, 10), ItemBG = Color3.fromRGB(18, 20, 23),
                Stroke = Color3.fromRGB(184, 145, 72), Accent = Color3.fromRGB(224, 48, 48), TextWhite = Color3.fromRGB(250, 247, 239),
                TextGray = Color3.fromRGB(190, 185, 175), GreenActive = Color3.fromRGB(40, 190, 100), RedSoft = Color3.fromRGB(255, 105, 105),
                Gold = Color3.fromRGB(218, 177, 94),
            }
            local State = { AutoJoin = false, MinGenFilter = MIN_VAL, BlackList = {} }

            local function httpRequest(url)
                local reqFunc = (syn and syn.request) or http_request or request
                local body
                if reqFunc then local ok, res = pcall(function() return reqFunc({ Url = url, Method = "GET" }) end); if ok and res and res.Body then body = res.Body end end
                if not body then local ok, res = pcall(function() return game:HttpGet(url, true) end); if ok and res then body = res end end
                return body
            end

            local function formatNumber(n)
                n = tonumber(n) or 0
                if n >= 1e12 then return string.format("%.2fT", n / 1e12) elseif n >= 1e9 then return string.format("%.2fB", n / 1e9) elseif n >= 1e6 then return string.format("%.2fM", n / 1e6) elseif n >= 1e3 then return string.format("%.2fK", n / 1e3) end
                return tostring(math.floor(n))
            end

            local function parseMoneyValue(value)
                if value == nil then return nil end
                if type(value) == "number" then return value end
                local s = tostring(value):upper():gsub("[%s$,]", "")
                local numStr = s:match("[%d%.]+")
                if not numStr then return nil end
                local num = tonumber(numStr)
                if not num then return nil end
                local u = s:upper()
                if u:find("T") then return num * 1e12 elseif u:find("B") then return num * 1e9 elseif u:find("M") then return num * 1e6 elseif u:find("K") then return num * 1e3 end
                return num
            end

            local function getField(tbl, keys)
                if type(tbl) ~= "table" then return nil end
                for _, k in ipairs(keys) do if tbl[k] ~= nil and tbl[k] ~= "" then return tbl[k] end end
                return nil
            end

            local function normalizeEntry(fbKey, rawData)
                if type(rawData) ~= "table" then return nil end
                local name = getField(rawData, { "Item", "item", "name", "Name", "petName", "PetName" })
                if name == nil then return nil end
                local numVal = parseMoneyValue(getField(rawData, { "ValueFormatted", "valueFormatted", "money", "Money" }))
                if not numVal or numVal <= 0 then numVal = parseMoneyValue(getField(rawData, { "Value", "value" })) or 0 end
                local jobId = getField(rawData, { "JobId", "jobId", "serverId", "id" })
                if type(jobId) ~= "string" then jobId = tostring(jobId or "") end
                if #jobId < 32 then return nil end
                local placeId = tonumber(getField(rawData, { "PlaceId", "placeId" })) or game.PlaceId
                return { fbKey = tostring(fbKey), uniqueId = tostring(fbKey) .. "_" .. jobId, nome = tostring(name), money = rawData.ValueFormatted or ("$" .. formatNumber(numVal) .. "/s"), valor = numVal, jobId = jobId, placeId = placeId }
            end

            local function collectAll(snapshot)
                local out, visited = {}, {}
                local function walk(node, path)
                    if type(node) ~= "table" or visited[node] then return end
                    visited[node] = true
                    local item = normalizeEntry(path, node)
                    if item then out[item.uniqueId] = item; return end
                    for key, child in pairs(node) do if type(child) == "table" then walk(child, tostring(path) .. "/" .. tostring(key)) end end
                end
                if type(snapshot) == "table" then for key, child in pairs(snapshot) do if type(child) == "table" then walk(child, tostring(key)) end end end
                return out
            end

            local function isBlacklisted(name)
                if not name then return false end
                return State.BlackList[tostring(name):lower()] ~= nil
            end;pcall(function()
                for _, c in pairs(CoreGui:GetChildren()) do
                    if c.Name == "AfgJoinerUI" then c:Destroy() end
                end
            end);

            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "AfgJoinerUI"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            local ok = pcall(function() ScreenGui.Parent = CoreGui end); if not ok then ScreenGui.Parent = PlayerGui end

            local OPEN_POS = UDim2.new(0.5, -(GUI_WIDTH/2), 0.5, -(GUI_HEIGHT/2))

            local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT); MainFrame.Position = OPEN_POS
            MainFrame.BackgroundColor3 = THEME.Background; MainFrame.BackgroundTransparency = 0.1; MainFrame.ClipsDescendants = true; MainFrame.BorderSizePixel = 0
            Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
            local Bg = Instance.new("ImageLabel", MainFrame); Bg.Size = UDim2.new(1,0,1,0); Bg.BackgroundTransparency = 1; Bg.Image = AFG_BACKGROUND_IMAGE; Bg.ScaleType = Enum.ScaleType.Crop; Bg.ZIndex = 1
            Instance.new("UICorner", Bg).CornerRadius = UDim.new(0, 14)
            local Shade = Instance.new("Frame", MainFrame); Shade.Size = UDim2.new(1,0,1,0); Shade.BackgroundColor3 = Color3.fromRGB(0,0,0); Shade.BackgroundTransparency = 0.5; Shade.ZIndex = 2
            Instance.new("UICorner", Shade).CornerRadius = UDim.new(0, 14)

            local Header = Instance.new("Frame", MainFrame); Header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT); Header.BackgroundTransparency = 1; Header.ZIndex = 3
            local DragHandle = Instance.new("Frame", Header); DragHandle.Size = UDim2.new(1, 0, 0, 34); DragHandle.BackgroundTransparency = 1; DragHandle.Active = true
            local TitleLabel = Instance.new("TextLabel", Header); TitleLabel.Text = "Afg Joiner"; TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.TextSize = 14 * FONT_SIZE_MULTIPLIER; TitleLabel.TextColor3 = THEME.TextWhite; TitleLabel.Size = UDim2.new(1, -160, 0, 25); TitleLabel.Position = UDim2.new(0, 20, 0, 10); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.ZIndex = 4

            local ToolBar = Instance.new("Frame", Header); ToolBar.Size = UDim2.new(0, 150, 0, 25); ToolBar.Position = UDim2.new(1, -155, 0, 8); ToolBar.BackgroundTransparency = 1; ToolBar.ZIndex = 5
            local ToolLayout = Instance.new("UIListLayout", ToolBar); ToolLayout.FillDirection = Enum.FillDirection.Horizontal; ToolLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right; ToolLayout.Padding = UDim.new(0, 5)

            local isLocked = false
            local BtnLock = Instance.new("TextButton", ToolBar); BtnLock.Size = UDim2.new(0, 30, 0, 25); BtnLock.BackgroundColor3 = THEME.ItemBG; BtnLock.Text = "🔓"; BtnLock.TextColor3 = THEME.TextWhite; BtnLock.TextSize = 12; BtnLock.ZIndex = 6
            Instance.new("UICorner", BtnLock).CornerRadius = UDim.new(0, 4)
            local BtnLog = Instance.new("TextButton", ToolBar); BtnLog.Size = UDim2.new(0, 30, 0, 25); BtnLog.BackgroundColor3 = THEME.ItemBG; BtnLog.Text = "📖"; BtnLog.TextColor3 = THEME.Gold; BtnLog.TextSize = 12; BtnLog.ZIndex = 6
            Instance.new("UICorner", BtnLog).CornerRadius = UDim.new(0, 4)
            local BtnMin = Instance.new("TextButton", ToolBar); BtnMin.Size = UDim2.new(0, 30, 0, 25); BtnMin.BackgroundColor3 = THEME.ItemBG; BtnMin.Text = "-"; BtnMin.TextColor3 = THEME.TextWhite; BtnMin.TextSize = 18; BtnMin.ZIndex = 6
            Instance.new("UICorner", BtnMin).CornerRadius = UDim.new(0, 4)
            local BtnClose = Instance.new("TextButton", ToolBar); BtnClose.Size = UDim2.new(0, 30, 0, 25); BtnClose.BackgroundColor3 = THEME.RedSoft; BtnClose.Text = "X"; BtnClose.TextColor3 = THEME.TextWhite; BtnClose.TextSize = 14; BtnClose.Font = Enum.Font.GothamBold; BtnClose.ZIndex = 6
            Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(0, 4)

            local StatusLabel = Instance.new("TextLabel", Header); StatusLabel.Text = "Connecting..."; StatusLabel.Size = UDim2.new(1, -40, 0, 20); StatusLabel.Position = UDim2.new(0, 20, 0, HEADER_HEIGHT - 23); StatusLabel.BackgroundTransparency = 1; StatusLabel.TextColor3 = THEME.Accent; StatusLabel.TextSize = 11 * FONT_SIZE_MULTIPLIER; StatusLabel.Font = Enum.Font.Gotham; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.ZIndex = 4

            local LogFrame = Instance.new("Frame", ScreenGui)
            LogFrame.Size = UDim2.new(0, GUI_WIDTH, 0, 150); LogFrame.Position = UDim2.new(OPEN_POS.X.Scale, OPEN_POS.X.Offset, OPEN_POS.Y.Scale, OPEN_POS.Y.Offset + GUI_HEIGHT + 5)
            LogFrame.BackgroundColor3 = THEME.Background; LogFrame.Visible = false; LogFrame.ZIndex = 15; LogFrame.ClipsDescendants = true
            Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 8)
            local LogHeader = Instance.new("Frame", LogFrame); LogHeader.Size = UDim2.new(1,0,0,25); LogHeader.BackgroundColor3 = THEME.ItemBG; LogHeader.ZIndex = 16
            Instance.new("UICorner", LogHeader).CornerRadius = UDim.new(0, 8)
            local LogTitle = Instance.new("TextLabel", LogHeader); LogTitle.Size = UDim2.new(1,0,1,0); LogTitle.Text = "Debug Logs (Drag me)"; LogTitle.TextColor3 = THEME.TextGray; LogTitle.BackgroundTransparency = 1; LogTitle.Font = Enum.Font.Code; LogTitle.TextSize = 11; LogTitle.ZIndex = 17

            local LogScroll = Instance.new("ScrollingFrame", LogFrame); LogScroll.Size = UDim2.new(1, -10, 1, -35); LogScroll.Position = UDim2.new(0, 5, 0, 30); LogScroll.BackgroundTransparency = 1; LogScroll.ZIndex = 16
            local LogLayout = Instance.new("UIListLayout", LogScroll); LogLayout.Padding = UDim.new(0, 2)

            local logLabels = {}
            AddLog = function(msg)
                if not isRunning then return end
                if #logLabels >= MAX_LOGS then
                    local old = table.remove(logLabels, 1)
                    if old then old:Destroy() end
                end
                local l = Instance.new("TextLabel", LogScroll); l.Size = UDim2.new(1, 0, 0, 15); l.BackgroundTransparency = 1; l.Text = "> " .. tostring(msg); l.TextColor3 = THEME.GreenActive; l.TextSize = 10; l.Font = Enum.Font.Code; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 17
                table.insert(logLabels, l)
                LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y + 5)
                task.defer(function() LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset) end)
            end

            local Controls = Instance.new("Frame", MainFrame); Controls.Size = UDim2.new(1, -40, 0, CONTROLS_HEIGHT); Controls.Position = UDim2.new(0, 20, 0, HEADER_HEIGHT); Controls.BackgroundTransparency = 1; Controls.ZIndex = 3
            local AJButton = Instance.new("TextButton", Controls); AJButton.Text = "AUTO JOIN: OFF"; AJButton.Size = UDim2.new(0, 100 * SCALE, 1, 0); AJButton.BackgroundColor3 = THEME.ItemBG; AJButton.TextColor3 = THEME.TextWhite; AJButton.Font = Enum.Font.GothamBold; AJButton.TextSize = 10; AJButton.ZIndex = 4
            Instance.new("UICorner", AJButton).CornerRadius = UDim.new(0, 8)

            local ValueInput = Instance.new("TextBox", Controls); ValueInput.Text = "0M"; ValueInput.Size = UDim2.new(1, -(100 * SCALE + 10), 1, 0); ValueInput.Position = UDim2.new(0, 100 * SCALE + 10, 0, 0); ValueInput.BackgroundColor3 = THEME.ItemBG; ValueInput.TextColor3 = THEME.TextWhite; ValueInput.Font = Enum.Font.GothamBold; ValueInput.TextSize = 11; ValueInput.ZIndex = 4
            Instance.new("UICorner", ValueInput).CornerRadius = UDim.new(0, 8)

            local Scroll = Instance.new("ScrollingFrame", MainFrame); Scroll.Size = UDim2.new(1, -40, 1, -(HEADER_HEIGHT + CONTROLS_HEIGHT + 15)); Scroll.Position = UDim2.new(0, 20, 0, HEADER_HEIGHT + CONTROLS_HEIGHT + 10); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.ScrollBarImageColor3 = THEME.Accent; Scroll.ZIndex = 3
            local ListLayout = Instance.new("UIListLayout", Scroll); ListLayout.Padding = UDim.new(0, 4); ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local ToggleFrame = Instance.new("Frame", ScreenGui); ToggleFrame.Size = UDim2.new(0, TOGGLE_SIZE, 0, TOGGLE_SIZE); ToggleFrame.Position = UDim2.new(0, 10, 0.5, -(TOGGLE_SIZE/2)); ToggleFrame.BackgroundColor3 = THEME.Background; ToggleFrame.Visible = false; ToggleFrame.ZIndex = 10
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 12)
            Instance.new("UIStroke", ToggleFrame).Color = THEME.Gold
            local ToggleBtn = Instance.new("TextButton", ToggleFrame); ToggleBtn.Text = "AFG"; ToggleBtn.Size = UDim2.new(1, 0, 1, 0); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.TextColor3 = THEME.Gold; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.ZIndex = 11;

            setStatus = function(txt, color)
                if not isRunning or not StatusLabel or not StatusLabel.Parent then return end
                StatusLabel.Text = txt
                StatusLabel.TextColor3 = color or THEME.TextGray
            end

            cleanup = function()
                isRunning = false
                State.AutoJoin = false
                table.clear(joinQueue)
                for _, conn in ipairs(connections) do
                    pcall(function() conn:Disconnect() end)
                end
                table.clear(connections)
            end

            table.insert(connections, BtnClose.MouseButton1Click:Connect(function()
                cleanup()
                if ScreenGui then ScreenGui:Destroy() end
            end))

            table.insert(connections, BtnMin.MouseButton1Click:Connect(function() MainFrame.Visible = false; LogFrame.Visible = false; ToggleFrame.Visible = true end))
            table.insert(connections, BtnLock.MouseButton1Click:Connect(function() isLocked = not isLocked; BtnLock.Text = isLocked and "🔒" or "🔓"; BtnLock.BackgroundColor3 = isLocked and THEME.Accent or THEME.ItemBG end))
            table.insert(connections, BtnLog.MouseButton1Click:Connect(function() LogFrame.Visible = not LogFrame.Visible; BtnLog.Text = LogFrame.Visible and "📕" or "📖" end))

            table.insert(connections, ToggleBtn.MouseButton1Click:Connect(function()
                if not ScreenGui or not ScreenGui.Parent then return end
                MainFrame.Visible = true
                ToggleFrame.Visible = false
            end))

            renderRow = function(item)
                if not isRunning then return end
                if rowFrames[item.uniqueId] then
                    rowFrames[item.uniqueId].Visible = true
                    return
                end

                if #renderOrder >= MAX_ROWS then
                    local oldestId = table.remove(renderOrder, 1)
                    if rowFrames[oldestId] then
                        rowFrames[oldestId]:Destroy()
                        rowFrames[oldestId] = nil
                    end
                end

                local r = Instance.new("Frame", Scroll); r.Name = item.uniqueId; r.Size = UDim2.new(1, 0, 0, ROW_HEIGHT); r.BackgroundColor3 = THEME.ItemBG; r.ZIndex = 4
                Instance.new("UICorner", r).CornerRadius = UDim.new(0, 8)
                local nl = Instance.new("TextLabel", r); nl.Text = item.nome; nl.Size = UDim2.new(0.5, 0, 1, 0); nl.Position = UDim2.new(0, 10, 0, 0); nl.BackgroundTransparency = 1; nl.TextColor3 = THEME.TextWhite; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Font = Enum.Font.GothamBold; nl.ZIndex = 5
                local vl = Instance.new("TextLabel", r); vl.Text = item.money; vl.Size = UDim2.new(0.3, 0, 1, 0); vl.Position = UDim2.new(0.5, 0, 0, 0); vl.BackgroundTransparency = 1; vl.TextColor3 = THEME.Gold; vl.ZIndex = 5
                local jb = Instance.new("TextButton", r); jb.Text = "JOIN"; jb.Size = UDim2.new(0, 50, 0, 24); jb.Position = UDim2.new(1, -60, 0.5, -12); jb.BackgroundColor3 = THEME.Accent; jb.TextColor3 = THEME.TextWhite; jb.ZIndex = 5
                Instance.new("UICorner", jb).CornerRadius = UDim.new(0, 6)
                jb.MouseButton1Click:Connect(function() safeTeleport(item.placeId, item.jobId, item.nome) end)
                rowFrames[item.uniqueId] = r
                table.insert(renderOrder, item.uniqueId)
                Scroll.CanvasSize = UDim2.new(0, 0, 0, #renderOrder * (ROW_HEIGHT + 4))
            end

            table.insert(connections, ValueInput.FocusLost:Connect(function()
                if not isRunning then return end
                local v = parseMoneyValue(ValueInput.Text)
                if v and v >= 0 then
                    State.MinGenFilter = v
                    ValueInput.Text = (v == 0) and "0M" or formatNumber(v)

                    for id, item in pairs(foundItems) do
                        if item.valor >= State.MinGenFilter and not isBlacklisted(item.nome) then
                            renderRow(item)
                        else
                            if rowFrames[id] then rowFrames[id].Visible = false end
                        end
                    end
                end
            end))

            table.insert(connections, AJButton.MouseButton1Click:Connect(function()
                if not isRunning then return end
                State.AutoJoin = not State.AutoJoin
                AJButton.Text = "AUTO JOIN: " .. (State.AutoJoin and "ON" or "OFF")
                AJButton.BackgroundColor3 = State.AutoJoin and THEME.Accent or THEME.ItemBG

                if State.AutoJoin then
                    for id, item in pairs(foundItems) do
                        if item.valor >= State.MinGenFilter and not isBlacklisted(item.nome) then
                            local inQueue = false
                            for _, qItem in ipairs(joinQueue) do
                                if qItem.uniqueId == item.uniqueId then inQueue = true; break end
                            end
                            if not inQueue then table.insert(joinQueue, item) end
                        end
                    end
                    if processQueue then processQueue() end
                end
            end))

            safeTeleport = function(placeId, jobId, itemName)
                if not isRunning then return "failed" end
                if not jobId or #jobId < 32 or jobId == game.JobId or (fullJobs[jobId] and tick() < fullJobs[jobId]) then return "failed" end
                if isJoining then return "busy" end
                isJoining = true; currentJoinJob = jobId; joinAttemptId = joinAttemptId + 1
                local thisAttempt = joinAttemptId
                setStatus("Joining: " .. itemName, THEME.Accent); AddLog("Joining: " .. itemName)
                task.delay(TELEPORT_TIMEOUT, function()
                    if isRunning and isJoining and joinAttemptId == thisAttempt then
                        isJoining = false; currentJoinJob = nil; setStatus("Timeout", THEME.RedSoft)
                    end
                end)
                local opts = Instance.new("TeleportOptions"); opts.ServerInstanceId = jobId
                local ok, err = pcall(function() TeleportService:TeleportAsync(placeId or game.PlaceId, {Player}, opts) end)
                if not ok then isJoining = false; currentJoinJob = nil; AddLog("Teleport Failed: " .. tostring(err)); return "failed" end
                return "success"
            end

            table.insert(connections, TeleportService.TeleportInitFailed:Connect(function(player, result, err)
                if player == Player and isRunning then
                    isJoining = false
                    if currentJoinJob then fullJobs[currentJoinJob] = tick() + 120 end
                    AddLog("Teleport Init Failed (Server Full?)")
                    setStatus("Server Full - Skipping", THEME.RedSoft)
                    currentJoinJob = nil
                end
            end))

            -- V6.1: Filter vor jedem Queue-Join erneut prüfen
            processQueue = function()
                if isProcessing or not State.AutoJoin or not isRunning then return end
                isProcessing = true
                task.spawn(function()
                    while #joinQueue > 0 and State.AutoJoin and isRunning do
                        local item = joinQueue[1]

                        if not item or item.valor < State.MinGenFilter or isBlacklisted(item.nome) then
                            table.remove(joinQueue, 1)
                        elseif not isJoining then
                            local status = safeTeleport(item.placeId, item.jobId, item.nome)
                            if status == "success" or status == "failed" then
                                table.remove(joinQueue, 1)
                            end
                        end

                        task.wait(1)
                    end
                    isProcessing = false
                end)
            end

            task.spawn(function()
                while isRunning do
                    task.wait(POLL_INTERVAL)
                    if not isRunning then break end

                    local body = httpRequest(FIREBASE_URL .. "?t=" .. tick())
                    if not isRunning then break end

                    if body and body ~= "null" then
                        local ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
                        if ok and type(decoded) == "table" then
                            setStatus("Connected", THEME.GreenActive)
                            local current = collectAll(decoded)
                            local count = 0
                            for id, item in pairs(current) do
                                if not processedIds[id] then
                                    processedIds[id] = tick()
                                    foundItems[id] = item
                                    if item.valor >= State.MinGenFilter and not isBlacklisted(item.nome) then
                                        count = count + 1
                                        renderRow(item)
                                        if State.AutoJoin then table.insert(joinQueue, item); processQueue() end
                                    end
                                end
                            end
                            if count > 0 then AddLog("Found " .. count .. " new pets!") end
                        end
                    else
                        setStatus("Reconnecting...", THEME.RedSoft)
                    end
                end
            end)

            local function makeDraggable(obj, handle)
                local dragging, inputStart, startPos
                table.insert(connections, handle.InputBegan:Connect(function(input)
                    if not isLocked and isRunning and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        dragging = true; inputStart = input.Position; startPos = obj.Position
                    end
                end))
                table.insert(connections, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end))
                table.insert(connections, UserInputService.InputChanged:Connect(function(input)
                    if dragging and not isLocked and isRunning and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - inputStart
                        obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end))
            end
            makeDraggable(MainFrame, DragHandle)
            makeDraggable(LogFrame, LogHeader)

            for _, v in ipairs(MainFrame:GetDescendants()) do if v:IsA("GuiObject") and v ~= Bg and v ~= Shade then v.ZIndex = math.max(v.ZIndex, 3) end end
        end)
        if success then break end
        warn("[Afg Joiner] Load failed:", err)
        if attempt >= 5 then break end
        task.wait(2)
    end
end
safeLoad()
