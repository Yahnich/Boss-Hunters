relic_cursed_thorned_bandages = class(relicBaseClass)

function relic_cursed_thorned_bandages:GetModifierHealAmplify_Percentage(params)
	if not params.ability then return 0 end
	local duration = 30
	
	local ability = self:GetAbility()
	local target = params.target
	local attacker = params.healer
	local damage = math.floor( math.min( params.heal, target:GetHealthDeficit() ) / duration )
	if attacker == self:GetParent() and not attacker:HasModifier("relic_unique_ritual_candle") and damage > 1 then
		Timers:CreateTimer(1, function()
			if target:IsAlive() then
				ability:DealDamage(attacker, target, damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
				duration = duration - 1
				if duration > 0 then
					return 1
				end
			end
		end)
	end
	return 200
end