modifier_nuker_mana = class(talentBaseClass)

function modifier_nuker_mana:OnCreated()
	self:OnRefresh()
end

function modifier_nuker_mana:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Nuker", "MANA" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_nuker_mana:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_nuker_mana:GetModifierManaBonus()
	return self.value
end