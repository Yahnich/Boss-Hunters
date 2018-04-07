modifier_generic_attack_bonus = class({})

function modifier_generic_attack_bonus:OnCreated(kv)
	self.damage = kv.damage
end

function modifier_generic_attack_bonus:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return funcs
end

function modifier_generic_attack_bonus:GetModifierPreAttack_BonusDamage( params )
    return self.damage
end

function modifier_generic_attack_bonus:IsHidden()
    return true
end