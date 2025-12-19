kunkka_tidebringer = class({})

function kunkka_tidebringer:IsStealable()
    return false
end

function kunkka_tidebringer:IsHiddenWhenStolen()
    return false
end

function kunkka_tidebringer:GetIntrinsicModifierName()
    return "modifier_kunkka_tidebringer_handler"
end

modifier_kunkka_tidebringer_handler = class({})
LinkLuaModifier("modifier_kunkka_tidebringer_handler", "heroes/hero_kunkka/kunkka_tidebringer", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_tidebringer_handler:IsHidden()
    return true
end

function modifier_kunkka_tidebringer_handler:OnCreated()
    self:StartIntervalThink(0.1)
end

function modifier_kunkka_tidebringer_handler:OnIntervalThink()
   if IsServer() then
        if self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_kunkka_tidebringer_active") then
            self.damage = self:GetSpecialValueFor("damage_bonus")
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kunkka_tidebringer_active", {})
        else
            if not self:GetAbility():IsCooldownReady() then
                self.damage = 0
            end
        end
    end
end

function modifier_kunkka_tidebringer_handler:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end

function modifier_kunkka_tidebringer_handler:GetModifierBaseAttack_BonusDamage()
    return self.damage
end

modifier_kunkka_tidebringer_active = class({})
LinkLuaModifier("modifier_kunkka_tidebringer_active", "heroes/hero_kunkka/kunkka_tidebringer", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_tidebringer_active:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        self.heroes_hit = 0
        self.creeps_hit = 0
        EmitSoundOn("Hero_Kunkaa.Tidebringer", caster)
        --AddAnimationTranslate(caster, "tidebringer")
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_POINT_FOLLOW, caster)
                    ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_tidebringer", caster:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
        self:AttachEffect(nfx)
    end
end

function modifier_kunkka_tidebringer_active:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_kunkka_tidebringer_active:OnAttackLanded(params)
    local caster = params.attacker
    local ability = self:GetAbility()
    local mini_stun = self:GetSpecialValueFor("mini_stun_duration")
    local heal_pct = self:GetSpecialValueFor("heal_pct") / 100
    local cdr_hero = self:GetSpecialValueFor("hit_cdr_hero")
    local cdr_creep = self:GetSpecialValueFor("hit_cdr_creep")
    local damage = params.original_damage * self:GetSpecialValueFor("cleave_damage") /100
    local no_cooldown = self:GetSpecialValueFor("no_cooldown")

    if IsServer() then
        if caster == self:GetParent() then
            if not caster:IsIllusion() and ability:IsCooldownReady() then
                EmitSoundOn("Hero_Kunkka.Tidebringer.Attack", caster)
                ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer_b.vpcf", PATTACH_POINT, self:GetCaster(), {})
                local targets = caster:FindEnemyUnitsInCone(caster:GetForwardVector(), caster:GetAbsOrigin(), self:GetSpecialValueFor("cleave_ending_width"), self:GetSpecialValueFor("cleave_distance"))
                for _, enemy in ipairs(targets) do
                    EmitSoundOn("Hero_Kunkka.TidebringerDamage", targets)
                    local tidebringer_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, caster)
                                                ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                                                ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                                                ParticleManager:SetParticleControl(tidebringer_hit_fx, 1, Vector(2,  17, 1))
                                                ParticleManager:SetParticleControlForward(tidebringer_hit_fx, 1, caster:GetForwardVector())
                                                ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                                                ParticleManager:ReleaseParticleIndex(tidebringer_hit_fx)
                    ability:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
                    
                    if mini_stun ~= 0 then
                        ability:Stun(enemy, mini_stun)
                    end

                    if heal_pct ~= 0 then
                        caster:HealEvent(damage * heal_pct, self, caster)
                    end

                    if cdr_hero ~= 0 then
                        if enemy:IsConsideredHero() then
                            self.heroes_hit = self.heroes_hit + 1
                        else
                            self.creeps_hit = self.creeps_hit + 1
                        end
                    end
                end
                if self.heroes_hit or self.creeps_hit ~= 0 then
                    local heroCdr = self.heroes_hit * cdr_hero
                    local creepCdr = self.creeps_hit * cdr_creep
                    local total = heroCdr + creepCdr
                    ability:SetCooldown((ability:GetCooldown(ability:GetLevel()-1) - total ))
                else
                    ability:SetCooldown()
                end
                self:Destroy()
            end
        end
    end
end