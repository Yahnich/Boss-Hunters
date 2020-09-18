boss_apotheosis_ruthless_hunter = class({})

function boss_apotheosis_ruthless_hunter:IsStealable()
    return true
end

function boss_apotheosis_ruthless_hunter:IsHiddenWhenStolen()
    return false
end

function boss_apotheosis_ruthless_hunter:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	ParticleManager:FireLinearWarningParticle( caster:GetAbsOrigin(), self:GetCursorPosition(), 100 * 2 )
	return true
end

function boss_apotheosis_ruthless_hunter:OnSpellStart()
	EmitSoundOn("Hero_Spirit_Breaker.ChargeOfDarkness", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_boss_apotheosis_ruthless_hunter", {})
end

modifier_boss_apotheosis_ruthless_hunter = class({})
LinkLuaModifier( "modifier_boss_apotheosis_ruthless_hunter", "bosses/boss_apotheosis/boss_apotheosis_ruthless_hunter.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_boss_apotheosis_ruthless_hunter:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()

		self.hitUnits = {}

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
		
		self.dir = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetParent():GetAbsOrigin())
		self.distance = CalculateDistance( self:GetAbility():GetCursorPosition(), parent )
		self.damage = self:GetSpecialValueFor("damage")
		self.knockback = self:GetSpecialValueFor("knockback")
		self.stun = self:GetSpecialValueFor("duration")
		self.speed = self:GetSpecialValueFor("speed")
		self:StartMotionController()
	end
end

function modifier_boss_apotheosis_ruthless_hunter:DoControlledMotion()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if self.distance > 0 then
		local speed = self.speed * FrameTime()
		local radius = 100
		local position = parent:GetAbsOrigin()
		self.distance = self.distance - speed
		GridNav:DestroyTreesAroundPoint(position, radius, true)

		
		local enemies = parent:FindEnemyUnitsInRadius(position, radius)
		for _,enemy in pairs(enemies) do
			if not self.hitUnits[enemy:entindex()] then
				if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
					enemy:StopMotionControllers(false)
					local modifierKnockback = {
						center_x = position.x,
						center_y = position.y,
						center_z = position.z,
						duration = self.stun,
						knockback_duration = 0.5,
						knockback_distance = self.knockback,
						knockback_height = 125,
					}
					enemy:AddNewModifier( parent, ability, "modifier_knockback", modifierKnockback )
					ability:DealDamage( parent, enemy, self.damage )
				end
				self.hitUnits[enemy:entindex()] = true
			end
		end
		
		parent:SetAbsOrigin(GetGroundPosition(position, parent) + self.dir*speed)
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:StopMotionController(true)
		self:Destroy()
	end
end



function modifier_boss_apotheosis_ruthless_hunter:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end

function modifier_boss_apotheosis_ruthless_hunter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_boss_apotheosis_ruthless_hunter:GetOverrideAnimation()
	return ACT_DOTA_RUN
end

function modifier_boss_apotheosis_ruthless_hunter:OnRemoved()
	if IsServer() then
		EmitSoundOn("boss_apotheosis.Charge.Impact", self:GetParent())
		self:GetParent():StartGesture(ACT_DOTA_SPIRIT_BREAKER_CHARGE_END)
	end
end