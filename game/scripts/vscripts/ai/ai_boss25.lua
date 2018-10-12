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
	
	thisEntity.vamp = thisEntity:FindAbilityByName("boss_wk_vampirism")
	thisEntity.mortal = thisEntity:FindAbilityByName("boss_wk_mortal_strike")
	thisEntity.reincarnation = thisEntity:FindAbilityByName("boss_wk_reincarnation")
	thisEntity.blast = thisEntity:FindAbilityByName("boss_wk_scourge_blast")
	thisEntity.cull = thisEntity:FindAbilityByName("boss_wk_culling_blow")
	
	AITimers:CreateTimer(function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then 
			thisEntity.vamp:SetLevel(1)
			thisEntity.mortal:SetLevel(1)
			thisEntity.reincarnation:SetLevel(1)
			thisEntity.blast:SetLevel(1)
			thisEntity.cull:SetLevel(1)
		else
			thisEntity.vamp:SetLevel(2)
			thisEntity.mortal:SetLevel(2)
			thisEntity.reincarnation:SetLevel(2)
			thisEntity.blast:SetLevel(2)
			thisEntity.cull:SetLevel(2)
		end
	end)
end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			local target =  AICore:GetHighestPriorityTarget(thisEntity)
			if thisEntity.mortal:IsCooldownReady() and RollPercentage(50) and target then
				if not target:HasModifier("modifier_boss_wk_mortal_strike_debuff") then
					return CastMortalStrike(target)
				else
					local newt = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.mortal:GetTrueCastRange() + thisEntity:GetIdealSpeed(), false )
					if newT and not newT:HasModifier("modifier_boss_wk_mortal_strike_debuff") then
						return CastMortalStrike(newT)
					end
				end
			end
			if thisEntity.cull:IsCooldownReady() and RollPercentage(50) then
				return CastCulling()
			end
			if thisEntity.blast:IsCooldownReady() and RollPercentage(50) and target then
				if thisEntity:HasModifier("modifier_boss_wk_reincarnation_enrage") then
					return CastScourge(thisEntity:GetAbsOrigin())
				else
					if CalculateDistance(target, thisEntity) > thisEntity.blast:GetTrueCastRange() then
						local newT = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.blast:GetTrueCastRange(), false)
						if newT then
							return  CastScourge(newT:GetAbsOrigin())
						end
					else
						return CastScourge(target:GetAbsOrigin())
					end
				end
			end
			
			return AICore:AttackHighestPriority( thisEntity )
		else return 0.5 end
	else return AI_THINK_RATE end
end

function CastCulling()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.cull:entindex()
	})
	return thisEntity.cull:GetCastPoint() + 0.1
end

function CastMortalStrike(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET ,
		TargetIndex  = target:entindex(),
		AbilityIndex = thisEntity.mortal:entindex()
	})
	return thisEntity.mortal:GetCastPoint() + 0.1
end

function CastVanguard()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.vanguard:entindex()
	})
	return thisEntity.vanguard:GetCastPoint() + 0.1
end

function CastReaper()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.reaper:entindex()
	})
	return thisEntity.reaper:GetCastPoint() + 0.1
end

function CastScourge(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position, 
		AbilityIndex = thisEntity.blast:entindex()
	})
	return thisEntity.blast:GetCastPoint() + 0.1
end