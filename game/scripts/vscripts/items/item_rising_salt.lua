item_rising_salt = class({})
LinkLuaModifier( "modifier_item_rising_salt_passive", "items/item_rising_salt.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_rising_salt_attack", "items/item_rising_salt.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_rising_salt:GetIntrinsicModifierName()
	return "modifier_item_rising_salt_passive"	
end

function item_rising_salt:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		local damage = caster:GetAttackDamage() * self:GetSpecialValueFor("bonus_damage")/100
		self:DealDamage(caster, hTarget, damage, {damage_type=DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_DAMAGE)
	end	
end

modifier_item_rising_salt_passive = class({})
function modifier_item_rising_salt_passive:OnCreated()
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
	self.bonus_cdr = self:GetSpecialValueFor("bonus_cdr")
end

function modifier_item_rising_salt_passive:DeclareFunctions()
	return {	MODIFIER_PROPERTY_MANA_BONUS,
			 	MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
			 	MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_item_rising_salt_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_rising_salt_passive:GetModifierPercentageCooldownStacking()
	return self.bonus_cdr
end

function modifier_item_rising_salt_passive:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit == self:GetParent() and self:GetAbility():IsCooldownReady() then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_rising_salt_attack", {})
			self:GetAbility():StartCooldown(self:GetSpecialValueFor("cooldown"))
		end
	end
end

function modifier_item_rising_salt_passive:IsHidden()
	return true
end

modifier_item_rising_salt_attack = class({})
function modifier_item_rising_salt_attack:GetTextureName()
	return "iron_talon"
end

function modifier_item_rising_salt_attack:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_item_rising_salt_attack:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility():FireTrackingProjectile("", params.target, self:GetParent():GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
			self:Destroy()
		end
	end
end

function modifier_item_rising_salt_attack:IsDebuff()
	return false
end