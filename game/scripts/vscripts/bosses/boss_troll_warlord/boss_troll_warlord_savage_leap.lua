boss_troll_warlord_savage_leap = class({})
LinkLuaModifier("modifier_boss_troll_warlord_savage_leap_movement", "bosses/boss_troll_warlord/boss_troll_warlord_savage_leap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_troll_warlord_savage_leap_ride", "bosses/boss_troll_warlord/boss_troll_warlord_savage_leap", LUA_MODIFIER_MOTION_NONE)

function boss_troll_warlord_savage_leap:OnAbilityPhaseStart()
	self.pos = self:GetCursorTarget():GetAbsOrigin()
	ParticleManager:FireWarningParticle( self.pos, self:GetSpecialValueFor("radius"))
	return true
end

function boss_troll_warlord_savage_leap:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Ability.Leap", caster)
	caster:AddNewModifier( caster, self, "modifier_boss_troll_warlord_savage_leap_movement", {})
end

modifier_boss_troll_warlord_savage_leap_movement = class({})

if IsServer() then
	function modifier_boss_troll_warlord_savage_leap_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility().pos
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetSpecialValueFor("leap_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 350
		self:StartMotionController()
	end
	
	
	function modifier_boss_troll_warlord_savage_leap_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()

		FindClearSpaceForUnit(parent, parentPos, true)
		if parent:IsFrozen() then return end
		local ability = self:GetAbility()
		local damage = self:GetSpecialValueFor("damage") * parent:GetModelScale()
		local radius = self:GetSpecialValueFor("radius") * parent:GetModelScale()
		
		ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, parent, {[1] = Vector(radius, 1, 1)})
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parentPos, radius ) ) do
			ability:DealDamage(parent, enemy, damage)
		end
		EmitSoundOn("Ability.TossImpact", parent)
		self:StopMotionController()
	end
	
	function modifier_boss_troll_warlord_savage_leap_movement:DoControlledMotion()
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
			local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
			for _,enemy in pairs(enemies) do
				if enemy:IsHero() then
					if not enemy:TriggerSpellAbsorb(self) then
						self:GetAbility().enemy = enemy
						parent:AddNewModifier(parent, self:GetAbility(), "modifier_boss_troll_warlord_savage_leap_ride", {Duration = self:GetSpecialValueFor("duration")})
						self:GetAbility().enemy:Daze(self:GetAbility(), self:GetCaster(), self:GetSpecialValueFor("duration"))
					end
					break
				end
			end
			self:Destroy()
			return nil
		end       
		
	end
end

function modifier_boss_troll_warlord_savage_leap_movement:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_boss_troll_warlord_savage_leap_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_troll_warlord_savage_leap_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_boss_troll_warlord_savage_leap_movement:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end

modifier_boss_troll_warlord_savage_leap_ride = class({})
function modifier_boss_troll_warlord_savage_leap_ride:OnCreated(table)
	if IsServer() then 
		self:StartIntervalThink(FrameTime())
		self:GetParent():FindAbilityByName("boss_troll_warlord_axe_fury"):SetActivated(true)
	end
end

function modifier_boss_troll_warlord_savage_leap_ride:OnIntervalThink()
	if self:GetAbility().enemy:IsAlive() then
		self:GetParent():SetAbsOrigin(self:GetAbility().enemy:GetAbsOrigin())
		self:GetParent():SetForceAttackTarget(self:GetAbility().enemy)
	else
		self:Destroy()
	end
end

function modifier_boss_troll_warlord_savage_leap_ride:OnRemoved()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
		self:GetAbility().enemy = nil
		self:GetParent():SetForceAttackTarget(nil)
		self:GetParent():FindAbilityByName("boss_troll_warlord_axe_fury"):SetActivated(false)
	end
end

function modifier_boss_troll_warlord_savage_leap_ride:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_ROOTED] = true,
                    [MODIFIER_STATE_SILENCED] = true}
    return state
end