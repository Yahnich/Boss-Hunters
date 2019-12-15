slardar_slithereen_crush_bh = class({})

function slardar_slithereen_crush_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("crush_radius")
end

function slardar_slithereen_crush_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_slardar_slithereen_crush_1") and not self:GetCaster():IsRooted() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function slardar_slithereen_crush_bh:GetCastRange( target, position )
	if self:GetCaster():HasTalent("special_bonus_unique_slardar_slithereen_crush_1") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_slardar_slithereen_crush_1")
	else
		return self:GetTalentSpecialValueFor("crush_radius")
	end
end

function slardar_slithereen_crush_bh:OnSpellStart(bForced)
	local caster = self:GetCaster()

	if not caster:HasTalent("special_bonus_unique_slardar_slithereen_crush_1") or bForced or ( caster:HasTalent("special_bonus_unique_slardar_slithereen_crush_1") and CalculateDistance( caster, self:GetCursorPosition() ) < 300 ) then
		local radius = self:GetTalentSpecialValueFor("crush_radius")
		local damage = self:GetTalentSpecialValueFor("damage")
		local stunDur = self:GetTalentSpecialValueFor("stun_duration")
		local slowDur = self:GetTalentSpecialValueFor("crush_extra_slow_duration")
		
		local haze = caster:FindAbilityByName("slardar_amplify_damage_bh")
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
			if enemy:TriggerSpellAbsorb( self ) then
				self:DealDamage( caster, enemy, damage )
				self:Stun(enemy, stunDur)
				enemy:AddNewModifier( caster, self, "modifier_slardar_slithereen_crush_bh", {duration = stunDur + slowDur} )
				if caster:HasScepter() and haze then
					haze:ApplyHaze( enemy )
				end
			end
		end
		
		caster:EmitSound("Hero_Slardar.Slithereen_Crush")
		ParticleManager:FireParticle("particles/units/heroes/hero_slardar/slardar_crush.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin(), [1] = Vector(radius, radius, radius)} )
	else
		caster:AddNewModifier( caster, self, "modifier_slardar_slithereen_crush_bh_movement", {} )
	end
	
end

modifier_slardar_slithereen_crush_bh = class({})
LinkLuaModifier( "modifier_slardar_slithereen_crush_bh", "heroes/hero_slardar/slardar_slithereen_crush_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_slithereen_crush_bh:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("crush_extra_slow")
	self.as = self:GetTalentSpecialValueFor("crush_attack_slow_tooltip")
end


function modifier_slardar_slithereen_crush_bh:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		
    }
    return funcs
end

function modifier_slardar_slithereen_crush_bh:GetModifierMoveSpeedBonus_Percentage()
    return self.ms
end

function modifier_slardar_slithereen_crush_bh:GetModifierAttackSpeedBonus()
	return self.as
end

modifier_slardar_slithereen_crush_bh_movement = class({})
LinkLuaModifier( "modifier_slardar_slithereen_crush_bh_movement", "heroes/hero_slardar/slardar_slithereen_crush_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_slithereen_crush_bh_movement:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()
		local position = self:GetAbility():GetCursorPosition()
		self.endPos = position
		self.dir = CalculateDirection( position, parent )
		self.distance = CalculateDistance( position, parent )
		self.speed = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_slithereen_crush_1")

		self:StartMotionController()
	end
end


function modifier_slardar_slithereen_crush_bh_movement:OnRemoved()
	if IsServer() then
		self:GetAbility():OnSpellStart(true)
	end
end

function modifier_slardar_slithereen_crush_bh_movement:DoControlledMotion()
	local parent = self:GetParent()
	if self.distance > 0 then
		self.distance = self.distance - self.speed * FrameTime()
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*self.speed * FrameTime() )
	else
		parent:SetAbsOrigin(GetGroundPosition(self.endPos, parent) )
		FindClearSpaceForUnit(parent, self.endPos, true)
		self:StopMotionController(true)
		parent:StartGesture( ACT_DOTA_CAST_ABILITY_2 )
		Timers:CreateTimer( self:GetAbility():GetCastPoint(), self:Destroy() )
	end
end

function modifier_slardar_slithereen_crush_bh_movement:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end

function modifier_slardar_slithereen_crush_bh_movement:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_slardar_slithereen_crush_bh_movement:GetActivityTranslationModifiers()
	return "sprint"
end

function modifier_slardar_slithereen_crush_bh_movement:GetOverrideAnimation()
	return ACT_DOTA_RUN
end