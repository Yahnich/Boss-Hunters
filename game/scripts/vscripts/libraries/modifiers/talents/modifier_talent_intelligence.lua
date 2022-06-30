modifier_talent_intelligence = class(talentBaseClass)

function modifier_talent_intelligence:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "INTELLIGENCE", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_intelligence:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_talent_intelligence:GetModifierBonusStats_Intellect()
	return self.value
end