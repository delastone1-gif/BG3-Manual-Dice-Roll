-- PhysicalDiceInput.lua
-- Console command system for inputting physical dice rolls
-- v1.2.1: Refactored to use combined boost approach to prevent interference

local function Log(message)
    Ext.Utils.Print("[PhysicalDiceInput] " .. tostring(message))
end

Log("Physical Dice Input System Loading...")

-- Store the next roll value and current turn
local nextRollValue = nil
local currentTurnCharacter = nil  -- Track whose turn it is

-- COMBINED BOOST APPROACH: Track values separately, build one boost
local currentRollValue = nil      -- nil or 1-20
local currentDamageValue = nil    -- nil or 1-80
local activeCombinedBoostString = nil
local activeBoostedCharacters = {}  -- Track ALL characters with active boosts

-- Function to build combined boost string from current values
local function BuildCombinedBoost()
    local parts = {}

    -- Add attack roll parts if roll value is set
    if currentRollValue then
        local rollVal = currentRollValue
        table.insert(parts, string.format("MinimumRollResult(Attack,%d)", rollVal))
        table.insert(parts, string.format("MaximumRollResult(Attack,%d)", rollVal))
        table.insert(parts, string.format("MinimumRollResult(RawAbility,%d)", rollVal))
        table.insert(parts, string.format("MaximumRollResult(RawAbility,%d)", rollVal))
        table.insert(parts, string.format("MinimumRollResult(SkillCheck,%d)", rollVal))
        table.insert(parts, string.format("MaximumRollResult(SkillCheck,%d)", rollVal))
        table.insert(parts, string.format("MinimumRollResult(SavingThrow,%d)", rollVal))
        table.insert(parts, string.format("MaximumRollResult(SavingThrow,%d)", rollVal))
    end

    -- Add damage parts if damage value is set
    if currentDamageValue then
        local dmgVal = currentDamageValue
        table.insert(parts, string.format("MinimumRollResult(Damage,%d)", dmgVal))
        table.insert(parts, string.format("MaximumRollResult(Damage,%d)", dmgVal))
    end

    if #parts == 0 then
        return nil  -- No boost to apply
    end

    return table.concat(parts, ";")
end

