centaur_warchiefs_aegis = class({})

function centaur_warchiefs_aegis:GetIntrinsicModifierName()
	return "modifier_centaur_warchiefs_aegis_passive"
end

function centaur_warchiefs_aegis:ProcReturn(target, damage)
	local caster = self:GetCaster()
	local fDmg = damage or self:GetTalentSpecialValueFor("level_damage") * caster:GetLevel()
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT_FOLLOW, caster, target)
	return self:DealDamage( caster, target, fDmg, {damage_flags = DOTA_DAMAGE_FLAG_REFLECTION})
end

modifier_centaur_warchiefs_aegis_passive = class({})
LinkLuaModifier("modifier_centaur_warchiefs_aegis_passive", "heroes/hero_centaur/centaur_warchiefs_aegis", LUA_MODIFIER_MOTION_NONE)

function modifier_centaur_warchiefs_aegis_passive:IsHidden()
	return true
end

function modifier_centaur_warchiefs_aegis_passive:IsAura()
	return true
end

function modifier_centaur_warchiefs_aegis_passive:GetModifierAura()
	return "modifier_centaur_warchiefs_aegis_return"
end

function modifier_centaur_warchiefs_aegis_passive:GetAuraRadius()
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("scepter_radius")
	else
		return 0
	end
end

function modifier_centaur_warchiefs_aegis_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_centaur_warchiefs_aegis_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_centaur_warchiefs_aegis_passive:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

modifier_centaur_warchiefs_aegis_return = class({})
LinkLuaModifier("modifier_centaur_warchiefs_aegis_return", "heroes/hero_centaur/centaur_warchiefs_aegis", LUA_MODIFIER_MOTION_NONE)

function modifier_centaur_warchiefs_aegis_return:OnCreated()
	self:OnRefresh()
end

function modifier_centaur_warchiefs_aegis_return:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("level_damage")
	self.str_bonus = self:GetTalentSpecialValueFor("bonus_strength")
	self:GetParent():HookInModifier("GetModifierStrengthBonusPercentage", self)
	self:GetParent():HookInModifier("GetModifierDamageReflectBonus", self)
end

function modifier_centaur_warchiefs_aegis_return:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierStrengthBonusPercentage", self)
	self:GetParent():HookOutModifier("GetModifierDamageReflectBonus", self)
end

function modifier_centaur_warchiefs_aegis_return:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_FAIL }
end

function modifier_centaur_warchiefs_aegis_return:GetModifierDamageReflectBonus(params)
	if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK  or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) then
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT_FOLLOW, params.unit, params.attacker)
		return self.damage * self:GetParent():GetLevel()
	end
end

function modifier_centaur_warchiefs_aegis_return:OnAttackFail(params)
	if params.target == self:GetParent() then
		self:GetAbility():ProcReturn( params.attacker, self.damage )
	end
end

function modifier_centaur_warchiefs_aegis_return:GetModifierStrengthBonusPercentage(params)
	return self.str_bonus
end