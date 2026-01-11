juggernaut_decisive_judgement = class({})

function juggernaut_decisive_judgement:GetIntrinsicModifierName()
    return "modifier_juggernaut_decisive_judgement_passive"
end

modifier_juggernaut_decisive_judgement_passive = class({})
LinkLuaModifier("modifier_juggernaut_decisive_judgement_passive", "heroes/hero_juggernaut/juggernaut_decisive_judgement", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_decisive_judgement_passive:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_juggernaut_decisive_judgement_passive:OnCreated()
    self:OnRefresh()
end

function modifier_juggernaut_decisive_judgement_passive:OnRefresh()
    if IsServer() then
        self.crit_chance = self:GetSpecialValueFor("crit_chance")
        self.crit_mult = self:GetSpecialValueFor("crit_damage")

        self.bladeform_duration = self:GetSpecialValueFor("bladeform_duration")
        self.endurance_duration = self:GetSpecialValueFor("endurance_duration")
    end
end

function modifier_juggernaut_decisive_judgement_passive:IsHidden()
    return true
end

function modifier_juggernaut_decisive_judgement_passive:GetModifierPreAttack_CriticalStrike(params)
    if self:RollPRNG(self.crit_chance) then
        self.record = params.record
        return self.crit_mult
    end
end

function modifier_juggernaut_decisive_judgement_passive:GetCritDamage()
    return self.crit_mult / 100
end

function modifier_juggernaut_decisive_judgement_passive:OnAttackLanded(params)
    if IsServer() then
        local pass = false
        if self.record and params.record == self.record then
            pass = true
            self.record = nil
        end

        if pass then
            local parent = self:GetParent()
            local crit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf", PATTACH_CUSTOMORIGIN, parent)
            ParticleManager:SetParticleControlEnt(crit_fx, 0, parent, PATTACH_POINT_FOLLOW, attach_attack1, parent:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(crit_fx)
            EmitSoundOn("Hero_Juggernaut.BladeDance", parent)


            local bladeform = self:GetSpecialValueFor("bladeform_agi_bonus")
            local bladeform_buff = parent:FindModifierByName("modifier_juggernaut_decisive_judgement_bladeform")
            local endurance_buff = parent:FindModifierByName("modifier_juggernaut_decisive_judgement_endurance")

            local bladeform_stack_max = self:GetSpecialValueFor("bladeform_stack_max")
            local endurance_stack_max = self:GetSpecialValueFor("endurance_stack_max")

            if bladeform ~= 0 then
                if not bladeform_buff then
                    parent:AddNewModifier(parent, self:GetAbility(), "modifier_juggernaut_decisive_judgement_bladeform", {duration = self.bladeform_duration})
                    parent:FindModifierByName("modifier_juggernaut_decisive_judgement_bladeform"):SetStackCount(1)
                else
                    if bladeform_buff:GetStackCount() < bladeform_stack_max then
                        bladeform_buff:IncrementStackCount()
                        bladeform_buff:SetDuration(self.bladeform_duration, true)
                    end
                    if bladeform_buff:GetStackCount() == bladeform_stack_max then
                        bladeform_buff:SetDuration(self.bladeform_duration, true)
                    end
                end
            else
                if not endurance_buff then
                    parent:AddNewModifier(parent, self:GetAbility(), "modifier_juggernaut_decisive_judgement_endurance", {duration = self.endurance_duration})
                    parent:FindModifierByName("modifier_juggernaut_decisive_judgement_endurance"):SetStackCount(1)
                else
                    if endurance_buff:GetStackCount() < endurance_stack_max then
                        endurance_buff:IncrementStackCount()
                        endurance_buff:SetDuration(self.endurance_duration, true)
                    end
                    if endurance_buff:GetStackCount() == endurance_stack_max then
                        endurance_buff:SetDuration(self.endurance_duration, true)
                    end
                end
            end
        end
    end
end

modifier_juggernaut_decisive_judgement_bladeform = class({})
LinkLuaModifier("modifier_juggernaut_decisive_judgement_bladeform", "heroes/hero_juggernaut/juggernaut_decisive_judgement", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_decisive_judgement_bladeform:OnCreated()
    self:OnRefresh()
    if IsClient() then return end
    self:StartIntervalThink(0)
end

function modifier_juggernaut_decisive_judgement_bladeform:OnRefresh()
    self.bladeform_agi = self:GetSpecialValueFor("bladeform_agi_bonus") / 100
    if IsServer() then
		self:IncrementStackCount()
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_juggernaut_decisive_judgement_bladeform:OnIntervalThink()
    self:GetParent():CalculateStatBonus(true)
end

function modifier_juggernaut_decisive_judgement_bladeform:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_juggernaut_decisive_judgement_bladeform:OnTooltip()
    return self:GetSpecialValueFor("bladeform_agi_bonus")
end

function modifier_juggernaut_decisive_judgement_bladeform:GetModifierBonusStats_Agility(params)
    if self._lockedAgi then return end
	self._lockedAgi = true
	local agi = self:GetCaster():GetBaseAgility()
	self._lockedAgi = false
    return math.ceil(self.bladeform_agi * agi * self:GetStackCount())
end

function modifier_juggernaut_decisive_judgement_bladeform:GetEffectName()
    return "particles/units/heroes/hero_juggernaut/jugg_agility_boost.vpcf"
end

modifier_juggernaut_decisive_judgement_endurance = class({})
LinkLuaModifier("modifier_juggernaut_decisive_judgement_endurance", "heroes/hero_juggernaut/juggernaut_decisive_judgement", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_decisive_judgement_endurance:OnCreated()
    self:OnRefresh()
    if IsClient() then return end
end

function modifier_juggernaut_decisive_judgement_endurance:OnRefresh()
    self.restore = self:GetSpecialValueFor("endurance_restore_bonus")
end

function modifier_juggernaut_decisive_judgement_endurance:DeclareFunctions()
    return {MODIFIER_PROPERTY_RESTORATION_AMPLIFICATION, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_juggernaut_decisive_judgement_endurance:OnTooltip()
    return self.restore
end

function modifier_juggernaut_decisive_judgement_endurance:GetModifierPropertyRestorationAmplification()
    return self.restore * self:GetStackCount()
end

function modifier_juggernaut_decisive_judgement_endurance:GetEffectName()
    return "particles/units/heroes/hero_juggernaut/jugg_agility_boost.vpcf"
end
