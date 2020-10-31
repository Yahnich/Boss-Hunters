medusa_slither = class({})

function medusa_slither:IsStealable()
	return false
end

function medusa_slither:IsHiddenWhenStolen()
	return false
end

function medusa_slither:GetCastRange(vLocation, hTarget)
	if IsClient() then
		return self:GetTalentSpecialValueFor("dash_range")
	end
end

function medusa_slither:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_medusa_slither_2")
end

function medusa_slither:OnSpellStart()
	local caster = self:GetCaster()

	caster:RemoveModifierByName("modifier_medusa_slither")
	caster:AddNewModifier(caster, self, "modifier_medusa_slither", {Duration = self:GetTalentSpecialValueFor("duration")})
	caster:AddNewModifier(caster, self, "modifier_medusa_slither_evasion", {Duration = self:GetTalentSpecialValueFor("duration")})
	
	EmitSoundOn( "Hero_Medusa.MysticSnake.Cast", caster )
end

modifier_medusa_slither_evasion = class({})
LinkLuaModifier("modifier_medusa_slither_evasion", "heroes/hero_medusa/medusa_slither", LUA_MODIFIER_MOTION_NONE)

function modifier_medusa_slither_evasion:OnCreated()
	self:OnRefresh()
end

function modifier_medusa_slither_evasion:OnRefresh()
	self.evasion = self:GetTalentSpecialValueFor("evasion")
	if self:GetCaster():HasTalent("special_bonus_unique_medusa_slither_1") then
		self.as = self.evasion
		self.ms = self.evasion
	end
end

function modifier_medusa_slither_evasion:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_medusa_slither_evasion:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_medusa_slither_evasion:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_medusa_slither_evasion:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end
modifier_medusa_slither = class({})
LinkLuaModifier("modifier_medusa_slither", "heroes/hero_medusa/medusa_slither", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_medusa_slither:OnCreated()
		local parent = self:GetParent()
		self.distance = math.min( self:GetTalentSpecialValueFor("dash_range"), CalculateDistance( parent, self:GetAbility():GetCursorPosition() ) )
		self.direction = CalculateDirection( self:GetAbility():GetCursorPosition(), parent )
		self.speed = self:GetTalentSpecialValueFor("speed") * FrameTime()
		self:StartMotionController()
	end
	
	function modifier_medusa_slither:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		FindClearSpaceForUnit(parent, parentPos, true)
		self:StopMotionController()
	end
	
	function modifier_medusa_slither:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
	end
end

function modifier_medusa_slither:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_medusa_slither:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_DISABLE_TURNING }
end

function modifier_medusa_slither:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_medusa_slither:GetModifierDisableTurning()
	return 1
end

function modifier_medusa_slither:IsHidden()
	return true
end

function modifier_medusa_slither:GetEffectName()
	return "particles/units/heroes/hero_medusa/medusa_slither.vpcf"
end