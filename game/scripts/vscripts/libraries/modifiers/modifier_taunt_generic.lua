modifier_taunt_generic = class({})
function modifier_taunt_generic:OnCreated(table)
	if IsServer() then
		self:GetParent():SetForceAttackTarget(self:GetCaster())
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_taunt_generic:OnDestroy()
	if IsServer() then
		self:GetParent():SetForceAttackTarget(nil)
	end
end

function modifier_taunt_generic:OnIntervalThink()
	self:GetParent():SetForceAttackTarget(self:GetCaster())

	local newOrder = {
 		UnitIndex = self:GetParent():entindex(), 
 		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
 		TargetIndex = self:GetCaster():entindex(), --Optional.  Only used when targeting units
 	}
 
	ExecuteOrderFromTable(newOrder)
end

function modifier_taunt_generic:GetTauntTarget()
	return self:GetCaster()
end

function modifier_taunt_generic:GetEffectName()
	return "particles/brd_taunt/brd_taunt_mark_base.vpcf"
end

function modifier_taunt_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_taunt_generic:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_taunt_generic:StatusEffectPriority()
	return 10
end

function modifier_taunt_generic:IsPurgable()
	return true
end

function modifier_taunt_generic:IsDebuff()
	return true
end

