juggernaut_windless_cuts = class({})

function juggernaut_windless_cuts:Precache(context)
    PrecacheResource("particle", "particles/items5_fx/wraith_pact_pulses.vpcf", context)
end

function juggernaut_windless_cuts:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_juggernaut_windless_cuts", {duration = duration + 0.1})
    caster:Purge(false,true,false,false,false)
    self:Slash(target)

    local last_gasp = caster:FindModifierByName("modifier_juggernaut_windless_cuts_last_gasp")
    if not last_gasp and self:GetSpecialValueFor("last_gasp_threshold") ~= 0 then
        caster:AddNewModifier(caster, self, "modifier_juggernaut_windless_cuts_last_gasp", {duration = -1})
    else
        return
    end
end

function juggernaut_windless_cuts:Slash(target)
    local caster = self:GetCaster()

    local direction = CalculateDirection(target, caster)
	local position = target:GetAbsOrigin() + direction * 84 --RandomInt(10, caster:GetAttackRange())
    local omni_slash = self:GetSpecialValueFor("bonus_damage")
    if omni_slash ~= 0 then
        self.nfx1 = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf"
        self.nfx2 = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail.vpcf"
    else
        self.nfx1 = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt_scepter.vpcf"
        self.nfx2 = "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_trail_scepter.vpcf"
    end

    ParticleManager:FireParticle(self.nfx1, PATTACH_POINT_FOLLOW, target, {[0]="attach_hitloc"})
	caster:SetAbsOrigin( position )
	ParticleManager:FireParticle(self.nfx2, PATTACH_POINT, caster, {[0]="attach_hitloc", [1]=position})
	EmitSoundOn("Hero_Juggernaut.OmniSlash", caster)
	EmitSoundOn("Hero_Juggernaut.OmniSlash.Damage", target)

    caster:PerformGenericAttack(target, true, {procAttackEffects = true})
	caster:SetForwardVector( CalculateDirection( target, caster ) )
	caster:FaceTowards( target:GetAbsOrigin() )
end

juggernaut_hidden_blade = class(juggernaut_windless_cuts)
function juggernaut_hidden_blade:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
end

modifier_juggernaut_windless_cuts = class({})
LinkLuaModifier("modifier_juggernaut_windless_cuts", "heroes/hero_juggernaut/juggernaut_windless_cuts", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_windless_cuts:OnCreated()
    local caster = self:GetCaster()
    self.aspd_bonus = self:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_dmg = self:GetSpecialValueFor("bonus_damage")
    self.radius = self:GetSpecialValueFor("omni_slash_radius")
    self.duration = self:GetSpecialValueFor("duration")

    self.blade_fury = caster:FindAbilityByName("juggernaut_whirling_dervish")
    self.endless = self:GetSpecialValueFor("endless")
    self.ignore = true
    self.activated = false
    self.disable_heal = 0

    if IsServer() then
        self.blade_fury:SetActivated(false)
        caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		self.rate = self:GetSpecialValueFor("attack_rate_multiplier")
		self.tick = caster:GetSecondsPerAttack(false) / self.rate
		caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 0.5/self.tick)
		self:StartIntervalThink( self.tick )
    end
end

function modifier_juggernaut_windless_cuts:OnRefresh()
    self:OnCreated()
end

