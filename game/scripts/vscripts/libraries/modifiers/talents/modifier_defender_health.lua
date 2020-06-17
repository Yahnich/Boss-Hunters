modifier_defender_health = class(talentBaseClass)

function modifier_defender_health:OnCreated()
	self:OnRefresh()
end

function modifier_defender_health:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Defender", "HEALTH" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_defender_health:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_defender_health:GetModifierHealthBonus()
	return self.value
end