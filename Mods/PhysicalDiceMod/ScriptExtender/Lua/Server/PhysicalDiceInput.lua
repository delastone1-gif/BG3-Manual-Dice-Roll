-- PhysicalDiceInput.lua
-- Console command system for inputting physical dice rolls

local function Log(message)
    Ext.Utils.Print("[PhysicalDiceInput] " .. tostring(message))
end

Log("Physical Dice Input System Loading...")

-- Store the next roll value and current turn
local nextRollValue = nil
local activeBoostString = nil
local activeBoostedCharacters = {}  -- Track ALL characters with active boosts
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
        hasActiveBoost = #activeBoostedCharacters > 0,
        hasQueuedRoll = nextRollValue ~= nil,
        queuedValue = nextRollValue
    }

    Ext.Net.BroadcastMessage("PhysicalDiceStatus", Ext.Json.Stringify(statusData))
end

-- Function to get all party members
local function GetAllPartyMembers()
    local party = {}
    local players = Osi.DB_Players:Get(nil)
    for _, playerData in pairs(players) do
        local characterGuid = playerData[1]
        if Osi.IsPartyMember(characterGuid, 1) == 1 then
            table.insert(party, characterGuid)
        end
    end
    return party
end

-- Function to apply boost to ALL party members
local function ApplyBoost(rollValue)
    Log("═══════════════════════════════════════════════")
    Log(string.format("🎲 APPLYING PHYSICAL DICE ROLL: %d", rollValue))
    Log("═══════════════════════════════════════════════")

    -- Remove old boosts if exist
    if activeBoostString and #activeBoostedCharacters > 0 then
        for _, characterGuid in ipairs(activeBoostedCharacters) do
            Osi.RemoveBoosts(characterGuid, activeBoostString, 1, "", "")
        end
        Log(string.format("Removed previous boost from %d party members", #activeBoostedCharacters))
        activeBoostedCharacters = {}
    end

    -- Apply new boost to ALL party members
    activeBoostString = CreateBoostString(rollValue)
    local partyMembers = GetAllPartyMembers()

    for _, characterGuid in ipairs(partyMembers) do
        Osi.AddBoosts(characterGuid, activeBoostString, "", "")
        table.insert(activeBoostedCharacters, characterGuid)
    end

    Log(string.format("✅ Boost ACTIVE on %d party members! Roll LOCKED to EXACTLY %d", #activeBoostedCharacters, rollValue))
    Log("📺 CHECK IN-GAME: Next party member dice roll should show EXACTLY " .. rollValue)
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
            ApplyBoost(nextRollValue)
            BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", nextRollValue))
            nextRollValue = nil
        else
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
    end
end)


Ext.Osiris.RegisterListener("TurnEnded", 1, "after", function(characterGuid)
    if characterGuid == currentTurnCharacter then
        currentTurnCharacter = nil
    end

    -- Remove boost at turn end (from all party members)
    if #activeBoostedCharacters > 0 and activeBoostString then
        for _, boostedCharacter in ipairs(activeBoostedCharacters) do
            Osi.RemoveBoosts(boostedCharacter, activeBoostString, 1, "", "")
        end
        Log(string.format("✅ Boost removed at end of turn from %d party members", #activeBoostedCharacters))
        activeBoostedCharacters = {}
        activeBoostString = nil
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
            ApplyBoost(mcmValue)
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
        Log("⚡ Applying boost IMMEDIATELY to ALL party members!")
        ApplyBoost(rollValue)
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
    -- Check if the attacker has an active boost
    for _, boostedCharacter in ipairs(activeBoostedCharacters) do
        if attacker == boostedCharacter then
            Log("⚔️  ATTACK STARTED - Boost is ACTIVE for this roll!")
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

    if attackerHadBoost and #activeBoostedCharacters > 0 then
        Ext.Timer.WaitFor(100, function()
            if #activeBoostedCharacters > 0 and activeBoostString then
                -- Remove boost from ALL party members
                for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                    Osi.RemoveBoosts(boostedCharacter, activeBoostString, 1, "", "")
                end
                Log("✅ Boost removed after attack (one-shot mode)")
                Log("💡 TIP: Check the dice roll that appeared in-game!")
                activeBoostedCharacters = {}
                activeBoostString = nil
                BroadcastStatus("Attack completed - boost removed")
            end
        end)
    end
end)

-- Register command to check current stored roll value
Ext.RegisterConsoleCommand("checkroll", function(cmd)
    if #activeBoostedCharacters > 0 then
        Log(string.format("⚡ Boost is CURRENTLY ACTIVE on %d party members", #activeBoostedCharacters))
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

    if #activeBoostedCharacters > 0 and activeBoostString then
        for _, boostedCharacter in ipairs(activeBoostedCharacters) do
            Osi.RemoveBoosts(boostedCharacter, activeBoostString, 1, "", "")
        end
        Log(string.format("Cleared active boost from %d party members", #activeBoostedCharacters))
        activeBoostedCharacters = {}
        activeBoostString = nil
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
            ApplyBoost(rollValue)
            BroadcastStatus(string.format("Boost ACTIVE! Roll locked to %d", rollValue))
        else
            nextRollValue = rollValue
            BroadcastStatus(string.format("Roll %d queued for next turn", rollValue))
        end

    elseif data.command == "clearroll" then
        if #activeBoostedCharacters > 0 and activeBoostString then
            for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                Osi.RemoveBoosts(boostedCharacter, activeBoostString, 1, "", "")
            end
            Log(string.format("UI: Cleared active boost from %d party members", #activeBoostedCharacters))
            activeBoostedCharacters = {}
            activeBoostString = nil
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
            ApplyBoost(rollValue)
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

        if #activeBoostedCharacters > 0 and activeBoostString then
            for _, boostedCharacter in ipairs(activeBoostedCharacters) do
                Osi.RemoveBoosts(boostedCharacter, activeBoostString, 1, "", "")
            end
            Log(string.format("API: Cleared active boost from %d party members", #activeBoostedCharacters))
            activeBoostedCharacters = {}
            activeBoostString = nil
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
            hasActiveBoost = #activeBoostedCharacters > 0,
            hasQueuedRoll = nextRollValue ~= nil,
            queuedValue = nextRollValue,
            activeBoostedCharacters = activeBoostedCharacters,
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
