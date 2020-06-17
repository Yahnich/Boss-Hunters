modifier_attacker_movespeed = class(talentBaseClass)

function modifier_attacker_movespeed:OnCreated()
	self:OnRefresh()
end

function modifier_attacker_movespeed:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Attacker", "MOVESPEED" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_attacker_movespeed:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_attacker_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return self.value
end