queenofpain_sadomasochism = class({})
LinkLuaModifier( "modifier_queenofpain_sadomasochism", "heroes/hero_queenofpain/queenofpain_sadomasochism", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function queenofpain_sadomasochism:GetIntrinsicModifierName()
    return "modifier_queenofpain_sadomasochism"
end

modifier_queenofpain_sadomasochism = class({})

function modifier_queenofpain_sadomasochism:OnCreated()
	self:OnRefresh()
end

function modifier_queenofpain_sadomasochism:OnRefresh()
	self.dmg = self:GetAbility():GetSpecialValueFor("damage_amp")
	self.area = self:GetAbility():GetSpecialValueFor("area_dmg")
	self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100
	self.minionMult = self:GetAbility():GetSpecialValueFor("minion_lifesteal") / 100
	self.stack_bonus = self:GetAbility():GetSpecialValueFor("stack_increase")
	self.duration = self:GetAbility():GetSpecialValueFor("stack_duration")
	self:GetParent():HookInModifier( "GetModifierAreaDamage", self )
end

function modifier_queenofpain_sadomasochism:OnDestroy()
	self:GetParent():HookOutModifier( "GetModifierAreaDamage", self )
end

function modifier_queenofpain_sadomasochism:DestroyOnExpire()
	return false
end

function modifier_queenofpain_sadomasochism:DeclareFunctions()
  local funcs = { 	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
					MODIFIER_EVENT_ON_TAKEDAMAGE}
  return funcs
end

function modifier_queenofpain_sadomasochism:OnAbilityFullyCast( params )
	if params.unit == self:GetCaster() and not params.ability:IsItem() then
		local duration = self.duration * self:GetCaster():GetStatusAmplification()
		self:AddIndependentStack( duration )
		self:SetDuration( duration, true )
	end
end

function modifier_queenofpain_sadomasochism:GetModifierTotalDamageOutgoing_Percentage(params)
	return self.dmg + self.stack_bonus * self:GetStackCount()
end

function modifier_queenofpain_sadomasochism:GetModifierAreaDamage(params)
	return self.area + self.stack_bonus * self:GetStackCount()
end

function modifier_queenofpain_sadomasochism:OnTakeDamage(params)
	if params.unit ~= params.attacker and params.attacker == self:GetCaster() and params.attacker:GetHealth() > 0 and params.attacker:GetHealthDeficit() > 0 then
		local lifesteal = self.lifesteal + (self.stack_bonus / 100) * self:GetStackCount()
		if params.unit:IsMinion() and params.inflictor then
			lifesteal = lifesteal * self.minionMult
		end
		ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
		ParticleManager:FireParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker, {[1] = "attach_hitloc"})
		params.attacker:HealEvent( params.damage * lifesteal, self:GetAbility(), params.attacker)
	end
end

function modifier_queenofpain_sadomasochism:IsHidden()
	return self:GetStackCount() == 0
end

function modifier_queenofpain_sadomasochism:DestroyOnExpire()
	return false
end