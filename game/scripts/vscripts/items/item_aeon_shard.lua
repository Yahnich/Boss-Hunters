item_aeon_shard = class({})

function item_aeon_shard:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_aeon_shard_consumed", {})
	self:Destroy()
end

function item_aeon_shard:GetIntrinsicModifierName()
	return "modifier_item_aeon_shard_passive"
end

LinkLuaModifier( "modifier_item_aeon_shard_passive", "items/item_aeon_shard.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_aeon_shard_passive = class({})

function modifier_item_aeon_shard_passive:OnCreated()
	self.bonus_attack_speed = self:GetSpecialValueFor("bonus_attackspeed")
end

function modifier_item_aeon_shard_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_aeon_shard_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_item_aeon_shard_passive:IsHidden()
	return true
end

function modifier_item_aeon_shard_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


LinkLuaModifier( "modifier_item_aeon_shard_consumed", "items/item_aeon_shard.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_aeon_shard_consumed = class({})

function modifier_item_aeon_shard_consumed:GetTexture()
	return "item_moon_shard"
end

function modifier_item_aeon_shard_consumed:OnCreated()
	self.bonus_attack_speed = self:GetSpecialValueFor("consumed_attackspeed")
end

function modifier_item_aeon_shard_consumed:OnRefresh()
	self.bonus_attack_speed = self:GetSpecialValueFor("consumed_attackspeed")
	self:IncrementStackCount()
end


function modifier_item_aeon_shard_consumed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_aeon_shard_consumed:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed * math.max(1, self:GetStackCount())
end

function modifier_item_aeon_shard_consumed:RemoveOnDeath()
	return false
end

function modifier_item_aeon_shard_consumed:IsPermanent()
	return true
end