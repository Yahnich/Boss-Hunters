viper_viper_strike_bh = class({})

function viper_viper_strike_bh:GetCastRange( target, position )
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("cast_range_scepter")
	else
		return self.BaseClass.GetCastRange( self, target, position )
	end
end

function viper_viper_strike_bh:GetCooldown( iLvl )
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("cooldown_scepter")
	else
		return self.BaseClass.GetCooldown( self, iLvl )
	end
end

function viper_viper_strike_bh:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_viper_viper_strike_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function viper_viper_strike_bh:CastFilterResultTarget( target )
	local caster = self:GetCaster()
	local teamTarget = DOTA_UNIT_TARGET_TEAM_ENEMY
	if caster:HasTalent("special_bonus_unique_viper_viper_strike_2") then
		teamTarget = DOTA_UNIT_TARGET_TEAM_BOTH
	end
	return UnitFilter( target, teamTarget, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber() )
end

function viper_viper_strike_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	-- warmup
	self.warmUp = ParticleManager:CreateParticle( "particles/units/heroes/hero_viper/viper_viper_strike_warmup.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControlEnt( self.warmUp, 1, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_1", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.warmUp, 2, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_2", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.warmUp, 3, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_3", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.warmUp, 4, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_4", caster:GetAbsOrigin(), true )
	return true
end

function viper_viper_strike_bh:OnAbilityPhaseInterrupted()
	if self.warmUp then
		ParticleManager:DestroyParticle( self.warmUp, false )
		ParticleManager:ReleaseParticleIndex( self.warmUp )
	end
end

function viper_viper_strike_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	
	if self.warmUp then
		ParticleManager:DestroyParticle( self.warmUp, false )
		ParticleManager:ReleaseParticleIndex( self.warmUp )
	end
	if caster:HasTalent("special_bonus_unique_viper_viper_strike_1") then
		caster:AddNewModifier( caster, self, "modifier_viper_viper_strike_bh_talent", {duration = self:GetTalentSpecialValueFor("duration")})
	else
		self:FireViperStrike( target )
	end
	caster:EmitSound( "hero_viper.viperStrike" )
end

function viper_viper_strike_bh:FireViperStrike( target )
	local caster = self:GetCaster()
	local barbs = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_viper_strike_beam.vpcf", PATTACH_CUSTOMORIGIN, caster)
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	ParticleManager:SetParticleControlEnt(barbs, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 2, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 3, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 4, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_3", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 5, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_4", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl( barbs, 6, Vector( speed, 0, 0 ) )
	
	self:FireTrackingProjectile("particles/units/heroes/hero_viper/viper_viper_strike.vpcf", target, speed, {extraData = {["particle"] = barbs}})
end

function viper_viper_strike_bh:OnProjectileHit_ExtraData( target, position, extraData )
	if target and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("damage")
		if target:IsSameTeam( caster) then
			target:HealEvent( damage, self, caster )
		else
			self:DealDamage( caster, target, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
		end
		target:EmitSound("hero_viper.viperStrikeImpact")
		target:AddNewModifier( caster, self, "modifier_viper_viper_strike_bh", { duration = self:GetTalentSpecialValueFor("duration") } )
	end
	ParticleManager:ClearParticle( tonumber( extraData.particle ) )
end

modifier_viper_viper_strike_bh_talent = class({})
LinkLuaModifier("modifier_viper_viper_strike_bh_talent", "heroes/hero_viper/viper_viper_strike_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_viper_strike_bh_talent:OnCreated()
	self.tick = self:GetCaster():FindTalentValue("special_bonus_unique_viper_viper_strike_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_viper_viper_strike_2")
	self.triggerUnits = {}
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(self.tick)
	end
end

function modifier_viper_viper_strike_bh_talent:OnRefresh()
	self:OnCreated()
end

function modifier_viper_viper_strike_bh_talent:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local radius = ability:GetTrueCastRange()
	if self.talent2 then
		for _, unit in ipairs( caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
			if not self.triggerUnits[unit] and not unit:HasModifier("modifier_viper_viper_strike_bh") then
				self.triggerUnits[unit] = true
				ability:FireViperStrike( unit )
				break
			end
		end
	else
		for _, unit in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
			if not self.triggerUnits[unit] and not unit:HasModifier("modifier_viper_viper_strike_bh") then
				self.triggerUnits[unit] = true
				ability:FireViperStrike( unit )
				break
			end
		end
	end
end

modifier_viper_viper_strike_bh = class({})
LinkLuaModifier("modifier_viper_viper_strike_bh", "heroes/hero_viper/viper_viper_strike_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_viper_strike_bh:OnCreated()
	self:OnRefresh()
end

function modifier_viper_viper_strike_bh:OnRefresh()
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.evasion = self:GetTalentSpecialValueFor("evasion_loss")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.cdr = self:GetTalentSpecialValueFor("cdr_loss")
	self.dmg = self:GetTalentSpecialValueFor("damage")
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		self.as = self.as * (-1)
		self.evasion = self.evasion * (-1)
		self.ms = self.ms * (-1)
		self.cdr = self.cdr * (-1)
	end
	self.asDegrade = self.as / self:GetDuration()
	self.msDegrade = self.ms / self:GetDuration()
	self.evasionDegrade = self.evasion / self:GetDuration()
	self.cdrDegrade = self.cdr / self:GetDuration()
	self.tick = self:GetDuration() / self:GetTalentSpecialValueFor("duration") * 1
	self.internal = 0
	self:StartIntervalThink( 0 )
end

function modifier_viper_viper_strike_bh:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if parent:IsSameTeam( caster ) then
		self.as = math.max( 0, self.as - self.asDegrade * FrameTime() )
		self.ms = math.max( 0, self.ms - self.msDegrade * FrameTime() )
		self.evasion = math.max( 0, self.evasion - self.evasionDegrade * FrameTime() )
		self.cdr = math.max( 0, self.cdr - self.evasionDegrade * FrameTime() )
	else
		self.as = math.min( 0, self.as - self.asDegrade * FrameTime() )
		self.ms = math.min( 0, self.ms - self.msDegrade * FrameTime() )
		self.evasion = math.min( 0, self.evasion - self.evasionDegrade * FrameTime() )
		self.cdr = math.min( 0, self.cdr - self.evasionDegrade * FrameTime() )
	end
	self.internal = self.internal + FrameTime()
	if IsServer() then
		if self.cdr ~= 0 then
			for i = 0, parent:GetAbilityCount() - 1 do
				local ability = parent:GetAbilityByIndex( i )
				if ability and not ability:IsCooldownReady() then
					ability:ModifyCooldown( -(1 + self.cdr/100) * FrameTime() )
				end
			end
		end
		if self.internal >= self.tick then
			self.internal = 0
			if self:GetParent():IsSameTeam( self:GetCaster() ) then
				parent:HealEvent( self.dmg * 1, self:GetAbility(), caster )
			else
				self:GetAbility():DealDamage( caster, parent, self.dmg * 1, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
			end
		end
	end
end

function modifier_viper_viper_strike_bh:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_ONGOING }
end

function modifier_viper_viper_strike_bh:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_viper_viper_strike_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_viper_viper_strike_bh:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_viper_viper_strike_bh:GetModifierPercentageCooldownOngoing()
	return self.cdr
end

function modifier_viper_viper_strike_bh:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf"
end

function modifier_viper_viper_strike_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_viper.vpcf"
end

function modifier_viper_viper_strike_bh:StatusEffectPriority()
	return 10
end