-- Halloween Candy Farm + Key UI
-- Key gate is client-side only; it does NOT verify Loot-Link completion.
-- Accepted keys: 41495090, 1563757714
-- GET KEY copies/opens the Loot-Link URL.

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local VALID_KEYS = {
    ["41495090"] = true,
    ["1563757714"] = true,
}
local LOOT_LINK = "https://loot-link.com/s?MbfCj5Mg"
local unlocked = false

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "HalloweenKeyGate"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.DisplayOrder = 999999
keyGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(340, 220)
frame.Position = UDim2.new(0.5, -170, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(24, 18, 38)
frame.BorderSizePixel = 0
frame.Parent = keyGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(164, 91, 255)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "HALLOWEEN CANDY FARM"
title.TextColor3 = Color3.fromRGB(215, 180, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 22)
subtitle.Position = UDim2.fromOffset(12, 48)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Enter your key to continue"
subtitle.TextColor3 = Color3.fromRGB(205, 195, 220)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.Parent = frame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -32, 0, 36)
keyBox.Position = UDim2.fromOffset(16, 76)
keyBox.BackgroundColor3 = Color3.fromRGB(42, 32, 60)
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Enter key..."
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.PlaceholderColor3 = Color3.fromRGB(160, 145, 175)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.Parent = frame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 7)

local function makeButton(text, x, width, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(width, 34)
    button.Position = UDim2.fromOffset(x, 122)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    return button
end

local unlockButton = makeButton("UNLOCK", 16, 148, Color3.fromRGB(126, 66, 205))
local getKeyButton = makeButton("GET KEY", 176, 148, Color3.fromRGB(65, 48, 91))

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 28)
status.Position = UDim2.fromOffset(12, 164)
status.BackgroundTransparency = 1
status.Text = "Get a key, then enter it above."
status.TextColor3 = Color3.fromRGB(180, 165, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.Parent = frame

-- Drag window by its background/title.
local dragging, dragInput, dragStart, startPos
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
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

getKeyButton.MouseButton1Click:Connect(function()
    local copied = false
    if typeof(setclipboard) == "function" then
        copied = pcall(setclipboard, LOOT_LINK)
    end
    pcall(function()
        GuiService:OpenBrowserWindow(LOOT_LINK)
    end)
    if copied then
        status.Text = "Link copied! Complete the steps and get your key."
    else
        status.Text = "Opened key link (if supported). If not, copy the link from the script."
    end
    status.TextColor3 = Color3.fromRGB(220, 200, 255)
end)

unlockButton.MouseButton1Click:Connect(function()
    if VALID_KEYS[keyBox.Text:gsub("%s+", "")] then
        unlocked = true
        status.Text = "Key accepted! Starting farm..."
        status.TextColor3 = Color3.fromRGB(130, 255, 170)
    else
        status.Text = "Invalid key. Check it and try again."
        status.TextColor3 = Color3.fromRGB(255, 120, 130)
    end
end)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        unlockButton:Activate()
    end
end)

repeat task.wait() until unlocked
keyGui:Destroy()


-- Halloween Candy Farm | LocalScript / executor
-- Автосбор 60 конфет, автоматический ResetHunt, полёт, noclip, скорость и перетаскиваемое GUI.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAX_SPEED = 500
local currentSpeed = 250
local running = false
local savedCollisions = {}
local noclipConnection
local flightObjects = {}
local closing = false

-- Anti-AFK: реагирует на событие бездействия Roblox.
-- Может не работать в executor-средах, где VirtualUser ограничен.
local antiAfkConnection
local antiAfkEnabled = true

