juggernaut_whirling_dervish = class({})

function juggernaut_whirling_dervish:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    local disarm = self:GetSpecialValueFor("disarm")
    caster:Dispel(caster, false)
    caster:AddNewModifier(caster, self, "modifier_juggernaut_whirling_dervish_caster", {duration = duration})
    caster:AddNewModifier(caster, self, "modifier_juggernaut_whirling_dervish_handler", {duration = duration})
    if disarm ~= 0 then
        caster:AddNewModifier(caster, self, "modifier_juggernaut_whirling_dervish_ronin", {duration = duration})
    end
end

modifier_juggernaut_whirling_dervish_caster = class({})
LinkLuaModifier("modifier_juggernaut_whirling_dervish_caster", "heroes/hero_juggernaut/juggernaut_whirling_dervish", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_whirling_dervish_caster:IsHidden()
    return true
end

function modifier_juggernaut_whirling_dervish_caster:CheckState()
    return
    {
        [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }
end
function modifier_juggernaut_whirling_dervish_caster:OnCreated()
    local caster = self:GetCaster()
    self.windless_cuts = caster:FindAbilityByName("juggernaut_windless_cuts")
    self.hidden_blade = caster:FindAbilityByName("juggernaut_hidden_blade")
	self.dmg_reduction = self:GetSpecialValueFor("damage_reduction")

    EmitSoundOn("Hero_Juggernaut.BladeFuryStart", self:GetParent())

    if IsServer() then
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        if caster:HasAbility("juggernaut_hidden_blade") then
            self.windless_cuts:SetActivated(false)
            self.hidden_blade:SetActivated(false)
        else
            self.windless_cuts:SetActivated(false)
        end
    end
end
function modifier_juggernaut_whirling_dervish_caster:OnDestroy()
    local caster = self:GetCaster()
    if IsServer() then
        if caster:HasAbility("juggernaut_hidden_blade") then
            self.windless_cuts:SetActivated(true)
            self.hidden_blade:SetActivated(true)
        else
            self.windless_cuts:SetActivated(true)
        end
        caster:Dispel(caster, true)
        caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
    end
    StopSoundOn("Hero_Juggernaut.BladeFuryStart", self:GetParent())
end

function modifier_juggernaut_whirling_dervish_caster:DeclareFunctions()
    return
	{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_juggernaut_whirling_dervish_caster:GetModifierMagicalResistanceBonus()
    return 80
end

function modifier_juggernaut_whirling_dervish_caster:GetModifierDamageOutgoing_Percentage()
	if IsServer() and not self:GetCaster():IsInAbilityAttackMode() then
		return -self.dmg_reduction
	end
end

modifier_juggernaut_whirling_dervish_handler = class({})
LinkLuaModifier("modifier_juggernaut_whirling_dervish_handler", "heroes/hero_juggernaut/juggernaut_whirling_dervish", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_whirling_dervish_handler:OnCreated()
    self.radius = self:GetSpecialValueFor("radius")
    self.damage = self:GetSpecialValueFor("damage")
	self.tick = self:GetSpecialValueFor("damage_tick")

    if IsServer() then
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(nfx, 5, (Vector(self.radius + 100,0,0)))
        self:AddEffect(nfx)
        self:StartIntervalThink(self.tick)
    end
end

function modifier_juggernaut_whirling_dervish_handler:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_juggernaut_whirling_dervish_handler:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        self:GetAbility():DealDamage(params.attacker, params,target, self.damage / 2)
    end
end

function modifier_juggernaut_whirling_dervish_handler:OnIntervalThink()
    local caster = self:GetParent()
	local mods = self:GetSpecialValueFor("applies_modifiers")
    for _, units in ipairs(caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)) do
        self:GetAbility():DealDamage(caster, units, self.damage)
		if mods ~= 0 then
            caster:PerformAttack(units, false, true, true, false, false, true, true)
        end
        EmitSoundOn("Hero_Juggernaut.BladeFury.Impact", units)
    end
end

function modifier_juggernaut_whirling_dervish_handler:OnDestroy()
    self:StartIntervalThink(-1)
end

function modifier_juggernaut_whirling_dervish_handler:IsBuff()
    return true
end

function modifier_juggernaut_whirling_dervish_handler:IsPurgable()
    return false
end

function modifier_juggernaut_whirling_dervish_handler:GetTextureName()
    return "juggernaut_whirling_dervish"
end

modifier_juggernaut_whirling_dervish_ronin = class({})
LinkLuaModifier("modifier_juggernaut_whirling_dervish_ronin", "heroes/hero_juggernaut/juggernaut_whirling_dervish", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_whirling_dervish_ronin:IsHidden()
    return true
end

function modifier_juggernaut_whirling_dervish_ronin:OnCreated()
    self.radius = self:GetSpecialValueFor("radius")
end

function modifier_juggernaut_whirling_dervish_ronin:IsAura()
    return true
end

function modifier_juggernaut_whirling_dervish_ronin:GetAuraRadius()
    return self.radius
end

function modifier_juggernaut_whirling_dervish_ronin:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_juggernaut_whirling_dervish_ronin:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HEROES_AND_CREEPS
end

function modifier_juggernaut_whirling_dervish_ronin:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_juggernaut_whirling_dervish_ronin:GetModifierAura()
	return "modifier_juggernaut_whirling_dervish_ronin_aura"
end

modifier_juggernaut_whirling_dervish_ronin_aura = class({})
LinkLuaModifier("modifier_juggernaut_whirling_dervish_ronin_aura", "heroes/hero_juggernaut/juggernaut_whirling_dervish", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_whirling_dervish_ronin_aura:IsDebuff()
    return true
end

function modifier_juggernaut_whirling_dervish_ronin_aura:IsPurgable()
    return false
end

function modifier_juggernaut_whirling_dervish_ronin_aura:OnCreated()
    self.mspd_slow = self:GetSpecialValueFor("mspd_slow")
    self.aspd_slow = self:GetSpecialValueFor("aspd_slow")
end

function modifier_juggernaut_whirling_dervish_ronin_aura:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_juggernaut_whirling_dervish_ronin_aura:GetModifierMoveSpeedBonus_Percentage()
    return -self.mspd_slow
end

function modifier_juggernaut_whirling_dervish_ronin_aura:GetModifierAttackSpeedBonus_Constant()
    return -self.aspd_slow
end