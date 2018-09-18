boss_greymane_pounce = class({})

function boss_greymane_pounce:OnAbilityPhaseStart()
	local origPos = self:GetCaster():GetAbsOrigin()
	ParticleManager:FireLinearWarningParticle( origPos, self:GetCursorPosition(), 120 )
	return true
end

function boss_greymane_pounce:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Ability.Leap", caster)
	caster:StartGesture(ACT_DOTA_SPAWN)
	caster:AddNewModifier( caster, self, "modifier_boss_greymane_pounce", {duration = self:GetSpecialValueFor("jump_duration")} )
end

function boss_greymane_pounce:OnChannelFinish()
	if self.capturedTarget then
		self.capturedTarget:RemoveModifierByName("modifier_boss_greymane_pounce_stun")
	end
end

modifier_boss_greymane_pounce = class({})
LinkLuaModifier("modifier_boss_greymane_pounce", "bosses/boss_greymane/boss_greymane_pounce", LUA_MODIFIER_MOTION_NONE)


if IsServer() then
	function modifier_boss_greymane_pounce:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetSpecialValueFor("jump_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 125
		
		self.radius = 120
		self:StartMotionController()
	end
	
	
	function modifier_boss_greymane_pounce:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		ResolveNPCPositions(parentPos, parent:GetHullRadius() + parent:GetCollisionPadding())
		self:StopMotionController()
	end
	
	function modifier_boss_greymane_pounce:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			parent:SetAbsOrigin( self.endPos )
			parent:Interrupt()
			self:Destroy()
			return
		end
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			local remainingTime = math.min( ability:GetChannelTime(), ability:GetChannelTime() - (ability:GetChannelStartTime() - GameRules:GetGameTime()) )
			enemy:AddNewModifier(caster, ability, "modifier_boss_greymane_pounce_stun", {duration = remainingTime})
			ability.capturedTarget = enemy
			EmitSoundOn("Hero_Slark.Pounce.Impact", enemy)
			self:Destroy()
			break
		end
	end
end

function modifier_boss_greymane_pounce:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_greymane_pounce:IsHidden()
	return true
end

modifier_boss_greymane_pounce_stun = class({})
LinkLuaModifier("modifier_boss_greymane_pounce_stun", "bosses/boss_greymane/boss_greymane_pounce", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_greymane_pounce_stun:OnCreated()
	self.damage = self:GetSpecialValueFor("damage_per_second")
	if IsServer() then self:StartIntervalThink( self:GetSpecialValueFor("damage_interval") ) end
end

function modifier_boss_greymane_pounce_stun:OnIntervalThink()
	local caster = self:GetCaster()
	if not caster:IsAlive() or not caster:IsChanneling() then self:Destroy() end
	local ability = self:GetAbility()
	local parent = self:GetParent()
	ParticleManager:FireParticle("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_POINT_FOLLOW, parent)
	parent:EmitSound("Hero_Riki.Backstab")
	ability:DealDamage( caster, parent, self.damage )
	caster:StartGesture(ACT_DOTA_ATTACK)
end

function modifier_boss_greymane_pounce_stun:OnDestroy()
	if IsServer() then self:GetCaster():Interrupt() end
end

function modifier_boss_greymane_pounce_stun:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_boss_greymane_pounce_stun:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_boss_greymane_pounce_stun:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end