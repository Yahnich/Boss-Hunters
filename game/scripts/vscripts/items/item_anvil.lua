item_anvil = class({})
function item_anvil:GetIntrinsicModifierName()
	return "modifier_item_anvil_handle"
end

modifier_item_anvil_handle = class({})
LinkLuaModifier( "modifier_item_anvil_handle", "items/item_anvil.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_anvil_handle:OnCreated()
	self.bash_chance = self:GetSpecialValueFor("bash_chance")
	self.bash_duration = self:GetSpecialValueFor("bash_duration")
	
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_anvil_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_anvil_handle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE 
			}
end

function modifier_item_anvil_handle:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_anvil_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_anvil_handle:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and RollPercentage( self.bash_chance ) then
		self:GetAbility():SetCooldown()
		self:GetAbility():Stun(params.target, self.bash_duration, true)
		EmitSoundOn("DOTA_Item.SkullBasher", params.target)
	end
end

function modifier_item_anvil_handle:IsHidden()
	return true
end

function modifier_item_anvil_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end