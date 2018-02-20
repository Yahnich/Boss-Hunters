item_urn_1 = class({})
LinkLuaModifier( "modifier_item_urn_handle", "items/item_urn.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_urn_handle_damage", "items/item_urn.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_urn_handle_heal", "items/item_urn.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_urn_1:GetIntrinsicModifierName()
	return "modifier_item_urn_handle"
end

function item_urn_1:OnSpellStart()
	EmitSoundOn("DOTA_Item.SpiritVessel.Cast", self:GetCaster())
	if self:GetCursorTarget():GetTeam() == self:GetCaster():GetTeam() then
		EmitSoundOn("DOTA_Item.SpiritVessel.Target.Ally", self:GetCursorTarget())

		ParticleManager:FireRopeParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetCursorTarget(), {})
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_urn_handle_heal", {Duration = self:GetSpecialValueFor("duration")})
	else
		EmitSoundOn("DOTA_Item.SpiritVessel.Target.Enemy", self:GetCursorTarget())

		ParticleManager:FireRopeParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetCursorTarget(), {})
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_urn_handle_damage", {Duration = self:GetSpecialValueFor("duration")})
	end
end

item_urn_2 = class(item_urn_1)
item_urn_3 = class(item_urn_1)
item_urn_4 = class(item_urn_1)
item_urn_5 = class(item_urn_1)

modifier_item_urn_handle = class({})
function modifier_item_urn_handle:OnCreated()
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.mregen = self:GetSpecialValueFor("bonus_mregen")
	self.stats = self:GetSpecialValueFor("bonus_stats")
	self.bonus_evasion = self:GetSpecialValueFor("bonus_evasion")
end

function modifier_item_urn_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_urn_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_EVASION_CONSTANT
			}
end

function modifier_item_urn_handle:GetModifierPhysicalArmorBonus()
	if not self:GetAbility().casted then return self.armor end
end

function modifier_item_urn_handle:GetModifierConstantManaRegen()
	return self.mregen
end

function modifier_item_urn_handle:GetModifierBonusStats_Agility()
	return self.stats
end

function modifier_item_urn_handle:GetModifierBonusStats_Strength()
	return self.stats
end

function modifier_item_urn_handle:GetModifierBonusStats_Intellect()
	return self.stats
end

function modifier_item_urn_handle:GetModifierEvasion_Constant()
	if not self:GetAbility().casted then return self.evasion end
end

function modifier_item_urn_handle:IsHidden()
	return true
end

modifier_item_urn_handle_heal = class({})
function modifier_item_urn_handle_heal:OnCreated()
	if IsServer() then
		self:GetParent():HealEvent(self:GetAbility():GetSpecialValueFor("damage_heal"), self:GetAbility(), self:GetCaster())
		self:StartIntervalThink(1.0)
	end
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
	self:GetAbility().casted = true
end

function modifier_item_urn_handle_heal:OnDestroy()
	self:GetAbility().casted = false
end

function modifier_item_urn_handle_heal:OnIntervalThink()
	self:GetParent():HealEvent(self:GetAbility():GetSpecialValueFor("damage_heal"), self:GetAbility(), self:GetCaster())
end

function modifier_item_urn_handle_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_EVASION_CONSTANT
			}
end

function modifier_item_urn_handle_heal:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_urn_handle:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_urn_handle_heal:GetEffectName()
	return "particles/items4_fx/spirit_vessel_heal.vpcf"
end

function modifier_item_urn_handle_heal:IsDebuff()
	return false
end

modifier_item_urn_handle_damage = class({})
function modifier_item_urn_handle_damage:OnCreated()
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("damage_heal"), {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
		self:StartIntervalThink(1.0)
	end
	self.armor = self:GetSpecialValueFor("reduc_armor")
	self.blind = self:GetSpecialValueFor("bonus_evasion")
	self.disable = self:GetSpecialValueFor("disables_healing")
	self:GetAbility().casted = true
end

function modifier_item_urn_handle_damage:OnRefresh()
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("damage_heal"), {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
	end
	self.armor = self:GetSpecialValueFor("reduc_armor")
	self.blind = self:GetSpecialValueFor("bonus_evasion")
	self.disable = self:GetSpecialValueFor("disables_healing")
	self:GetAbility().casted = true
end

function modifier_item_urn_handle_damage:OnDestroy()
	self:GetAbility().casted = false
end

function modifier_item_urn_handle_damage:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetAbility():GetSpecialValueFor("damage_heal"), {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
end

function modifier_item_urn_handle_damage:GetEffectName()
	return "particles/items4_fx/spirit_vessel_damage.vpcf"
end

function modifier_item_urn_handle_damage:IsDebuff()
	return true
end

function modifier_item_urn_handle_damage:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MISS_PERCENTAGE,
			MODIFIER_PROPERTY_DISABLE_HEALING,}
end

function modifier_item_urn_handle_damage:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_urn_handle:GetModifierMiss_Percentage()
	return self.evasion
end

function modifier_item_urn_handle:GetDisableHealing()
	print(self.disable)
	return tonumber(self.disable)
end