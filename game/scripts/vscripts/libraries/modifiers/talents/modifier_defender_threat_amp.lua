modifier_defender_threat_amp = class(talentBaseClass)

function modifier_defender_threat_amp:OnCreated()
	self:OnRefresh()
end

function modifier_defender_threat_amp:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Defender", "THREAT_AMP" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_defender_threat_amp:Bonus_ThreatGain()
	return self.value
end