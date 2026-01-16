venomancer_pandemic = class({})

function venomancer_pandemic:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	self:FireTrackingProjectile("particles/units/heroes/hero_venomancer/venomancer_pandemic_projectile.vpcf", target, self:GetSpecialValueFor("projectile_speed"))
end

--------------------------------------------------------------------------------

function venomancer_pandemic:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		
		local duration = self:GetSpecialValueFor("debuff_duration")
		local damage = self:GetSpecialValueFor("impact_damage")
		local poison = self:GetSpecialValueFor("poison_per_sec")
		local spread = self:GetSpecialValueFor("total_spreads")
		
		target:AddNewModifier( caster, self, "modifier_venomancer_pandemic_cancer", {duration = duration} ):SetStackCount( spread )
		self:DealDamage( caster, target, damage )
	end
end

LinkLuaModifier( "modifier_venomancer_pandemic_cancer", "heroes/hero_venomancer/venomancer_pandemic", LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_pandemic_cancer = class({})

function modifier_venomancer_pandemic_cancer:OnCreated()
	self:OnRefresh()
	
	self:OnIntervalThink( )
	self:StartIntervalThink( 1 )
end

function modifier_venomancer_pandemic_cancer:OnRefresh()
	self.poison_per_sec = self:GetSpecialValueFor("poison_per_sec")
	self.debuff_radius = self:GetSpecialValueFor("debuff_radius")
	self.debuff_duration = self:GetSpecialValueFor("debuff_duration")
	self.poison_damage_on_expire = self:GetSpecialValueFor("poison_damage_on_expire") / 100
	self.healing_on_expire = self:GetSpecialValueFor("healing_on_expire") / 100
end

function modifier_venomancer_pandemic_cancer:OnDestroy()
	if IsClient() then return end
	if self:GetStackCount() <= 0 then return end
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local damageToDeal = parent:GetPoisonDamage() * self.poison_damage_on_expire
	local healToApply = parent:GetPoisonDamage() * self.healing_on_expire
	
	ability:DealDamage( caster, parent, damageToDeal )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.debuff_radius ) ) do
		enemy:AddNewModifier( caster, ability, "modifier_venomancer_pandemic_cancer", {duration = self.debuff_duration} ):SetStackCount( self:GetStackCount() - 1 )
	end
	if healToApply > 0 then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.debuff_radius ) ) do
			ally:HealEvent( healToApply, ability, caster )
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_venomancer/venomancer_pandemic_spread.vpcf", PATTACH_POINT_FOLLOW, parent, {[1] = Vector(self.debuff_radius, 1, self.debuff_radius)})
end

function modifier_venomancer_pandemic_cancer:OnIntervalThink()
	if IsServer() then 
		local parent = self:GetParent()
		local caster = self:GetCaster()
		parent:AddPoison( caster, self.poison_per_sec )
	end
end

function modifier_venomancer_pandemic_cancer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_venomancer_pandemic_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf"
end

function modifier_venomancer_pandemic_cancer:IsAura()
    return true
end

function modifier_venomancer_pandemic_cancer:GetAuraDuration()
    return 0.5
end

function modifier_venomancer_pandemic_cancer:GetAuraRadius()
    return self.debuff_radius
end

function modifier_venomancer_pandemic_cancer:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_venomancer_pandemic_cancer:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_venomancer_pandemic_cancer:GetModifierAura()
    return "modifier_venomancer_pandemic_aura_slow"
end

LinkLuaModifier( "modifier_venomancer_pandemic_aura_slow", "heroes/hero_venomancer/venomancer_pandemic", LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_pandemic_aura_slow = class({})

function modifier_venomancer_pandemic_aura_slow:OnCreated()
	self:OnRefresh()
end

function modifier_venomancer_pandemic_aura_slow:OnRefresh()
	self.movement_slow_max = -self:GetSpecialValueFor("movement_slow_max")
	self.attack_slow = -self:GetSpecialValueFor("attack_slow")
end

function modifier_venomancer_pandemic_aura_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_venomancer_pandemic_aura_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_slow_max
end

function modifier_venomancer_pandemic_aura_slow:GetModifierAttackSpeedBonus_Constant()
	return self.attack_slow
end

function modifier_venomancer_pandemic_aura_slow:IsHidden()
	return self:GetParent():HasModifier("modifier_venomancer_pandemic_cancer")
end

function modifier_venomancer_pandemic_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_pandemic_slow.vpcf"
end