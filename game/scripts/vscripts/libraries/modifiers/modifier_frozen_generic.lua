modifier_frozen_generic = class({})
function modifier_frozen_generic:OnCreated(table)
	if self:GetParent():HasModifier("modifier_status_immunity") then
		self:Destroy()
		return
	end
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_frozen_generic:OnIntervalThink()
	if self:GetParent():IsChilled() then
		self:GetParent():RemoveChill()
	end
end

function modifier_frozen_generic:CheckState()
	if not self:GetParent():IsBoss() then
		local state = { [MODIFIER_STATE_STUNNED] = true,
						[MODIFIER_STATE_FROZEN] = true}
		return state
	else
		local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVISIBLE] = false}
		return state
	end
end


function modifier_frozen_generic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, 
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}

	return funcs
end

function modifier_frozen_generic:GetModifierAttackSpeedBonus_Constant( params )
	if self:GetParent():IsBoss() then
		return -1000
	end
end

function modifier_frozen_generic:GetModifierPercentageCasttime()
	return -95
end

function modifier_frozen_generic:GetModifierTurnRate_Percentage()
	return -95
end

function modifier_frozen_generic:IsPurgable()
	return true
end

function modifier_frozen_generic:IsDebuff()
	return true
end

function modifier_frozen_generic:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf"
end

function modifier_frozen_generic:StatusEffectPriority()
	return 11
end

function modifier_frozen_generic:GetEffectName()
	return "particles/generic_frozen.vpcf"
end

function modifier_frozen_generic:GetTexture()
	return "winter_wyvern_cold_embrace"
end