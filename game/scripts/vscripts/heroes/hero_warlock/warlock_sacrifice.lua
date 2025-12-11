warlock_sacrifice = class({})
LinkLuaModifier("modifier_warlock_sacrifice_imp", "heroes/hero_warlock/warlock_sacrifice", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warlock_sacrifice_golem", "heroes/hero_warlock/warlock_sacrifice", LUA_MODIFIER_MOTION_NONE)

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
		caster:AddNewModifier(caster, self, "modifier_warlock_sacrifice_imp", {Duration = self:GetTalentSpecialValueFor("duration")})
	elseif target:GetUnitName() == "npc_dota_warlock_golem_1" then
		caster:AddNewModifier(caster, self, "modifier_warlock_sacrifice_golem", {Duration = self:GetTalentSpecialValueFor("duration")})
	end
	
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_sacrifice.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
		ParticleManager:ReleaseParticleIndex(nfx)
	EmitSoundOn("Ability.DarkRitual", caster)
	
	if caster:HasTalent("special_bonus_unique_warlock_sacrifice_2") then
		ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, target, {})
		local damage = caster:GetIntellect( false) * caster:FindTalentValue("special_bonus_unique_warlock_sacrifice_2", "damage")/100
		if target:GetUnitName() == "npc_dota_warlock_golem_1" then
			damage = damage * caster:FindTalentValue("special_bonus_unique_warlock_sacrifice_2", "golem_mult")
		end
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_warlock_sacrifice_2", "radius"), {})
		for _,enemy in pairs(enemies) do
			self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end

	if caster:HasTalent("special_bonus_unique_warlock_sacrifice_1") then
		self:DealDamage( caster, target, target:GetHealth() * caster:FindTalentValue("special_bonus_unique_warlock_sacrifice_1"), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS} )
	else
		target:ForceKill(false)
	end
end

modifier_warlock_sacrifice_imp = class({})

function modifier_warlock_sacrifice_imp:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return funcs
end

function modifier_warlock_sacrifice_imp:GetModifierSpellAmplify_Percentage()
    return self:GetTalentSpecialValueFor("spell_amp")
end

function modifier_warlock_sacrifice_imp:GetModifierConstantHealthRegen()
    return self:GetTalentSpecialValueFor("health_regen")
end

function modifier_warlock_sacrifice_imp:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end


modifier_warlock_sacrifice_golem = class({})

function modifier_warlock_sacrifice_golem:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
    }
    return funcs
end

function modifier_warlock_sacrifice_golem:GetModifierSpellAmplify_Percentage()
    return self:GetTalentSpecialValueFor("spell_amp")
end

function modifier_warlock_sacrifice_golem:GetModifierConstantHealthRegen()
    return self:GetTalentSpecialValueFor("golem_health_regen")
end

function modifier_warlock_sacrifice_golem:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetTalentSpecialValueFor("golem_bonus_damage")
end

function modifier_warlock_sacrifice_golem:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end