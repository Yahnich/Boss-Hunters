modifier_talent_magic_resist = class(talentBaseClass)

function modifier_talent_magic_resist:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "MAGIC_RESIST", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_magic_resist:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_talent_magic_resist:GetModifierMagicalResistanceBonus()
	return self.value
end