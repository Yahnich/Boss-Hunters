modifier_talent_health_regen = class(talentBaseClass)

function modifier_talent_health_regen:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "HEALTH_REGEN", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_health_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_talent_health_regen:GetModifierConstantHealthRegen()
	return self.value
end