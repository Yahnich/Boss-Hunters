--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.thorn = thisEntity:FindAbilityByName("boss_treant_thornmaze")
	thisEntity.root = thisEntity:FindAbilityByName("boss_treant_overgrowth")
	thisEntity.leech = thisEntity:FindAbilityByName("boss_treant_leech_seed")
	local level = math.floor(GameRules:GetGameDifficulty()/2)
	AITimers:CreateTimer(0.1, function() 
		thisEntity.thorn:SetLevel( level )
		thisEntity.root:SetLevel( level )
		thisEntity.leech:SetLevel( level )
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			if thisEntity.thorn:IsFullyCastable() then
				local position = AICore:OptimalHitPosition( thisEntity, thisEntity.thorn:GetTrueCastRange(), thisEntity.thorn:GetSpecialValueFor("spread_radius") )
				return CastThornMaze( position )
			end
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and thisEntity.leech:IsFullyCastable() and CalculateDistance( target, thisEntity ) <= thisEntity.leech:GetSpecialValueFor("radius") then
				return CastLeechSeed( target )
			end
			if thisEntity.root:IsFullyCastable() then
				for _, enemy in ipairs( thisEntity:FindEnemyUnitsInRadius( thisEntity:GetAbsOrigin(), thisEntity.root:GetTrueCastRange() + thisEntity:GetIdealSpeed() * 0.5 ) ) do
					if enemy:HasModifier("modifier_boss_treant_thornmaze_debuff") then
						return CastOvergrowth( enemy )
					end
				end
				local rootTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.root:GetTrueCastRange() + thisEntity:GetIdealSpeed() ) or target
				if rootTarget and RollPercentage( 15 ) then return CastOvergrowth( rootTarget ) end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return 0.5 end
	else return AI_THINK_RATE end
end

function CastThornMaze( position )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.thorn:entindex()
	})
	return thisEntity.thorn:GetCastPoint() + 0.1
end

function CastOvergrowth(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.root:entindex()
	})
	return thisEntity.root:GetCastPoint() + 0.1
end

function CastLeechSeed(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.leech:entindex()
	})
	return thisEntity.leech:GetCastPoint() + 0.1
end