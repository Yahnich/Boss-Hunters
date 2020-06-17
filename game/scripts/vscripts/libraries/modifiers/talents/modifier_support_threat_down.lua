modifier_support_threat_down = class(talentBaseClass)

function modifier_support_threat_down:OnCreated()
	self:OnRefresh()
end

function modifier_support_threat_down:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Support", "THREAT_DOWN" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_support_threat_down:Bonus_ThreatGain()
	return self.value
end