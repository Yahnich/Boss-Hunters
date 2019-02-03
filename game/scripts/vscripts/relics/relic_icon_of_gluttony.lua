relic_icon_of_gluttony = class(relicBaseClass)

function relic_icon_of_gluttony:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_DEATH}
end

function relic_icon_of_gluttony:GetModifierHPRegenAmplify_Percentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -33 end
end

function relic_icon_of_gluttony:GetModifierMPRegenAmplify_Percentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -33 end
end

function relic_icon_of_gluttony:OnDeath(params)
	if params.attacker == self:GetParent() then
		local heal = 0.15
		local hero = self:GetParent()
		if not params.unit.Holdout_IsCore then heal = 0.01 end
		hero:HealEvent( hero:GetMaxHealth() * heal, nil, nil )
		hero:RestoreMana( hero:GetMaxMana() * heal )
	end
end