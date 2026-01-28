-- PhysicalDiceInput.lua
-- Console command system for inputting physical dice rolls

local function Log(message)
    Ext.Utils.Print("[PhysicalDiceInput] " .. tostring(message))
end

Log("Physical Dice Input System Loading...")

-- Store the next roll value and current turn
local nextRollValue = nil
local activeBoost = nil
local activeBoostString = nil
local activeCharacter = nil
local currentTurnCharacter = nil  -- Track whose turn it is

-- Function to create boost string for a specific roll value
-- Uses BOTH Minimum and Maximum to lock the roll to an exact value
local function CreateBoostString(rollValue)
    return string.format(
        "MinimumRollResult(Attack,%d);MinimumRollResult(RawAbility,%d);MinimumRollResult(SkillCheck,%d);MinimumRollResult(SavingThrow,%d);MaximumRollResult(Attack,%d);MaximumRollResult(RawAbility,%d);MaximumRollResult(SkillCheck,%d);MaximumRollResult(SavingThrow,%d)",
        rollValue, rollValue, rollValue, rollValue,
        rollValue, rollValue, rollValue, rollValue
    )
end

-- Function to broadcast status to all clients
local function BroadcastStatus(message)
    local characterName = "None"
    if currentTurnCharacter and Osi.IsPartyMember(currentTurnCharacter, 1) == 1 then
        characterName = Osi.GetDisplayName(currentTurnCharacter) or currentTurnCharacter
    end

    local statusData = {
        message = message,
        characterName = characterName,
        hasActiveBoost = activeBoost ~= nil,
        hasQueuedRoll = nextRollValue ~= nil,
        queuedValue = nextRollValue
    }

    Ext.Net.BroadcastMessage("PhysicalDiceStatus", Ext.Json.Stringify(statusData))
end

-- Function to apply boost to a character
local function ApplyBoost(characterGuid, rollValue)
    Log("═══════════════════════════════════════════════")
    Log(string.format("🎲 APPLYING PHYSICAL DICE ROLL: %d", rollValue))
    Log("═══════════════════════════════════════════════")

    -- Remove old boost if exists
    if activeBoost and activeBoostString and activeCharacter then
        Osi.RemoveBoosts(activeCharacter, activeBoostString, 1, "", "")
        Log("Removed previous boost")
    end

    -- Apply new boost
    activeBoostString = CreateBoostString(rollValue)
    Osi.AddBoosts(characterGuid, activeBoostString, "", "")
    activeBoost = characterGuid
    activeCharacter = characterGuid

    Log(string.format("✅ Boost ACTIVE! Roll LOCKED to EXACTLY %d", rollValue))
    Log("📺 CHECK IN-GAME: Your dice should show EXACTLY " .. rollValue)
    Log("═══════════════════════════════════════════════")
end

-- Track whose turn it is
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", function(characterGuid)
    currentTurnCharacter = characterGuid
    local isPlayerCharacter = Osi.IsPartyMember(characterGuid, 1) == 1

    if isPlayerCharacter then
        Log(string.format("🔄 Party member turn started: %s", characterGuid))

        -- If there's a queued roll value, apply it now
        if nextRollValue then
            ApplyBoost(characterGuid, nextRollValue)
            BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", nextRollValue))
            nextRollValue = nil
        else
            -- Check if MCM auto-apply is enabled
            if _G.PhysicalDiceMCM and _G.PhysicalDiceMCM.CheckAutoApply() then
                local mcmRollValue = _G.PhysicalDiceMCM.GetMCMSetting("current_roll_value")
                if mcmRollValue and mcmRollValue >= 1 and mcmRollValue <= 20 then
                    ApplyBoost(characterGuid, mcmRollValue)
                    BroadcastStatus(string.format("AUTO-APPLIED from MCM: Roll locked to %d", mcmRollValue))
                    Log("MCM auto-apply activated")
                else
                    BroadcastStatus("Your turn - ready for roll input")
                end
            else
                BroadcastStatus("Your turn - ready for roll input")
            end
        end
    end
end)


Ext.Osiris.RegisterListener("TurnEnded", 1, "after", function(characterGuid)
    if characterGuid == currentTurnCharacter then
        currentTurnCharacter = nil
    end

    -- Remove boost at turn end
    if activeBoost and characterGuid == activeCharacter then
        Osi.RemoveBoosts(characterGuid, activeBoostString, 1, "", "")
        Log("✅ Boost removed at end of turn")
        activeBoost = nil
        activeBoostString = nil
        activeCharacter = nil
        BroadcastStatus("Turn ended - boost removed")
    end
end)

