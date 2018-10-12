archangel_imperium_vici = class({})

function archangel_imperium_vici:GetIntrinsicModifierName()
	return "modifier_archangel_imperium_vici"
end

modifier_archangel_imperium_vici = class({})
LinkLuaModifier("modifier_archangel_imperium_vici", "bosses/boss_archangel/archangel_imperium_vici", LUA_MODIFIER_MOTION_NONE)

function modifier_archangel_imperium_vici:OnCreated()
	self.negSr = self:GetSpecialValueFor("neg_sr")
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
	self:StartIntervalThink(0.5)
end

function modifier_archangel_imperium_vici:OnRefresh()
	self.negSr = self:GetSpecialValueFor("neg_sr")
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
end

function modifier_archangel_imperium_vici:OnIntervalThink()
	self.ms = 0
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
end

function modifier_archangel_imperium_vici:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
end

function modifier_archangel_imperium_vici:CheckState()
	return {[MODIFIER_STATE_FLYING] = not self:GetCaster():PassivesDisabled()}
end

function modifier_archangel_imperium_vici:GetModifierStatusResistance()
	if not self:GetCaster():PassivesDisabled() then
		return self.negSr
	end
end

function modifier_archangel_imperium_vici:GetModifierMoveSpeed_AbsoluteMin()
	if not self:GetCaster():PassivesDisabled() then
		return self.ms
	end
end

function modifier_archangel_imperium_vici:IsHidden()
	return true
end