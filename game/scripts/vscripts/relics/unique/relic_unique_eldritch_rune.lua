relic_unique_eldritch_rune = class(relicBaseClass)


function relic_cursed_unbridled_power:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_cursed_unbridled_power:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.attacker == self:GetParent() and params.damage > 0 then
		if params.damage_type == DAMAGE_TYPE_PURE or params.inflictor == self:GetAbility() then return end
			if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
				params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
			end
			if params.damage_type == DAMAGE_TYPE_PHYSICAL then
				self:GetAbility():DealDamage( params.attacker, params.target, params.original_damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = params.damage_flags} )
			elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
				self:GetAbility():DealDamage( params.attacker, params.target, params.original_damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = params.damage_flags} )
			end
			return -999
		end
	end
end