boss_axe_feral_leap = class({})

function boss_axe_feral_leap:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:EmitSound( "Hero_Axe.BerserkersCall.Start" )
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor( "radius" ) )
	return true
end

function boss_axe_feral_leap:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier( caster, self, "modifier_boss_axe_feral_leap", {duration = duration} )
end

modifier_boss_axe_feral_leap = class({})
LinkLuaModifier("modifier_boss_axe_feral_leap", "bosses/boss14/boss_axe_feral_leap", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_axe_feral_leap:OnCreated(kv)
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		
		self.speed = ( self.distance / kv.duration ) * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 650
		self:StartMotionController()
	end
	
	
	function modifier_boss_axe_feral_leap:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetSpecialValueFor("radius")
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local damage = self:GetSpecialValueFor("damage")
		local radius = self:GetSpecialValueFor("radius")
		local threat = self:GetSpecialValueFor("threat")
		-- effect
		parent:EmitSound( "Hero_Axe.Berserkers_Call" )
		parent:EmitSound( "Hero_Axe.CounterHelix" )
		parent:StartGesture( ACT_DOTA_CAST_ABILITY_3 )
		local enemies = parent:FindEnemyUnitsInRadius( parentPos, radius )
		for _, enemy in ipairs( enemies ) do
			ability:DealDamage( parent, enemy, damage )
		end
		for _, enemy in ipairs( enemies ) do
			enemy:ModifyThreat( threat, true )
		end
		self:StopMotionController()
	end
	
	function modifier_boss_axe_feral_leap:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
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

function modifier_boss_axe_feral_leap:GetEffectName()
	return "particles/units/heroes/hero_earthshaker/earthshaker_crater_impact_blur.vpcf"
end

function modifier_boss_axe_feral_leap:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_axe_feral_leap:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_boss_axe_feral_leap:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end