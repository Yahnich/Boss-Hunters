relic_cursed_immaculate_staff = class({})

function relic_cursed_immaculate_staff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_SPENT_MANA}
end

function relic_cursed_immaculate_staff:OnSpentMana(params)
	if params.unit == self:GetParent() then
		ParticleManager:FireParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ApplyDamage({victim = params.unit, attacker = params.unit, damage = params.cost * 0.75, ability = params.ability, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS})
	end
end

function relic_cursed_immaculate_staff:GetCooldownReduction()
	return 40
end

function relic_cursed_immaculate_staff:IsHidden()
	return true
end

function relic_cursed_immaculate_staff:IsPurgable()
	return false
end

function relic_cursed_immaculate_staff:RemoveOnDeath()
	return false
end

function relic_cursed_immaculate_staff:IsPermanent()
	return true
end

function relic_cursed_immaculate_staff:AllowIllusionDuplicate()
	return true
end

function relic_cursed_immaculate_staff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end