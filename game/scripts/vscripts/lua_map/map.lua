require( "libraries/Timers" )
if map == nil then
    map = class({})
end

--LinkLuaModifier( "outside_map_ability_modifier", "lua_map/outside_hurt_mod.lua", LUA_MODIFIER_MOTION_NONE )
function OnExitMap(trigger)
    local ent = trigger.activator
    if not ent then print("xd") return end
    local applier = CreateItem("item_exitmap_modifier", nil, nil)
    if ent:IsAlive() then
        FindClearSpaceForUnit(ent, Vector(2230.66, -3206.13, 256), true)
        if not ent:HasModifier("modifier_movespeed_minus_constant") then
            applier:ApplyDataDrivenModifier(ent, ent, "modifier_movespeed_minus_constant", {})
            ent:SetModifierStackCount("modifier_movespeed_minus_constant", ent, 1)
        end
        print ("someone try to leave the map , tp back to spawn")
    end
end

function OnWaterEnter(trigger)
    local ent = trigger.activator
    print (ent:GetName())
    ent.InWater = true
    print (ent.InWater)
end

function OnWaterExit(trigger)
    local ent = trigger.activator
	print("shit")
    if not ent then return end
    ent.InWater = false
    return
end