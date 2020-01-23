boss_slark_leap = class({})


function boss_slark_leap:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)
	
	caster:AddNewModifier( caster, self, "modifier_boss_slark_leap_movement", {duration = self:GetSpecialValueFor("pounce_distance") / self:GetSpecialValueFor("pounce_speed") + 0.1} )
	ParticleManager:FireParticle("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", PATTACH_ABSORIGIN, caster)
	EmitSoundOn("Hero_Slark.Pounce.Cast", caster)
end


modifier_boss_slark_leap_movement = class({})
LinkLuaModifier("modifier_boss_slark_leap_movement", "bosses/boss_slarks/boss_slark_leap", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_slark_leap_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = self:GetSpecialValueFor("pounce_distance")
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self:GetSpecialValueFor("pounce_speed") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 125
		
		self.radius = self:GetSpecialValueFor("pounce_radius")
		self.damage = self:GetSpecialValueFor("pounce_damage")
		self.duration = self:GetSpecialValueFor("leash_duration")
		
		self.enemiesHit = {}
		parent:StartGesture( ACT_DOTA_SLARK_POUNCE )
		self:StartMotionController()
	end
	
	
	function modifier_boss_slark_leap_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		ResolveNPCPositions(parentPos, parent:GetHullRadius() + parent:GetCollisionPadding())
		self:StopMotionController()
	end
	
	function modifier_boss_slark_leap_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			parent:SetAbsOrigin( GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed )
			self:Destroy()
			return
		end       
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			if not self.enemiesHit[enemy:entindex()] then
				self:Pounce(enemy)
				self.enemiesHit[enemy:entindex()] = true
				self:Destroy()
			end
		end
	end
	
	function modifier_boss_slark_leap_movement:Pounce(target)
		local caster = self:GetParent()
		local ability = self:GetAbility()
		if target:TriggerSpellAbsorb( ability ) then return end
		ability:DealDamage(caster, target, self.damage)
		target:AddNewModifier(caster, ability, "modifier_boss_slark_leap_tether", {duration = self.duration} )
		EmitSoundOn("Hero_Slark.Pounce.Impact", target)
	end
end

function modifier_boss_slark_leap_movement:GetEffectName()
	return "particles/units/heroes/hero_slark/slark_pounce_trail.vpcf"
end

function modifier_boss_slark_leap_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_slark_leap_movement:IsHidden()
	return true
end