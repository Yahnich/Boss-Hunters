zeus_heavenly_jump = class({})

-- function zeus_heavenly_jump:GetCooldown(iLvl)
	-- return self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_zeus_heavenly_jump_1")
-- end

function zeus_heavenly_jump:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)
	
	caster:AddNewModifier( caster, self, "modifier_zeus_heavenly_jump_movement", {duration = self:GetSpecialValueFor("jump_duration"), ignoreStatusAmp = true} )
	ParticleManager:FireParticle("particles/units/heroes/hero_zuus/zuus_shard_head.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin(), [1] = "attach_hitloc", [2] = caster:GetAbsOrigin() })
	EmitSoundOn("Hero_Zuus.Taunt.Jump", caster)
	EmitSoundOn("Hero_Zuus.GodsWrath.PreCast", caster)
end

modifier_zeus_heavenly_jump_movement = class({})
LinkLuaModifier("modifier_zeus_heavenly_jump_movement", "heroes/hero_zeus/zeus_heavenly_jump", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function modifier_zeus_heavenly_jump_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = TernaryOperator( self:GetSpecialValueFor("jump_distance"), parent:IsMoving(), 0 )
		self.direction = parent:GetForwardVector()
		self.travel_duration = self:GetRemainingTime()
		self.speed = self.distance / self:GetRemainingTime() * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 250
		
		self.radius = self:GetSpecialValueFor("shock_distance")
		self.damage = self:GetSpecialValueFor("shock_damage")
		self.duration = self:GetSpecialValueFor("shock_duration")
		
		
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local bonusTargets = {}
		
		self.talent1 = caster:HasTalent("special_bonus_unique_zeus_heavenly_jump_1")
		self.talent1Dur = caster:FindTalentValue("special_bonus_unique_zeus_heavenly_jump_1", "duration")
		self.talent2 = caster:HasTalent("special_bonus_unique_zeus_heavenly_jump_2")
		self.talent2Radius = caster:FindTalentValue("special_bonus_unique_zeus_heavenly_jump_2")
		
		if self.talent1 then
			caster:AddNewModifier( caster, ability, "modifier_zeus_heavenly_jump_talent", {duration = self.talent1Dur} )
		end
		
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
			bonusTargets[enemy] = true
		end
		for _, cloud in ipairs( caster._NimbusClouds or {} ) do
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( cloud:GetAbsOrigin(), cloud.radius ) ) do
				bonusTargets[enemy] = true
			end
		end
		for enemy, state in pairs( bonusTargets ) do
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_POINT_FOLLOW, caster, enemy, {})
			ability:DealDamage(caster, enemy, self.damage, {}, 0)
			enemy:Paralyze( ability, caster, self.duration )
		end
		parent:StartGesture( ACT_DOTA_CAST_ABILITY_3 )
		self:StartMotionController()
	end
	
	
	function modifier_zeus_heavenly_jump_movement:OnDestroy()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local parentPos = parent:GetAbsOrigin()
		ResolveNPCPositions(parentPos, parent:GetHullRadius() + parent:GetCollisionPadding())
		self:StopMotionController()
		
		if self.talent2 then
			local thunderbolt = parent:FindAbilityByName("zeus_thunder_bolt")
			if thunderbolt then
				bonusTargets = {}
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parentPos, self.talent2Radius ) ) do
					bonusTargets[enemy] = true
				end
				
				for _, cloud in ipairs( caster._NimbusClouds or {} ) do
					for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( cloud:GetAbsOrigin(), cloud.radius ) ) do
						bonusTargets[enemy] = true
					end
				end
				for enemy, state in pairs( bonusTargets ) do
					thunderbolt:ApplyThunderBolt( enemy )
				end
			end
		end
	end
	
	function modifier_zeus_heavenly_jump_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		
		if parent:IsAlive() then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( ( self:GetElapsedTime()/self.travel_duration ) * math.pi )
			parent:SetAbsOrigin( newPos )
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			parent:SetAbsOrigin( GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed )
			self:Destroy()
			return
		end
	end
end

function modifier_zeus_heavenly_jump_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_zeus_heavenly_jump_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
end

function modifier_zeus_heavenly_jump_movement:GetActivityTranslationModifiers()
	return "jump_gesture"
end

function modifier_zeus_heavenly_jump_movement:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end

function modifier_zeus_heavenly_jump_movement:IsHidden()
	return true
end

modifier_zeus_heavenly_jump_talent = class({})
LinkLuaModifier("modifier_zeus_heavenly_jump_talent", "heroes/hero_zeus/zeus_heavenly_jump", LUA_MODIFIER_MOTION_NONE)

function modifier_zeus_heavenly_jump_talent:OnCreated()
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_zeus_heavenly_jump_1")
end

function modifier_zeus_heavenly_jump_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_zeus_heavenly_jump_talent:CheckState()
	return {[MODIFIER_STATE_FLYING] = true}
end

function modifier_zeus_heavenly_jump_talent:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_zeus_heavenly_jump_talent:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"
end