item_frostbite = class({})

function item_frostbite:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_frostbite") then
		return "custom/frostbite"
	else
		return "custom/frostbite_off"
	end
end

function item_frostbite:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_frostbite")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_frostbite", {})
	end
end

function item_frostbite:GetIntrinsicModifierName()
	return "modifier_item_frostbite"
end

LinkLuaModifier( "modifier_item_frostbite", "items/item_frostbite.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_frostbite = class({})
function modifier_item_frostbite:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_frostbite:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_frostbite_debuff")
		end
	end
end

function modifier_item_frostbite:IsAura()
	return true
end

function modifier_item_frostbite:GetModifierAura()
	return "modifier_frostbite_debuff"
end

function modifier_item_frostbite:GetAuraRadius()
	return self.radius
end

function modifier_item_frostbite:GetAuraDuration()
	return 0.5
end

function modifier_item_frostbite:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_frostbite:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_frostbite:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_frostbite:IsHidden()    
	return true
end

LinkLuaModifier( "modifier_frostbite_debuff", "items/item_frostbite.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_frostbite_debuff = class({})

function modifier_frostbite_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_frostbite_debuff:OnRefresh()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_frostbite_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage") / 100, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_frostbite_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_frostbite_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_frostbite_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end