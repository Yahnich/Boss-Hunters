mag_polarity = class({})
LinkLuaModifier( "modifier_mag_polarity", "heroes/hero_magnus/mag_polarity.lua" ,LUA_MODIFIER_MOTION_NONE )

function mag_polarity:IsStealable()
    return true
end

function mag_polarity:IsHiddenWhenStolen()
    return false
end

function mag_polarity:OnAbilityPhaseStart()
    EmitSoundOn("Hero_Magnataur.ReversePolarity.Anim", self:GetCaster())
    return true
end

function mag_polarity:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")

    EmitSoundOn("Hero_Magnataur.ReversePolarity.Cast", self:GetCaster())

    ParticleManager:FireParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf", PATTACH_POINT, caster, {[0]=Vector(1,0,0), [1]=Vector(radius,radius,radius), [2]=Vector(0.3,0,0), [3]=caster:GetAbsOrigin() + caster:GetForwardVector()*200})
	local magnets = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), radius)
    for _,magnet in pairs(magnets) do
        if magnet:HasModifier("modifier_mag_magnet") then
            radius = radius + self:GetSpecialValueFor("radius_magnet")
            damage = damage + self:GetSpecialValueFor("damage_magnet")
        end
    end

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
    for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity_pull.vpcf", PATTACH_POINT, caster, enemy, {[0]=caster:GetAbsOrigin() + caster:GetForwardVector()*200, [1]=enemy:GetAbsOrigin()})

			EmitSoundOn("Hero_Magnataur.ReversePolarity.Cast", enemy)
			FindClearSpaceForUnit(enemy, GetGroundPosition(caster:GetAbsOrigin(), caster) + caster:GetForwardVector()*200, true)
			self:Stun(enemy, self:GetSpecialValueFor("stun_duration"), false)
			self:DealDamage(caster, enemy, damage, {}, 0)
		end
    end
end

modifier_mag_polarity = class({})
function modifier_mag_polarity:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

function modifier_mag_polarity:GetModifierIncomingDamage_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_unique_mag_polarity_2")
end