mirana_astral_arrow = class({})

function mirana_astral_arrow:IsStealable()
    return true
end

function mirana_astral_arrow:IsHiddenWhenStolen()
    return false
end

function mirana_astral_arrow:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local casterPos = caster:GetAbsOrigin()

    local direction = CalculateDirection(point, caster:GetAbsOrigin())
    local speed = 857

    EmitSoundOn("Hero_Mirana.ArrowCast", caster)

    self:FireLinearProjectile("particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf", direction*speed, self:GetTrueCastRange(), 96, {}, false, true, 500)
    
    if caster:HasScepter() then
        local spawn_point = casterPos + direction * self:GetTrueCastRange() 

        -- Set QAngles
        local left_QAngle = QAngle(0, 20, 0)
        local right_QAngle = QAngle(0, -20, 0)

        -- Left arrow variables
        local left_spawn_point = RotatePosition(caster:GetAbsOrigin(), left_QAngle, spawn_point)
        local left_direction = (left_spawn_point - caster:GetAbsOrigin()):Normalized()                

        -- Right arrow variables
        local right_spawn_point = RotatePosition(caster:GetAbsOrigin(), right_QAngle, spawn_point)
        local right_direction = (right_spawn_point - caster:GetAbsOrigin()):Normalized()

        self:FireLinearProjectile("particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf", right_direction*speed, self:GetTrueCastRange(), 96, {}, false, true, 500)
        self:FireLinearProjectile("particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf", left_direction*speed, self:GetTrueCastRange(), 96, {}, false, true, 500)
    end
	if caster:HasTalent("special_bonus_unique_mirana_astral_arrow_3") then
		caster:AddNewModifier( caster, self, "modifier_mirana_astral_arrow_talent", {} )
	end
end

function mirana_astral_arrow:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    local damage = self:GetTalentSpecialValueFor("damage")
    if hTarget ~= nil and not hTarget:TriggerSpellAbsorb(self) then
        if not hTarget:IsMinion() then EmitSoundOn("Hero_Mirana.ArrowImpact", hTarget) end

        self:DealDamage(caster, hTarget, damage, {}, 0)
        self:Stun(hTarget, self:GetTalentSpecialValueFor("duration"), false)
		return not hTarget:IsMinion()
    end
end

modifier_mirana_astral_arrow_talent = class({})
LinkLuaModifier("modifier_mirana_astral_arrow_talent", "heroes/hero_mirana/mirana_astral_arrow", LUA_MODIFIER_MOTION_NONE)

function modifier_mirana_astral_arrow_talent:OnCreated()
	self.damage_bonus = self:GetCaster():FindTalentValue("special_bonus_unique_mirana_astral_arrow_3")
end

function modifier_mirana_astral_arrow_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_mirana_astral_arrow_talent:GetModifierDamageOutgoing_Percentage(params)
	if IsServer() and params.attacker then
		self:Destroy()
	end
	return self.damage_bonus
end