modifier_talent_mana_regen = class(talentBaseClass)

function modifier_talent_mana_regen:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "MANA_REGEN", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_mana_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function modifier_talent_mana_regen:GetModifierConstantManaRegen()
	return self.value
end