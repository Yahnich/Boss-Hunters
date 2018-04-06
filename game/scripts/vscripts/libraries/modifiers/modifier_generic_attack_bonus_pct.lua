modifier_generic_attack_bonus_pct = class({})

function modifier_generic_attack_bonus_pct:OnCreated(kv)
	self.damage = kv.damage
end

function modifier_generic_attack_bonus_pct:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }

    return funcs
end

function modifier_generic_attack_bonus_pct:GetModifierDamageOutgoing_Percentage( params )
    return self.damage
end

function modifier_generic_attack_bonus_pct:IsHidden()
    return true
end