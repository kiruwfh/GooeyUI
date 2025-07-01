-- This file is intended to be used with loadstring.

local Gooey = {}
Gooey.__index = Gooey

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function CreateDraggable(object)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position -- FIX: Get the object's own position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    object.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            -- FIX: Move the object itself, not its parent
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end


function Gooey.New(name)
    local self = setmetatable({}, Gooey)
    local guiName = name or "Gooey"

    -- FIX: Prevent UI duplication by destroying any old GUI on re-injection
    local playerGui = game:GetService("PlayerGui")
    local oldGui = playerGui:FindFirstChild(guiName)
    if oldGui then
        oldGui:Destroy()
    end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = guiName
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.ScreenGui.Parent = playerGui
    self.ScreenGui.Enabled = true -- The GUI container is always enabled.

    self.Windows = {}
    self.Visible = not isMobile -- GUI is visible by default on PC, hidden on mobile
    self.isMobile = isMobile
    self.ActionButtons = {}
    self.ToggleKey = Enum.KeyCode.Unknown
    self.ToggleConnection = nil

    if self.isMobile then
        -- On mobile, create a dedicated toggle button that is always visible
        local mobileToggle = Instance.new("TextButton")
        mobileToggle.Name = "GooeyMobileToggle"
        mobileToggle.Size = UDim2.new(0, 50, 0, 50)
        mobileToggle.Position = UDim2.new(0, 20, 0.5, -25)
        mobileToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        mobileToggle.Text = ""
        mobileToggle.ZIndex = 10
        mobileToggle.Parent = self.ScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = mobileToggle
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 80, 100)
        stroke.Thickness = 1
        stroke.Parent = mobileToggle
        
        -- You could add a UIGradient or an ImageLabel here to make it prettier
        CreateDraggable(mobileToggle)

        mobileToggle.MouseButton1Click:Connect(function()
            self:ToggleVisibility()
        end)
    end

    return self
end

function Gooey:CreateWindow(title)
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "Window"
    windowFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Center the anchor for scaling animations
    
    -- Target properties for the animation
    local targetSize = UDim2.new(0, 450, 0, 350)
    windowFrame:SetAttribute("TargetSize", targetSize)
    
    windowFrame.Visible = self.Visible -- Set initial visibility based on platform
    
    if self.Visible then -- Only play intro animation if initially visible (on PC)
        -- Initial state for animation
        windowFrame.Size = UDim2.new(targetSize.X.Scale, 0, targetSize.Y.Scale, 0)
        windowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        windowFrame.BackgroundTransparency = 1
        
        -- Animate the window appearing
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local goals = {
            Size = targetSize,
            BackgroundTransparency = 0.1
        }
        local tween = tweenService:Create(windowFrame, tweenInfo, goals)
        tween:Play()
    else
        -- On mobile, just create it in its final state but hidden
        windowFrame.Size = targetSize
        windowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        windowFrame.BackgroundTransparency = 0.1
    end

    windowFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    windowFrame.BorderSizePixel = 0
    windowFrame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = windowFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = windowFrame

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    topBar.BorderSizePixel = 0
    topBar.Parent = windowFrame

    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 12)
    topBarCorner.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Gooey"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 16
    titleLabel.Parent = topBar

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 35)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = windowFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, 0, 1, -75) -- 35 for topbar, 40 for tabs
    pagesContainer.Position = UDim2.new(0, 0, 0, 75)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.ClipsDescendants = true
    pagesContainer.Parent = windowFrame

    windowFrame.Parent = self.ScreenGui

    CreateDraggable(topBar)
    
    table.insert(self.Windows, windowFrame)

    return windowFrame -- Return the main frame, children can be found by name
end