-- Register SHORT console command (!r) to apply current MCM slider value
Ext.RegisterConsoleCommand("r", function(cmd)
    -- Get value from MCM slider
    local mcmValue = nil
    if _G.PhysicalDiceMCM then
        mcmValue = _G.PhysicalDiceMCM.GetMCMSetting("current_roll_value")
    end

    if mcmValue and mcmValue >= 1 and mcmValue <= 20 then
        Log(string.format("✓ Applying MCM slider value: %d", mcmValue))

        -- Apply immediately if it's a party member's turn
        if currentTurnCharacter and Osi.IsPartyMember(currentTurnCharacter, 1) == 1 then
            ApplyBoost(currentTurnCharacter, mcmValue)
            BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", mcmValue))
        else
            nextRollValue = mcmValue
            BroadcastStatus(string.format("Roll %d queued for next turn", mcmValue))
        end
    else
        Log("ERROR: Set slider value in MCM first, then use !r to apply")
        BroadcastStatus("Set MCM slider first, then use !r")
    end
end)

-- Register console command to set roll value
Ext.RegisterConsoleCommand("setroll", function(cmd, value)
    local rollValue = tonumber(value)

    if not rollValue then
        Log("ERROR: Invalid roll value. Usage: !setroll <number>")
        Log("Example: !setroll 15")
        BroadcastStatus("ERROR: Invalid roll value")
        return
    end

    if rollValue < 1 or rollValue > 20 then
        Log("ERROR: Roll value must be between 1 and 20")
        BroadcastStatus("ERROR: Roll must be 1-20")
        return
    end

    Log(string.format("✓ Physical dice roll set to: %d", rollValue))

    -- Check if it's currently a party member's turn
    if currentTurnCharacter and Osi.IsPartyMember(currentTurnCharacter, 1) == 1 then
        -- It's a party member's turn RIGHT NOW - apply immediately!
        Log("⚡ Applying boost IMMEDIATELY (it's your turn!)")
        ApplyBoost(currentTurnCharacter, rollValue)
        BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", rollValue))
    else
        -- Not a party member's turn - queue for next party turn
        nextRollValue = rollValue
        Log("📋 Boost queued - will apply at start of next party member's turn")
        BroadcastStatus(string.format("Roll %d queued for next turn", rollValue))
    end
end)

-- Log attacks when boost is active
Ext.Osiris.RegisterListener("StartAttack", 4, "after", function(target, attackerOwner, attacker, unknown)
    if activeBoost and attacker == activeCharacter then
        Log("⚔️  ATTACK STARTED - Boost is ACTIVE for this roll!")
    end
end)

-- Remove boost after first attack (one-shot mode)
Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(defender, attackerOwner, attacker2, damageType, damageAmount, damageCause, storyActionID)
    if activeBoost and attackerOwner == activeCharacter then
        Ext.Timer.WaitFor(100, function()
            if activeBoost and activeBoostString and activeCharacter then
                Osi.RemoveBoosts(activeCharacter, activeBoostString, 1, "", "")
                Log("✅ Boost removed after attack (one-shot mode)")
                Log("💡 TIP: Check the dice roll that appeared in-game!")
                activeBoost = nil
                activeBoostString = nil
                activeCharacter = nil
                BroadcastStatus("Attack completed - boost removed")
            end
        end)
    end
end)

-- Register command to check current stored roll value
Ext.RegisterConsoleCommand("checkroll", function(cmd)
    if activeBoost then
        Log("⚡ Boost is CURRENTLY ACTIVE on character: " .. tostring(activeCharacter))
    elseif nextRollValue then
        Log(string.format("📋 Next roll queued: %d", nextRollValue))
        Log("It will apply at the start of the next party member's turn")
    else
        Log("No roll value set or active. Use !setroll <number> to set one.")
    end
end)

-- Register command to clear stored roll value
Ext.RegisterConsoleCommand("clearroll", function(cmd)
    local hadSomething = false

    if activeBoost then
        Osi.RemoveBoosts(activeCharacter, activeBoostString, 1, "", "")
        Log("Cleared active boost")
        activeBoost = nil
        activeBoostString = nil
        activeCharacter = nil
        hadSomething = true
    end

    if nextRollValue then
        Log(string.format("Cleared queued roll value (%d)", nextRollValue))
        nextRollValue = nil
        hadSomething = true
    end

    if hadSomething then
        BroadcastStatus("Boost cleared")
    else
        Log("Nothing to clear")
        BroadcastStatus("No active boost to clear")
    end
end)


------- UI INTEGRATION -------

-- Listen for commands from the UI
Ext.RegisterNetListener("PhysicalDiceCommand", function(channel, payload, userId)
    local data = Ext.Json.Parse(payload)

    if data.command == "setroll" then
        local rollValue = data.value

        if rollValue < 1 or rollValue > 20 then
            BroadcastStatus("ERROR: Roll value must be between 1 and 20")
            return
        end

        Log(string.format("UI: Physical dice roll set to: %d", rollValue))

        -- Check if it's currently a party member's turn
        if currentTurnCharacter and Osi.IsPartyMember(currentTurnCharacter, 1) == 1 then
            ApplyBoost(currentTurnCharacter, rollValue)
            BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", rollValue))
        else
            nextRollValue = rollValue
            BroadcastStatus(string.format("Roll %d queued for next turn", rollValue))
        end

    elseif data.command == "clearroll" then
        if activeBoost then
            Osi.RemoveBoosts(activeCharacter, activeBoostString, 1, "", "")
            Log("UI: Cleared active boost")
            activeBoost = nil
            activeBoostString = nil
            activeCharacter = nil
        end

        if nextRollValue then
            Log(string.format("UI: Cleared queued roll value (%d)", nextRollValue))
            nextRollValue = nil
        end

        BroadcastStatus("Boost cleared")
    end
end)

