modifier_kunkka_captains_rum = class({})

function modifier_kunkka_captains_rum:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_kunkka_captains_rum:OnCreated()
	self.damagereduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.movespeedbonus = self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	self.damageamp = self:GetAbility():GetSpecialValueFor("bonus_basedamage_perc")
	self.bonusdamage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_kunkka_captains_rum:GetModifierIncomingDamage_Percentage()
    return self.damagereduction
end

function modifier_kunkka_captains_rum:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeedbonus
end

function modifier_kunkka_captains_rum: GetModifierBaseDamageOutgoing_Percentage()
    return self.damageamp
end

function modifier_kunkka_captains_rum:GetModifierPreAttack_BonusDamage()
    return self.bonusdamage
end

function modifier_kunkka_captains_rum:DestroyOnExpire()
    return true
end

function modifier_kunkka_captains_rum:IsPurgable()
    return false
end

function modifier_kunkka_captains_rum:RemoveOnDeath()
    return true
end