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
	thisEntity.battlemaster = thisEntity:FindAbilityByName("boss_legion_commander_battlemaster")
	thisEntity.hail = thisEntity:FindAbilityByName("boss_legion_commander_hail_of_arrows")
	thisEntity.bolster = thisEntity:FindAbilityByName("boss_legion_commander_bolster")
	thisEntity.rage = thisEntity:FindAbilityByName("boss_legion_commander_infernal_rage")
	level = math.floor(GameRules:GetGameDifficulty() / 2 + 0.5)
	
	thisEntity.battlemaster:SetLevel( level )
	thisEntity.hail:SetLevel( level )
	thisEntity.bolster:SetLevel( level )
	thisEntity.rage:SetLevel( level )
	thisEntity:SetHealth(thisEntity:GetMaxHealth())
end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		if thisEntity.hail:IsFullyCastable() then
			local radius = thisEntity.hail:GetSpecialValueFor("radius")
			local range = thisEntity.hail:GetTrueCastRange() + radius
			if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 then
				local position = AICore:OptimalHitPosition(thisEntity, range, radius)
				if position and RollPercentage(25) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = position,
						AbilityIndex = thisEntity.hail:entindex()
					})
					return thisEntity.hail:GetCastPoint() + 0.1
				end
			end
		end
		if thisEntity.bolster:IsFullyCastable() then
			local hpregen = thisEntity.bolster:GetSpecialValueFor("hp_regen") * (thisEntity.bolster:GetSpecialValueFor("duration") / 3)
			if (thisEntity:IsAttacking() or thisEntity:GetHealthDeficit() > hpregen) and RollPercentage(15) then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = thisEntity:entindex(),
					AbilityIndex = thisEntity.bolster:entindex()
				})
				return AI_THINK_RATE
			elseif AICore:TotalAlliedUnitsInRange( thisEntity, thisEntity.bolster:GetTrueCastRange() ) > 0 then
				local ally = AICore:WeakestAlliedUnitInRange( thisEntity, thisEntity.bolster:GetTrueCastRange() , false)
				if ally and ally:GetHealthDeficit() > hpregen and RollPercentage(8) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = ally:entindex(),
						AbilityIndex = thisEntity.bolster:entindex()
					})
					return AI_THINK_RATE
				end
			end
		end
		if thisEntity.rage:IsFullyCastable() and ( RollPercentage(25) or thisEntity:HasModifier("modifier_boss_legion_commander_bolster_buff") ) then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.rage:entindex()
			})
			return thisEntity.rage:GetCastPoint() + 0.1
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end