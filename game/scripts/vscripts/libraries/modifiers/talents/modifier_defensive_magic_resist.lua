modifier_defensive_magic_resist = class(talentBaseClass)

function modifier_defensive_magic_resist:OnCreated()
	self:OnRefresh()
end

function modifier_defensive_magic_resist:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Defensive", "MAGIC_RESIST" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_defensive_magic_resist:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_defensive_magic_resist:GetModifierMagicalResistanceBonus()
	return self.value
end