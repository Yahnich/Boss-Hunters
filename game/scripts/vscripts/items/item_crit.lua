item_crit1 = class({})
LinkLuaModifier( "modifier_item_crit_handle", "items/item_crit.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_crit", "items/item_crit.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_crit1:GetIntrinsicModifierName()
	return "modifier_item_crit_handle"
end

item_crit2 = class({item_crit1})
function item_crit2:GetIntrinsicModifierName()
	return "modifier_item_crit_handle"
end

item_crit3 = class({item_crit1})
function item_crit3:GetIntrinsicModifierName()
	return "modifier_item_crit_handle"
end

item_crit4 = class({item_crit1})
function item_crit4:GetIntrinsicModifierName()
	return "modifier_item_crit_handle"
end

modifier_item_crit_handle = class({})
function modifier_item_crit_handle:OnCreated(table)
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_crit_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_crit_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_EVENT_ON_ATTACK_START
			}
end

function modifier_item_crit_handle:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_crit_handle:OnAttackStart(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage(self:GetAbility():GetSpecialValueFor("critical_chance")) then
			params.attacker:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_crit", {})
		end
	end
end

function modifier_item_crit_handle:IsHidden()
	return true
end

modifier_item_crit = class({})
function modifier_item_crit:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_item_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_EVENT_ON_ATTACK_LANDED
			}
end

function modifier_item_crit:GetModifierPreAttack_CriticalStrike()
	return self:GetAbility():GetSpecialValueFor("critical_bonus")
end

function modifier_item_crit:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.attacker:RemoveModifierByName("modifier_item_crit")
		end
	end
end

function modifier_item_crit:IsHidden()
	return true
end