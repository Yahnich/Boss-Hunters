dazzle_poison_touch_bh = class({})

function dazzle_poison_touch_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local endRadius = self:GetTalentSpecialValueFor("end_radius")
	local length = self:GetTalentSpecialValueFor("end_distance")
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	for _, enemy in ipairs( caster:FindEnemyUnitsInCone(direction, caster:GetAbsOrigin(), endRadius, length) ) do
		self:FireTrackingProjectile("particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf", enemy, speed)
	end
end

function dazzle_poison_touch_bh:OnProjectileHit( target, position )
	if target then
		target:AddNewModifier( caster, self, "modifier_dazzle_poison_touch_bh", {duration = self:GetTalentSpecialValueFor("duration")} )
	end
end

modifier_dazzle_poison_touch_bh = class({})
LinkLuaModifier( "modifier_dazzle_poison_touch_bh", "heroes/hero_dazzle/dazzle_poison_touch_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_dazzle_poison_touch_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.slow = self:GetTalentSpecialValueFor("slow")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_poison_touch_1")
	self.heal = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_1") / 100
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_1", "radius")
	if IsServer() then
		self:StartIntervalThink( self:GetDuration() / self:GetTalentSpecialValueFor("duration") )
	end
end

function modifier_dazzle_poison_touch_bh:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.slow = self:GetTalentSpecialValueFor("slow")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_poison_touch_1")
	self.heal = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_1")
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_1", "radius")
	if IsServer() then
		self:StartIntervalThink( self:GetDuration() / self:GetTalentSpecialValueFor("duration") )
	end
end

function modifier_dazzle_poison_touch_bh:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	local damage = ability:DealDamage( caster, parent, self.damage )
	if self.talent1 then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			ally:HealEvent( damage * self.heal, ability, caster )
		end
	end
end

function modifier_dazzle_poison_touch_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_dazzle_poison_touch_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_dazzle_poison_touch_bh:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_poison_debuff.vpcf"
end