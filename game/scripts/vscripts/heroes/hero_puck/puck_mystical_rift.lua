puck_mystical_rift = class({})

function puck_mystical_rift:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function puck_mystical_rift:GetBehavior()
    if self:GetSpecialValueFor("fears") == 0 then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    else
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_AUTOCAST
    end
end

function puck_mystical_rift:RequiresFacing()
    return true
end

function puck_mystical_rift:OnSpellStart()
    local caster = self:GetCaster()
    local pos = caster:GetAbsOrigin()
    local target = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local max_distance = self:GetSpecialValueFor("max_distance")
    local dir = CalculateDirection(caster:GetAbsOrigin(), target)
    local repeats = self:GetSpecialValueFor("repeats")

    if not caster:IsRooted() then
        if CalculateDistance(pos, target) > CalculateDistance(pos, pos + caster:GetForwardVector() * max_distance) then
            caster:SmoothFindClearSpace(pos - dir * max_distance)
        else
            caster:SmoothFindClearSpace(target)
        end
        self:SpreadDust(radius)
        if repeats ~= 0 then
            Timers:CreateTimer(repeats, function()
                self:SpreadDust(radius)
            end)
        end
    else
        self:SpreadDust(radius)
        if repeats ~= 0 then
            Timers:CreateTimer(repeats, function()
                self:SpreadDust(radius)
            end)
        end
    end
end

function puck_mystical_rift:SpreadDust(radius)
    local caster = self:GetCaster()
    local armor_reduction = self:GetSpecialValueFor("armor_reduction")
    local purge = self:GetSpecialValueFor("purge")
    local fear = self:GetSpecialValueFor("fears")
    local duration = self:GetSpecialValueFor("silence_duration")

    local disarms = self:GetSpecialValueFor("disarms")

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_waning_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(nfx)

    for _, enemy in ipairs (caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)) do
        self:DealDamage(caster, enemy, self:GetSpecialValueFor("damage"))
        enemy:Silence(self, caster, duration)

        if disarms ~= 0 then
            enemy:Disarm(self, caster, duration)
        end

        if armor_reduction ~= 0 then
            enemy:AddNewModifier(caster, self, "modifier_puck_mystical_rift_glimmerdrake", {duration = duration})
        end

        if purge ~= 0 then
            enemy:Dispel(caster, false)
            enemy:Break(self, caster, duration)
        end

        if fear ~= 0 then
            if not self:GetAutoCastState() then
                enemy:Charm(self, caster, duration)

            else
                enemy:Fear(self, caster, duration)
            end
        end
    end

    EmitSoundOn("Hero_Puck.Waning_Rift", caster)
end

modifier_puck_mystical_rift_glimmerdrake = class({})
LinkLuaModifier("modifier_puck_mystical_rift_glimmerdrake", "heroes/hero_puck/puck_mystical_rift", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_mystical_rift_glimmerdrake:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_puck_mystical_rift_glimmerdrake:IsDebuff()
    return true
end

function modifier_puck_mystical_rift_glimmerdrake:IsPurgable()
    return true
end

function modifier_puck_mystical_rift_glimmerdrake:OnCreated()
    self:OnRefresh()
end

function modifier_puck_mystical_rift_glimmerdrake:OnRefresh()
    self.armor_reduction = self:GetSpecialValueFor("armor_reduction")
end

function modifier_puck_mystical_rift_glimmerdrake:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_puck_mystical_rift_glimmerdrake:GetModifierPhysicalArmorBonus()
    return -self.armor_reduction
end