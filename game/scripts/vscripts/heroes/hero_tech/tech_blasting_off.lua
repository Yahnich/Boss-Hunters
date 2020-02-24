tech_blasting_off = class({})

function tech_blasting_off:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function tech_blasting_off:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Techies.BlastOff.Cast", self:GetCaster() )
	return true
end

function tech_blasting_off:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Techies.BlastOff.Cast", self:GetCaster() )
end

function tech_blasting_off:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:Stop()
	
	StopSoundOn("Hero_Techies.BlastOff.Cast", self:GetCaster() )
	caster:AddNewModifier( caster, self, "modifier_tech_blasting_off_movement", { duration = self:GetTalentSpecialValueFor("jump_duration") + 0.1 } )
	ParticleManager:FireParticle("particles/units/heroes/hero_techies/techies_blast_off_cast.vpcf", PATTACH_ABSORIGIN, caster)
end


modifier_tech_blasting_off_movement = class({})
LinkLuaModifier("modifier_tech_blasting_off_movement", "heroes/hero_tech/tech_blasting_off", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_tech_blasting_off_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = parent:GetForwardVector()
		self.speed = (self.distance / self:GetTalentSpecialValueFor("jump_duration")) * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 281.108
		
		self.radius = self:GetTalentSpecialValueFor("radius")
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.selfDmg = self:GetTalentSpecialValueFor("hp_cost") / 100
		self.duration = self:GetTalentSpecialValueFor("silence_duration")
		
		if parent:HasTalent("special_bonus_unique_tech_blasting_off_1") then
			self.mine = parent:FindAbilityByName("tech_mine")
		end
		
		self:StartMotionController()
	end
	
	
	function modifier_tech_blasting_off_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local ability = self:GetAbility()
		ResolveNPCPositions(parentPos, parent:GetHullRadius() + parent:GetCollisionPadding())
		self:StopMotionController()
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parentPos, self.radius ) ) do
			if not enemy:TriggerSpellAbsorb( ability ) then
				ability:DealDamage( parent, enemy, self.damage )
				enemy:Silence(ability, parent, self.duration)
			end
		end
		ParticleManager:FireParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_ABSORIGIN, parent, {[0] = parentPos} )
		EmitSoundOn("Hero_Techies.Suicide", parent)
		ability:DealDamage( parent, parent, self.selfDmg * parent:GetMaxHealth() )
		if not parent:IsAlive() and parent:HasTalent("special_bonus_unique_tech_blasting_off_2") and not parent:HasModifier("modifier_tech_blasting_off_cd") then
			parent:RespawnHero(false, false)
			parent:SetHealth( parent:GetMaxHealth() )
			parent:SetMana( parent:GetMaxMana() )
			parent:SetAbsOrigin( parentPos )
			parent:AddNewModifier( parent, ability, "modifier_tech_blasting_off_cd", {duration = parent:FindTalentValue("special_bonus_unique_tech_blasting_off_2")} )
		end
	end
	
	function modifier_tech_blasting_off_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		
		if parent:IsAlive() and self.distanceTraveled <= self.distance then
			if self.distanceTraveled > self.distance / 2 and self.mine then
				self.mine:PlantLandMine( parent:GetAbsOrigin() )
				self.mine = nil
			end
			
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			parent:SetAbsOrigin( GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed )
			self:Destroy()
			return
		end
	end
end

function modifier_tech_blasting_off_movement:GetEffectName()
	return "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf"
end

function modifier_tech_blasting_off_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_tech_blasting_off_movement:IsHidden()
	return true
end

function modifier_tech_blasting_off_movement:RemoveOnDeath()
	return false
end


modifier_tech_blasting_off_cd = class({})
LinkLuaModifier("modifier_tech_blasting_off_cd", "heroes/hero_tech/tech_blasting_off", LUA_MODIFIER_MOTION_NONE)