item_vladmir = class({})

function item_vladmir:GetIntrinsicModifierName()
	return "modifier_item_vlads_stats"
end

modifier_item_vlads_stats = class({})
LinkLuaModifier( "modifier_item_vlads_stats", "items/item_lifesteal.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_vlads_stats:OnCreated()
	self.all = self:GetSpecialValueFor("bonus_all_stats")
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_item_vlads_stats:OnRefresh()
	self.all = self:GetSpecialValueFor("bonus_all_stats")
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_item_vlads_stats:OnDestroy()
	for _, ally in ipairs( self:GetParent():FindFriendlyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ) ) do
		ally:RemoveModifierByName("modifier_item_lifesteal_aura")
	end
end

function modifier_item_vlads_stats:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_vlads_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,}
end

function modifier_item_vlads_stats:GetModifierBonusStats_Strength()
	return self.all
end
function modifier_item_vlads_stats:GetModifierBonusStats_Agility()
	return self.all
end
function modifier_item_vlads_stats:GetModifierBonusStats_Intellect()
	return self.all
end

function modifier_item_vlads_stats:IsAura()
	return true
end

function modifier_item_vlads_stats:GetModifierAura()
	return "modifier_item_lifesteal_aura"
end

function modifier_item_vlads_stats:GetAuraRadius()
	return self.radius
end

function modifier_item_vlads_stats:GetAuraDuration()
	return 0.5
end

function modifier_item_vlads_stats:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_vlads_stats:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_vlads_stats:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_vlads_stats:IsHidden()
	return true
end

modifier_item_lifesteal_aura = class({})
LinkLuaModifier( "modifier_item_lifesteal_aura", "items/item_lifesteal.lua" ,LUA_MODIFIER_MOTION_NONE )


function modifier_item_lifesteal_aura:OnCreated()
	self.damage = self:GetSpecialValueFor("damage_aura")
	self.armor = self:GetSpecialValueFor("armor_aura")
	self.mpRegen = self:GetSpecialValueFor("mana_regen_aura")
	self.hpRegen = self:GetSpecialValueFor("hp_regen")
	self.unholyLifesteal = self:GetSpecialValueFor("lifesteal_buff") / 100
	self.lifesteal = self:GetSpecialValueFor("vampiric_aura") / 100
	if self:GetParent():IsRangedAttacker() then
		self.lifesteal = self:GetSpecialValueFor("vampiric_aura_ranged") / 100
	end
end

function modifier_item_lifesteal_aura:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage_aura")
	self.armor = self:GetSpecialValueFor("armor_aura")
	self.mpRegen = self:GetSpecialValueFor("mana_regen_aura")
	self.hpRegen = self:GetSpecialValueFor("hp_regen")
	self.unholyLifesteal = self:GetSpecialValueFor("lifesteal_buff") / 100
	self.lifesteal = self:GetSpecialValueFor("vampiric_aura") / 100
	if self:GetParent():IsRangedAttacker() then
		self.lifesteal = self:GetSpecialValueFor("vampiric_aura_ranged") / 100
	end
end

function modifier_item_lifesteal_aura:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_item_lifesteal_aura:OnTakeDamage(params)
	if params.attacker == self:GetParent() and not params.inflictor then
		local lifesteal = self.lifesteal
		if params.attacker:HasModifier("modifier_item_lifesteal_active") then lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal_buff") / 100 end
		local flHeal = params.damage * lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_lifesteal_aura:OnTooltip()
	return self.lifesteal
end

function modifier_item_lifesteal_aura:GetModifierConstantHealthRegen()
	return self.hpRegen
end

function modifier_item_lifesteal_aura:GetModifierConstantManaRegen()
	return self.mpRegen
end

function modifier_item_lifesteal_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_lifesteal_aura:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

item_lifesteal2 = class(item_vladmir)

function item_lifesteal2:GetIntrinsicModifierName()
	return "modifier_item_lifesteal_stats"
end

function item_lifesteal2:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_lifesteal_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn( "DOTA_Item.Satanic.Activate", self:GetCaster() )
end

modifier_item_lifesteal_stats = class(modifier_item_vlads_stats)
LinkLuaModifier( "modifier_item_lifesteal_stats", "items/item_lifesteal.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_lifesteal_stats:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.all = self:GetSpecialValueFor("bonus_all_stats")
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_item_lifesteal_stats:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_lifesteal_stats:GetModifierBonusStats_Strength()
	return self.all
end
function modifier_item_lifesteal_stats:GetModifierBonusStats_Agility()
	return self.all
end
function modifier_item_lifesteal_stats:GetModifierBonusStats_Intellect()
	return self.all
end

function modifier_item_lifesteal_stats:GetModifierPreAttack_BonusDamage()
	return self.damage
end

modifier_item_lifesteal_active = class({})
LinkLuaModifier( "modifier_item_lifesteal_active", "items/item_lifesteal.lua" ,LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_item_lifesteal_active:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_lifesteal_active:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_lifesteal_active:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_item_lifesteal_active:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end

item_lifesteal3 = class(item_lifesteal2)
item_lifesteal4 = class(item_lifesteal2)
item_lifesteal5 = class(item_lifesteal2)