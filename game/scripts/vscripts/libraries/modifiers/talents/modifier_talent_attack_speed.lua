modifier_talent_attack_speed = class(talentBaseClass)

function modifier_talent_attack_speed:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "ATTACK_SPEED", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
	
end

function modifier_talent_attack_speed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_talent_attack_speed:GetModifierAttackSpeedBonus_Constant()
	return self.value
end