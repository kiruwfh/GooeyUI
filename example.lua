-- This is an example of how to use the Gooey.lua library in your own scripts.
-- You would run this script in an executor after uploading Gooey.lua to your GitHub.

-- 1. Load the library using the raw GitHub link
local raw_link = "https://raw.githubusercontent.com/kiruwfh/GooeyUI/main/Gooey.lua"
local Gooey = loadstring(game:HttpGet(raw_link))()

if not Gooey then
    warn("Gooey library failed to load. Check your internet connection and the raw link.")
    return
end

-- 2. Create a new GUI manager
-- The library will automatically detect if the user is on mobile or PC.
local MyGui = Gooey.New("Gooey")

-- 3. Create a window
local myWindow = MyGui:CreateWindow("Gooey | v1.2")

-- 4. Create tabs and get their content pages
local pages = MyGui:CreateTabs({
    Window = myWindow,
    Tabs = {"Combat", "Movement", "Visuals", "Misc"}
})

-- 5. Set the initial toggle key (This will only work on PC)
MyGui:SetToggleKey(Enum.KeyCode.RightShift)


-- 6. Create platform-specific elements
if MyGui.isMobile then
    -- On Mobile, create quick action buttons that are always on screen
    MyGui:CreateAction({
        Text = "SPD", -- Short text for small buttons
        Callback = function() 
            print("Speed action toggled!") 
            -- Here you would toggle your speed script
        end
    })
    MyGui:CreateAction({
        Text = "FLY",
        Callback = function() 
            print("Fly action toggled!") 
            -- Here you would toggle your fly script
        end
    })
else
    -- On PC, create keybinds inside the menu
    MyGui:CreateKeybind({
        Parent = pages.Combat,
        Text = "Aimbot Key",
        Default = Enum.KeyCode.F,
        Callback = function(key)
            print("Aimbot key set to: " .. key.Name)
        end
    })
end

-- 7. Create common elements that work on both platforms

-- Movement Page
MyGui:CreateSlider({
    Parent = pages.Movement,
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(value)
        -- Example of how to use the value:
        -- if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        --     game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        -- end
        print("Walkspeed set to: " .. string.format("%.2f", value))
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

-- Visuals Page
MyGui:CreateCheckbox({
    Parent = pages.Visuals,
    Text = "Enable ESP",
    Default = true,
    Callback = function(toggled)
        print("ESP toggled: " .. tostring(toggled))
    end
})

MyGui:CreateCheckbox({
    Parent = pages.Visuals,
    Text = "Chams",
    Default = false,
    Callback = function(toggled)
        print("Chams toggled: " .. tostring(toggled))
    end
})

-- Misc Page
MyGui:CreateKeybind({
    Parent = pages.Misc,
    Text = "Toggle GUI Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        -- This updates the key used to open/close the menu on PC
        MyGui:SetToggleKey(key)
    end
})

MyGui:CreateButton({
    Parent = pages.Misc,
    Text = "Destroy GUI",
    Callback = function()
        MyGui.ScreenGui:Destroy()
        -- This allows the script to be re-injected after being destroyed
        _G.GooeyLoaded = nil 
    end
})

print("Gooey GUI Loaded Successfully!") 
