bristleback_yer_mum = class({})

function bristleback_yer_mum:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier(caster, self, "modifier_bristleback_yer_mum", {duration = self:GetSpecialValueFor("duration")})
end

function bristleback_yer_mum:IsStealable()
	return true
end

function bristleback_yer_mum:IsHiddenWhenStolen()
	return false
end

modifier_bristleback_yer_mum = class({})
LinkLuaModifier("modifier_bristleback_yer_mum", "heroes/hero_bristleback/bristleback_yer_mum", 0)

function modifier_bristleback_yer_mum:OnCreated()
	self:OnRefresh()
end

function modifier_bristleback_yer_mum:OnRefresh()
	self.attackspeed = self:GetSpecialValueFor("attackspeed_increase")
	self.reduction = self:GetSpecialValueFor("damage_reduction")
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_yer_mum_2")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_bristleback_yer_mum_1")
	if self.talent1 then
		self.lifesteal = self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_yer_mum_1")
		self:GetParent():HookInModifier("GetModifierLifestealTargetBonus", self )
	end
end

function modifier_bristleback_yer_mum:OnDestroy()
	if self.talent1 then
		self:GetParent():HookOutModifier("GetModifierLifestealTargetBonus", self )
	end
end

function modifier_bristleback_yer_mum:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_bristleback_yer_mum:DeclareFunctions()
	return { MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_bristleback_yer_mum:GetModifierAttackSpeedBonus_Constant(params)
	return self.attackspeed
end

function modifier_bristleback_yer_mum:GetModifierBaseDamageOutgoing_Percentage(params)
	return self.reduction
end

function modifier_bristleback_yer_mum:GetModifierTotalDamageOutgoing_Percentage(params)
	return self.amp
end

function modifier_bristleback_yer_mum:GetModifierLifestealTargetBonus(params)
	return self.lifesteal
end

function modifier_bristleback_yer_mum:GetTauntTarget()
	return self:GetCaster()
end

function modifier_bristleback_yer_mum:GetEffectName()
	return "particles/brd_taunt/brd_taunt_mark_base.vpcf"
end

function modifier_bristleback_yer_mum:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_bristleback_yer_mum:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_bristleback_yer_mum:StatusEffectPriority()
	return 10
end

function modifier_bristleback_yer_mum:IsPurgable()
	return false
end

function modifier_bristleback_yer_mum:IsDebuff()
	return true
end