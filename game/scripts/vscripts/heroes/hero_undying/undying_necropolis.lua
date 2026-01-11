undying_necropolis = class({})

function undying_necropolis:GetBehavior()
	if self:GetSpecialValueFor("enter_tombstone") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function undying_necropolis:CastFilterResultTarget(target)
	return UnitFilter( target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, target:GetTeamNumber() )
end

function undying_necropolis:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local target = self:GetCursorTarget()
	
	local duration = self:GetSpecialValueFor("tombstone_duration")
	
	
	if self:GetSpecialValueFor("decay_chance") > 0 then
		self.decay = caster:FindAbilityByName( "undying_devour_life" )
		if not self.decay:IsTrained() then
			self.decay = nil
		end
	end
	
	local tombstone = self:GetCaster():CreateSummon("npc_dota_unit_tombstone4", position, duration, false)
	tombstone:AddNewModifier(caster, self, "modifier_undying_necropolis_tombstone", {duration = duration})
	tombstone:SetCoreHealth( self:GetSpecialValueFor("tombstone_hp") )
	if target then
		local hideaway = target:AddNewModifier( caster, self, "modifier_undying_necropolis_legion", {duration = duration} )
		hideaway.tombstone = tombstone
		tombstone._hideawayUnit = target
	end
end

function undying_necropolis:SummonZombie( unit, duration )
	local caster = self:GetCaster()
	local fDur = duration or self:GetSpecialValueFor("tombstone_duration")
	local zombie = caster:CreateSummon("npc_dota_unit_undying_zombie", unit:GetAbsOrigin(), duration, false)
	if RandomInt( 1, 100 ) < 50 then
		zombie:SetOriginalModel( "models/heroes/undying/undying_minion_torso.vmdl" )
		zombie:SetModel( "models/heroes/undying/undying_minion_torso.vmdl" )
	end
	zombie:CreatureLevelUp( caster:GetLevel() - 1 )
	zombie:AddNewModifier(caster, self, "modifier_undying_necropolis_zombie", {unit = unit:entindex()})
	zombie:SetCoreHealth( self:GetSpecialValueFor("zombie_hp") )
	zombie:SetAverageBaseDamage( caster:GetStrength() * self:GetSpecialValueFor("zombie_atk_dmg") / 100 )
	return zombie
end

modifier_undying_necropolis_legion = class({})
LinkLuaModifier( "modifier_undying_necropolis_legion", "heroes/hero_undying/undying_necropolis", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_necropolis_legion:OnCreated()
	if IsServer() then
		self:StartIntervalThink( 0.2 )
	end
end

function modifier_undying_necropolis_legion:OnIntervalThink()
	if CalculateDistance( self:GetParent(), self.tombstone ) > 128 then
		tombstone._hideawayUnit = nil
		self:Destroy()
	end
end

function modifier_undying_necropolis_legion:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true
			[MODIFIER_STATE_OUT_OF_GAME] = true
			[MODIFIER_STATE_INVULNERABLE] = true}
end

function modifier_undying_necropolis_legion:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_undying_necropolis_legion:GetModifierInvisibilityLevel()
	return 1.0
end

modifier_undying_necropolis_undying = class({})
LinkLuaModifier( "modifier_undying_necropolis_undying", "heroes/hero_undying/undying_necropolis", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_necropolis_undying:OnCreated()
	self.hpConversion = self:GetSpecialValueFor("tombstone_hp_conversion") / 100
	self.damage = self:GetSpecialValueFor("tombstone_boss_dmg")
	if IsServer() then
		self._lastHP = self:GetCaster():GetHealth()
		self._damageTaken = 0
		self._damageHealed = 0
		self:StartIntervalThink( 0.2 )
	end
end

function modifier_undying_necropolis_undying:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local healthChange = caster:GetHealth() - self._lastHP
	if healthChange > 0 then
		self._damageHealed = self._damageHealed + math.abs(healthChange)
	else
		self._damageTaken = self._damageTaken + math.abs(healthChange)
		if self._damageTaken > caster:GetMaxHealth() * self.hpConversion then
			if parent:GetHealth() > damage then
				parent:SetHealth( parent:GetHealth() - damage )
			else
				parent:StartGesture(ACT_DOTA_DIE)
				parent:Kill( self:GetAbility(), caster)
			end
		end
	end
	self._lastHP = caster:GetHealth()
end

function modifier_undying_necropolis_undying:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true
			[MODIFIER_STATE_OUT_OF_GAME] = true
			[MODIFIER_STATE_INVULNERABLE] = true}
end

