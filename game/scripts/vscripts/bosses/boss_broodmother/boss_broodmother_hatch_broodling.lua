boss_broodmother_hatch_broodling = class({})

function boss_broodmother_hatch_broodling:GetIntrinsicModifierName()
	return "modifier_boss_broodmother_hatch_broodling_handler"
end

modifier_boss_broodmother_hatch_broodling_handler = class({})
LinkLuaModifier("modifier_boss_broodmother_hatch_broodling_handler", "bosses/boss_broodmother/boss_broodmother_hatch_broodling", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_broodmother_hatch_broodling_handler:OnCreated()
		self:StartIntervalThink( self:GetSpecialValueFor("hatch_delay") + RandomFloat(-1, 1) )
	end
	
	function modifier_boss_broodmother_hatch_broodling_handler:OnIntervalThink()
		EmitSoundOn( "Hero_Broodmother.SpawnSpiderlingsDeath", self:GetParent() )
		self:GetParent():ForceKill( false )
		UTIL_Remove(self:GetParent())
		CreateUnitByName("npc_dota_creature_broodmother", self:GetParent():GetAbsOrigin(), true, self, nil, self:GetCaster():GetTeam())
	end
end