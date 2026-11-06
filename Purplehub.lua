-- ============================================================
-- Fight Club helper script (v3, исправленная)
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local config = {
    killAura = false, esp = false, bigHeads = false,
    hitboxes = false, punchSpeed = false, punchDamage = false,
}

-- ============================================================
-- ESP (обновляется при респавне)
-- ============================================================
local espObjects = {}
local function createESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char or espObjects[plr] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.Parent = char
    espObjects[plr] = hl
end
local function removeESP(plr)
    if espObjects[plr] then espObjects[plr]:Destroy(); espObjects[plr] = nil end
end
local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if config.esp then createESP(p) else removeESP(p) end
    end
end
local function hookPlayer(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if config.esp then createESP(p) end
        if config.bigHeads or config.hitboxes then setBigHeads(config.bigHeads or config.hitboxes, p) end
    end)
end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end

-- ============================================================
-- БОЛЬШИЕ ГОЛОВЫ / ХИТБОКСЫ
-- ============================================================
local function setBigHeads(state, onlyPlayer)
    local list = onlyPlayer and {onlyPlayer} or Players:GetPlayers()
    for _, plr in ipairs(list) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
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
-- KILL AURA (через RemoteEvent, а не TakeDamage)
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
                if d < dist then closest, dist = plr, d end
            end
        end
    end
    return closest
end

-- Ищем подходящий RemoteEvent для удара
local function findPunchEvent()
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("melee") or n:find("punch") or n:find("hit") or n:find("attack") then
                return v
            end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not config.killAura then return end
    local target = getClosestPlayer(15)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local ev = findPunchEvent()
    if ev then
        pcall(function() ev:FireServer(hum) end)
    end
end)

-- ============================================================
-- PUNCH SPEED / DAMAGE (через RemoteEvent, если есть параметры)
-- ============================================================
-- ВНИМАНИЕ: точные аргументы зависят от игры.
-- Здесь — попытка найти ивент и отправить усиленные значения.
local function firePunchEvent(speed, damage)
    local ev = findPunchEvent()
    if ev then
        pcall(function()
            ev:FireServer(speed, damage)
        end)
    end
end
local function setPunchSpeed(state)
    -- при включении отправляем ускорение, при выключении — норму
    firePunchEvent(state and 0.1 or 0.5, nil)
end
local function setPunchDamage(state)
    firePunchEvent(nil, state and 999 or 10)
end

-- ============================================================
-- МЕНЮ (тач + порог перетаскивания, исправленный moved)
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FC_Menu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 320)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Text = "👁"
toggleBtn.TextSize = 26
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local function onClick(btn, fn) btn.Activated:Connect(fn) end

local function makeDraggable(obj, handle)
    local dragging, dragInput, dragStart, startPos, moved = false, nil, nil, nil, false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false -- ВАЖНО: сбрасываем перед новым драгом
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                moved = true
                obj.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    return function() return moved end
end

local btnMoved = makeDraggable(toggleBtn, toggleBtn)
makeDraggable(frame, frame)

onClick(toggleBtn, function()
    if not btnMoved() then frame.Visible = not frame.Visible end
end)

local function addButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    onClick(btn, callback)
    return btn
end

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
