print("deobf by discord.gg/speedhub")
print("deobf by discord.gg/speedhub")
print("deobf by discord.gg/speedhub")
print("deobf by discord.gg/speedhub")
print("deobf by discord.gg/speedhub")

-- ============================================================
-- Snow TP Bat — Full (visible buttons with borders)
-- ============================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local localPlayer      = Players.LocalPlayer
local playerGui        = localPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG_FILE = "SnowVS_TPBat.json"

local config = {
    keybind   = "P",
    inputType = "Keyboard",
    scale     = 1,
}

local state = {
    enabled            = false,
    connection         = nil,
    hitCooldown        = false,
    key                = Enum.KeyCode.P,
    inputType          = Enum.UserInputType.Keyboard,
    binding            = false,
    antiDieConnections = {},
}

local function loadConfig()
    pcall(function()
        if type(isfile) ~= "function" then return end
        if not isfile(CONFIG_FILE) then return end
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(data) ~= "table" then return end

        if type(data.keybind) == "string" and Enum.KeyCode[data.keybind] then
            config.keybind = data.keybind
        end
        if data.inputType == "Keyboard" or data.inputType == "Gamepad1" then
            config.inputType = data.inputType
        end
        if type(data.scale) == "number" then
            config.scale = math.clamp(data.scale, 0.8, 1.3)
        end

        state.key       = Enum.KeyCode[config.keybind] or Enum.KeyCode.P
        state.inputType = Enum.UserInputType[config.inputType] or Enum.UserInputType.Keyboard
    end)
end

local function saveConfig()
    pcall(function()
        if type(writefile) ~= "function" then return end
        writefile(CONFIG_FILE, HttpService:JSONEncode(config))
    end)
end

loadConfig()

-- ============================================================
-- LOGIC
-- ============================================================
local function disconnectAntiDie()
    for _, conn in ipairs(state.antiDieConnections) do
        pcall(function() conn:Disconnect() end)
    end
    state.antiDieConnections = {}
end

local function hookAntiDie(character)
    disconnectAntiDie()
    if not state.enabled or not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    pcall(function()
        humanoid.BreakJointsOnDeath = false
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dying, false)
    end)

    table.insert(state.antiDieConnections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if state.enabled and humanoid.Parent and humanoid.Health <= 0 then
            pcall(function()
                humanoid.Health = humanoid.MaxHealth
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
    end))
end

local function findBat()
    local character = localPlayer.Character
    if not character then return nil end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            local n = child.Name:lower()
            if n:find("bat") or n:find("slap") then
                return child
            end
        end
    end

    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("bat") or n:find("slap") then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        pcall(function() humanoid:EquipTool(child) end)
                    end
                    return child
                end
            end
        end
    end

    return nil
end

local function nearestPlayerTarget(root)
    if not root then return nil, math.huge end
    local best, bestD = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local otherRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local otherHum  = player.Character:FindFirstChildOfClass("Humanoid")
            if otherRoot and otherHum and otherHum.Health > 0 then
                local d = (root.Position - otherRoot.Position).Magnitude
                if d < bestD then
                    bestD = d
                    best = player
                end
            end
        end
    end

    return best, bestD
end

local function swing()
    if state.hitCooldown then return end
    state.hitCooldown = true

    pcall(function()
        local bat = findBat()
        if not bat then return end
        bat:Activate()
        local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
        if remote then
            remote:FireServer()
        end
    end)

    task.delay(0.08, function()
        state.hitCooldown = false
    end)
end

local function tpBatTick()
    if not state.enabled then return end

    local character = localPlayer.Character
    if not character then return end

    local root     = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    if humanoid.Health <= 0 then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        pcall(function()
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end)
    end

    local bat = findBat()
    if bat and bat.Parent ~= character then
        pcall(function() humanoid:EquipTool(bat) end)
    end

    local target, distance = nearestPlayerTarget(root)
    if not target then return end

    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or distance > 100 then return end

    pcall(function()
        if root.SetNetworkOwner then root:SetNetworkOwner(nil) end
    end)

    if not state.enabled or root.Parent ~= character or not targetRoot.Parent then
        return
    end

    root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0.9, 0))
    root.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity

    pcall(function()
        if root.SetNetworkOwner then root:SetNetworkOwner(localPlayer) end
    end)

    local camera = workspace.CurrentCamera
    if camera then
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
    end

    swing()

    pcall(function()
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.CanCollide = false
            end
        end
    end)
end

