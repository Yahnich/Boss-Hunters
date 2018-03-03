kotl_chakra_magic= class({})
LinkLuaModifier( "modifier_kotl_chakra_magic_int_gain", "heroes/hero_kotl/kotl_chakra_magic.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_chakra_magic:IsStealable()
    return true
end

function kotl_chakra_magic:IsHiddenWhenStolen()
    return false
end

if IsServer() then
    function kotl_chakra_magic:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        EmitSoundOn("Hero_KeeperOfTheLight.ChakraMagic.Target", target)
        local chakraCast = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_POINT_FOLLOW, caster)
            ParticleManager:SetParticleControlEnt(chakraCast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true) 
            ParticleManager:SetParticleControlEnt(chakraCast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(chakraCast)
        local modifier = target:AddNewModifier(caster, self, "modifier_kotl_chakra_magic_int_gain", {duration = self:GetTalentSpecialValueFor("duration")})
        modifier:SetStackCount(self:GetTalentSpecialValueFor("stacks"))
        
        if caster:HasTalent("special_bonus_unique_kotl_chakra_magic_2") then
            local modifier = caster:AddNewModifier(caster, self, "modifier_kotl_chakra_magic_int_gain", {duration = self:GetTalentSpecialValueFor("duration")})
            modifier:SetStackCount(self:GetTalentSpecialValueFor("stacks"))
        end
    end
end

modifier_kotl_chakra_magic_int_gain = class({})

function modifier_kotl_chakra_magic_int_gain:OnCreated() 
    self.intgain = self:GetAbility():GetTalentSpecialValueFor("int_gain")
    if self:GetCaster():HasTalent("special_bonus_unique_kotl_chakra_magic_1") then
        self.spellAmp = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_chakra_magic_1")
    else
        self.spellAmp = 0
    end
    if IsServer() then
        self:GetParent():GiveMana(self.intgain*12)
    end
end

function modifier_kotl_chakra_magic_int_gain:OnRefresh()
    self.intgain = self:GetAbility():GetTalentSpecialValueFor("int_gain")
    if IsServer() then
        self:GetParent():GiveMana(self.intgain*12)
    end
end

function modifier_kotl_chakra_magic_int_gain:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
                MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
            }
    return funcs
end

function modifier_kotl_chakra_magic_int_gain:OnAbilityFullyCast(params)
    if params.unit == self:GetParent() and params.ability ~= self:GetAbility() then
        self:DecrementStackCount()
        if self:GetStackCount() == 0 then
            self:Destroy()
        end
    end
end

function modifier_kotl_chakra_magic_int_gain:GetModifierSpellAmplify_Percentage()
    return self.spellAmp
end

function modifier_kotl_chakra_magic_int_gain:GetModifierBonusStats_Intellect()
    return self.intgain
end