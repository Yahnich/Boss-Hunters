item_leechblade = class({})

function item_leechblade:GetIntrinsicModifierName()
	return "modifier_item_leechblade_stats"
end

function item_leechblade:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_leechblade_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn( "DOTA_Item.Satanic.Activate", self:GetCaster() )
end

modifier_item_leechblade_stats = class(itemBaseClass)
LinkLuaModifier( "modifier_item_leechblade_stats", "items/item_leechblade.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_leechblade_stats:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("melee_lifesteal") / 100
	if self:GetParent():IsRangedAttacker() then
		self.lifesteal = self:GetSpecialValueFor("ranged_lifesteal") / 100
	end
	self.activeLifesteal = self:GetSpecialValueFor("active_lifesteal") / 100
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_leechblade_stats:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_leechblade_stats:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetHealth() > 0 and self:GetParent():IsRealHero() and not params.inflictor then
		local lifesteal = self.lifesteal
		if params.attacker:HasModifier("modifier_item_leechblade_active") then lifesteal = self.activeLifesteal end
		local flHeal = params.damage * lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_leechblade_stats:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_leechblade_stats:IsHidden()
	return true
end

function modifier_item_leechblade_stats:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_leechblade_active = class({})
LinkLuaModifier( "modifier_item_leechblade_active", "items/item_leechblade.lua" ,LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_item_leechblade_active:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_leechblade_active:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_leechblade_active:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_item_leechblade_active:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end