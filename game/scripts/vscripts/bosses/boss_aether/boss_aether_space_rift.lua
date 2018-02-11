boss_aether_space_rift = class({})

function boss_aether_space_rift:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetTalentSpecialValueFor("impact_radius"))
	self.riftFX = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.riftFX, 0, self:GetCursorPosition() + Vector(0,0,128) )
	ParticleManager:SetParticleControl(self.riftFX, 6, self:GetCursorPosition() + Vector(0,0,128) )
	return true
end

function boss_aether_space_rift:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle(self.riftFX)
end

function boss_aether_space_rift:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local damage = self:GetTalentSpecialValueFor("impact_curr_hp_damage") / 100
	local impactRad = self:GetTalentSpecialValueFor("impact_radius")
	local suckRad = self:GetTalentSpecialValueFor("pull_radius")
	local suckDuration = self:GetTalentSpecialValueFor("suck_duration")
	local enemies = caster:FindEnemyUnitsInRadius(target, suckRad)
	EmitSoundOn("Hero_Weaver.TimeLapse", caster)
	for _, enemy in ipairs( enemies ) do
		enemy:AddNewModifier(caster, self, "modifier_boss_aether_space_rift_motion", {duration = suckDuration})
		if CalculateDistance(enemy, caster) <= impactRad then
			self:DealDamage( caster, enemy, damage * enemy:GetHealth() )
		end
	end
	Timers:CreateTimer(suckDuration, function() ParticleManager:ClearParticle(self.riftFX) end)
end

modifier_boss_aether_space_rift_motion = class({})
LinkLuaModifier("modifier_boss_aether_space_rift_motion", "bosses/boss_aether/boss_aether_space_rift", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_aether_space_rift_motion:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetTalentSpecialValueFor("suck_duration") * FrameTime()
		self:StartMotionController()
	end
	
	
	function modifier_boss_aether_space_rift_motion:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		FindClearSpaceForUnit(parent, parentPos, true)
		self:StopMotionController()
	end
	
	function modifier_boss_aether_space_rift_motion:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin() + self.direction * self.speed, parent) 
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
		
	end
end