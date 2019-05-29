modifier_chill_generic = class({})
function modifier_chill_generic:OnCreated(table)
	if IsServer() then
		if self:GetStackCount() > 99 then
			self:GetParent():Freeze(self:GetAbility(), self:GetCaster(), 1.5)
			self:Destroy()
		end
		self:StartIntervalThink(0.33)
	end
end

function modifier_chill_generic:OnRefresh(table)
	if IsServer() then
		if self:GetStackCount() > 99 then
			self:GetParent():Freeze(self:GetAbility(), self:GetCaster(), 1.5)
			self:Destroy()
		end
	end
end

function modifier_chill_generic:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() > 99 then
			self:GetParent():Freeze(self:GetAbility(), self:GetCaster(), 1.5)
			self:Destroy()
		end
	end
end

function modifier_chill_generic:GetTexture()
	return "ancient_apparition_cold_feet"
end

function modifier_chill_generic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_chill_generic:GetModifierMoveSpeedBonus_Percentage()
	return -1 * self:GetStackCount()
end

function modifier_chill_generic:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_chill_generic:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_dire.vpcf"
end

function modifier_chill_generic:StatusEffectPriority()
	return 10
end

function modifier_chill_generic:IsPurgable()
	return true
end

function modifier_chill_generic:IsDebuff()
	return true
end

