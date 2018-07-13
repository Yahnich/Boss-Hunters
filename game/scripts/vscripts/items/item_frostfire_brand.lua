item_frostfire_brand = class({})

function item_frostfire_brand:GetIntrinsicModifierName()
	return "modifier_item_frostfire_brand_stats"
end

function item_frostfire_brand:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_frostfire_brand") then
		return "custom/frostfire_brand"
	else
		return "custom/frostfire_brand_off"
	end
end

function item_frostfire_brand:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_frostfire_brand")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_frostfire_brand", {})
	end
end

LinkLuaModifier( "modifier_item_frostfire_brand_stats", "items/item_frostfire_brand.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_frostfire_brand_stats = class({})

function modifier_item_frostfire_brand_stats:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	if IsServer() then self:GetAbility():OnToggle() end
end

function modifier_item_frostfire_brand_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_frostfire_brand_stats:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_frostfire_brand_stats:IsHidden()
	return true
end


LinkLuaModifier( "modifier_item_frostfire_brand", "items/item_frostfire_brand.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_frostfire_brand = class({})
function modifier_item_frostfire_brand:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_frostfire_brand:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_frostfire_brand_debuff")
		end
	end
end

function modifier_item_frostfire_brand:IsAura()
	return true
end

function modifier_item_frostfire_brand:GetModifierAura()
	return "modifier_frostfire_brand_debuff"
end

function modifier_item_frostfire_brand:GetAuraRadius()
	return self.radius
end

function modifier_item_frostfire_brand:GetAuraDuration()
	return 0.5
end

function modifier_item_frostfire_brand:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_frostfire_brand:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_frostfire_brand:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_frostfire_brand:IsHidden()    
	return false
end

LinkLuaModifier( "modifier_frostfire_brand_debuff", "items/item_frostfire_brand.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_frostfire_brand_debuff = class({})

function modifier_frostfire_brand_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_frostfire_brand_debuff:OnRefresh()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
end

function modifier_frostfire_brand_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage") / 100, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_frostfire_brand_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_frostfire_brand_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_frostfire_brand_debuff:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_frostfire_brand_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end