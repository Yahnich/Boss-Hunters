relic_cursed_immaculate_staff = class(relicBaseClass)

function relic_cursed_immaculate_staff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_SPENT_MANA}
end

function relic_cursed_immaculate_staff:OnSpentMana(params)
	if params.unit == self:GetParent() and not self:GetParent():HasModifier("relic_unique_ritual_candle") then
		ParticleManager:FireParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ApplyDamage({victim = params.unit, attacker = params.unit, damage = params.cost * 0.75, ability = params.ability, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL})
	end
end

function relic_cursed_immaculate_staff:GetCooldownReduction()
	return 40
end