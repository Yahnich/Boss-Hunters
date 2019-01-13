elite_pulsar = class({})

function elite_pulsar:GetIntrinsicModifierName()
	return "modifier_elite_pulsar"
end

modifier_elite_pulsar = class(relicBaseClass)
LinkLuaModifier("modifier_elite_pulsar", "elites/elite_pulsar", LUA_MODIFIER_MOTION_NONE)
function modifier_elite_pulsar:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_elite_pulsar:OnDeath(params)
	if params.unit == self:GetParent() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		
		local radius = self:GetSpecialValueFor("radius")
		local delay = self:GetSpecialValueFor("delay")
		local damage = self:GetSpecialValueFor("max_hp_dmg")
		
		local position = caster:GetAbsOrigin()
		
		ParticleManager:FireWarningParticle(position, radius)
		
		ParticleManager:FireParticle("particles/units/heroes/hero_pugna/pugna_netherblast_pre.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector(radius,delay,delay)})
		ParticleManager:FireParticle("particles/bosses/boss_green_dragon/boss_green_dragon_explosion_prep.vpcf", PATTACH_POINT_FOLLOW, caster)
		Timers:CreateTimer(delay, function()
			ParticleManager:FireParticle("particles/bosses/boss_green_dragon/boss_green_dragon_rot_explosion.vpcf", PATTACH_POINT_FOLLOW, caster)
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
				ability:DealDamage( caster, enemy, enemy:GetMaxHealth() * damage, {damage_type = DAMAGE_TYPE_PHYSICAL} )
			end
		end)
	end
end