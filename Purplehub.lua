
-- PURPLE HUB V2 | MOBILE GUI
-- For your own Roblox experience

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local purple = Color3.fromRGB(170, 80, 255)
local dark = Color3.fromRGB(25, 13, 40)

local gui = Instance.new("ScreenGui")
gui.Name = "PurpleHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(270, 390)
main.Position = UDim2.new(0.5, -135, 0.5, -195)
main.BackgroundColor3 = dark
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local stroke = Instance.new("UIStroke", main)
stroke.Color = purple
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 48)
title.BackgroundTransparency = 1
title.Text = "💜 PURPLE HUB V2"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.Parent = main

-- Mobile dragging
local dragging, dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle button helper
local function makeButton(name, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.88, 0, 0, 39)
    b.Position = UDim2.new(0.06, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(65, 35, 95)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = name .. " : OFF"
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = main

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)

    local enabled = false

    b.Activated:Connect(function()
        enabled = not enabled
        b.Text = name .. (enabled and " : ON" or " : OFF")
        b.BackgroundColor3 = enabled and purple
            or Color3.fromRGB(65,35,95)
        callback(enabled)
    end)

    return b
end

local highlights = {}
local headEffects = {}
local bigHead = false
local transparent = false
local visualizer = false

local function clearPlayer(p)
    if highlights[p] then
        highlights[p]:Destroy()
        highlights[p] = nil
    end

    if headEffects[p] then
        headEffects[p]:Destroy()
        headEffects[p] = nil
    end
end

local function updatePlayer(p)
    if p == player then return end

    local char = p.Character
    if not char then return end

    if highlights[p] then
        highlights[p]:Destroy()
        highlights[p] = nil
    end

    local head = char:FindFirstChild("Head")
    if not head then return end

    if espEnabled then
        local h = Instance.new("Highlight")
        h.FillColor = purple
        h.OutlineColor = Color3.new(1,1,1)
        h.FillTransparency = 0.65
        h.Parent = char
        highlights[p] = h
    end

    if headEffects[p] then
        headEffects[p]:Destroy()
    end

    if visualizer then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = head
        box.Size = head.Size
        box.Color3 = purple
        box.Transparency = 0.65
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Parent = head
        headEffects[p] = box
    end
end

espEnabled = false

makeButton("PLAYER ESP", 60, function(on)
    espEnabled = on
    for _, p in ipairs(Players:GetPlayers()) do
        updatePlayer(p)
    end
end)

makeButton("BIG HEAD VISUAL", 108, function(on)
    bigHead = on
    for _, p in ipairs(Players:GetPlayers()) do
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head and p ~= player then
            head.Size = on and Vector3.new(2.5,2.5,2.5)
                or Vector3.new(1,1,1)
        end
    end
end)

makeButton("TRANSPARENT HEAD", 156, function(on)
    transparent = on
    for _, p in ipairs(Players:GetPlayers()) do
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head and p ~= player then
            head.LocalTransparencyModifier = on and 0.65 or 0
        end
    end
end)

makeButton("HITBOX VISUALIZER", 204, function(on)
    visualizer = on
    for _, p in ipairs(Players:GetPlayers()) do
        updatePlayer(p)
    end
end)

-- Reapply visual effects after respawn
local function watchPlayer(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        updatePlayer(p)
    end)
end

Players.PlayerAdded:Connect(watchPlayer)

for _, p in ipairs(Players:GetPlayers()) do
    watchPlayer(p)
end

-- Hide / show menu
local hide = Instance.new("TextButton")
hide.Size = UDim2.fromOffset(90, 38)
hide.Position = UDim2.new(0, 10, 0.5, 0)
hide.BackgroundColor3 = purple
hide.Text = "PURPLE"
hide.TextColor3 = Color3.new(1,1,1)
hide.Font = Enum.Font.GothamBold
hide.Parent = gui

Instance.new("UICorner", hide).CornerRadius = UDim.new(0,10)

hide.Activated:Connect(function()
    main.Visible = not main.Visible
end)

print("PURPLE HUB V2 LOADED")
