item_dark_ones_blessing = class({})

function item_dark_ones_blessing:GetIntrinsicModifierName()
	return "modifier_item_dark_ones_blessing_stats"
end

function item_dark_ones_blessing:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():SetThreat(0)
end

modifier_item_dark_ones_blessing_stats = class({})
LinkLuaModifier( "modifier_item_dark_ones_blessing_stats", "items/item_dark_ones_blessing.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_dark_ones_blessing_stats:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_dark_ones_blessing_stats:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_dark_ones_blessing_stats:OnDestroy()
	if IsServer() then
		for _, ally in ipairs( self:GetParent():FindFriendlyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
			ally:RemoveModifierByName("modifier_item_dark_ones_blessing_aura")
		end
	end
end

function modifier_item_dark_ones_blessing_stats:IsAura()
	return true
end

function modifier_item_dark_ones_blessing_stats:GetModifierAura()
	return "modifier_item_dark_ones_blessing_aura"
end

function modifier_item_dark_ones_blessing_stats:GetAuraRadius()
	return self.radius
end

function modifier_item_dark_ones_blessing_stats:GetAuraDuration()
	return 0.5
end

function modifier_item_dark_ones_blessing_stats:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_dark_ones_blessing_stats:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_dark_ones_blessing_stats:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_dark_ones_blessing_stats:IsHidden()
	return true
end

modifier_item_dark_ones_blessing_aura = class({})
LinkLuaModifier( "modifier_item_dark_ones_blessing_aura", "items/item_dark_ones_blessing.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_dark_ones_blessing_aura:GetTextureName()
	return "custom/dark_ones_blessing"
end

function modifier_item_dark_ones_blessing_aura:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("melee_lifesteal") / 100
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.mana_regen = self:GetSpecialValueFor("bonus_mana_regen")
	if self:GetParent():IsRangedAttacker() then
		self.lifesteal = self:GetSpecialValueFor("ranged_lifesteal") / 100
	end
end

function modifier_item_dark_ones_blessing_aura:OnRefresh()
	self.lifesteal = self:GetSpecialValueFor("melee_lifesteal") / 100
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.mana_regen = self:GetSpecialValueFor("bonus_mana_regen")
	if self:GetParent():IsRangedAttacker() then
		self.lifesteal = self:GetSpecialValueFor("ranged_lifesteal") / 100
	end
end

function modifier_item_dark_ones_blessing_aura:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function modifier_item_dark_ones_blessing_aura:GetModifierConstantManaRegen()
	return self.mana_regen
end

function modifier_item_dark_ones_blessing_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_dark_ones_blessing_aura:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage
end

function modifier_item_dark_ones_blessing_aura:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK  and self:GetParent():GetHealth() > 0 and self:GetParent():IsRealHero() and not params.inflictor then
		local flHeal = params.damage * self.lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end