relic_cursed_thorned_bandages = class(relicBaseClass)

function relic_cursed_thorned_bandages:GetModifierHealAmplify_Percentage(params)
	local duration = 30
	local damage = params.heal / duration
	local ability = self:GetAbility()
	local target = params.target
	local attacker = params.healer
	Timers:CreateTimer(1, function()
		if target:IsAlive() then
			ability:DealDamage(attacker, target, damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION})
			duration = duration - 1
			if duration > 0 then
				return 1
			end
		end
	end)
	return 200
end