--[[
Broodking AI
]]

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.tendril = thisEntity:FindAbilityByName("boss_sloth_demon_slime_tendrils")
	thisEntity.hide = thisEntity:FindAbilityByName("boss_sloth_demon_slime_hide")
	thisEntity.trail = thisEntity:FindAbilityByName("boss_sloth_demon_slime_trail")
	thisEntity.cocoon = thisEntity:FindAbilityByName("boss_sloth_demon_slime_cocoon")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.tendril:SetLevel(1)
			thisEntity.hide:SetLevel(1)
			thisEntity.trail:SetLevel(1)
			thisEntity.cocoon:SetLevel(1)
		else
			thisEntity.tendril:SetLevel(2)
			thisEntity.hide:SetLevel(2)
			thisEntity.trail:SetLevel(2)
			thisEntity.cocoon:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.cocoon:IsFullyCastable() and ( AICore:BeingAttacked( thisEntity ) > 2 or thisEntity:GetHealthPercent() < 75 ) then
			return CastCocoon(thisEntity)
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastCocoon(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.cocoon:entindex()
	})
	return thisEntity.cocoon:GetCastPoint() + 0.1
end