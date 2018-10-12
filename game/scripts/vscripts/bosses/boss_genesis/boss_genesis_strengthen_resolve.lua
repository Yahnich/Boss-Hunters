boss_genesis_strengthen_resolve = class({})

function boss_genesis_strengthen_resolve:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_genesis_strengthen_resolve", {duration = self:GetSpecialValueFor("duration")} )
end

modifier_boss_genesis_strengthen_resolve = class({})
LinkLuaModifier( "modifier_boss_genesis_strengthen_resolve", "bosses/boss_genesis/boss_genesis_strengthen_resolve", LUA_MODIFIER_MOTION_NONE )