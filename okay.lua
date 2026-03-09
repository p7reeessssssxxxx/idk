
local Players   = game:GetService("Players")
local TweenSvc  = game:GetService("TweenService")
local CoreGui   = game:GetService("CoreGui")
local MktSvc    = game:GetService("MarketplaceService")
local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
--               CONFIGURATION
-- Auto-creates FakePurchase/config.txt in your executors workspace
-- Edit the number to change the balance of your robux 
----------------------------------------------------------------
local CONFIG_FOLDER = "FakePurchase"
local CONFIG_FILE   = CONFIG_FOLDER .. "/config.txt"
local DEFAULT_CONFIG = [[return {
    RobuxBalance = 10000,   -- fake robux balance change to any amount (realistic is the best)
}]]

local _cfg = {}
if makefolder and writefile and readfile and isfile and isfolder then
    -- create folder on first run
    if not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
    -- create config file on first run
    if not isfile(CONFIG_FILE) then
        writefile(CONFIG_FILE, DEFAULT_CONFIG)
        print("[FakePurchase] Created config at " .. CONFIG_FILE)
    end
    -- load config
    local ok, result = pcall(function()
        return loadstring(readfile(CONFIG_FILE))()
    end)
    if ok and type(result) == "table" then
        _cfg = result
    else
        warn("[FakePurchase] Config error: " .. tostring(result))
    end
end

local robuxBalance = _cfg.RobuxBalance or 10000
local ROBUX_ICON   = "rbxassetid://102756393309336"
local function formatNumber(n)
    local s = tostring(math.floor(n))
    local result = ""
    local count = 0
    for i = #s, 1, -1 do
        if count > 0 and count % 3 == 0 then result = "," .. result end
        result = s:sub(i,i) .. result
        count = count + 1
    end
    return result
end


local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

local function showPopup(templateName, message)
    local templates = StarterGui:FindFirstChild("UITemplates")
    if not templates then return end
    local template = templates:FindFirstChild(templateName)
    if not template then return end
    local mainGUI = playerGui:FindFirstChild("MainGUI")
    if not mainGUI then return end
    local popups = mainGUI:FindFirstChild("Popups")
    if not popups then return end
    if not popups:GetAttribute("Enabled") then return end

    pcall(function() SoundService.SFX.BellRing:Play() end)

    local toast = template:Clone()
    toast.Message.Text = message
    toast.Transparency = 1
    toast.UIScale.Scale = 0
    toast.Parent = popups

    TweenSvc:Create(toast, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0}):Play()
    TweenSvc:Create(toast.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Scale = 1}):Play()
    TweenSvc:Create(toast.Message, TweenInfo.new(1, Enum.EasingStyle.Quint), {MaxVisibleGraphemes = #message}):Play()

    task.delay(4, function()
        TweenSvc:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
        TweenSvc:Create(toast.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = 0}):Play()
        task.delay(0.5, function() toast:Destroy() end)
    end)
end


local function showSuccessToast(message)
    showPopup("giftPopup", message)
end


local function showBuyToast(message)
    showPopup("successPopup", message)
end

local function fireCoinDonation(targetPlayer, amount, spawnPosition)
    local vfxRemote = game:GetService("ReplicatedStorage"):FindFirstChild("VFXObjects")
    if vfxRemote then vfxRemote = vfxRemote:FindFirstChild("CreateVfx") end
    if not vfxRemote then
        warn("[FakePurchase] VFXObjects.CreateVfx not found")
        return
    end
    local char = targetPlayer and targetPlayer.Character
    if not char then return end
    vfxRemote:FireServer("GiveCurrency", spawnPosition, char, amount)
end

local activeGui  = nil
local fo         = nil
local blockerGui = nil

local function blockFO()
    if fo then fo.Enabled = false end
    if blockerGui then blockerGui.Enabled = true end
end

local function unblockFO()
    if fo then fo.Enabled = true end
    if blockerGui then blockerGui.Enabled = false end
end

local function newLabel(props)
    local l = Instance.new("TextLabel")
    for k,v in pairs(props) do l[k] = v end
    l.BackgroundTransparency = 1
    l.TextScaled = false
    l.RichText = false
    return l
end

local function makeBaseCard(W, H)
    if activeGui then activeGui:Destroy(); activeGui = nil end

    local sg = Instance.new("ScreenGui")
    sg.Name           = "FakePurchasePrompt"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 999999
    sg.IgnoreGuiInset = true
    sg.Parent         = playerGui
    activeGui         = sg

    local overlay = Instance.new("Frame")
    overlay.Size                   = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3       = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel        = 0
    overlay.ZIndex                 = 10
    overlay.Parent                 = sg

    local card = Instance.new("Frame")
    card.Size                   = UDim2.fromOffset(W, H)
    card.AnchorPoint            = Vector2.new(0.5, 0.5)
    card.Position               = UDim2.new(0.5, 0, 0.52, 0)
    card.BackgroundColor3       = Color3.fromRGB(28, 30, 36)
    card.BackgroundTransparency = 1
    card.BorderSizePixel        = 0
    card.ZIndex                 = 11
    card.Parent                 = sg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    TweenSvc:Create(overlay, TweenInfo.new(0.18), {BackgroundTransparency=0.48}):Play()
    TweenSvc:Create(card,
        TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=0}):Play()

    return sg, card, overlay