local function setEnabled(value)
    state.enabled = value == true

    if state.enabled then
        hookAntiDie(localPlayer.Character)
        if state.connection then
            state.connection:Disconnect()
            state.connection = nil
        end
        state.connection = RunService.Heartbeat:Connect(tpBatTick)
    else
        if state.connection then
            state.connection:Disconnect()
            state.connection = nil
        end
        disconnectAntiDie()

        local char = localPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                if root.SetNetworkOwner then
                    root:SetNetworkOwner(localPlayer)
                end
            end)
        end
    end
end

localPlayer.CharacterAdded:Connect(function(character)
    if state.enabled then
        task.wait(0.1)
        hookAntiDie(character)
    end
end)

-- ============================================================
-- UI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SnowVSTPBatStandalone"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(300, 176)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.ZIndex = 1
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local uiScale = Instance.new("UIScale", frame)
uiScale.Scale = config.scale

-- Background artwork
local bgArt = Instance.new("ImageLabel")
bgArt.Name = "BackgroundArt"
bgArt.Size = UDim2.fromScale(1, 1)
bgArt.Position = UDim2.fromScale(0, 0)
bgArt.BackgroundTransparency = 1
bgArt.Image = "rbxassetid://71276441402938"
bgArt.ImageTransparency = 0
bgArt.ScaleType = Enum.ScaleType.Crop
bgArt.ZIndex = 1
bgArt.Parent = frame
Instance.new("UICorner", bgArt).CornerRadius = UDim.new(0, 12)

-- Title artwork
local titleArt = Instance.new("ImageLabel")
titleArt.Name = "TitleArtwork"
titleArt.Size = UDim2.fromOffset(180, 65)
titleArt.Position = UDim2.fromOffset(18, 8)
titleArt.BackgroundTransparency = 1
titleArt.Image = "rbxassetid://85348603619953"
titleArt.ImageTransparency = 0
titleArt.ScaleType = Enum.ScaleType.Fit
titleArt.ZIndex = 3
titleArt.Parent = frame

-- Activate button
local activateBtn = Instance.new("TextButton")
activateBtn.Name = "ActivateBtn"
activateBtn.Size = UDim2.fromOffset(264, 40)
activateBtn.Position = UDim2.fromOffset(18, 84)
activateBtn.BackgroundColor3 = Color3.fromRGB(160, 165, 175)
activateBtn.BackgroundTransparency = 0.2
activateBtn.BorderSizePixel = 0
activateBtn.Font = Enum.Font.GothamBold
activateBtn.TextSize = 15
activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
activateBtn.Text = "TP BAT OFF"
activateBtn.AutoButtonColor = false
activateBtn.ZIndex = 3
activateBtn.Parent = frame
Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 10)
local actStroke = Instance.new("UIStroke", activateBtn)
actStroke.Color = Color3.fromRGB(255, 255, 255)
actStroke.Thickness = 1.2
actStroke.Transparency = 0.35

-- Keybind row
local keyRow = Instance.new("Frame")
keyRow.Name = "KeyRow"
keyRow.Size = UDim2.fromOffset(264, 32)
keyRow.Position = UDim2.fromOffset(18, 132)
keyRow.BackgroundColor3 = Color3.fromRGB(160, 165, 175)
keyRow.BackgroundTransparency = 0.2
keyRow.BorderSizePixel = 0
keyRow.ZIndex = 3
keyRow.Parent = frame
Instance.new("UICorner", keyRow).CornerRadius = UDim.new(0, 10)
local rowStroke = Instance.new("UIStroke", keyRow)
rowStroke.Color = Color3.fromRGB(255, 255, 255)
rowStroke.Thickness = 1.2
rowStroke.Transparency = 0.35

local keyLabel = Instance.new("TextLabel")
keyLabel.Name = "KeyLabel"
keyLabel.Size = UDim2.new(0, 120, 1, 0)
keyLabel.Position = UDim2.fromOffset(12, 0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "KEYBIND"
keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextSize = 13
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.ZIndex = 4
keyLabel.Parent = keyRow

-- Keybind value pill
local keyBtn = Instance.new("TextButton")
keyBtn.Name = "KeyBtn"
keyBtn.Size = UDim2.fromOffset(62, 24)
keyBtn.Position = UDim2.new(1, -70, 0.5, -12)
keyBtn.BackgroundColor3 = Color3.fromRGB(120, 125, 135)
keyBtn.BackgroundTransparency = 0.1
keyBtn.BorderSizePixel = 0
keyBtn.Font = Enum.Font.GothamBold
keyBtn.TextSize = 13
keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBtn.Text = state.key.Name
keyBtn.AutoButtonColor = false
keyBtn.ZIndex = 4
keyBtn.Parent = keyRow
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)
local keyStroke = Instance.new("UIStroke", keyBtn)
keyStroke.Color = Color3.fromRGB(255, 255, 255)
keyStroke.Thickness = 1
keyStroke.Transparency = 0.4

