boss_doom_blood_is_power = class({})

function boss_doom_blood_is_power:GetIntrinsicModifierName()
	return "modifier_boss_doom_blood_is_power"
end

modifier_boss_doom_blood_is_power = class({})
LinkLuaModifier("modifier_boss_doom_blood_is_power", "bosses/boss_doom/boss_doom_blood_is_power", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_doom_blood_is_power:OnCreated()
	self.max_cdr = self:GetSpecialValueFor("max_cdr")
end

function modifier_boss_doom_blood_is_power:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function modifier_boss_doom_blood_is_power:GetModifierPercentageCooldown()
	return math.min( self.max_cdr, 100 - self:GetParent():GetHealthPercent() )
end

function modifier_boss_doom_blood_is_power:IsHidden()
	return true
end