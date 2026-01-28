-- RollInterceptor.lua
-- Intercepts dice rolls using RequestedRoll component

local function Log(message)
    Ext.Utils.Print("[RollInterceptor] " .. tostring(message))
end

Log("Roll Interceptor Loading...")

-- Subscribe to entity events to catch new rolls
Ext.Entity.Subscribe("RequestedRoll", function(entity, component, isCreate)
    if not isCreate then return end  -- Only care about new rolls

    local rollData = entity.RequestedRoll
    if not rollData then return end

    -- Log the roll details prominently
    Log("═══════════════════════════════════")
    Log("📊 ROLL DETECTED")
    Log("═══════════════════════════════════")
    Log("Natural Roll: " .. tostring(rollData.NaturalRoll) .. " (d20)")
    Log("DC Target: " .. tostring(rollData.DC))
    Log("Ability: " .. tostring(rollData.Ability))
    Log("Skill: " .. tostring(rollData.Skill))
    Log("Advantage: " .. tostring(rollData.AdvantageType))
    Log("Finished: " .. tostring(rollData.Finished))
    Log("═══════════════════════════════════")

    -- If roll is not finished yet, we could modify it
    if not rollData.Finished then
        Log("⚠️ Roll in progress - modifiable!")
    end
end)

Log("Roll Interceptor Loaded!")
Log("NOTE: Only server-side rolls (saving throws) are visible here")
Log("Attack rolls happen client-side and won't appear in this log")
