boss_genesis_crumple = class({})

function boss_genesis_crumple:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_genesis_crumple:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local damage = caster:GetAttackDamage() * self:GetSpecialValueFor("damage") / 100
	local stunDur = self:GetSpecialValueFor("stun")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage( caster, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
			self:Stun( enemy, stunDur )
		end
	end
	ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius, 1, 1) })
	EmitSoundOnLocationWithCaster(position, "Hero_Leshrac.Split_Earth", caster)
end