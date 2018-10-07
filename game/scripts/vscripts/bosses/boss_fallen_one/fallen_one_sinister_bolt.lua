fallen_one_sinister_bolt = class({})

function fallen_one_sinister_bolt:OnAbilityPhaseStart()
	local startPos = self:GetCaster():GetAbsOrigin()
	local endPos = startPos + CalculateDirection( self:GetCursorPosition(), startPos ) * self:GetSpecialValueFor("distance")
	ParticleManager:FireLinearWarningParticle( startPos, endPos, self:GetSpecialValueFor("radius") * 2 )
	return true
end

function fallen_one_sinister_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local direction = CalculateDirection( target, caster )
	local distance = self:GetSpecialValueFor("distance")
	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if target then
			if target:TriggerSpellAbsorb(ability) then return false end
			EmitSoundOn("Hero_VengefulSpirit.MagicMissileImpact", target)
			ability:Stun( target, ability:GetSpecialValueFor("stun_duration") )
		end
		local expRadius = ability:GetSpecialValueFor("explosion_radius") 
		ParticleManager:FireWarningParticle( position, expRadius )
		Timers:CreateTimer( 0.5, function()
			ParticleManager:FireParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(expRadius,1,1)})
			local damage = ability:GetSpecialValueFor("damage")
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, expRadius ) ) do
				if not enemy:TriggerSpellAbsorb(ability) then
					ability:DealDamage( caster, enemy, damage )
				end
			end
		end)
		return false
	end
	caster:EmitSound(""Hero_VengefulSpirit.MagicMissile"")
	ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf",
																		  position = caster:GetAbsOriginCenter(),
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = radius,
																		  velocity = speed * direction,
																		  distance = distance })
end