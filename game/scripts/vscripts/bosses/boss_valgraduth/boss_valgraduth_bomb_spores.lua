boss_valgraduth_bomb_spores = class({})

function boss_valgraduth_bomb_spores:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("spore_max_distance") )
	return true
end

function boss_valgraduth_bomb_spores:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_boss_valgraduth_bomb_spores", {duration = self:GetSpecialValueFor("spore_duration")} )
end

modifier_boss_valgraduth_bomb_spores = class({})
LinkLuaModifier("modifier_boss_valgraduth_bomb_spores", "bosses/boss_valgraduth/boss_valgraduth_bomb_spores", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_valgraduth_bomb_spores:OnCreated()
		self.spores_per_sec = self:GetSpecialValueFor("spores_per_second")
		self.spore_speed = self:GetSpecialValueFor("spore_speed")
		self.spore_max_distance = self:GetSpecialValueFor("spore_max_distance")
		self.spore_min_distance = self:GetSpecialValueFor("spore_min_distance")
		self.linger_duration = self:GetSpecialValueFor("linger_duration")
		self:StartIntervalThink( 1 / self.spores_per_sec )
	end

	function modifier_boss_valgraduth_bomb_spores:OnRefresh()
		self:OnCreated()
	end
	
	function modifier_boss_valgraduth_bomb_spores:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:IsStunned() or caster:IsSilenced() then return end
		caster:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_4, 2 )
		local spawn = CreateUnitByName( "npc_dota_techies_land_mine", caster:GetAbsOrigin() + RandomVector( 15 ), true, nil, nil, caster:GetTeamNumber() )
		local distance = RandomInt( self.spore_min_distance, self.spore_max_distance )
		local duration = distance / self.spore_speed
		spawn:ApplyKnockBack(caster:GetAbsOrigin(), duration, duration, distance, 600, caster, self, false)
		spawn:AddNewModifier( caster, self:GetAbility(), "modifier_boss_valgraduth_bomb_spores_bomb", {duration = self.linger_duration})
	end
end

function modifier_boss_valgraduth_bomb_spores:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_ROOTED] = true,}
end

modifier_boss_valgraduth_bomb_spores_bomb = class({})
LinkLuaModifier("modifier_boss_valgraduth_bomb_spores_bomb", "bosses/boss_valgraduth/boss_valgraduth_bomb_spores", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_valgraduth_bomb_spores_bomb:OnCreated()
		self.trigger_radius = self:GetSpecialValueFor("trigger_radius")
		self.explosion_radius = self:GetSpecialValueFor("explosion_radius")
		self.damage = self:GetSpecialValueFor("damage")
		self:StartIntervalThink(0.1)
	end
	
	function modifier_boss_valgraduth_bomb_spores_bomb:OnIntervalThink()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local position = parent:GetAbsOrigin()
		local foundInTriggerRange = false
		if not caster or not ability or caster:IsNull() or ability:IsNull() then
			self:Destroy()
			return
		end
		if parent:HasModifier("modifier_knockback") then
			return
		end
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( position, self.trigger_radius ) ) do
			if CalculateDistance(parent, enemy, true) <= self.trigger_radius then
				foundInTriggerRange = true
				break
			end
		end
		if foundInTriggerRange then
			for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( position, self.explosion_radius ) ) do
				if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
					ability:DealDamage( caster, enemy, self.damage )
				end
			end
			EmitSoundOn( "Hero_Techies.LandMine.Detonate", parent )
			ParticleManager:FireParticle( "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_ABSORIGIN, parent )
			self:Destroy()
		end
	end
	
	function modifier_boss_valgraduth_bomb_spores_bomb:OnDestroy()
		self:GetParent():ForceKill(false)
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_boss_valgraduth_bomb_spores_bomb:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true}
end

function modifier_boss_valgraduth_bomb_spores_bomb:IsHidden()
	return true
end