modifier_attacker_evasion = class(talentBaseClass)

function modifier_attacker_evasion:OnCreated()
	self:OnRefresh()
end

function modifier_attacker_evasion:OnRefresh()
	self.tier = (self.tier or 0) + 1
	self.values = self.values or TalentManager:GetTalentDataForType( "Attacker", "EVASION" )
	self.value = tonumber(self.values[self.tier])
end

function modifier_attacker_evasion:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_attacker_evasion:GetModifierEvasion_Constant()
	return self.value
end