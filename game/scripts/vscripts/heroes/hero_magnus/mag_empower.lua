mag_empower = class({})
LinkLuaModifier( "modifier_mag_empower", "heroes/hero_magnus/mag_empower.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mag_empower_effect", "heroes/hero_magnus/mag_empower.lua" ,LUA_MODIFIER_MOTION_NONE )

function mag_empower:GetIntrinsicModifierName()
	return "modifier_mag_empower"
end

modifier_mag_empower = class({})
function modifier_mag_empower:IsAura()
    return true
end

function modifier_mag_empower:GetAuraDuration()
    return 0.5
end

function modifier_mag_empower:GetAuraRadius()
    return self:GetSpecialValueFor("aura_radius")
end

function modifier_mag_empower:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_mag_empower:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mag_empower:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_mag_empower:GetModifierAura()
    return "modifier_mag_empower_effect"
end

function modifier_mag_empower:IsAuraActiveOnDeath()
    return false
end

function modifier_mag_empower:IsHidden()
    return true
end

modifier_mag_empower_effect = class({})
function modifier_mag_empower_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_mag_empower_effect:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetSpecialValueFor("bonus_damage")
end

function modifier_mag_empower_effect:OnAttackLanded(params)
    if params.attacker == self:GetParent() and params.target:IsAlive() then
    	ParticleManager:FireParticle("particles/units/heroes/hero_magnataur/magnataur_empower_cleave_effect.vpcf", PATTACH_POINT, params.target, {[0]=params.target:GetAbsOrigin()})
    	local enemies = params.attacker:FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), self:GetSpecialValueFor("cleave_radius"))
    	for _,enemy in pairs(enemies) do
    		if enemy ~= params.target then
    			local damage = params.damage*self:GetSpecialValueFor("cleave_damage")/100
    			self:GetAbility():DealDamage(params.attacker, enemy, damage, {damage_type = DAMAGE_TYPE_PURE}, 0)
    		end
    	end
    end
end

function modifier_mag_empower_effect:GetEffectName()
    return "particles/units/heroes/hero_magnataur/magnataur_empower.vpcf"
end