relic_the_pact = class(relicBaseClass)

function relic_the_pact:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_the_pact:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) and params.attacker ~= params.unit and params.source then
		local heal = params.damage * 0.35
		if heal > 0 and params.attacker:IsAlive() and params.attacker:GetHealth() ~= 0 then
			self:GetParent():HealEvent( heal, self:GetAbility(), params.attacker)
		end
	end
end

function relic_the_pact:GetModifierBaseDamageOutgoing_Percentage()
	return 100

end

function relic_the_pact:GetModifierHealAmplify_Percentage(params)
	if not self:GetParent():HasModifier("relic_ritual_candle") and params.ability and params.ability ~= self:GetAbility() then 
		return -999
	end
end