item_wings_of_icarus = class({})

function item_wings_of_icarus:GetIntrinsicModifierName()
	return "modifier_item_wings_of_icarus_passive"
end

function item_wings_of_icarus:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_wings_of_icarus_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_item_wings_of_icarus_passive = class(itemBaseClass)
LinkLuaModifier( "modifier_item_wings_of_icarus_passive", "items/item_wings_of_icarus.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_wings_of_icarus_passive:OnCreated()
	self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
end

function modifier_item_wings_of_icarus_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE}
end

function modifier_item_wings_of_icarus_passive:GetModifierMoveSpeedBonus_Special_Boots()
	return self.bonus_ms
end

modifier_item_wings_of_icarus_active = class({})
LinkLuaModifier( "modifier_item_wings_of_icarus_active", "items/item_wings_of_icarus.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_wings_of_icarus_active:OnCreated()
	self.bonus_ms = self:GetSpecialValueFor("active_ms")
end

function modifier_item_wings_of_icarus_active:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 128, true)
	end
end

function modifier_item_wings_of_icarus_active:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] =  true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] =  true,}
end

function modifier_item_wings_of_icarus_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_item_wings_of_icarus_active:GetModifierMoveSpeed_AbsoluteMin()
	return self.bonus_ms
end

function modifier_item_wings_of_icarus_active:GetEffectName()
	return "particles/econ/events/ti6/phase_boots_ti6.vpcf"
end