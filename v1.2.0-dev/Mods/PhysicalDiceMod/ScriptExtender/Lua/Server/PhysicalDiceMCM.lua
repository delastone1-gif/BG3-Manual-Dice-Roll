-- PhysicalDiceMCM.lua
-- MCM (Mod Configuration Menu) integration for Physical Dice Mod

local function Log(message)
    Ext.Utils.Print("[PhysicalDiceMCM] " .. tostring(message))
end

Log("Physical Dice MCM Integration Loading...")

-- Module UUID for this mod
local ModuleUUID = "6e190ccd-9cd6-405d-9469-9608dff86e10"

-- Reference to MCM API (will be set when MCM is available)
local MCM = nil

-- Current roll value from MCM
local mcmRollValue = 10

-- Function to check if MCM is available
local function IsMCMAvailable()
    return Mods.BG3MCM ~= nil and Mods.BG3MCM.MCMAPI ~= nil
end

-- Function to get a setting value from MCM
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

-- Function to set a setting value in MCM
local function SetMCMSetting(settingId, value)
    if IsMCMAvailable() then
        local success, err = pcall(function()
            Mods.BG3MCM.MCMAPI:SetSettingValue(settingId, value, ModuleUUID)
        end)
        if not success then
            Log("Error setting MCM setting " .. settingId .. ": " .. tostring(err))
        end
    end
end

-- Function to apply the current MCM roll value
local function ApplyMCMRoll()
    Log("ApplyMCMRoll() called!")
    mcmRollValue = GetMCMSetting("current_roll_value") or 10
    Log("Got MCM roll value: " .. mcmRollValue)

    -- Call the main system's setroll logic
    -- We'll expose this through a global function
    if _G.PhysicalDice then
        Log("Calling PhysicalDice.SetRoll...")
        _G.PhysicalDice.SetRoll(mcmRollValue)
        Log("Applied roll from MCM: " .. mcmRollValue)
    else
        Log("ERROR: PhysicalDice global not found")
    end
end

-- Function to clear the boost
local function ClearMCMBoost()
    if _G.PhysicalDice then
        _G.PhysicalDice.ClearRoll()
        Log("Cleared boost from MCM")
    else
        Log("ERROR: PhysicalDice global not found")
    end
end

-- Function to increment roll value
local function IncrementRoll()
    mcmRollValue = GetMCMSetting("current_roll_value") or 10
    if mcmRollValue < 20 then
        mcmRollValue = mcmRollValue + 1
        SetMCMSetting("current_roll_value", mcmRollValue)
        Log("Incremented roll to: " .. mcmRollValue)
    end
end

-- Function to decrement roll value
local function DecrementRoll()
    mcmRollValue = GetMCMSetting("current_roll_value") or 10
    if mcmRollValue > 1 then
        mcmRollValue = mcmRollValue - 1
        SetMCMSetting("current_roll_value", mcmRollValue)
        Log("Decremented roll to: " .. mcmRollValue)
    end
end

-- Function to set quick roll values
local function SetQuickRoll(value)
    SetMCMSetting("current_roll_value", value)
    Log("Set quick roll to: " .. value)
end

-- Initialize MCM integration
local function InitializeMCM()
    -- Wait a bit for MCM to fully load
    Ext.Timer.WaitFor(1000, function()
        if not IsMCMAvailable() then
            Log("MCM not available - integration disabled")
            Log("Mod will work with console commands only")
            return
        end

        Log("MCM available! Setting up server-side integration...")

        -- NOTE: Keybindings are registered CLIENT-SIDE in PhysicalDiceMCMClient.lua
        -- Server-side only handles auto-apply logic and button callbacks (if available)

        -- Register button callbacks if available
        Log("Checking for button callback API...")
        Log("MCMAPI type: " .. type(Mods.BG3MCM.MCMAPI))
        Log("SetButtonCallback exists: " .. tostring(Mods.BG3MCM.MCMAPI.SetButtonCallback ~= nil))

        if Mods.BG3MCM.MCMAPI.SetButtonCallback then
            Log("SetButtonCallback is available, registering buttons...")
            -- Quick roll buttons
            Mods.BG3MCM.MCMAPI:SetButtonCallback("quick_roll_1", ModuleUUID, function()
                SetQuickRoll(1)
            end)

            Mods.BG3MCM.MCMAPI:SetButtonCallback("quick_roll_10", ModuleUUID, function()
                SetQuickRoll(10)
            end)

            Mods.BG3MCM.MCMAPI:SetButtonCallback("quick_roll_20", ModuleUUID, function()
                SetQuickRoll(20)
            end)

            -- Apply button
            Mods.BG3MCM.MCMAPI:SetButtonCallback("apply_button", ModuleUUID, function()
                ApplyMCMRoll()
            end)

            Log("Registered quick roll buttons and apply button")
        end

        -- Register setting change listener
        -- When the slider changes, we might want to do something
        -- For now, we'll just log it
        Log("MCM integration complete!")
        Log("Use the in-game Mod Configuration Menu to set your dice rolls")
        Log("Or continue using console commands: !setroll, !checkroll, !clearroll")
    end)
end

-- Auto-apply on turn start if enabled
local function CheckAutoApply()
    local autoApply = GetMCMSetting("auto_apply_on_turn")
    return autoApply == true
end

-- Export functions for use by main system
_G.PhysicalDiceMCM = {
    ApplyMCMRoll = ApplyMCMRoll,
    ClearMCMBoost = ClearMCMBoost,
    CheckAutoApply = CheckAutoApply,
    GetMCMSetting = GetMCMSetting,
    SetMCMSetting = SetMCMSetting,
    IsMCMAvailable = IsMCMAvailable
}

-- Initialize when the module loads
InitializeMCM()

Log("Physical Dice MCM Integration Loaded!")
