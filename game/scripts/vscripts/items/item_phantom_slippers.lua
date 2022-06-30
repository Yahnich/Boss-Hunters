item_phantom_slippers = class({})

function item_phantom_slippers:GetIntrinsicModifierName()
	return "modifier_item_phantom_slippers_passive"
end

function item_phantom_slippers:GetAssociatedModifierName()
	return "modifier_item_boots_of_speed_passive"
end

function item_phantom_slippers:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_phantom_slippers_phase", {duration = self:GetSpecialValueFor("duration")} )
end

item_phantom_slippers_2 = class(item_phantom_slippers)
item_phantom_slippers_3 = class(item_phantom_slippers)
item_phantom_slippers_4 = class(item_phantom_slippers)

function item_phantom_slippers_4:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_phantom_slippers_flight", {duration = self:GetSpecialValueFor("duration")} )
end

item_phantom_slippers_5 = class(item_phantom_slippers_4)
item_phantom_slippers_6 = class(item_phantom_slippers_4)
item_phantom_slippers_7 = class(item_phantom_slippers_4)
item_phantom_slippers_8 = class(item_phantom_slippers_4)
item_phantom_slippers_9 = class(item_phantom_slippers_4)

modifier_item_phantom_slippers_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_phantom_slippers_passive", "items/item_phantom_slippers.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_phantom_slippers_passive:OnCreatedSpecific()
	self.bonus_ms = self:GetSpecialValueFor("movespeed")
end

function modifier_item_phantom_slippers_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT )
	return funcs
end

function modifier_item_phantom_slippers_passive:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

modifier_item_phantom_slippers_phase = class({})
LinkLuaModifier( "modifier_item_phantom_slippers_phase", "items/item_phantom_slippers.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_phantom_slippers_phase:OnCreated()
	self.movespeed = self:GetSpecialValueFor("phase_speed")
	self.turnrate = self:GetSpecialValueFor("turnrate")
end

function modifier_item_phantom_slippers_phase:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_item_phantom_slippers_phase:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_TURN_RATE_OVERRIDE }
end

function modifier_item_phantom_slippers_phase:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_item_phantom_slippers_phase:GetModifierTurnRate_Override()
	return self.turnrate
end

function modifier_item_phantom_slippers_phase:GetEffectName()
	return "particles/items2_fx/phase_boots.vpcf"
end

modifier_item_phantom_slippers_flight = class(modifier_item_phantom_slippers_phase)
LinkLuaModifier( "modifier_item_phantom_slippers_flight", "items/item_phantom_slippers.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_phantom_slippers_flight:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end
