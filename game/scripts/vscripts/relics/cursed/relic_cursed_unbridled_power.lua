relic_cursed_unbridled_power = class(relicBaseClass)

function relic_cursed_unbridled_power:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
end

function relic_cursed_unbridled_power:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.attacker == self:GetParent() and params.damage > 0 then
		if params.damage_type ~= DAMAGE_TYPE_PURE and params.inflictor ~= self:GetAbility() then
			if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
				params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
			end
			self:GetAbility():DealDamage( params.attacker, params.target, params.original_damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = params.damage_flags} )
			return -999
		end
	end
end

function relic_cursed_unbridled_power:GetModifierIncomingDamage_Percentage(params)
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") and params.target == self:GetParent() and params.damage > 0 then
		if params.damage_type ~= DAMAGE_TYPE_PURE and params.inflictor ~= self:GetAbility() then
			if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
				params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
			end
			self:GetAbility():DealDamage( params.attacker, params.target,  params.original_damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = params.damage_flags} )
			return -999
		end
	end
end