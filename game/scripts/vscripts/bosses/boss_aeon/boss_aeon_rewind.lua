boss_aeon_rewind = class({})

POSSIBLE_BOSS_TABLE = {	"npc_dota_boss28", 
						"npc_dota_boss21", 
						"npc_dota_boss4", 
						"npc_dota_boss22", 
						"npc_dota_boss_troll_warlord",
						"npc_dota_boss23",
						"npc_dota_greymane",
						"npc_dota_boss16",}
						
function boss_aeon_rewind:OnAbilityPhaseStart()
	self.positions = {}
	local caster = self:GetCaster()
	for i = 1, self:GetSpecialValueFor("spawns") do
		local position = caster:GetAbsOrigin() + ActualRandomVector(600, 200)
		ParticleManager:FireWarningParticle(position, 128)
		table.insert( self.positions, position )
	end
	return true
end

function boss_aeon_rewind:OnSpellStart()
	local caster = self:GetCaster()
	
	for _, summon in ipairs(self.summons or {}) do
		if not summon:IsNull() and summon:IsAlive() then
			summon:ForceKill(false)
		end
	end
	
	self.summons = {}
	setmetatable(self.summons, {__mode = "v"})
	local hpMult = self:GetSpecialValueFor("curr_hp_mult") / 100
	for _, position in ipairs( self.positions ) do
		local spawnName = POSSIBLE_BOSS_TABLE[RandomInt(1, #POSSIBLE_BOSS_TABLE)]
		local spawnedUnit = CreateUnitByName( spawnName, position, true, nil, nil, caster:GetTeam() )
		spawnedUnit:SetCoreHealth( math.ceil( caster:GetHealth() * hpMult) )
		spawnedUnit:SetAverageBaseDamage(spawnedUnit:GetAverageBaseDamage() * 0.6, 20)
		
		if spawnName == "npc_dota_boss22" then
			spawnedUnit:FindAbilityByName("boss15_peel_the_veil"):SetActivated(false)
		elseif spawnName == "npc_dota_boss23" then
			spawnedUnit:FindAbilityByName("boss16_the_flock"):SetActivated(false)
		end
		
		spawnedUnit:AddNewModifier(self:GetCaster(), self, "modifier_spawn_immunity", {duration = 2})
		spawnedUnit:AddNewModifier(self:GetCaster(), self, "modifier_silence_generic", {duration = 5})
		spawnedUnit.hasBeenInitialized = true
		table.insert(self.summons, spawnedUnit)
	end
end