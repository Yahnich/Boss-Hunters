slark_pounce_bh = class({})

-- function slark_pounce_bh:GetCooldown(iLvl)
	-- return self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_slark_pounce_1")
-- end

function slark_pounce_bh:GetBehavior(iLvl)
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET 
	if not self:GetCaster():HasTalent("special_bonus_unique_slark_pounce_2") then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	end
	return behavior
end

function slark_pounce_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)
	
	caster:AddNewModifier( caster, self, "modifier_slark_pounce_movement", {duration = self:GetTalentSpecialValueFor("pounce_distance") / self:GetTalentSpecialValueFor("pounce_speed") + 0.1} )
	ParticleManager:FireParticle("particles/units/heroes/hero_slark/slark_pounce_start.vpcf", PATTACH_ABSORIGIN, caster)
	EmitSoundOn("Hero_Slark.Pounce.Cast", caster)
end

modifier_slark_pounce_movement = class({})
LinkLuaModifier("modifier_slark_pounce_movement", "heroes/hero_slark/slark_pounce_bh", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function modifier_slark_pounce_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = self:GetTalentSpecialValueFor("pounce_distance")
		self.direction = parent:GetForwardVector()
		self.speed = self:GetTalentSpecialValueFor("pounce_speed") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 125
		
		self.radius = self:GetTalentSpecialValueFor("pounce_radius")
		self.damage = self:GetTalentSpecialValueFor("pounce_damage")
		self.duration = self:GetTalentSpecialValueFor("leash_duration")
		
		self.enemiesHit = {}
		parent:StartGesture( ACT_DOTA_SLARK_POUNCE )
		self:StartMotionController()
	end
	
	
	function modifier_slark_pounce_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		ResolveNPCPositions(parentPos, parent:GetHullRadius() + parent:GetCollisionPadding())
		self:StopMotionController()
	end
	
	function modifier_slark_pounce_movement:DoControlledMotion()
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
				return
			end
		end
	end
	
	function modifier_slark_pounce_movement:Pounce(target)
		local caster = self:GetParent()
		local ability = self:GetAbility()
		if target:TriggerSpellAbsorb( ability ) then return end
		ability:DealDamage(caster, target, self.damage)
		target:Paralyze(ability, caster, self.duration)
		target:Disarm(ability, caster, self.duration)
		EmitSoundOn("Hero_Slark.Pounce.Impact", target)
		
		if caster:HasTalent("special_bonus_unique_slark_pounce_1") then
			caster:AddNewModifier( caster, ability, "modifier_slark_area_damage", {} )
			caster:PerformAbilityAttack(target, true, ability)
			caster:RemoveModifierByName( "modifier_slark_area_damage" )
		end
	end
end

function modifier_slark_pounce_movement:GetEffectName()
	return "particles/units/heroes/hero_slark/slark_pounce_trail.vpcf"
end

function modifier_slark_pounce_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_slark_pounce_movement:IsHidden()
	return true
end


modifier_slark_area_damage = class({})
LinkLuaModifier("modifier_slark_area_damage", "heroes/hero_slark/slark_pounce_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_area_damage:OnCreated()
	self.area = self:GetCaster():FindTalentValue("special_bonus_unique_slark_pounce_1")
	self:GetParent():HookInModifier( "GetModifierAreaDamage", self, priority )
end

function modifier_slark_area_damage:OnDestroy()
	self.area = self:GetCaster():FindTalentValue("special_bonus_unique_slark_pounce_1")
	self:GetParent():HookOutModifier( "GetModifierAreaDamage", self )
end

function modifier_slark_area_damage:GetModifierAreaDamage()
	return self.area
end

function modifier_slark_area_damage:IsHidden()
	return true
end