-- Top-right control buttons (-, +, x)
local function createCtrlButton(text, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(22, 22)
    btn.Position = UDim2.new(1, xOffset, 0, 14)
    btn.BackgroundColor3 = Color3.fromRGB(70, 140, 230)
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local ctrlStroke = Instance.new("UIStroke", btn)
    ctrlStroke.Color = Color3.fromRGB(255, 255, 255)
    ctrlStroke.Thickness = 1
    ctrlStroke.Transparency = 0.3
    return btn
end

local scaleMinus = createCtrlButton("-", -85)
local scalePlus  = createCtrlButton("+", -59)
local closeBtn   = createCtrlButton("x", -33)

-- Reopen button
local reopenBtn = Instance.new("ImageButton")
reopenBtn.Name = "SnowVSTPBatReopen"
reopenBtn.Size = UDim2.fromOffset(170, 38)
reopenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.BackgroundTransparency = 0.08
reopenBtn.BorderSizePixel = 0
reopenBtn.Image = "rbxassetid://85348603619953"
reopenBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.ScaleType = Enum.ScaleType.Fit
reopenBtn.Visible = false
reopenBtn.Active = true
reopenBtn.Draggable = true
reopenBtn.Parent = screenGui
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(0, 12)

-- ============================================================
-- UI BEHAVIOR
-- ============================================================
local function refreshUI()
    activateBtn.Text = state.enabled and "TP BAT ON" or "TP BAT OFF"

    if state.enabled then
        activateBtn.BackgroundColor3 = Color3.fromRGB(80, 210, 120)
        activateBtn.BackgroundTransparency = 0.2
        actStroke.Color = Color3.fromRGB(140, 255, 170)
        actStroke.Transparency = 0.25
    else
        activateBtn.BackgroundColor3 = Color3.fromRGB(160, 165, 175)
        activateBtn.BackgroundTransparency = 0.2
        actStroke.Color = Color3.fromRGB(255, 255, 255)
        actStroke.Transparency = 0.4
    end

    if state.binding then
        keyBtn.Text = "..."
    elseif state.inputType == Enum.UserInputType.Gamepad1 then
        keyBtn.Text = "GP " .. state.key.Name
    else
        keyBtn.Text = state.key.Name
    end
end

activateBtn.MouseButton1Click:Connect(function()
    setEnabled(not state.enabled)
    refreshUI()
end)

keyBtn.MouseButton1Click:Connect(function()
    state.binding = true
    refreshUI()
end)

local function setScale(v)
    config.scale = math.clamp(v, 0.8, 1.3)
    uiScale.Scale = config.scale
    saveConfig()
end

scaleMinus.MouseButton1Click:Connect(function()
    setScale(config.scale - 0.05)
end)

scalePlus.MouseButton1Click:Connect(function()
    setScale(config.scale + 0.05)
end)

closeBtn.MouseButton1Click:Connect(function()
    reopenBtn.Position = frame.Position
    frame.Visible = false
    reopenBtn.Visible = true
end)

reopenBtn.MouseButton1Click:Connect(function()
    frame.Position = reopenBtn.Position
    reopenBtn.Visible = false
    frame.Visible = true
end)

-- ============================================================
-- KEYBIND LISTENER
-- ============================================================
UserInputService.InputBegan:Connect(function(input)
    local isKeyboard = input.UserInputType == Enum.UserInputType.Keyboard
    local isGamepad  = input.UserInputType == Enum.UserInputType.Gamepad1

    if not (isKeyboard or isGamepad) then return end

    if state.binding then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            state.key        = input.KeyCode
            state.inputType  = input.UserInputType
            config.keybind   = input.KeyCode.Name
            config.inputType = input.UserInputType.Name
            saveConfig()
        end
        state.binding = false
        refreshUI()
        return
    end

    local focused = UserInputService:GetFocusedTextBox()
    if focused then return end

    if input.UserInputType == state.inputType and input.KeyCode == state.key then
        setEnabled(not state.enabled)
        refreshUI()
    end
end)

-- ============================================================
-- CLEANUP HOOK
-- ============================================================
getgenv().SnowVS_TPBatStandalone = {
    destroy = function()
        setEnabled(false)
        pcall(function() screenGui:Destroy() end)
        getgenv().SnowVS_TPBatStandalone = nil
    end,
}

refreshUI()

print("[Snow TP Bat] Loaded. Press " .. state.key.Name .. " to toggle.")
