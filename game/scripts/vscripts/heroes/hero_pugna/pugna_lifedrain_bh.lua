pugna_lifedrain_bh = class({})

function pugna_lifedrain_bh:IsHiddenWhenStolen()
	return false
end

function pugna_lifedrain_bh:GetCooldown()
end

function pugna_lifedrain_bh:GetBehavior()
	local baseFlags = DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	if self.drain and not self.drain:IsNull() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + baseFlags
	else
		if not self:GetCaster():HasTalent("special_bonus_unique_pugna_lifedrain_1") then
			baseFlags = baseFlags + DOTA_ABILITY_BEHAVIOR_CHANNELLED 
		end
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + baseFlags
	end
end

function pugna_lifedrain_bh:GetChannelTime()
	if self:GetCaster():HasTalent("special_bonus_unique_pugna_lifedrain_1") then
		return 0
	else
		return self:GetTalentSpecialValueFor("duration_tooltip")
	end
end

function pugna_lifedrain_bh:GetCooldown(nLevel)
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	if self:GetCaster():HasScepter() then cooldown = self:GetSpecialValueFor("scepter_cooldown") end
	if self:GetCaster():HasTalent("special_bonus_unique_pugna_lifedrain_1") and not self.drain then return 0 end
	return cooldown
end

function pugna_lifedrain_bh:OnSpellStart()
	local caster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	if self.drain and not self.drain:IsNull() then
		self.drain:Destroy()
	else
		hTarget:AddNewModifier(caster, self, "modifier_pugna_life_drain_bh", {duration = self:GetSpecialValueFor("duration_tooltip")})
	end
end

function pugna_lifedrain_bh:OnChannelFinish(bInterrupt)
	if self.drain and not self.drain:IsNull() then
		self.drain:Destroy()
	end
end

modifier_pugna_life_drain_bh = class({})
LinkLuaModifier("modifier_pugna_life_drain_bh", "heroes/hero_pugna/pugna_lifedrain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_pugna_life_drain_bh:OnCreated()
	local ability = self:GetAbility()
	ability.drain = self
	self.drain = self:GetTalentSpecialValueFor("health_drain")
	self.breakBuffer = self:GetTalentSpecialValueFor("break_buffer")
	self.tick = self:GetTalentSpecialValueFor("tick_rate")
	
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_pugna_lifedrain_2")
	if self:GetCaster():IsSameTeam( self:GetParent() ) then self.slow = 0 end
	if IsServer() then
		self:StartIntervalThink( self.tick )
		
		local caster = self:GetCaster()
		caster:AddNewModifier( caster, ability, "modifier_pugna_life_drain_bh_channel", { duration = self:GetRemainingTime() } )
		
		-- particles
		local parent = self:GetParent()
		EmitSoundOn("Hero_Pugna.LifeDrain.Target", parent)
		if not caster:IsSameTeam( parent ) then
			self.beamFX = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain.vpcf", PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(self.beamFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.beamFX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		else
			self.beamFX = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_life_drain_beam_give.vpcf", PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(self.beamFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.beamFX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		end
	end
end

function modifier_pugna_life_drain_bh:OnRefresh()
	local ability = self:GetAbility()
	ability.drain = self
	self.drain = self:GetTalentSpecialValueFor("health_drain")
	self.breakBuffer = self:GetTalentSpecialValueFor("break_buffer")
	self.tick = self:GetTalentSpecialValueFor("tick_rate")
	
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_pugna_lifedrain_2")
	if self:GetCaster():IsSameTeam( self:GetParent() ) then self.slow = 0 end
	if IsServer() then
		self:StartIntervalThink( self.tick )
		
		local caster = self:GetCaster()
		caster:AddNewModifier( caster, ability, "modifier_pugna_life_drain_bh_channel", { duration = self:GetRemainingTime() } )
	end
end

function modifier_pugna_life_drain_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	if CalculateDistance( caster, parent ) >= self.breakBuffer + ability:GetTrueCastRange() then
		self:Destroy()
		caster:RemoveModifierByName("modifier_pugna_life_drain_bh_channel")
		return
	end
	
	if caster:IsSameTeam( parent ) then
		local damage = ability:DealDamage( caster, caster, self.drain * self.tick )
		if parent:GetHealth() < parent:GetMaxHealth() then
			parent:HealEvent( damage, ability, caster )
			ParticleManager:SetParticleControl( self.beamFX, 11, Vector(0,0,0) )
		else
			parent:RestoreMana( damage )
			ParticleManager:SetParticleControl( self.beamFX, 11, Vector(1,0,0) )
		end
	else
		local damage = ability:DealDamage( caster, parent, self.drain * self.tick )
		if caster:GetHealth() < caster:GetMaxHealth() then
			caster:HealEvent( damage, ability, caster )
			ParticleManager:SetParticleControl( self.beamFX, 11, Vector(0,0,0) )
		else
			caster:RestoreMana( damage )
			ParticleManager:SetParticleControl( self.beamFX, 11, Vector(1,0,0) )
		end
	end
end

function modifier_pugna_life_drain_bh:OnDestroy()
	self:GetAbility().drain = nil
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_pugna_life_drain_bh_channel" )
		ParticleManager:ClearParticle( self.beamFX )
		StopSoundOn("Hero_Pugna.LifeDrain.Target", parent)
	end
end

function modifier_pugna_life_drain_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_pugna_life_drain_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pugna_life_drain_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_pugna_life_drain_bh_channel = class({})
LinkLuaModifier("modifier_pugna_life_drain_bh_channel", "heroes/hero_pugna/pugna_lifedrain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_pugna_life_drain_bh_channel:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_pugna_life_drain_bh_channel:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end