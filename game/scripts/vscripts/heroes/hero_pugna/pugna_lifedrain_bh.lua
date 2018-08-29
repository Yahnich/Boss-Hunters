pugna_lifedrain_bh = class({})

function pugna_lifedrain_bh:IsHiddenWhenStolen()
	return false
end

function pugna_lifedrain_bh:GetCooldown()
end

function pugna_lifedrain_bh:GetBehavior()
	local baseFlags = DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	if self.drain then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + baseFlags
	else
		if not self:GetCaster():HasTalent("special_bonus_unique_pugna_lifedrain_1") then
			baseFlags = baseFlags + DOTA_ABILITY_BEHAVIOR_CHANNELED
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
	EmitSoundOn("Hero_Pugna.LifeDrain.Target", hTarget)
	
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
	
	self.slow = self:GetCaster:FindTalentValue("special_bonus_unique_pugna_lifedrain_2")
	if IsServer() then
		ability:SetActivated(false)
		self:StartIntervalThink( self.tick )
		
		local caster = self:GetCaster()
		caster:AddNewModifier( caster, ability, "modifier_pugna_life_drain_bh_channel", { duration = self:GetRemainingTime() } )
		
		-- particles
		if caster:IsSameTeam( parent ) then
		else
		end
	end
end

function modifier_pugna_life_drain_bh:OnRefresh()
	local ability = self:GetAbility()
	ability.drain = self
	self.drain = self:GetTalentSpecialValueFor("health_drain")
	self.breakBuffer = self:GetTalentSpecialValueFor("break_buffer")
	self.tick = self:GetTalentSpecialValueFor("tick_rate")
	
	self.slow = self:GetCaster:FindTalentValue("special_bonus_unique_pugna_lifedrain_2")
	if IsServer() then
		ability:SetActivated(false)
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
		parent:HealEvent( damage, ability, caster )
	else
		local damage = ability:DealDamage( caster, parent, self.drain * self.tick )
		caster:HealEvent( damage, ability, caster )
	end
end

function modifier_pugna_life_drain_bh:OnDestroy()
	self:GetAbility().drain = nil
	if IsServer() then
		self:GetAbility():SetActivated(true)
		ParticleManager:ClearParticle( self.linkFX )
	end
end

function modifier_pugna_life_drain_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_pugna_life_drain_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

modifier_pugna_life_drain_bh_channel = class({})
LinkLuaModifier("modifier_pugna_life_drain_bh_channel", "heroes/hero_pugna/pugna_lifedrain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_pugna_life_drain_bh_channel:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_pugna_life_drain_bh_channel:GetOverrideAnimation()
	return ACT_THE_SUCK
end