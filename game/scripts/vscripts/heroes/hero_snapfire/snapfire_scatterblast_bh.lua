snapfire_scatterblast_bh = class({})

function snapfire_scatterblast_bh:IsStealable()
    return true
end

function snapfire_scatterblast_bh:IsHiddenWhenStolen()
    return false
end

-- function snapfire_scatterblast_bh:GetIntrinsicModifierName()
    -- return "modifier_snapfire_scatterblast_bh_talent"
-- end

function snapfire_scatterblast_bh:OnAbilityPhaseStart()
    EmitSoundOn("Hero_Snapfire.Shotgun.Load", self:GetCaster())
    return true
end

function snapfire_scatterblast_bh:OnAbilityPhaseInterrupted()
    StopSoundOn("Hero_Snapfire.Shotgun.Load", self:GetCaster())
end

function snapfire_scatterblast_bh:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    
    local direction = CalculateDirection(point, caster:GetAbsOrigin())
    local speed = self:GetSpecialValueFor("blast_speed")
    local velocity = direction * speed
    local distance = self:GetTrueCastRange() --self:GetCastRange(point, caster)
    local start_width = self:GetSpecialValueFor("blast_width_initial")
    local end_width = self:GetSpecialValueFor("blast_width_end")

    EmitSoundOn("Hero_Snapfire.Shotgun.Fire", self:GetCaster())

    self:FireLinearProjectile("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", velocity, distance, start_width, {width_end = end_width, extraData = {name = "majorblast"}}, false, false, 0)
	
	if caster:HasTalent("special_bonus_unique_snapfire_scatterblast_2") then
		local potentialTargets = {}
		local targetToBlast
		for _, potentialTarget in ipairs( caster:FindEnemyUnitsInCone( direction, caster:GetAbsOrigin(), end_width / 2, distance ) ) do
			potentialTargets[potentialTarget] = true
		end
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), distance ) ) do
			if not potentialTargets[enemy] then
				targetToBlast = enemy
				break
			end
		end
		DebugDrawLine( caster:GetAbsOrigin(), caster:GetAbsOrigin() + direction * distance, 255, 0, 0, true, 0.5)
		if targetToBlast then
			local angle = math.atan( end_width / distance ) -- max angle, minimum 2x angle to rotate
			local blastDistance = CalculateDistance( targetToBlast, caster )
			local directionVector = CalculateDirection( targetToBlast, caster )
			local dotProduct = DotProduct( direction * distance, directionVector * blastDistance )
			DebugDrawLine( caster:GetAbsOrigin(), caster:GetAbsOrigin() + directionVector * blastDistance, 255, 0, 0, true, 0.5)
			
			local angleBetweenBlasts = math.acos( dotProduct / (distance * blastDistance) ) -- take largest angle
			local angleDiff = 0
			if angle * 2 > math.abs(angleBetweenBlasts) then
				local line = { caster:GetAbsOrigin(), caster:GetAbsOrigin() + direction * distance }
				local sideOfLine = FindSideOfLine( targetToBlast:GetAbsOrigin(), line )
				angleDiff = TernaryOperator( -(angle * 2 - math.abs(angleBetweenBlasts)), sideOfLine > 0, (angle * 2 - math.abs(angleBetweenBlasts)) )
			end
			
			local blastDirection = RotateVector2D( directionVector, angleDiff )
			DebugDrawLine( caster:GetAbsOrigin(), caster:GetAbsOrigin() + blastDirection * blastDistance, 0, 255, 0, true, 0.5)
			
			self:FireLinearProjectile("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", blastDirection * speed, distance, start_width, {width_end = end_width, extraData = {name = "majorblast"}}, false, false, 0)
		end
	end
end

function snapfire_scatterblast_bh:OnProjectileHit_ExtraData(hTarget, vLocation, table)
    local caster = self:GetCaster()

    local damage = self:GetSpecialValueFor("damage")
    local point_blank_range = self:GetSpecialValueFor("point_blank_range")
    local point_blank_dmg_bonus_pct = self:GetSpecialValueFor("point_blank_dmg_bonus_pct")/100
    local point_blank_knock_back = self:GetSpecialValueFor("point_blank_knock_back")

    local debuff_duration = self:GetSpecialValueFor("debuff_duration")

    local talentDamage = caster:FindTalentValue("special_bonus_unique_snapfire_scatterblast_2", "damage")/100
    if hTarget ~= nil then
		local pointBlank = CalculateDistance(hTarget, caster) <= point_blank_range
		if table.name == "majorblast" and hTarget:TriggerSpellAbsorb( self ) then return end
        EmitSoundOn("Hero_Snapfire.Shotgun.Target ", hTarget)


        if pointBlank then
            ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_impact.vpcf", PATTACH_ABSORIGIN, hTarget, {})
            damage = damage * point_blank_dmg_bonus_pct + damage
            debuff_duration = debuff_duration * point_blank_dmg_bonus_pct + debuff_duration

            -- if table.name == "majorblast" then
                -- hTarget:ApplyKnockBack(vLocation, 0.1, 0.1, point_blank_knock_back, 0, caster, self, true)
            -- end
        end

        if table.name == "minorblast" then
            damage = damage * talentDamage
        end

        if caster:HasTalent("special_bonus_unique_snapfire_scatterblast_1") then
            local disarm_duration = caster:FindTalentValue("special_bonus_unique_snapfire_scatterblast_1")
			if pointBlank then
				disarm_duration = disarm_duration * point_blank_dmg_bonus_pct + disarm_duration
			end
            hTarget:AddNewModifier(caster, self, "modifier_snapfire_scatterblast_bh_disarm", {Duration = disarm_duration})
        end

        self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
        hTarget:AddNewModifier(caster, self, "modifier_snapfire_scatterblast_bh_slow", {Duration = debuff_duration})
    end
