boss_golem_golem_leap = class({})

function boss_golem_golem_leap:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("base_radius") * self:GetCaster():GetModelScale() )
	return true
end

function boss_golem_golem_leap:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Ability.TossThrow", caster)
	caster:AddNewModifier( caster, self, "modifier_boss_golem_golem_leap_movement", {})
end



modifier_boss_golem_golem_leap_movement = class({})
LinkLuaModifier("modifier_boss_golem_golem_leap_movement", "bosses/boss_golem/boss_golem_golem_leap", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_golem_golem_leap_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetSpecialValueFor("leap_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 650
		self:StartMotionController()
	end
	
	
	function modifier_boss_golem_golem_leap_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()

		FindClearSpaceForUnit(parent, parentPos, true)
		if parent:IsFrozen() then return end
		local ability = self:GetAbility()
		local damage = math.max( 100, self:GetSpecialValueFor("base_damage") + self:GetSpecialValueFor("base_damage") * (parent:GetModelScale() - 1) * 0.5 )
		local radius = math.max( 175, self:GetSpecialValueFor("base_radius") * parent:GetModelScale() )
		
		ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, parent, {[1] = Vector(radius, 1, 1)})
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parentPos, radius ) ) do
			if not enemy:TriggerSpellAbsorb(self) then
				ability:DealDamage(parent, enemy, damage)
			end
		end
		EmitSoundOn("Ability.TossImpact", parent)
		self:StopMotionController()
		ResolveNPCPositions( self:GetParent():GetAbsOrigin(), 500 ) 
	end
	
	function modifier_boss_golem_golem_leap_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance and not parent:IsFrozen() then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
		
	end
end

function modifier_boss_golem_golem_leap_movement:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_boss_golem_golem_leap_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_golem_golem_leap_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_boss_golem_golem_leap_movement:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end