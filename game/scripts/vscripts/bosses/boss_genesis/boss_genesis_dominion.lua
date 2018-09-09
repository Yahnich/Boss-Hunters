boss_genesis_dominion = class({})

function boss_genesis_dominion:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_genesis_dominion", {duration = self:GetSpecialValueFor("duration")} )
	caster:EmitSound("Hero_Omniknight.GuardianAngel")
end

modifier_boss_genesis_dominion = class({})
LinkLuaModifier( "modifier_boss_genesis_dominion", "bosses/boss_genesis/boss_genesis_dominion", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_dominion:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL}
end

function modifier_boss_genesis_dominion:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_boss_genesis_dominion:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
end