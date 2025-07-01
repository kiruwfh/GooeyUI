-- This is an example of how to use the Gooey.lua library (v2.0) in your own scripts.
-- You would run this script in an executor after uploading Gooey.lua to your GitHub.

-- 1. Load the library using the raw GitHub link
local raw_link = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Gooey.lua"
local Gooey = loadstring(game:HttpGet(raw_link))()

if not Gooey then
    warn("Gooey library failed to load. Check your internet connection and the raw link.")
    return
end

-- 2. Create a new GUI manager
-- The library will automatically detect if the user is on mobile or PC.
local MyGui = Gooey.New("Gooey")

-- 3. Create a window
local myWindow = MyGui:CreateWindow("Gooey | v2.0")

-- 4. Create tabs and get their content pages
local pages = MyGui:CreateTabs({
    Window = myWindow,
    Tabs = {"Movement", "Visuals", "Misc"}
})

-- 5. Set the initial toggle key (This will only work on PC)
MyGui:SetToggleKey(Enum.KeyCode.RightShift)


-- 6. Create universal toggle elements
-- These will automatically adapt to PC (keyboard bind) or Mobile (on-screen action button)
MyGui:CreateToggle({
    Parent = pages.Movement,
    Text = "Super Speed",
    Default = false,
    Callback = function(state)
        print("Super Speed toggled:", state)
        if state then
            -- Your code to enable speed
        else
            -- Your code to disable speed
        end
    end
})

MyGui:CreateToggle({
    Parent = pages.Movement,
    Text = "Fly",
    Callback = function(state)
        print("Fly toggled:", state)
    end
})

MyGui:CreateToggle({
    Parent = pages.Visuals,
    Text = "Fullbright",
    Default = true,
    Callback = function(state)
        print("Fullbright toggled:", state)
        if state then
            game:GetService("Lighting").Brightness = 2
        else
            game:GetService("Lighting").Brightness = 1
        end
    end
})

-- 7. Other elements still work as before
MyGui:CreateSlider({
    Parent = pages.Movement,
    Text = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(value)
        print("Jump Power set to: " .. string.format("%.0f", value))
    end
})

-- 8. Misc Section
MyGui:CreateButton({
    Parent = pages.Misc,
    Text = "Destroy GUI",
    Callback = function()
        MyGui.ScreenGui:Destroy()
    end
})

print("Gooey v2.0 GUI Loaded Successfully!") 
