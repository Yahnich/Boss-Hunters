item_phantomblade = class({})

function item_phantomblade:GetIntrinsicModifierName()
	return "modifier_item_phantomblade_passive"
end

function item_phantomblade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("DOTA_Item.GhostScepter.Activate", caster)
	self:FireTrackingProjectile("particles/items_fx/ethereal_blade.vpcf", target, 1275)
end

function item_phantomblade:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	if target:GetTeam() == caster:GetTeam() and not PlayerResource:IsDisableHelpSetForPlayerID(target:GetPlayerID(), caster:GetPlayerID()) then
		target:AddNewModifier(caster, self, "modifier_item_phantomblade_buff", {Duration = self:GetSpecialValueFor("duration")})
	elseif not target:IsSameTeam( caster ) then
		target:AddNewModifier(caster, self, "modifier_item_phantomblade_debuff", {Duration = self:GetSpecialValueFor("duration")})
	end
end

item_phantomblade_2 = class(item_phantomblade)
item_phantomblade_3 = class(item_phantomblade)
item_phantomblade_4 = class(item_phantomblade)
item_phantomblade_5 = class(item_phantomblade)
item_phantomblade_6 = class(item_phantomblade)
item_phantomblade_7 = class(item_phantomblade)
item_phantomblade_8 = class(item_phantomblade)
item_phantomblade_9 = class(item_phantomblade)


modifier_item_phantomblade_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_phantomblade_passive", "items/item_phantomblade.lua", LUA_MODIFIER_MOTION_NONE )

modifier_item_phantomblade_buff = class({})
LinkLuaModifier( "modifier_item_phantomblade_buff", "items/item_phantomblade.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_phantomblade_buff:OnCreated()
	self.restoration_amp = self:GetSpecialValueFor("restoration_amp")
	self.status_resist = self:GetSpecialValueFor("status_resist")
end

function modifier_item_phantomblade_buff:OnRefresh()
end

function modifier_item_phantomblade_buff:GetTextureName()
	return "ethereal_blade"
end

function modifier_item_phantomblade_buff:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true}
end

function modifier_item_phantomblade_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_RESTORE_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function modifier_item_phantomblade_buff:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_item_phantomblade_buff:GetModifierHealAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_buff:GetModifierHPRegenAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_buff:GetModifierMPRestoreAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_buff:GetModifierMPRegenAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_buff:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_item_phantomblade_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_necrolyte_spirit.vpcf"
end

function modifier_item_phantomblade_buff:StatusEffectPriority()
	return 11
end

modifier_item_phantomblade_debuff = class({})
LinkLuaModifier( "modifier_item_phantomblade_debuff", "items/item_phantomblade.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_phantomblade_debuff:OnCreated()
	self.restoration_amp = self:GetSpecialValueFor("restoration_amp") * (-1)
	self.status_resist = self:GetSpecialValueFor("status_resist") * (-1)
end

function modifier_item_phantomblade_debuff:OnRefresh()
end

function modifier_item_phantomblade_debuff:GetTextureName()
	return "ethereal_blade"
end

function modifier_item_phantomblade_debuff:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_DISARMED] = true}
end

function modifier_item_phantomblade_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_RESTORE_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function modifier_item_phantomblade_debuff:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_item_phantomblade_debuff:GetModifierHPRegenAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_debuff:GetModifierHealAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_debuff:GetModifierMPRestoreAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_debuff:GetModifierMPRegenAmplify_Percentage()
	return self.restoration_amp
end

function modifier_item_phantomblade_debuff:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_item_phantomblade_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_necrolyte_spirit.vpcf"
end

function modifier_item_phantomblade_debuff:StatusEffectPriority()
	return 11
end