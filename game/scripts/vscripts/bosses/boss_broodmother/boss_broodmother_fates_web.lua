boss_broodmother_fates_web = class({})

function boss_broodmother_fates_web:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local duration = self:GetSpecialValueFor("duration")
	CreateModifierThinker(caster, self, "modifier_boss_broodmother_fates_web_web", {duration = duration}, target, caster:GetTeam(), false)
end


modifier_boss_broodmother_fates_web_web = class({})
LinkLuaModifier("modifier_boss_broodmother_fates_web_web", "bosses/boss_broodmother/boss_broodmother_fates_web", LUA_MODIFIER_MOTION_NONE)



modifier_boss_broodmother_fates_web_handler = class({})
LinkLuaModifier("modifier_boss_broodmother_fates_web_handler", "bosses/boss_broodmother/boss_broodmother_fates_web", LUA_MODIFIER_MOTION_NONE)