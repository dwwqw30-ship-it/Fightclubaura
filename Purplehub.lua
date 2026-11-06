
-- PURPLE HUB V3
-- Roblox Studio | LocalScript
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local purple = Color3.fromRGB(174, 91, 255)
local dark = Color3.fromRGB(25, 14, 39)
local panel = Color3.fromRGB(48, 27, 69)

local gui = Instance.new("ScreenGui")
gui.Name = "PurpleHubV3"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(285, 355)
main.Position = UDim2.new(0.5, -142, 0.5, -177)
main.BackgroundColor3 = dark
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local outline = Instance.new("UIStroke", main)
outline.Color = purple
outline.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 48)
title.BackgroundTransparency = 1
title.Text = "PURPLE HUB V3"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = main

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(10, 95)
content.Size = UDim2.new(1, -20, 1, -105)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 8)

local function button(name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 39)
    b.BackgroundColor3 = panel
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = name .. "  OFF"
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = content

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)

    local enabled = false

    b.Activated:Connect(function()
        enabled = not enabled
        b.Text = name .. (enabled and "  ON" or "  OFF")

        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = enabled and purple or panel
        }):Play()

        callback(enabled)
    end)
end

local esp = false
local big = false
local transparent = false
local visualizer = false

local highlights = {}
local boxes = {}

local function update(p)
    if p == player then return end

    if highlights[p] then
        highlights[p]:Destroy()
        highlights[p] = nil
    end

    if boxes[p] then
        boxes[p]:Destroy()
        boxes[p] = nil
    end

    local char = p.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    if esp then
        local h = Instance.new("Highlight")
        h.FillColor = purple
        h.OutlineColor = Color3.new(1,1,1)
        h.FillTransparency = 0.65
        h.Parent = char
        highlights[p] = h
    end

    if visualizer then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = head
        box.Size = head.Size
        box.Color3 = purple
        box.Transparency = 0.6
        box.AlwaysOnTop = true
        box.Parent = head
        boxes[p] = box
    end
end

local function refresh()
    for _, p in ipairs(Players:GetPlayers()) do
        update(p)
    end
end

button("PLAYER ESP", function(v)
    esp = v
    refresh()
end)

button("BIG HEAD VISUAL", function(v)
    big = v
    for _, p in ipairs(Players:GetPlayers()) do
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head and p ~= player then
            if v then
                head.Size = Vector3.new(2,2,2)
            else
                head.Size = Vector3.new(1,1,1)
            end
        end
    end
end)

button("TRANSPARENT HEAD", function(v)
    transparent = v
    for _, p in ipairs(Players:GetPlayers()) do
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head and p ~= player then
            head.LocalTransparencyModifier = v and 0.6 or 0
        end
    end
end)

button("HITBOX VISUALIZER", function(v)
    visualizer = v
    refresh()
end)

local combat = Instance.new("TextLabel")
combat.Size = UDim2.new(1, 0, 0, 30)
combat.BackgroundTransparency = 1
combat.Text = "COMBAT SETTINGS"
combat.TextColor3 = purple
combat.Font = Enum.Font.GothamBold
combat.TextSize = 15
combat.Parent = content

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 65)
info.BackgroundColor3 = panel
info.TextColor3 = Color3.new(1,1,1)
info.TextWrapped = true
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.Text = "Combat system requires server-side implementation in your own Roblox game."
info.Parent = content

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        update(p)
    end)
end)

-- Round open/close button
local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(58, 58)
open.Position = UDim2.new(0, 15, 0.5, 0)
open.BackgroundColor3 = purple
open.Text = "💜"
open.TextSize = 25
open.Parent = gui

Instance.new("UICorner", open).CornerRadius = UDim.new(1, 0)

local openStroke = Instance.new("UIStroke", open)
openStroke.Color = Color3.new(1,1,1)
openStroke.Thickness = 2

open.Activated:Connect(function()
    main.Visible = not main.Visible
end)

print("PURPLE HUB V3 LOADED")
