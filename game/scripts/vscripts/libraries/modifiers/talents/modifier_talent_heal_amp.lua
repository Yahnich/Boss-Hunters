modifier_talent_heal_amp = class(talentBaseClass)

function modifier_talent_heal_amp:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "HEAL_AMP", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_heal_amp:GetModifierHealAmplify_Percentage()
	return self.value
end