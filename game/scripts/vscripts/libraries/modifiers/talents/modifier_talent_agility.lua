modifier_talent_agility = class(talentBaseClass)

function modifier_talent_agility:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "AGILITY", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_agility:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_talent_agility:GetModifierBonusStats_Agility()
	return self.value
end