boss4_death_ball = class({})

function boss4_death_ball:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetAbsOrigin()
	local direction = CalculateDirection(self:GetCursorPosition(), casterPos)
	ParticleManager:FireLinearWarningParticle(casterPos, casterPos + direction * self:GetSpecialValueFor("distance"), self:GetSpecialValueFor("radius"))
	EmitSoundOn("Hero_Undying.SoulRip.Cast", caster)
	return true
end

function boss4_death_ball:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Undying.SoulRip.Cast", caster)
end

function boss4_death_ball:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	
	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local distance = self:GetSpecialValueFor("distance")
	local damageUnit = self:GetSpecialValueFor("damage_per_unit")
	local maxUnits = self:GetSpecialValueFor("max_units")
	local totalUnits = 0
	local damage = 0
	
	EmitSoundOn("Hero_Undying.SoulRip.Ally", caster)
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("search_radius") ) ) do
		if totalUnits <= maxUnits then
			damage = damage + damageUnit
			totalUnits = totalUnits + 1
		end
		self:DealDamage(caster, ally, damageUnit, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_POINT_FOLLOW, caster, ally)
	end
	
	local ProjectileHit = function(self, target, position)
		if target then
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			if not self.hitUnits[target:entindex()] then
				if target:TriggerSpellAbsorb(ability) then return false end
				ability:DealDamage(caster, target, self.damage)
				caster:HealEvent(self.damage, ability, caster)
				EmitSoundOn("Hero_Undying.PreAttack", caster)
				ParticleManager:FireParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT_FOLLOW, target)
				self.hitUnits[target:entindex()] = true
			end
		end
		return true
	end
	ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = "particles/bosses/boss4/boss4_death_ball.vpcf",
																		  position = caster:GetAbsOrigin() + Vector(0,0,200),
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = radius,
																		  velocity = speed * direction,
																		  distance = distance,
																		  hitUnits = {},
																		  damage = damage})
end