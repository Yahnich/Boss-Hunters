boss_ifdat_incinerate = class({})

function boss_ifdat_incinerate:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	ParticleManager:FireRopeParticle("particles/lina_lagunarok_blade.vpcf", PATTACH_POINT_FOLLOW, caster, target )
	local stacks = self:GetSpecialValueFor("stacks_applied")
	local overTime = 0.3
	local tick = overTime / stacks
	caster:EmitSound( "Ability.LagunaBlade" )
	Timers:CreateTimer( tick, function()
		self:DealDamage( caster, target, 1, {damage_type = DAMAGE_TYPE_PURE})
		stacks = stacks - 1
		if stacks > 0 then
			return tick
		else
			target:EmitSound( "Ability.LagunaBladeImpact" )
		end
	end)
end