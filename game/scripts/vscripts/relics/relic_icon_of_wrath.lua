relic_icon_of_wrath = class(relicBaseClass)

function relic_icon_of_wrath:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function relic_icon_of_wrath:GetModifierIncomingDamage_Percentage(params)
	if self:GetParent():IsIllusion() or params.unit ~= self:GetParent() then return end
	if not HasBit(params.damage_type, DOTA_DAMAGE_FLAG_REFLECTION) and not self:GetParent() == params.attacker then
		self:GetAbility():DealDamage( self:GetParent(), params.attacker, self:GetParent():GetPrimaryStatValue(), {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION} )
		if not self:GetParent():HasModifier("relic_ritual_candle") then return 25 end
	end
end