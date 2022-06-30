modifier_talent_threat_amp = class(talentBaseClass)

function modifier_talent_threat_amp:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "THREAT_AMP", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_threat_amp:Bonus_ThreatGain()
	return self.value
end