sylph_winds_aid = sylph_winds_aid or class({})

function sylph_winds_aid:OnSpellStart()
	EmitSoundOn("Hero_Windrunner.ShackleshotStun", self:GetCaster())
	local windbuff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_winds_aid_buff", {duration = self:GetSpecialValueFor("duration")})
	local zephyr = self:GetCaster():FindModifierByName("modifier_sylph_innate_zephyr_passive")
	windbuff:SetStackCount(zephyr:GetStackCount())
	zephyr:SetStackCount(0)
end

LinkLuaModifier( "modifier_sylph_winds_aid_buff", "heroes/sylph/sylph_winds_aid.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
modifier_sylph_winds_aid_buff = modifier_sylph_winds_aid_buff or class({})

function modifier_sylph_winds_aid_buff:OnCreated()
	self.critical_strike = self:GetAbility():GetSpecialValueFor("crit_per_stack")
end

function modifier_sylph_winds_aid_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
	return funcs
end

function modifier_sylph_winds_aid_buff:CheckState()
	local state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	return state
end

function modifier_sylph_winds_aid_buff:GetModifierPreAttack_CriticalStrike()
	return 100 + self.critical_strike * self:GetStackCount()
end

function modifier_sylph_winds_aid_buff:GetEffectName()
	return "particles/heroes/sylph/sylph_winds_aid.vpcf"
end