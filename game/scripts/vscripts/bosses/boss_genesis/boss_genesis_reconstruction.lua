boss_genesis_reconstruction = class({})

function boss_genesis_reconstruction:GetIntrinsicModifierName()
	return "modifier_boss_genesis_reconstruction"
end

modifier_boss_genesis_reconstruction = class({})
LinkLuaModifier( "modifier_boss_genesis_reconstruction", "bosses/boss_genesis/boss_genesis_reconstruction", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_reconstruction:DeclareFunctions()
	return {}
end

function modifier_boss_genesis_reconstruction:Gethealthregne()
	if self:GetCaster():HasModifier("modifier_boss_genesis_strengthen_resolve") then
		return self:GetSpecialValueFor("regen")
	else
		return self:GetSpecialValueFor("regen_buff")
	end
end