-- Track combat state and notify clients
local inCombat = false

Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(characterGuid, combatGuid)
    local isPlayerCharacter = Osi.IsPartyMember(characterGuid, 1) == 1
    if isPlayerCharacter and not inCombat then
        inCombat = true
        local combatData = {
            inCombat = true
        }
        Ext.Net.BroadcastMessage("PhysicalDiceCombatState", Ext.Json.Stringify(combatData))
        Log("Combat started - UI should be visible")
    end
end)

Ext.Osiris.RegisterListener("LeftCombat", 2, "after", function(characterGuid, combatGuid)
    local isPlayerCharacter = Osi.IsPartyMember(characterGuid, 1) == 1
    if isPlayerCharacter then
        -- Check if any other party member is still in combat
        local anyInCombat = false
        -- We'll assume combat ended if this was called
        inCombat = false
        local combatData = {
            inCombat = false
        }
        Ext.Net.BroadcastMessage("PhysicalDiceCombatState", Ext.Json.Stringify(combatData))
        Log("Combat ended - UI should be hidden")
    end
end)

-- Console command to toggle UI
Ext.RegisterConsoleCommand("toggledice", function(cmd)
    local toggleData = {
        command = "toggle"
    }
    Ext.Net.BroadcastMessage("PhysicalDiceUICommand", Ext.Json.Stringify(toggleData))
    Log("Toggle UI command sent to clients")
end)

------- EXPORT API FOR MCM INTEGRATION -------

-- Export functions for MCM integration
_G.PhysicalDice = {
    -- Set roll value (called by MCM or console)
    SetRoll = function(rollValue)
        if rollValue < 1 or rollValue > 20 then
            Log("ERROR: Roll value must be between 1 and 20")
            return false
        end

        Log(string.format("API: Physical dice roll set to: %d", rollValue))

        -- Check if it's currently a party member's turn
        if currentTurnCharacter and Osi.IsPartyMember(currentTurnCharacter, 1) == 1 then
            ApplyBoost(currentTurnCharacter, rollValue)
            BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", rollValue))
        else
            nextRollValue = rollValue
            BroadcastStatus(string.format("Roll %d queued for next turn", rollValue))
        end
        return true
    end,

    -- Clear roll boost (called by MCM or console)
    ClearRoll = function()
        local hadSomething = false

        if activeBoost then
            Osi.RemoveBoosts(activeCharacter, activeBoostString, 1, "", "")
            Log("API: Cleared active boost")
            activeBoost = nil
            activeBoostString = nil
            activeCharacter = nil
            hadSomething = true
        end

        if nextRollValue then
            Log(string.format("API: Cleared queued roll value (%d)", nextRollValue))
            nextRollValue = nil
            hadSomething = true
        end

        if hadSomething then
            BroadcastStatus("Boost cleared")
        end
        return hadSomething
    end,

    -- Check current status
    GetStatus = function()
        return {
            hasActiveBoost = activeBoost ~= nil,
            hasQueuedRoll = nextRollValue ~= nil,
            queuedValue = nextRollValue,
            activeCharacter = activeCharacter,
            currentTurnCharacter = currentTurnCharacter
        }
    end
}

Log("Physical Dice Input System Loaded!")
Log("")
Log("═══════════════════════════════════════════════")
Log("🎲 PHYSICAL DICE MOD - READY")
Log("═══════════════════════════════════════════════")
Log("Commands:")
Log("  !setroll <1-20>  - Set your physical dice roll")
Log("  !checkroll       - Check current boost status")
Log("  !clearroll       - Clear boost/queued value")
Log("")
Log("HOW TO USE:")
Log("  Option 1 - MCM (If installed):")
Log("    - Press ESC > Mod Configuration Menu")
Log("    - Select 'Physical Dice Mod'")
Log("    - Use slider or hotkeys (F9/F10)")
Log("")
Log("  Option 2 - Console Commands:")
Log("    1. Your turn starts")
Log("    2. Roll your physical d20 (e.g., you get 15)")
Log("    3. Press F3 and type: !setroll 15")
Log("    4. Boost applies INSTANTLY")
Log("    5. Make your attack - roll will be EXACTLY 15")
Log("")
Log("NOTE: Boost locks roll to EXACT value using Min+Max")
Log("═══════════════════════════════════════════════")
