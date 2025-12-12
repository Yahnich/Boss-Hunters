treant_leech_seed_bh = class({})

function treant_leech_seed_bh:GetIntrinsicModifierName()
	return "modifier_treant_leech_seed_bh_handler"
end

function treant_leech_seed_bh:ShouldUseResources()
	return true
end

function treant_leech_seed_bh:ApplyLeechSeed(target, duration)
	local caster = self:GetCaster()
	local bDur = duration or self:GetSpecialValueFor("duration")
	
	target:AddNewModifier( caster, self, "modifier_treant_leech_seed_bh_debuff", {duration = bDur} )
	
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_POINT_FOLLOW, caster, target)
end

function treant_leech_seed_bh:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	local heal = caster:GetIntellect( false) * self:GetSpecialValueFor("leech_heal") / 100
	
	target:HealEvent( heal, self, caster )
end

modifier_treant_leech_seed_bh_handler = class({})
LinkLuaModifier("modifier_treant_leech_seed_bh_handler", "heroes/hero_treant_protector/treant_leech_seed_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_treant_leech_seed_bh_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_treant_leech_seed_bh_handler:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.target:IsSameTeam(params.attacker) then
		self:GetAbility():ApplyLeechSeed( params.target )
		self:GetAbility():SetCooldown()
	end
end

function modifier_treant_leech_seed_bh_handler:IsHidden()
	return true
end

modifier_treant_leech_seed_bh_debuff = class({})
LinkLuaModifier("modifier_treant_leech_seed_bh_debuff", "heroes/hero_treant_protector/treant_leech_seed_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_treant_leech_seed_bh_debuff:OnCreated()
	self.slow = self:GetSpecialValueFor("movement_slow")
	if IsServer() then
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetCaster():GetStrength() * self:GetSpecialValueFor("leech_damage") / 100
		self.speed = self:GetSpecialValueFor("projectile_speed")
		self:StartIntervalThink( self:GetCaster():GetSecondsPerAttack() )
	end
end

function modifier_treant_leech_seed_bh_debuff:OnRefresh()
	self.slow = self:GetSpecialValueFor("movement_slow")
	if IsServer() then
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetCaster():GetStrength() * self:GetSpecialValueFor("leech_damage") / 100
		self.speed = self:GetSpecialValueFor("projectile_speed")
		self:StartIntervalThink( self:GetCaster():GetSecondsPerAttack() )
	end
end

function modifier_treant_leech_seed_bh_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	ParticleManager:FireParticle("particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf", PATTACH_POINT_FOLLOW, parent)
	ability:DealDamage( caster, parent, self.damage )
	for _, enemy in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		ability:FireTrackingProjectile("particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf", enemy, self.speed, {source = parent, origin = parent:GetAbsOrigin()})
	end
end

function modifier_treant_leech_seed_bh_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_treant_leech_seed_bh_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end