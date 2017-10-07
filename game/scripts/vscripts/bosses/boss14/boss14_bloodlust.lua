boss14_bloodlust = class({})

function boss14_bloodlust:GetIntrinsicModifierName()
	return "modifier_boss14_bloodlust_passive"
end

modifier_boss14_bloodlust_passive = class({})
LinkLuaModifier("modifier_boss14_bloodlust_passive", "bosses/boss14/boss14_bloodlust", 0)

function modifier_boss14_bloodlust_passive:OnCreated()
	self.ms = self:GetSpecialValueFor("movespeed")
	self.amp = self:GetSpecialValueFor("damage_amp")
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function modifier_boss14_bloodlust_passive:OnIntervalThink()
	if self:GetParent().AIprevioustarget then self:SetStackCount(self:GetParent().AIprevioustarget:GetThreat()) else self:DecrementStackCount() end
end

function modifier_boss14_bloodlust_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_boss14_bloodlust_passive:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount() * self.amp
end

function modifier_boss14_bloodlust_passive:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * self.ms
end

function modifier_boss14_bloodlust_passive:GetModifierModelScale()
	return math.min(100, self:GetStackCount() / 2)
end