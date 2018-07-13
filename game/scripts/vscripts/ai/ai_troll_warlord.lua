--[[
Troll Warlord Boss
]]

if IsServer() then
	function Spawn( entityKeyValues )
		Timers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)

		thisEntity.axe_fury = thisEntity:FindAbilityByName("boss_troll_warlord_axe_fury")
		if thisEntity.axe_fury then
			thisEntity.axe_fury:SetLevel( math.ceil(GameRules:GetGameDifficulty()/2) )
			--thisEntity.axe_fury:SetCooldown()
		end

		thisEntity.ensare = thisEntity:FindAbilityByName("boss_troll_warlord_ensare")
		if thisEntity.ensare then
			thisEntity.ensare:SetLevel( math.ceil(GameRules:GetGameDifficulty()/2) )
		end

		thisEntity.mystic_axes = thisEntity:FindAbilityByName("boss_troll_warlord_mystic_axes")
		if thisEntity.mystic_axes then
			thisEntity.mystic_axes:SetLevel( math.ceil(GameRules:GetGameDifficulty()/2) )
		end

		thisEntity.enrage = thisEntity:FindAbilityByName("boss_troll_warlord_enrage")
		if thisEntity.enrage then
			thisEntity.enrage:SetLevel( math.ceil(GameRules:GetGameDifficulty()/2) )
		end

		thisEntity.leap = thisEntity:FindAbilityByName("boss_troll_warlord_savage_leap")
		if thisEntity.leap then
			thisEntity.leap:SetLevel( math.ceil(GameRules:GetGameDifficulty()/2) )
		end
	end

	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target then
				if thisEntity.axe_fury and thisEntity.axe_fury:IsFullyCastable() and not thisEntity:HasModifier("modifier_boss_troll_warlord_enrage") then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.axe_fury:entindex()
					})
					return thisEntity.axe_fury:GetCastPoint() + 0.1
				end

				if thisEntity.ensare and thisEntity.ensare:IsFullyCastable() and not thisEntity:HasModifier("modifier_boss_troll_warlord_enrage")then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.ensare:entindex()
					})
					return thisEntity.ensare:GetCastPoint() + 0.1
				end
				if thisEntity.mystic_axes and thisEntity.mystic_axes:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.mystic_axes:entindex()
					})
					return thisEntity.mystic_axes:GetCastPoint() + 0.1
				end

				if thisEntity.leap and thisEntity.leap:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.leap:entindex()
					})
					return thisEntity.leap:GetCastPoint() + 0.1
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end