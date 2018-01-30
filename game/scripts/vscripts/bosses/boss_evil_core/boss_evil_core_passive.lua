boss_evil_core_passive = class({})

function boss_evil_core_passive:GetIntrinsicModifierName()
	return "modifier_boss_evil_core_passive"
end

modifier_boss_evil_core_passive = class({})
LinkLuaModifier("modifier_boss_evil_core_passive", "bosses/boss_evil_core/boss_evil_core_passive", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	POSSIBLE_BOSSES = {	"npc_dota_boss31", 
						"npc_dota_boss32_trueform", 
						"npc_dota_boss33_a", 
						"npc_dota_boss33_b", 
						"npc_dota_boss34", 
						"npc_dota_boss35" }

	function modifier_boss_evil_core_passive:OnCreated()
		self.manaCharge = self:GetParent():GetMaxMana()
		self.manaChargeRegen = ( self.manaCharge / self:GetTalentSpecialValueFor("recharge_time") ) * 0.3
		self.damageTaken = self:GetTalentSpecialValueFor("damage_per_hit")
		
		
		self:StartIntervalThink(0.3)
		self:ActivateShield()
	end
	
	function modifier_boss_evil_core_passive:OnDestroy()
		self:DestroyShield()
		self:SpawnAsura(self:GetParent():GetAbsOrigin())
	end
	
	function modifier_boss_evil_core_passive:OnIntervalThink()
		local parent = self:GetParent()
		parent:SetMana(self.manaCharge)
		if not self.shield then
			if self.manaCharge < parent:GetMaxMana() then
				self.manaCharge = math.min(parent:GetMaxMana(), self.manaCharge + self.manaChargeRegen)
			elseif self:GetAbility():IsCooldownReady() then -- guarantee a minimum of time between casts
				self:ActivateShield()
			end
		else
			self.manaCharge = math.min(parent:GetMaxMana(), self.manaCharge + self.manaChargeRegen)
			if self.manaCharge >= parent:GetMaxMana() then
				self:DestroyShield()
			end
		end
	end
	
	function modifier_boss_evil_core_passive:ActivateShield(bInit)
		local parent = self:GetParent()
		self.shield = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_POINT_FOLLOW, parent)
		ParticleManager:SetParticleControl(self.shield, 1, Vector(200,200,0))
		local count = 2
		
		self:GetAbility():SetCooldown()
		self.manaCharge = 0
		parent:SetMana(self.manaCharge)
		self:SpawnRandomUnits(parent:GetAbsOrigin() + ActualRandomVector(500), count + math.floor((100 - parent:GetHealthPercent()) / 25) )
	end
	
	function modifier_boss_evil_core_passive:DestroyShield()
		ParticleManager:ClearParticle(self.shield)
		self.shield = nil
	end
	
	function modifier_boss_evil_core_passive:SpawnAsura(position)
		local caster = self:GetCaster()
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
			if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and unit:GetUnitName() ~= "npc_dota_boss36" and unit:GetUnitName() ~= "npc_dota_boss36_guardian" then
				unit:ForceKill(true)
			end
		end
		local asura = CreateUnitByName( "npc_dota_boss36_guardian" , position, true, nil, nil, caster:GetTeam() )
		asura:AddNewModifier(caster, self:GetAbility(), "modifier_spawn_timer", {duration = 3})
		GameRules.holdOut:_RefreshPlayers()
	end
	
	function modifier_boss_evil_core_passive:SpawnRandomUnits(position, count)
		for i = 1, count do
			local spawnedUnit = CreateUnitByName( POSSIBLE_BOSSES[RandomInt(1, #POSSIBLE_BOSSES)] , position, true, nil, nil, self:GetCaster():GetTeam() )
			spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetBaseMaxHealth() / 4)
			spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth() / 4)
			spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
			spawnedUnit:SetAverageBaseDamage(spawnedUnit:GetAverageBaseDamage() / 2, 20)
			
			spawnedUnit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_spawn_timer", {duration = 3})
		end
	end
end

function modifier_boss_evil_core_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_evil_core_passive:GetModifierIncomingDamage_Percentage( params )
	local parent = self:GetParent()
	
	local damage = self.damageTaken * ((GameRules.BasePlayers - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)) + 1)
	if self.shield then damage = 1 end
	if parent:GetHealth() > damage then
		parent:SetHealth( math.max(1, parent:GetHealth() - damage) )
	else
		parent:Kill(params.inflictor, params.attacker)
	end
	return -999
end