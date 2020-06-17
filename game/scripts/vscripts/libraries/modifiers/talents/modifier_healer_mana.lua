modifier_healer_mana = class(talentBaseClass)

function modifier_healer_mana:OnCreated()
	self:OnRefresh()
end

function modifier_healer_mana:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Healer", "MANA" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_healer_mana:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS }
end

function modifier_healer_mana:GetModifierManaBonus()
	return self.value
end