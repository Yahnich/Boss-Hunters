alchemist_acid_bomb = class({})

function alchemist_acid_bomb:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function alchemist_acid_bomb:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local linger_duration = self:GetSpecialValueFor("linger_duration")
    local panacea = self:GetSpecialValueFor("affect_allies") ~= 0
    local point = self:GetCursorPosition()

    if IsClient() then return end

    if linger_duration > 0 then
        duration = -1
        if self.spray ~= nil then
            self.spray:SetDuration( linger_duration, false )
        end
    end
    CreateModifierThinker(caster, self, "modifier_alchemist_acid_bomb_thinker", { duration = duration }, point, caster:GetTeamNumber(), false)
    if panacea then
        CreateModifierThinker(caster, self, "modifier_alchemist_acid_bomb_panacea", { duration = duration }, point, caster:GetTeamNumber(), false)
    end

    -- particles
    local particle = "particles/units/heroes/hero_alchemist/alchemist_acid_spray_cast.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(effect, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(effect, 1, point)
    ParticleManager:ReleaseParticleIndex(effect)
end

modifier_alchemist_acid_bomb_thinker = class({})
LinkLuaModifier( "modifier_alchemist_acid_bomb_thinker", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_acid_bomb_thinker:IsHidden()
    return true
end
function modifier_alchemist_acid_bomb_thinker:IsPurgable()
    return false
end
function modifier_alchemist_acid_bomb_thinker:IsAura()
    return true
end
function modifier_alchemist_acid_bomb_thinker:GetModifierAura()
    return "modifier_alchemist_acid_bomb_aura"
end
function modifier_alchemist_acid_bomb_thinker:GetAuraRadius()
    return self.radius
end
function modifier_alchemist_acid_bomb_thinker:GetAuraDuration()
    return 0.5
end
function modifier_alchemist_acid_bomb_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_alchemist_acid_bomb_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HEROES_AND_CREEPS
end
function modifier_alchemist_acid_bomb_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_alchemist_acid_bomb_thinker:OnCreated()
    self:OnRefresh()
	self:GetAbility().spray = self
end
function modifier_alchemist_acid_bomb_thinker:OnRefresh()
    self.radius = self:GetSpecialValueFor("radius")
    if IsClient() then return end

    for _, unit in ipairs(self:GetCaster():FindAllUnitsInRadius(self:GetCaster():GetAbsOrigin(), self.radius)) do
        if unit:HasModifier("modifier_alchemist_acid_bomb_aura") then
            unit:RemoveModifierByName("modifier_alchemist_acid_bomb_aura")
        end
    end

    -- particles
    local particle = "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(effect, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(effect, 1, Vector(self.radius, 1, self.radius))
    self:AddEffect(effect)

    -- sounds
    local sound = "Hero_Alchemist.AcidSpray"
    EmitSoundOn(sound, self:GetParent())
end

modifier_alchemist_acid_bomb_aura = class({})
LinkLuaModifier( "modifier_alchemist_acid_bomb_aura", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_acid_bomb_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE  -- This allows stacking of multiple instances
end

function modifier_alchemist_acid_bomb_aura:IsHidden()
    return false
end
function modifier_alchemist_acid_bomb_aura:IsDebuff()
    return true
end
function modifier_alchemist_acid_bomb_aura:IsPurgable()
    return false
end
function modifier_alchemist_acid_bomb_aura:OnCreated()
    self:SetHasCustomTransmitterData(true)
    self:OnRefresh()
    
    if IsClient() then return end
    self.duration = 1
    self:StartIntervalThink(1.0)
end
function modifier_alchemist_acid_bomb_aura:OnRefresh()
    self.armor_reduction = self:GetSpecialValueFor("armor_reduction")
    self.damage = self:GetSpecialValueFor("damage")
    self.slow_per_second = self:GetSpecialValueFor("slow_per_second")
    self.maximum_slow = self:GetSpecialValueFor("maximum_slow")
end
function modifier_alchemist_acid_bomb_aura:OnIntervalThink()
    self.duration = self.duration + 1
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self:GetAbility()
    })
    self:SendBuffRefreshToClients()
end
function modifier_alchemist_acid_bomb_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_alchemist_acid_bomb_aura:GetModifierPhysicalArmorBonus()
    return -self.armor_reduction
end
function modifier_alchemist_acid_bomb_aura:GetModifierMoveSpeedBonus_Percentage()
    return -math.min(self.slow_per_second * self.duration, self.maximum_slow)
end
function modifier_alchemist_acid_bomb_aura:AddCustomTransmitterData()
    return {
        duration = tonumber(self.duration)
    }
end
function modifier_alchemist_acid_bomb_aura:HandleCustomTransmitterData(data)
    self.duration = tonumber(data.duration)
end

modifier_alchemist_acid_bomb_panacea = class({})
LinkLuaModifier( "modifier_alchemist_acid_bomb_panacea", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_acid_bomb_panacea:IsHidden()
    return true
end
function modifier_alchemist_acid_bomb_panacea:IsPurgable()
    return false
end
function modifier_alchemist_acid_bomb_panacea:IsAura()
    return true
end
function modifier_alchemist_acid_bomb_panacea:GetModifierAura()
    return "modifier_alchemist_acid_bomb_panacea_aura"
end
function modifier_alchemist_acid_bomb_panacea:GetAuraRadius()
    return self.radius
end
function modifier_alchemist_acid_bomb_panacea:GetAuraDuration()
    return 0.5
end
function modifier_alchemist_acid_bomb_panacea:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_alchemist_acid_bomb_panacea:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HEROES_AND_CREEPS
end
function modifier_alchemist_acid_bomb_panacea:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_alchemist_acid_bomb_panacea:OnCreated()
    self:OnRefresh()
end
function modifier_alchemist_acid_bomb_panacea:OnRefresh()
    self.radius = self:GetSpecialValueFor("radius")
    if IsClient() then return end

    for _, unit in ipairs(self:GetCaster():FindAllUnitsInRadius(self:GetCaster():GetAbsOrigin(), self.radius)) do
        if unit:HasModifier("modifier_alchemist_acid_bomb_panacea_aura") then
            unit:RemoveModifierByName("modifier_alchemist_acid_bomb_panacea_aura")
        end
    end
end

modifier_alchemist_acid_bomb_panacea_aura = class({})
LinkLuaModifier( "modifier_alchemist_acid_bomb_panacea_aura", "heroes/hero_alchemist/alchemist_acid_bomb", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_acid_bomb_panacea_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_alchemist_acid_bomb_panacea_aura:IsHidden()
    return false
end
function modifier_alchemist_acid_bomb_panacea_aura:IsDebuff()
    return false
end
function modifier_alchemist_acid_bomb_panacea_aura:IsPurgable()
    return false
end
function modifier_alchemist_acid_bomb_panacea_aura:OnCreated()
    self:OnRefresh()
    
    if IsClient() then return end
    self:StartIntervalThink(1.0)
end
function modifier_alchemist_acid_bomb_panacea_aura:OnRefresh()
    self.armor_bonus = self:GetSpecialValueFor("armor_reduction")
    self.heal = self:GetSpecialValueFor("damage")
end
function modifier_alchemist_acid_bomb_panacea_aura:OnIntervalThink()
    self:GetParent():Heal(self.heal, self:GetAbility())
end
function modifier_alchemist_acid_bomb_panacea_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end
function modifier_alchemist_acid_bomb_panacea_aura:GetModifierPhysicalArmorBonus()
    return self.armor_bonus
end