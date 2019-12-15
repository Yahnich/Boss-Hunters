kotl_blind = class({})
LinkLuaModifier( "modifier_kotl_blind_talent", "heroes/hero_kotl/kotl_blind.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_blind:IsStealable()
    return true
end

function kotl_blind:IsHiddenWhenStolen()
    return false
end

function kotl_blind:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
end

function kotl_blind:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function kotl_blind:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOnLocationWithCaster(point, "Hero_KeeperOfTheLight.BlindingLight", caster)

    ParticleManager:FireParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf", PATTACH_POINT, caster, {[0]="attach_attack1", [1]=point, [2]="attach_attack1"})

    local miss_rate = self:GetSpecialValueFor("miss_rate")
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local knockback_duration = self:GetSpecialValueFor("knockback_duration")
    local knockback_distance = self:GetSpecialValueFor("knockback_distance")
    local damage = self:GetSpecialValueFor("damage")

    if caster:HasTalent("special_bonus_unique_kotl_blind_1") then
        knockback_distance = -knockback_distance
    end

    AddFOWViewer(caster:GetTeam(), point, radius, knockback_duration, true)

    GridNav:DestroyTreesAroundPoint(point, radius, false)

    local enemies = caster:FindEnemyUnitsInRadius(point, radius)
    for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:Blind(miss_rate, self, caster, duration)
			enemy:ApplyKnockBack(point, knockback_duration, knockback_duration, knockback_distance, 50, caster, self)
			self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
    end

    if caster:HasTalent("special_bonus_unique_kotl_blind_2") then
        local duration = caster:FindTalentValue("special_bonus_unique_kotl_blind_2", "duration")
        local allies = caster:FindFriendlyUnitsInRadius(point, radius)
        for _,ally in pairs(allies) do
            ally:AddNewModifier(caster, self, "modifier_kotl_blind_talent", {Duration = duration})
        end
    end
end

modifier_kotl_blind_talent = class({})
function modifier_kotl_blind_talent:OnCreated(table)
    self.bonus_accuracy = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_blind_2", "bonus_accuracy")
end

function modifier_kotl_blind_talent:OnRefresh(table)
    self.bonus_accuracy = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_blind_2", "bonus_accuracy")
end

function modifier_kotl_blind_talent:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TOOLTIP
    }
    return funcs
end

function modifier_kotl_blind_talent:OnTooltip()
    return self.bonus_accuracy
end

function modifier_kotl_blind_talent:GetAccuracy()
    return self.bonus_accuracy
end

function modifier_kotl_blind_talent:IsDebuff()
    return false
end

function modifier_kotl_blind_talent:IsPurgable()
    return true
end

function modifier_kotl_blind_talent:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end