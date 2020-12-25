item_blade_of_storm = class({})

function item_blade_of_storm:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_item_blade_of_storm_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("DOTA_Item.Butterfly", caster)
	ParticleManager:FireParticle("particles/items2_fx/butterfly_active.vpcf", PATTACH_POINT_FOLLOW, caster)
end

function item_blade_of_storm:GetIntrinsicModifierName()
	return "modifier_item_blade_of_storm_passive"
end

function item_blade_of_storm:GetRuneSlots()
	return self:GetSpecialValueFor("rune_slots")
end

item_blade_of_storm_2 = class(item_blade_of_storm)
item_blade_of_storm_3 = class(item_blade_of_storm)
item_blade_of_storm_4 = class(item_blade_of_storm)
item_blade_of_storm_5 = class(item_blade_of_storm)
item_blade_of_storm_6 = class(item_blade_of_storm)
item_blade_of_storm_7 = class(item_blade_of_storm)
item_blade_of_storm_8 = class(item_blade_of_storm)
item_blade_of_storm_9 = class(item_blade_of_storm)

modifier_item_blade_of_storm_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_blade_of_storm_passive", "items/item_blade_of_storm.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_blade_of_storm_passive:OnCreatedSpecific()
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
end

function modifier_item_blade_of_storm_passive:OnRefreshSpecific()
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
end

function modifier_item_blade_of_storm_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_EVASION_CONSTANT )
	return funcs
end

function modifier_item_blade_of_storm_passive:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_blade_of_storm_passive:IsHidden()
	return true
end

modifier_item_blade_of_storm_active = class({})
LinkLuaModifier( "modifier_item_blade_of_storm_active", "items/item_blade_of_storm.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_blade_of_storm_active:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_UNSLOWABLE] = true}
end

function modifier_item_blade_of_storm_active:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_item_blade_of_storm_active:GetEffectName()
	return "particles/items2_fx/butterfly_buff.vpcf"
end