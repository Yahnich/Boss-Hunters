modifier_talent_status_amp = class(talentBaseClass)

function modifier_talent_status_amp:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "STATUS_AMP", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_status_amp:GetModifierStatusAmplify_Percentage()
	return self.value
end