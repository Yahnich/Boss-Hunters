boss_ogre_smash_king = class({})

function boss_ogre_smash_king:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( GetGroundPosition(self:GetCursorPosition(), self:GetCaster()), self:GetSpecialValueFor("radius"))
	return true
end

function boss_ogre_smash_king:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")

	EmitSoundOnLocationWithCaster(point, "Ability.MeleeSmashLand", caster)
	ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_POINT, caster, {[0]=point, [1]=Vector(radius, 0, 0)})

	CutTreesInRadius(point, radius)

	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:Stun(enemy, self:GetSpecialValueFor("duration"), false)
			self:DealDamage(caster, enemy, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end