	broodmother_hunger = class({})
LinkLuaModifier("modifier_broodmother_hunger", "heroes/hero_broodmother/broodmother_hunger", LUA_MODIFIER_MOTION_NONE)

function broodmother_hunger:OnSpellStart()
	local caster = self:GetCaster()
	
	local friends = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
    for _,friend in pairs(friends) do
        if friend:GetPlayerOwnerID() == caster:GetPlayerOwnerID() or caster:HasScepter() then
            friend:AddNewModifier(caster, self, "modifier_broodmother_hunger", {Duration = self:GetSpecialValueFor("duration")})
        end
    end
end

modifier_broodmother_hunger = class({})
function modifier_broodmother_hunger:OnCreated(table)
    if IsServer() then
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
                    ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_thorax", self:GetParent():GetAbsOrigin(), true)
        self:AttachEffect(nfx)
    end

    if self:GetCaster():HasTalent("special_bonus_unique_broodmother_hunger_2") then
        self.agi = self:GetCaster():FindTalentValue("special_bonus_unique_broodmother_hunger_2")
    end
end

function modifier_broodmother_hunger:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED,
                    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
                    MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
    return funcs
end

function modifier_broodmother_hunger:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            self:GetParent():Lifesteal(self:GetAbility(), self:GetSpecialValueFor("lifesteal_pct"), params.damage, params.target, DAMAGE_TYPE_PHYSICAL, DOTA_LIFESTEAL_SOURCE_NONE, true)
        end
    end
end

function modifier_broodmother_hunger:GetModifierBaseAttack_BonusDamage()
    return self:GetSpecialValueFor("bonus_damage")
end

function modifier_broodmother_hunger:GetModifierBonusStats_Agility()
    return self.agi
end

function modifier_broodmother_hunger:GetStatusEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_hunger_hero_effect.vpcf"
end

function modifier_broodmother_hunger:StatusEffectPriority()
    return 10
end