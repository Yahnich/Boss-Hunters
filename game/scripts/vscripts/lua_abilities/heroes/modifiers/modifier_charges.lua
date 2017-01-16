modifier_lifesteal_generic = class({})

function modifier_lifesteal_generic:OnCreated()
	self.lifesteal = self.lifesteal or self:GetStackCount()
end

function modifier_lifesteal_generic:IsHidden()
	self.lifesteal
end