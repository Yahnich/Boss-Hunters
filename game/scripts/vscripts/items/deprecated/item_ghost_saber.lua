item_ghost_saber = class({})
LinkLuaModifier( "modifier_item_ghost_saber_passive", "items/item_ghost_saber.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_ghost_saber_active", "items/item_ghost_saber.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_ghost_saber:GetIntrinsicModifierName()
	return "modifier_item_ghost_saber_passive"	
end

function item_ghost_saber:OnSpellStart()
	EmitSoundOn("DOTA_Item.GhostScepter.Activate", self:GetCaster())
	if self:GetCursorTarget():GetTeam() == self:GetCaster():GetTeam() and not PlayerResource:IsDisableHelpSetForPlayerID(self:GetCursorTarget():GetPlayerID(), self:GetCaster():GetPlayerID()) then
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_ghost_saber_active", {Duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_item_ghost_saber_passive = class(itemBaseClass)
function modifier_item_ghost_saber_passive:OnCreated()
	self.bonus_agi = self:GetSpecialValueFor("bonus_stats")
	self.bonus_int = self:GetSpecialValueFor("bonus_stats")
	self.bonus_str = self:GetSpecialValueFor("bonus_stats")
end

function modifier_item_ghost_saber_passive:DeclareFunctions()
	return {	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			 	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			 	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_ghost_saber_passive:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_item_ghost_saber_passive:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_item_ghost_saber_passive:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_item_ghost_saber_passive:IsHidden()
	return true
end

function modifier_item_ghost_saber_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_ghost_saber_active = class({})
function modifier_item_ghost_saber_active:GetTextureName()
	return "ethereal_blade"
end

function modifier_item_ghost_saber_active:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true}
end

function modifier_item_ghost_saber_active:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_item_ghost_saber_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_necrolyte_spirit.vpcf"
end

function modifier_item_ghost_saber_active:StatusEffectPriority()
	return 11
end

function modifier_item_ghost_saber_active:IsDebuff()
	return false
end