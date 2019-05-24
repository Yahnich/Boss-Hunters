--[[
Broodking AI
]]
TECHIES_BEHAVIOR_SEEK_AND_DESTROY = 1
TECHIES_BEHAVIOR_ROAM_AND_MINE = 2
require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.suicide = thisEntity:FindAbilityByName("boss_suicide")
	thisEntity.mine = thisEntity:FindAbilityByName("boss_proximity")
	thisEntity.AIstate = RandomInt(1,2)
	if  math.floor(GameRules.gameDifficulty + 0.5) > 2 then
		thisEntity.suicide:SetLevel(2)
		thisEntity.mine:SetLevel(2)
	else
		thisEntity.suicide:SetLevel(1)
		thisEntity.mine:SetLevel(1)
	end
	thisEntity.suicide:StartCooldown(5)
end


function AIThink(thisEntity)
	if not thisEntity:IsAlive() then
		for _,mine in pairs( FindUnitsInRadius( thisEntity:GetTeam(), thisEntity:GetOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false ) ) do
			if mine:GetUnitName() == "npc_dota_techies_land_mine" or mine:GetName() == "npc_dota_techies_land_mine" or mine:GetUnitLabel() == "npc_dota_techies_land_mine" then
				if mine:GetOwnerEntity() == thisEntity then
					mine:RemoveSelf()
				end
			end
		end
	end
	if not thisEntity:IsDominated() then
		if thisEntity:IsChanneling() then return AI_THINK_RATE end
		local boom = AICore:NearestEnemyHeroInRange( thisEntity, 300, true )
		if boom then 
			if thisEntity.suicide:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = boom:GetOrigin(),
					AbilityIndex = thisEntity.suicide:entindex()
				})
				return AI_THINK_RATE
			end
		end
		if thisEntity.mine:IsFullyCastable() and not AICore:SpecificAlliedUnitsInRange( thisEntity, "npc_dota_techies_land_mine", 450 ) then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = thisEntity:GetOrigin(),
				AbilityIndex = thisEntity.mine:entindex()
			})
			return AI_THINK_RATE
		end
		if thisEntity.AIstate == TECHIES_BEHAVIOR_SEEK_AND_DESTROY then
			AICore:RunToTarget( thisEntity, AICore:NearestEnemyHeroInRange( thisEntity, 9999, true ) )
		elseif thisEntity.AIstate == TECHIES_BEHAVIOR_ROAM_AND_MINE then
			AICore:RunToRandomPosition( thisEntity, 15 )
		end
		return AI_THINK_RATE
	else return AI_THINK_RATE end
end