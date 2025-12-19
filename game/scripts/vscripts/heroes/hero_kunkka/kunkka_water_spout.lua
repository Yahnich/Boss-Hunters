kunkka_water_spout = class({})

function kunkka_water_spout:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function kunkka_water_spout:OnSpellStart()
    local point = self:GetCursorPosition()
    local caster = self:GetCaster()
    self:CreateTorrent(point)

    local extra_torrents = self:GetSpecialValueFor("extra_torrents")
    local extra_torrent_delay = self:GetSpecialValueFor("extra_torrent_delay")
    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("AbilityCastRange"))
    if extra_torrents ~= 0 then
        if #enemies >= 2 then
            for _, units in ipairs(enemies) do
                if extra_torrents ~= 0 then
                    extra_torrents = extra_torrents - 1
                    self:CreateTorrent(units:GetAbsOrigin())
                end
            end
        else
            if #enemies <= 1 then
                Timers:CreateTimer(extra_torrent_delay, function()
                    extra_torrents = extra_torrents - 1
                    self:CreateTorrent(point)
                    if extra_torrents ~=0 then
                        return extra_torrent_delay
                    end
                end)
            end
        end
    end
end

function kunkka_water_spout:CreateTorrent(position)
    local caster = self:GetCaster()
	EmitSoundOnLocationWithCaster(position, "Ability.pre.Torrent", caster)

    local bubbles = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(bubbles, 0, position)
	local stunDuration = self:GetSpecialValueFor("stun_duration")
	local slow = self:GetSpecialValueFor("slow_duration") + stunDuration
    local radius = self:GetSpecialValueFor("radius")

    local bonus_armor = self:GetSpecialValueFor("bonus_armor")
    local bonus_damage = self:GetSpecialValueFor("bonus_physical_damage")
    AddFOWViewer(caster:GetTeamNumber(), position, radius, 3.13, false)

    Timers:CreateTimer(self:GetSpecialValueFor("delay"), function()
        ParticleManager:ClearParticle(bubbles)
        StopSoundOn("Ability.pre.Torrent", caster)
        EmitSoundOnLocationWithCaster(position, "Ability.Torrent", caster)
        ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_POINT, caster, {[0]=position})
        local enemies = caster:FindEnemyUnitsInRadius(position, radius)
        for _,enemy in ipairs(enemies) do
			enemy:ApplyKnockBack(enemy:GetAbsOrigin(), stunDuration + 0.1, stunDuration, 0, 350, caster, self, true)
			enemy:AddNewModifier(caster, self, "modifier_kunkka_water_spout_damage", {duration = stunDuration})
            enemy:AddNewModifier(caster, self, "modifier_kunkka_water_spout_slow", {duration = slow})
            if bonus_damage ~= 0 then
                enemy:AddNewModifier(caster, self, "modifier_kunkka_water_spout_privateer", {duration = stunDuration})
            end
        end
        if bonus_armor ~= 0 then
            for _, allies in ipairs(caster:FindFriendlyUnitsInRadius(position, radius)) do
                allies:AddNewModifier(caster, self, "modifier_kunkka_water_spout_admiral", {duration = self:GetSpecialValueFor("bonus_armor_duration")})
            end
        end
    end)
end


-----------------------------------------------------------------------------------------------------------------------------------------
modifier_kunkka_water_spout_damage = class({})
LinkLuaModifier("modifier_kunkka_water_spout_damage", "heroes/hero_kunkka/kunkka_water_spout", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_water_spout_damage:GetAttributes()
    if self:GetSpecialValueFor("greater_torrents") ~= 0 then
        return MODIFIER_ATTRIBUTE_MULTIPLE
    else return
    end
end

function modifier_kunkka_water_spout_damage:IsHidden()
    return true
end

function modifier_kunkka_water_spout_damage:OnCreated()
    self.tick = self:GetSpecialValueFor("damage_tick_interval")
    self:StartIntervalThink(self.tick)
end

function modifier_kunkka_water_spout_damage:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local damage = self:GetSpecialValueFor("damage") / 6
    if IsServer() then
        self:GetAbility():DealDamage(caster, parent, damage)
    end
end

function modifier_kunkka_water_spout_damage:OnDestroy()
    self:StartIntervalThink(-1)
end
-----------------------------------------------------------------------------------------------------------------------------------------
modifier_kunkka_water_spout_slow = class({})
LinkLuaModifier("modifier_kunkka_water_spout_slow", "heroes/hero_kunkka/kunkka_water_spout", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_water_spout_slow:OnCreated()
    self.slow = self:GetSpecialValueFor("movespeed_bonus")
end

function modifier_kunkka_water_spout_slow:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_kunkka_water_spout_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end

modifier_kunkka_water_spout_admiral = class({})
LinkLuaModifier("modifier_kunkka_water_spout_admiral", "heroes/hero_kunkka/kunkka_water_spout", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_water_spout_admiral:OnCreated()
    self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
    self.mspd_bonus = self:GetSpecialValueFor("admiral_mspd_bonus")
end

function modifier_kunkka_water_spout_admiral:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_kunkka_water_spout_admiral:GetModifierMoveSpeedBonus_Percentage()
    return self.mspd_bonus
end

function modifier_kunkka_water_spout_admiral:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

modifier_kunkka_water_spout_privateer = class({})
LinkLuaModifier("modifier_kunkka_water_spout_privateer", "heroes/hero_kunkka/kunkka_water_spout",  LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_water_spout_privateer:OnCreated()
    self:OnRefresh()
end

function modifier_kunkka_water_spout_privateer:OnRefresh()
    self.bonus_dmg = self:GetSpecialValueFor("bonus_physical_damage")
end

function modifier_kunkka_water_spout_privateer:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_kunkka_water_spout_privateer:OnAttackLanded(params)
    local parent = self:GetParent()
    local caster = self:GetCaster()
    if IsServer() then
        if parent == params.target and caster == params.attacker then
            self:GetAbility():DealDamage(caster, parent, self.bonus_dmg {damage_type = DAMAGE_TYPE_PHYSICAL})
        end
    end
end