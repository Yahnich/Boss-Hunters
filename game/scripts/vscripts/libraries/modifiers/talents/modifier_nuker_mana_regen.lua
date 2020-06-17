modifier_nuker_mana_regen = class(talentBaseClass)

function modifier_nuker_mana_regen:OnCreated()
	self:OnRefresh()
end

function modifier_nuker_mana_regen:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Nuker", "MANA_REGEN" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_nuker_mana_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function modifier_nuker_mana_regen:GetModifierConstantManaRegen()
	return self.value
end