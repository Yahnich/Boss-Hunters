relic_cursed_ritual_kris = class(relicBaseClass)

function relic_cursed_ritual_kris:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function relic_cursed_ritual_kris:GetModifierPreAttack_CriticalStrike(params)
	if self:RollPRNG(10) then
		ApplyDamage({victim = params.attacker, attacker = params.attacker, damage = params.attacker:GetHealth() * 0.1, ability = params.ability, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS})
		return 360
	end
end