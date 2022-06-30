undying_tombstone_bh = class({})

function undying_tombstone_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	if caster:HasTalent("special_bonus_unique_undying_tombstone_1") then
		self.decay = caster:FindAbilityByName( "undying_decay_bh" )
		if not self.decay:IsTrained() then
			self.decay = nil
		end
	end
	
	local duration = self:GetTalentSpecialValueFor("tombstone_duration")
	local tombstone = self:GetCaster():CreateSummon("npc_dota_unit_tombstone4", position, duration, false)
	tombstone:AddNewModifier(caster, self, "undying_tombstone_bh_tombstone", {duration = duration})
	tombstone:SetCoreHealth( self:GetTalentSpecialValueFor("tombstone_hp") )
end

function undying_tombstone_bh:SummonZombie( unit, duration )
	local caster = self:GetCaster()
	local fDur = duration or self:GetTalentSpecialValueFor("tombstone_duration")
	local zombie = caster:CreateSummon("npc_dota_unit_undying_tombstone_zombie", unit:GetAbsOrigin(), duration, false)
	if RandomInt( 1, 100 ) < 50 then
		zombie:SetOriginalModel( "models/heroes/undying/undying_minion_torso.vmdl" )
		zombie:SetModel( "models/heroes/undying/undying_minion_torso.vmdl" )
	end
	zombie:CreatureLevelUp( caster:GetLevel() - 1 )
	zombie:AddNewModifier(caster, self, "undying_tombstone_bh_zombie", {unit = unit:entindex()})
	zombie:SetCoreHealth( self:GetTalentSpecialValueFor("zombie_hp") )
	zombie:SetAverageBaseDamage( caster:GetStrength() * self:GetTalentSpecialValueFor("zombie_atk_dmg") / 100 )
	return zombie
end

undying_tombstone_bh_tombstone = class({})
LinkLuaModifier( "undying_tombstone_bh_tombstone", "heroes/hero_undying/undying_tombstone_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function undying_tombstone_bh_tombstone:OnCreated( )
		self.spawnInterval = self:GetTalentSpecialValueFor("tombstone_spawn_interval")
		self.spawnRadius = self:GetTalentSpecialValueFor("tombstone_spawn_radius")
		
		self.dmgBoss = self:GetTalentSpecialValueFor("zombie_boss_dmg")
		self.dmgMonster = self:GetTalentSpecialValueFor("zombie_boss_dmg")
		self.dmgMinion = self:GetTalentSpecialValueFor("zombie_dmg")
		
		self.tombstoneZombies = {}
		
		self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_undying_tombstone_2")
		self.talent2Radius = self:GetCaster():FindTalentValue("special_bonus_unique_undying_tombstone_2")
		
		self:StartIntervalThink( self.spawnInterval )
		self:OnIntervalThink( )
	end
	
	function undying_tombstone_bh_tombstone:OnIntervalThink()
		local caster = self:GetCaster()
		local tombstone = self:GetParent()
		local ability = self:GetAbility()
		
		local zombies = 0
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( tombstone:GetAbsOrigin(), self.spawnRadius ) ) do
			local zombie = ability:SummonZombie( enemy, self:GetRemainingTime( ) )
			table.insert( self.tombstoneZombies, zombie )
			zombies = zombies + 1
		end
		tombstone:ModifyThreat( 5 * zombies, true )
	end
	
	function undying_tombstone_bh_tombstone:OnDestroy()
		for _, zombie in ipairs( self.tombstoneZombies ) do
			if zombie and not zombie:IsNull() and zombie:IsAlive() then
				zombie:ForceKill( false )
			end
		end
	end
end

function undying_tombstone_bh_tombstone:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function undying_tombstone_bh_tombstone:GetModifierIncomingDamage_Percentage(params)
	local parent = self:GetParent()
	if params.inflictor then
		return -999
	else
		local hp = parent:GetHealth()
		local damage = TernaryOperator( self.dmgBoss, params.attacker:IsBoss(), TernaryOperator( self.dmgMinion, params.attacker:IsMinion(), self.dmgMonster ) )
		if damage < hp and params.inflictor ~= self:GetAbility() then
			parent:SetHealth( hp - damage )
			return -999
		elseif hp <= 1 then
			self:GetParent():StartGesture(ACT_DOTA_DIE)
			parent:Kill(params.inflictor, params.attacker)
		end
	end
end

function undying_tombstone_bh_tombstone:GetModifierHealAmplify_Percentage( params )
	if not params.ability then
		return -999
	else
		local hp = self:GetParent():GetHealth()
		heal = math.floor( math.log( params.amount ) + 0.5 )
		if heal > 0 then
			self:GetParent():SetHealth( math.min( hp + heal, self:GetParent():GetMaxHealth() ) )
		end
	end
