--[[
Warlock Boss
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		Timers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )

		thisEntity.conflag = thisEntity:FindAbilityByName("boss_warlock_conflagration")
		if thisEntity.conflag then
			thisEntity.conflag:SetLevel(1)
		end

		thisEntity.desecrate = thisEntity:FindAbilityByName("boss_warlock_desecrate")
		if thisEntity.desecrate then
			thisEntity.desecrate:SetLevel(1)
			thisEntity.desecrate:SetCooldown()
		end

		thisEntity.bonds = thisEntity:FindAbilityByName("boss_warlock_fatal_bonds")
		if thisEntity.bonds then
			thisEntity.bonds:SetLevel(1)
		end

		thisEntity.unholy_summon = thisEntity:FindAbilityByName("boss_warlock_unholy_summon")
		if thisEntity.unholy_summon then
			thisEntity.unholy_summon:SetLevel(1)
		end

		thisEntity.ult_form = thisEntity:FindAbilityByName("boss_warlock_ultimate_form")
		if thisEntity.ult_form then
			thisEntity.ult_form:SetLevel(1)
		end

		thisEntity.demon_lust = thisEntity:FindAbilityByName("boss_warlock_demon_lust")
		if thisEntity.demon_lust then
			thisEntity.demon_lust:SetLevel(1)
			thisEntity.demon_lust:SetCooldown()
		end

		thisEntity.rain_of_fire = thisEntity:FindAbilityByName("boss_warlock_rain_of_fire")
		if thisEntity.rain_of_fire then
			thisEntity.rain_of_fire:SetLevel(1)
		end

		thisEntity.inferno_spikes = thisEntity:FindAbilityByName("boss_warlock_inferno_spikes")
		if thisEntity.inferno_spikes then
			thisEntity.inferno_spikes:SetLevel(1)
		end
	end

	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target then
				if thisEntity.conflag and thisEntity.conflag:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.conflag:entindex()
					})
					return thisEntity.conflag:GetCastPoint() + 0.1
				end

				if thisEntity.desecrate and thisEntity.desecrate:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.desecrate:entindex()
					})
					return thisEntity.desecrate:GetCastPoint() + 0.1					
				end

				if thisEntity.bonds and thisEntity.bonds:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.bonds:entindex()
					})
					return thisEntity.bonds:GetCastPoint() + 0.1					
				end

				if thisEntity.unholy_summon and thisEntity.unholy_summon:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.unholy_summon:entindex()
					})
					return thisEntity.unholy_summon:GetCastPoint() + 0.1					
				end

				if thisEntity.demon_lust and thisEntity.demon_lust:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.demon_lust:entindex()
					})
					return thisEntity.demon_lust:GetCastPoint() + 0.1					
				end

				if thisEntity.rain_of_fire and thisEntity.rain_of_fire:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.rain_of_fire:entindex()
					})
					return thisEntity.rain_of_fire:GetCastPoint() + 0.1					
				end

				if thisEntity.inferno_spikes and thisEntity.inferno_spikes:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.inferno_spikes:entindex()
					})
					return thisEntity.inferno_spikes:GetCastPoint() + 0.1					
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return 0.25 end
	end
end