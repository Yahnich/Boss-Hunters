item_focused_lens = class({})

function item_focused_lens:GetIntrinsicModifierName()
	return "modifier_item_focused_lens_passive"
end

function item_focused_lens:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:RemoveModifierByNameAndCaster("modifier_item_focused_lens_active", caster)
	if self.currTarget and not self.currTarget:IsNull() then self.currTarget:RemoveModifierByNameAndCaster("modifier_item_focused_lens_active", caster) end
	self.currTarget = target
	target:AddNewModifier(caster, self, "modifier_item_focused_lens_active", {})
end

LinkLuaModifier( "modifier_item_focused_lens_passive", "items/item_focused_lens.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_focused_lens_passive = class({})
function modifier_item_focused_lens_passive:OnCreated()
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	self.targetrange = self:GetAbility():GetSpecialValueFor("target_cast_range")
end

function modifier_item_focused_lens_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS}
end

function modifier_item_focused_lens_passive:GetModifierCastRangeBonus()
	local castrange = self.castrange
	if self:GetAbility().currTarget 
	and not self:GetAbility().currTarget:IsNull() then
		castrange = castrange + self.targetrange
	end
	return castrange
end

function modifier_item_focused_lens_passive:IsHidden()
	return true
end

function modifier_item_focused_lens_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_item_focused_lens_active", "items/item_focused_lens.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_focused_lens_active = class({})

function modifier_item_focused_lens_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_item_focused_lens_active:OnCreated()
	self:GetAbility().currTarget = self:GetParent()
end

function modifier_item_focused_lens_active:OnDestroy()
	self:GetAbility().currTarget = nil
end

function modifier_item_focused_lens_active:GetModifierIncomingDamage_Percentage(params)
	if params.attacker == self:GetCaster() then
		return self:GetSpecialValueFor("target_amp")
	end
end

function modifier_item_focused_lens_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_focused_lens_active:GetEffectName()
	return "particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_track_trail.vpcf"
end