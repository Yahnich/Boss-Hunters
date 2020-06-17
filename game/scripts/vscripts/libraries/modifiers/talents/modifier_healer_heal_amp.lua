modifier_healer_heal_amp = class(talentBaseClass)

function modifier_healer_heal_amp:OnCreated()
	self:OnRefresh()
end

function modifier_healer_heal_amp:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Healer", "HEAL_AMP" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_healer_heal_amp:GetModifierHealAmplify_Percentage()
	return self.value
end