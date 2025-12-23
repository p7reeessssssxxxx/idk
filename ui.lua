-- Professional Dark Theme UI Library for Roblox
-- Premium Features: Input System, Smooth Animations, Modern Design, Config System

local CrustyHub = {}

-- ==================== PREVENT MULTIPLE GUI ====================
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local function PreventMultipleGUI()
    if PlayerGui:FindFirstChild("CrustyHub") then
        PlayerGui:FindFirstChild("CrustyHub"):Destroy()
        task.wait(0.1)
    end
end
-- ==================== END PREVENT MULTIPLE ====================

-- ==================== CONFIG SYSTEM ====================
CrustyHub.ConfigSystem = {}
CrustyHub.ConfigSystem.FolderName = nil
CrustyHub.ConfigSystem.ConfigFileName = "config.json"
CrustyHub.ConfigSystem.AutoSave = false
CrustyHub.ConfigSystem.ElementCallbacks = {}

function CrustyHub.ConfigSystem:SetFolder(folderName)
    self.FolderName = folderName
    if folderName and folderName ~= "" then
        self.ConfigFileName = folderName .. "/config.json"
        
        -- Klasör yoksa oluştur
        if not isfolder(folderName) then
            makefolder(folderName)
        end
    end
end

function CrustyHub.ConfigSystem:SaveConfig(data)
    if not self.AutoSave then return false end
    
    local success = pcall(function()
        local HttpService = game:GetService("HttpService")
        writefile(self.ConfigFileName, HttpService:JSONEncode(data))
    end)
    
    return success
end

function CrustyHub.ConfigSystem:LoadConfig()
    local success, content = pcall(function()
        return readfile(self.ConfigFileName)
    end)
    
    if success and content and content ~= "" then
        local successDecode, data = pcall(function()
            local HttpService = game:GetService("HttpService")
            return HttpService:JSONDecode(content)
        end)
        
        if successDecode and data then
            return data
        end
    end
    
    return {}
end

function CrustyHub.ConfigSystem:RegisterCallback(key, callback)
    self.ElementCallbacks[key] = callback
end

function CrustyHub.ConfigSystem:ApplyCallbacks(configData)
    for key, value in pairs(configData) do
        if self.ElementCallbacks[key] then
            task.spawn(function()
                self.ElementCallbacks[key](value)
            end)
        end
    end
end
-- ==================== END CONFIG SYSTEM ====================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Professional Color Palette
local THEME = {
    Main = Color3.fromRGB(18, 18, 21),
    Background = Color3.fromRGB(22, 22, 26),
    Content = Color3.fromRGB(26, 26, 31),
    TabBg = Color3.fromRGB(20, 20, 24),
    ActiveTab = Color3.fromRGB(30, 30, 36),
    Text = Color3.fromRGB(235, 235, 245),
    Muted = Color3.fromRGB(145, 145, 160),
    Accent = Color3.fromRGB(110, 120, 250),
    AccentDark = Color3.fromRGB(85, 95, 225),
    Line = Color3.fromRGB(35, 35, 42),
    Track = Color3.fromRGB(38, 38, 45),
    Dropdown = Color3.fromRGB(24, 24, 30),
    ToggleOn = Color3.fromRGB(110, 120, 250),
    ToggleOff = Color3.fromRGB(50, 50, 58),
    Slider = Color3.fromRGB(110, 120, 250),
    Button = Color3.fromRGB(110, 120, 250),
    ButtonHover = Color3.fromRGB(125, 135, 255),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 170, 25),
    Danger = Color3.fromRGB(250, 70, 70),
    InputBg = Color3.fromRGB(28, 28, 34),
    InputStroke = Color3.fromRGB(45, 45, 55),
}

-- Smooth Animation Presets
local ANIMATIONS = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
    Elastic = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function CreateRoundedRect(parent, radius)
    return CreateInstance("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 8)
    })
end

