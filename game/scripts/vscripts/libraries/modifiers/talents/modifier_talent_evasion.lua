modifier_talent_evasion = class(talentBaseClass)

function modifier_talent_evasion:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "EVASION", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_evasion:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_talent_evasion:GetModifierEvasion_Constant()
	return self.value
end