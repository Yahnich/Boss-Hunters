modifier_talent_strength = class(talentBaseClass)

function modifier_talent_strength:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "STRENGTH", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_strength:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_talent_strength:GetModifierBonusStats_Strength()
	return self.value
end