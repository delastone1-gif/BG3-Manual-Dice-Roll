-- PhysicalDiceClient.lua
-- Client-side script for Physical Dice Input mod

-- Helper function to log with prefix
local function Log(message)
    Ext.Utils.Print("[PhysicalDice-Client] " .. tostring(message))
end

Log("Physical Dice Mod - Client Script Loaded!")

------- MESSAGE HANDLERS -------

-- Register for server messages requesting dice rolls
Ext.RegisterNetListener("RequestDiceRoll", function(channel, payload)
    Log("Received roll request from server")
    local data = Ext.Json.Parse(payload)
    Log(string.format("Roll Type: %s, Die Type: %s", tostring(data.rollType), tostring(data.dieType)))

    -- TODO: Show UI for input
    -- For now, just log that we received the request
    -- Later we'll implement a proper input dialog
end)

------- TEST FUNCTION -------

-- Test function to send a sample dice roll to server (for testing)
function TestSendDiceRoll(value)
    Log("Sending test dice roll: " .. tostring(value))
    Ext.Net.PostMessageToServer("DiceRollInput", Ext.Json.Stringify({result = value}))
end

Log("Client script initialization complete")