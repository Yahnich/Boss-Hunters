item_orb_of_vitality = class({})

function item_orb_of_vitality:GetIntrinsicModifierName()
	return "modifier_item_orb_of_vitality_passive"
end

function item_orb_of_vitality:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_orb_of_vitality_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_item_orb_of_vitality_passive = class({})
LinkLuaModifier("modifier_item_orb_of_vitality_passive", "items/item_orb_of_vitality", LUA_MODIFIER_MOTION_NONE)

function modifier_item_orb_of_vitality_passive:OnCreated()
	self.regen = self:GetSpecialValueFor("bonus_hp_regen")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
	self.bonusHP = self:GetSpecialValueFor("bonus_health")
	self.stat = self:GetSpecialValueFor("bonus_strength")
end

function modifier_item_orb_of_vitality_passive:IsHidden()
	return true
end

function modifier_item_orb_of_vitality_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,	
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			}
end

function modifier_item_orb_of_vitality_passive:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_orb_of_vitality_passive:GetModifierHealthBonus()
	return self:GetParent():GetStrength() * self.hpPerStr + self.bonusHP
end

function modifier_item_orb_of_vitality_passive:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_item_orb_of_vitality_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end