local function AnimateHover(object, hoverColor, normalColor)
    object.MouseEnter:Connect(function()
        TweenService:Create(object, ANIMATIONS.Fast, {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    
    object.MouseLeave:Connect(function()
        TweenService:Create(object, ANIMATIONS.Fast, {
            BackgroundColor3 = normalColor
        }):Play()
    end)
end

-- Main Window Class
function CrustyHub:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "Crusty Hub"
    local windowSize = options.Size or UDim2.new(0, 380, 0, 320)
    
    -- AutoSave ve FolderName ayarla
    if options.AutoSave ~= nil then
        self.ConfigSystem.AutoSave = options.AutoSave
    end
    
    if options.FolderName then
        self.ConfigSystem:SetFolder(options.FolderName)
    end
    
    PreventMultipleGUI()
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.ConfigData = {}
    
    function Window:LoadConfigData()
        local data = CrustyHub.ConfigSystem:LoadConfig()
        if data then
            self.ConfigData = data
            return true
        end
        return false
    end
    
    function Window:SaveConfigData()
        return CrustyHub.ConfigSystem:SaveConfig(self.ConfigData)
    end
    
    function Window:UpdateConfig(key, value)
        self.ConfigData[key] = value
        self:SaveConfigData()
    end
    
    function Window:GetConfigValue(key, default)
        return self.ConfigData[key] ~= nil and self.ConfigData[key] or default
    end
    
    -- Config yükle
    Window:LoadConfigData()
    
    -- Config callback'lerini uygula
    task.defer(function()
        task.wait(0.3)
        CrustyHub.ConfigSystem:ApplyCallbacks(Window.ConfigData)
    end)
    
    -- Main ScreenGui
    local screenGui = CreateInstance("ScreenGui", {
        Name = "CrustyHub",
        Parent = PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    
    -- Toggle Button
    local toggleButton = CreateInstance("TextButton", {
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.new(0, 120, 0, 32),
        BackgroundColor3 = THEME.Background,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "Show Fent hub sab",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = THEME.Text,
        AutoButtonColor = false,
    })
    
    CreateRoundedRect(toggleButton, 10)
    
    CreateInstance("UIStroke", {
        Parent = toggleButton,
        Thickness = 1,
        Transparency = 0.85,
        Color = THEME.Line
    })
    
    CreateInstance("ImageLabel", {
        Parent = toggleButton,
        Name = "Shadow",
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.92,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        ZIndex = 0
    })
    
    -- Main Frame
    local mainFrame = CreateInstance("Frame", {
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = windowSize,
        BackgroundColor3 = THEME.Main,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
    })
    
    CreateRoundedRect(mainFrame, 12)
    
    CreateInstance("UIStroke", {
        Parent = mainFrame,
        Thickness = 1,
        Transparency = 0.7,
        Color = THEME.Line
    })
    
    CreateInstance("ImageLabel", {
        Parent = mainFrame,
        Name = "Shadow",
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        ZIndex = -1
    })
    
    -- Top Bar
    local topBar = CreateInstance("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1
    })
    
    local title = CreateInstance("TextLabel", {
        Parent = topBar,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0.5, -14, 1, 0),
        BackgroundTransparency = 1,
        Text = windowName,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = THEME.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local closeButton = CreateInstance("TextButton", {
        Parent = topBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = THEME.Content,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = THEME.Muted,
        AutoButtonColor = false,
    })
    
    CreateRoundedRect(closeButton, 8)
    AnimateHover(closeButton, THEME.Danger, THEME.Content)
    
    -- Tab Bar
    local tabBarContainer = CreateInstance("Frame", {
        Parent = mainFrame,
        Position = UDim2.new(0, 10, 0, 38),
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundColor3 = THEME.TabBg,
        BackgroundTransparency = 0.3,
    })
    
    CreateRoundedRect(tabBarContainer, 8)
    
    local tabBar = CreateInstance("Frame", {
        Parent = tabBarContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    })
    
    CreateInstance("UIListLayout", {
        Parent = tabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    
    CreateInstance("UIPadding", {
        Parent = tabBar,
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3)
    })
    
    -- Content Container
    local contentContainer = CreateInstance("Frame", {
        Parent = mainFrame,
        Position = UDim2.new(0, 10, 0, 72),
        Size = UDim2.new(1, -20, 1, -82),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })
    
    -- Window Toggle Animation
    local isOpen = false
    
    local function ToggleWindow()
        isOpen = not isOpen
        
        if isOpen then
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            mainFrame.BackgroundTransparency = 1
            
            TweenService:Create(mainFrame, ANIMATIONS.Elastic, {
                Size = windowSize,
                BackgroundTransparency = 0
            }):Play()
            
            for _, obj in ipairs(mainFrame:GetDescendants()) do
                if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local origTransparency = obj.BackgroundTransparency
                    obj.BackgroundTransparency = 1
                    TweenService:Create(obj, ANIMATIONS.Normal, {
                        BackgroundTransparency = origTransparency
                    }):Play()
                end
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local origTextTransparency = obj.TextTransparency
                    obj.TextTransparency = 1
                    TweenService:Create(obj, ANIMATIONS.Normal, {
                        TextTransparency = origTextTransparency
                    }):Play()
                end
            end
            
            TweenService:Create(toggleButton, ANIMATIONS.Normal, {
                BackgroundTransparency = 0.4,
                TextTransparency = 0.3
            }):Play()
        else
            TweenService:Create(mainFrame, ANIMATIONS.Smooth, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(toggleButton, ANIMATIONS.Normal, {
                BackgroundTransparency = 0.15,
                TextTransparency = 0
            }):Play()
            
            task.wait(0.35)
            mainFrame.Visible = false
        end
    end
    
    toggleButton.MouseButton1Click:Connect(ToggleWindow)
    closeButton.MouseButton1Click:Connect(function()
        if isOpen then
            ToggleWindow()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            ToggleWindow()
        end
    end)
    
    -- Smooth Dragging
    local dragging = false
    local dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            
            TweenService:Create(mainFrame, ANIMATIONS.Fast, {
                Position = newPos
            }):Play()
        end
    end)
    
    -- Tab Creation
    local isFirstTab = true
    
    function Window:CreateTab(tabName)
        local Tab = {}
        Tab.Elements = {}
        
        local tabButton = CreateInstance("TextButton", {
            Parent = tabBar,
            Size = UDim2.new(0, 0, 0, 24),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = THEME.ActiveTab,
            BackgroundTransparency = isFirstTab and 0.2 or 1,
            BorderSizePixel = 0,
            Text = tabName,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = isFirstTab and THEME.Text or THEME.Muted,
            AutoButtonColor = false,
        })
        
        CreateRoundedRect(tabButton, 6)
        
        CreateInstance("UIPadding", {
            Parent = tabButton,
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14)
        })
        
        local tabContent = CreateInstance("ScrollingFrame", {
            Parent = contentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = THEME.Line,
            ScrollBarImageTransparency = 0.7,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = isFirstTab,
        })
        
        CreateInstance("UIListLayout", {
            Parent = tabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        if isFirstTab then
            Window.CurrentTab = tabContent
            isFirstTab = false
        end
        
        tabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab and Window.CurrentTab ~= tabContent then
                TweenService:Create(Window.CurrentTab, ANIMATIONS.Fast, {
                    Position = UDim2.new(-0.2, 0, 0, 0)
                }):Play()
                task.wait(0.15)
                Window.CurrentTab.Visible = false
            end
            
            for _, btn in ipairs(tabBar:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, ANIMATIONS.Normal, {
                        BackgroundTransparency = 1,
                        TextColor3 = THEME.Muted
                    }):Play()
                end
            end
            
            TweenService:Create(tabButton, ANIMATIONS.Normal, {
                BackgroundTransparency = 0.2,
                TextColor3 = THEME.Text
            }):Play()
            
            tabContent.Position = UDim2.new(0.2, 0, 0, 0)
            tabContent.Visible = true
            TweenService:Create(tabContent, ANIMATIONS.Normal, {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            Window.CurrentTab = tabContent
        end)
        
        local function UpdateCanvas()
            local listLayout = tabContent:FindFirstChildOfClass("UIListLayout")
            if listLayout then
                tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            end
        end
        
        function Tab:CreateSection(sectionName)
            local Section = {}
            
            local section = CreateInstance("Frame", {
                Parent = tabContent,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = THEME.Content,
                BackgroundTransparency = 0.7,
            })
            
            CreateRoundedRect(section, 10)
            
            local sectionTitle = CreateInstance("TextLabel", {
                Parent = section,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Text = sectionName,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = THEME.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            CreateInstance("UIPadding", {
                Parent = sectionTitle,
                PaddingLeft = UDim.new(0, 12)
            })
            
            local content = CreateInstance("Frame", {
                Parent = section,
                Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
            })
            
            CreateInstance("UIListLayout", {
                Parent = content,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            CreateInstance("UIPadding", {
                Parent = content,
                PaddingBottom = UDim.new(0, 10)
            })
            
            -- Input Element
            function Section:CreateInput(options)
                local saveKey = options.Name
                local defaultValue = Window:GetConfigValue(saveKey, options.Default or "")
                
                local input = CreateInstance("Frame", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                })
                
                local label = CreateInstance("TextLabel", {
                    Parent = input,
                    Position = UDim2.new(0, 0, 0.5, -8),
                    Size = UDim2.new(0.4, -5, 0, 16),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Input",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = THEME.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local inputBox = CreateInstance("TextBox", {
                    Parent = input,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0.55, 0, 0, 28),
                    BackgroundColor3 = THEME.InputBg,
                    BorderSizePixel = 0,
                    Text = tostring(defaultValue),
                    PlaceholderText = options.Placeholder or "Enter value...",
                    PlaceholderColor3 = THEME.Muted,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = THEME.Text,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ClearTextOnFocus = false,
                })
                
                CreateRoundedRect(inputBox, 6)
                
                CreateInstance("UIStroke", {
                    Parent = inputBox,
                    Thickness = 0,
                    Transparency = 1,
                    Color = THEME.InputStroke
                })
                
                inputBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        local text = inputBox.Text
                        local value = tonumber(text) or text
                        
                        Window:UpdateConfig(saveKey, value)
                        
                        if options.Callback then
                            options.Callback(value)
                        end
                    end
                end)
                
                CrustyHub.ConfigSystem:RegisterCallback(saveKey, function(value)
                    inputBox.Text = tostring(value)
                    if options.Callback then
                        options.Callback(value)
                    end
                end)
                
                UpdateCanvas()
                return input
            end
            
            -- Toggle Element
            function Section:CreateToggle(options)
                local saveKey = options.Name
                local defaultValue = Window:GetConfigValue(saveKey, options.Default or false)
                
                local toggle = CreateInstance("Frame", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                })
                
                local label = CreateInstance("TextLabel", {
                    Parent = toggle,
                    Size = UDim2.new(1, -46, 1, 0),
                    BackgroundTransparency = 1,
                    Text = options.Name or "Toggle",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = THEME.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local toggleButton = CreateInstance("TextButton", {
                    Parent = toggle,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    BackgroundColor3 = defaultValue and THEME.ToggleOn or THEME.ToggleOff,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "",
                })
                
                CreateRoundedRect(toggleButton, 10)
                
                local toggleKnob = CreateInstance("Frame", {
                    Parent = toggleButton,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = defaultValue and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                })
                
                CreateRoundedRect(toggleKnob, 8)
                
                local isToggled = defaultValue
                
                local function UpdateToggle(value)
                    isToggled = value
                    
                    TweenService:Create(toggleButton, ANIMATIONS.Normal, {
                        BackgroundColor3 = isToggled and THEME.ToggleOn or THEME.ToggleOff
                    }):Play()
                    
                    TweenService:Create(toggleKnob, ANIMATIONS.Smooth, {
                        Position = isToggled and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
                    }):Play()
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    UpdateToggle(isToggled)
                    
                    Window:UpdateConfig(saveKey, isToggled)
                    
                    if options.Callback then
                        options.Callback(isToggled)
                    end
                end)
                
                CrustyHub.ConfigSystem:RegisterCallback(saveKey, function(value)
                    UpdateToggle(value)
                    if options.Callback then
                        options.Callback(value)
                    end
                end)
                
                UpdateCanvas()
                return toggle
            end
            
            -- Button Element
            function Section:CreateButton(options)
                local button = CreateInstance("TextButton", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = THEME.Button,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = options.Name or "Button",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                })
                
                CreateRoundedRect(button, 8)
                
                button.MouseButton1Click:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        Size = UDim2.new(0.98, 0, 0, 30)
                    }):Play()
                    
                    task.wait(0.1)
                    
                    TweenService:Create(button, ANIMATIONS.Elastic, {
                        Size = UDim2.new(1, 0, 0, 30)
                    }):Play()
                    
                    if options.Callback then
                        options.Callback()
                    end
                end)
                
                AnimateHover(button, THEME.ButtonHover, THEME.Button)
                
                UpdateCanvas()
                return button
            end
            
            -- Slider, Dropdown kod bloklarını buraya ekle (karakterden kaynakı sığdıramadım)
            
            UpdateCanvas()
            return Section
        end
        
        RunService.Heartbeat:Connect(UpdateCanvas)
        
        table.insert(Window.Tabs, {Button = tabButton, Content = tabContent})
        return Tab
    end
    
    -- Notification System
    function Window:Notify(options)
        local notification = CreateInstance("Frame", {
            Parent = screenGui,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 200, 1, -60),
            Size = UDim2.new(0, 260, 0, 65),
            BackgroundColor3 = THEME.Background,
            BorderSizePixel = 0,
        })
        
        CreateRoundedRect(notification, 10)
        
        local accentColor = options.Type == "Success" and THEME.Success or 
                           options.Type == "Warning" and THEME.Warning or
                           options.Type == "Error" and THEME.Danger or
                           THEME.Accent
        
        local accent = CreateInstance("Frame", {
            Parent = notification,
            Size = UDim2.new(0, 3, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
        })
        
        CreateRoundedRect(accent, 2)
        
        local title = CreateInstance("TextLabel", {
            Parent = notification,
            Position = UDim2.new(0, 16, 0, 10),
            Size = UDim2.new(1, -26, 0, 20),
            BackgroundTransparency = 1,
            Text = options.Title or "Notification",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = THEME.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local message = CreateInstance("TextLabel", {
            Parent = notification,
            Position = UDim2.new(0, 16, 0, 32),
            Size = UDim2.new(1, -26, 0, 25),
            BackgroundTransparency = 1,
            Text = options.Content or "",
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = THEME.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
        
        TweenService:Create(notification, ANIMATIONS.Elastic, {
            Position = UDim2.new(1, -10, 1, -60)
        }):Play()
        
        task.wait(options.Duration or 3)
        
        TweenService:Create(notification, ANIMATIONS.Smooth, {
            Position = UDim2.new(1, 200, 1, -60)
        }):Play()
        
        task.wait(0.35)
        notification:Destroy()
    end
    
    return Window
end

return CrustyHub
