-- RollInterceptor.lua (CLIENT SIDE)
-- Intercepts dice rolls using RequestedRoll component

local function Log(message)
    Ext.Utils.Print("[RollInterceptor-CLIENT] " .. tostring(message))
end

Log("Roll Interceptor Loading...")

-- Subscribe to entity events to catch new rolls
Ext.Entity.Subscribe("RequestedRoll", function(entity, component, isCreate)
    if not isCreate then return end  -- Only care about new rolls

    local rollData = entity.RequestedRoll
    if not rollData then return end

    -- Log the roll details
    Log("=== NEW ROLL DETECTED ===")
    Log("Roll UUID: " .. tostring(rollData.RollUuid))
    Log("Roller: " .. tostring(rollData.Roller))
    Log("DC: " .. tostring(rollData.DC))
    Log("Ability: " .. tostring(rollData.Ability))
    Log("Skill: " .. tostring(rollData.Skill))
    Log("Advantage: " .. tostring(rollData.AdvantageType))
    Log("Natural Roll: " .. tostring(rollData.NaturalRoll))
    Log("Finished: " .. tostring(rollData.Finished))

    -- If roll is not finished yet, we could modify it
    if not rollData.Finished then
        Log("Roll is still in progress - could be modified!")

        -- EXAMPLE: Override the natural roll
        -- rollData.NaturalRoll = 20  -- Force a natural 20!

        -- For your physical dice mod, you would:
        -- 1. Pause here
        -- 2. Show UI asking for physical dice input
        -- 3. Set rollData.NaturalRoll to the input value
    end
end)

Log("Roll Interceptor Loaded!")
