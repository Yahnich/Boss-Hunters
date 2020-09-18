item_trebuchet = class({})

function item_trebuchet:GetIntrinsicModifierName()
	return "modifier_item_trebuchet"
end

function item_trebuchet:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetTalentSpecialValueFor("active_duration")
	local distance = self:GetTalentSpecialValueFor("push_distance")
	caster:AddNewModifier(caster, self, "modifier_item_trebuchet_active", {duration = duration})
	caster:ApplyKnockBack(caster:GetAbsOrigin() + caster:GetForwardVector() * distance, 0.5, 0.5, distance, 0, caster, self, false)
	caster:EmitSound("DOTA_Item.ForceStaff.Activate")
end

modifier_item_trebuchet_active = class({})
LinkLuaModifier( "modifier_item_trebuchet_active", "items/item_trebuchet.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_trebuchet_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_item_trebuchet_active:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return 9999
	end
end

function modifier_item_trebuchet_active:GetEffectName()
	return "particles/items_fx/force_staff.vpcf"
end

modifier_item_trebuchet = class(itemBaseClass)
LinkLuaModifier( "modifier_item_trebuchet", "items/item_trebuchet.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_trebuchet:OnCreated()
	self.range = self:GetSpecialValueFor("bonus_range")
	self.str = self:GetSpecialValueFor("bonus_str")
	self.agi = self:GetSpecialValueFor("bonus_agi")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.as = self:GetSpecialValueFor("bonus_attack_speed")
	self.ms = self:GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_trebuchet:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,}
end

function modifier_item_trebuchet:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_trebuchet:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_item_trebuchet:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_trebuchet:GetModifierMoveSpeedBonus_Special_Boots()
	return self.ms
end

function modifier_item_trebuchet:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_item_trebuchet:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self.range
	end
end