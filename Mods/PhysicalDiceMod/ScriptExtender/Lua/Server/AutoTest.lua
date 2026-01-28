-- AutoTest.lua
-- Automatically test the boost system

local function Log(message)
    Ext.Utils.Print("[AutoTest] " .. tostring(message))
end

Log("Auto Test System Loading...")

-- Set this to true to enable automatic testing
local AUTO_TEST_ENABLED = false  -- DISABLED - Using console command system instead
local TEST_ROLL_VALUE = 18  -- Change this to test different values

if AUTO_TEST_ENABLED then
    Log("AUTO TEST MODE ENABLED - Rolls will be set to " .. TEST_ROLL_VALUE .. " during player turns")

    local activeBoost = nil
    local boostString = string.format(
        "MinimumRollResult(Attack,%d);MinimumRollResult(RawAbility,%d);MinimumRollResult(SkillCheck,%d);MinimumRollResult(SavingThrow,%d)",
        TEST_ROLL_VALUE, TEST_ROLL_VALUE, TEST_ROLL_VALUE, TEST_ROLL_VALUE
    )

    -- Apply boost when player's turn starts
    Ext.Osiris.RegisterListener("TurnStarted", 1, "after", function(characterGuid)
        -- Check if this is a party member (player-controlled character)
        local isPlayerCharacter = Osi.IsPartyMember(characterGuid, 1) == 1

        if isPlayerCharacter then
            Log(string.format("Turn started - Player character detected: %s", characterGuid))
            Log("=== PLAYER TURN STARTED ===")
            Log("Applying test boost - rolls will be at least " .. TEST_ROLL_VALUE)
            Osi.AddBoosts(characterGuid, boostString, "", "")
            activeBoost = characterGuid
        end
    end)

    -- Remove boost when player's turn ends
    Ext.Osiris.RegisterListener("TurnEnded", 1, "after", function(characterGuid)
        if characterGuid == activeBoost then
            Log("=== PLAYER TURN ENDED ===")
            Log("Removing test boost")
            Osi.RemoveBoosts(characterGuid, boostString, 1, "", "")
            activeBoost = nil
        end
    end)
else
    Log("Auto test disabled")
end

Log("Auto Test System Loaded!")
