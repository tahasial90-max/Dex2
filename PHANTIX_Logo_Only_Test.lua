-- PHANTIX LOGO ONLY TEST
-- Dieses Testscript zeigt ausschließlich das Bild. Kein Text-Fallback.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("PHANTIX_LogoOnlyTest")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PHANTIX_LogoOnlyTest"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = playerGui

local image = Instance.new("ImageLabel")
image.Name = "PHANTIX_Logo_ImageOnly"
image.AnchorPoint = Vector2.new(0.5, 0.5)
image.Position = UDim2.fromScale(0.5, 0.5)
image.Size = UDim2.fromOffset(320, 120)
image.BackgroundTransparency = 1
image.BorderSizePixel = 0
image.Image = "rbxassetid://79473124931614"
image.ImageTransparency = 0
image.ImageColor3 = Color3.new(1, 1, 1)
image.ScaleType = Enum.ScaleType.Fit
image.Visible = true
image.ZIndex = 10
image.Parent = gui

-- Schließen durch Antippen des Logos (Test-GUI entfernen).
image.Active = true
image.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        gui:Destroy()
    end
end)

print("[PHANTIX] Logo-only test: rbxassetid://79473124931614")
