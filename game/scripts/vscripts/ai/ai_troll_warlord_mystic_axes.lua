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
			thisEntity.charge:SetLevel( math.ceil(GameRules:GetGameDifficulty() / 2) )
		end

	end

	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:RandomEnemyHeroInRange( thisEntity, 3000, true)
			thisEntity.thinks = (thisEntity.thinks or 0) + 1
			if target then
				if thisEntity.charge and thisEntity.charge:IsFullyCastable() then
					thisEntity:CastAbilityOnTarget(target, thisEntity.charge, -1)
					return 8 / GameRules:GetGameDifficulty()
				end
			end
			return 0.25
		else return 0.25 end
	end
end