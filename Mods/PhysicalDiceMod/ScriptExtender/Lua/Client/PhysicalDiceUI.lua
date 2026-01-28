-- PhysicalDiceUI.lua
-- ImGui interface for physical dice input

local function Log(message)
    Ext.Utils.Print("[PhysicalDiceUI] " .. tostring(message))
end

Log("Physical Dice UI Loading...")

-- UI State
local showWindow = false
local inputValue = "15"
local statusMessage = "No boost active"
local currentCharacterName = "None"

-- Toggle UI visibility
local function ToggleUI()
    showWindow = not showWindow
    Log("UI toggled: " .. tostring(showWindow))
end

-- Send roll value to server
local function SendRollToServer(value)
    local rollValue = tonumber(value)

    if not rollValue then
        statusMessage = "ERROR: Invalid number"
        return
    end

    if rollValue < 1 or rollValue > 20 then
        statusMessage = "ERROR: Must be 1-20"
        return
    end

    -- Send to server
    local data = {
        command = "setroll",
        value = rollValue
    }
    Ext.Net.PostMessageToServer("PhysicalDiceCommand", Ext.Json.Stringify(data))
    statusMessage = "Sent roll value: " .. rollValue
    Log("Sent roll value to server: " .. rollValue)
end

-- Clear boost on server
local function ClearBoost()
    local data = {
        command = "clearroll"
    }
    Ext.Net.PostMessageToServer("PhysicalDiceCommand", Ext.Json.Stringify(data))
    statusMessage = "Boost cleared"
    Log("Clear boost command sent")
end

-- Listen for status updates from server
Ext.RegisterNetListener("PhysicalDiceStatus", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    statusMessage = data.message or "Unknown status"
    currentCharacterName = data.characterName or "None"
    Log("Status update: " .. statusMessage)
end)

-- ImGui rendering function
local function RenderUI()
    if not showWindow then
        return
    end

    -- Create window
    local windowFlags = {
        "NoCollapse",
        "AlwaysAutoResize"
    }

    local openWindow, shouldDraw = Ext.IMGUI.Begin("Physical Dice Input", showWindow, windowFlags)

    if not shouldDraw then
        Ext.IMGUI.End()
        return
    end

    -- Title section
    Ext.IMGUI.PushStyleColor("Text", 0.2, 0.8, 1.0, 1.0)
    Ext.IMGUI.Text("🎲 Physical Dice Mod")
    Ext.IMGUI.PopStyleColor()
    Ext.IMGUI.Separator()

    Ext.IMGUI.Spacing()

    -- Current turn display
    Ext.IMGUI.Text("Current Turn: " .. currentCharacterName)
    Ext.IMGUI.Spacing()

    -- Input field
    Ext.IMGUI.Text("Enter your physical dice roll:")
    inputValue = Ext.IMGUI.InputText("##rollvalue", inputValue, 3)

    Ext.IMGUI.Spacing()

    -- Apply button
    if Ext.IMGUI.Button("Apply Roll", 120, 30) then
        SendRollToServer(inputValue)
    end

    Ext.IMGUI.SameLine()

    -- Clear button
    if Ext.IMGUI.Button("Clear Boost", 120, 30) then
        ClearBoost()
    end

    Ext.IMGUI.Spacing()
    Ext.IMGUI.Separator()
    Ext.IMGUI.Spacing()

    -- Quick select buttons
    Ext.IMGUI.Text("Quick Select:")

    -- Row 1: 1-10
    for i = 1, 10 do
        if Ext.IMGUI.Button(tostring(i), 35, 25) then
            inputValue = tostring(i)
            SendRollToServer(inputValue)
        end
        if i < 10 then
            Ext.IMGUI.SameLine()
        end
    end

    -- Row 2: 11-20
    for i = 11, 20 do
        if Ext.IMGUI.Button(tostring(i), 35, 25) then
            inputValue = tostring(i)
            SendRollToServer(inputValue)
        end
        if i < 20 then
            Ext.IMGUI.SameLine()
        end
    end

    Ext.IMGUI.Spacing()
    Ext.IMGUI.Separator()
    Ext.IMGUI.Spacing()

    -- Status display
    Ext.IMGUI.PushStyleColor("Text", 0.2, 1.0, 0.2, 1.0)
    Ext.IMGUI.TextWrapped(statusMessage)
    Ext.IMGUI.PopStyleColor()

    Ext.IMGUI.Spacing()
    Ext.IMGUI.Separator()
    Ext.IMGUI.Spacing()

    -- Help text
    Ext.IMGUI.PushStyleColor("Text", 0.7, 0.7, 0.7, 1.0)
    Ext.IMGUI.TextWrapped("Toggle this window with console command: !toggledice")
    Ext.IMGUI.PopStyleColor()

    Ext.IMGUI.End()
end

-- Register the UI render callback
Ext.Events.Tick:Subscribe(function()
    RenderUI()
end)

-- Listen for combat state changes from server
Ext.RegisterNetListener("PhysicalDiceCombatState", function(channel, payload)
    local data = Ext.Json.Parse(payload)

    if data.inCombat then
        showWindow = true
        Log("Combat started - UI shown automatically")
    else
        showWindow = false
        Log("Combat ended - UI hidden automatically")
    end
end)

-- Listen for UI commands from server (like toggle)
Ext.RegisterNetListener("PhysicalDiceUICommand", function(channel, payload)
    local data = Ext.Json.Parse(payload)

    if data.command == "toggle" then
        ToggleUI()
    end
end)

Log("Physical Dice UI Loaded!")
Log("Use console command: !toggledice to show/hide the UI")
