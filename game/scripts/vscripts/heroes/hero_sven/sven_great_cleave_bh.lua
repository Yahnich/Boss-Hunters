sven_great_cleave_bh = class({})

function sven_great_cleave_bh:GetIntrinsicModifierName()
	return "modifier_sven_great_cleave_bh"
end

LinkLuaModifier( "modifier_sven_great_cleave_bh", "heroes/hero_sven/sven_great_cleave_bh" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_great_cleave_bh = class({})


function modifier_sven_great_cleave_bh:OnCreated()
	self.cleave = self:GetAbility():GetSpecialValueFor("great_cleave_damage")
	
	self.distance = self:GetAbility():GetSpecialValueFor("cleave_distance")
	self.startRadius = self:GetAbility():GetSpecialValueFor("cleave_starting_width")
	self.endRadius = self:GetAbility():GetSpecialValueFor("cleave_ending_width")
end

function modifier_sven_great_cleave_bh:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_sven_great_cleave_bh:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not self:GetAbility():GetToggleState() then
			local damage = params.original_damage*self.cleave/100
			local caster = self:GetParent()
			DoCleaveAttack(caster, params.target, self:GetAbility(), damage, self.startRadius, self.endRadius, self.distance, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
		end
	end
end

function modifier_sven_great_cleave_bh:IsHidden()
	return true
end