guardian_fortitude = class({})

function guardian_fortitude:GetIntrinsicModifierName()
	return "modifier_guardian_fortitude_passive"
end

function modifier_guardian_fortitude_passive:OnCreated()
	self.resistance = self:GetTalentSpecialValueFor("total_resistance")
end

function modifier_guardian_fortitude_passive:OnRefresh()
	self.resistance = self:GetTalentSpecialValueFor("total_resistance")
end

function modifier_guardian_fortitude_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end


function modifier_guardian_fortitude_passive:GetModifierIncomingDamage_Percentage(params)
	return resistance
end

function modifier_guardian_fortitude_passive:BonusDebuffDuration_Constant()
	return self.resistance
end

function modifier_guardian_fortitude_passive:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and self:GetParent():HasAbility( params.ability:GetName() ) and self:GetParent():HasTalent("guardian_fortitude_talent_1") then
		params.unit:ModifyThreat( params.unit:FindTalentValue("guardian_fortitude_talent_1") )
	end
end