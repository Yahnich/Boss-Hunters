item_unyielding_totem = class({})

function item_unyielding_totem:GetIntrinsicModifierName()
	return "modifier_item_unyielding_totem_passive"
end

function item_unyielding_totem:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_item_unyielding_totem_active", {duration = self:GetSpecialValueFor("duration")} )
	EmitSoundOn( "DOTA_Item.BlackKingBar.Activate", caster )
	
	caster:Dispel( )
end

item_unyielding_totem_2 = class(item_unyielding_totem)
item_unyielding_totem_3 = class(item_unyielding_totem)
item_unyielding_totem_4 = class(item_unyielding_totem)
item_unyielding_totem_5 = class(item_unyielding_totem)
item_unyielding_totem_6 = class(item_unyielding_totem)
item_unyielding_totem_7 = class(item_unyielding_totem)
item_unyielding_totem_8 = class(item_unyielding_totem)
item_unyielding_totem_9 = class(item_unyielding_totem)

modifier_item_unyielding_totem_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_unyielding_totem_passive", "items/item_unyielding_totem.lua" ,LUA_MODIFIER_MOTION_NONE )


modifier_item_unyielding_totem_active = class({})
LinkLuaModifier( "modifier_item_unyielding_totem_active", "items/item_unyielding_totem.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_unyielding_totem_active:OnCreated()
	self:OnRefresh()
end

function modifier_item_unyielding_totem_active:OnRefresh()
	self.dmg = self:GetSpecialValueFor("dmg_reduction")
	self.status = self:GetSpecialValueFor("status_amp_loss")
end

function modifier_item_unyielding_totem_active:OnDestroy()
end

function modifier_item_unyielding_totem_active:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_item_unyielding_totem_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_item_unyielding_totem_active:GetModifierTotalDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_item_unyielding_totem_active:GetModifierStatusAmplify_Percentage()
	return self.status
end
function modifier_item_unyielding_totem_active:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_item_unyielding_totem_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_item_unyielding_totem_active:StatusEffectPriority()
	return 10
end