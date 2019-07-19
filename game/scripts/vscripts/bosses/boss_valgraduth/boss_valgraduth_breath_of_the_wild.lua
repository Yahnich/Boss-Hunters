boss_valgraduth_breath_of_the_wild = class({})

function boss_valgraduth_breath_of_the_wild:GetIntrinsicModifierName()
	return "modifier_boss_valgraduth_breath_of_the_wild"
end

modifier_boss_valgraduth_breath_of_the_wild = class({})
LinkLuaModifier( "modifier_boss_valgraduth_breath_of_the_wild", "bosses/boss_valgraduth/boss_valgraduth_breath_of_the_wild", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_valgraduth_breath_of_the_wild:OnCreated()
		self.possibleSpawns = {	"npc_dota_boss26_mini", "npc_dota_boss6", "npc_dota_creature_broodmother", "npc_dota_boss_wolf", "npc_dota_boss26", "npc_dota_boss18", "npc_dota_boss23_m", "npc_dota_boss10"}
		self.health = self:GetSpecialValueFor("base_health")
		self.damage = self:GetSpecialValueFor("base_damage")
		self:StartIntervalThink( 1 )
	end
	
	function modifier_boss_valgraduth_breath_of_the_wild:OnRefresh()
		self:OnCreated()
	end
	
	function modifier_boss_valgraduth_breath_of_the_wild:OnIntervalThink()
		if not self:GetParent():IsAlive() then return end
		self:StartIntervalThink( self:GetSpecialValueFor("spawn_rate") )
		self:SetDuration( self:GetSpecialValueFor("spawn_rate") + 0.1, true )
		local spawn = CreateUnitByName( self.possibleSpawns[RandomInt(1, #self.possibleSpawns)], self:GetParent():GetAbsOrigin() + RandomVector( 150 ), true, nil, nil, DOTA_TEAM_BADGUYS)
		spawn:SetCoreHealth( self.health )
		spawn:SetAverageBaseDamage( self.damage, 25 )
		EmitSoundOn( "Hero_Treant.NaturesGuise.On", self:GetParent() )
	end
end