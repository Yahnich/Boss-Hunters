relic_weighted_gloves = class(relicBaseClass)

function relic_weighted_gloves:OnCreated()
	self:GetParent():HookInModifier("GetModifierAttackSpeedLimitBonus", self)
end

function relic_weighted_gloves:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierAttackSpeedLimitBonus", self)
end

function relic_weighted_gloves:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function relic_weighted_gloves:GetModifierAttackSpeedBonus_Constant()
	return 20
end

function relic_weighted_gloves:GetModifierAttackSpeedLimitBonus()
	return 100
end