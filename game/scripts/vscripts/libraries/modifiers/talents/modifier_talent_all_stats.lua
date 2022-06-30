modifier_talent_all_stats = class(talentBaseClass)

function modifier_talent_all_stats:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "ALL_STATS", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_all_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_talent_all_stats:GetModifierBonusStats_Intellect()
	return self.value
end

function modifier_talent_all_stats:GetModifierBonusStats_Strength()
	return self.value
end

function modifier_talent_all_stats:GetModifierBonusStats_Agility()
	return self.value
end
