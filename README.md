# Gooey | A Simple & Stylish GUI Library for Roblox

A minimalistic and modern GUI library designed to be powerful, easy to use, 
and visually appealing, all within a single, self-contained script.

## Features

- **Easy to Use:** Simple and intuitive API.
- **Modern Design:** Stylish and clean UI that looks great out of the box.
- **Fully Animated:** Smooth, tweened animations for all interactions.
- **Customizable:** All core components needed for a modern cheat menu.
- **Self-Contained:** Everything is in one file, perfect for `loadstring`.

## How to Use

To use Gooey in your own script, you need to load it using `loadstring`. You'll need to upload the `Gooey.lua` file to your GitHub repository and use the "Raw" file link.

```lua
-- Replace with your own GitHub raw link
local raw_link = "https://raw.githubusercontent.com/kiruwfh/GooeyUI/main/Gooey.lua"

local Gooey = loadstring(game:HttpGet(raw_link))()

-- Now you are ready to create your GUI!
-- See the example.lua file for a full usage example.

local MyGui = Gooey.New("MyGooey")
local myWindow = MyGui:CreateWindow("My Awesome Menu")

local pages = MyGui:CreateTabs({
    Window = myWindow,
    Tabs = {"Combat", "Movement"}
})

MyGui:CreateButton({
    Parent = pages.Combat,
    Text = "Click Me!",
    Callback = function()
        print("Button clicked!")
    end
})
```

## API Reference

### `Gooey.New(name)`
Creates a new Gooey instance. This is the first thing you should call.
- **`name`** (string) [Optional]: The name for the ScreenGui instance.
- **Returns:** (table) The Gooey instance.

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
Creates a keybind button.
- **`options`** (table):
    - **`Parent`** (Instance): The page or frame.
    - **`Text`** (string): The label for the keybind.
    - **`Default`** (Enum.KeyCode) [Optional]: The initial keybind (default: `Unknown`).
    - **`Callback`** (function): Runs when a new key is set, receives the `KeyCode` enum as an argument.

### `Gooey:SetToggleKey(key)`
Sets the key to toggle the GUI's visibility.
- **`key`** (Enum.KeyCode): The key to bind.

## License

This project is licensed under the MIT License. See the `Gooey.lua` file for details. 
