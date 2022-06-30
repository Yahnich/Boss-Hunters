modifier_talent_mana = class(talentBaseClass)

function modifier_talent_mana:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "MANA", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_mana:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS }
end

function modifier_talent_mana:GetModifierManaBonus()
	return self.value
end