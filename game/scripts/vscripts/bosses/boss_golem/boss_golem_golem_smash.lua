boss_golem_golem_smash = class({})

function boss_golem_golem_smash:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("base_radius") * self:GetCaster():GetModelScale() )
	return true
end

function boss_golem_golem_smash:OnSpellStart()
	local caster = self:GetCaster()
	
	local damage = self:GetSpecialValueFor("base_damage") * caster:GetModelScale()
	local radius = self:GetSpecialValueFor("base_radius") * caster:GetModelScale()
	ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius, 1, 1)})
	EmitSoundOn("Ability.TossImpact", caster)
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		self:DealDamage(caster, enemy, damage)
	end
end



