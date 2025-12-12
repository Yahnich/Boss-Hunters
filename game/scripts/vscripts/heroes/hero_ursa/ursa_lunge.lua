ursa_lunge = class({})
LinkLuaModifier("modifier_ursa_lunge_movement", "heroes/hero_ursa/ursa_lunge", LUA_MODIFIER_MOTION_NONE)

function ursa_lunge:IsStealable()
	return true
end

function ursa_lunge:IsHiddenWhenStolen()
	return false
end

function ursa_lunge:GetCastRange(target, position)
	return self:GetSpecialValueFor("jump_distance")
end

function ursa_lunge:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_LoneDruid.BattleCry.Bear", caster)

	caster:AddNewModifier(caster, self, "modifier_ursa_lunge_movement", {duration = self:GetSpecialValueFor("jump_duration") + FrameTime()})
end

modifier_ursa_lunge_movement = class({})
if IsServer() then
	function modifier_ursa_lunge_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetSpecialValueFor("jump_duration") * FrameTime()
		self.maxHeight = 100
		self:StartMotionController()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_lunge.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
		self:AttachEffect(nfx)
	end
	
	function modifier_ursa_lunge_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		FindClearSpaceForUnit(parent, parentPos, true)

		GridNav:DestroyTreesAroundPoint(parentPos, parent:GetAttackRange(), false)

		local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), parent:GetAttackRange())
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				if parent:HasTalent("special_bonus_unique_ursa_lunge_2") then
					enemy:ApplyKnockBack(parent:GetAbsOrigin(), 0.25, 0.25, 150, 100, parent, self:GetAbility())
				end

				parent:PerformAttack(enemy, true, true, true, true, false, false, false)
			end
		end

		self:StopMotionController()
	end
	
	function modifier_ursa_lunge_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			local height = GetGroundHeight(parent:GetAbsOrigin(), parent)
			newPos.z = height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
		
	end
end

function modifier_ursa_lunge_movement:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_ursa_lunge_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_ursa_lunge_movement:GetModifierIncomingDamage_Percentage()
	return self:GetSpecialValueFor("reduction")
end

function modifier_ursa_lunge_movement:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_ursa_lunge_movement:IsHidden()
	return true
end