boss_leshrac_erupt = class({})

function boss_leshrac_erupt:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("impact_radius") )
	return true
end

function boss_leshrac_erupt:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local damage = self:GetSpecialValueFor("damage")
	local delay = self:GetCastPoint()
	local stun = self:GetSpecialValueFor("duration_stun")
	local radius = self:GetSpecialValueFor("impact_radius")
	local eruptions = self:GetSpecialValueFor("eruptions")
	
	Timers:CreateTimer( function()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			self:DealDamage( caster, enemy, damage )
			self:Stun(enemy, stun)
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_CUSTOMORIGIN, caster, {[0] = position, [1] = Vector( radius,1,1) } )
		EmitSoundOnLocationWithCaster( position, "Hero_Leshrac.Split_Earth", caster )
		eruptions = eruptions - 1
		if eruptions > 0 then
			return delay
		end
	end)
end