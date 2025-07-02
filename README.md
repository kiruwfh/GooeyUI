# Gooey.lua  GUI Library

**Gooey.lua** is a lightweight, modern, and adaptable GUI library for Roblox scripts. It's designed for rapid development of user interfaces that work seamlessly on both PC and mobile devices.

## Features

- **Cross-Platform:** Automatically adapts to the user's device. Creates keybinds for PC users and dedicated action buttons for mobile users.
- **Persistent UI:** The interface remains on screen even after the player's character respawns.
- **Simple & Clean API:** Create complex UIs with minimal, easy-to-understand code.
- **Lightweight:** No external dependencies, just one file to manage.

## Installation

1.  Download the `Gooey.lua` file.
2.  Place it in your script's environment. The most common method is to place it in the same directory as your main script.

## Usage

Using Gooey is straightforward. You initialize the library and then start adding elements to it.

The core of the library is the universal `Gooey:CreateToggle()` function, which creates a window with a title and a toggle switch.

### Example

Here is how you can create a simple UI Hub with one feature, "Auto Farm," which can be toggled with the `E` key on PC or a dedicated button on mobile.

```lua
-- Load the Gooey library
local Gooey = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-username/your-repo/main/Gooey.lua"))()

-- Create the main window (hub)
local mainHub = Gooey:CreateWindow({
    Title = "My Awesome Hub",
    Size = UDim2.fromOffset(300, 400),
    Draggable = true
})

-- Create a tab within the window
local mainTab = mainHub:CreateTab("Main Features")

-- Create a toggle for a feature
mainTab:CreateToggle({
    Title = "Auto Farm",
    Description = "Automatically collects resources for you.",
    Key = Enum.KeyCode.E, -- The key to press on PC
    Callback = function(state)
        if state then
            print("Auto Farm has been enabled!")
            -- Start your auto-farming logic here
        else
            print("Auto Farm has been disabled.")
            -- Stop your auto-farming logic here
        end
    end
})
```

This simple script will produce a fully functional UI that works perfectly on both PC and mobile platforms.

## API Reference

### `Gooey.New(name)`
Creates a new Gooey instance. This is the first thing you should call.
- **`name`** (string) [Optional]: The name for the ScreenGui instance.
- **Returns:** (table) The Gooey instance. The instance contains the boolean `isMobile`.

### `Gooey:CreateWindow(title)`
Creates a new draggable window.
- **`title`** (string) [Optional]: The title displayed in the window's top bar.
- **Returns:** (Instance) The main window Frame.

### `Gooey:CreateTabs(options)`
Creates tabs within a window for categorizing elements.
- **`options`** (table):
    - **`Window`** (Instance): The window instance returned by `:CreateWindow()`.
    - **`Tabs`** (table): An array of strings for the tab names (e.g., `{"Combat", "Movement"}`).
- **Returns:** (table) A dictionary where keys are tab names and values are the page Instances.

### `Gooey:CreateButton(options)`
Creates a clickable button.
- **`options`** (table):
    - **`Parent`** (Instance): The page or frame to put the button in.
    - **`Text`** (string): The text on the button.
    - **`Callback`** (function): The function to run when the button is clicked.

### `Gooey:CreateCheckbox(options)`
Creates a toggleable checkbox.
- **`options`** (table):
    - **`Parent`** (Instance): The page or frame.
    - **`Text`** (string): The label for the checkbox.
    - **`Default`** (boolean) [Optional]: The initial state (default: false).
    - **`Callback`** (function): Runs on change, receives the new state (`true`/`false`) as an argument.

### `Gooey:CreateSlider(options)`
Creates a draggable slider for number values.
- **`options`** (table):
    - **`Parent`** (Instance): The page or frame.
    - **`Text`** (string): The label for the slider.
    - **`Min`** (number): The minimum value.
    - **`Max`** (number): The maximum value.
    - **`Default`** (number) [Optional]: The initial value (default: `Min`).
    - **`Callback`** (function): Runs on change, receives the new number value as an argument.

### `Gooey:CreateKeybind(options)`
Creates a keybind button. **(PC Only)**
- **`options`** (table):
    - **`Parent`** (Instance): The page or frame.
    - **`Text`** (string): The label for the keybind.
    - **`Default`** (Enum.KeyCode) [Optional]: The initial keybind (default: `Unknown`).
    - **`Callback`** (function): Runs when a new key is set, receives the `KeyCode` enum as an argument.

### `Gooey:CreateAction(options)`
Creates a draggable, on-screen action button. **(Mobile Only)**
- **`options`** (table):
    - **`Text`** (string): The text on the button (keep it short, e.g., 3-4 letters).
    - **`Callback`** (function): The function to run when the button is clicked.

### `Gooey:SetToggleKey(key)`
Sets the key to toggle the GUI's visibility. **(PC Only)**
- **`key`** (Enum.KeyCode): The key to bind.

## License

This project is licensed under the MIT License. See the `Gooey.lua` file for details. 