end

local function addTopBar(card, W, titleText, showRobux)
    local title = newLabel({
        Size=UDim2.new(1,1,0,44), Position=UDim2.fromOffset(16,0),
        Text=titleText, TextColor3=Color3.fromRGB(255,255,255),
        TextSize=24, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=card
    })

    local rightRow = Instance.new("Frame")
    rightRow.BackgroundTransparency=1
    rightRow.Size=UDim2.fromOffset(0,30)
    rightRow.AutomaticSize=Enum.AutomaticSize.X
    rightRow.AnchorPoint=Vector2.new(1,0.5)
    rightRow.Position=UDim2.new(1,-20,0,22)
    rightRow.ZIndex=12; rightRow.Parent=card

    local rightLayout=Instance.new("UIListLayout")
    rightLayout.FillDirection=Enum.FillDirection.Horizontal
    rightLayout.VerticalAlignment=Enum.VerticalAlignment.Center
    rightLayout.HorizontalAlignment=Enum.HorizontalAlignment.Right
    rightLayout.Padding=UDim.new(0,8)
    rightLayout.SortOrder=Enum.SortOrder.LayoutOrder
    rightLayout.Parent=rightRow

    local bNum
    if showRobux then
        local badgeInner = Instance.new("Frame")
        badgeInner.BackgroundTransparency=1
        badgeInner.Size=UDim2.fromOffset(0,22)
        badgeInner.AutomaticSize=Enum.AutomaticSize.X
        badgeInner.ZIndex=12; badgeInner.LayoutOrder=1; badgeInner.Parent=rightRow

        local innerLayout=Instance.new("UIListLayout")
        innerLayout.FillDirection=Enum.FillDirection.Horizontal
        innerLayout.VerticalAlignment=Enum.VerticalAlignment.Center
        innerLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left
        innerLayout.Padding=UDim.new(0,4)
        innerLayout.SortOrder=Enum.SortOrder.LayoutOrder
        innerLayout.Parent=badgeInner

        local rIcon=Instance.new("ImageLabel")
        rIcon.Size=UDim2.fromOffset(16,16)
        rIcon.BackgroundTransparency=1
        rIcon.ScaleType=Enum.ScaleType.Fit
        rIcon.Image=ROBUX_ICON; rIcon.ImageColor3=Color3.fromRGB(255,255,255)
        rIcon.ZIndex=13; rIcon.LayoutOrder=1; rIcon.Parent=badgeInner

        bNum=newLabel({
            Size=UDim2.fromOffset(0,22),
            AutomaticSize=Enum.AutomaticSize.X,
            Text=formatNumber(robuxBalance),
            TextColor3=Color3.fromRGB(255,255,255),
            TextSize=15, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.None,
            ZIndex=13, Parent=badgeInner
        })
        bNum.LayoutOrder=2
    end

    local xBtn = Instance.new("ImageButton")
    xBtn.Size=UDim2.fromOffset(15,15)
    xBtn.BackgroundTransparency=1
    xBtn.BorderSizePixel=0
    xBtn.Image="rbxasset://textures/loading/cancelButton.png"
    xBtn.ImageColor3=Color3.fromRGB(200,202,215)
    xBtn.ZIndex=12; xBtn.LayoutOrder=2; xBtn.Parent=rightRow
    xBtn.MouseEnter:Connect(function()
        TweenSvc:Create(xBtn,TweenInfo.new(0.08),{ImageColor3=Color3.fromRGB(255,255,255)}):Play()
    end)
    xBtn.MouseLeave:Connect(function()
        TweenSvc:Create(xBtn,TweenInfo.new(0.08),{ImageColor3=Color3.fromRGB(200,202,215)}):Play()
    end)

    return xBtn, bNum