end

modifier_snapfire_scatterblast_bh_slow = class({})
LinkLuaModifier("modifier_snapfire_scatterblast_bh_slow", "heroes/hero_snapfire/snapfire_scatterblast_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_snapfire_scatterblast_bh_slow:OnCreated(table)
	self:OnRefresh()
end

function modifier_snapfire_scatterblast_bh_slow:OnRefresh(table)
    self.slow = -self:GetSpecialValueFor("slow_pct")

    if IsServer() then
        ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_slow.vpcf", PATTACH_ABSORIGIN, self:GetParent(), {})
    end
end

function modifier_snapfire_scatterblast_bh_slow:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
    return funcs
end

function modifier_snapfire_scatterblast_bh_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_snapfire_scatterblast_bh_slow:GetModifierAttackSpeedBonus_Constant()
    return self.slow
end

function modifier_snapfire_scatterblast_bh_slow:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_debuff.vpcf"
end

function modifier_snapfire_scatterblast_bh_slow:IsPurgable()
    return true
end

function modifier_snapfire_scatterblast_bh_slow:IsDebuff()
    return true
end

modifier_snapfire_scatterblast_bh_talent = class({})
LinkLuaModifier("modifier_snapfire_scatterblast_bh_talent", "heroes/hero_snapfire/snapfire_scatterblast_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_snapfire_scatterblast_bh_talent:OnCreated(table)
    if IsServer() then 
        local parent = self:GetParent()

        self.chance = parent:FindTalentValue("special_bonus_unique_snapfire_scatterblast_2", "chance")
        self.distance = self:GetAbility():GetTrueCastRange()
        self.start_width = self:GetSpecialValueFor("blast_width_initial")
        self.end_width = self:GetSpecialValueFor("blast_width_end")
        self.speed = self:GetSpecialValueFor("blast_speed")

        self:StartIntervalThink(1)
    end
end

function modifier_snapfire_scatterblast_bh_talent:OnIntervalThink()
    self.chance = self:GetParent():FindTalentValue("special_bonus_unique_snapfire_scatterblast_2", "chance")
end

function modifier_snapfire_scatterblast_bh_talent:DeclareFunctions()
    local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end

function modifier_snapfire_scatterblast_bh_talent:OnAttackLanded(params)
    if IsServer() then
        local parent = self:GetParent()
        local attacker = params.attacker
        local target = params.target

        if parent:HasTalent("special_bonus_unique_snapfire_scatterblast_2") then
            if target and target ~= attacker and target:GetTeam() ~= attacker:GetTeam()
             and attacker == parent then
                local direction = CalculateDirection(target, attacker)
                local velocity = direction * self.speed

                if RollPRNGFormula( attacker, self.chance ) then
                    EmitSoundOn("Hero_Snapfire.Shotgun.Fire", parent)

                    self:GetAbility():FireLinearProjectile("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", velocity, self.distance, self.start_width, {width_end = self.end_width, extraData = {name = "minorblast"}}, false, false, 0)
                end
            end
        end
    end
end

function modifier_snapfire_scatterblast_bh_talent:IsPurgable()
    return false
end

function modifier_snapfire_scatterblast_bh_talent:IsDebuff()
    return false
end

function modifier_snapfire_scatterblast_bh_talent:IsHidden()
    return true
end

modifier_snapfire_scatterblast_bh_disarm = class({})
LinkLuaModifier("modifier_snapfire_scatterblast_bh_disarm", "heroes/hero_snapfire/snapfire_scatterblast_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_snapfire_scatterblast_bh_disarm:CheckState()
    return {[MODIFIER_STATE_DISARMED] = true }
end

function modifier_snapfire_scatterblast_bh_disarm:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_disarm.vpcf"
end

function modifier_snapfire_scatterblast_bh_disarm:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_snapfire_scatterblast_bh_disarm:IsPurgable()
    return true
end

function modifier_snapfire_scatterblast_bh_disarm:IsDebuff()
    return true
end