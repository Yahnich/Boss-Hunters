drow_ranger_leapshot = class({})

function drow_ranger_leapshot:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)
	
	for _, enemy in pairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), caster:GetAttackRange() ) ) do
		if caster:FindAbilityByName("drow_ranger_glacier_arrows"):GetAutoCastState() then 
			caster:FindAbilityByName("drow_ranger_glacier_arrows"):LaunchFrostArrow(enemy, false)
		else
			caster:FireAbilityAutoAttack( enemy, self )
		end
		
	end
	caster:AddNewModifier( caster, self, "modifier_drow_ranger_leapshot_movement", {duration = self:GetTalentSpecialValueFor("leap_distance") / self:GetTalentSpecialValueFor("leap_speed")} )
end

function drow_ranger_leapshot:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		caster:PerformGenericAttack(target, true)
		target:Silence( self, caster, self:GetTalentSpecialValueFor("silence_duration") )
		if caster:HasTalent("special_bonus_unique_drow_ranger_leapshot_2") then
			target:ApplyKnockBack(position, 0.3, 0.3, -200, 0, caster, self)
		end
	end
end

modifier_drow_ranger_leapshot_movement = class({})
LinkLuaModifier("modifier_drow_ranger_leapshot_movement", "heroes/hero_drow_ranger/drow_ranger_leapshot", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_drow_ranger_leapshot_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = self:GetTalentSpecialValueFor("leap_distance")
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self:GetTalentSpecialValueFor("leap_speed") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 325
		self:StartMotionController()
	end
	
	
	function modifier_drow_ranger_leapshot_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local damage = self:GetTalentSpecialValueFor("damage")
		local radius = self:GetTalentSpecialValueFor("radius")

		local angles = parent:GetAnglesAsVector()
		parent:SetAngles(0, angles.y, angles.z)
		
		self:StopMotionController()
	end
	
	function modifier_drow_ranger_leapshot_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		local angles = parent:GetAnglesAsVector()
		parent:SetAngles(angles.x + 48, angles.y, angles.z)
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

function modifier_drow_ranger_leapshot_movement:GetEffectName()
	return "particles/units/heroes/hero_drow_ranger/drow_ranger_leapshot_blur.vpcf"
end

function modifier_drow_ranger_leapshot_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_drow_ranger_leapshot_movement:IsHidden()
	return true
end