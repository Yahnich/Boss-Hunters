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

function viper_viper_strike_bh:GetManaCost( iLvl )
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("mana_cost_scepter")
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
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

	local barbs = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_viper_strike_beam.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(barbs, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 2, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 3, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 4, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_3", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(barbs, 5, caster, PATTACH_POINT_FOLLOW, "attach_wing_barb_4", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl( barbs, 6, Vector( speed, 0, 0 ) )
	
	self:FireTrackingProjectile("particles/units/heroes/hero_viper/viper_viper_strike.vpcf", target, speed, {extraData = {["particle"] = barbs}})
	
	caster:EmitSound( "hero_viper.viperStrike" )
end

function viper_viper_strike_bh:OnProjectileHit_ExtraData( target, position, extraData )
	if target then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("damage")
		if caster:HasTalent("special_bonus_unique_viper_viper_strike_1") then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_viper_viper_strike_1") ) ) do
				self:DealDamage( caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
			end
		else
			self:DealDamage( caster, target, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
		end
		target:EmitSound("hero_viper.viperStrikeImpact")
		target:AddNewModifier( caster, self, "modifier_viper_viper_strike_bh", { duration = self:GetTalentSpecialValueFor("duration") } )
		ParticleManager:ClearParticle( tonumber( extraData.particle ) )
	end
end

modifier_viper_viper_strike_bh = class({})
LinkLuaModifier("modifier_viper_viper_strike_bh", "heroes/hero_viper/viper_viper_strike_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_viper_strike_bh:OnCreated()
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.dmg = self:GetTalentSpecialValueFor("damage")
	self.asDegrade = self.as / self:GetRemainingTime()
	self.msDegrade = self.ms / self:GetRemainingTime()
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_viper_viper_strike_1")
	self.talentRadius = self:GetCaster():FindTalentValue("special_bonus_unique_viper_viper_strike_1")
	self.tick = self:GetDuration() / self:GetTalentSpecialValueFor("duration") * 1
	self.internal = 0
	self:StartIntervalThink( 0 )
end

function modifier_viper_viper_strike_bh:OnRefresh()
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.dmg = self:GetTalentSpecialValueFor("damage")
	self.asDegrade = self.as / self:GetRemainingTime()
	self.msDegrade = self.ms / self:GetRemainingTime()
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_viper_viper_strike_1")
	self.talentRadius = self:GetCaster():FindTalentValue("special_bonus_unique_viper_viper_strike_1")
	self.tick = self:GetDuration() / self:GetTalentSpecialValueFor("duration") * 1
	self.internal = 0
	self:StartIntervalThink( 0 )
end

function modifier_viper_viper_strike_bh:OnIntervalThink()
	self.as = self.as - self.asDegrade * FrameTime()
	self.ms = self.ms - self.msDegrade * FrameTime()
	
	self.internal = self.internal + FrameTime()
	if IsServer() and self.internal >= self.tick then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.internal = 0
		self:GetAbility():DealDamage( caster, parent, self.dmg * 1, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
		if self.talent then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.talentRadius ) ) do
				self:GetAbility():DealDamage( caster, enemy, self.dmg * 1, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
			end
		end
	end
end

function modifier_viper_viper_strike_bh:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_viper_viper_strike_bh:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_viper_viper_strike_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_viper_viper_strike_bh:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf"
end