item_phantom_staff = class({})
LinkLuaModifier( "modifier_item_phantom_staff", "items/item_phantom_staff.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_phantom_staff:OnSpellStart()
	EmitSoundOn("DOTA_Item.GhostScepter.Activate", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_phantom_staff", {Duration = self:GetSpecialValueFor("duration")})	
end

modifier_item_phantom_staff = class(itemBaseClass)
function modifier_item_phantom_staff:GetTextureName()
	return "ghost"
end

function modifier_item_phantom_staff:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true}
end

function modifier_item_phantom_staff:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_item_phantom_staff:GetStatusEffectName()
	return "particles/status_fx/status_effect_necrolyte_spirit.vpcf"
end

function modifier_item_phantom_staff:StatusEffectPriority()
	return 11
end

function modifier_item_phantom_staff:IsDebuff()
	return false
end