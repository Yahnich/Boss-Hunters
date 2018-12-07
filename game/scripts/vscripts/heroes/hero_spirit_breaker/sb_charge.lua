sb_charge = class({})
LinkLuaModifier( "modifier_sb_charge", "heroes/hero_spirit_breaker/sb_charge.lua" ,LUA_MODIFIER_MOTION_NONE )

function sb_charge:IsStealable()
    return true
end

function sb_charge:IsHiddenWhenStolen()
    return false
end

function sb_charge:GetCastPoint()
	return 0.25
end

function sb_charge:OnSpellStart()
	EmitSoundOn("Hero_Spirit_Breaker.ChargeOfDarkness", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sb_charge", {})
end

modifier_sb_charge = class({})
function modifier_sb_charge:OnCreated(table)
	self.ms = self:GetTalentSpecialValueFor("movement_speed")
	self.basems = self:GetParent():GetIdealSpeed()
	if IsServer() then
		local parent = self:GetParent()

		self.hitUnits = {}

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
		
		self.dir = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetParent():GetAbsOrigin())
		self.distance = 1000

		self:StartMotionController()
	end
end

function modifier_sb_charge:DoControlledMotion()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if self.distance > 0 then
		local speed = self.ms
		speed = (speed + parent:GetMoveSpeedModifier(parent:GetBaseMoveSpeed())) * FrameTime()
		local radius = 100
		self.distance = self.distance - speed
		GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), radius, true)

		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*speed)
	
		local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), radius)
		for _,enemy in pairs(enemies) do
			if not self.hitUnits[enemy:entindex()] then
				if parent:HasTalent("special_bonus_unique_sb_charge_1") then
					parent:PerformAttack(enemy, true, true, true, true, true, false, false)
				end

				local ability2 = parent:FindAbilityByName("sb_bash")
				if ability2 and ability2:IsTrained() then
					ability2:Bash(enemy, ability2:GetTalentSpecialValueFor("knockback_distance"))
				end
				self.hitUnits[enemy:entindex()] = true
			end
		end
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:StopMotionController(true)
		self:Destroy()
	end
end

function modifier_sb_charge:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end

function modifier_sb_charge:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    }
    return funcs
end

function modifier_sb_charge:GetModifierMoveSpeed_AbsoluteMin()
	return self.basems + self.ms
end

function modifier_sb_charge:GetActivityTranslationModifiers()
	return "charge"
end

function modifier_sb_charge:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_sb_charge:GetModifierEvasion_Constant()
	if self:GetCaster():HasTalent("special_bonus_unique_sb_charge_2") then
		return 100
	end
end

function modifier_sb_charge:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_Spirit_Breaker.Charge.Impact", self:GetParent())
		self:GetParent():StartGesture(ACT_DOTA_SPIRIT_BREAKER_CHARGE_END)
	end
end