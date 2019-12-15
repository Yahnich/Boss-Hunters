boss_lifestealer_open_wounds = class({})

function boss_lifestealer_open_wounds:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
	local duration = self:GetTalentSpecialValueFor("duration")
    EmitSoundOn("Hero_LifeStealer.OpenWounds.Cast", target)
	if target:TriggerSpellAbsorb(self) then return end
    target:AddNewModifier(caster, self, "modifier_boss_lifestealer_open_wounds", {Duration = duration})
	target:ModifyThreat( 50 )
	caster:Taunt(self, target, duration / 2)
end

modifier_boss_lifestealer_open_wounds = class({})
LinkLuaModifier( "modifier_boss_lifestealer_open_wounds", "bosses/boss_lifestealer/boss_lifestealer_open_wounds.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_boss_lifestealer_open_wounds:OnCreated(table)
	self.vision = self:GetTalentSpecialValueFor("vision")
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal") / 100
	self.slow = self:GetTalentSpecialValueFor("slow")
	self.min_slow = self:GetTalentSpecialValueFor("min_slow")
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.min_duration = self:GetTalentSpecialValueFor("min_duration") * ( self:GetRemainingTime() / self.duration )
	self.slow_decay = ( (self.slow - self.min_slow) / (self:GetRemainingTime() - self.min_duration) )
    self:StartIntervalThink(1)
end

function modifier_boss_lifestealer_open_wounds:OnIntervalThink()
	self.slow = self.slow - self.slow_decay
end

function modifier_boss_lifestealer_open_wounds:DeclareFunctions()
    funcs = {
                MODIFIER_EVENT_ON_TAKEDAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_FIXED_DAY_VISION,
				MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
            }
    return funcs
end

function modifier_boss_lifestealer_open_wounds:OnTakeDamage(params)
    if IsServer() then
        if params.attacker:GetTeam() == self:GetCaster():GetTeam() then
            ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_open_wounds_impact.vpcf", PATTACH_POINT, self:GetCaster(), {[0]=params.unit:GetAbsOrigin()})
            local heal = params.damage * self.lifesteal
            params.attacker:HealEvent(heal, self:GetAbility(), self:GetCaster(), false)
        end
    end
end

function modifier_boss_lifestealer_open_wounds:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_boss_lifestealer_open_wounds:GetFixedDayVision()
    return self.vision
end

function modifier_boss_lifestealer_open_wounds:GetFixedNightVision()
    return self.vision
end

function modifier_boss_lifestealer_open_wounds:IsDebuff()
    return true
end

function modifier_boss_lifestealer_open_wounds:GetEffectName()
    return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end

function modifier_boss_lifestealer_open_wounds:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_open_wounds.vpcf"
end

function modifier_boss_lifestealer_open_wounds:StatusEffectPriority()
    return 10
end