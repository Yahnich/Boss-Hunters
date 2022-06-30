modifier_talent_movespeed = class(talentBaseClass)

function modifier_talent_movespeed:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "MOVESPEED", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_movespeed:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_talent_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return self.value
end