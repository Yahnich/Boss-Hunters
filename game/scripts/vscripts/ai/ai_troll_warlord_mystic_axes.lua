--[[
Troll Warlord Boss Axes
]]

if IsServer() then
	function Spawn( entityKeyValues )
		Timers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)

		thisEntity.charge = thisEntity:FindAbilityByName("boss_troll_warlord_mystic_axes_charge")
		if thisEntity.charge then
			thisEntity.charge:SetLevel(1)
		end

	end

	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:RandomEnemyHeroInRange( thisEntity, 3000, true)
			if target then
				if thisEntity.charge and thisEntity.charge:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.charge:entindex()
					})
					return thisEntity.charge:GetCastPoint() + 0.1
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end