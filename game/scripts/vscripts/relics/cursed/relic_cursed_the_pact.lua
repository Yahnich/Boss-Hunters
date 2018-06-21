relic_cursed_the_pact = class(relicBaseClass)

function relic_cursed_the_pact:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_cursed_the_pact:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		local heal = params.damage
		if heal > 0 and params.attacker:IsAlive() and params.attacker:GetHealth() ~= 0 then
			SendOverheadEventMessage(params.attacker, OVERHEAD_ALERT_HEAL, params.attacker, heal, params.attacker)
			self:GetParent():SetHealth( math.max( math.min( params.attacker:GetMaxHealth(), params.attacker:GetHealth() + heal ), 1 ) )
		end
	end
end

function relic_cursed_the_pact:GetModifierDamageOutgoing_Percentage()
	return 100

end

function relic_cursed_the_pact:GetModifierMagicalResistanceBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -50 end
end

function relic_cursed_the_pact:GetModifierPhysicalArmorBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -25 end
end

function relic_cursed_the_pact:GetDisableHealing(params)
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return 1 end
end