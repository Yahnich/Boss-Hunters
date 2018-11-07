modifier_restoration_disable = class({})

function modifier_restoration_disable:OnCreated()
	if IsServer() then
		self.mana = self:GetParent():GetMana()
		self:StartIntervalThink(0)
	end
end

function modifier_restoration_disable:OnIntervalThink()
	self:GetParent():SetMana( self.mana )
end

function modifier_restoration_disable:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING
    }

    return funcs
end

function modifier_restoration_disable:GetDisableHealing()
    return 1
end

function modifier_restoration_disable:GetTexture()
    return "custom/healing_disabled"
end

function modifier_restoration_disable:IsDebuff()
	return true
end

function modifier_restoration_disable:IsHidden()
	return false
end