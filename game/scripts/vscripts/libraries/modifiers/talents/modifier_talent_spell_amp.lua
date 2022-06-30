modifier_talent_spell_amp = class(talentBaseClass)

function modifier_talent_spell_amp:OnStackCountChanged()
	self.tier = math.floor( self:GetStackCount() / 10 )
	self.values = TalentManager:GetTalentDataForType( "SPELL_AMP", self.tier )
	self.level = self:GetStackCount() % 10
	self.value = tonumber(self.values[self.level])
end

function modifier_talent_spell_amp:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_talent_spell_amp:GetModifierSpellAmplify_Percentage()
	return self.value
end