local function startAntiAfk()
    if antiAfkConnection then return end
    antiAfkConnection = player.Idled:Connect(function()
        if not antiAfkEnabled then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

local function stopAntiAfk()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

startAntiAfk()

local points = {
    {291.08,3.34,94.45},{268.23,2.34,63.29},
    {186.81,2.54,195.68},{109.86,2.34,145.81},
    {60.48,1.97,205.02},{2.82,22.55,241.14},
    {-2.68,2.34,235.53},{-1.95,-0.52,155.14},
    {-0.75,16.68,106.23},{-20.76,14.03,97.45},
    {-25.66,4.89,46.90},{-28.10,2.35,-17.02},
    {-60.65,2.34,-30.73},{-72.18,2.35,-104.97},
    {-126.77,2.34,-108.14},{-218.12,2.34,-98.67},
    {-243.56,24.74,-114.39},{-263.65,27.77,-189.50},
    {-190.58,2.34,-26.32},{-158.64,2.34,7.11},
    {-188.27,2.29,96.28},{-174.75,35.57,111.89},
    {-254.57,3.23,95.31},{-341.60,3.23,29.81},
    {-357.99,3.95,-3.36},{-496.91,2.34,16.04},
    {-517.18,2.34,69.10},{-394.92,2.34,155.52},
    {-292.73,2.34,212.79},{-297.31,2.34,257.59},
    {-248.25,2.34,292.49},{-194.97,2.33,301.78},
    {-190.61,18.65,293.75},{-96.13,2.34,243.08},
    {-104.73,-51.49,237.52},{-58.19,-52.31,221.39},
    {133.41,3.55,283.72},{54.49,32.97,395.91},
    {-143.28,1.97,608.65},{-218.91,-0.54,694.55},
    {62.23,1.97,695.11},{240.58,2.59,825.11},
    {414.73,32.94,478.93},{455.44,1.95,-13.96},
    {250.08,23.79,-190.47},{196.93,2.34,-114.42},
    {124.86,2.34,-145.52},{62.52,1.97,-142.16},
    {-0.82,2.35,-102.15},{30.34,2.34,-29.38},
    {64.01,1.97,-56.15},{359.62,64.97,-498.48},
    {1028.53,2,-54.06},{-473.88,2.34,302.13},
    {-476.49,2.34,435.01},{-588.84,141.70,-59.60},
    {-546.42,32.41,-119.41},{-242.32,1.94,985.83},
    {-383.89,1.94,1324.81},{141.18,3.15,-1470.95},
}

local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:FindFirstChildOfClass("Humanoid"),
        char:FindFirstChild("HumanoidRootPart")
end

local function animate(obj, duration, props, style, direction)
    if not obj or not obj.Parent then return end
    local tw = TweenService:Create(obj, TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    ), props)
    tw:Play()
    return tw
end

-- GUI
local oldGui = playerGui:FindFirstChild("HalloweenCandyFarm")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HalloweenCandyFarm"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.AnchorPoint = Vector2.zero
frame.Position = UDim2.fromOffset(25, 160)
frame.Size = UDim2.fromOffset(310, 255)
frame.BackgroundColor3 = Color3.fromRGB(30, 12, 47)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local outline = Instance.new("UIStroke", frame)
outline.Color = Color3.fromRGB(180, 60, 255)
outline.Thickness = 2

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(8, 8)
title.Size = UDim2.new(1, -16, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(75, 25, 100)
title.Text = "🍬  HALLOWEEN FARM"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Active = true
title.Selectable = false
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 9)

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(10, 55)
status.Size = UDim2.new(1, -20, 0, 25)
status.BackgroundTransparency = 1
status.Text = "Готов к запуску"
status.TextColor3 = Color3.fromRGB(225,205,255)
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Position = UDim2.fromOffset(10, 81)
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: 250"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = frame

local function makeButton(text, size, pos, color, parent, z)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Active = true
    b.ZIndex = z or 2
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local normalSize = size
    b.MouseEnter:Connect(function()
        animate(b, 0.12, {
            BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.13)
        })
    end)
    b.MouseLeave:Connect(function()
        animate(b, 0.12, {
            BackgroundColor3 = color,
            Size = normalSize
        })
    end)
    b.Activated:Connect(function()
        animate(b, 0.06, {
            Size = UDim2.new(
                normalSize.X.Scale, normalSize.X.Offset - 3,
                normalSize.Y.Scale, normalSize.Y.Offset - 2
            )
        })
        task.delay(0.07, function()
            if b.Parent then animate(b, 0.1, {Size = normalSize}) end
        end)
    end)
    return b
end

local minus = makeButton("-25", UDim2.fromOffset(65,34),
    UDim2.fromOffset(12,111), Color3.fromRGB(87,39,125), frame)

local plus = makeButton("+25", UDim2.fromOffset(65,34),
    UDim2.fromOffset(82,111), Color3.fromRGB(87,39,125), frame)

local maxButton = makeButton("MAX 500", UDim2.fromOffset(133,34),
    UDim2.fromOffset(153,111), Color3.fromRGB(125,35,165), frame)

local startButton = makeButton("▶  ЗАПУСТИТЬ АВТОФАРМ",
    UDim2.new(1,-24,0,38), UDim2.fromOffset(12,155),
    Color3.fromRGB(35,165,70), frame)

local closeButton = makeButton("Закрыть",
    UDim2.new(1,-24,0,32), UDim2.fromOffset(12,201),
    Color3.fromRGB(130,39,51), frame)

