modifier_talent_threat_down = class(talentBaseClass)

function modifier_talent_threat_down:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "THREAT_DOWN", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_threat_down:Bonus_ThreatGain()
	return self.value
end