end

local function addBlueButton(card, W, H, text)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.fromOffset(W-24,42)
    btn.Position=UDim2.fromOffset(12,H-54)
    btn.BackgroundColor3=Color3.fromRGB(51,95,255)
    btn.BorderSizePixel=0
    btn.Text=text
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.TextSize=15; btn.Font=Enum.Font.GothamBold
    btn.ZIndex=12; btn.Parent=card
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(75,128,255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(57,111,245)}):Play()
    end)
    return btn
end

local function makeCloseFunc(sg, card, overlay, onClose)
    local closed = false
    return function()
        if closed then return end
        closed = true
        activeGui = nil
        if onClose then onClose() end
        if blockerGui then blockerGui.Enabled = false end
        TweenSvc:Create(overlay,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play()
        TweenSvc:Create(card,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play()
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                TweenSvc:Create(d,TweenInfo.new(0.15),{ImageTransparency=1}):Play()
            end
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                TweenSvc:Create(d,TweenInfo.new(0.15),{TextTransparency=1}):Play()
            end
            if d:IsA("Frame") then
                TweenSvc:Create(d,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play()
            end
        end
        local t = TweenSvc:Create(card,TweenInfo.new(0.15),{
            Position=UDim2.new(0.5,0,0.52,0),
        })
        t:Play()
        t.Completed:Once(function() if sg.Parent then sg:Destroy() end end)
    end, function() return closed end
end


local function showPurchaseComplete(itemName)
    blockFO()
    local W,H = 456,230
    local sg,card,overlay = makeBaseCard(W,H)
    local xBtn = addTopBar(card, W, "Purchase completed", false)
    local okBtn = addBlueButton(card, W, H, "OK")

    local ringBg = Instance.new("Frame")
    ringBg.Size=UDim2.fromOffset(48,48)
    ringBg.AnchorPoint=Vector2.new(0.5,0)
    ringBg.Position=UDim2.new(0.5,0,0,72)
    ringBg.BackgroundColor3=Color3.fromRGB(28,30,36)
    ringBg.BorderSizePixel=0; ringBg.ZIndex=12; ringBg.Parent=card
    Instance.new("UICorner",ringBg).CornerRadius=UDim.new(1,0)

    local ring = Instance.new("ImageLabel")
    ring.Size=UDim2.new(1,0,1,0)
    ring.BackgroundTransparency=1
    ring.BorderSizePixel=0
    ring.Image="rbxassetid://110348019216278"
    ring.ImageColor3=Color3.fromRGB(255,255,255)
    ring.ScaleType=Enum.ScaleType.Fit
    ring.ZIndex=13; ring.Parent=ringBg

    newLabel({
        Size=UDim2.new(1,-32,0,44),
        AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,120),
        Text="You have successfully bought "..itemName..".",
        TextColor3=Color3.fromRGB(190,192,205),
        TextSize=13, Font=Enum.Font.Gotham,
        TextWrapped=true, ZIndex=12, Parent=card
    })

    local close, isClosed = makeCloseFunc(sg, card, overlay, nil)
    xBtn.MouseButton1Click:Connect(close)
    okBtn.MouseButton1Click:Connect(function()
        TweenSvc:Create(okBtn,TweenInfo.new(0.08),{BackgroundTransparency=0.3}):Play()
        task.delay(0.12, function()
            close()
            task.delay(0.2, function()
                showSuccessToast("sent gift!")
            end)
        end)
    end)
end


local function showFakePrompt(itemName, itemPrice, thumbImage, onClose)
    local W,H = 420,215
    local sg,card,overlay = makeBaseCard(W,H)
    local xBtn, bNum = addTopBar(card, W, "Buy item", true)

    local THUMB=80
    local ROW_Y=37
    local ITEM_AREA=H-46-54
    local THUMB_Y = ROW_Y + math.floor((ITEM_AREA-THUMB)/2)

    local tBox=Instance.new("Frame")
    tBox.Size=UDim2.fromOffset(THUMB,THUMB)
    tBox.Position=UDim2.fromOffset(20,THUMB_Y)
    tBox.BackgroundColor3=Color3.fromRGB(18,20,26)
    tBox.BorderSizePixel=0; tBox.ZIndex=12; tBox.Parent=card
    Instance.new("UICorner",tBox).CornerRadius=UDim.new(0,6)

    local tImg=Instance.new("ImageLabel")
    tImg.Size=UDim2.new(1,-4,1,-4)
    tImg.Position=UDim2.fromOffset(2,2)
    tImg.BackgroundTransparency=1
    tImg.Image=thumbImage
    tImg.ScaleType=Enum.ScaleType.Fit
    tImg.ZIndex=13; tImg.Parent=tBox

    local TX=20+THUMB+14
    newLabel({
        Size=UDim2.fromOffset(W-TX-14,22),
        Position=UDim2.fromOffset(TX,THUMB_Y+8),
        Text=itemName,
        TextColor3=Color3.fromRGB(255,255,255),
        TextSize=16, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
        ZIndex=12, Parent=card
    })

    local pRow=Instance.new("Frame")
    pRow.Size=UDim2.fromOffset(100,18)
    pRow.Position=UDim2.fromOffset(TX,THUMB_Y+34)
    pRow.BackgroundTransparency=1; pRow.ZIndex=12; pRow.Parent=card

    local pI=Instance.new("ImageLabel")
    pI.Size=UDim2.fromOffset(16,16)
    pI.AnchorPoint=Vector2.new(0,0.5)
    pI.Position=UDim2.fromOffset(0,9)
    pI.BackgroundTransparency=1
    pI.ScaleType=Enum.ScaleType.Fit
    pI.Image=ROBUX_ICON; pI.ImageColor3=Color3.fromRGB(255,255,255); pI.ZIndex=13; pI.Parent=pRow

    newLabel({
        Size=UDim2.fromOffset(120,18),
        Position=UDim2.fromOffset(22,0),
        Text=formatNumber(tonumber(itemPrice) or 0),
        TextColor3=Color3.fromRGB(255,255,255),
        TextSize=15, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=13, Parent=pRow
    })

    
    local btnX = 12
    local btnY = H - 54
    local btnW = W - 24
    local btnH = 42

    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.fromOffset(btnW, btnH)
    buyBtn.Position = UDim2.fromOffset(btnX, btnY)
    buyBtn.BackgroundColor3 = Color3.fromRGB(51, 95, 255)
    buyBtn.BorderSizePixel = 0
    buyBtn.AutoButtonColor = false
    buyBtn.Text = ""
    buyBtn.ZIndex = 12
    buyBtn.Parent = card
    Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 8)

    buyBtn.ClipsDescendants = false

    local sweep = Instance.new("Frame")
    sweep.Size = UDim2.fromOffset(btnW, btnH)
    sweep.AnchorPoint = Vector2.new(1, 0)
    sweep.Position = UDim2.fromOffset(btnX + btnW, btnY)
    sweep.BackgroundColor3 = Color3.fromRGB(38, 61, 143)
    sweep.BackgroundTransparency = 0
    sweep.BorderSizePixel = 0
    sweep.ZIndex = 13
    sweep.Parent = card
    Instance.new("UICorner", sweep).CornerRadius = UDim.new(0, 8)



    TweenSvc:Create(sweep,
        TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(0, btnH) }
    ):Play()

    
    local buyText = Instance.new("TextLabel")
    buyText.Size = UDim2.fromOffset(btnW, btnH)
    buyText.Position = UDim2.fromOffset(btnX, btnY)
    buyText.BackgroundTransparency = 1
    buyText.Text = "Buy"
    buyText.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyText.TextSize = 15
    buyText.Font = Enum.Font.GothamBold
    buyText.ZIndex = 20
    buyText.Parent = card

    local close, isClosed = makeCloseFunc(sg, card, overlay, onClose)
    local buying = false

    xBtn.MouseButton1Click:Connect(close)

    buyBtn.MouseButton1Click:Connect(function()
        if buying or isClosed() then return end
        buying = true
        task.delay(0.08, function()
            if isClosed() then return end
            local price = tonumber(itemPrice) or 0
            robuxBalance = math.max(0, robuxBalance - price)
            if bNum then bNum.Text = formatNumber(robuxBalance) end
            close()
            task.delay(0.2, function()
                showPurchaseComplete(itemName)
            end)
            task.delay(0.3, function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    fireCoinDonation(player, price, hrp.Position + Vector3.new(0, 5, 0))
                end
            end)
            task.delay(0.4, function()
                showBuyToast("You purchased " .. itemName .. "!")
            end)
        end)
    end)
