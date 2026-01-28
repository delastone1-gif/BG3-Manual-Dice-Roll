-- BoostRollSystem.lua
-- Uses BG3's boost system to set dice roll results based on physical dice input

local function Log(message)
    Ext.Utils.Print("[BoostRollSystem] " .. tostring(message))
end

Log("Boost Roll System Loading...")

-- Store active boost for cleanup
local activeBoost = nil
local targetCharacter = nil

-- Function to set a specific roll result using boosts
function SetRollResult(characterUuid, rollValue)
    Log(string.format("Setting roll result to %d for character %s", rollValue, characterUuid))

    -- Remove previous boost if exists
    if activeBoost and targetCharacter then
        Osi.RemoveBoosts(targetCharacter, activeBoost, 1, "", "")
        Log("Removed previous boost")
    end

    -- Create boost string for minimum roll result
    -- This sets the minimum for all roll types to ensure it works
    local boostString = string.format(
        "MinimumRollResult(Attack,%d);MinimumRollResult(RawAbility,%d);MinimumRollResult(SkillCheck,%d);MinimumRollResult(SavingThrow,%d)",
        rollValue, rollValue, rollValue, rollValue
    )

    Log("Applying boost: " .. boostString)

    -- Apply the boost
    Osi.AddBoosts(characterUuid, boostString, "", "")

    -- Store for cleanup
    activeBoost = boostString
    targetCharacter = characterUuid

    -- Schedule removal after a short delay (1 second) so only the next roll is affected
    Ext.Timer.WaitFor(1000, function()
        if targetCharacter and activeBoost then
            Osi.RemoveBoosts(targetCharacter, activeBoost, 1, "", "")
            Log("Auto-removed boost after timeout")
            activeBoost = nil
            targetCharacter = nil
        end
    end)
end

-- Function to clear active boost immediately
function ClearRollBoost()
    if activeBoost and targetCharacter then
        Osi.RemoveBoosts(targetCharacter, activeBoost, 1, "", "")
        Log("Manually cleared boost")
        activeBoost = nil
        targetCharacter = nil
    end
end

-- Test function you can call from console
function TestSetRoll(characterName, value)
    -- Get player character UUID
    local player = Osi.GetHostCharacter()
    if player then
        SetRollResult(player, value)
        Log(string.format("Test: Set next roll to %d", value))
    else
        Log("ERROR: Could not find player character")
    end
end

-- Register network listener for client requests
Ext.RegisterNetListener("SetPhysicalDiceRoll", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    Log(string.format("Received dice input: %d for character %s", data.rollValue, data.characterUuid))
    SetRollResult(data.characterUuid, data.rollValue)
end)

Log("Boost Roll System Loaded!")
Log("To test, use: Ext.ServerEntity.Get(Osi.GetHostCharacter()).Vars.PhysicalDiceMod = {...}")
