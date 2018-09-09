boss_genesis_sanctuary = class({})

function boss_genesis_sanctuary:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_genesis_sanctuary", {duration = self:GetSpecialValueFor("duration")} )
	caster:EmitSound("Hero_Omniknight.Repel")
end

modifier_boss_genesis_sanctuary = class({})
LinkLuaModifier( "modifier_boss_genesis_sanctuary", "bosses/boss_genesis/boss_genesis_sanctuary", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_sanctuary:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL}
end

function modifier_boss_genesis_sanctuary:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_boss_genesis_sanctuary:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end