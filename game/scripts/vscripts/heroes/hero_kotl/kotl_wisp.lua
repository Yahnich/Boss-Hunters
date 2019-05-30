kotl_wisp = class({})
LinkLuaModifier( "modifier_kotl_wisp", "heroes/hero_kotl/kotl_wisp.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kotl_wisp_slow", "heroes/hero_kotl/kotl_wisp.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_wisp:IsStealable()
    return true
end

function kotl_wisp:IsHiddenWhenStolen()
    return false
end

function kotl_wisp:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function kotl_wisp:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_KeeperOfTheLight.Wisp.Cast", caster)

    local duration = self:GetSpecialValueFor("on_count") * 3.15 + 1

    CreateModifierThinker(caster, self, "modifier_kotl_wisp", {Duration = duration}, point, caster:GetTeam(), false)
end

modifier_kotl_wisp = class({})
function modifier_kotl_wisp:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local point = parent:GetAbsOrigin()

        EmitSoundOn("Hero_KeeperOfTheLight.Wisp.Spawn", parent)
        EmitSoundOn("Hero_KeeperOfTheLight.Wisp.Aura", parent)

        self.radius = self:GetSpecialValueFor("radius")
        self.onTick = self:GetSpecialValueFor("on_duration")
        self.offTick = self:GetSpecialValueFor("off_duration")
        self.onCount = self:GetSpecialValueFor("on_count")

        AddFOWViewer(caster:GetTeam(), point, self.radius, self.onCount * 3.15, true)

        self.on = true

        local firstTick = self:GetSpecialValueFor("off_duration_initial")

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(nfx, 0, point + Vector(0, 0, 350))
                    ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, self.radius, self.radius))

        self:AttachEffect(nfx)

        self:StartIntervalThink(firstTick)
    end
end

function modifier_kotl_wisp:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_KeeperOfTheLight.Wisp.Aura", self:GetParent())
        EmitSoundOn("Hero_KeeperOfTheLight.Wisp.Destroy", self:GetParent())
    end
end

function modifier_kotl_wisp:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local point = parent:GetAbsOrigin()

    GridNav:DestroyTreesAroundPoint(point, self.radius, false)


    if self.onCount > 0 then
        if self.on then
            EmitSoundOn("Hero_KeeperOfTheLight.Wisp.Active", parent)

            self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling_on.vpcf", PATTACH_POINT, caster)
                        ParticleManager:SetParticleControl(self.nfx, 0, point + Vector(0, 0, 350))
                        ParticleManager:SetParticleControl(self.nfx, 2, Vector(self.radius, 0, 0))

            local enemies = caster:FindEnemyUnitsInRadius(point, self.radius)
            for _,enemy in pairs(enemies) do
                if not enemy:IsCharmed() then
                    enemy:Charm(self:GetAbility(), parent, self.onTick)
                    enemy:AddNewModifier(caster, self:GetAbility(), "modifier_kotl_wisp_slow", {Duration = self.onTick})
                end
            end

            if caster:HasTalent("special_bonus_unique_kotl_wisp_2") then
                local healthGain = caster:FindTalentValue("special_bonus_unique_kotl_wisp_2")/100
                local allies = caster:FindFriendlyUnitsInRadius(point, self.radius)
                for _,ally in pairs(allies) do
                    ally:HealEvent(ally:GetMaxHealth() * healthGain, self:GetAbility(), caster, false)
                end
            end

            self.onCount = self.onCount - 1
            self:StartIntervalThink(self.offTick)
            self.on = false
        else
            StopSoundOn("Hero_KeeperOfTheLight.Wisp.Active", parent)
            ParticleManager:ClearParticle(self.nfx)

            local enemies = caster:FindEnemyUnitsInRadius(point, self.radius)
            for _,enemy in pairs(enemies) do
                enemy:RemoveModifierByNameAndCaster("modifier_charm_generic", parent)
                enemy:RemoveModifierByName("modifier_kotl_wisp_slow")
            end

            self.on = true
            self:StartIntervalThink(self.onTick)
        end
    else
        ParticleManager:ClearParticle(self.nfx)
        self:Destroy()
    end
end

modifier_kotl_wisp_slow = class({})
function modifier_kotl_wisp_slow:OnCreated(table)
    self.ms = self:GetSpecialValueFor("fixed_movement_speed")

    if self:GetCaster():HasTalent("special_bonus_unique_kotl_wisp_1") then
        self.inc_damage = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_wisp_1")
    end

    if IsServer() then
        EmitSoundOn("Hero_KeeperOfTheLight.Wisp.Target", self:GetParent())
    end
end

function modifier_kotl_wisp_slow:OnRefresh(table)
    self.ms = self:GetSpecialValueFor("fixed_movement_speed")

    if self:GetCaster():HasTalent("special_bonus_unique_kotl_wisp_1") then
        self.inc_damage = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_wisp_1")
    end
end

function modifier_kotl_wisp_slow:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_KeeperOfTheLight.Wisp.Target", self:GetParent())
    end
end

function modifier_kotl_wisp_slow:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_kotl_wisp_slow:GetModifierMoveSpeed_Absolute()
    return self.ms
end

function modifier_kotl_wisp_slow:GetModifierIncomingDamage_Percentage()
    return self.inc_damage
end

function modifier_kotl_wisp_slow:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling_debuff.vpcf"
end

function modifier_kotl_wisp_slow:GetStatusEffectName()
    return "particles/status_fx/status_effect_keeper_dazzle.vpcf"
end

function modifier_kotl_wisp_slow:StatusEffectPriority()
    return 11
end

function modifier_kotl_wisp_slow:IsPurgable()
    return true
end

function modifier_kotl_wisp_slow:IsHidden()
    return true
end