mirana_stardust_reflection = class({})
LinkLuaModifier("modifier_moonlight_duration", "heroes/hero_mirana/mirana_stardust_reflection", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_moonlight_fade", "heroes/hero_mirana/mirana_stardust_reflection", LUA_MODIFIER_MOTION_NONE)

function mirana_stardust_reflection:IsStealable()
    return true
end

function mirana_stardust_reflection:IsHiddenWhenStolen()
    return false
end

function mirana_stardust_reflection:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_mirana_stardust_reflection_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_mirana_stardust_reflection_1") end
    return cooldown
end

function mirana_stardust_reflection:OnAbilityPhaseStart()
    ParticleManager:FireParticle("particles/units/heroes/hero_mirana/mirana_moonlight_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
    return true
end

function mirana_stardust_reflection:OnSpellStart()
    local caster = self:GetCaster()

    EmitSoundOn("Ability.MoonlightShadow", caster)

    local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
    for _,friend in pairs(friends) do
        ParticleManager:FireParticle("particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf", PATTACH_POINT_FOLLOW, friend, {})
        friend:AddNewModifier(caster, self, "modifier_moonlight_duration", {Duration = self:GetSpecialValueFor("duration")})
        friend:AddNewModifier(caster, self, "modifier_moonlight_fade", {Duration = self:GetSpecialValueFor("fade_delay")})
    end
end

modifier_moonlight_duration = class({})
function modifier_moonlight_duration:OnRemoved()
    if IsServer() then
        self:GetParent():RemoveModifierByName("modifier_moonlight_fade")
        self:GetParent():RemoveModifierByName("modifier_invisible")
    end
end

function modifier_moonlight_duration:GetEffectName()
    return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
end

function modifier_moonlight_duration:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_moonlight_duration:DeclareFunctions()
    funcs = {
                MODIFIER_EVENT_ON_ATTACK,
                MODIFIER_EVENT_ON_ABILITY_EXECUTED,
            }
    return funcs
end

function modifier_moonlight_duration:GetCooldownReduction()
    if self:GetCaster():HasTalent("special_bonus_unique_mirana_stardust_reflection_2") then
        return self:GetCaster():FindTalentValue("special_bonus_unique_mirana_stardust_reflection_2")
    else
        return 0
    end
end

function modifier_moonlight_duration:OnAttack(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_moonlight_fade", {Duration = self:GetSpecialValueFor("fade_delay")})
        end
    end
end

function modifier_moonlight_duration:OnAbilityExecuted(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_moonlight_fade", {Duration = self:GetSpecialValueFor("fade_delay")})
        end
    end
end

modifier_moonlight_fade = class({})
function modifier_moonlight_fade:OnCreated(table)
    if IsServer() then
        self:GetParent():RemoveModifierByName("modifier_invisible")
    end
end

function modifier_moonlight_fade:OnRemoved()
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible", {})
    end
end

function modifier_moonlight_fade:IsHidden()
    return true
end