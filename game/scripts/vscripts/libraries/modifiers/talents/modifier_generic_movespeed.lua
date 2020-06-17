modifier_generic_movespeed = class(talentBaseClass)

function modifier_generic_movespeed:OnCreated()
	self:OnRefresh()
end

function modifier_generic_movespeed:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Generic", "MOVESPEED" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_generic_movespeed:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_generic_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return self.value
end