--[[
    PHANTIX — TITLE IMAGE TEST
    Eigenständiger Test: prüft nur, ob das Logo als Roblox-Image geladen wird.
    Starten, Ergebnis oben ablesen, danach mit dem X schließen.
]]
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
player = player or Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("PHANTIX_TitleImageTest")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PHANTIX_TitleImageTest"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "TestPanel"
panel.Size = UDim2.fromOffset(300, 150)
panel.Position = UDim2.new(0.5, -150, 0, 70)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 28)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel
local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(42, 211, 255)
outline.Thickness = 1.5
outline.Parent = panel

local heading = Instance.new("TextLabel")
heading.BackgroundTransparency = 1
heading.Size = UDim2.new(1, -20, 0, 22)
heading.Position = UDim2.fromOffset(10, 7)
heading.Font = Enum.Font.GothamBold
heading.Text = "PHANTIX LOGO TEST"
heading.TextColor3 = Color3.fromRGB(230, 235, 255)
heading.TextSize = 14
heading.Parent = panel

local logo = Instance.new("ImageLabel")
logo.Name = "TestLogo"
logo.BackgroundTransparency = 1
logo.Size = UDim2.fromOffset(190, 62)
logo.Position = UDim2.new(0.5, -95, 0, 34)
logo.Image = "rbxassetid://79473124931614"
logo.ImageTransparency = 0
logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
logo.ScaleType = Enum.ScaleType.Fit
logo.Visible = true
logo.Parent = panel

local fallback = Instance.new("TextLabel")
fallback.BackgroundTransparency = 1
fallback.Size = logo.Size
fallback.Position = logo.Position
fallback.Font = Enum.Font.FredokaOne
fallback.Text = "PHANTIX"
fallback.TextColor3 = Color3.fromRGB(245, 255, 250)
fallback.TextSize = 30
fallback.Visible = true
fallback.Parent = panel

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.fromOffset(10, 112)
status.Font = Enum.Font.Gotham
status.Text = "Status: Lade Logo ..."
status.TextColor3 = Color3.fromRGB(255, 211, 105)
status.TextSize = 12
status.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(25, 25)
close.Position = UDim2.new(1, -30, 0, 5)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 110, 130)
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.Parent = panel
close.Activated:Connect(function() gui:Destroy() end)

-- Fallback-Text bleibt sichtbar, bis Roblox den Bild-Download bestätigt.
task.spawn(function()
    local ok, err = pcall(function()
        ContentProvider:PreloadAsync({logo})
    end)
    task.wait(0.25)
    if gui.Parent == nil then return end
    if ok and logo.IsLoaded then
        fallback.Visible = false
        status.Text = "ERFOLG: Logo wurde geladen."
        status.TextColor3 = Color3.fromRGB(0, 225, 158)
    else
        fallback.Visible = true
        status.Text = "FEHLER: Bild nicht geladen — Text-Fallback sichtbar."
        status.TextColor3 = Color3.fromRGB(255, 110, 130)
        warn("[PHANTIX TEST] Logo konnte nicht geladen werden. IsLoaded=" .. tostring(logo.IsLoaded) .. " Fehler=" .. tostring(err))
    end
end)

print("[PHANTIX TEST] Titelbild-Test gestartet: rbxassetid://79473124931614")