end


local hookedButtons = {}

local function hookItemButton(btn)
    if hookedButtons[btn] then return end
    hookedButtons[btn] = true

    local assetId = tonumber(btn.Name:match("^Item(%d+)$"))
    if not assetId then return end

    local name  = "Game Pass"
    local price = "?"
    local thumb = "rbxthumb://type=GamePass&id=" .. assetId .. "&w=150&h=150"

    task.spawn(function()
        local ok, info = pcall(MktSvc.GetProductInfo, MktSvc, assetId, Enum.InfoType.GamePass)
        if ok and info then
            name  = info.Name or name
            price = tostring(info.PriceInRobux or "?")
        end
    end)

    local lastTrigger = 0
    local function triggerFake()
        local now = tick()
        if now - lastTrigger < 0.5 then return end
        lastTrigger = now
        blockFO()
        showFakePrompt(name, price, thumb)
    end

    btn.MouseButton1Down:Connect(triggerFake)
    local pr = btn:FindFirstChild("Prompt")
    if pr and pr:IsA("RemoteEvent") then
        pr.OnClientEvent:Connect(triggerFake)
    end
end

local function watchBoothItems(boothUI)
    local function hookAll(obj)
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("TextButton") and desc.Name:match("^Item%d+$") then
                hookItemButton(desc)
            end
        end
        obj.DescendantAdded:Connect(function(desc)
            if desc:IsA("TextButton") and desc.Name:match("^Item%d+$") then
                hookItemButton(desc)
            end
        end)
    end
    hookAll(boothUI)