-- Подтверждение закрытия
local overlay = Instance.new("TextButton")
overlay.Name = "Overlay"
overlay.Size = UDim2.fromScale(1,1)
overlay.Position = UDim2.fromScale(0,0)
overlay.BackgroundColor3 = Color3.new(0,0,0)
overlay.BackgroundTransparency = 1
overlay.Text = ""
overlay.Visible = false
overlay.Active = true
overlay.AutoButtonColor = false
overlay.BorderSizePixel = 0
overlay.ZIndex = 20
overlay.Parent = gui

local dialog = Instance.new("Frame")
dialog.AnchorPoint = Vector2.new(0.5,0.5)
dialog.Position = UDim2.fromScale(0.5,0.5)
dialog.Size = UDim2.fromOffset(260,125)
dialog.BackgroundColor3 = Color3.fromRGB(43,17,61)
dialog.BorderSizePixel = 0
dialog.Visible = false
dialog.ZIndex = 21
dialog.Parent = overlay
Instance.new("UICorner", dialog).CornerRadius = UDim.new(0,12)
local dialogStroke = Instance.new("UIStroke", dialog)
dialogStroke.Color = Color3.fromRGB(190,75,255)
dialogStroke.Thickness = 2

local question = Instance.new("TextLabel")
question.Size = UDim2.new(1,-16,0,50)
question.Position = UDim2.fromOffset(8,8)
question.BackgroundTransparency = 1
question.Text = "Точно закрыть автофарм?"
question.TextColor3 = Color3.new(1,1,1)
question.TextSize = 16
question.Font = Enum.Font.GothamBold
question.ZIndex = 22
question.Parent = dialog

local yes = makeButton("Да", UDim2.fromOffset(105,36),
    UDim2.fromOffset(18,75), Color3.fromRGB(175,45,55), dialog, 22)
local no = makeButton("Нет", UDim2.fromOffset(105,36),
    UDim2.fromOffset(137,75), Color3.fromRGB(45,155,80), dialog, 22)

-- Надёжное перетаскивание окна: удерживай ЛКМ или ПКМ на заголовке.
-- Обрабатываем InputChanged на UserInputService, а начальную позицию
-- фиксируем только в момент нажатия, чтобы окно не прыгало.
local dragging = false
local dragStart = nil
local startPos = nil
local dragButton = nil

title.InputBegan:Connect(function(input)
    local kind = input.UserInputType
    if kind == Enum.UserInputType.MouseButton1
    or kind == Enum.UserInputType.MouseButton2 then
        if overlay.Visible then return end
        dragging = true
        dragButton = kind
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = input.Position
        local delta = currentPos - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if dragging and input.UserInputType == dragButton then
        dragging = false
        dragStart = nil
        startPos = nil
        dragButton = nil
    end
end)

-- Noclip
local function setNoclip(enabled)
    if enabled then
        if noclipConnection then return end
        noclipConnection = RunService.Stepped:Connect(function()
            if not running then return end
            local char = player.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if savedCollisions[part] == nil then
                        savedCollisions[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for part, old in pairs(savedCollisions) do
            if part and part.Parent then part.CanCollide = old end
        end
        table.clear(savedCollisions)
    end
end

local function stopFlight()
    for _, object in ipairs(flightObjects) do
        if object and object.Parent then object:Destroy() end
    end
    table.clear(flightObjects)

    local _, humanoid, root = getCharacter()
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function flyTo(destination)
    if not running then return false end
    local _, humanoid, root = getCharacter()
    if not humanoid or not root then return false end

    if humanoid.Sit or humanoid.SeatPart then
        humanoid.Sit = false
        humanoid.Jump = true
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.4)
    end

    stopFlight()
    _, humanoid, root = getCharacter()
    if not humanoid or not root then return false end

    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e9,1e9,1e9)
    bp.P = 30000
    bp.D = 1500
    bp.Position = root.Position
    bp.Parent = root

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.P = 20000
    bg.D = 1000
    bg.CFrame = root.CFrame
    bg.Parent = root

    table.insert(flightObjects,bp)
    table.insert(flightObjects,bg)
    humanoid.PlatformStand = true

    local target = destination + Vector3.new(0,2,0)
    local duration = math.max((root.Position-target).Magnitude/currentSpeed,0.2)
    local flightTween = TweenService:Create(
        bp,
        TweenInfo.new(duration,Enum.EasingStyle.Linear),
        {Position=target}
    )
    flightTween:Play()

    local start = os.clock()
    while running and root.Parent and os.clock()-start < duration+5 do
        if humanoid.Sit or humanoid.SeatPart then
            humanoid.Sit = false
            humanoid.Jump = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        if (root.Position-target).Magnitude < 4 then break end
        task.wait(0.05)
    end

    flightTween:Cancel()
    return running
