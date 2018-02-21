bristleback_yer_mum = class({})

function bristleback_yer_mum:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_bristleback_yer_mum", {duration = self:GetTalentSpecialValueFor("duration")})
end

function bristleback_yer_mum:IsStealable()
	return true
end

function bristleback_yer_mum:IsHiddenWhenStolen()
	return false
end

modifier_bristleback_yer_mum = class({})
LinkLuaModifier("modifier_bristleback_yer_mum", "heroes/hero_bristleback/bristleback_yer_mum", 0)

if IsServer() then
	function modifier_bristleback_yer_mum:OnCreated()
		self.chance = self:GetTalentSpecialValueFor("reduction_chance")
		self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_bristleback_yer_mum:OnRefresh()
		self.chance = self:GetTalentSpecialValueFor("reduction_chance")
		self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_bristleback_yer_mum:OnRemoved()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_bristleback_yer_mum:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_bristleback_yer_mum:GetModifierTotalDamageOutgoing_Percentage(params)
	if RollPercentage(self.chance) then return self.reduction end
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