relic_cursed_the_pact = class(relicBaseClass)

function relic_cursed_the_pact:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_cursed_the_pact:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and params.attacker ~= params.unit then
		local heal = params.damage
		if heal > 0 and params.attacker:IsAlive() and params.attacker:GetHealth() ~= 0 then
			self:GetParent():HealEvent( heal, self:GetAbility(), params.attacker)
		end
	end
end

function relic_cursed_the_pact:GetModifierBaseDamageOutgoing_Percentage()
	return 100

end

function relic_cursed_the_pact:GetModifierMagicalResistanceBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -33 end
end

function relic_cursed_the_pact:GetModifierPhysicalArmorBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -15 end
end

function relic_cursed_the_pact:GetModifierHealAmplify_Percentage(params)
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -999 end
end