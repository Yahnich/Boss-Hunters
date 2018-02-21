mirana_astral_arrow = class({})

function mirana_astral_arrow:IsStealable()
    return true
end

function mirana_astral_arrow:IsHiddenWhenStolen()
    return false
end

function mirana_astral_arrow:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_mirana_astral_arrow_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_mirana_astral_arrow_2") end
    return cooldown
end

function mirana_astral_arrow:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local casterPos = caster:GetAbsOrigin()

    local direction = CalculateDirection(point, caster:GetAbsOrigin())
    local speed = 857

    EmitSoundOn("Hero_Mirana.ArrowCast", caster)

    self:FireLinearProjectile("particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf", direction*speed, self:GetTrueCastRange(), 96, {}, false, true, 500)
    
    if caster:HasTalent("special_bonus_unique_mirana_astral_arrow_1") then
        local spawn_point = casterPos + direction * self:GetTrueCastRange() 

        -- Set QAngles
        local left_QAngle = QAngle(0, 30, 0)
        local right_QAngle = QAngle(0, -30, 0)

        -- Left arrow variables
        local left_spawn_point = RotatePosition(caster:GetAbsOrigin(), left_QAngle, spawn_point)
        local left_direction = (left_spawn_point - caster:GetAbsOrigin()):Normalized()                

        -- Right arrow variables
        local right_spawn_point = RotatePosition(caster:GetAbsOrigin(), right_QAngle, spawn_point)
        local right_direction = (right_spawn_point - caster:GetAbsOrigin()):Normalized()

        self:FireLinearProjectile("particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf", right_direction*speed, self:GetTrueCastRange(), 96, {}, false, true, 500)
        self:FireLinearProjectile("particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf", left_direction*speed, self:GetTrueCastRange(), 96, {}, false, true, 500)
    end
end

function mirana_astral_arrow:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    local damage = self:GetTalentSpecialValueFor("damage")
    local agi_damage = self:GetTalentSpecialValueFor("agi_damage")/100

    damage = damage + caster:GetAgility() * agi_damage
    if hTarget ~= nil then
        --EmitSoundOn("Hero_Mirana.ArrowImpact", hTarget)

        self:DealDamage(caster, hTarget, damage, {}, 0)
        self:Stun(hTarget, self:GetTalentSpecialValueFor("duration"), false)
    end
end