function Gooey:CreateTabs(options)
    local window = options.Window
    local tabNames = options.Tabs
    local activeTabColor = Color3.fromRGB(70, 70, 85)
    local inactiveTabColor = Color3.fromRGB(40, 40, 50)
    
    local tabContainer = window:FindFirstChild("TabContainer")
    local pagesContainer = window:FindFirstChild("PagesContainer")

    if not (tabContainer and pagesContainer) then
        warn("Gooey: This window does not support tabs.")
        return {}
    end

    local tabButtons = {}
    local pages = {}
    
    local activeTab = {
        Name = tabNames[1],
        Index = 1
    }
    local isTransitioning = false

    for i, name in ipairs(tabNames) do
        -- Create Page
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = (i == 1) -- Only first page is visible
        page.Parent = pagesContainer
        page.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
        page.ScrollBarThickness = 4
        page.ScrollBarImageTransparency = 1 -- Make it fully transparent by default
        page.ScrollingDirection = Enum.ScrollingDirection.Y

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.Parent = page
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.Parent = page
        
        pages[name] = page

        -- Create Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Size = UDim2.new(0, 100, 0, 28)
        tabButton.BackgroundColor3 = (i == 1) and activeTabColor or inactiveTabColor
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14
        tabButton.Parent = tabContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = tabButton

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(80, 80, 95)
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = tabButton

        table.insert(tabButtons, tabButton)

        -- Fade in the scrollbar for the very first visible tab after intro animation
        if i == 1 then
            task.delay(0.75, function() -- Wait for window and tab animation
                if page and page.Parent then
                     game:GetService("TweenService"):Create(page, TweenInfo.new(0.3), {ScrollBarImageTransparency = 0.4}):Play()
                end
            end)
        end

        tabButton.MouseButton1Click:Connect(function()
            if isTransitioning or name == activeTab.Name then return end
            isTransitioning = true

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
            
            local clickedIndex = i
            local slideDirection = (clickedIndex > activeTab.Index) and 1 or -1

            local oldPage = pages[activeTab.Name]
            local oldButton = tabButtons[activeTab.Index]
            local newPage = pages[name]

            -- Hide old scrollbar before it moves
            tweenService:Create(oldPage, TweenInfo.new(0.1), {ScrollBarImageTransparency = 1}):Play()

            -- Animate old page out
            local oldPageGoal = { Position = UDim2.fromOffset(-pagesContainer.AbsoluteSize.X * slideDirection, 0) }
            tweenService:Create(oldPage, tweenInfo, oldPageGoal):Play()
            
            -- Prepare and animate new page in (scrollbar is already invisible)
            newPage.Position = UDim2.fromOffset(pagesContainer.AbsoluteSize.X * slideDirection, 0)
            newPage.Visible = true
            local newPageGoal = { Position = UDim2.fromOffset(0, 0) }
            local newPageTween = tweenService:Create(newPage, tweenInfo, newPageGoal)
            newPageTween:Play()

            -- After transition, fade in new scrollbar and allow clicks again
            newPageTween.Completed:Connect(function()
                if oldPage and oldPage ~= newPage then
                    oldPage.Visible = false
                end
                tweenService:Create(newPage, TweenInfo.new(0.2), {ScrollBarImageTransparency = 0.4}):Play()
                isTransitioning = false
            end)
            
            -- Update button colors with animation
            tweenService:Create(oldButton, tweenInfo, { BackgroundColor3 = inactiveTabColor }):Play()
            tweenService:Create(tabButton, tweenInfo, { BackgroundColor3 = activeTabColor }):Play()
            
            -- Update active tab info
            activeTab.Name = name
            activeTab.Index = clickedIndex
        end)
    end
    
    return pages
end

function Gooey:CreateButton(options)
    local parent = options.Parent
    local text = options.Text or "Button"
    local callback = options.Callback or function() end

    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 95)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button
    
    local tweenService = game:GetService("TweenService")
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.fromRGB(70, 70, 85)
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    button.MouseEnter:Connect(function()
        tweenService:Create(button, tweenInfo, {BackgroundColor3 = hoverColor}):Play()
    end)

    button.MouseLeave:Connect(function()
        tweenService:Create(button, tweenInfo, {BackgroundColor3 = originalColor}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        -- No animation on click, as requested
        pcall(callback)
    end)

    return button
end

function Gooey:CreateCheckbox(options)
    local parent = options.Parent
    local text = options.Text or "Checkbox"
    local callback = options.Callback or function() end
    local default = options.Default or false

    local toggled = default
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    local container = Instance.new("Frame")
    container.Name = text .. "Container"
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0.2, -20, 0, 20)
    toggleButton.Position = UDim2.new(0.8, 10, 0.5, -10)
    toggleButton.BackgroundColor3 = toggled and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(50, 50, 65)
    toggleButton.Text = ""
    toggleButton.Parent = container

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(80, 80, 95)
    toggleStroke.Thickness = 1
    toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    toggleStroke.Parent = toggleButton

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    knob.Parent = toggleButton
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        pcall(callback, toggled)

        local goalKnob = { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }
        local goalBg = { BackgroundColor3 = toggled and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(50, 50, 65) }
        
        tweenService:Create(knob, tweenInfo, goalKnob):Play()
        tweenService:Create(toggleButton, tweenInfo, goalBg):Play()
    end)
    
    return container
