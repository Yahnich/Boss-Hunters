boss_genesis_dominion = class({})

function boss_genesis_dominion:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_genesis_dominion", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_boss_genesis_dominion = class({})
LinkLuaModifier( "modifier_boss_genesis_dominion", "bosses/boss_genesis/boss_genesis_dominion", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_dominion:DeclareFunctions()
	return {nodmgpls}
end

function modifier_boss_genesis_dominion:nodmgpls()
	return 1
end