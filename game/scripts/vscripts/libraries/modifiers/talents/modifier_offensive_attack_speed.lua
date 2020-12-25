modifier_offensive_attack_speed = class(talentBaseClass)

function modifier_offensive_attack_speed:OnCreated()
	self:OnRefresh()
end

function modifier_offensive_attack_speed:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Offensive", "ATTACK_SPEED" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_offensive_attack_speed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_offensive_attack_speed:GetModifierAttackSpeedBonus_Constant()
	return self.value
end