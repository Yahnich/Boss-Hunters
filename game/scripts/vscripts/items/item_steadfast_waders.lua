item_steadfast_waders = class({})

function item_steadfast_waders:GetIntrinsicModifierName()
	return "modifier_item_steadfast_waders_passive"
end

function item_steadfast_waders:GetAssociatedModifierName()
	return "modifier_item_boots_of_speed_passive"
end

function item_steadfast_waders:ShouldUseResources()
	return true
end

item_steadfast_waders_2 = class(item_steadfast_waders)
item_steadfast_waders_3 = class(item_steadfast_waders)
item_steadfast_waders_4 = class(item_steadfast_waders)
item_steadfast_waders_5 = class(item_steadfast_waders)
item_steadfast_waders_6 = class(item_steadfast_waders)
item_steadfast_waders_7 = class(item_steadfast_waders)
item_steadfast_waders_8 = class(item_steadfast_waders)
item_steadfast_waders_9 = class(item_steadfast_waders)

modifier_item_steadfast_waders_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_steadfast_waders_passive", "items/item_steadfast_waders.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_steadfast_waders_passive:OnCreatedSpecific()
	self.min_ms = self:GetSpecialValueFor("min_movespeed")
	self.ms = self:GetSpecialValueFor("movespeed")
	self.restore = self:GetSpecialValueFor("restore_amount")
end

function modifier_item_steadfast_waders_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN )
	table.insert( funcs, MODIFIER_PROPERTY_ABSORB_SPELL )
	table.insert( funcs, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT )
	return funcs
end

function modifier_item_steadfast_waders_passive:CheckState()
	if self:GetAbility():GetLevel() >= 2 then
		return {[MODIFIER_STATE_UNSLOWABLE] = true, [MODIFIER_STATE_ROOTED] = false}
	end
end

function modifier_item_steadfast_waders_passive:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_item_steadfast_waders_passive:GetModifierMoveSpeed_AbsoluteMin()
	return self.min_ms
end

function modifier_item_steadfast_waders_passive:GetAbsorbSpell( params )
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if ability:IsCooldownReady() then
		ability:SetCooldown()
		Timers:CreateTimer(function()
			caster:HealEvent( self.restore, ability, caster )
			caster:RestoreMana( self.restore )
			caster:Dispel( caster, true )
		end)
	end
end

function modifier_item_steadfast_waders_passive:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end