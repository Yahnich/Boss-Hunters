modifier_attacker_health = class(talentBaseClass)

function modifier_attacker_health:OnCreated()
	self:OnRefresh()
end

function modifier_attacker_health:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Attacker", "HEALTH" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_attacker_health:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_attacker_health:GetModifierHealthBonus()
	return self.value
end