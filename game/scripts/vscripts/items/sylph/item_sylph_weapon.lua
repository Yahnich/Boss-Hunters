item_sylph_weapon_1 = class({})

function item_sylph_weapon_1:GetIntrinsicModifierName()
	return "modifier_item_sylph_weapon"
end

item_sylph_weapon_2 = class(item_sylph_weapon_1)
item_sylph_weapon_3 = class(item_sylph_weapon_1)
item_sylph_weapon_4 = class(item_sylph_weapon_1)
item_sylph_weapon_5 = class(item_sylph_weapon_1)

modifier_item_sylph_weapon = class({})
LinkLuaModifier("modifier_item_sylph_weapon", "items/sylph/item_sylph_weapon.lua", 0)

function modifier_item_sylph_weapon:OnCreated()
	self.bonus_range = self:GetSpecialValueFor("bonus_range")
	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetSpecialValueFor("crit_damage")
end

function modifier_item_sylph_weapon:OnRefresh()
	self.bonus_range = self:GetSpecialValueFor("bonus_range")
	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetSpecialValueFor("crit_damage")
end


function modifier_item_sylph_weapon:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_item_sylph_weapon:GetModifierAttackRangeBonus()
	return self.bonus_range
end

function modifier_item_sylph_weapon:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.inflictor and RollPercentage(self.crit_chance) then
		params.target:ShowPopup( {
						PostSymbol = 4,
						Color = Vector( 125, 125, 255 ),
						Duration = 0.5,
						Number = params.damage * self.crit_dmg,
						pfx = "spell"} )
		return 100 - self.crit_dmg
	end
end

function modifier_item_sylph_weapon:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(self.crit_chance) then
		return self.crit_dmg
	end
end

function modifier_item_sylph_weapon:IsHidden()
	return true
end