local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local VirtualInputManager = game:GetService("VirtualInputManager")

if not hrp then
    warn("No HumanoidRootPart found!")
    return
end

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 150)
frame.Position = UDim2.new(0.5, -130, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(230, 200, 255) -- Soft pastel purple
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.ClipsDescendants = true

-- Smooth corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 20)
uiCorner.Parent = frame

-- Glow effect
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(180, 100, 255)
uiStroke.Parent = frame

-- Start Button
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 200, 0, 40)
startButton.Position = UDim2.new(0.5, -100, 0.15, 0)
startButton.Text = "Start"
startButton.BackgroundColor3 = Color3.fromRGB(160, 100, 255) -- Soft purple
startButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
startButton.Font = Enum.Font.GothamBold
startButton.Parent = frame

-- Stop Button
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 200, 0, 40)
stopButton.Position = UDim2.new(0.5, -100, 0.45, 0)
stopButton.Text = "Stop"
stopButton.BackgroundColor3 = Color3.fromRGB(255, 120, 160) -- Soft pink
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.Parent = frame

-- Close Button (Now Round & Cute)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, -5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0) -- Fully round button
closeCorner.Parent = closeButton

-- Cute Message Label (Now Visible!)
local messageLabel = Instance.new("TextLabel")
messageLabel.Size = UDim2.new(1, -10, 0, 20)
messageLabel.Position = UDim2.new(0.5, -125, 0.85, 0)
messageLabel.Text = "n.exc"
messageLabel.BackgroundTransparency = 1
messageLabel.TextColor3 = Color3.fromRGB(120, 60, 200)
messageLabel.Font = Enum.Font.GothamBold
messageLabel.TextScaled = true
messageLabel.Parent = frame

-- Teleporting Logic
local isTeleporting = false
local teleportingCoroutine

local function startTeleporting()
    isTeleporting = true
    teleportingCoroutine = coroutine.create(function()
        local street2Parts = {}

        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") and part.Name == "Street 2" then
                table.insert(street2Parts, part)
            end
        end

        if #street2Parts == 0 then
            warn("No 'Street 2' parts found!")
            isTeleporting = false
            return
        end

        local index = 1
        while isTeleporting do
            local currentPart = street2Parts[index]

            -- Check if the part still exists
            if not currentPart or not currentPart.Parent then
                -- Move to the next part if the current part is missing
                index = (index % #street2Parts) + 1
                continue
            end

            local targetPosition = currentPart.CFrame.Position + Vector3.new(0, -6, 0)
            local teleportStartTime = tick()

            while tick() - teleportStartTime < 105 and isTeleporting do
                -- Teleport to the current spot
                hrp.CFrame = CFrame.new(targetPosition)

                -- Press "Q"
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

                task.wait(0.05)
            end

            -- After teleporting for 105 seconds, move to the next part
            index = (index % #street2Parts) + 1
        end
    end)
    coroutine.resume(teleportingCoroutine)
end

local function stopTeleporting()
    isTeleporting = false
    if teleportingCoroutine then
        coroutine.close(teleportingCoroutine)
    end
end

local function closeGui()
    screenGui:Destroy()
end

-- Dragging Logic
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Button Actions
startButton.MouseButton1Click:Connect(function()
    if not isTeleporting then
        startTeleporting()
    end
end)

stopButton.MouseButton1Click:Connect(function()
    if isTeleporting then
        stopTeleporting()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    closeGui()
end)
