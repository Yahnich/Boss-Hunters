centaur_warchiefs_aegis = class({})

function centaur_warchiefs_aegis:GetIntrinsicModifierName()
	return "modifier_centaur_warchiefs_aegis_passive"
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
	return self:GetParent():FindTalentValue("special_bonus_unique_centaur_warchiefs_aegis_1")
end

function modifier_centaur_warchiefs_aegis_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_centaur_warchiefs_aegis_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

modifier_centaur_warchiefs_aegis_return = class({})
LinkLuaModifier("modifier_centaur_warchiefs_aegis_return", "heroes/hero_centaur/centaur_warchiefs_aegis", LUA_MODIFIER_MOTION_NONE)

function modifier_centaur_warchiefs_aegis_return:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("level_damage")
	self.str_bonus = self:GetTalentSpecialValueFor("bonus_strength")
end

function modifier_centaur_warchiefs_aegis_return:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("level_damage")
	self.str_bonus = self:GetTalentSpecialValueFor("bonus_strength")
end

function modifier_centaur_warchiefs_aegis_return:ProcReturn(target)
	if not target:IsSameTeam( self:GetCaster() ) then
		local damage = self.damage * self:GetCaster():GetLevel()
		self:GetAbility():DealDamage( self:GetCaster(), target, damage, {damage_flags = DOTA_DAMAGE_FLAG_REFLECTION})
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), target)
	end
end
function modifier_centaur_warchiefs_aegis_return:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ATTACK_FAIL}
end

function modifier_centaur_warchiefs_aegis_return:OnTakeDamage( params )
	if params.unit == self:GetParent() then
		if not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
			self:ProcReturn(params.attacker)
		end
	end
end

function modifier_centaur_warchiefs_aegis_return:OnAttackFail(params)
	if params.unit == self:GetParent() then
		self:ProcReturn(params.attacker)
	end
end

function modifier_centaur_warchiefs_aegis_return:GetModifierStrengthBonusPercentage(params)
	return self.str_bonus
end