kotl_chakra_magic= class({})
LinkLuaModifier( "modifier_kotl_chakra_magic", "heroes/hero_kotl/kotl_chakra_magic.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_chakra_magic:IsStealable()
    return true
end

function kotl_chakra_magic:IsHiddenWhenStolen()
    return false
end

function kotl_chakra_magic:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_kotl_chakra_magic_2")
end

function kotl_chakra_magic:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    self:DoChakraStuff(target)

    if caster:HasTalent("special_bonus_unique_kotl_chakra_magic_2") and target ~= caster then
        self:DoChakraStuff(caster)
    end
end

function kotl_chakra_magic:DoChakraStuff(hTarget)
    local caster = self:GetCaster()
    local target = hTarget

    EmitSoundOn("Hero_KeeperOfTheLight.ChakraMagic.Target", target)

    local chakraCast =  ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_POINT_FOLLOW, caster)
                        ParticleManager:SetParticleControlEnt(chakraCast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true) 
                        ParticleManager:SetParticleControlEnt(chakraCast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                        ParticleManager:ReleaseParticleIndex(chakraCast)

    local mana_restore = self:GetSpecialValueFor("mana_restore")
    local cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction")

    target:RestoreMana( mana_restore )
    for i = 0, target:GetAbilityCount() - 1 do
        local ability = target:GetAbilityByIndex(i)
        if ability and ability:GetAbilityType() ~= 1 and not ability:IsItem() then
            ability:SetCooldown(ability:GetCooldownTimeRemaining() - cooldown_reduction)
        end
    end

    if caster:HasTalent("special_bonus_unique_kotl_chakra_magic_1") then
        local duration = caster:FindTalentValue("special_bonus_unique_kotl_chakra_magic_1", "duration")
        target:AddNewModifier(caster, self, "modifier_kotl_chakra_magic", {Duration = duration})
    end
end

modifier_kotl_chakra_magic = class({})
function modifier_kotl_chakra_magic:OnCreated(table)
    self.bonus_spell_amp = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_chakra_magic_1")
end

function modifier_kotl_chakra_magic:OnRefresh(table)
    self.bonus_spell_amp = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_chakra_magic_1")
end

function modifier_kotl_chakra_magic:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function modifier_kotl_chakra_magic:GetModifierSpellAmplify_Percentage()
    return self.bonus_spell_amp
end

function modifier_kotl_chakra_magic:IsDebuff()
    return false
end

function modifier_kotl_chakra_magic:IsPurgable()
    return true
end