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

    -- FINAL FIX: This is the most robust method to get PlayerGui across all executors.
    -- Some executors run scripts so fast that LocalPlayer isn't available yet.
    local playerGui
    repeat wait() until pcall(function() playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end)

    -- Prevent UI duplication by destroying any old GUI on re-injection
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
    self.Binds = {} -- Stores PC keybinds -> { [Enum.KeyCode] = callback }
    
    -- Master connection for all PC keybinds
    if not self.isMobile then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and self.Binds[input.KeyCode] then
                pcall(self.Binds[input.KeyCode])
            end
        end)
    end

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
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) -- Faster animation
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
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out) -- Faster animation
            
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

function Gooey:CreateToggle(options)
    local parent = options.Parent
    local text = options.Text or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end

    -- State variables for this specific toggle
    local toggled = default
    local currentBind = Enum.KeyCode.Unknown
    local mobileActionButton = nil
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    local container = Instance.new("Frame")
    container.Name = text .. "Container"
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local bindButton = Instance.new("TextButton")
    bindButton.Name = "BindButton"
    bindButton.Size = UDim2.new(0.3, -10, 1, -5)
    bindButton.Position = UDim2.new(0.5, 5, 0.5, 0)
    bindButton.AnchorPoint = Vector2.new(0, 0.5)
    bindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bindButton.Font = Enum.Font.Gotham
    bindButton.Text = self.isMobile and "Bind" or "[ ... ]"
    bindButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    bindButton.TextSize = 12
    bindButton.Parent = container

    local bindCorner = Instance.new("UICorner")
    bindCorner.CornerRadius = UDim.new(0, 5)
    bindCorner.Parent = bindButton

    local toggleSwitch = Instance.new("TextButton")
    toggleSwitch.Name = "Toggle"
    toggleSwitch.Size = UDim2.new(0.2, -20, 0, 20)
    toggleSwitch.Position = UDim2.new(0.8, 10, 0.5, -10)
    toggleSwitch.BackgroundColor3 = toggled and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(50, 50, 65)
    toggleSwitch.Text = ""
    toggleSwitch.Parent = container

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleSwitch
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(80, 80, 95)
    toggleStroke.Parent = toggleSwitch
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    knob.Parent = toggleSwitch
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local function UpdateToggleState(newState)
        toggled = newState
        
        -- Update Visuals
        local goalKnob = { Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }
        local goalBg = { BackgroundColor3 = toggled and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(50, 50, 65) }
        tweenService:Create(knob, tweenInfo, goalKnob):Play()
        tweenService:Create(toggleSwitch, tweenInfo, goalBg):Play()
        
        -- Fire callback
        pcall(callback, toggled)
    end
    
    toggleSwitch.MouseButton1Click:Connect(function()
        UpdateToggleState(not toggled)
    end)
    
    -- Binding Logic
    local listening = false
    bindButton.MouseButton1Click:Connect(function()
        if self.isMobile then
            if mobileActionButton then
                mobileActionButton:Destroy()
                mobileActionButton = nil
                bindButton.Text = "Bind"
            else
                mobileActionButton = Instance.new("TextButton")
                -- ... configure mobileActionButton (the round one)
                mobileActionButton.Size = UDim2.new(0, 45, 0, 45)
                mobileActionButton.Position = UDim2.new(0, 10, 0.5, 0) -- Example position
                mobileActionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                mobileActionButton.Text = string.sub(text, 1, 3)
                mobileActionButton.Font = Enum.Font.GothamBold
                mobileActionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                mobileActionButton.Parent = self.ScreenGui
                local mCorner = Instance.new("UICorner")
                mCorner.CornerRadius = UDim.new(1, 0)
                mCorner.Parent = mobileActionButton
                CreateDraggable(mobileActionButton)
                
                mobileActionButton.MouseButton1Click:Connect(function()
                     UpdateToggleState(not toggled)
                end)
                
                bindButton.Text = "Unbind"
            end
        else -- PC Logic
            if listening then return end
            listening = true
            bindButton.Text = "[ ... ]"
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gp)
                if not gp and input.UserInputType == Enum.UserInputType.Keyboard then
                    -- Unbind old key
                    if self.Binds[currentBind] then self.Binds[currentBind] = nil end
                    
                    if input.KeyCode == Enum.KeyCode.Escape then
                        currentBind = Enum.KeyCode.Unknown
                        bindButton.Text = "[ ... ]"
                    else
                        currentBind = input.KeyCode
                        self.Binds[currentBind] = function() UpdateToggleState(not toggled) end
                        bindButton.Text = "[ " .. currentBind.Name .. " ]"
                    end
                    
                    listening = false
                    connection:Disconnect()
                end
            end)
        end
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

function Gooey:ToggleVisibility()
    self.Visible = not self.Visible
    local tweenService = game:GetService("TweenService")
    local tweenInfoIn = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) -- Faster animation
    local tweenInfoOut = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In) -- Faster animation

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

return Gooey 