function modifier_juggernaut_windless_cuts:OnIntervalThink(ignoreTarget)
    local caster = self:GetCaster()
	self.tick = caster:GetSecondsPerAttack(false) / self.rate

	local target
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius) ) do
		if enemy ~= ignoreTarget then
			target = enemy
			break
		end
	end
	if target then
		caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        local refreshes = self:GetSpecialValueFor("second_wind")
        local modifier = caster:FindModifierByName("modifier_juggernaut_windless_cuts")
        caster:StartGestureWithPlaybackRate(ACT_DOTA_OVERRIDE_ABILITY_4, 0.5/self.tick)
        self:GetAbility():Slash(target)

        if refreshes == 1 and modifier:GetRemainingTime() <= 0.5 and self.activated == false then
            local setHP = caster:GetHealth() * 0.05
            modifier:SetDuration(self.duration, true)
            self.activated = true
            self.disable_heal = 1
            caster:SetHealth(setHP)
            self.refresh_outgoing = self:GetSpecialValueFor("refresh_outgoing_increase")
        end
	elseif ( not target or target:IsNull() or not target:IsAlive() ) then
        if self.endless == 1 then
            self.ignore = false
            self.hasted = true

            local nfx = ParticleManager:CreateParticle("particles/items5_fx/wraith_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
            ParticleManager:SetParticleControl(nfx, 1, (Vector(self.radius,0,0)))
            self:AddEffect(nfx)

            caster:AddNewModifier(caster, self, "modifier_rune_haste", {duration = caster:FindModifierByName("modifier_juggernaut_windless_cuts"):GetRemainingTime()})
            caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
        else
		    self:Destroy()
        end
	end
end

function modifier_juggernaut_windless_cuts:OnDestroy()
    local caster = self:GetCaster()
    if IsServer() then
		
		local refresh_outgoing_increase_duration = self:GetSpecialValueFor("refresh_outgoing_increase_duration")
		if refresh_outgoing_increase_duration ~= 0 then
			target:AddNewModifier(caster, self, "modifier_juggernaut_windless_cuts_ronin", {duration = refresh_outgoing_increase_duration})
		end
        self.blade_fury:SetActivated(true)
        caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
        ResolveNPCPositions(caster:GetAbsOrigin(), caster:GetHullRadius() + caster:GetCollisionPadding())
    end
end

function modifier_juggernaut_windless_cuts:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_juggernaut_windless_cuts:GetDisableHealing()
    return self.disable_heal
end

function modifier_juggernaut_windless_cuts:GetModifierTotalDamageOutgoing_Percentage()
    return self.refresh_outgoing
end

function modifier_juggernaut_windless_cuts:GetModifierAttackSpeedBonus_Constant()
    return self.aspd_bonus
end

function modifier_juggernaut_windless_cuts:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_juggernaut_windless_cuts:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = self.ignore,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
		[MODIFIER_STATE_DISARMED] = true,
    }
end

function modifier_juggernaut_windless_cuts:GetStatusEffectName()
    return "particles/status_fx/status_effect_omnislash.vpcf"
end

function modifier_juggernaut_windless_cuts:StatusEffectPriority()
    return 20
end

modifier_juggernaut_windless_cuts_ronin = class({})
LinkLuaModifier("modifier_juggernaut_windless_cuts_ronin", "heroes/hero_juggernaut/juggernaut_windless_cuts", LUA_MODIFIER_MOTION_NONE)
function modifier_juggernaut_windless_cuts_ronin:IsDebuff()
    return true
end

function modifier_juggernaut_windless_cuts_ronin:IsPurgeable()
    return true
end

function modifier_juggernaut_windless_cuts_ronin:OnCreated()
    self:OnRefresh()
end

function modifier_juggernaut_windless_cuts_ronin:OnRefresh()
    self.refresh_outgoing_increase = self:GetSpecialValueFor("refresh_outgoing_increase")
end

function modifier_juggernaut_windless_cuts_ronin:DeclareFunctions()
    return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

modifier_juggernaut_windless_cuts_last_gasp = class({})
LinkLuaModifier("modifier_juggernaut_windless_cuts_last_gasp", "heroes/hero_juggernaut/juggernaut_windless_cuts", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_windless_cuts_last_gasp:IsHidden()
    return self:GetParent():HasModifier("modifier_juggernaut_windless_cuts_last_gasp_cd")
end

function modifier_juggernaut_windless_cuts_last_gasp:IsBuff()
    return true
end

function modifier_juggernaut_windless_cuts_last_gasp:DeclareFunctions()
    return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_juggernaut_windless_cuts_last_gasp:OnCreated()
    self.duration = self:GetSpecialValueFor("duration")
    self.threshold = self:GetSpecialValueFor("last_gasp_threshold") / 100

    self.nearestEnemy = {}
    self:StartIntervalThink(0.1)
end

function modifier_juggernaut_windless_cuts_last_gasp:OnIntervalThink()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local maxHP = caster:GetMaxHealth()
    local currentHP = caster:GetHealth()

    if IsServer() then
        if currentHP < (maxHP * self.threshold) and ability:IsCooldownReady() then
            self:StartIntervalThink(-1)
			ability:SetCooldown()
            for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("AbilityCastRange"), {order=FIND_CLOSEST})) do
                if not self.nearestEnemy[enemy:entindex()] then
                    caster:AddNewModifier(caster, ability, "modifier_juggernaut_windless_cuts", {duration = self.duration + 0.1})
                    caster:Dispel(caster,true)
                    ability:Slash(enemy)
                    self.nearestEnemy[enemy:entindex()] = true
                    Timers:CreateTimer(self.cooldown, function()
                        self:OnCreated()
                    end)
                end
            end
        end
    end
end

function modifier_juggernaut_windless_cuts_last_gasp:OnTooltip()
    return self.threshold * 100
end