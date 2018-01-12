winterw_ice_shell = class({})
LinkLuaModifier( "modifier_ice_shell", "heroes/hero_ww/winterw_ice_shell.lua" ,LUA_MODIFIER_MOTION_NONE )

function winterw_ice_shell:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Winter_Wyvern.ColdEmbrace.Cast", caster)
	EmitSoundOn("Hero_Winter_Wyvern.ColdEmbrace", target)

	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,ally in pairs(allies) do
		if ally:HasModifier("modifier_ice_shell") then
			ally:FindModifierByName("modifier_ice_shell"):Destroy()
		end
	end
	target:AddNewModifier(caster, self, "modifier_ice_shell", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_ice_shell = ({})
function modifier_ice_shell:OnCreated(table)
    if IsServer() then
    	self:GetParent():SetThreat(0)

    	if self:GetCaster():HasTalent("special_bonus_unique_winterw_frozen_ice_shell_1") then
    		self:StartIntervalThink(0.33)
    	else
    		self:StartIntervalThink(1.0)
    	end
    end
end

function modifier_ice_shell:OnIntervalThink()
	local health = self:GetParent():GetMaxHealth() * self:GetSpecialValueFor("heal")/100

    self:GetParent():HealEvent(health, self:GetAbility(), self:GetCaster())

    if self:GetCaster():HasTalent("special_bonus_unique_winterw_frozen_ice_shell_2") then
	    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), 500, {})
		for _,enemy in pairs(enemies) do
			enemy:AddChill(self:GetAbility(), self:GetCaster(), self:GetCaster():FindTalentValue("special_bonus_unique_winterw_frozen_ice_shell_2"))
			enemy:SetChillCount(enemy:GetChillCount()+4)
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
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
    }
    return funcs
end

function modifier_ice_shell:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_ice_shell:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_ice_shell:IsDebuff()
    return false
end

function modifier_ice_shell:GetEffectName()
    return "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf"
end