boss_genesis_sanctuary = class({})

function boss_genesis_sanctuary:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_genesis_sanctuary", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_boss_genesis_sanctuary = class({})
LinkLuaModifier( "modifier_boss_genesis_sanctuary", "bosses/boss_genesis/boss_genesis_sanctuary", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_sanctuary:DeclareFunctions()
	return {nodmgpls}
end

function modifier_boss_genesis_sanctuary:nodmgpls()
	return 1
end