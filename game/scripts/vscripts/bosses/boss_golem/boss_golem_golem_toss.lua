boss_golem_golem_toss = class({})

function boss_golem_golem_toss:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("base_radius") * self:GetCaster():GetModelScale() * 0.35 )
	return true
end

function boss_golem_golem_toss:OnSpellStart()
	local caster = self:GetCaster()
	
	golem = CreateUnitByName("npc_dota_boss12_golem", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
	golem:AddNewModifier( caster, self, "modifier_boss_golem_golem_toss_movement", {})
	EmitSoundOn("Ability.TossThrow", golem)
	local hp = caster:GetMaxHealth()
	local golemHP = math.max(10, hp * self:GetSpecialValueFor("max_health_cost") / 100)
	
	local scale = caster:GetModelScale()
	local golemScale = caster:GetModelScale() * 0.6
	
	golem:SetModelScale( math.max(golemScale, self:GetSpecialValueFor("minimum_scale") ) )
	golem:SetBaseMoveSpeed( math.min( 300, golem:GetBaseMoveSpeed() / scale ) )
	golem:SetAverageBaseDamage( caster:GetAverageBaseDamage() * 0.8, 25 )
	golem.unitIsRoundBoss = true
	golem:SetCoreHealth( math.max(1, golemHP) )
	if golem:GetModelScale() < self:GetSpecialValueFor("minimum_scale") then
		golem:FindAbilityByName("boss_golem_golem_toss"):SetActivated(false)
	else
		golem:FindAbilityByName("boss_golem_golem_toss"):SetCooldown()
	end
	
	if caster:GetModelScale() < self:GetSpecialValueFor("minimum_scale") then
		golem:FindAbilityByName("boss_golem_golem_toss"):SetActivated(false)
	end
	golem:FindAbilityByName("boss_golem_split"):SetActivated(false)
	golem:FindAbilityByName("boss_golem_cracked_mass"):SetActivated(false)
	
	golem.unitIsRoundBoss = true
	golem.hasBeenInitialized = true
	
	caster:SetModelScale( math.max( scale * 0.9, self:GetSpecialValueFor("minimum_scale") ) )
	caster:SetBaseMaxHealth( math.max(1, hp - golemHP) )
	caster:SetMaxHealth( math.max(1, hp - golemHP) )
	caster:SetBaseMoveSpeed( caster:GetBaseMoveSpeed() / scale )
	caster:SetAverageBaseDamage( caster:GetAverageBaseDamage() * 0.9, 25 )
end



modifier_boss_golem_golem_toss_movement = class({})
LinkLuaModifier("modifier_boss_golem_golem_toss_movement", "bosses/boss_golem/boss_golem_golem_toss", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_golem_golem_toss_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetSpecialValueFor("toss_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 650
		self:StartMotionController()
	end
	
	
	function modifier_boss_golem_golem_toss_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()

		FindClearSpaceForUnit(parent, parentPos, true)
		if parent:IsFrozen() then return end
		local ability = self:GetAbility()
		local damage = self:GetSpecialValueFor("base_damage") * parent:GetModelScale()
		local radius = self:GetSpecialValueFor("base_radius") * parent:GetModelScale()
		
		ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, parent, {[1] = Vector(radius, 1, 1)})
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parentPos, radius ) ) do
			ability:DealDamage(parent, enemy, damage)
		end
		EmitSoundOn("Ability.TossImpact", parent)
		self:StopMotionController()
		ResolveNPCPositions( self:GetParent():GetAbsOrigin(), 500 ) 
	end
	
	function modifier_boss_golem_golem_toss_movement:DoControlledMotion()
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

function modifier_boss_golem_golem_toss_movement:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_boss_golem_golem_toss_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_golem_golem_toss_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_boss_golem_golem_toss_movement:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end