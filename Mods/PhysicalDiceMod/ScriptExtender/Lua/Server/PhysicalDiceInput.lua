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
            nextRollValue = nil
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
    end
end)

-- Register console command to set roll value
Ext.RegisterConsoleCommand("setroll", function(cmd, value)
    local rollValue = tonumber(value)

    if not rollValue then
        Log("ERROR: Invalid roll value. Usage: !setroll <number>")
        Log("Example: !setroll 15")
        return
    end

    if rollValue < 1 or rollValue > 20 then
        Log("ERROR: Roll value must be between 1 and 20")
        return
    end

    Log(string.format("✓ Physical dice roll set to: %d", rollValue))

    -- Check if it's currently a party member's turn
    if currentTurnCharacter and Osi.IsPartyMember(currentTurnCharacter, 1) == 1 then
        -- It's a party member's turn RIGHT NOW - apply immediately!
        Log("⚡ Applying boost IMMEDIATELY (it's your turn!)")
        ApplyBoost(currentTurnCharacter, rollValue)
    else
        -- Not a party member's turn - queue for next party turn
        nextRollValue = rollValue
        Log("📋 Boost queued - will apply at start of next party member's turn")
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
    if activeBoost then
        Osi.RemoveBoosts(activeCharacter, activeBoostString, 1, "", "")
        Log("Cleared active boost")
        activeBoost = nil
        activeBoostString = nil
        activeCharacter = nil
    end

    if nextRollValue then
        Log(string.format("Cleared queued roll value (%d)", nextRollValue))
        nextRollValue = nil
    end

    if not activeBoost and not nextRollValue then
        Log("Nothing to clear")
    end
end)


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
Log("  1. Your turn starts")
Log("  2. Roll your physical d20 (e.g., you get 15)")
Log("  3. Type: !setroll 15")
Log("  4. Boost applies INSTANTLY")
Log("  5. Make your attack - roll will be EXACTLY 15")
Log("")
Log("NOTE: Boost locks roll to EXACT value using Min+Max")
Log("═══════════════════════════════════════════════")
