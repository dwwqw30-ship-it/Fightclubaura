-- ============================================================
-- Fight Club helper script (v2)
-- Меню + перетаскивание + круглая кнопка скрытия
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== НАСТРОЙКИ =====
local config = {
    killAura = false,
    esp = false,
    bigHeads = false,
    hitboxes = false,
    punchSpeed = false,
    punchDamage = false,
}

-- ============================================================
-- ESP
-- ============================================================
local espObjects = {}
local function createESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    if espObjects[plr] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.Parent = char
    espObjects[plr] = hl
end

local function removeESP(plr)
    if espObjects[plr] then
        espObjects[plr]:Destroy()
        espObjects[plr] = nil
    end
end

local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if config.esp then createESP(p) else removeESP(p) end
    end
end

Players.PlayerAdded:Connect(function(p)
    if config.esp then
        p.CharacterAdded:Connect(function() task.wait(0.5) createESP(p) end)
    end
end)
Players.PlayerRemoving:Connect(removeESP)

-- ============================================================
-- БОЛЬШИЕ ГОЛОВЫ / ХИТБОКСЫ
-- ============================================================
local function setBigHeads(state)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                if state then
                    head.Size = Vector3.new(3, 3, 3)
                    head.Transparency = 0.3
                    head.CanCollide = false
                else
                    head.Size = Vector3.new(2, 1, 1)
                    head.Transparency = 0
                    head.CanCollide = true
                end
            end
        end
    end
end

-- ============================================================
-- KILL AURA
-- ============================================================
local function getClosestPlayer(maxDist)
    local closest, dist = nil, maxDist or 20
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHrp.Position).Magnitude
                if d < dist then
                    closest, dist = plr, d
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if config.killAura then
        local target = getClosestPlayer(15)
        if target and target.Character then
            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:TakeDamage(10)
            end
        end
    end
end)

-- ============================================================
-- PUNCH SPEED / DAMAGE (заглушки — под свою игру)
-- ============================================================
local function setPunchSpeed(state)
    local rs = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(rs:GetDescendants()) do
        if obj:IsA("NumberValue") and obj.Name:lower():find("punch") then
            obj.Value = state and 0.1 or 0.5
        end
    end
end

local function setPunchDamage(state)
    local rs = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(rs:GetDescendants()) do
        if obj:IsA("NumberValue") and obj.Name:lower():find("damage") then
            obj.Value = state and 999 or 10
        end
    end
end

-- ============================================================
-- МЕНЮ
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FC_Menu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- --- Основное меню ---
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 320)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Visible = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- --- Круглая кнопка скрытия (переключатель) ---
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Text = "👁"
toggleBtn.TextSize = 26
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleBtn

-- --- Перетаскивание меню (мышь + тач) ---
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- --- Перетаскивание круглой кнопки ---
local btnDragging, btnDragInput, btnStartPos, btnDragStart
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                btnDragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        btnDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input == btnDragInput) then
        local delta = input.Position - btnDragStart
        -- защита от «уезжания» кнопки, если началось перетаскивание
        toggleBtn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)

-- --- Переключение видимости меню ---
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- --- Функция добавления кнопки ---
local function addButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- --- Кнопки меню ---
local y = 5

local auraBtn = addButton("Kill Aura: OFF", y, function()
    config.killAura = not config.killAura
    auraBtn.Text = "Kill Aura: " .. (config.killAura and "ON" or "OFF")
end); y = y + 40

local espBtn = addButton("ESP: OFF", y, function()
    config.esp = not config.esp
    espBtn.Text = "ESP: " .. (config.esp and "ON" or "OFF")
    refreshESP()
end); y = y + 40

local headBtn = addButton("Big Heads: OFF", y, function()
    config.bigHeads = not config.bigHeads
    headBtn.Text = "Big Heads: " .. (config.bigHeads and "ON" or "OFF")
    setBigHeads(config.bigHeads)
end); y = y + 40

local hitboxBtn = addButton("Hitboxes: OFF", y, function()
    config.hitboxes = not config.hitboxes
    hitboxBtn.Text = "Hitboxes: " .. (config.hitboxes and "ON" or "OFF")
    -- хитбоксы = большие прозрачные головы (можно расширить на торс/руки)
    setBigHeads(config.hitboxes)
end); y = y + 40

local speedBtn = addButton("Punch Speed: OFF", y, function()
    config.punchSpeed = not config.punchSpeed
    speedBtn.Text = "Punch Speed: " .. (config.punchSpeed and "ON" or "OFF")
    setPunchSpeed(config.punchSpeed)
end); y = y + 40

local dmgBtn = addButton("Punch Damage: OFF", y, function()
    config.punchDamage = not config.punchDamage
    dmgBtn.Text = "Punch Damage: " .. (config.punchDamage and "ON" or "OFF")
    setPunchDamage(config.punchDamage)
end)
