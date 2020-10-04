if IsClient() then return end

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	
	thisEntity.cocoon = thisEntity:FindAbilityByName("boss_sloth_demon_slime_cocoon")

	AITimers:CreateTimer(0.1, function()
		 for i = 0, thisEntity:GetAbilityCount() - 1 do
			local ability = thisEntity:GetAbilityByIndex( i )
			
			if ability then
				ability:SetLevel( math.floor( GameRules.gameDifficulty/2 + 0.5) )
			end
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.cocoon then
			if thisEntity.cocoon:IsFullyCastable() and ( AICore:BeingAttacked( thisEntity ) > 2 or thisEntity:GetHealthPercent() < 75 ) then
				return CastCocoon(thisEntity)
			end
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