end



task.spawn(function()
    local RunService = game:GetService("RunService")

    local function killPrompt(obj)
        if not obj or not obj.Parent then return end
        local n = obj.Name
        if n == "PurchasePrompt" or n == "PurchasePromptApp" or n == "PurchasePromptNew" then
            pcall(function() obj.Enabled = false end)
            pcall(function()
                for _, d in ipairs(obj:GetDescendants()) do
                    pcall(function()
                        if d:IsA("ScreenGui")  then d.Enabled = false end
                        if d:IsA("Frame")      then d.BackgroundTransparency = 1 end
                        if d:IsA("TextLabel")  then d.TextTransparency = 1 end
                        if d:IsA("TextButton") then d.TextTransparency = 1; d.BackgroundTransparency = 1 end
                        if d:IsA("ImageLabel") or d:IsA("ImageButton") then d.ImageTransparency = 1 end
                    end)
                end
            end)
        end
    end

 
    RunService.Heartbeat:Connect(function()
        pcall(function()
            for _, obj in ipairs(CoreGui:GetDescendants()) do
                local n = obj.Name
                if n == "PurchasePrompt" or n == "PurchasePromptApp" or n == "PurchasePromptNew" then
                    if obj:IsA("ScreenGui") and obj.Enabled then
                        obj.Enabled = false
                    end
                end
            end
        end)
    end)

    pcall(function()
        CoreGui.DescendantAdded:Connect(killPrompt)
        for _, obj in ipairs(CoreGui:GetDescendants()) do killPrompt(obj) end
    end)
end)

