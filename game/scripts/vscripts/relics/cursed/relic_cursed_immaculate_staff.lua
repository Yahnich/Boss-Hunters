relic_cursed_immaculate_staff = class(relicBaseClass)

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