lifestealer_assimilate_exit = class({})

function lifestealer_assimilate_exit:IsStealable()
    return false
end

function lifestealer_assimilate_exit:OnSpellStart()
    self:GetCaster():RemoveModifierByName("modifier_lifestealer_assimilate_bh_ally")
end