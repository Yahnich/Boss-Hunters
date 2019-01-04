omniknight_purification_bh = class({})

function omniknight_purification_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("search_radius")
end

function omniknight_purification_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local damage = self:GetTalentSpecialValueFor("damage")
	local heal = self:GetTalentSpecialValueFor("heal")
	local search = self:GetTalentSpecialValueFor("search_radius")
	local radius = self:GetTalentSpecialValueFor("area_of_effect")
	
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( target, search) ) do
		ally:HealEvent(heal, self, caster )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( ally:GetAbsOrigin(), radius) ) do
			self:DealDamage(caster, enemy, damage)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_POINT_FOLLOW, ally, enemy)
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT_FOLLOW, ally, {[1] = Vector(radius, 0, 0), [2] = caster:GetAbsOrigin()})
	end
	EmitSoundOnLocationWithCaster(target, "Hero_Omniknight.Purification", caster)
end