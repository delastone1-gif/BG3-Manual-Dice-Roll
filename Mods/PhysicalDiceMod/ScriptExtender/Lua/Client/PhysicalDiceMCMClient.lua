-- PhysicalDiceMCMClient.lua
-- CLIENT-SIDE MCM integration for Physical Dice Mod
-- Handles keybinding callbacks (must be registered client-side)

local function Log(message)
    Ext.Utils.Print("[PhysicalDiceMCM-Client] " .. tostring(message))
end

Log("Physical Dice MCM Client Integration Loading...")

-- Module UUID for this mod
local ModuleUUID = "6e190ccd-9cd6-405d-9469-9608dff86e10"

-- Function to check if MCM is available
local function IsMCMAvailable()
    return Mods.BG3MCM ~= nil and Mods.BG3MCM.MCMAPI ~= nil
end

-- Function to send command to server
local function SendCommandToServer(command, value)
    local data = {
        command = command,
        value = value
    }
    Ext.Net.PostMessageToServer("PhysicalDiceCommand", Ext.Json.Stringify(data))
    Log("Sent command to server: " .. command .. (value and (" = " .. value) or ""))
end

-- Function to get MCM setting value
local function GetMCMSetting(settingId)
    if IsMCMAvailable() then
        local success, value = pcall(function()
            return Mods.BG3MCM.MCMAPI:GetSettingValue(settingId, ModuleUUID)
        end)
        if success then
            return value
        else
            Log("Error getting MCM setting " .. settingId .. ": " .. tostring(value))
        end
    end
    return nil
end

-- Keybinding callback: Apply Roll (F9)
local function OnApplyRoll()
    Log("F9 HOTKEY PRESSED!")
    local rollValue = GetMCMSetting("current_roll_value") or 10
    Log("Applying roll value: " .. rollValue)
    SendCommandToServer("setroll", rollValue)
end

-- Keybinding callback: Clear Boost (F10)
local function OnClearBoost()
    Log("F10 HOTKEY PRESSED!")
    SendCommandToServer("clearroll")
end

-- Keybinding callback: Increment Roll (+)
local function OnIncrementRoll()
    Log("INCREMENT HOTKEY PRESSED!")
    local currentValue = GetMCMSetting("current_roll_value") or 10
    if currentValue < 20 then
        local newValue = currentValue + 1
        if IsMCMAvailable() then
            Mods.BG3MCM.MCMAPI:SetSettingValue("current_roll_value", newValue, ModuleUUID)
        end
        Log("Incremented to: " .. newValue)
    end
end

-- Keybinding callback: Decrement Roll (-)
local function OnDecrementRoll()
    Log("DECREMENT HOTKEY PRESSED!")
    local currentValue = GetMCMSetting("current_roll_value") or 10
    if currentValue > 1 then
        local newValue = currentValue - 1
        if IsMCMAvailable() then
            Mods.BG3MCM.MCMAPI:SetSettingValue("current_roll_value", newValue, ModuleUUID)
        end
        Log("Decremented to: " .. newValue)
    end
end

