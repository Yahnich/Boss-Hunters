relic_generic_stick = class(relicBaseClass)

function relic_generic_stick:OnCreated()
	self:SetStackCount(1)
end

function relic_generic_stick:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_stick:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end