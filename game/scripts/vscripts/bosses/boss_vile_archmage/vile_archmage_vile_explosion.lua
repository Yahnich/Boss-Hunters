vile_archmage_vile_explosion = class({})

function vile_archmage_vile_explosion:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("radius") )
	return true
end

function vile_archmage_vile_explosion:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local delay = self:GetSpecialValueFor("delay")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	
	EmitSoundOnLocationWithCaster(position, "Hero_Pugna.NetherBlastPreCast", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_pugna/pugna_netherblast_pre.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
	Timers:CreateTimer(delay, function()
		ParticleManager:FireParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
		EmitSoundOnLocationWithCaster(position, "Hero_Pugna.NetherBlast", caster)
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			self:DealDamage( caster, enemy, damage )
		end
	end)
end