end


function undying_tombstone_bh_tombstone:IsAura()
	return self.talent2
end

function undying_tombstone_bh_tombstone:GetModifierAura()
	return "undying_tombstone_bh_tombstone_talent"
end

function undying_tombstone_bh_tombstone:GetAuraRadius()
	return self.talent2Radius
end

function undying_tombstone_bh_tombstone:GetAuraDuration()
	return 0.5
end

function undying_tombstone_bh_tombstone:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function undying_tombstone_bh_tombstone:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function undying_tombstone_bh_tombstone:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function undying_tombstone_bh_tombstone:GetEffectName()
	if self:GetCaster():HasTalent("special_bonus_unique_undying_tombstone_2") then
		return "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud.vpcf"
	end
end

function undying_tombstone_bh_tombstone:IsHidden()
	return true
end

function undying_tombstone_bh_tombstone:IsPurgable()
	return false
end

undying_tombstone_bh_tombstone_talent = class({})
LinkLuaModifier( "undying_tombstone_bh_tombstone_talent", "heroes/hero_undying/undying_tombstone_bh", LUA_MODIFIER_MOTION_NONE)

function undying_tombstone_bh_tombstone_talent:OnCreated()
	self.talent2Slow = self:GetCaster():FindTalentValue( "special_bonus_unique_undying_tombstone_2", "slow" )
	self.talent2Blind = self:GetCaster():FindTalentValue( "special_bonus_unique_undying_tombstone_2", "blind" )
end

function undying_tombstone_bh_tombstone_talent:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function undying_tombstone_bh_tombstone_talent:GetModifierMoveSpeedBonus_Percentage(params)
	return -self.talent2Slow
end

function undying_tombstone_bh_tombstone_talent:GetModifierMiss_Percentage(params)
	return self.talent2Blind
end

function undying_tombstone_bh_tombstone_talent:GetEffectName()
	return "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud_debuff.vpcf"
end

undying_tombstone_bh_zombie = class({})
LinkLuaModifier( "undying_tombstone_bh_zombie", "heroes/hero_undying/undying_tombstone_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function undying_tombstone_bh_zombie:OnCreated( kv )
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		
		self.unit = EntIndexToHScript( kv.unit )
		
		self.dmgBoss = self:GetTalentSpecialValueFor("zombie_boss_dmg")
		self.dmgOther = self:GetTalentSpecialValueFor("zombie_dmg")
		
		self:StartIntervalThink(0.5)
		self:OnIntervalThink( )
	end
	
	function undying_tombstone_bh_zombie:OnIntervalThink()
		if self.unit then
			if not self.unit:IsNull() and self.unit:IsAlive() then
				self.parent:MoveToTargetToAttack( self.unit )
			else
				self.parent:ForceKill( false )
			end
		else
			self.parent:MoveToPositionAggressive( self.caster:GetAbsOrigin() + RandomVector(350) )
		end
	end
	
	function undying_tombstone_bh_zombie:OnDestroy( kv )
		local decay = self:GetAbility().decay
		
		local chance = self:GetCaster():FindTalentValue("special_bonus_unique_undying_tombstone_1")
		local radius = self:GetCaster():FindTalentValue("special_bonus_unique_undying_tombstone_1", "value2")
		if decay and RollPercentage( chance ) then
			decay:Decay( self:GetParent():GetAbsOrigin(), radius / 100 )
		end
	end
end

function undying_tombstone_bh_zombie:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function undying_tombstone_bh_zombie:GetModifierIncomingDamage_Percentage(params)
	local parent = self:GetParent()
	if params.inflictor then
		return -999
	else
		local hp = parent:GetHealth()
		local damage = TernaryOperator( self.dmgBoss, params.attacker:IsBoss(), self.dmgOther )
		if damage < hp and params.inflictor ~= self:GetAbility() then
			parent:SetHealth( hp - damage )
			return -999
		elseif hp <= 1 then
			self:GetParent():StartGesture(ACT_DOTA_DIE)
			parent:Kill(params.inflictor, params.attacker)
		end
	end
end

function undying_tombstone_bh_zombie:GetModifierHealAmplify_Percentage( params )
	if not params.ability then
		return -999
	else
		local hp = self:GetParent():GetHealth()
		heal = math.floor( math.log10( params.amount ) + 0.5 )
		if heal > 0 then
			self:GetParent():SetHealth( math.min( hp + heal, self:GetParent():GetMaxHealth() ) )
		end
	end
end

function undying_tombstone_bh_zombie:IsHidden()
	return true
end

function undying_tombstone_bh_zombie:IsPurgable()
	return false
end