modifier_illusion_bonuses = class({})

function modifier_illusion_bonuses:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
    }

    return funcs
end

function modifier_illusion_bonuses:GetModifierAttackRangeBonus( params )
	if IsServer() then return self:GetCaster():GetAttackRange() end
end

function modifier_illusion_bonuses:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetCaster():GetIncreasedAttackSpeed() * 100
end

function modifier_illusion_bonuses:GetModifierProjectileSpeedBonus()
	return self:GetCaster():GetProjectileSpeed()
end

function modifier_illusion_bonuses:IsHidden()
    return true
end