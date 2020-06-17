modifier_attacker_attack_speed = class(talentBaseClass)

function modifier_attacker_attack_speed:OnCreated()
	self:OnRefresh()
end

function modifier_attacker_attack_speed:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Attacker", "ATTACK_SPEED" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_attacker_attack_speed:GetModifierAttackSpeedBonus()
	return self.value
end