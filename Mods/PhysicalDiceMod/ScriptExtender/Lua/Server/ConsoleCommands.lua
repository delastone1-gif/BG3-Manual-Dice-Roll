-- ConsoleCommands.lua
-- Register console commands for testing

local function Log(message)
    Ext.Utils.Print("[ConsoleCommands] " .. tostring(message))
end

Log("Registering console commands...")

-- Register a console command to test setting dice rolls
Ext.RegisterConsoleCommand("testdice", function(cmd, value)
    local rollValue = tonumber(value) or 20
    local player = Osi.GetHostCharacter()

    if not player then
        Log("ERROR: No host character found")
        return
    end

    Log(string.format("Setting next roll to %d for player", rollValue))

    local boostString = string.format(
        "MinimumRollResult(Attack,%d);MinimumRollResult(RawAbility,%d);MinimumRollResult(SkillCheck,%d);MinimumRollResult(SavingThrow,%d)",
        rollValue, rollValue, rollValue, rollValue
    )

    Osi.AddBoosts(player, boostString, "", "")
    Log("Boost applied! Make an attack or check now.")

    -- Auto-remove after 2 seconds
    Ext.Timer.WaitFor(2000, function()
        Osi.RemoveBoosts(player, boostString, 1, "", "")
        Log("Boost removed")
    end)
end)

Log("Console commands registered! Use: !testdice 15")
