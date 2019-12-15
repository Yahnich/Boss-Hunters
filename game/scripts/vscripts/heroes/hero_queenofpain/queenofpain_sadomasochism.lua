queenofpain_sadomasochism = class({})
LinkLuaModifier( "modifier_queenofpain_sadomasochism", "heroes/hero_queenofpain/queenofpain_sadomasochism", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function queenofpain_sadomasochism:GetIntrinsicModifierName()
    return "modifier_queenofpain_sadomasochism"
end

modifier_queenofpain_sadomasochism = class({})

function modifier_queenofpain_sadomasochism:OnCreated()
	self.bonus = self:GetAbility():GetTalentSpecialValueFor("damage_amp")
	self.area = self:GetAbility():GetTalentSpecialValueFor("area_dmg")
	self.lifesteal = self:GetAbility():GetTalentSpecialValueFor("lifesteal") / 100
	self.minionLifesteal = self:GetAbility():GetTalentSpecialValueFor("minion_lifesteal") / 100
end

function modifier_queenofpain_sadomasochism:OnRefresh()
	self.bonus = self:GetAbility():GetTalentSpecialValueFor("damage_amp")
	self.area = self:GetAbility():GetTalentSpecialValueFor("area_dmg")
	self.lifesteal = self:GetAbility():GetTalentSpecialValueFor("lifesteal") / 100
	self.minionLifesteal = self:GetAbility():GetTalentSpecialValueFor("minion_lifesteal") / 100
end

function modifier_queenofpain_sadomasochism:DestroyOnExpire()
	return false
end

function modifier_queenofpain_sadomasochism:DeclareFunctions()
  local funcs = { 	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_EVENT_ON_TAKEDAMAGE}
  return funcs
end

function modifier_queenofpain_sadomasochism:GetModifierTotalDamageOutgoing_Percentage(params)
	return self.bonus
end

function modifier_queenofpain_sadomasochism:GetModifierAreaDamage(params)
	return self.area
end

function modifier_queenofpain_sadomasochism:OnTakeDamage(params)
	if params.unit ~= params.attacker and params.attacker == self:GetCaster() and params.attacker:GetHealth() ~= 0 and params.attacker:GetHealthDeficit() > 0 then
		local lifesteal = TernaryOperator( self.minionLifesteal, params.unit:IsMinion(), self.lifesteal )
		ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
		ParticleManager:FireParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker, {[1] = "attach_hitloc"})
		params.attacker:HealEvent( params.damage * lifesteal, self:GetAbility(), params.attacker)
	end
end

function modifier_queenofpain_sadomasochism:IsHidden()
	return true
end