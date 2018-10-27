wk_vamp = class({})
LinkLuaModifier( "modifier_wk_vamp", "heroes/hero_wraith_king/wk_vamp.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wk_vamp_effect", "heroes/hero_wraith_king/wk_vamp.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wk_vamp_active", "heroes/hero_wraith_king/wk_vamp.lua",LUA_MODIFIER_MOTION_NONE )

function wk_vamp:IsStealable()
    return true
end

function wk_vamp:IsHiddenWhenStolen()
    return false
end

function wk_vamp:GetIntrinsicModifierName()
    return "modifier_wk_vamp"
end

function wk_vamp:GetChannelTime()
    return self:GetTalentSpecialValueFor("channel_duration")
end

function wk_vamp:OnSpellStart()
    self.counter = 0
end

function wk_vamp:OnChannelThink(flInterval)
    if self.counter >= (0.5 + flInterval) then
        local caster = self:GetCaster()

        local healthDamage = caster:GetMaxHealth() * self:GetTalentSpecialValueFor("life_drain")/100
        print(healthDamage)
        healthDamage = healthDamage * (0.5 + flInterval)
        print(healthDamage)

        caster:ModifyHealth(caster:GetHealth() - healthDamage, self, false, 0)

        local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_POINT, caster)
                        ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
                        ParticleManager:SetParticleControl(nfx, 1, caster:GetAbsOrigin())
                        ParticleManager:SetParticleControl(nfx, 2, caster:GetAbsOrigin())
                        ParticleManager:ReleaseParticleIndex(nfx)

            self:DealDamage(caster, enemy, healthDamage, {}, 0)
        end

        if caster:HasTalent("special_bonus_unique_wk_vamp_2") then
            local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
            for _,ally in pairs(allies) do
                if ally ~= caster then
                    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_fg_heal.vpcf", PATTACH_POINT, caster)
                                ParticleManager:SetParticleControlEnt(nfx, 0, ally, PATTACH_POINT, "attach_hitloc", ally:GetAbsOrigin(), true)
                                ParticleManager:SetParticleControl(nfx, 1, caster:GetAbsOrigin())
                                ParticleManager:ReleaseParticleIndex(nfx)

                    ally:HealEvent(healthDamage, self, caster, false)
                end
            end
        end

        self.counter = 0
    else
        self.counter = self.counter + FrameTime()
    end 
end

modifier_wk_vamp = class({})
function modifier_wk_vamp:IsAura()
    return true
end

function modifier_wk_vamp:GetAuraDuration()
    return 0.5
end

function modifier_wk_vamp:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_wk_vamp:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_wk_vamp:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_wk_vamp:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_wk_vamp:GetModifierAura()
    return "modifier_wk_vamp_effect"
end

function modifier_wk_vamp:IsAuraActiveOnDeath()
    return false
end

function modifier_wk_vamp:IsHidden()
    return true
end

modifier_wk_vamp_effect = class({})
function modifier_wk_vamp_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_wk_vamp_effect:OnAttackLanded(params)
    if IsServer() then
        local parent = self:GetParent()
        local target = params.target
        local attacker = params.attacker
        local ability = self:GetAbility()
        local damage = params.damage

        if attacker == parent then
            local lifestealPct = self:GetTalentSpecialValueFor("lifesteal")
            attacker:Lifesteal(nil, lifestealPct, damage, nil, 0, DOTA_LIFESTEAL_SOURCE_NONE, true)
        end
    end
end

function modifier_wk_vamp:IsDebuff()
    return false
end