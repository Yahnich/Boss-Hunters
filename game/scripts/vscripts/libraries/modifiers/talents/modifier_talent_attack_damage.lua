modifier_talent_attack_damage = class(talentBaseClass)

function modifier_talent_attack_damage:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "ATTACK_DAMAGE", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_attack_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_talent_attack_damage:GetModifierBaseAttack_BonusDamage()
	return self.value
end