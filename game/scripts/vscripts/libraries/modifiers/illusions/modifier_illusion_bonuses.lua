modifier_illusion_bonuses = class({})

function modifier_illusion_bonuses:OnCreated()
	self:GetParent().illusionOwner = self:GetCaster()
end

function modifier_illusion_bonuses:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
    }

    return funcs
end

function modifier_illusion_bonuses:GetModifierAttackRangeOverride( params )
	return self:GetCaster():GetAttackRange()
end

function modifier_illusion_bonuses:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetCaster():GetAgility()
end

function modifier_illusion_bonuses:GetModifierProjectileSpeedBonus()
	return self:GetCaster():GetProjectileSpeed()
end

function modifier_illusion_bonuses:IsHidden()
    return true
end