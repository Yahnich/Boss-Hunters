mystic_unyielding = class({})

function mystic_unyielding:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_mystic_unyielding_buff", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_mystic_unyielding_buff = class({})

function modifier_mystic_unyielding_buff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MIN_HEALTH, 
					MODIFIER_EVENT_ON_TAKEDAMAGE}
	return funcs
end

function modifier_mystic_unyielding_buff:GetMinHealth(params)
	PrintAll(params)
	return 1
end

function modifier_mystic_unyielding_buff:GetEffectName()
	return ""
end



