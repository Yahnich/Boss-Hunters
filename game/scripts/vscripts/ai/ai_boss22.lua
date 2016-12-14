--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.spike = thisEntity:FindAbilityByName("creature_aoe_spikes_2")
	if not thisEntity.spike then thisEntity.spike = thisEntity:FindAbilityByName("creature_aoe_spikes_2_h") end
	if not thisEntity.spike then thisEntity.spike = thisEntity:FindAbilityByName("creature_aoe_spikes_2_vh") end
	thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash2")
	if not thisEntity.smash then thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash_vh") end
	thisEntity.stun = thisEntity:FindAbilityByName("creature_melee_smash_stun_vh")
	thisEntity.drain = thisEntity:FindAbilityByName("boss_life_drain")
	thisEntity.silence = thisEntity:FindAbilityByName("creature_silence")
	if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
		thisEntity.drain:SetLevel(1)
	elseif  math.floor(GameRules.gameDifficulty + 0.5) == 2 then 
		thisEntity.drain:SetLevel(3)
	else
		thisEntity.drain:SetLevel(2)
	end
end


function AIThink()
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			if thisEntity.spike then
				if thisEntity.spike:IsFullyCastable() and AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, thisEntity.spike:GetCastRange(), false ) < 1 then
					local target = AICore:FarthestEnemyHeroInRange( thisEntity, thisEntity.spike:GetCastRange(), false  )
					if target then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetOrigin(),
							AbilityIndex = thisEntity.spike:entindex()
						})
						return 1
					end
				end
			end
			if thisEntity.smash then
				if thisEntity.smash:IsFullyCastable() and AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, thisEntity.smash:GetCastRange(), false  ) < 2 then
					local target = AICore:FarthestEnemyHeroInRange( thisEntity, thisEntity.smash:GetCastRange(), false  )
					if target then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetOrigin(),
							AbilityIndex = thisEntity.smash:entindex()
						})
						return 0.5
					end
				end
			end
			if thisEntity.stun then
				if thisEntity.stun:IsFullyCastable() and AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, thisEntity.stun:GetCastRange(), false  ) < 7 then
					local target = AICore:FarthestEnemyHeroInRange( thisEntity, thisEntity.stun:GetCastRange(), false  )
					if target then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetOrigin(),
							AbilityIndex = thisEntity.stun:entindex()
						})
						return 0.5
					end
				end
			end
			if thisEntity.silence:IsFullyCastable() and AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, thisEntity.silence:GetCastRange(), false  ) < 5 then
				local target = AICore:FarthestEnemyHeroInRange( thisEntity, thisEntity.silence:GetCastRange(), false  )
				if target then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetOrigin(),
						AbilityIndex = thisEntity.silence:entindex()
					})
					return 0.5
				end
			end 
			if thisEntity.drain:IsFullyCastable() then
				local target = AICore:NearestDisabledEnemyHeroInRange( thisEntity, thisEntity.drain:GetCastRange(), false  )
				if target then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.drain:entindex()
					})
					return 0.5
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.5 end
	else return 0.25 end
end