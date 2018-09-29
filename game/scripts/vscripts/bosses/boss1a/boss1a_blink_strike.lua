boss1a_blink_strike = class({})

function boss1a_blink_strike:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetSpecialValueFor("strike_radius"))
	return true
end

function boss1a_blink_strike:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	EmitSoundOn("Hero_Riki.Blink_Strike", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_riki/riki_blink_strike.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = caster:GetAbsOrigin(),[1] = position})
	for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(position, self:GetSpecialValueFor("strike_radius"))) do
		if enemy:TriggerSpellAbsorb(self) then return end
		ParticleManager:FireParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_POINT_FOLLOW, enemy) -- riki blink strike sounds and particles
		caster:PerformGenericAttack(enemy, true)
	end
	FindClearSpaceForUnit(caster, position, true)

	
end