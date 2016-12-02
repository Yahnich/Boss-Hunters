modifier_perk_enrage = class({})

function modifier_perk_enrage:OnCreated( kv )
	self.threat_amp = self:GetAbility():GetSpecialValueFor( "threat_amp" ) / 100
	self:StartIntervalThink(0.1)
end

function modifier_perk_enrage:OnRefresh( kv )
	self.threat_amp = self:GetAbility():GetSpecialValueFor( "threat_amp" ) / 100
	self:StartIntervalThink(0.1)
end

function modifier_perk_enrage:IsHidden()
	return false
end

function modifier_perk_enrage:OnIntervalThink()
	local caster = self:GetParent()
	local threat = caster.threat
	if not caster.threat then return nil end
	if threat <= 0 then
		self:SetStackCount(0)
	else
		self:SetStackCount(threat*self.threat_amp)
	end
end

function modifier_perk_enrage:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount()
end

function modifier_perk_enrage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end