end

function Gooey:CreateSlider(options)
    local parent = options.Parent
    local text = options.Text or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local callback = options.Callback or function() end
    
    local tweenService = game:GetService("TweenService")
    local inputService = game:GetService("UserInputService")
    local dragging = false
    
    local container = Instance.new("Frame")
    container.Name = text .. "Container"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(1, 0, 0, 20)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Size = UDim2.new(1, 0, 0, 12)
    sliderFrame.Position = UDim2.new(0, 0, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "FillFrame"
    fillFrame.BackgroundColor3 = Color3.fromRGB(100, 120, 255)
    fillFrame.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fillFrame

    local handle = Instance.new("TextButton")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(0, -8, 0.5, -8)
    handle.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    handle.Text = ""
    handle.ZIndex = 2
    handle.Parent = sliderFrame

    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    local function UpdateSlider(value)
        local percentage = (value - min) / (max - min)
        percentage = math.clamp(percentage, 0, 1)
        
        valueLabel.Text = string.format("%.2f", value)
        fillFrame.Size = UDim2.new(percentage, 0, 1, 0)
        handle.Position = UDim2.new(percentage, -8, 0.5, -8)
        pcall(callback, value)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    inputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    inputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseX = input.Position.X
            local sliderX = sliderFrame.AbsolutePosition.X
            local sliderWidth = sliderFrame.AbsoluteSize.X
            
            local percentage = (mouseX - sliderX) / sliderWidth
            percentage = math.clamp(percentage, 0, 1)
            
            local newValue = min + (max - min) * percentage
            UpdateSlider(newValue)
        end
    end)

    UpdateSlider(default)
    return container
end

local activeKeybind = nil
function Gooey:CreateKeybind(options)
    if self.isMobile then
        -- This component is not for mobile, use CreateAction instead
        warn("Gooey: CreateKeybind is not recommended for mobile. Use CreateAction.")
        return
    end

    local parent = options.Parent
    local text = options.Text or "Keybind"
    local defaultKey = options.Default or Enum.KeyCode.Unknown
    local callback = options.Callback or function() end

    local currentKey = defaultKey
    local isListening = false

    local container = Instance.new("Frame")
    container.Name = text .. "Container"
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.Size = UDim2.new(0.4, 0, 1, 0)
    keyButton.Position = UDim2.new(0.6, 0, 0, 0)
    keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    keyButton.Font = Enum.Font.Gotham
    keyButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    keyButton.TextSize = 14
    keyButton.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = keyButton

    local function UpdateText()
        if isListening then
            keyButton.Text = "..."
        else
            keyButton.Text = currentKey.Name == "Unknown" and "None" or currentKey.Name
        end
    end

    local inputConnection = nil
    keyButton.MouseButton1Click:Connect(function()
        if activeKeybind and activeKeybind ~= keyButton then return end

        isListening = not isListening
        activeKeybind = isListening and keyButton or nil
        UpdateText()

        if isListening then
            inputConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        currentKey = Enum.KeyCode.Unknown
                    else
                        currentKey = input.KeyCode
                    end
                    isListening = false
                    activeKeybind = nil
                    UpdateText()
                    pcall(callback, currentKey)
                    if inputConnection then inputConnection:Disconnect() end
                end
            end)
        else
            if inputConnection then inputConnection:Disconnect() end
        end
    end)
    
    UpdateText()
    return container
end

function Gooey:CreateAction(options)
    if not self.isMobile then return end -- Only for mobile

    local text = options.Text or "A"
    local callback = options.Callback or function() end

    local actionButton = Instance.new("TextButton")
    actionButton.Name = text .. "ActionButton"
    actionButton.Size = UDim2.new(0, 45, 0, 45)
    -- Position dynamically
    local yPos = 100 + (#self.ActionButtons * 55)
    actionButton.Position = UDim2.new(0, 22.5, 0, yPos)
    actionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    actionButton.Text = text
    actionButton.Font = Enum.Font.GothamBold
    actionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    actionButton.TextSize = 18
    actionButton.ZIndex = 9
    actionButton.Parent = self.ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = actionButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 95)
    stroke.Thickness = 1
    stroke.Parent = actionButton
    
    CreateDraggable(actionButton)

    actionButton.MouseButton1Click:Connect(pcall, callback)
    
    table.insert(self.ActionButtons, actionButton)
    return actionButton
