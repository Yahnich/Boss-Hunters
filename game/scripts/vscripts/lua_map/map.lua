	MapHandler = class({})

MIN_POS_Y = -8191
MAX_POS_Y = 8191

MIN_POS_X = -8191
MAX_POS_X = 8191

MIN_POS_Z = 0

SPAWN_POS = GetGroundPosition(Vector(6456, 6944, 0), nil)

function MapHandler:CheckAndResolvePositions(hero)
	if not hero or not hero.GetAbsOrigin then return end
	hero.lastAllowedPosition = hero.lastAllowedPosition or hero:GetAbsOrigin()
	if not RoundManager.boundingBox then return end
	local edgeBox = Entities:FindByName(nil, RoundManager.boundingBox.."_edge_collider")
	if hero:GetAbsOrigin().z < GetGroundHeight(hero:GetAbsOrigin(), hero) or hero:GetAbsOrigin().z > 1800 + GetGroundHeight(hero:GetAbsOrigin(), hero) then
		local currOrigin = hero:GetAbsOrigin()
		FindClearSpaceForUnit(hero, GetGroundPosition(currOrigin, hero), true)
	end
	if MapHandler:IsOutsideMapBounds(hero) or ( edgeBox and not edgeBox:IsTouching(hero) ) then
		FindClearSpaceForUnit(hero, hero.lastAllowedPosition, true)
		hero:StopMotionControllers(true)
		if edgeBox and not edgeBox:IsTouching(hero) and RoundManager:GetCurrentEvent() then
			if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
				hero.lastAllowedPosition = RoundManager:GetCurrentEvent():GetHeroSpawnPosition()
			else
				hero.lastAllowedPosition = RoundManager:PickRandomSpawn()
			end
			hero:StopMotionControllers(true)
			if hero and hero.lastAllowedPosition then
				FindClearSpaceForUnit(hero, hero.lastAllowedPosition, true)
			end
		end
		return
	end
	if GridNav:IsTraversable(hero:GetAbsOrigin()) and RoundManager.boundingBox and edgeBox and edgeBox:IsTouching(hero) then
		hero.lastAllowedPosition = hero:GetAbsOrigin()
	end
end

function OnWaterEnter(trigger)
    local ent = trigger.activator
	if not ent then return end
    if ent:IsHero() then
    	ent:AddNewModifier(ent, nil, "modifier_in_water", {})
    end
end

function OnWaterExit(trigger)
    local ent = trigger.activator
    if not ent then return end
    ent:RemoveModifierByName("modifier_in_water")
    return
end

function MapHandler:IsOutsideMapBounds(unit)
	if not unit or unit:IsNull() then return end
	local unitPos = unit:GetAbsOrigin()
	return (unitPos.x > MAX_POS_X or unitPos.x < MIN_POS_X) or (unitPos.y > MAX_POS_Y or unitPos.y < MIN_POS_Y) or (unitPos.z < MIN_POS_Z)
end

function FindWidth(unit)
	local width = 0
	for tag, vector in pairs( unit:GetBounds() ) do
		if math.abs(vector.x) < math.abs(vector.y) then
			width = width + math.abs(vector.x)
		else
			width = width + math.abs(vector.y)
		end
	end
	return width
end

function FindLength(unit)
	local length = 0
	for tag, vector in pairs( unit:GetBounds() ) do
		if math.abs(vector.x) > math.abs(vector.y) then
			length = length + math.abs(vector.x)
		else
			length = length + math.abs(vector.y)
		end
	end
	return length
end

function FindRadius(unit)
	local circum = (CalculateDistance( unit:GetAbsOrigin(), unit:GetBoundingMaxs() ) + CalculateDistance( unit:GetAbsOrigin(), unit:GetBoundingMins() )) /2
	local radius = (CalculateDistance( unit:GetAbsOrigin(), unit:GetBoundingMaxs() ) + CalculateDistance( unit:GetAbsOrigin(), unit:GetBoundingMins() )) / (math.pi * 2)
	return radius
end

function FindNearestBoundPosition( trigger, position )
	local nearestPoint, nearestPoint2, lineSegment
	for tag, vector in pairs( trigger:GetBounds() ) do
		if not nearestPoint or CalculateDistance( nearestPoint, position ) > CalculateDistance( vector, position ) then
			nearestPoint2 = nearestPoint
			nearestPoint = vector
			-- print( nearestPoint2, nearestPoint )
		elseif not nearestPoint2 or CalculateDistance( nearestPoint2, position ) > CalculateDistance( vector, position ) then
			nearestPoint2 = vector
			-- print( nearestPoint2, nearestPoint, "second closest" )
		end
	end
	local lineSegmentOrthPoints = { nearestPoint, nearestPoint2 }
	local projectionVector = GetPerpendicularVector(  lineSegmentOrthPoints[2] - lineSegmentOrthPoints[1] )
	local lineSegmentPerpPoints = { position, projectionVector * 2000 }
	local intersection = FindLineIntersection( lineSegmentOrthPoints, lineSegmentPerpPoints )
	-- print( intersection, lineSegmentOrthPoints[1], lineSegmentOrthPoints[2], position )
	return intersection
end

function LeftBoundingBox(trigger)
	local unit = trigger.activator
	local edge = trigger.caller
	local distance = 0
	Timers:CreateTimer(function()
		if not unit or unit:IsNull() then return end
		if RoundManager.boundingBox and unit and edge then
			if MapHandler:IsOutsideMapBounds(unit) then
				local newPos = unit:GetAbsOrigin() + CalculateDirection( edge, unit:GetAbsOrigin() ) * math.max( 0, CalculateDistance( edge, unit ) - FindRadius( edge ) )
				FindClearSpaceForUnit( unit, GetGroundPosition( newPos, unit ), true )
				GridNav:DestroyTreesAroundPoint( newPos, 120, true )
				unit:StopMotionControllers(true)
			elseif edge:GetName() == RoundManager.boundingBox.."_edge_collider" and not edge:IsTouching(unit) then
				local newPos = unit:GetAbsOrigin() + CalculateDirection( edge, unit:GetAbsOrigin() ) * math.max( 0, CalculateDistance( edge, unit ) - FindRadius( edge ) )
				FindClearSpaceForUnit( unit, GetGroundPosition( newPos, unit ), true )
				GridNav:DestroyTreesAroundPoint( newPos, 120, true )
				unit:StopMotionControllers(true)
			end
		end
	end)
end