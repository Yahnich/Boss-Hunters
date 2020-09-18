relic_unbridled_power = class(relicBaseClass)

-- function relic_unbridled_power:DeclareFunctions()
	-- return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			-- MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			-- }
-- end

-- function relic_unbridled_power:GetModifierTotalDamageOutgoing_Percentage(params)
	-- if params.attacker == self:GetParent() and params.original_damage > 0 then
		-- local ability = params.inflictor or self:GetAbility()
		-- if params.damage_type == DAMAGE_TYPE_PURE or ability.unbridledPowerPreventOutLoop then
			-- ability.unbridledPowerPreventOutLoop = false
			-- return
		-- end
		-- if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
			-- params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE)
			-- params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
		-- end
		-- ability.unbridledPowerPreventOutLoop = true
		-- ability:DealDamage( params.attacker, params.target, params.original_damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = params.damage_flags} )
		-- ability.unbridledPowerPreventOutLoop = false
		-- return -999
	-- end
-- end

-- function relic_unbridled_power:GetModifierIncomingDamage_Percentage(params)
	-- if not self:GetParent():HasModifier("relic_ritual_candle") and params.target == self:GetParent() and params.damage > 0 then
		-- local ability = params.inflictor or self:GetAbility()
		-- if params.damage_type == DAMAGE_TYPE_PURE or ability.unbridledPowerPreventInLoop then return end
		-- params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION)
		-- if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
			-- params.damage_flags = bit.bor(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE)
		-- end
		-- ability.unbridledPowerPreventInLoop = true
		-- ability:DealDamage( params.attacker, params.target,  params.original_damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = params.damage_flags} )
		-- ability.unbridledPowerPreventInLoop = false
		-- return -999
	-- end
-- end