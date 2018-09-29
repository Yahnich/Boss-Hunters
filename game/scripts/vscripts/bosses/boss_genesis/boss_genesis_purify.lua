boss_genesis_purify = class({})

function boss_genesis_purify:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_genesis_purify:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	if not target:TriggerSpellAbsorb(self) then return end
	target:Dispel(caster, true)
	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf", PATTACH_POINT_FOLLOW, target)
	target:EmitSound("Hero_Omniknight.Purification")
end