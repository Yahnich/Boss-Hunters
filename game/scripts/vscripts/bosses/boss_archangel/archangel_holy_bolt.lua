archangel_holy_bolt = class({})

function archangel_holy_bolt:GetCastRange( target, position )
	return self:GetSpecialValueFor("distance")
end

function archangel_holy_bolt:OnAbilityPhaseStart()
	local startPos = self:GetCaster():GetAbsOrigin()
	local direction = self:GetCaster():GetForwardVector()
	
	local distance = self:GetSpecialValueFor("distance")
	local endPos = startPos + direction * distance
	ParticleManager:FireLinearWarningParticle( startPos, endPos )
	self.bolts = 1 + math.floor( (100 - self:GetCaster():GetHealthPercent()) / self:GetSpecialValueFor("extra_bolt_treshold") )
	local angle = 360 / self.bolts
	for i = 1, self.bolts - 1 do
		direction = RotateVector2D( direction, ToRadians( angle ) )
		local newPos = startPos + direction * distance
		ParticleManager:FireLinearWarningParticle( startPos, newPos )
	end
	
	return true
end

function archangel_holy_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local direction = caster:GetForwardVector()
	local distance = self:GetSpecialValueFor("distance")
	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if target:TriggerSpellAbsorb(self) then return false end
		EmitSoundOn("Hero_SkywrathMage.ArcaneBolt.Impact", target)
		ability:DealDamage( caster, target, self.damage )
		target:AddNewModifier( caster, ability, "modifier_archangel_holy_bolt", {duration = slow_duration})
		return false
	end
	caster:EmitSound("Hero_SkywrathMage.ArcaneBolt.Cast")
	ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf",
																			position = caster:GetAbsOriginCenter(),
																			caster = caster,
																			ability = self,
																			speed = speed,
																			radius = radius,
																			velocity = speed * direction,
																			distance = distance,
																			damage = damage})
	local startPos = caster:GetAbsOrigin()
	self.bolts = 1 + math.floor( (100 - self:GetCaster():GetHealthPercent()) / self:GetSpecialValueFor("extra_bolt_treshold") )
	local angle = 360 / self.bolts
	for i = 1, self.bolts - 1 do
		direction = RotateVector2D( direction, ToRadians( angle ) )
		local newPos = startPos + direction * distance
		ProjectileHandler:CreateProjectile(PROJECTILE_LINEAR, ProjectileHit, {  FX = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf",
																				position = GetGroundPosition( caster:GetAbsOrigin(), caster ) + Vector(0,0,caster:GetCenter().z/2),
																				caster = caster,
																				ability = self,
																				speed = speed,
																				radius = radius,
																				velocity = speed * direction,
																				distance = distance,
																				slow_duration = slow_duration,
																				damage = damage})
	end
end

modifier_archangel_holy_bolt = class({})
LinkLuaModifier( "modifier_archangel_holy_bolt", "bosses/boss_archangel/archangel_holy_bolt.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_archangel_holy_bolt:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_archangel_holy_bolt:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_archangel_holy_bolt:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_archangel_holy_bolt:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_archangel_holy_bolt:GetEffectName()
	return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_slow_debuff.vpcf"
end

function modifier_archangel_holy_bolt:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end