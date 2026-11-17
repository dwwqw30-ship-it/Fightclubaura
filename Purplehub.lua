local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local event = RS:WaitForChild("AutoWinEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "PurpleHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(230, 145)
frame.Position = UDim2.new(0.5, -115, 0.5, -72)
frame.BackgroundColor3 = Color3.fromRGB(30, 15, 45)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "PURPLE HUB"
title.TextColor3 = Color3.fromRGB(190, 100, 255)
title.TextSize = 23
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.85, 0, 0, 50)
button.Position = UDim2.new(0.075, 0, 0, 65)
button.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
button.Text = "AUTO WIN: OFF"
button.TextColor3 = Color3.new(1,1,1)
button.TextSize = 18
button.Parent = frame

Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

local enabled = false

button.MouseButton1Click:Connect(function()
    enabled = not enabled
    button.Text = enabled and "AUTO WIN: ON" or "AUTO WIN: OFF"

    if enabled then
        event:FireServer()
    end
end)

local hide = Instance.new("TextButton")
hide.Size = UDim2.fromOffset(38, 38)
hide.Position = UDim2.new(1, -42, 0, 4)
hide.BackgroundColor3 = Color3.fromRGB(150, 70, 230)
hide.Text = "—"
hide.TextSize = 22
hide.TextColor3 = Color3.new(1,1,1)
hide.Parent = frame

local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(55, 55)
open.Position = UDim2.new(0, 15, 0.5, 0)
open.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
open.Text = "PH"
open.TextColor3 = Color3.new(1,1,1)
open.TextSize = 20
open.Visible = false
open.Parent = gui

hide.MouseButton1Click:Connect(function()
    frame.Visible = false
    open.Visible = true
end)

open.MouseButton1Click:Connect(function()
    frame.Visible = true
    open.Visible = false
end)

Instance.new("UICorner", open).CornerRadius = UDim.new(1, 0)
