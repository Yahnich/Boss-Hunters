enigma_black_hole_bh = class({})

function enigma_black_hole_bh:GetChannelTime()
	return self:GetTalentSpecialValueFor("channel_time")
end

function enigma_black_hole_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function enigma_black_hole_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	if self.thinker then UTIL_Remove( self.thinker ) end
	self.thinker = CreateModifierThinker(caster, self, "modifier_enigma_black_hole_bh_thinker", {Duration = self:GetTalentSpecialValueFor("channel_time")}, target, caster:GetTeam(), false)
end

function enigma_black_hole_bh:OnChannelFinish(bInterrupt)
	if self.thinker and not self.thinker:IsNull() then self.thinker:FindModifierByName("modifier_enigma_black_hole_bh_thinker"):Destroy() end
end

modifier_enigma_black_hole_bh_thinker = class({})
LinkLuaModifier("modifier_enigma_black_hole_bh_thinker", "heroes/hero_enigma/enigma_black_hole_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_enigma_black_hole_bh_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	if IsServer() then
		local bhFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_enigma/enigma_blackhole.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl(bhFX, 15, Vector( self.radius, 1, 1) )
		self:GetParent():EmitSound("Hero_Enigma.Black_Hole")
		self:AddEffect(bhFX)
	end
end

function modifier_enigma_black_hole_bh_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Enigma.Black_Hole")
		self:GetParent():EmitSound("Hero_Enigma.Black_Hole.Stop")
		UTIL_Remove( self:GetParent() )
		for _, enemy in ipairs( self:GetCaster():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
			enemy:RemoveModifierByName("modifier_enigma_black_hole_bh_aura")
		end
	end
end

function modifier_enigma_black_hole_bh_thinker:IsAura()
	return true
end

function modifier_enigma_black_hole_bh_thinker:GetModifierAura()
	return "modifier_enigma_black_hole_bh_aura"
end

function modifier_enigma_black_hole_bh_thinker:GetAuraRadius()
	return self.radius
end

function modifier_enigma_black_hole_bh_thinker:GetAuraDuration()
	return 0.5
end

function modifier_enigma_black_hole_bh_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_enigma_black_hole_bh_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_enigma_black_hole_bh_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_enigma_black_hole_bh_aura = class({})
LinkLuaModifier("modifier_enigma_black_hole_bh_aura", "heroes/hero_enigma/enigma_black_hole_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_enigma_black_hole_bh_aura:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.pull_speed = self:GetTalentSpecialValueFor("pull_speed")
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.tick = self:GetTalentSpecialValueFor("tick_rate")
	self.animation = self:GetTalentSpecialValueFor("animation_rate")
	if IsServer() then
		self.centerPos = self:GetAbility():GetCursorPosition()
		self:StartIntervalThink( self.tick )
		self:StartMotionController()
	end
end

function modifier_enigma_black_hole_bh_aura:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage * self.tick )
end

function modifier_enigma_black_hole_bh_aura:DoControlledMotion()
	if self:GetParent():IsNull() then return end
	local parent = self:GetParent()
	if parent:IsAlive() then
		local pullDirection = CalculateDirection( self.centerPos, self:GetParent() )
		local rotateDirection = GetPerpendicularVector( pullDirection )
		
		local distance = CalculateDistance( self.centerPos, self:GetParent() )
		local pullSpeed = self.pull_speed * ( distance / self.radius ) * FrameTime()
		local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + pullDirection * pullSpeed + rotateDirection * pullSpeed
		parent:SetAbsOrigin( newPos )
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:Destroy()
		return nil
	end       
end

function modifier_enigma_black_hole_bh_aura:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_enigma_black_hole_bh_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE}
end

function modifier_enigma_black_hole_bh_aura:GetOverrideAnimationRate()
	return self.animation
end

function modifier_enigma_black_hole_bh_aura:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_enigma_black_hole_bh_aura:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_enigma_black_hole_bh_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_enigma_blackhole_tgt.vpcf"
end

function modifier_enigma_black_hole_bh_aura:StatusEffectPriority()
	return 25
end