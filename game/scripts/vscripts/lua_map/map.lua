MapHandler = class({})

MIN_POS_Y = -8000
MAX_POS_Y = 4000

MIN_POS_X = -5300
MAX_POS_X = 5700

SPAWN_POS = Vector(73, -6219, 0)

function MapHandler:CheckAndResolvePositions(hero)
	if MapHandler:IsOutsideMapBounds(hero) then
		FindClearSpaceForUnit(hero, SPAWN_POS, true)
		hero.lastAllowedPosition = Vector(0,0, hero:GetAbsOrigin().z) + SPAWN_POS
	end
end

function OnWaterEnter(trigger)
    local ent = trigger.activator
	if not ent then return end
    ent.InWater = true

    if ent:IsHero() then
    	ent:AddNewModifier(ent, nil, "modifier_in_water", {})
    end
end

function OnWaterExit(trigger)
    local ent = trigger.activator
    if not ent then return end
    ent.InWater = false
    ent:RemoveModifierByName("modifier_in_water")
    return
end

function MapHandler:IsOutsideMapBounds(unit)
	local unitPos = unit:GetAbsOrigin()
	return (unitPos.x > MAX_POS_X or unitPos.x < MIN_POS_X) or (unitPos.y > MAX_POS_Y or unitPos.y < MIN_POS_Y)
end