end

-- Получить текущий текст счётчика конфет именно в Halloween-меню.
local function getCandyCounter()
    local handler = playerGui:FindFirstChild("MainGUIHandler")
    local menu = handler and handler:FindFirstChild("Halloween2026Menu")
    local bottom = menu and menu:FindFirstChild("Bottom")
    local candyFound = bottom and bottom:FindFirstChild("CandyFound")
    local count = candyFound and candyFound:FindFirstChild("Frame")
    count = count and count:FindFirstChild("Count")

    if count and count:IsA("TextLabel") then
        return string.gsub(count.Text, "%s+", "")
    end

    -- Резервный поиск, если разработчики поменяли структуру интерфейса.
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and string.find(obj.Text, "/", 1, true) then
            if string.match(obj.Text, "^%s*60%s*/%s*60%s*$") then
                return "60/60"
            end
        end
    end
    return nil
end

local function has60Counter()
    return getCandyCounter() == "60/60"
end

-- Нажать точную кнопку ResetHunt.
-- Пробуем несколько стандартных способов вызова GUI-событий: некоторые
-- интерфейсы игры слушают Activated, другие MouseButton1Click.
local function activateGuiButton(button)
    if not button or not button:IsA("GuiButton") then
        return false
    end

    local didCall = false

    pcall(function()
        button:Activate()
        didCall = true
    end)

    -- Эти сигналы доступны в большинстве executor-сред.
    if typeof(firesignal) == "function" then
        pcall(function()
            firesignal(button.Activated)
            didCall = true
        end)
        if button:IsA("TextButton") then
            pcall(function()
                firesignal(button.MouseButton1Click)
                didCall = true
            end)
        elseif button:IsA("ImageButton") then
            pcall(function()
                firesignal(button.MouseButton1Click)
                didCall = true
            end)
        end
    end

    return didCall
end

local function findResetButton()
    local handler = playerGui:FindFirstChild("MainGUIHandler")
    local menu = handler and handler:FindFirstChild("Halloween2026Menu")
    local bottom = menu and menu:FindFirstChild("Bottom")
    local button = bottom and bottom:FindFirstChild("ResetHunt")
    if button and button:IsA("GuiButton") then
        return button
    end

    -- Резервный поиск по точному имени во всём PlayerGui.
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj.Name == "ResetHunt" and obj:IsA("GuiButton") then
            return obj
        end
    end
    return nil
end

local function pressRespawn()
    local button = findResetButton()
    if not button then
        status.Text = "ResetHunt не найдена"
        return false
    end

    if not button.Visible or not button.Active then
        status.Text = "ResetHunt скрыта или неактивна"
        return false
    end

    local ok = activateGuiButton(button)
    if not ok then
        status.Text = "Не удалось нажать ResetHunt"
        return false
    end
    return true
end

-- Иногда после ResetHunt игра показывает отдельное подтверждение.
-- Ищем только видимые кнопки с подходящими словами и нажимаем не больше одной.
local function clickResetConfirmation()
    local keywords = {"confirm", "yes", "respawn", "reset", "перезап", "подтверд", "да"}
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("GuiButton") and obj.Visible and obj.Active then
            local pieces = {obj.Name or ""}
            if obj:IsA("TextButton") then
                table.insert(pieces, obj.Text or "")
            end
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    table.insert(pieces, child.Text or "")
                    table.insert(pieces, child.Name or "")
                end
            end
            local combined = string.lower(table.concat(pieces, " "))
            for _, word in ipairs(keywords) do
                if string.find(combined, word, 1, true) then
                    local resetButton = findResetButton()
                    if obj ~= resetButton and activateGuiButton(obj) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function stopFarm()
    running = false
    stopFlight()
    setNoclip(false)
    status.Text = "Остановлен"
    startButton.Text = "▶  ЗАПУСТИТЬ АВТОФАРМ"
    startButton.BackgroundColor3 = Color3.fromRGB(35,165,70)
end

