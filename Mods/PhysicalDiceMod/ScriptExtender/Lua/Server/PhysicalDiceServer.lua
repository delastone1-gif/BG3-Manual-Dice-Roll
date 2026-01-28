-- PhysicalDiceServer.lua
-- Server-side script for Physical Dice Input mod
-- This is a DISCOVERY script to log events and find roll interception points

-- Helper function to log with prefix
local function Log(message)
    Ext.Utils.Print("[PhysicalDice] " .. tostring(message))
end

Log("Physical Dice Mod - Server Script Loaded!")

-- Store pending rolls
PendingRolls = {}

------- EVENT DISCOVERY & LOGGING -------

-- Log when attacks happen (this event is confirmed to exist)
Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(defender, attackerOwner, attacker2, damageType, damageAmount, damageCause, storyActionID)
    Log(string.format("AttackedBy Event: Defender=%s, Attacker=%s, Damage=%s (%s)",
        tostring(defender), tostring(attackerOwner), tostring(damageAmount), tostring(damageType)))
end)

-- Log turn events
Ext.Osiris.RegisterListener("TurnEnded", 1, "after", function(characterGuid)
    Log("TurnEnded: " .. tostring(characterGuid))
end)

Ext.Osiris.RegisterListener("TurnStarted", 1, "after", function(characterGuid)
    Log("TurnStarted: " .. tostring(characterGuid))
end)

-- Log combat start/end
Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(characterGuid, combatGuid)
    Log("EnteredCombat: Character=" .. tostring(characterGuid) .. ", Combat=" .. tostring(combatGuid))
end)

Ext.Osiris.RegisterListener("LeftCombat", 2, "after", function(characterGuid, combatGuid)
    Log("LeftCombat: Character=" .. tostring(characterGuid))
end)

-- Try to catch skill check events (may or may not exist)
local function TryRegisterEvent(eventName, arity)
    local success, err = pcall(function()
        Ext.Osiris.RegisterListener(eventName, arity, "after", function(...)
            local args = {...}
            local argStr = ""
            for i, v in ipairs(args) do
                argStr = argStr .. tostring(v) .. ", "
            end
            Log(eventName .. " Event: " .. argStr)
        end)
    end)
    if success then
        Log("Successfully registered: " .. eventName)
    else
        Log("Failed to register: " .. eventName .. " - " .. tostring(err))
    end
end

-- Try various possible event names
TryRegisterEvent("RolledSkillCheck", 3)
TryRegisterEvent("RolledAttack", 3)
TryRegisterEvent("SkillCheck", 2)
TryRegisterEvent("AttackRolled", 4)

-- Try RollResult with different arities to find the right one
TryRegisterEvent("RollResult", 1)
TryRegisterEvent("RollResult", 2)
TryRegisterEvent("RollResult", 3)
TryRegisterEvent("RollResult", 4)
TryRegisterEvent("RollResult", 5)
TryRegisterEvent("RollResult", 6)

-- Try StartAttack and related attack events
TryRegisterEvent("StartAttack", 1)
TryRegisterEvent("StartAttack", 2)
TryRegisterEvent("StartAttack", 3)
TryRegisterEvent("StartAttack", 4)

------- MESSAGE HANDLERS -------

-- Handle dice input from client
Ext.RegisterNetListener("DiceRollInput", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    Log("Received dice input: " .. tostring(data.result))
    -- TODO: Apply the custom roll result
    -- This part will be implemented once we discover how to intercept rolls
end)

Log("Server script initialization complete")