end

function Gooey:ToggleVisibility()
    self.Visible = not self.Visible
    local tweenService = game:GetService("TweenService")
    local tweenInfoIn = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenInfoOut = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    for _, window in ipairs(self.Windows) do
        local targetSize = window:GetAttribute("TargetSize") or UDim2.new(0, 450, 0, 350)

        if self.Visible then
            window.Visible = true
            local goalsIn = {
                Size = targetSize,
                BackgroundTransparency = 0.1
            }
            tweenService:Create(window, tweenInfoIn, goalsIn):Play()
        else
            local goalsOut = {
                Size = UDim2.new(targetSize.X.Scale, 0, targetSize.Y.Scale, 0),
                BackgroundTransparency = 1
            }
            local tween = tweenService:Create(window, tweenInfoOut, goalsOut)
            tween.Completed:Connect(function()
                if window and window.Parent then
                    window.Visible = false
                end
            end)
            tween:Play()
        end
    end
end

function Gooey:SetToggleKey(key)
    if self.isMobile then return end -- Don't set keyboard binds on mobile

    if self.ToggleConnection then
        self.ToggleConnection:Disconnect()
        self.ToggleConnection = nil
    end

    self.ToggleKey = key

    self.ToggleConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.ToggleKey then
            self:ToggleVisibility()
        end
    end)
end

-- =======================================================
-- Example Usage - This part runs when you inject the script
-- =======================================================

-- 1. Create a new GUI manager
local MyGui = Gooey.New("Gooey")

-- 2. Create a window
local myWindow = MyGui:CreateWindow("Gooey | v1.2")

-- 3. Create tabs and get their content pages
local pages = MyGui:CreateTabs({
    Window = myWindow,
    Tabs = {"Combat", "Movement", "Visuals", "Misc"}
})

-- 4. Set the initial toggle key (for PC)
MyGui:SetToggleKey(Enum.KeyCode.RightShift)

-- 5. Create elements inside the pages
if isMobile then
    -- Mobile-specific quick actions
    MyGui:CreateAction({
        Text = "SP",
        Callback = function() print("Speed Toggled!") end
    })
    MyGui:CreateAction({
        Text = "TP",
        Callback = function() print("Teleporting!") end
    })
else
    -- PC-specific keybinds
    MyGui:CreateKeybind({
        Parent = pages.Combat,
        Text = "Aimbot Key",
        Default = Enum.KeyCode.F,
        Callback = function(key)
            print("Aimbot key set to: " .. key.Name)
        end
    })
end

-- Common elements
MyGui:CreateSlider({
    Parent = pages.Movement,
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(value)
        -- Example: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        print("Walkspeed set to: " .. value)
    end
})

MyGui:CreateCheckbox({
    Parent = pages.Movement,
    Text = "Fly",
    Callback = function(toggled)
        print("Fly toggled: " .. tostring(toggled))
    end
})
MyGui:CreateCheckbox({
    Parent = pages.Movement,
    Text = "NoClip",
    Callback = function(toggled)
        print("NoClip toggled: " .. tostring(toggled))
    end
})
MyGui:CreateCheckbox({
    Parent = pages.Movement,
    Text = "Infinite Jump",
    Callback = function(toggled)
        print("Infinite Jump toggled: " .. tostring(toggled))
    end
})
MyGui:CreateButton({
    Parent = pages.Movement,
    Text = "Reset Character",
    Callback = function()
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character:BreakJoints()
        end
    end
})

MyGui:CreateCheckbox({
    Parent = pages.Visuals,
    Text = "Enable ESP",
    Default = true,
    Callback = function(toggled)
        print("ESP toggled: " .. tostring(toggled))
    end
})

MyGui:CreateKeybind({
    Parent = pages.Misc,
    Text = "Toggle GUI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        MyGui:SetToggleKey(key)
    end
})

MyGui:CreateButton({
    Parent = pages.Misc,
    Text = "Destroy GUI",
    Callback = function()
        MyGui.ScreenGui:Destroy()
    end
})

return Gooey 
