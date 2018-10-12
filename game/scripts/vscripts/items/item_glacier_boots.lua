item_glacier_boots = class({})

function item_glacier_boots:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_glacier_boots_toggle") then
		return "custom/glacier_boots_on"
	else
		return "custom/glacier_boots"
	end
end

function item_glacier_boots:OnToggle()
	if not self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_glacier_boots_toggle")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_glacier_boots_toggle", {})
	end
end

function item_glacier_boots:GetIntrinsicModifierName()
	return "modifier_item_glacier_boots"
end

LinkLuaModifier( "modifier_item_glacier_boots_toggle", "items/item_glacier_boots.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_glacier_boots_toggle = class(itemBaseClass)

function modifier_item_glacier_boots_toggle:OnCreated()
	self.slow = self:GetSpecialValueFor("active_ms")
	self.armor = self:GetSpecialValueFor("active_armor")
end

function modifier_item_glacier_boots_toggle:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_glacier_boots_toggle:GetModifierMoveSpeedBonus_Constant()
	return self.slow
end

function modifier_item_glacier_boots_toggle:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_glacier_boots_toggle:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_item_glacier_boots_toggle:GetStatusEffectName()
	return "particles/status_fx/status_effect_wyvern_cold_embrace.vpcf"
end

function modifier_item_glacier_boots_toggle:StatusEffectPriority()
	return 5
end

LinkLuaModifier( "modifier_item_glacier_boots", "items/item_glacier_boots.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_glacier_boots = class(itemBaseClass)
function modifier_item_glacier_boots:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.ms = self:GetSpecialValueFor("bonus_ms")
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_glacier_boots:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_item_glacier_boots_toggle")
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_glacier_boots_debuff")
		end
	end
end

function modifier_item_glacier_boots:IsAura()
	return true
end

function modifier_item_glacier_boots:GetModifierAura()
	return "modifier_glacier_boots_debuff"
end

function modifier_item_glacier_boots:GetAuraRadius()
	return self.radius
end

function modifier_item_glacier_boots:GetAuraDuration()
	return 0.5
end

function modifier_item_glacier_boots:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_glacier_boots:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_glacier_boots:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_glacier_boots:IsHidden()
	return true
end

function modifier_item_glacier_boots:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_glacier_boots:GetModifierMoveSpeedBonus_Special_Boots()
	return self.ms
end

function modifier_item_glacier_boots:GetModifierPhysicalArmorBonus()
	return self.armor
end

LinkLuaModifier( "modifier_glacier_boots_debuff", "items/item_glacier_boots.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_glacier_boots_debuff = class({})

function modifier_glacier_boots_debuff:OnCreated()
	self.attackslow = self:GetAbility():GetSpecialValueFor("aura_slow")
	self.active_attackslow = self:GetAbility():GetSpecialValueFor("active_as")
	self.active_moveslow = self:GetAbility():GetSpecialValueFor("aura_slow")
end

function modifier_glacier_boots_debuff:OnRefresh()
	self.attackslow = self:GetAbility():GetSpecialValueFor("aura_slow")
	self.active_attackslow = self:GetAbility():GetSpecialValueFor("active_as")
	self.active_moveslow = self:GetAbility():GetSpecialValueFor("aura_slow")
end

function modifier_glacier_boots_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_glacier_boots_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self:GetCaster():HasModifier("modifier_item_glacier_boots_toggle") then
		return self.active_moveslow
	else
		return 0
	end
end

function modifier_glacier_boots_debuff:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():HasModifier("modifier_item_glacier_boots_toggle") then
		return self.active_attackslow
	else
		return self.attackslow
	end
end

function modifier_glacier_boots_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end