relic_generic_stick = class({})

function relic_generic_stick:OnCreated()
	self:SetStackCount(1)
end

function relic_generic_stick:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_stick:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function relic_generic_stick:IsHidden()
	return true
end

function relic_generic_stick:IsPurgable()
	return false
end

function relic_generic_stick:RemoveOnDeath()
	return false
end

function relic_generic_stick:IsPermanent()
	return true
end

function relic_generic_stick:AllowIllusionDuplicate()
	return true
end

function relic_generic_stick:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end