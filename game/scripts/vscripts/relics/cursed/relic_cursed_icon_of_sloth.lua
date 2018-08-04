relic_cursed_icon_of_sloth = class(relicBaseClass)

function relic_cursed_icon_of_sloth:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MIN_HEALTH}
end

function relic_cursed_icon_of_sloth:GetModifierIncomingDamage_Percentage(params)
	if params.damage > self:GetParent():GetHealth() and self:GetParent():GetHealthPercent() >= 10 then
		self:GetParent():SetHealth(1)
		return -999
	end
end

function relic_cursed_icon_of_sloth:GetMinHealth()
	if self:GetParent():GetHealthPercent() >= 10 then
		return 1
	end
end

function relic_cursed_icon_of_sloth:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -33 end
end