-- Function to apply the combined boost to ALL party members
local function ApplyCombinedBoost()
    -- Remove old boost if exists
    if activeCombinedBoostString and #activeBoostedCharacters > 0 then
        for _, characterGuid in ipairs(activeBoostedCharacters) do
            Osi.RemoveBoosts(characterGuid, activeCombinedBoostString, 1, "", "")
        end
        activeBoostedCharacters = {}
    end

    -- Build new combined boost
    activeCombinedBoostString = BuildCombinedBoost()

    if not activeCombinedBoostString then
        Log("No boost to apply (both values are nil)")
        return
    end

    -- Apply to ALL party members
    local partyMembers = {}
    local players = Osi.DB_Players:Get(nil)
    for _, playerData in pairs(players) do
        local characterGuid = playerData[1]
        if Osi.IsPartyMember(characterGuid, 1) == 1 then
            table.insert(partyMembers, characterGuid)
        end
    end

    for _, characterGuid in ipairs(partyMembers) do
        Osi.AddBoosts(characterGuid, activeCombinedBoostString, "", "")
        table.insert(activeBoostedCharacters, characterGuid)
    end

    -- Log what was applied
    local statusParts = {}
    if currentRollValue then
        table.insert(statusParts, string.format("Attack=%d", currentRollValue))
    end
    if currentDamageValue then
        table.insert(statusParts, string.format("Damage=%d", currentDamageValue))
    end
    Log(string.format("✅ Combined boost ACTIVE on %d party members [%s]",
        #activeBoostedCharacters, table.concat(statusParts, ", ")))
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
        hasActiveBoost = #activeBoostedCharacters > 0,
        hasQueuedRoll = nextRollValue ~= nil,
        queuedValue = nextRollValue
    }

    Ext.Net.BroadcastMessage("PhysicalDiceStatus", Ext.Json.Stringify(statusData))
end

-- Function to apply attack roll boost
local function ApplyBoost(rollValue)
    Log("═══════════════════════════════════════════════")
    Log(string.format("🎲 APPLYING PHYSICAL DICE ROLL: %d", rollValue))
    Log("═══════════════════════════════════════════════")

    -- Update the tracked value
    currentRollValue = rollValue

    -- Apply combined boost (includes damage if set)
    ApplyCombinedBoost()

    Log("📺 CHECK IN-GAME: Next party member dice roll should show EXACTLY " .. rollValue)
    Log("═══════════════════════════════════════════════")
end

-- Function to apply damage boost
local function ApplyDamageBoost(damageValue)
    Log("═══════════════════════════════════════════════")
    Log(string.format("💥 APPLYING DAMAGE ROLL: %d", damageValue))
    Log("═══════════════════════════════════════════════")

    -- Update the tracked value
    currentDamageValue = damageValue

    -- Apply combined boost (includes attack roll if set)
    ApplyCombinedBoost()

    Log("📺 CHECK IN-GAME: Next damage roll should be EXACTLY " .. damageValue)
    Log("═══════════════════════════════════════════════")
end

-- Track whose turn it is
Ext.Osiris.RegisterListener("TurnStarted", 1, "after", function(characterGuid)
    currentTurnCharacter = characterGuid
    local isPlayerCharacter = Osi.IsPartyMember(characterGuid, 1) == 1

    if isPlayerCharacter then
        Log(string.format("🔄 Party member turn started: %s", characterGuid))

        -- Check if MCM auto-apply is enabled
        if _G.PhysicalDiceMCM and _G.PhysicalDiceMCM.CheckAutoApply() then
            local mcmRollValue = _G.PhysicalDiceMCM.GetMCMSetting("current_roll_value")
            if mcmRollValue and mcmRollValue >= 1 and mcmRollValue <= 20 then
                ApplyBoost(mcmRollValue)
                BroadcastStatus(string.format("AUTO-APPLIED from MCM: Roll locked to %d", mcmRollValue))
                Log("MCM auto-apply activated")
            else
                BroadcastStatus("Your turn - ready for roll input")
            end
        else
            BroadcastStatus("Your turn - ready for roll input")
        end
    end
end)


Ext.Osiris.RegisterListener("TurnEnded", 1, "after", function(characterGuid)
    if characterGuid == currentTurnCharacter then
        currentTurnCharacter = nil
    end

    -- Remove boost at turn end (from all party members)
    if #activeBoostedCharacters > 0 and activeCombinedBoostString then
        for _, boostedCharacter in ipairs(activeBoostedCharacters) do
            Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
        end
        Log(string.format("✅ Combined boost removed at end of turn from %d party members", #activeBoostedCharacters))
        activeBoostedCharacters = {}
        activeCombinedBoostString = nil
        currentRollValue = nil
        currentDamageValue = nil
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

        -- Apply boost immediately - works even when loading mid-combat
        ApplyBoost(mcmValue)
        BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", mcmValue))
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

    -- Apply boost immediately - works even when loading mid-combat
    Log("⚡ Applying combined boost IMMEDIATELY to ALL party members!")
    ApplyBoost(rollValue)
    BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", rollValue))
end)

-- Track attack data for logging
local pendingAttackData = {}

-- Log attacks when boost is active
Ext.Osiris.RegisterListener("StartAttack", 4, "after", function(target, attackerOwner, attacker, unknown)
    -- Check if the attacker has an active boost
    for _, boostedCharacter in ipairs(activeBoostedCharacters) do
        if attacker == boostedCharacter then
            local attackerName = Osi.GetDisplayName(attackerOwner) or "Unknown"
            local targetName = Osi.GetDisplayName(target) or "Unknown"
            Log(string.format("⚔️  ATTACK: %s → %s (Boost ACTIVE)", attackerName, targetName))

            -- Store attack info for result logging
            pendingAttackData[attackerOwner] = {
                attacker = attackerName,
                target = targetName,
                expectedRoll = currentRollValue or "?"
            }
            break
        end
    end
end)

-- Remove boost after first attack (one-shot mode)
Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(defender, attackerOwner, attacker2, damageType, damageAmount, damageCause, storyActionID)
    -- Check if the attacker has an active boost
    local attackerHadBoost = false
    for _, boostedCharacter in ipairs(activeBoostedCharacters) do
        if attackerOwner == boostedCharacter then
            attackerHadBoost = true
            break
        end
    end

    -- Log attack result if we have stored data
    if pendingAttackData[attackerOwner] then
        local attackData = pendingAttackData[attackerOwner]
        local hit = damageAmount > 0
        local result = hit and "✅ HIT" or "❌ MISS"
        local dmgText = hit and string.format(" - Damage: %d %s", damageAmount, damageType) or ""

        Log(string.format("🎯 RESULT: %s%s (Expected roll: %s)", result, dmgText, attackData.expectedRoll))
        pendingAttackData[attackerOwner] = nil
    end

    -- Remove combined boost if needed (one-shot mode)
    if attackerHadBoost and #activeBoostedCharacters > 0 then
        Ext.Timer.WaitFor(100, function()
            if #activeBoostedCharacters > 0 and activeCombinedBoostString then
                -- Remove combined boost from ALL party members
                for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                    Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
                end

                local hadRoll = currentRollValue ~= nil
                local hadDamage = currentDamageValue ~= nil

                Log("✅ Combined boost removed after attack (one-shot mode)")
                if hadRoll then Log("  └─ Attack roll boost cleared") end
                if hadDamage then Log("  └─ Damage boost cleared") end

                activeBoostedCharacters = {}
                activeCombinedBoostString = nil
                currentRollValue = nil
                currentDamageValue = nil
                BroadcastStatus("Attack completed - all boosts removed")
            end
        end)
    end
end)

-- Register command to check current stored roll value
Ext.RegisterConsoleCommand("checkroll", function(cmd)
    if #activeBoostedCharacters > 0 then
        local statusParts = {}
        if currentRollValue then
            table.insert(statusParts, string.format("Attack Roll=%d", currentRollValue))
        end
        if currentDamageValue then
            table.insert(statusParts, string.format("Damage=%d", currentDamageValue))
        end
        Log(string.format("⚡ Boost is CURRENTLY ACTIVE on %d party members", #activeBoostedCharacters))
        Log("   Active values: " .. table.concat(statusParts, ", "))
    else
        Log("No boost currently active. Use !setroll <number> or !setdamage <number> to apply one.")
    end
end)

-- Register command to clear stored roll value
Ext.RegisterConsoleCommand("clearroll", function(cmd)
    local hadSomething = false

    if #activeBoostedCharacters > 0 and activeCombinedBoostString then
        for _, boostedCharacter in ipairs(activeBoostedCharacters) do
            Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
        end
        Log(string.format("Cleared combined boost from %d party members", #activeBoostedCharacters))
        activeBoostedCharacters = {}
        activeCombinedBoostString = nil
        currentRollValue = nil
        currentDamageValue = nil
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

-- Register console command to set damage roll value
Ext.RegisterConsoleCommand("setdamage", function(cmd, value)
    local damageValue = tonumber(value)

    if not damageValue then
        Log("ERROR: Invalid damage value. Usage: !setdamage <number>")
        Log("Example: !setdamage 50")
        return
    end

    if damageValue < 1 or damageValue > 80 then
        Log("ERROR: Damage value must be between 1 and 80")
        return
    end

    Log(string.format("✓ Physical damage roll set to: %d", damageValue))
    ApplyDamageBoost(damageValue)
end)

-- Register command to clear damage boost
Ext.RegisterConsoleCommand("cleardamage", function(cmd)
    if currentDamageValue then
        currentDamageValue = nil

        -- Re-apply combined boost (may now only have attack roll, or be nil)
        if activeCombinedBoostString and #activeBoostedCharacters > 0 then
            for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
            end
            activeBoostedCharacters = {}
        end

        ApplyCombinedBoost()
        Log("Cleared damage boost")
    else
        Log("No damage boost to clear")
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

        -- Apply boost immediately - works even when loading mid-combat
        ApplyBoost(rollValue)
        BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", rollValue))

    elseif data.command == "clearroll" then
        if #activeBoostedCharacters > 0 and activeCombinedBoostString then
            for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
            end
            Log(string.format("UI: Cleared combined boost from %d party members", #activeBoostedCharacters))
            activeBoostedCharacters = {}
            activeCombinedBoostString = nil
            currentRollValue = nil
            currentDamageValue = nil
        end

        if nextRollValue then
            Log(string.format("UI: Cleared queued roll value (%d)", nextRollValue))
            nextRollValue = nil
        end

        BroadcastStatus("Boost cleared")

    elseif data.command == "setdamage" then
        local damageValue = data.value

        if damageValue < 1 or damageValue > 80 then
            Log("ERROR: Damage value must be between 1 and 80")
            return
        end

        Log(string.format("UI: Physical damage roll set to: %d", damageValue))
        ApplyDamageBoost(damageValue)

    elseif data.command == "cleardamage" then
        if currentDamageValue then
            currentDamageValue = nil

            -- Re-apply combined boost (may now only have attack roll, or be nil)
            if activeCombinedBoostString and #activeBoostedCharacters > 0 then
                for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                    Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
                end
                activeBoostedCharacters = {}
            end

            ApplyCombinedBoost()
            Log("UI: Cleared damage boost")
        end
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

        -- Apply boost immediately - works even when loading mid-combat
        ApplyBoost(rollValue)
        BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", rollValue))
        return true
    end,

    -- Clear roll boost (called by MCM or console)
    ClearRoll = function()
        local hadSomething = false

        if #activeBoostedCharacters > 0 and activeCombinedBoostString then
            for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
            end
            Log(string.format("API: Cleared combined boost from %d party members", #activeBoostedCharacters))
            activeBoostedCharacters = {}
            activeCombinedBoostString = nil
            currentRollValue = nil
            currentDamageValue = nil
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

    -- Set damage value (called by MCM or console)
    SetDamage = function(damageValue)
        if damageValue < 1 or damageValue > 80 then
            Log("ERROR: Damage value must be between 1 and 80")
            return false
        end

        Log(string.format("API: Physical damage roll set to: %d", damageValue))

        -- Apply damage boost immediately
        ApplyDamageBoost(damageValue)
        return true
    end,

    -- Clear damage boost (called by MCM or console)
    ClearDamage = function()
        local hadSomething = false

        if currentDamageValue then
            currentDamageValue = nil

            -- Re-apply combined boost (may now only have attack roll, or be nil)
            if activeCombinedBoostString and #activeBoostedCharacters > 0 then
                for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                    Osi.RemoveBoosts(boostedCharacter, activeCombinedBoostString, 1, "", "")
                end
                activeBoostedCharacters = {}
            end

            ApplyCombinedBoost()
            Log("API: Cleared damage boost")
            hadSomething = true
        end

        return hadSomething
    end,

    -- Check current status
    GetStatus = function()
        return {
            hasActiveBoost = #activeBoostedCharacters > 0,
            hasActiveDamageBoost = currentDamageValue ~= nil,
            hasQueuedRoll = nextRollValue ~= nil,
            queuedValue = nextRollValue,
            currentRollValue = currentRollValue,
            currentDamageValue = currentDamageValue,
            activeBoostedCharacters = activeBoostedCharacters,
            currentTurnCharacter = currentTurnCharacter
        }
    end
}

Log("Physical Dice Input System Loaded!")
Log("")
Log("═══════════════════════════════════════════════")
Log("🎲 PHYSICAL DICE MOD v1.2.1-COMBINED (2026-01-30)")
Log("   Build: Combined Boost System (NO INTERFERENCE)")
Log("   Script Extender: v29")
Log("═══════════════════════════════════════════════")
Log("Commands:")
Log("  !setroll <1-20>    - Set your physical dice roll")
Log("  !setdamage <1-80>  - Set your physical damage roll")
Log("  !checkroll         - Check current boost status")
Log("  !clearroll         - Clear all boosts")
Log("  !cleardamage       - Clear damage boost only")
Log("")
Log("HOW TO USE:")
Log("  Option 1 - MCM (If installed):")
Log("    - Press ESC > Mod Configuration Menu")
Log("    - Select 'Physical Dice Mod'")
Log("    - Use sliders and buttons")
Log("")
Log("  Option 2 - Console Commands:")
Log("    1. Your turn starts")
Log("    2. Roll your physical dice")
Log("    3. Press F3 and type: !setroll 15 (for attack)")
Log("    4. Or type: !setdamage 50 (for damage)")
Log("    5. Make your attack/spell - values locked!")
Log("")
Log("NEW: Combined boost system - no interference!")
Log("═══════════════════════════════════════════════")
