dazzle_poison_touch_bh = class({})

function dazzle_poison_touch_bh:GetManaCost( iLvl ) 
	return self.BaseClass.GetManaCost( self, iLvl ) + self:GetCaster():GetModifierStackCount( "modifier_dazzle_weave_bh_handler", self:GetCaster() )
end

function dazzle_poison_touch_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local endRadius = self:GetTalentSpecialValueFor("end_radius")
	local length = self:GetTalentSpecialValueFor("end_distance") + caster:GetHullRadius() + caster:GetCollisionPadding()
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	local direction = CalculateDirection( target, caster )
	local maxTargets = self:GetTalentSpecialValueFor("max_targets")
	local targetsHit = 1
	
	self:FireTrackingProjectile("particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf", target, speed)
	for _, enemy in ipairs( caster:FindEnemyUnitsInCone(direction, caster:GetAbsOrigin(), endRadius, length) ) do
		if enemy ~= target then
			self:FireTrackingProjectile("particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf", enemy, speed)
			targetsHit = targetsHit + 1
		end
		if targetsHit == maxTargets then
			break
		end
	end
	if caster:HasScepter() then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), -1 ) ) do
			if enemy:HasModifier("modifier_dazzle_weave_bh") then
				self:FireTrackingProjectile("particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf", enemy, speed)
			end
		end
	end
end

function dazzle_poison_touch_bh:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb(self) then
		local caster = self:GetCaster()
		target:AddNewModifier( caster, self, "modifier_dazzle_poison_touch_bh", {duration = self:GetTalentSpecialValueFor("duration")} )
	end
end

modifier_dazzle_poison_touch_bh = class({})
LinkLuaModifier( "modifier_dazzle_poison_touch_bh", "heroes/hero_dazzle/dazzle_poison_touch_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_dazzle_poison_touch_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.slow = self:GetTalentSpecialValueFor("slow")
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_poison_touch_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_poison_touch_2")
	self.talent2ticks = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_2", "duration")
	self.talent2Dmg = self.damage * (self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_2") - 1) / self.talent2ticks
	self.talent2Slo = self.slow * (self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_2") - 1) / self.talent2ticks
	self.heal = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_1") / 100
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_poison_touch_1", "radius")
	
	self.tick = self:GetDuration() / self:GetTalentSpecialValueFor("duration")
	self:StartIntervalThink( self.tick )
end

function modifier_dazzle_poison_touch_bh:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.slow = self:GetTalentSpecialValueFor("slow")
	self.duration = self:GetTalentSpecialValueFor("duration")
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
	
	if self.talent2 then
		self.talent2ticks = self.talent2ticks - 1
		if self.talent2ticks >= 0 then
			self.slow = self.slow + self.talent2Slo
			self.damage = self.damage + self.talent2Dmg
		end
	end
	if IsServer() then
		local damage = ability:DealDamage( caster, parent, self.damage )
		if self.talent1 then
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
				ally:HealEvent( damage * self.heal, ability, caster )
			end
		end
	end
end

function modifier_dazzle_poison_touch_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_dazzle_poison_touch_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_dazzle_poison_touch_bh:OnAttackLanded(params)
	if params.target == self:GetParent() then
		self:SetDuration( self.duration, true )
	end
end

function modifier_dazzle_poison_touch_bh:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_poison_debuff.vpcf"
end

function modifier_dazzle_poison_touch_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end