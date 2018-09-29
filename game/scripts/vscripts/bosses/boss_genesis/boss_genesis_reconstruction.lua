boss_genesis_reconstruction = class({})

function boss_genesis_reconstruction:GetIntrinsicModifierName()
	return "modifier_boss_genesis_reconstruction"
end

modifier_boss_genesis_reconstruction = class({})
LinkLuaModifier( "modifier_boss_genesis_reconstruction", "bosses/boss_genesis/boss_genesis_reconstruction", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_reconstruction:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_boss_genesis_reconstruction:GetModifierHealthRegenPercentage()
	if self:GetCaster():HasModifier("modifier_boss_genesis_strengthen_resolve") then
		return self:GetSpecialValueFor("regen_buff")
	elseif not self:GetCaster():PassivesDisabled() then
		return self:GetSpecialValueFor("regen")
	end
end

function modifier_boss_genesis_reconstruction:IsHidden()
	return true
end
