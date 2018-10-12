modifier_healing_disable = class({})

function modifier_healing_disable:OnCreated() print("ok boss") end

function modifier_healing_disable:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING
    }

    return funcs
end

function modifier_healing_disable:GetDisableHealing()
    return 1
end

function modifier_healing_disable:GetTexture()
    return "custom/healing_disabled"
end

function modifier_healing_disable:IsDebuff()
	return true
end

function modifier_healing_disable:IsHidden()
	return false
end