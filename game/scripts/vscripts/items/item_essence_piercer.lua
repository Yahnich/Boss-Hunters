item_essence_piercer = class({})

function item_essence_piercer:GetIntrinsicModifierName()
	return "modifier_item_essence_piercer_passive"
end

function item_essence_piercer:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:RemoveModifierByNameAndCaster("modifier_item_essence_piercer_active", caster)
	if self.currTarget and not self.currTarget:IsNull() then self.currTarget:RemoveModifierByNameAndCaster("modifier_item_essence_piercer_active", caster) end
	self.currTarget = target
	target:AddNewModifier(caster, self, "modifier_item_essence_piercer_active", {})
end

LinkLuaModifier( "modifier_item_essence_piercer_passive", "items/item_essence_piercer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_essence_piercer_passive = class({})
function modifier_item_essence_piercer_passive:OnCreated()
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.spellamp = self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_essence_piercer_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,}
end

function modifier_item_essence_piercer_passive:GetModifierCastRangeBonus()
	return self.castrange
end

function modifier_item_essence_piercer_passive:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_essence_piercer_passive:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end
function modifier_item_essence_piercer_passive:GetModifierCastRangeBonus()
	return self.as
end

function modifier_item_essence_piercer_passive:IsHidden()
	return true
end

function modifier_item_essence_piercer_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_item_essence_piercer_active", "items/item_essence_piercer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_essence_piercer_active = class({})

function modifier_item_essence_piercer_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_item_essence_piercer_active:OnCreated()
	self:GetAbility().currTarget = self:GetParent()
end

function modifier_item_essence_piercer_active:OnDestroy()
	self:GetAbility().currTarget = nil
end

function modifier_item_essence_piercer_active:GetModifierIncomingDamage_Percentage(params)
	return self:GetSpecialValueFor("target_amp")
end

function modifier_item_essence_piercer_active:GetEffectName()
	return "particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_track_trail.vpcf"
end