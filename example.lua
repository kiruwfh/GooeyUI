-- This is an example of how to use the Gooey.lua library in your own scripts.
-- You would run this script in an executor after uploading Gooey.lua to your GitHub.

-- 1. Load the library using the raw GitHub link
local raw_link = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Gooey.lua"
local Gooey = loadstring(game:HttpGet(raw_link))()

if not Gooey then
    warn("Gooey library failed to load. Check your internet connection and the raw link.")
    return
end

-- 2. Create a new GUI manager
local MyGui = Gooey.New("MyGooey")

-- 3. Create a window
local myWindow = MyGui:CreateWindow("Gooey | v1.0")

-- 4. Create tabs and get their content pages
local pages = MyGui:CreateTabs({
    Window = myWindow,
    Tabs = {"Combat", "Movement", "Visuals", "Misc"}
})

-- 5. Set the initial toggle key
-- This key can be changed later using the Keybind element in the "Misc" tab
MyGui:SetToggleKey(Enum.KeyCode.RightShift)


-- 6. Create elements inside the pages

-- Combat Page
MyGui:CreateKeybind({
    Parent = pages.Combat,
    Text = "Aimbot Key",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        print("Aimbot key set to: " .. key.Name)
    end
})

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
MyGui:CreateButton({
    Parent = pages.Movement,
    Text = "Reset Character",
    Callback = function()
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character:BreakJoints()
        end
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

-- Misc Page
MyGui:CreateKeybind({
    Parent = pages.Misc,
    Text = "Toggle GUI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        -- This updates the key used to open/close the menu
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

print("Gooey GUI Loaded Successfully!") 