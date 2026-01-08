sniper_rangefinder = class({})

function sniper_rangefinder:GetIntrinsicModifierName()
    return "modifier_sniper_rangefinder"
end

modifier_sniper_rangefinder = class({})
LinkLuaModifier("modifier_sniper_rangefinder", "heroes/hero_sniper/sniper_rangefinder", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_rangefinder:IsHidden()
    return true
end

function modifier_sniper_rangefinder:OnCreated()
    self:OnRefresh()
end

function modifier_sniper_rangefinder:OnRefresh()
    self.bonus_range = self:GetSpecialValueFor("bonus_range")
    self.bonus_bat = self:GetSpecialValueFor("bonus_attack_time")

    if IsServer() then
        if self.bonus_bat ~= 0 then
            self:GetParent():SetBaseAttackTime(self.bonus_bat)
        end
    end
end

function modifier_sniper_rangefinder:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_sniper_rangefinder:GetModifierAttackRangeBonus()
    return self.bonus_range
end

