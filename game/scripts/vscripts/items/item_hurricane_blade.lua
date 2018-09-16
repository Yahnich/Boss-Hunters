item_hurricane_blade = class({})

function item_hurricane_blade:OnSpellStart()
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_hurricane_blade_disarm", {duration = self:GetSpecialValueFor("disarm_duration")})
end

function item_hurricane_blade:GetIntrinsicModifierName()
	return "modifier_item_hurricane_blade"
end

modifier_item_hurricane_blade = class(itemBaseClass)
LinkLuaModifier( "modifier_item_hurricane_blade", "items/item_hurricane_blade.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_hurricane_blade:OnCreated()
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
	
	self.disableChance = self:GetSpecialValueFor("disable_chance")
	self.disableDuration = self:GetSpecialValueFor("disable_duration")
end

function modifier_item_hurricane_blade:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_EVASION_CONSTANT,
			}
end

function modifier_item_hurricane_blade:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_hurricane_blade:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_hurricane_blade:IsHidden()
	return true
end

function modifier_item_hurricane_blade:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_hurricane_blade_disarm", "items/item_hurricane_blade.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_hurricane_blade_disarm = class({})

if IsServer() then
	function modifier_hurricane_blade_disarm:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_hurricane_blade_disarm:OnRemoved()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_hurricane_blade_disarm:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end

function modifier_hurricane_blade_disarm:GetEffectName()
	return "particles/items2_fx/heavens_halberd_debuff_disarm.vpcf"
end

function modifier_hurricane_blade_disarm:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end