boss_golem_golem_smash = class({})

function boss_golem_golem_smash:OnAbilityPhaseStart()
	local radius = math.max( 175, math.min( self:GetSpecialValueFor("base_radius"), self:GetSpecialValueFor("base_radius") * self:GetCaster():GetModelScale() / 1.8 ) )
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), radius )
	return true
end

function boss_golem_golem_smash:OnSpellStart()
	local caster = self:GetCaster()
	
	local damage = math.max( 75, math.min( self:GetSpecialValueFor("base_damage"), self:GetSpecialValueFor("base_damage") * caster:GetModelScale() / 1.8 ) )
	local radius = math.max( 175, math.min( self:GetSpecialValueFor("base_radius"), self:GetSpecialValueFor("base_radius") * caster:GetModelScale() / 1.8 ) )
	ParticleManager:FireParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius, 1, 1)})
	EmitSoundOn("Ability.TossImpact", caster)
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, enemy, damage)
		end
	end
end

