modifier_frozen_generic = class({})
function modifier_frozen_generic:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_frozen_generic:OnIntervalThink()
	if self:GetParent():IsChilled() then
		self:GetParent():RemoveChill()
		if RollPercentage(25) then
			local units = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), 250, {})
			for _,unit in pairs(units) do
				unit:AddChill(self:GetAbility(), self:GetCaster(), 2.5)
				break
			end
		end
	end
end

function modifier_frozen_generic:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_FROZEN] = true}
	return state
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