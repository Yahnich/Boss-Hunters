modifier_bh_heal_disable = class({})

function modifier_bh_heal_disable:OnCreated()
end

function modifier_bh_heal_disable:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING
    }

    return funcs
end

function modifier_bh_heal_disable:GetDisableHealing()
    return 1
end

function modifier_bh_heal_disable:GetTexture()
    return "custom/healing_disabled"
end

function modifier_bh_heal_disable:IsDebuff()
	return true
end

function modifier_bh_heal_disable:IsHidden()
	return false
end