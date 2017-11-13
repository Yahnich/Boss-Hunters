item_wraith_weapon_1 = class({})

function item_wraith_weapon_1:GetIntrinsicModifierName()
	return "modifier_item_wraith_weapon"
end

item_wraith_weapon_2 = class(item_wraith_weapon_1)
item_wraith_weapon_3 = class(item_wraith_weapon_1)
item_wraith_weapon_4 = class(item_wraith_weapon_1)
item_wraith_weapon_5 = class(item_wraith_weapon_1)

modifier_item_wraith_weapon = class({})
LinkLuaModifier("modifier_item_wraith_weapon", "items/wraith/item_wraith_weapon.lua", 0)

function modifier_item_wraith_weapon:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetSpecialValueFor("crit_damage")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_wraith_weapon:OnRefresh()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetSpecialValueFor("crit_damage")
end

function modifier_item_wraith_weapon:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_item_wraith_weapon:GetModifierBaseAttack_BonusDamage()
	return self.bonus_dmg
end

function modifier_item_wraith_weapon:GetModifierTotalDamageOutgoing_Percentage(params)
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

function modifier_item_wraith_weapon:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(self.crit_chance) then
		return self.crit_dmg
	end
end

function modifier_item_wraith_weapon:IsHidden()
	return true
end