local function startFarm()
    if running then return end
    running = true
    setNoclip(true)
    startButton.Text = "■  ОСТАНОВИТЬ"
    startButton.BackgroundColor3 = Color3.fromRGB(180,45,55)

    task.spawn(function()
        while running do
            -- Собрать весь маршрут.
            for i, p in ipairs(points) do
                if not running then break end
                status.Text = "Маршрут: "..i.."/"..#points
                if not flyTo(Vector3.new(p[1],p[2],p[3])) then break end
                task.wait(0.5)
            end

            if not running then break end

            -- Подождать, пока счётчик обновится до 60/60.
            status.Text = "Ожидание 60/60..."
            local deadline = os.clock() + 12
            while running and os.clock() < deadline and not has60Counter() do
                task.wait(0.25)
            end

            if not running then break end

            if has60Counter() then
                status.Text = "60/60 — ресет конфет..."
                local clicked = pressRespawn()

                if clicked then
                    -- Не кликаем повторно каждую секунду: ждём, пока
                    -- счётчик сбросится после нажатия.
                    local resetDeadline = os.clock() + 10
                    while running and os.clock() < resetDeadline and has60Counter() do
                        task.wait(0.25)
                    end

                    if has60Counter() then
                        status.Text = "Пробую подтвердить ресет..."
                        local foundConfirm = clickResetConfirmation()
                        if foundConfirm then
                            local confirmDeadline = os.clock() + 8
                            while running and os.clock() < confirmDeadline and has60Counter() do
                                task.wait(0.25)
                            end
                        end

                        if has60Counter() then
                            status.Text = "ResetHunt нажата, но счётчик не сбросился"
                            task.wait(3)
                        else
                            status.Text = "Конфеты сброшены — новый круг"
                            task.wait(1)
                        end
                    else
                        status.Text = "Конфеты сброшены — новый круг"
                        task.wait(1)
                    end
                else
                    task.wait(2)
                end
            else
                status.Text = "Не увидел 60/60 — новый круг"
                task.wait(1)
            end
        end

        stopFlight()
        setNoclip(false)
        if not running then status.Text = "Остановлен" end
        startButton.Text = "▶  ЗАПУСТИТЬ АВТОФАРМ"
        startButton.BackgroundColor3 = Color3.fromRGB(35,165,70)
    end)
end

-- Скорость
minus.Activated:Connect(function()
    currentSpeed = math.clamp(currentSpeed-25,5,MAX_SPEED)
    speedLabel.Text = "Скорость: "..currentSpeed
end)

plus.Activated:Connect(function()
    currentSpeed = math.clamp(currentSpeed+25,5,MAX_SPEED)
    speedLabel.Text = "Скорость: "..currentSpeed
end)

maxButton.Activated:Connect(function()
    currentSpeed = MAX_SPEED
    speedLabel.Text = "Скорость: 500"
end)

startButton.Activated:Connect(function()
    if running then stopFarm() else startFarm() end
end)

closeButton.Activated:Connect(function()
    overlay.Visible = true
    overlay.Size = UDim2.fromScale(1,1)
    overlay.Position = UDim2.fromScale(0,0)
    overlay.BackgroundTransparency = 1
    dialog.Visible = true
    dialog.Size = UDim2.fromOffset(0,0)
    animate(overlay,0.2,{BackgroundTransparency=0.4})
    animate(dialog,0.25,{Size=UDim2.fromOffset(260,125)},
        Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end)

no.Activated:Connect(function()
    local tw = animate(dialog,0.15,{Size=UDim2.fromOffset(0,0)},
        Enum.EasingStyle.Back,Enum.EasingDirection.In)
    if tw then tw.Completed:Wait() end
    dialog.Visible = false
    overlay.Visible = false
end)

yes.Activated:Connect(function()
    if closing then return end
    closing = true
    stopFarm()
    local tw = animate(frame,0.25,{
        Size=UDim2.fromOffset(0,0),
        BackgroundTransparency=1
    },Enum.EasingStyle.Back,Enum.EasingDirection.In)
    if tw then tw.Completed:Wait() end
    gui:Destroy()
end)

-- Автопрыжок, если персонаж сел.
local seatConnection
local function watchCharacter(char)
    if seatConnection then seatConnection:Disconnect() end
    local humanoid = char:WaitForChild("Humanoid",10)
    if not humanoid then return end

    seatConnection = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if running and humanoid.Sit then
            humanoid.Sit = false
            humanoid.Jump = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

if player.Character then watchCharacter(player.Character) end
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    watchCharacter(char)
    if running then setNoclip(true) end
end)

-- Анимация появления
frame.Size = UDim2.fromOffset(0,0)
frame.BackgroundTransparency = 1
animate(frame,0.35,{
    Size=UDim2.fromOffset(310,255),
    BackgroundTransparency=0
},Enum.EasingStyle.Back,Enum.EasingDirection.Out)

print("Halloween Candy Farm загружен. Координат:",#points)
print("Перетаскивание: удерживай ЛКМ или ПКМ на фиолетовом заголовке.")
print("Anti-AFK включён (если VirtualUser поддерживается executor).")
