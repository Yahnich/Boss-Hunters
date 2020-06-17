modifier_nuker_spell_amp = class(talentBaseClass)

function modifier_nuker_spell_amp:OnCreated()
	self:OnRefresh()
end

function modifier_nuker_spell_amp:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Nuker", "SPELL_AMP" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_nuker_spell_amp:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_nuker_spell_amp:GetModifierSpellAmplify_Percentage()
	return self.value
end