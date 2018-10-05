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
			if target:TriggerSpellAbsorb(self) then return false end
			EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Impact", target)
			ability:Stun( target, ability:GetSpecialValueFor("stun_duration") )
		end
		local expRadius = ability:GetSpecialValueFor("explosion_radius") 
		ParticleManager:FireWarningParticle( target:GetAbsOrigin(), expRadius )
		Timers:CreateTimer( 0.5, function()
			local damage = ability:GetSpecialValueFor("damage")
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, expRadius ) do
				ability:DealDamage( caster, enemy, damage )
			end
		end)
		return false
	end
	caster:EmitSound("Hero_SkywrathMage.ArcaneBolt.Cast")
	ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = "skywrath_mage_arcane_bolt.vpcf",
																		  position = caster:GetAbsOrigin(),
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = radius,
																		  velocity = speed * direction,
																		  distance = distance })
end