-- Initialize MCM integration
local function RegisterCallbacks()
    Log("RegisterCallbacks() called")

    if not IsMCMAvailable() then
        Log("MCM not available in RegisterCallbacks - client integration disabled")
        return
    end

    Log("MCM available! Setting up client-side keybindings...")

        -- Register keybinding callbacks (CLIENT-SIDE ONLY)
        if Mods.BG3MCM.MCMAPI.SetKeybindingCallback then
            -- Apply Roll hotkey
            Mods.BG3MCM.MCMAPI:SetKeybindingCallback("apply_roll_hotkey", ModuleUUID, OnApplyRoll)
            Log("Registered Apply Roll hotkey (F9) - CLIENT")

            -- Clear Boost hotkey
            Mods.BG3MCM.MCMAPI:SetKeybindingCallback("clear_boost_hotkey", ModuleUUID, OnClearBoost)
            Log("Registered Clear Boost hotkey (F10) - CLIENT")

            -- Increment hotkey
            Mods.BG3MCM.MCMAPI:SetKeybindingCallback("increment_roll_hotkey", ModuleUUID, OnIncrementRoll)
            Log("Registered Increment hotkey - CLIENT")

            -- Decrement hotkey
            Mods.BG3MCM.MCMAPI:SetKeybindingCallback("decrement_roll_hotkey", ModuleUUID, OnDecrementRoll)
            Log("Registered Decrement hotkey - CLIENT")

            Log("Client-side MCM keybinding integration complete!")
        else
            Log("SetKeybindingCallback not available")
        end

        -- Register button callbacks (CLIENT-SIDE) - buttons call the same functions as hotkeys!
        Log("Checking for button callback API (client-side)...")
        Log("SetButtonCallback exists: " .. tostring(Mods.BG3MCM.MCMAPI.SetButtonCallback ~= nil))

        if Mods.BG3MCM.MCMAPI.SetButtonCallback then
            Log("SetButtonCallback is available, registering buttons on CLIENT...")

            -- Apply button - calls same function as F9!
            Mods.BG3MCM.MCMAPI:SetButtonCallback("apply_button", ModuleUUID, function()
                Log("APPLY BUTTON PRESSED (calling F9 function)!")
                OnApplyRoll()
            end)

            -- Quick roll buttons
            Mods.BG3MCM.MCMAPI:SetButtonCallback("quick_roll_1", ModuleUUID, function()
                Log("Quick Roll 1 button pressed")
                if IsMCMAvailable() then
                    Mods.BG3MCM.MCMAPI:SetSettingValue("current_roll_value", 1, ModuleUUID)
                    OnApplyRoll()  -- Auto-apply after setting
                end
            end)

            Mods.BG3MCM.MCMAPI:SetButtonCallback("quick_roll_10", ModuleUUID, function()
                Log("Quick Roll 10 button pressed")
                if IsMCMAvailable() then
                    Mods.BG3MCM.MCMAPI:SetSettingValue("current_roll_value", 10, ModuleUUID)
                    OnApplyRoll()  -- Auto-apply after setting
                end
            end)

            Mods.BG3MCM.MCMAPI:SetButtonCallback("quick_roll_20", ModuleUUID, function()
                Log("Quick Roll 20 button pressed")
                if IsMCMAvailable() then
                    Mods.BG3MCM.MCMAPI:SetSettingValue("current_roll_value", 20, ModuleUUID)
                    OnApplyRoll()  -- Auto-apply after setting
                end
            end)

            Log("Registered button callbacks on CLIENT!")
        else
            Log("SetButtonCallback not available - buttons will be disabled")
        end

    -- Register setting change listener for auto-commit slider
    Log("Setting up slider auto-commit...")
    local settingChangeSuccess = pcall(function()
        if Ext.ModEvents and Ext.ModEvents.BG3MCM then
            Ext.ModEvents.BG3MCM["MCMSettingSaved"]:Subscribe(function(payload)
                if payload and payload.modUUID == ModuleUUID and payload.settingId == "current_roll_value" then
                    Log("Slider changed to: " .. tostring(payload.value) .. " - auto-applying!")
                    OnApplyRoll()
                end
            end)
            Log("Slider auto-commit enabled!")
        end
    end)

    if not settingChangeSuccess then
        Log("Could not enable slider auto-commit - manual apply will be required")
    end
end

-- Try to register immediately
Log("Attempting immediate callback registration...")
RegisterCallbacks()

-- Also listen for MCM's ready event (fires when MCM settings are loaded)
local success = pcall(function()
    if Ext.ModEvents and Ext.ModEvents.BG3MCM then
        Ext.ModEvents.BG3MCM["MCMSettingsSaved"]:Subscribe(function(payload)
            if payload and payload.modUUID == ModuleUUID then
                Log("MCM settings saved event received, re-registering callbacks...")
                RegisterCallbacks()
            end
        end)
        Log("Subscribed to MCM events")
    end
end)

if not success then
    Log("Could not subscribe to MCM events - will rely on immediate registration")
end

Log("Physical Dice MCM Client Integration Loaded!")
