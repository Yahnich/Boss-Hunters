relic_cursed_torn_prayer_card = class(relicBaseClass)

function relic_cursed_torn_prayer_card:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end
function relic_cursed_torn_prayer_card:GetModifierIncomingDamage_Percentage(params)
	if self:GetParent():GetMana() >= params.damage then
		self:GetParent():SpendMana( params.damage, self:GetAbility() ) 
		return -999
	elseif not self:GetParent():HasModifier("relic_unique_ritual_candle") then
		return 50
	end
end