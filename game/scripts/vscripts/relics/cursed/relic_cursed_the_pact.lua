relic_cursed_the_pact = class(relicBaseClass)

function relic_cursed_the_pact:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_cursed_the_pact:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		local heal = params.damage
		if heal > 0 then
			SendOverheadEventMessage(params.attacker, OVERHEAD_ALERT_HEAL, params.attacker, heal, params.attacker)
			self:GetParent():SetHealth( math.max( math.min( params.attacker:GetMaxHealth(), params.attacker:GetHealth() + heal ), 1 ) )
		end
	end
end

function relic_cursed_the_pact:GetModifierDamageOutgoing_Percentage()
	return 100

end

function relic_cursed_the_pact:GetModifierMagicalResistanceBonus()
	return -50
end

function relic_cursed_the_pact:GetModifierPhysicalArmorBonus()
	return -25
end

function relic_cursed_the_pact:GetDisableHealing(params)
	return 1
end