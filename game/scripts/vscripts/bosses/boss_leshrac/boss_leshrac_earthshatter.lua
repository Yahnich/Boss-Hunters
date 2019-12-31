boss_leshrac_earthshatter = class({})

function boss_leshrac_earthshatter:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("impact_radius") )
	return true
end

function boss_leshrac_earthshatter:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local damage = self:GetSpecialValueFor("damage")
	local delay = self:GetCastPoint()
	local stun = self:GetSpecialValueFor("duration_stun")
	local radius = self:GetSpecialValueFor("impact_radius")
	local radiusGrowth = self:GetSpecialValueFor("radius_growth")
	local eruptions = self:GetSpecialValueFor("eruptions")
	
	Timers:CreateTimer( function()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			if not enemy:TriggerSpellAbsorb( self ) then
				damageType = DAMAGE_TYPE_MAGICAL
				if enemy:GetMagicalArmorValue( ) > enemy:GetPhysicalArmorReduction()/100 then
					damageType = DAMAGE_TYPE_PHYSICAL
				end
				self:DealDamage( caster, enemy, damage, {damage_type = damageType} )
				self:Stun(enemy, stun)
			end
		end
		damage = damage * 0.75
		stun = stun * 0.75
		ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_CUSTOMORIGIN, caster, {[0] = position, [1] = Vector( radius,1,1) } )
		EmitSoundOnLocationWithCaster( position, "Hero_Leshrac.Split_Earth", caster )
		eruptions = eruptions - 1
		radius = radius + radiusGrowth
		if eruptions > 0 then
			ParticleManager:FireWarningParticle( position, radius )
			return delay
		end
	end)
end