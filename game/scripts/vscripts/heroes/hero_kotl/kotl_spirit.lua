kotl_spirit = class({})
function kotl_spirit:IsStealable()
    return false
end

function kotl_spirit:IsHiddenWhenStolen()
    return false
end

function kotl_spirit:GetIntrinsicModifierName()
	return "modifier_kotl_spirit_passive"
end

modifier_kotl_spirit_passive = class({})
LinkLuaModifier( "modifier_kotl_spirit_passive", "heroes/hero_kotl/kotl_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_kotl_spirit_passive:OnCreated()
	self.day_multiplier = self:GetTalentSpecialValueFor("day_multiplier")
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_kotl_spirit_passive:OnIntervalThink()
	if GameRules:IsDaytime( ) and not self:GetParent():HasModifier("modifier_kotl_spirit") then
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_kotl_spirit", {} )
	elseif not GameRules:IsDaytime( ) and self:GetParent():HasModifier("modifier_kotl_spirit") then
		self:GetParent():RemoveModifierByName("modifier_kotl_spirit")
	end
end

function modifier_kotl_spirit_passive:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, 
			 MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
			 MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end


function modifier_kotl_spirit_passive:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "heal_amp" or specialValue == "spell_amp" then
			return 1
		end
	end
end

function modifier_kotl_spirit_passive:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "heal_amp" or specialValue == "spell_amp" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local totalValue = flBaseValue * caster:GetLevel()
			if caster:HasModifier( "modifier_kotl_spirit" ) then
				totalValue = totalValue * self.day_multiplier
			end
			return totalValue
		end
	end
end

function modifier_kotl_spirit_passive:GetModifierSpellAmplify_Percentage()
	return self:GetTalentSpecialValueFor("spell_amp")
end

function modifier_kotl_spirit_passive:GetModifierHealAmplify_Percentage()
	return self:GetTalentSpecialValueFor("heal_amp")
end

function modifier_kotl_spirit_passive:IsHidden()
	return true
end

modifier_kotl_spirit = class({})
LinkLuaModifier( "modifier_kotl_spirit", "heroes/hero_kotl/kotl_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_kotl_spirit:OnCreated(table)
	self.cdr = self:GetSpecialValueFor("day_cdr")
	self.mana_cost = self:GetSpecialValueFor("day_cost_reduction")
	
	self:GetParent():HookInModifier("GetModifierManacostReduction", self)
    if IsServer() then
        EmitSoundOn("Hero_KeeperOfTheLight.SpiritForm", self:GetCaster())
    end
end

function modifier_kotl_spirit:OnRemoved()
	self:GetParent():HookOutModifier("GetModifierManacostReduction", self)
    if IsServer() then
        StopSoundOn("Hero_KeeperOfTheLight.SpiritForm", self:GetCaster())
    end
end

function modifier_kotl_spirit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
    return funcs
end

function modifier_kotl_spirit:GetModifierManacostReduction()
    return self.mana_cost
end

function modifier_kotl_spirit:GetModifierPercentageCooldown()
    return self.cdr
end

function modifier_kotl_spirit:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
end

function modifier_kotl_spirit:GetStatusEffectName()
    return "particles/status_fx/status_effect_keeper_spirit_form.vpcf"
end

function modifier_kotl_spirit:StatusEffectPriority()
    return 10
end