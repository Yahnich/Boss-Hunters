warlock_sacrifice = class({})

function warlock_sacrifice:IsStealable()
	return false
end

function warlock_sacrifice:IsHiddenWhenStolen()
	return false
end

function warlock_sacrifice:CastFilterResultTarget(target)
	if target:GetUnitName() == "npc_dota_warlock_imp" or target:GetUnitName() == "npc_dota_warlock_golem_1" then
		return UF_SUCCESS
	else
		return UF_FAIL_CUSTOM
	end
end

function warlock_sacrifice:GetCustomCastErrorTarget(target)
	return "Ability can only target Imps or Golems."
end

function warlock_sacrifice:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:GetUnitName() == "npc_dota_warlock_imp" then
		caster:AddNewModifier(caster, self, "modifier_warlock_sacrifice_imp", {Duration = self:GetSpecialValueFor("duration")})
	elseif target:GetUnitName() == "npc_dota_warlock_golem_1" then
		caster:AddNewModifier(caster, self, "modifier_warlock_sacrifice_golem", {Duration = self:GetSpecialValueFor("duration")})
	end
	
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_sacrifice.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
		ParticleManager:ReleaseParticleIndex(nfx)
	EmitSoundOn("Ability.DarkRitual", caster)
	
	local damageRadius = self:GetSpecialValueFor("damage_radius")
	if damageRadius > 0 then
		ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, target, {})
		local damage = caster:GetIntellect( false) * self:GetSpecialValueFor("int_damage")/100
		if target:GetUnitName() == "npc_dota_warlock_golem_1" then
			damage = damage * self:GetSpecialValueFor("golem_multiplier")
		end
		local enemies = caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), damageRadius )
		for _,enemy in pairs(enemies) do
			self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
	
	local sacrifice = self:GetSpecialValueFor("current_health_cost") / 100
	self:DealDamage( caster, target, math.ceil( target:GetHealth() * sacrifice ) + 1, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS} )
end

modifier_warlock_sacrifice_imp = class({})
LinkLuaModifier("modifier_warlock_sacrifice_imp", "heroes/hero_warlock/warlock_sacrifice", LUA_MODIFIER_MOTION_NONE)

function modifier_warlock_sacrifice_imp:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return funcs
end

function modifier_warlock_sacrifice_imp:GetModifierSpellAmplify_Percentage()
    return self:GetSpecialValueFor("spell_amp")
end

function modifier_warlock_sacrifice_imp:GetModifierConstantHealthRegen()
    return self:GetSpecialValueFor("health_regen")
end

function modifier_warlock_sacrifice_imp:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

function modifier_warlock_sacrifice_imp:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_warlock_sacrifice_golem = class(modifier_warlock_sacrifice_imp)
LinkLuaModifier("modifier_warlock_sacrifice_golem", "heroes/hero_warlock/warlock_sacrifice", LUA_MODIFIER_MOTION_NONE)

function modifier_warlock_sacrifice_golem:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

function modifier_warlock_sacrifice_golem:GetModifierConstantHealthRegen()
    return self:GetSpecialValueFor("golem_health_regen")
end

function modifier_warlock_sacrifice_golem:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetSpecialValueFor("golem_bonus_damage")
end