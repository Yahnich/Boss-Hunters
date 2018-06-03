broodmother_web = class({})
LinkLuaModifier("modifier_broodmother_web_aura", "heroes/hero_broodmother/broodmother_web", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_web", "heroes/hero_broodmother/broodmother_web", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_web_enemy", "heroes/hero_broodmother/broodmother_web", LUA_MODIFIER_MOTION_NONE)

function broodmother_web:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_broodmother_web_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_broodmother_web_1") end
    return cooldown
end

function broodmother_web:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

    EmitSoundOn("Hero_Broodmother.SpinWebCast", caster)
    local radius = self:GetTalentSpecialValueFor("radius")
    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spin_web_cast.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
                ParticleManager:SetParticleControl(nfx, 1, point)
                ParticleManager:SetParticleControl(nfx, 2, Vector(radius,radius,radius))
                ParticleManager:SetParticleControl(nfx, 3, Vector(radius,radius,radius))
                ParticleManager:ReleaseParticleIndex(nfx)

    local dummies = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag=DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
    for _,dummy2 in pairs(dummies) do
        if dummy2:HasModifier("modifier_broodmother_web_aura") then
            dummy2:RemoveSelf()
        end
    end
    local dummy = caster:CreateDummy(point)
    dummy:AddNewModifier(caster, self, "modifier_broodmother_web_aura", {})
end

modifier_broodmother_web_aura = class({})
function modifier_broodmother_web_aura:OnCreated(table)
    if IsServer() then
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/brood_web.vpcf", PATTACH_POINT, self:GetCaster())
                    ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
                    local radius = self:GetTalentSpecialValueFor("radius")
                    ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
        self:AttachEffect(nfx)
        self:StartIntervalThink(0.1)
    end
end

function modifier_broodmother_web_aura:OnIntervalThink()
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_broodmother_web_enemy", {Duration = 0.5})
    end
end

function modifier_broodmother_web_aura:GetAuraEntityReject(hEntity)
    if hEntity:GetPlayerOwnerID() ~= self:GetCaster():GetPlayerOwnerID() then
        return true
    end
end

function modifier_broodmother_web_aura:IsAura()
    return true
end

function modifier_broodmother_web_aura:GetAuraDuration()
    return 0.5
end

function modifier_broodmother_web_aura:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_broodmother_web_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_broodmother_web_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_broodmother_web_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_broodmother_web_aura:GetModifierAura()
    return "modifier_broodmother_web"
end

function modifier_broodmother_web_aura:IsAuraActiveOnDeath()
    return false
end

function modifier_broodmother_web_aura:IsHidden()
    return true
end

function modifier_broodmother_web_aura:CheckState()
    return {[MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_NO_TEAM_SELECT] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
        }
end

modifier_broodmother_web = class({})
function modifier_broodmother_web:IsHidden() return false end
function modifier_broodmother_web:IsDebuff() return false end

function modifier_broodmother_web:OnCreated(table)
    if IsServer() then
        AddAnimationTranslate(self:GetParent(), "web")
    end
end

function modifier_broodmother_web:OnRemoved()
    if IsServer() then
        RemoveAnimationTranslate(self:GetParent())
    end
end

function modifier_broodmother_web:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_broodmother_web:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("bonus_movespeed")
end

function modifier_broodmother_web:GetModifierHealthRegenPercentage()
    return self:GetTalentSpecialValueFor("heath_regen")
end

function modifier_broodmother_web:CheckState()
    return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
        }
end

modifier_broodmother_web_enemy = class({})
function modifier_broodmother_web_enemy:IsHidden() return false end
function modifier_broodmother_web_enemy:IsDebuff() return true end

function modifier_broodmother_web_enemy:OnCreated(table)
    self.move = -self:GetTalentSpecialValueFor("bonus_movespeed")/2
    if self:GetCaster():HasTalent("special_bonus_unique_broodmother_web_2") then
        self.move = -self:GetTalentSpecialValueFor("bonus_movespeed")
    end
    self:StartIntervalThink(0.1)
end

function modifier_broodmother_web_enemy:OnIntervalThink()
    self.move = -self:GetTalentSpecialValueFor("bonus_movespeed")/2
    if self:GetCaster():HasTalent("special_bonus_unique_broodmother_web_2") then
        self.move = -self:GetTalentSpecialValueFor("bonus_movespeed")
    end
end

function modifier_broodmother_web_enemy:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_broodmother_web_enemy:GetModifierMoveSpeedBonus_Percentage()
    return self.move
end