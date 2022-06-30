modifier_talent_armor = class(talentBaseClass)

function modifier_talent_armor:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "ARMOR", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_talent_armor:GetModifierPhysicalArmorBonus()
	return self.value
end