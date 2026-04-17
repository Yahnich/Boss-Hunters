alchemist_haste_potion = class({})

function alchemist_haste_potion:IsStealable()
	return true
end

function alchemist_haste_potion:IsHiddenWhenStolen()
	return false
end

function alchemist_haste_potion:OnSpellStart()
	local caster = self:GetCaster()
	
	self.projectiles = self.projectiles or {}
	local projectileID = self:FireTrackingProjectile("particles/units/heroes/hero_alchemist/alchemist_berserk_potion_projectile.vpcf", self:GetCursorTarget(), 900, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_3, false, true, 300)
	self.projectiles[projectileID] = {}
	
	EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Throw", caster )
end

function alchemist_haste_potion:OnProjectileHitHandle( target, position, projectile )
	if target then
		self:HastePotionEffect( target, self.projectiles[projectile] )
		self.projectiles[projectile] = nil
	end
end

function alchemist_haste_potion:HastePotionEffect( target )
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	local strong = self:GetSpecialValueFor("strong_dispel") == 1
	
	target:AddNewModifier( caster, self, "modifier_alchemist_haste_potion_buff", {duration = duration} )
	target:Dispel(caster, strong)
	
	EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Stun", target )
end

modifier_alchemist_haste_potion_buff = class({})
LinkLuaModifier( "modifier_alchemist_haste_potion_buff", "heroes/hero_alchemist/alchemist_haste_potion", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_haste_potion_buff:OnCreated()
	self:OnRefresh()
end

function modifier_alchemist_haste_potion_buff:OnRefresh()
	self.attack_speed = self:GetSpecialValueFor("attack_speed")
	self.hp_regen = self:GetSpecialValueFor("hp_regen")
	self.move_speed = self:GetSpecialValueFor("move_speed")
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_alchemist_haste_potion_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_alchemist_haste_potion_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_alchemist_haste_potion_buff:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_alchemist_haste_potion_buff:GetModifierMoveSpeedBonus_Constant()
	return self.move_speed
end

function modifier_alchemist_haste_potion_buff:GetModifierTotalDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_alchemist_haste_potion_buff:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_berserk_buff.vpcf"
end