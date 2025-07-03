--[[
    Gooey.lua | v2.0
    A simple, modern, and adaptive GUI library.
]]

local Gooey = {}
Gooey.__index = Gooey

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Environment
local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- The most robust method to get PlayerGui across all executors.
local playerGui
repeat task.wait() until pcall(function() playerGui = LocalPlayer:WaitForChild("PlayerGui") end)

-- Main GUI container
local ScreenGui = playerGui:FindFirstChild("GooeyScreenGui")
if ScreenGui then
    ScreenGui:Destroy()
end
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GooeyScreenGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- Draggable function
local function makeDraggable(object)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Parent.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            object.Parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Main Window Creation
function Gooey:CreateWindow(options)
    local window = {}
    window.Tabs = {}
    
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = options.Title or "Gooey"
    windowFrame.Size = options.Size or UDim2.fromOffset(350, 450)
    windowFrame.Position = UDim2.fromScale(0.5, 0.5)
    windowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    windowFrame.ClipsDescendants = true
    windowFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    windowFrame.BorderSizePixel = 0
    windowFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = windowFrame
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    header.Parent = windowFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = options.Title or "Gooey"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Parent = header
    
    if options.Draggable then
        makeDraggable(header)
    end

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.Size = UDim2.new(1, 0, 1, -35)
    contentContainer.Position = UDim2.new(0, 0, 0, 35)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = windowFrame

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = contentContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer

    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, 0, 1, -40)
    pagesContainer.Position = UDim2.new(0, 0, 0, 40)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.Parent = contentContainer
    
    local activeTab = { button = nil, page = nil }

    function window:CreateTab(tabName)
        local page = Instance.new("ScrollingFrame")
        page.Name = tabName
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = false
        page.Parent = pagesContainer
        page.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
        page.ScrollBarThickness = 4
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = page
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.Parent = page
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Size = UDim2.new(0, 100, 0, 28)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14
        tabButton.Parent = tabContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = tabButton

        tabButton.MouseButton1Click:Connect(function()
            if activeTab.button == tabButton then return end
            if activeTab.button then
                activeTab.button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                activeTab.page.Visible = false
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
            page.Visible = true
            activeTab = { button = tabButton, page = page }
        end)
        
        if not activeTab.button then
            tabButton.MouseButton1Click:Invoke()
        end
        
        return page
    end
    
    return window
end

-- Component Functions
function Gooey:CreateToggle(options)
    local parent = options.Parent
    assert(parent, "Gooey Error: Parent must be provided for CreateToggle")

    local container = Instance.new("Frame")
    container.Name = (options.Title or "Toggle") .. "Container"
    container.Size = UDim2.new(0.9, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = options.Title or "Toggle"
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleSwitch = Instance.new("TextButton")
    toggleSwitch.Name = "Switch"
    toggleSwitch.Size = UDim2.new(0.3, 0, 1, 0)
    toggleSwitch.Position = UDim2.new(0.7, 0, 0, 0)
    toggleSwitch.BackgroundTransparency = 1
    toggleSwitch.Text = ""
    toggleSwitch.Parent = container

    -- The rest of the toggle logic...
    -- ...
end

function Gooey:CreateButton(options)
    local parent = options.Parent
    assert(parent, "Gooey Error: Parent must be provided for CreateButton")

    local button = Instance.new("TextButton")
    button.Name = options.Title or "Button"
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.Text = options.Title or "Button"
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        if options.Callback then
            pcall(options.Callback, button)
        end
    end)
    return button
end

function Gooey:CreateSlider(options)
    local parent = options.Parent
    assert(parent, "Gooey Error: Parent must be provided for CreateSlider")

    local container = Instance.new("Frame")
    container.Name = (options.Title or "Slider") .. "Container"
    container.Size = UDim2.new(0.9, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = parent

    -- Slider logic...
    -- ...
end

return Gooey 
