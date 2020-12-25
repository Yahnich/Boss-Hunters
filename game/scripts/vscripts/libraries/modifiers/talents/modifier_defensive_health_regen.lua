modifier_defensive_health_regen = class(talentBaseClass)

function modifier_defensive_health_regen:OnCreated()
	self:OnRefresh()
end

function modifier_defensive_health_regen:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Defensive", "HEALTH_REGEN" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_defensive_health_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_defensive_health_regen:GetModifierConstantHealthRegen()
	return self.value
end