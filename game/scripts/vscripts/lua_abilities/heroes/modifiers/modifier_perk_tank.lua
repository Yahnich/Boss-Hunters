modifier_perk_tank = class({})

function modifier_perk_tank:OnCreated( kv )
	self.tank_perc = self:GetAbility():GetSpecialValueFor( "tank_perc" ) / 100
end

function modifier_perk_tank:OnRefresh( kv )
	self.tank_perc = self:GetAbility():GetSpecialValueFor( "tank_perc" ) / 100
end

function modifier_perk_tank:IsHidden()
	return true
end

function modifier_perk_tank:GetModifierExtraHealthPercentage()
	return self.tank_perc
end

function modifier_perk_tank:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}

	return funcs
end