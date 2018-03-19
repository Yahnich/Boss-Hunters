item_greater_crit = class({})
LinkLuaModifier( "modifier_item_crit_handle", "items/item_crit.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_greater_crit:GetIntrinsicModifierName()
	return "modifier_item_crit_handle"
end

item_crit2 = class(item_greater_crit)
item_crit3 = class(item_greater_crit)
item_crit4 = class(item_greater_crit)
item_crit5 = class(item_greater_crit)

modifier_item_crit_handle = class({})
function modifier_item_crit_handle:OnCreated()
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.crit_damage = self:GetSpecialValueFor("critical_bonus")
	self.crit_chance = self:GetSpecialValueFor("critical_chance")
end

function modifier_item_crit_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_crit_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
			}
end

function modifier_item_crit_handle:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end


function modifier_item_crit_handle:GetModifierPreAttack_CriticalStrike()
	if RollPercentage( self.crit_chance ) then
		return self.crit_damage
	end
end

function modifier_item_crit_handle:IsHidden()
	return true
end