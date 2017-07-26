MapHandler = class({})

MIN_POS_Y = -8000
MAX_POS_Y = 4000

MIN_POS_X = -5300
MAX_POS_X = 5700

SPAWN_POS = Vector(73, -6219, 0)

function MapHandler:CheckAndResolvePositions(hero)
	if MapHandler:IsOutsideMapBounds(hero) then
		hero:SetOrigin(SPAWN_POS)
		hero.lastAllowedPosition = Vector(0,0, hero:GetOrigin().z) + SPAWN_POS
	elseif hero.lastAllowedPosition and not GridNav:CanFindPath(hero.lastAllowedPosition, hero:GetOrigin()) then
		if not hero:HasFlyMovementCapability() then
			hero.positionResetBuffer = hero.positionResetBuffer or 0
			if hero.positionResetBuffer > 1 then
				hero:SetOrigin(hero.lastAllowedPosition or hero:GetOrigin())
				hero.positionResetBuffer = 0
			else
				hero.positionResetBuffer = hero.positionResetBuffer + FrameTime()
			end
		end
	else
		hero.lastAllowedPosition = hero:GetOrigin()
	end
end

function OnWaterEnter(trigger)
    local ent = trigger.activator
    ent.InWater = true
end

function OnWaterExit(trigger)
    local ent = trigger.activator
    if not ent then return end
    ent.InWater = false
    return
end

function MapHandler:IsOutsideMapBounds(unit)
	local unitPos = unit:GetAbsOrigin()
	return (unitPos.x > MAX_POS_X or unitPos.x < MIN_POS_X) or (unitPos.y > MAX_POS_Y or unitPos.y < MIN_POS_Y)
end