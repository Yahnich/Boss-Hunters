druid_bear_demolish = class({})
LinkLuaModifier( "modifier_druid_bear_demolish", "heroes/hero_lone_druid/druid_bear_demolish" ,LUA_MODIFIER_MOTION_NONE )

function druid_bear_demolish:GetIntrinsicModifierName()
	return "modifier_druid_bear_demolish"
end

modifier_druid_bear_demolish = class({})

function modifier_druid_bear_demolish:OnCreated()
	self.bonus_mr = self:GetTalentSpecialValueFor("bonus_mr")
end

function modifier_druid_bear_demolish:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
  }
  return funcs
end

function modifier_druid_bear_demolish:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local distance = self:GetTalentSpecialValueFor("cleave_distance")
			local startRadius = self:GetTalentSpecialValueFor("cleave_start")
			local endRadius = self:GetTalentSpecialValueFor("cleave_end")

			local cleave = self:GetTalentSpecialValueFor("cleave_damage")
			local damage = params.original_damage*self:GetTalentSpecialValueFor("cleave_damage")/100
			self:GetAbility():Cleave(params.target, damage, startRadius, endRadius, distance, "particles/units/heroes/hero_sven/sven_spell_great_cleave_gods_strength_crit.vpcf" )
		end
	end
end

function modifier_druid_bear_demolish:GetModifierMagicalResistanceBonus()
	return self.bonus_mr
end

function modifier_druid_bear_demolish:IsHidden()
	return true
end

function modifier_druid_bear_demolish:IsPurgeException()
	return false
end

function modifier_druid_bear_demolish:IsPurgable()
	return false
end