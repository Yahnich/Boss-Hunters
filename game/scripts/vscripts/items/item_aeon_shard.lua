item_aeon_shard = class({})

function item_aeon_shard:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_aeon_shard_consumed", {})
	self:Destroy()
end

function item_aeon_shard:GetIntrinsicModifierName()
	return "modifier_item_aeon_shard_passive"
end

LinkLuaModifier( "modifier_item_aeon_shard_passive", "items/item_aeon_shard.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_aeon_shard_passive = class(itemBasicBaseClass)

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

LinkLuaModifier( "modifier_item_aeon_shard_consumed", "items/item_aeon_shard.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_aeon_shard_consumed = class({})

function modifier_item_aeon_shard_consumed:GetTexture()
	return "item_moon_shard"
end

function modifier_item_aeon_shard_consumed:OnCreated()
	self.bonus_attack_speed = self:GetSpecialValueFor("consumed_attackspeed")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_item_aeon_shard_consumed:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
	end
end


function modifier_item_aeon_shard_consumed:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_aeon_shard_consumed:GetModifierAttackSpeedBonus_Constant()
	return 30 * self:GetStackCount()
end

function modifier_item_aeon_shard_consumed:DestroyOnExpire()
	return false
end

function modifier_item_aeon_shard_consumed:RemoveOnDeath()
	return false
end

function modifier_item_aeon_shard_consumed:IsPermanent()
	return true
end

function modifier_item_aeon_shard_consumed:IsPurgable()
	return false
end

function modifier_item_aeon_shard_consumed:AllowIllusionDuplicate()
	return true
end

function modifier_item_aeon_shard_consumed:GetAttributes()
return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