task.spawn(function()
    fo = CoreGui:WaitForChild("FoundationOverlay", 30)
    if fo then
        fo.Enabled = false
        fo:GetPropertyChangedSignal("Enabled"):Connect(function()
            if fo.Enabled then
                task.defer(function() pcall(function() fo.Enabled = false end) end)
            end
        end)
    end

    blockerGui = Instance.new("ScreenGui")
    blockerGui.Name = "PurchaseBlocker"
    blockerGui.DisplayOrder = 99997
    blockerGui.IgnoreGuiInset = true
    blockerGui.ResetOnSpawn = false
    blockerGui.Enabled = false
    blockerGui.Parent = playerGui
    local bf = Instance.new("TextButton")
    bf.Size = UDim2.new(1,0,1,0)
    bf.BackgroundTransparency = 1
    bf.Text = ""; bf.ZIndex = 1; bf.Parent = blockerGui

    local mapUIContainer = playerGui:WaitForChild("MapUIContainer", 20)
    local mapUI = mapUIContainer:WaitForChild("MapUI", 10)
    local function onChild(c)
        if c.Name:match("^BoothUI") then watchBoothItems(c) end
    end
    for _, c in ipairs(mapUI:GetChildren()) do onChild(c) end
    mapUI.ChildAdded:Connect(onChild)

    print("[fake gift] Ready")
end)


local CollectionService = game:GetService("CollectionService")

local hookedItemFrames = {}
local function hookItemFrame(frame)
    if hookedItemFrames[frame] then return end
    hookedItemFrames[frame] = true

    local assetId = frame:GetAttribute("AssetId")
    if not assetId then return end

    local name  = "Game Pass"
    local price = tostring(frame:GetAttribute("AssetPrice") or "?")
    local thumb = "rbxthumb://type=GamePass&id=" .. assetId .. "&w=150&h=150"

    task.spawn(function()
        local ok, info = pcall(MktSvc.GetProductInfo, MktSvc, assetId, Enum.InfoType.GamePass)
        if ok and info then
            name  = info.Name or name
            price = tostring(info.PriceInRobux or price)
        end
    end)

    local lastTrigger = 0
    frame.Activated:Connect(function()
        local now = tick()
        if now - lastTrigger < 0.5 then return end
        lastTrigger = now
        blockFO()
        showFakePrompt(name, price, thumb)
    end)
end

for _, frame in CollectionService:GetTagged("ItemFrame") do
    hookItemFrame(frame)
end
CollectionService:GetInstanceAddedSignal("ItemFrame"):Connect(hookItemFrame)
