item_emission = class({})

function item_emission:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_emission") then
		return "custom/emission"
	else
		return "custom/emission_off"
	end
end

function item_emission:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():RemoveModifierByName("modifier_item_emission")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_emission", {})
	end
end

function item_emission:GetIntrinsicModifierName()
	return "modifier_item_emission_passive"
end

LinkLuaModifier( "modifier_item_emission", "items/item_emission.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_emission = class({})
function modifier_item_emission:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_emission:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_emission_debuff")
		end
	end
end

function modifier_item_emission:IsAura()
	return true
end

function modifier_item_emission:GetModifierAura()
	return "modifier_emission_debuff"
end

function modifier_item_emission:GetAuraRadius()
	return self.radius
end

function modifier_item_emission:GetAuraDuration()
	return 0.5
end

function modifier_item_emission:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_emission:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_emission:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_emission:IsHidden()    
	return true
end

LinkLuaModifier( "modifier_emission_debuff", "items/item_emission.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_emission_debuff = class({})

function modifier_emission_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage") / 100
		self:StartIntervalThink(1)
	end
end

function modifier_emission_debuff:OnRefresh()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage") / 100
	end
end

function modifier_emission_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_emission_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_emission_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_emission_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end


modifier_item_emission_passive = class({})
LinkLuaModifier( "modifier_item_emission_passive", "items/item_emission.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_emission_passive:OnCreated()
	self.stat = self:GetSpecialValueFor("bonus_all")
	if IsServer() then self:GetAbility():OnToggle() end
end

function modifier_item_emission_passive:OnDestroy()
	if IsServer() then self:GetParent():RemoveModifierByName("modifier_item_emission") end
end

function modifier_item_emission_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_emission_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_emission_passive:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_emission_passive:GetModifierBonusStats_Agility()
	return self.stat
end

function modifier_item_emission_passive:GetModifierBonusStats_Intellect()
	return self.stat
end

function modifier_item_emission_passive:IsHidden()
	return true
end

function modifier_item_emission_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end