boss_broodling_spawn_spiderling = class({})

function boss_broodling_spawn_spiderling:OnSpellStart()
	self.spiders = self.spiders or {}
	for i = #self.spiders, 1, -1 do
		local spider = self.spiders[i]
		if spider:IsNull() or not spider:IsAlive() then
			table.remove( self.spiders, i )
		end
	end
	for i = 1, self:GetSpecialValueFor("spiders_spawned") do
		if #self.spiders < 10 then
			local spider = CreateUnitByName("npc_dota_creature_spiderling", self:GetCaster():GetAbsOrigin() + RandomVector(150), true, self, nil, self:GetCaster():GetTeam())
			table.insert( self.spiders, spider )
		end
	end
end