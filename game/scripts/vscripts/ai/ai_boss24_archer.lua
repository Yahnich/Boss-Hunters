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
	thisEntity.hail = thisEntity:FindAbilityByName("boss_reaper_necrotic_hail")
	thisEntity.reposition = thisEntity:FindAbilityByName("boss_reaper_reposition")
	thisEntity.multi = thisEntity:FindAbilityByName("boss_reaper_multi_shot")
	
	AITimers:CreateTimer(function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then 
			thisEntity.hail:SetLevel(1)
			thisEntity.reposition:SetLevel(1)
			thisEntity.multi:SetLevel(1)
		else
			thisEntity.hail:SetLevel(2)
			thisEntity.reposition:SetLevel(2)
			thisEntity.multi:SetLevel(2)
		end
	end)
end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			local target =  AICore:GetHighestPriorityTarget(thisEntity)
			if not thisEntity:HasModifier("modifier_boss_reaper_reposition") or thisEntity.aiChasing then
				if thisEntity.hail:IsFullyCastable() and RollPercentage(33) then
					local position = AICore:OptimalHitPosition(thisEntity, thisEntity.hail:GetTrueCastRange(), thisEntity.hail:GetSpecialValueFor("radius"), false)
					if position then 
						return CastHail(position) 
					end
				end
				if thisEntity.reposition:IsFullyCastable() then
					if target and CalculateDistance(target, thisEntity) > thisEntity:GetAttackRange() then
						thisEntity.aiChasing = true
						return CastReposition()
					elseif AICore:BeingAttacked( thisEntity ) > 0 then
						aiChasing = false
						return CastReposition()
					end
				end
				return AICore:AttackHighestPriority( thisEntity )
			else
				AICore:BeAHugeCoward( thisEntity, 500 )
				return AI_THINK_RATE
			end
		else return 0.5 end
	else return AI_THINK_RATE end
end

function CastReposition()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.reposition:entindex()
	})
	return thisEntity.reposition:GetCastPoint() + 0.1
end

function CastHail(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position, 
		AbilityIndex = thisEntity.hail:entindex()
	})
	return thisEntity.hail:GetCastPoint() + 0.1
end