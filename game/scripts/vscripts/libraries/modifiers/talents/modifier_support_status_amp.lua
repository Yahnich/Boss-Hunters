modifier_support_status_amp = class(talentBaseClass)

function modifier_support_status_amp:OnCreated()
	self:OnRefresh()
end

function modifier_support_status_amp:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Support", "STATUS_AMP" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_support_status_amp:GetModifierStatusAmplify_Percentage()
	return self.value
end