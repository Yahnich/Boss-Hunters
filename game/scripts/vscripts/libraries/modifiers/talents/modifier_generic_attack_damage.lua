modifier_generic_attack_damage = class(talentBaseClass)

function modifier_generic_attack_damage:OnCreated()
	self:OnRefresh()
end

function modifier_generic_attack_damage:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Generic", "ATTACK_DAMAGE" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_generic_attack_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_generic_attack_damage:GetModifierBaseAttack_BonusDamage()
	return self.value
end