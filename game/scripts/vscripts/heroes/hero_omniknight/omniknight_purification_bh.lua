omniknight_purification_bh = class({})

function omniknight_purification_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("area_of_effect")
end

function omniknight_purification_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local damage = self:GetTalentSpecialValueFor("damage")
	local heal = self:GetTalentSpecialValueFor("heal")
	local radius = self:GetTalentSpecialValueFor("area_of_effect")
	
	if caster:IsSameTeam(target) then
		target:HealEvent(heal, self, caster )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius) ) do
			self:DealDamage(caster, enemy, damage)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_POINT_FOLLOW, target, enemy)
		end
	else
		self:DealDamage(caster, target, damage)
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), radius) ) do
			ally:HealEvent(heal, self, caster )
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_POINT_FOLLOW, target, ally)
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT_FOLLOW, target, {[1] = Vector(radius, 0, 0), [2] = caster:GetAbsOrigin()})
	EmitSoundOn("Hero_Omniknight.Purification", target)
end