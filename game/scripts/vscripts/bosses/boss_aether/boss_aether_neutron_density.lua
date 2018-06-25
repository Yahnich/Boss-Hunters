boss_aether_neutron_density = class({})

function boss_aether_neutron_density:GetIntrinsicModifierName()
	return "modifier_boss_aether_neutron_density_passive"
end

function boss_aether_neutron_density:LaunchOrb(position)
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("orb_radius")
	local speed = self:GetTalentSpecialValueFor("orb_speed")
	local velocity = CalculateDirection( position, caster ) * speed
	local distance = CalculateDistance(position, caster )
	ParticleManager:FireWarningParticle(position, radius)
	self:FireLinearProjectile("particles/units/heroes/hero_puck/puck_illusory_orb.vpcf", velocity, distance, radius)
end

function boss_aether_neutron_density:OnProjectileHit(target, position)
	local radius = self:GetTalentSpecialValueFor("orb_radius")
	local damage = self:GetTalentSpecialValueFor("magic_damage")
	local stun = self:GetTalentSpecialValueFor("stun_duration")
	if target then
		self:DealDamage(caster, target, damage)
	elseif not target then
		local caster = self:GetCaster()
		
		
		local enemies = caster:FindEnemyUnitsInRadius(position, radius)
		for _, enemy in ipairs( enemies ) do
			self:DealDamage(caster, enemy, damage)
			self:Stun(enemy, stun, false)
		end
		
		ParticleManager:FireParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius, 0, 0)})
	end
end

modifier_boss_aether_neutron_density_passive = class({})
LinkLuaModifier("modifier_boss_aether_neutron_density_passive", "bosses/boss_aether/boss_aether_neutron_density", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_neutron_density_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START}
end

function modifier_boss_aether_neutron_density_passive:IsHidden()
	return true
end

function modifier_boss_aether_neutron_density_passive:OnAttackStart( params )
	if params.attacker == self:GetParent() and params.target and self:GetAbility():IsCooldownReady() then
		self:GetAbility():LaunchOrb( params.target:GetAbsOrigin() )
		self:GetAbility():SetCooldown()
	end
end