modifier_undying_necropolis_tombstone = class({})
LinkLuaModifier( "modifier_undying_necropolis_tombstone", "heroes/hero_undying/undying_necropolis", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_undying_necropolis_tombstone:OnCreated( )
		self.spawnInterval = self:GetSpecialValueFor("tombstone_spawn_interval")
		self.spawnRadius = self:GetSpecialValueFor("tombstone_spawn_radius")
		
		self.dmgBoss = self:GetSpecialValueFor("zombie_boss_dmg")
		self.dmgMonster = self:GetSpecialValueFor("zombie_boss_dmg")
		self.dmgMinion = self:GetSpecialValueFor("zombie_dmg")
		
		self.enter_tombstone = self:GetSpecialValueFor("enter_tombstone") == 1
		self.pickup_tombstone = self:GetSpecialValueFor("pickup_tombstone") == 1
		
		self.tombstoneZombies = {}
		
		self.talent2Radius = self:GetSpecialValueFor("fog_radius")
		self.talent2 = self.talent2Radius > 0
		
		self:StartIntervalThink( self.spawnInterval )
		self:OnIntervalThink( )
	end
	
	function modifier_undying_necropolis_tombstone:OnIntervalThink()
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
	
	function modifier_undying_necropolis_tombstone:OnDestroy()
		for _, zombie in ipairs( self.tombstoneZombies ) do
			if zombie and not zombie:IsNull() and zombie:IsAlive() then
				zombie:ForceKill( false )
			end
		end
	end
end

function modifier_undying_necropolis_tombstone:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_EVENT_ON_ORDER }
end

function modifier_undying_necropolis_tombstone:OnOrder( params )
	local caster = self:GetCaster()
	if not params.unit:IsSameTeam( caster ) then return end
	if not params.unit:IsRealHero( ) then return end
	if params.order_type ==  DOTA_UNIT_ORDER_MOVE_TO_TARGET
	or params.order_type ==  DOTA_UNIT_ORDER_ATTACK_TARGET then
		if self.enter_tombstone and not hideaway.tombstone then
			local hideaway = params.unit:AddNewModifier( caster, self:GetAbility(), "modifier_undying_necropolis_legion", {duration = self:GetRemainingTime()} )
			hideaway.tombstone = self:GetParent()
			tombstone._hideawayUnit = params.unit
		end
		if params.unit == caster and self.pickup_tombstone then
			self:GetParent():AddNewModifier( caster, self:GetAbility(), "modifier_undying_necropolis_undying", {duration = self:GetRemainingTime()} )
			self:GetParent():SetParent( caster, "attach_hitloc" )
			-- parent:SetLocalOrigin( Vector(75, 40, -140) )
		end
	end
end

function modifier_undying_necropolis_tombstone:GetModifierIncomingDamage_Percentage(params)
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

function modifier_undying_necropolis_tombstone:GetModifierHealAmplify_Percentage( params )
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

function modifier_undying_necropolis_tombstone:IsAura()
	return self.talent2
end

function modifier_undying_necropolis_tombstone:GetModifierAura()
	return "modifier_undying_necropolis_tombstone_talent"
end

function modifier_undying_necropolis_tombstone:GetAuraRadius()
	return self.talent2Radius
end

function modifier_undying_necropolis_tombstone:GetAuraDuration()
	return 0.5
end

function modifier_undying_necropolis_tombstone:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_undying_necropolis_tombstone:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_undying_necropolis_tombstone:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_undying_necropolis_tombstone:GetEffectName()
	if self:GetCaster():HasTalent("special_bonus_unique_undying_necropolis_2") then
		return "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud.vpcf"
	end
end

function modifier_undying_necropolis_tombstone:IsHidden()
	return true
end

function modifier_undying_necropolis_tombstone:IsPurgable()
	return false
end

modifier_undying_necropolis_tombstone_talent = class({})
LinkLuaModifier( "modifier_undying_necropolis_tombstone_talent", "heroes/hero_undying/undying_necropolis", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_necropolis_tombstone_talent:OnCreated()
	self.talent2Slow = self:GetSpecialValueFor( "fog_slow" )
	self.talent2Blind = self:GetSpecialValueFor( "fog_blind" )
end

function modifier_undying_necropolis_tombstone_talent:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_undying_necropolis_tombstone_talent:GetModifierMoveSpeedBonus_Percentage(params)
	return -self.talent2Slow
end

function modifier_undying_necropolis_tombstone_talent:GetModifierMiss_Percentage(params)
	return self.talent2Blind
end

function modifier_undying_necropolis_tombstone_talent:GetEffectName()
	return "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud_debuff.vpcf"
end

modifier_undying_necropolis_zombie = class({})
LinkLuaModifier( "modifier_undying_necropolis_zombie", "heroes/hero_undying/undying_necropolis", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_undying_necropolis_zombie:OnCreated( kv )
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		
		self.unit = EntIndexToHScript( kv.unit )
		
		self.dmgBoss = self:GetSpecialValueFor("zombie_boss_dmg")
		self.dmgOther = self:GetSpecialValueFor("zombie_dmg")
		
		self:StartIntervalThink(0.5)
		self:OnIntervalThink( )
	end
	
	function modifier_undying_necropolis_zombie:OnIntervalThink()
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
	
	function modifier_undying_necropolis_zombie:OnDestroy( kv )
		local decay = self:GetAbility().decay
		
		local chance = self:GetSpecialValueFor("decay_chance")
		local radius = self:GetSpecialValueFor("decay_radius")
		if decay and RollPercentage( chance ) then
			decay:Decay( self:GetParent():GetAbsOrigin(), radius / 100 )
		end
	end
end

function modifier_undying_necropolis_zombie:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_undying_necropolis_zombie:GetModifierIncomingDamage_Percentage(params)
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

function modifier_undying_necropolis_zombie:GetModifierHealAmplify_Percentage( params )
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

function modifier_undying_necropolis_zombie:IsHidden()
	return true
end

function modifier_undying_necropolis_zombie:IsPurgable()
	return false
end