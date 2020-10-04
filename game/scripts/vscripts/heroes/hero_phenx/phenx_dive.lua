phenx_dive = class({})
LinkLuaModifier( "modifier_phenx_dive_caster", "heroes/hero_phenx/phenx_dive.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phenx_dive_burn", "heroes/hero_phenx/phenx_dive.lua", LUA_MODIFIER_MOTION_NONE )

function phenx_dive:IsStealable()
    return true
end

function phenx_dive:IsHiddenWhenStolen()
    return false
end

function phenx_dive:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_phenx_dive_caster") then
        return "phoenix_icarus_dive_stop"
    end

    return "phoenix_icarus_dive"
end

function phenx_dive:GetBehavior()
    if self:GetCaster():HasModifier("modifier_phenx_dive_caster") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    return DOTA_ABILITY_BEHAVIOR_POINT
end

function phenx_dive:GetCastPoint()
    if self:GetCaster():HasModifier("modifier_phenx_dive_caster") then
        return 0
    end

    return self.BaseClass.GetCastPoint(self)
end

function phenx_dive:GetCooldown(iLvl)
    if self:GetCaster():HasModifier("modifier_phenx_dive_caster") or self:GetCaster():HasTalent("special_bonus_unique_phenx_dive_1") then
        return 0
    end

    return self.BaseClass.GetCooldown(self, iLvl)
end

function phenx_dive:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_Phoenix.FireSpirits.Cast", caster)

    if caster:HasModifier("modifier_phenx_dive_caster") then
        caster:RemoveModifierByName("modifier_phenx_dive_caster")
        self:RefundManaCost()
    else
        caster:AddNewModifier(caster, self, "modifier_phenx_dive_caster", {Duration = self:GetTalentSpecialValueFor("dash_duration"), ignoreStatusAmp = true})
        self:EndCooldown()
        caster:SetHealth( caster:GetHealth() * ( 100 - self:GetTalentSpecialValueFor("hp_cost_perc") ) / 100 )
    end
end

modifier_phenx_dive_caster = class({})
function modifier_phenx_dive_caster:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        self:StartIntervalThink(FrameTime())

        self.casterOrigin  = caster:GetAbsOrigin()
        self.casterAngles  = caster:GetAngles()
        self.forwardDir    = caster:GetForwardVector()
        self.rightDir      = caster:GetRightVector()

        self.ellipseCenter = self.casterOrigin + self.forwardDir * ( self:GetAbility():GetTrueCastRange() / 2 )

        self.startTime = GameRules:GetGameTime()

        self:StartMotionController()
    end
end

function modifier_phenx_dive_caster:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()
        self:GetAbility():SetCooldown()
		ResolveNPCPositions( caster:GetAbsOrigin(), caster:GetHullRadius() + caster:GetCollisionPadding() )
    end
end

function modifier_phenx_dive_caster:DoControlledMotion()
    local caster = self:GetCaster()
    local elapsedTime = GameRules:GetGameTime() - self.startTime
    local progress = elapsedTime / self:GetTalentSpecialValueFor("dash_duration")

    -- Calculate potision
    local theta = -2 * math.pi * progress
    local x =  math.sin( theta ) * self:GetTalentSpecialValueFor("dash_width") * 0.5
    local y = -math.cos( theta ) * self:GetAbility():GetTrueCastRange() * 0.5

    local pos = self.ellipseCenter + self.rightDir * x + self.forwardDir * y
    local yaw = self.casterAngles.y + 90 + progress * -360  

    pos = GetGroundPosition( pos, caster )
    caster:SetAbsOrigin( pos )
    caster:SetAngles( self.casterAngles.x, yaw, self.casterAngles.z )
end

function modifier_phenx_dive_caster:OnIntervalThink()
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("dash_width"), false)
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("dash_width"), {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
    for _,enemy in pairs(enemies) do
		self:GetParent():PerformAttack(enemy, true, true, true, true, true, false, false)
        break
    end
    self:StartIntervalThink(self:GetCaster():GetSecondsPerAttack())
end

function modifier_phenx_dive_caster:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
    return state
end

function modifier_phenx_dive_caster:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
    }
    return funcs
end

function modifier_phenx_dive_caster:OnStateChanged(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            if params.unit:IsStunned() or params.unit:IsHexed() or params.unit:IsFrozen() or params.unit:IsNightmared() or params.unit:IsOutOfGame() then
            -- Interrupt the ability
            params.unit:RemoveModifierByName("modifier_phenx_dive_caster")
            end
        end
    end
end

function modifier_phenx_dive_caster:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_phenx_dive_caster:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf"
end

function modifier_phenx_dive_caster:IsAura()
    return true
end

function modifier_phenx_dive_caster:GetAuraDuration()
    return self:GetTalentSpecialValueFor("burn_duration")
end

function modifier_phenx_dive_caster:GetAuraRadius()
    return self:GetTalentSpecialValueFor("dash_width")
end

function modifier_phenx_dive_caster:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_phenx_dive_caster:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_phenx_dive_caster:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_phenx_dive_caster:GetModifierAura()
    return "modifier_phenx_dive_burn"
end

function modifier_phenx_dive_caster:IsAuraActiveOnDeath()
    return false
end

modifier_phenx_dive_burn = class({})
function modifier_phenx_dive_burn:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_phenx_dive_burn:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage_per_second"), {}, 0)
    self:StartIntervalThink(0.5)
end

function modifier_phenx_dive_burn:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn_debuff.vpcf"
end

function modifier_phenx_dive_burn:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_phenx_dive_burn:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow_movement_speed_pct")
end