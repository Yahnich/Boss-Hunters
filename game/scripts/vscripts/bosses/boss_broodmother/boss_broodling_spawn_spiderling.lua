boss_broodling_spawn_spiderling = class({})

function boss_broodling_spawn_spiderling:OnSpellStart()
	for i = 1, self:GetSpecialValueFor("spiders_spawned") do
		CreateUnitByName("npc_dota_creature_spiderling", self:GetCaster():GetAbsOrigin() + RandomVector(150), true, self, nil, self:GetCaster():GetTeam())
	end
end