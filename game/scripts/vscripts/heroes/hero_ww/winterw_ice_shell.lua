winterw_ice_shell = class({})

function winterw_ice_shell:IsStealable()
	return true
end

function winterw_ice_shell:IsHiddenWhenStolen()
	return false
end

function winterw_ice_shell:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Winter_Wyvern.ColdEmbrace.Cast", caster)
	EmitSoundOn("Hero_Winter_Wyvern.ColdEmbrace", target)

	target:AddNewModifier(caster, self, "modifier_ice_shell", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_ice_shell = ({})
LinkLuaModifier( "modifier_ice_shell", "heroes/hero_ww/winterw_ice_shell.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_ice_shell:OnCreated(table)
	self.heal_pct = self:GetSpecialValueFor("heal_pct")
	self.heal_base = self:GetSpecialValueFor("heal_base")
    if IsServer() then
    	self:GetParent():SetThreat(0)
    end
end

function modifier_ice_shell:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		if caster:HasTalent("special_bonus_unique_winterw_frozen_ice_shell_1") then
			self:GetParent():AddNewModifier( caster, self:GetAbility(), "modifier_ice_shell_talent", {duration = caster:FindTalentValue("special_bonus_unique_winterw_frozen_ice_shell_1", "duration")} )
		end
		if caster:HasTalent("special_bonus_unique_winterw_frozen_ice_shell_2") then
			local splinter = caster:FindAbilityByName("winterw_frozen_splinter")
			if splinter then
				splinter:CreateFrozenSplinters( self:GetParent() )
			end
		end
	end
end

function modifier_ice_shell:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_FROZEN] = true,
					[MODIFIER_STATE_ATTACK_IMMUNE] = true}
	return state
end

function modifier_ice_shell:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
    return funcs
end

function modifier_ice_shell:GetModifierConstantHealthRegen()
    return self.heal_base
end

function modifier_ice_shell:GetModifierHealthRegenPercentage()
    return self.heal_pct
end

function modifier_ice_shell:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_ice_shell:IsDebuff()
    return false
end

function modifier_ice_shell:GetEffectName()
    return "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf"
end

modifier_ice_shell_talent = ({})
LinkLuaModifier( "modifier_ice_shell_talent", "heroes/hero_ww/winterw_ice_shell.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_ice_shell_talent:OnCreated(table)
	local mult = self:GetCaster():FindTalentValue("special_bonus_unique_winterw_frozen_ice_shell_1") / 100
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_winterw_frozen_ice_shell_1", "armor")
	self.heal_pct = mult * self:GetSpecialValueFor("heal_pct")
	self.heal_base = mult * self:GetSpecialValueFor("heal_base")
    if IsServer() then
    	self:GetParent():SetThreat(0)
    end
end

function modifier_ice_shell_talent:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
    return funcs
end

function modifier_ice_shell_talent:GetModifierConstantHealthRegen()
    return self.heal_base
end

function modifier_ice_shell_talent:GetModifierHealthRegenPercentage()
    return self.heal_pct
end

function modifier_ice_shell_talent:GetModifierPhysicalArmorBonus()
    return self.armor
end
