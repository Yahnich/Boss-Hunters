guardian_fortitude = class({})

function guardian_fortitude:GetIntrinsicModifierName()
	return "modifier_guardian_fortitude_passive"
end

modifier_guardian_fortitude_passive = class({})
LinkLuaModifier("modifier_guardian_fortitude_passive", "heroes/guardian/guardian_fortitude.lua", 0)

function modifier_guardian_fortitude_passive:OnCreated()
	self.resistance = self:GetAbility():GetTalentSpecialValueFor("total_resistance")
	if self:GetParent():HasScepter() then
		self.resistance = self:GetAbility():GetTalentSpecialValueFor("scepter_total_resistance")
	end
end

function modifier_guardian_fortitude_passive:OnRefresh()
	self.resistance = self:GetAbility():GetTalentSpecialValueFor("total_resistance")
	if self:GetParent():HasScepter() then
		self.resistance = self:GetAbility():GetTalentSpecialValueFor("scepter_total_resistance")
	end
end

function modifier_guardian_fortitude_passive:IsHidden()
	return true
end

function modifier_guardian_fortitude_passive:IsAura()
	return self:GetParent():HasScepter()
end

function modifier_guardian_fortitude_passive:GetAuraEntityReject( entity )
	if IsServer() then
		return self:GetParent() == entity
	end
end

--------------------------------------------------------------------------------

function modifier_guardian_fortitude_passive:GetModifierAura()
	if self:GetParent():HasScepter() then
		return "modifier_guardian_fortitude_scepter"
	end
end

--------------------------------------------------------------------------------

function modifier_guardian_fortitude_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_guardian_fortitude_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_guardian_fortitude_passive:GetAuraRadius()
	return 900
end

--------------------------------------------------------------------------------
function modifier_guardian_fortitude_passive:IsPurgable()
    return false
end

function modifier_guardian_fortitude_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end


function modifier_guardian_fortitude_passive:GetModifierIncomingDamage_Percentage(params)
	return self.resistance
end

function modifier_guardian_fortitude_passive:BonusDebuffDuration_Constant()
	return self.resistance
end

function modifier_guardian_fortitude_passive:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and self:GetParent():HasAbility( params.ability:GetName() ) and self:GetParent():HasTalent("guardian_fortitude_talent_1") then
		params.unit:ModifyThreat( params.unit:FindTalentValue("guardian_fortitude_talent_1") * params.unit:GetLevel() )
	end
end

modifier_guardian_fortitude_scepter = class({})
LinkLuaModifier("modifier_guardian_fortitude_scepter", "heroes/guardian/guardian_fortitude.lua", 0)

function modifier_guardian_fortitude_scepter:OnCreated()
	self.resistance = self:GetAbility():GetTalentSpecialValueFor("total_resistance")
end

function modifier_guardian_fortitude_scepter:OnRefresh()
	self.resistance = self:GetAbility():GetTalentSpecialValueFor("total_resistance")
end

function modifier_guardian_fortitude_scepter:IsHidden()
	return false
end
--------------------------------------------------------------------------------
function modifier_guardian_fortitude_scepter:IsPurgable()
    return false
end

function modifier_guardian_fortitude_scepter:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end


function modifier_guardian_fortitude_scepter:GetModifierIncomingDamage_Percentage(params)
	return self.resistance
end

function modifier_guardian_fortitude_scepter:BonusDebuffDuration_Constant()
	return self.resistance
end