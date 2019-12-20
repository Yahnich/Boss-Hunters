boss_treant_leech_seed = class({})

function boss_treant_leech_seed:GetIntrinsicModifierName()
	return "modifier_boss_treant_leech_seed_handler"
end

function boss_treant_leech_seed:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Treant.LeechSeed.Cast", caster)
	if target:TriggerSpellAbsorb( self ) then return end
	self:ApplyLeechSeed( target, self:GetSpecialValueFor( "duration" ) )
	EmitSoundOn("Hero_Treant.LeechSeed.Target", caster)
end

function boss_treant_leech_seed:ApplyLeechSeed(target, duration)
	local caster = self:GetCaster()
	local bDur = duration or self:GetSpecialValueFor("duration")
	
	target:AddNewModifier( caster, self, "modifier_boss_treant_leech_seed_debuff", {duration = bDur} )
	
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_POINT_FOLLOW, caster, target)
end

function boss_treant_leech_seed:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal")
	
	target:HealEvent( heal, self, caster )
end

modifier_boss_treant_leech_seed_debuff = class({})
LinkLuaModifier("modifier_boss_treant_leech_seed_debuff", "bosses/boss_treants/boss_treant_leech_seed", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_treant_leech_seed_debuff:OnCreated()
	if IsServer() then
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetSpecialValueFor("damage")
		self.speed = self:GetSpecialValueFor("projectile_speed")
		self:StartIntervalThink( 1 )
	end
end

function modifier_boss_treant_leech_seed_debuff:OnRefresh()
	self.slow = self:GetSpecialValueFor("movement_slow")
	if IsServer() then
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetSpecialValueFor("damage")
		self.speed = self:GetSpecialValueFor("projectile_speed")
		self:StartIntervalThink( 1 )
	end
end

function modifier_boss_treant_leech_seed_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	ParticleManager:FireParticle("particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf", PATTACH_POINT_FOLLOW, parent)
	local enemyFound = false
	for _, enemy in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		ability:FireTrackingProjectile("particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf", enemy, self.speed, {source = parent, origin = parent:GetAbsOrigin()})
		enemyFound = true
	end
	if enemyFound then
		EmitSoundOn( "Hero_Treant.LeechSeed.Tick", parent )
	end
end

function modifier_boss_treant_leech_seed_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_treant_leech_seed_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end