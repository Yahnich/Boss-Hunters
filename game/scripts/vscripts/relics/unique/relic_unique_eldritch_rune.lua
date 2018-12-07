relic_unique_eldritch_rune = class(relicBaseClass)


function relic_unique_eldritch_rune:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_unique_eldritch_rune:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.attacker == self:GetParent() and params.original_damage > 0 then
		local ability = params.inflictor or self:GetAbility()
		if params.damage_type == DAMAGE_TYPE_PURE or ability.eldritchRunePreventLoop then return end
		if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
			params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
		end
		ability.eldritchRunePreventLoop = true
		if params.damage_type == DAMAGE_TYPE_PHYSICAL then
			ability:DealDamage( params.attacker, params.target, params.original_damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = params.damage_flags} )
		elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
			ability:DealDamage( params.attacker, params.target, params.original_damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = params.damage_flags} )
		end
		ability.eldritchRunePreventLoop = false
		return -999
	end
end