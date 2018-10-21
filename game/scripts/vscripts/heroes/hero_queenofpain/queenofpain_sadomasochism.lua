queenofpain_sadomasochism = class({})
LinkLuaModifier( "modifier_queenofpain_sadomasochism", "heroes/hero_queenofpain/queenofpain_sadomasochism", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function queenofpain_sadomasochism:GetIntrinsicModifierName()
    return "modifier_queenofpain_sadomasochism"
end

modifier_queenofpain_sadomasochism = class({})

function modifier_queenofpain_sadomasochism:OnCreated()
	self.bonus = self:GetAbility():GetTalentSpecialValueFor("damage_amp")
end

function modifier_queenofpain_sadomasochism:OnRefresh()
	self.bonus = self:GetAbility():GetTalentSpecialValueFor("damage_amp")
end

function modifier_queenofpain_sadomasochism:DestroyOnExpire()
	return false
end

function modifier_queenofpain_sadomasochism:DeclareFunctions()
  local funcs = { 	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
  return funcs
end

function modifier_queenofpain_sadomasochism:GetModifierTotalDamageOutgoing_Percentage(params)
	return self.bonus
end

function modifier_queenofpain_sadomasochism:GetModifierIncomingDamage_Percentage(params)
	return self.bonus
end

function modifier_queenofpain_sadomasochism:IsHidden()
	return true
end