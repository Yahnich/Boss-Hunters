oracle_innate = class({})
LinkLuaModifier("modifier_oracle_innate_offense", "heroes/hero_oracle/oracle_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_oracle_innate_defense", "heroes/hero_oracle/oracle_innate", LUA_MODIFIER_MOTION_NONE)

function oracle_innate:IsStealable()
    return false
end

function oracle_innate:IsHiddenWhenStolen()
    return false
end

function oracle_innate:GetAbilityTextureName()
	if IsClient() then
		local caster = self:GetCaster()
		--Offense
	    if caster:HasModifier("modifier_oracle_innate_offense") then
	    	return "custom/oracle_fortunes_end_crimson"

	    --Defense
	    elseif caster:HasModifier("modifier_oracle_innate_defense") then
	    	return "custom/oracle_fortunes_end_immortal"

	    --Balance
	    else
	    	return "custom/oracle_balance"
	    end
	end
end

function oracle_innate:OnSpellStart()
    local caster = self:GetCaster()

    --Defense
    if caster:HasModifier("modifier_oracle_innate_offense") then
    	caster:RemoveModifierByName("modifier_oracle_innate_offense")
    	caster:AddNewModifier(caster, self, "modifier_oracle_innate_defense", {})

    --Balance
    elseif caster:HasModifier("modifier_oracle_innate_defense") then
    	caster:RemoveModifierByName("modifier_oracle_innate_defense")

    --Offense
    else
    	caster:AddNewModifier(caster, self, "modifier_oracle_innate_offense", {})

    end
end

modifier_oracle_innate_offense = class({})
function modifier_oracle_innate_offense:OnCreated(table)
	self.damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.heal = -self:GetTalentSpecialValueFor("bonus_healing")
	self.mana = self:GetTalentSpecialValueFor("mana_cost")
end

function modifier_oracle_innate_offense:OnRefresh(table)
	self.damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.heal = -self:GetTalentSpecialValueFor("bonus_healing")
	self.mana = self:GetTalentSpecialValueFor("mana_cost")
end

function modifier_oracle_innate_offense:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING}
	return funcs
end

function modifier_oracle_innate_offense:GetModifierHealAmplify_Percentage()
	return self.heal
end

function modifier_oracle_innate_offense:GetModifierTotalDamageOutgoing_Percentage()
	return self.damage
end

function modifier_oracle_innate_offense:GetModifierPercentageManacostStacking()
	return self.mana  * (-1)
end

function modifier_oracle_innate_offense:GetTexture()
    return "custom/oracle_fortunes_end_crimson"
end

function modifier_oracle_innate_offense:IsDebuff()
	return false
end

function modifier_oracle_innate_offense:IsPurgable()
	return false
end

function modifier_oracle_innate_offense:IsPurgeException()
	return false
end

modifier_oracle_innate_defense = class({})
function modifier_oracle_innate_defense:OnCreated(table)
	self.damage = -self:GetTalentSpecialValueFor("bonus_damage")
	self.heal = self:GetTalentSpecialValueFor("bonus_healing")
	self.mana = self:GetTalentSpecialValueFor("mana_cost")
end

function modifier_oracle_innate_defense:OnRefresh(table)
	self.damage = -self:GetTalentSpecialValueFor("bonus_damage")
	self.heal = self:GetTalentSpecialValueFor("bonus_healing")
	self.mana = self:GetTalentSpecialValueFor("mana_cost")
end

function modifier_oracle_innate_defense:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING}
	return funcs
end

function modifier_oracle_innate_defense:GetModifierHealAmplify_Percentage()
	return self.heal
end

function modifier_oracle_innate_defense:GetModifierTotalDamageOutgoing_Percentage()
	return self.damage
end

function modifier_oracle_innate_defense:GetModifierPercentageManacostStacking()
	return self.mana * (-1)
end

function modifier_oracle_innate_defense:GetTexture()
    return "custom/oracle_fortunes_end_immortal"
end

function modifier_oracle_innate_defense:IsDebuff()
	return false
end

function modifier_oracle_innate_defense:IsPurgable()
	return false
end

function modifier_oracle_innate_defense:IsPurgeException()
	return false
end