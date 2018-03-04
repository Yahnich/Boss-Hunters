boss_broodmother_fates_web = class({})

function boss_broodmother_fates_web:OnSpellStart()
	local caster = self:GetCaster()
	
	CreateModifierThinker(caster, self, "modifier_legion_commander_war_fury_thinker", {duration = duration}, target, caster:GetTeam(), false)
end