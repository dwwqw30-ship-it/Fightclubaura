
-- PURPLE HUB V4
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
gui.Name = "PurpleHubV4"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN WINDOW
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(285, 355)
main.Position = UDim2.new(0.5, -142, 0.5, -177)
main.BackgroundColor3 = dark
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local outline = Instance.new("UIStroke", main)
outline.Color = purple
outline.Thickness = 2

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 52)
title.BackgroundColor3 = panel
title.BackgroundTransparency = 0.2
title.Text = "PURPLE HUB V4"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 21
title.Active = true
title.Parent = main

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

-- MOBILE DRAG
local dragging = false
local dragInput
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragInput = nil
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or (input.UserInputType == Enum.UserInputType.Touch
    and input == dragInput) then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- SCROLLING CONTENT
local content = Instance.new("ScrollingFrame")
content.Position = UDim2.fromOffset(10, 62)
content.Size = UDim2.new(1, -20, 1, -72)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 5
content.ScrollBarImageColor3 = purple
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Active = true
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local padding = Instance.new("UIPadding")
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = content

-- BUTTON FUNCTION
local function button(name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -5, 0, 39)
    b.BackgroundColor3 = panel
    b.TextColor3 = Color3.new(1, 1, 1)
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

-- PLAYER VISUALS
local esp = false
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
        h.OutlineColor = Color3.new(1, 1, 1)
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
    for _, p in ipairs(Players:GetPlayers()) do
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head and p ~= player then
            head.Size = v and Vector3.new(2, 2, 2)
                or Vector3.new(1, 1, 1)
        end
    end
end)

button("TRANSPARENT HEAD", function(v)
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

-- COMBAT INFO
local combat = Instance.new("TextLabel")
combat.Size = UDim2.new(1, -5, 0, 30)
combat.BackgroundTransparency = 1
combat.Text = "COMBAT SETTINGS"
combat.TextColor3 = purple
combat.Font = Enum.Font.GothamBold
combat.TextSize = 15
combat.Parent = content

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -5, 0, 65)
info.BackgroundColor3 = panel
info.TextColor3 = Color3.new(1, 1, 1)
info.TextWrapped = true
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.Text = "Combat system requires server-side implementation in your own Roblox game."
info.Parent = content

Instance.new("UICorner", info).CornerRadius = UDim.new(0, 9)

-- PLAYER JOIN
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        update(p)
    end)
end)

-- OPEN / CLOSE BUTTON
local open = Instance.new("TextButton")
open.Size = UDim2.fromOffset(58, 58)
open.Position = UDim2.new(0, 15, 0.5, 0)
open.BackgroundColor3 = purple
open.Text = "💜"
open.TextSize = 25
open.Parent = gui

Instance.new("UICorner", open).CornerRadius = UDim.new(1, 0)

local openStroke = Instance.new("UIStroke", open)
openStroke.Color = Color3.new(1, 1, 1)
openStroke.Thickness = 2

open.Activated:Connect(function()
    main.Visible = not main.Visible
end)

print("PURPLE HUB V4 LOADED")
